# ManyType Server Security Boundary

## Deployment status

`manytype_server` is approved only for a private canary. It is not approved for
an Internet-facing deployment.

Run it on loopback, an authenticated overlay network, or a private interface
protected by a firewall allowlist. Do not publish its QUIC port in public DNS or
open that port to the Internet. The packaged runtime now enforces account and
peer allowlists, bounded resources, structured lifecycle logs, and an explicit
production-mode prohibition. It still lacks the complete ACL semantics and
field evidence required for public operation. See `deploy/RUNBOOK.md` for the
private-canary boundary.

## Protected assets

- Account and peer identities.
- Space headers, ACL records, settings, object changes, and sync heads.
- Private file blocks and their space/file bindings.
- The generated server identity and signing key.
- Availability of the QUIC listener, redb databases, and blob filesystem.

## Trust boundaries

1. QUIC authenticates the libp2p peer ID from the client TLS certificate.
2. The connection credential handshake proves control of an Ed25519 account
   key by signing the client and server peer IDs.
3. `AuthenticatedPeer` carries both proven identities into DRPC dispatch. Empty,
   malformed, or non-allowlisted identities are rejected at the connection
   boundary before DRPC streams are accepted, then checked again before
   a scoped handler runs.
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
| Denial of service | Bounded connection/stream setup and complete-frame I/O deadlines; transport idle timeout; bounded handshakes, messages, blobs, connections, streams, logical sync state, and file-index metadata | No per-principal request/CPU budget; an allowed peer can sustain complete-frame or control traffic; transient collection limits, physical database-size quota, and production capacity evidence remain incomplete |
| Elevation of privilege | Header account binding and immutable peer ownership close first-claim and ownership-replacement paths | No persisted ACL evaluator for readers/writers, invite redemption, revocation, or device authorization |

## Public-deployment blockers

Resolve and test all of these before reconsidering an Internet-facing service:

1. Add method-specific limits for protobuf collections, object changes, store
   values, ACL records, and other work that can be expensive below the bounded
   message-size ceiling.
2. Extend the single-process logical quota reservations to physical database
   allocation, stale-page reclamation, crash recovery, cleanup failures, and
   independently writing processes.
3. Add per-principal request-rate and CPU budgets for active traffic, including
   repeated complete control or zero-length frames, plus production capacity
   evidence beyond the current deadlines and concurrency caps.
4. Implement real authorized account, space, and file teardown plus an
   authenticated `AccountRevertDeletion`; `AccountDelete` currently verifies
   its signed, content-addressed, fresh credential-bound confirmation but only
   persists the replay marker.
5. Implement and persist ACL reader/writer evaluation, invitation redemption,
   expiry, revocation, and multi-device enrollment without making ownership
   mutable.
6. Put authentication, quotas, expiry, garbage collection, and abuse controls
   around public invite uploads. Document bearer-CID leakage behavior.
7. Extend structured runtime logs and minimal health checks with durable,
   principal-bound security audit events, metrics, alerts, and retention.
8. Exercise offline backup/restore on the deployment host and define retention,
   full blob/database consistency checks, disaster recovery, and server identity
   recovery and rotation procedures.
9. Add protocol fuzzing and adversarial integration tests for malformed frames,
   protobufs, signatures, CIDs, paths, partial writes, and concurrent claims.

## Private-canary checklist

- Bind only to the intended loopback, private, or overlay address.
- Enforce a network firewall allowlist independently of this process.
- Protect the generated `identity.key` with restrictive permissions and a
  separate encrypted host backup; never place it in the server configuration.
- Store databases and blobs on a private volume with backups and monitored free
  space.
- Limit access to trusted clients while the owner-only model is in effect.
- Review logs and disk growth during the canary; stop the service on unexpected
  traffic or unbounded growth.
- Keep a tested way to revoke network access immediately.

Run the locked server tests before each canary build:

```sh
cargo test --locked -p manytype_server
```
