#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

export ORACLE_ARTIFACT_PATH="${PHASE27_OBJECT_TRUTH_PATH:-$ROOT_DIR/test_vectors/phase27-object-truth.json}"
ORACLE_METADATA_PATH="${ORACLE_METADATA_PATH:-$ROOT_DIR/test_vectors/phase27-object-truth-metadata.json}"
oracle_run_preflight
oracle_export_runtime_env
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

oracle_write_metadata \
  "$ORACLE_METADATA_PATH" \
  "oracle object sync capture against the self-hosted official Any-Sync stack" \
  "$ROOT_DIR/docker/any-sync/etc/client.yml" \
  "" \
  "$ORACLE_ARTIFACT_PATH"

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
printf 'Oracle metadata written to: %s\n' "$ORACLE_METADATA_PATH"
printf 'oracle_object_capture.sh: PASSED\n'
