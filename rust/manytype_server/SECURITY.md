# ManyType Server Security Boundary

## Deployment status

`manytype_server` is approved only for a private canary. It is not approved for
an Internet-facing deployment.

Run it on loopback, an authenticated overlay network, or a private interface
protected by a firewall allowlist. Do not publish its QUIC port in public DNS or
open that port to the Internet. The server does not yet provide the resource
controls, audit trail, or complete ACL semantics required for public operation.

## Protected assets

- Account and peer identities.
- Space headers, ACL records, settings, object changes, and sync heads.
- Private file blocks and their space/file bindings.
- The server identity seed and signing key.
- Availability of the QUIC listener, redb databases, and blob filesystem.

## Trust boundaries

1. QUIC authenticates the libp2p peer ID from the client TLS certificate.
2. The connection credential handshake proves control of an Ed25519 account
   key by signing the client and server peer IDs.
3. `AuthenticatedPeer` carries both proven identities into DRPC dispatch. Empty
   or malformed identities are rejected before a scoped handler runs.
4. A first `SpaceSign` claim is accepted only when the space header:
   - is signed by its embedded Ed25519 account key;
   - contains the account key proven by the credential handshake; and
   - has the expected content-addressed ID and base36 replication suffix.
5. The first authenticated peer ID is persisted as owner. Repeating the claim
   as that peer is idempotent; replacing it is rejected, including after restart.

## Current authorization model

Authorization is deliberately conservative: the persisted owner peer is the
only principal allowed to access a private space.

- Sync heads, store values, space payloads, object changes, subscriptions, and
  consensus log mutations require ownership.
- ACL reads, ACL writes, share-state changes, and space deletion requests require
  ownership.
- Private block checks conceal existence from other peers. Private block reads,
  uploads, binding, deletion requests, and usage details require ownership.
- `SpaceStatusCheck` reports an unauthorized or unknown space as not existing.
- Account-level file usage contains only spaces owned by the authenticated peer.
- Marking a space shared does not currently grant another peer access. Persisted
  ACL membership evaluation is not implemented yet.

Two capability-style invite operations are intentional exceptions:

- `AclUploadInvite` accepts invite bytes and marks the resulting blob public.
- `BlockGet` and `BlocksCheck` expose a blob marked as a public invite without
  requiring space ownership.

Treat an invite CID as a bearer capability. The unauthenticated upload surface
is one reason public deployment remains disabled.

## Threat review

| STRIDE area | Current control | Remaining exposure |
| --- | --- | --- |
| Spoofing | libp2p TLS peer authentication plus an account-signed credential handshake; space claims bind both identities | No account/device enrollment, recovery, rotation, or revocation workflow |
| Tampering | Signed and content-addressed space headers; immutable first owner; receipt validation; owner checks before scoped mutations | ACL record signatures and semantic permissions need complete validation; delete RPCs are stubs |
| Repudiation | Structured tracing records method-level activity | No durable, principal-bound security audit log or retention policy |
| Information disclosure | Owner-only reads; hidden space status and private blob availability | Public invite CIDs are bearer capabilities; metadata/log review and ACL member reads remain incomplete |
| Denial of service | Handshake messages have a size limit | DRPC frames, reassembled messages, request collections, connections, and storage have no adequate limits |
| Elevation of privilege | Header account binding and immutable peer ownership close first-claim and ownership-replacement paths | No persisted ACL evaluator for readers/writers, invite redemption, revocation, or device authorization |

## Public-deployment blockers

Resolve and test all of these before reconsidering an Internet-facing service:

1. Add strict maximum sizes for DRPC frames, reassembled messages, protobuf
   collections, object changes, store values, ACL records, and blob uploads.
2. Replace the advertised 1 PiB placeholder with enforced per-account and
   per-space quotas, including atomic reservation and cleanup on failure.
3. Add connection, stream, request-rate, concurrency, and idle-time limits.
4. Validate or safely encode every space ID before constructing a database path;
   migrate or reject malformed legacy IDs.
5. Authenticate and bind `AccountDelete` to the credential account, verify its
   signature, and implement real authorized deletion for spaces and files.
6. Implement and persist ACL reader/writer evaluation, invitation redemption,
   expiry, revocation, and multi-device enrollment without making ownership
   mutable.
7. Put authentication, quotas, expiry, garbage collection, and abuse controls
   around public invite uploads. Document bearer-CID leakage behavior.
8. Add durable security audit events, metrics, alerts, health reporting, and
   failure-state visibility without logging content or secrets.
9. Define backup/restore, database and blob consistency checks, retention,
   disaster recovery, and server identity rotation procedures.
10. Protect the server identity seed with an appropriate secret store and strict
    filesystem permissions. Reject the development seed outside tests.
11. Add protocol fuzzing and adversarial integration tests for malformed frames,
    protobufs, signatures, CIDs, paths, partial writes, and concurrent claims.

## Private-canary checklist

- Bind only to the intended loopback, private, or overlay address.
- Enforce a network firewall allowlist independently of this process.
- Generate a unique server identity seed and restrict its configuration file.
- Store databases and blobs on a private volume with backups and monitored free
  space.
- Limit access to trusted clients while the owner-only model is in effect.
- Review logs and disk growth during the canary; stop the service on unexpected
  traffic or unbounded growth.
- Keep a tested way to revoke network access immediately.

Run the locked server tests before each canary build:

```sh
cargo test -p manytype_server --locked
```
