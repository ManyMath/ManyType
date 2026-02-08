#!/usr/bin/env bash

set -euo pipefail

# Prerequisites:
#   1. docker compose up -d in docker/any-sync/ (oracle stack must be running)
#   2. cargo build -p manytype_quic_ffi --release (FFI lib must be built)
#   3. dart pub get in packages/manytype_cli/ (Dart deps resolved)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ORACLE_ARTIFACT_PATH="${ORACLE_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/oracle-capture-artifact.json}"
ORACLE_METADATA_PATH="${ORACLE_METADATA_PATH:-$ROOT_DIR/test_vectors/oracle-capture-metadata.json}"
TMPDIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMPDIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

oracle_run_preflight
oracle_export_runtime_env
export ROOT_DIR
export TMPDIR
export ORACLE_ARTIFACT_PATH

printf 'Running oracle capture against docker oracle...\n'

timeout 120s bash -lc '
  set -euo pipefail
  export ORACLE_ARTIFACT_PATH="$ORACLE_ARTIFACT_PATH"
  cd "$ROOT_DIR"
  dart test packages/manytype_cli/test/oracle_sync_preflight_test.dart
'

if [[ ! -f "$ORACLE_ARTIFACT_PATH" ]]; then
  printf 'FAIL: oracle capture artifact was not written: %s\n' "$ORACLE_ARTIFACT_PATH" >&2
  exit 1
fi

oracle_write_metadata \
  "$ORACLE_METADATA_PATH" \
  "oracle preflight capture against the self-hosted official Any-Sync stack" \
  "$ROOT_DIR/docker/any-sync/etc/client.yml" \
  "" \
  "$ORACLE_ARTIFACT_PATH"

python3 - "$ORACLE_ARTIFACT_PATH" <<'PYEOF'
import json
import sys

data = json.load(open(sys.argv[1]))
events = data.get("events", [])
methods = {e.get("method", "") for e in events if e.get("type") == "unary_rpc"}
required = {
    "/coordinator.Coordinator/NetworkConfiguration",
    "/coordinator.Coordinator/SpaceStatusCheck",
    "/coordinator.Coordinator/SpaceSign",
    "/spacesync.SpaceSync/SpacePush",
    "/spacesync.SpaceSync/HeadSync",
    "/spacesync.SpaceSync/StoreDiff",
}
missing = required - methods
if missing:
    print("FAIL: artifact missing required RPC methods:", missing, file=sys.stderr)
    sys.exit(1)

ordered = [e.get("method", "") for e in events if e.get("type") == "unary_rpc"]
def idx(method):
    try:
        return ordered.index(method)
    except ValueError:
        return -1

network_index = idx("/coordinator.Coordinator/NetworkConfiguration")
status_index = idx("/coordinator.Coordinator/SpaceStatusCheck")
sign_index = idx("/coordinator.Coordinator/SpaceSign")
push_index = idx("/spacesync.SpaceSync/SpacePush")

if not (network_index >= 0 and status_index > network_index and sign_index > status_index and push_index > sign_index):
    print(
        "FAIL: RPC ordering is invalid; expected "
        "NetworkConfiguration -> SpaceStatusCheck -> SpaceSign -> SpacePush",
        file=sys.stderr,
    )
    sys.exit(1)

print(
    f"OK: artifact contains {len(events)} events, all required RPC methods present, "
    "and preflight ordering is correct"
)
PYEOF

printf 'Oracle capture artifact written to: %s\n' "$ORACLE_ARTIFACT_PATH"
printf 'Oracle metadata written to: %s\n' "$ORACLE_METADATA_PATH"
printf 'oracle_capture.sh: PASSED\n'
