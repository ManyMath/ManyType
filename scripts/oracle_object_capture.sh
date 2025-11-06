#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ORACLE_ARTIFACT_PATH="${PHASE27_OBJECT_TRUTH_PATH:-$ROOT_DIR/test_vectors/phase27-object-truth.json}"
export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export ROOT_DIR

printf 'Running oracle object sync capture...\n'

timeout 180s bash -lc '
  set -euo pipefail
  export PHASE27_OBJECT_TRUTH_PATH="$ORACLE_ARTIFACT_PATH"
  cd "$ROOT_DIR"
  dart test packages/manytype_cli/test/oracle_object_sync_test.dart
'

if [[ ! -f "$ORACLE_ARTIFACT_PATH" ]]; then
  printf 'FAIL: oracle object capture artifact was not written: %s\n' "$ORACLE_ARTIFACT_PATH" >&2
  exit 1
fi

python3 - "$ORACLE_ARTIFACT_PATH" <<'PYEOF'
import json
import sys

data = json.load(open(sys.argv[1]))
events = data.get("events", [])
methods = {e.get("method", "") for e in events if e.get("type") in ("unary_rpc", "stream_rpc")}
required = {
    "/coordinator.Coordinator/NetworkConfiguration",
    "/coordinator.Coordinator/SpaceStatusCheck",
    "/coordinator.Coordinator/SpaceSign",
    "/spacesync.SpaceSync/SpacePush",
    "/spacesync.SpaceSync/HeadSync",
}
# We expect at least one ObjectSync call (unary or stream)
object_sync_found = any("ObjectSync" in m for m in methods)

missing = required - methods
if missing:
    print("FAIL: artifact missing required RPC methods:", missing, file=sys.stderr)
    sys.exit(1)

if not object_sync_found:
    print("FAIL: artifact missing ObjectSync RPC", file=sys.stderr)
    sys.exit(1)

print(
    f"OK: artifact contains {len(events)} events, all required RPC methods present, "
    "including ObjectSync"
)
PYEOF

printf 'Oracle object capture artifact written to: %s\n' "$ORACLE_ARTIFACT_PATH"
printf 'oracle_object_capture.sh: PASSED\n'
