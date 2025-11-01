#!/usr/bin/env bash

set -euo pipefail

# Prerequisites:
#   1. docker compose up -d in docker/any-sync/ (oracle stack must be running)
#   2. cargo build -p manytype_quic_ffi --release (FFI lib must be built)
#   3. dart pub get in packages/manytype_cli/ (Dart deps resolved)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ORACLE_ARTIFACT_PATH="${ORACLE_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/oracle-capture-artifact.json}"
TMPDIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMPDIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export ROOT_DIR
export TMPDIR
export ORACLE_ARTIFACT_PATH

printf 'Running oracle capture against docker oracle...\n'

timeout 120s bash -lc '
  set -euo pipefail
  export HOME="$TMPDIR"
  export MANYTYPE_SYNC_CAPTURE_PATH="$ORACLE_ARTIFACT_PATH"
  cd "$ROOT_DIR"
  dart run packages/manytype_cli/bin/manytype.dart init
  dart run packages/manytype_cli/bin/manytype.dart create "oracle-capture-probe"
  dart run packages/manytype_cli/bin/manytype.dart \
    --network-config docker/any-sync/etc/client.yml sync
'

if [[ ! -f "$ORACLE_ARTIFACT_PATH" ]]; then
  printf 'FAIL: oracle capture artifact was not written: %s\n' "$ORACLE_ARTIFACT_PATH" >&2
  exit 1
fi

python3 - "$ORACLE_ARTIFACT_PATH" <<'PYEOF'
import json
import sys

data = json.load(open(sys.argv[1]))
events = data.get("events", [])
methods = {e.get("method", "") for e in events if e.get("type") == "unary_rpc"}
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
print(f"OK: artifact contains {len(events)} events, all required RPC methods present")
PYEOF

printf 'Oracle capture artifact written to: %s\n' "$ORACLE_ARTIFACT_PATH"
printf 'oracle_capture.sh: PASSED\n'
