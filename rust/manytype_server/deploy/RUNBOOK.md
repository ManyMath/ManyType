# ManyType private sync canary

This package is only for a private two-device canary. The binary rejects
`deployment_mode = "production"`; do not put its QUIC listener on an
unrestricted public address, publish it through a public tunnel, or describe a
canary as proven until both intended devices complete the sync exercise.

## Build and validate

From `rust/`:

```sh
cargo fmt --all -- --check
cargo clippy --locked -p manytype_server --all-targets -- -D warnings
cargo test --workspace --locked
cargo build --release --locked -p manytype_server
./manytype_server/deploy/test-deployment.sh
```

The smoke starts the release binary on loopback, checks minimal health and
readiness responses, proves that the data lock blocks a live backup, sends
`SIGTERM`, checks the structured shutdown event, and performs a backup/restore.

## Private host preparation

Record the authenticated account identity and transport peer ID from a device
using the canary recovery phrase. `Identity.fromMnemonic` deterministically
derives the same transport peer identity on both same-phrase devices, so that
peer ID goes in `allowed_peer_ids` and the account identity goes in
`allowed_account_identities`. These values are identifiers, not recovery
phrases or private keys. Never put a recovery phrase, identity seed, or server
`identity.key` in the configuration.

This shared deterministic peer identity is what lets the current immutable
owner check authorize devices A and B. A device with a genuinely distinct peer
identity remains denied even if it proves the same account identity. Supporting
that case requires an explicit authenticated device-admission or ownership
transfer protocol; do not weaken the owner check to work around it.

Use a host reachable only through the operator's private network or an IP
allowlisted firewall. Permit inbound UDP/33020 only from the two device egress
addresses or the private VPN subnet. Keep TCP/33021 on loopback. A Cloudflare
HTTP tunnel cannot carry this QUIC/UDP protocol and is not part of this canary.

Create the service user and configuration:

```sh
sudo useradd --system --home-dir /var/lib/manytype --shell /usr/sbin/nologin manytype
sudo install -d -o manytype -g manytype -m 0700 /var/lib/manytype
sudo install -d -o root -g manytype -m 0750 /etc/manytype
sudo install -o root -g root -m 0755 target/release/manytype_server /usr/local/bin/manytype_server
sudo install -o root -g manytype -m 0640 manytype_server/deploy/server.toml.example /etc/manytype/server.toml
sudo install -o root -g root -m 0644 manytype_server/deploy/manytype-server.service /etc/systemd/system/manytype-server.service
```

Replace every placeholder in `/etc/manytype/server.toml`, set the private host
address advertised by `quic_listen`, then validate before enabling anything:

```sh
sudo -u manytype /usr/local/bin/manytype_server check-config --config /etc/manytype/server.toml
sudo systemctl daemon-reload
sudo systemctl enable --now manytype-server.service
curl --fail http://127.0.0.1:33021/healthz
curl --fail http://127.0.0.1:33021/readyz
journalctl -u manytype-server.service -o json-pretty
```

The first start creates `/var/lib/manytype/identity.key` once with mode `0600`.
Changing or deleting it changes the server peer identity and invalidates the
address clients trust.

## Backup and restore

Snapshots are offline by design. They contain sync Redb files and file blobs,
but not `identity.key`. Keep the identity key in the host's separate encrypted
system backup.

```sh
sudo systemctl stop manytype-server.service
sudo -u manytype manytype_server backup --config /etc/manytype/server.toml --output /srv/backups/manytype-$(date +%Y%m%dT%H%M%SZ)
sudo systemctl start manytype-server.service
```

Restore validates the snapshot format and both database schemas in a staging
directory before replacing current data:

```sh
sudo systemctl stop manytype-server.service
sudo -u manytype manytype_server restore --config /etc/manytype/server.toml --input /srv/backups/manytype-SNAPSHOT --force
sudo systemctl start manytype-server.service
curl --fail http://127.0.0.1:33021/readyz
```

## Canary proof

Use a disposable workspace with a text object and a small attachment. Configure
device A, sync, then configure device B with the same account and confirm the
object and attachment arrive. Edit on B and confirm the change arrives on A.
Restart the service and both clients, repeat one edit in each direction, then
capture timestamps and the `server_ready`, authorization failure (from a
non-allowlisted test peer), and `shutdown_complete` journal events. Finally,
perform an offline backup, delete only the disposable workspace data, restore,
and confirm both devices converge again.

Required external evidence that this repository cannot fabricate:

- the real account identity and shared same-phrase device peer ID;
- a private host or VPN address reachable by both devices over UDP;
- firewall rules restricting UDP/33020 to those devices or that VPN;
- the native client transport wired to this server configuration;
- observed two-way object and attachment convergence across restart and restore.

Until all five exist, the server is packaged and locally controllable, but a
real two-device canary remains blocked and public deployment remains prohibited.
