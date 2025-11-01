# Oracle Capture Artifact Rationale

## Why Literal QLOG Was Not Used

QLOG is defined at the QUIC transport layer. Any-Sync encrypts its application payload with TLS
1.3 inside the QUIC stream; without the TLS master secret log the QLOG records contain opaque
encrypted blobs. Upstream Any-Sync tooling (`any-sync-coordinator`, `any-sync-node`) does not
expose an `SSLKEYLOGFILE` hook or equivalent, and the Rust `quinn` crate used by
`manytype_quic_ffi` does not enable QUIC event logging by default. Obtaining a useful QLOG file
would require either a patched `quinn` build with key material export or a TLS MITM proxy, both
far outside the scope of regression coverage for this protocol layer.

## What the Artifact Captures Instead

The capture mechanism is implemented in `packages/manytype_cli/lib/src/commands/sync.dart` inside
the `_SessionCapture` class. When `MANYTYPE_SYNC_CAPTURE_PATH` is set, every DRPC unary and
streaming RPC is serialized before and after the call:

- The protobuf request and response bytes are base64-encoded and stored verbatim.
- Stream RPCs record each framed message in order.
- Metadata events record connection roles, addresses, and terminal outcomes.

The resulting JSON artifact (`test_vectors/oracle-capture-artifact.json`) contains:

- `official_interop_mode: true` to confirm the capture was taken against a real Any-Sync oracle,
  not our Rust server.
- All five required RPC method invocations in sequence:
  `/coordinator.Coordinator/NetworkConfiguration`,
  `/coordinator.Coordinator/SpaceSign`,
  `/spacesync.SpaceSync/SpacePush`,
  `/spacesync.SpaceSync/HeadSync`,
  `/spacesync.SpaceSync/StoreDiff` plus `StoreElements` when store diffs exist.
- Raw protobuf bytes for each request and response, decodable with `protoc --decode_raw` or any
  proto library given the schema in `packages/manytype_protocol/`.

## Why This Is Sufficient for Regression Coverage

The regression intent of `ORACLE-03` is to prove that our client can drive a full coordinator plus
sync-node protocol flow against real Any-Sync infrastructure and to give future agents a
replayable reference. The protocol-level DRPC/protobuf capture satisfies this because:

1. **Completeness**: every protocol message that crossed the wire at the application layer is
   recorded, including full protobuf bytes. A future agent can decode any field.
2. **Reproducibility**: `scripts/oracle_capture.sh` is a self-contained script that regenerates
   the artifact from a running docker oracle. The regeneration procedure exits non-zero if any
   required RPC method is absent, so regressions are caught automatically.
3. **Scope match**: the protocol compliance question is whether our client completed the correct
   RPC sequence against the oracle. That is answered at the DRPC/protobuf layer, not the QUIC
   transport layer.

QLOG adds value when debugging QUIC-layer handshake or flow-control problems. Those concerns are
covered by Phase 9 (`HNDSHK-01` through `HNDSHK-03`) and Phase 11 (`any-sync-netcheck`), which
operate at the transport layer directly. `ORACLE-03` is specifically about oracle session
evidence, which is a higher-level concern.

## Regenerating the Artifact

```bash
# Prerequisites
cd docker/any-sync && docker compose up -d && cd -
cargo build -p manytype_quic_ffi --release

# Regenerate
bash scripts/oracle_capture.sh
```

The script overwrites `test_vectors/oracle-capture-artifact.json` and validates it before exiting.

## Verifying a Checked-In Artifact

```bash
python3 - test_vectors/oracle-capture-artifact.json <<'PYEOF'
import json, sys
data = json.load(open(sys.argv[1]))
events = data.get("events", [])
methods = {e.get("method","") for e in events if e.get("type") == "unary_rpc"}
required = {
  "/coordinator.Coordinator/NetworkConfiguration",
  "/coordinator.Coordinator/SpaceSign",
  "/spacesync.SpaceSync/SpacePush",
  "/spacesync.SpaceSync/HeadSync",
  "/spacesync.SpaceSync/StoreDiff",
}
missing = required - methods
if missing:
  print("FAIL: artifact missing required RPC methods:", missing, file=sys.stderr)
  sys.exit(1)
print(f"OK: {len(events)} events, all required RPC methods present")
PYEOF
```
