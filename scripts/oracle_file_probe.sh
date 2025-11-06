#!/usr/bin/env bash

set -euo pipefail

# Prerequisites:
#   1. docker compose up -d in docker/any-sync/ (oracle stack must be running)
#   2. cargo build -p manytype_quic_ffi --release (FFI lib must be built)
#   3. dart pub get in packages/manytype_cli/ (Dart deps resolved)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE_PROBE_ARTIFACT_PATH="${FILE_PROBE_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/file-node-probe-artifact.json}"
TMPDIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMPDIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export ROOT_DIR
export TMPDIR
export FILE_PROBE_ARTIFACT_PATH

printf 'Running file-node probe against docker oracle...\n'

timeout 120s bash -lc '
  set -euo pipefail
  export HOME="$TMPDIR"
  export MANYTYPE_FILE_CAPTURE_PATH="$FILE_PROBE_ARTIFACT_PATH"
  cd "$ROOT_DIR"
  dart run packages/manytype_cli/bin/manytype.dart init >/dev/null
  dart run packages/manytype_cli/bin/manytype.dart \
    --network-config docker/any-sync/etc/client.yml \
    probe-file-node
'

if [[ ! -f "$FILE_PROBE_ARTIFACT_PATH" ]]; then
  printf 'FAIL: file probe artifact was not written: %s\n' "$FILE_PROBE_ARTIFACT_PATH" >&2
  exit 1
fi

python3 - "$FILE_PROBE_ARTIFACT_PATH" <<'PYEOF'
import json
import sys

data = json.load(open(sys.argv[1]))
events = data.get("events", [])
methods = {(e.get("method") or "") for e in events if e.get("type") in {"unary_rpc", "rpc_error"}}
required = {
    "/coordinator.Coordinator/NetworkConfiguration",
    "/filesync.File/Check",
    "/filesync.File/BlocksCheck",
    "/filesync.File/BlockGet",
    "/filesync.File/BlockPush",
}
missing = required - methods
if missing:
    print("FAIL: artifact missing required probe methods:", missing, file=sys.stderr)
    sys.exit(1)

print(
    f"OK: file probe artifact contains {len(events)} events and all required probe methods"
)
PYEOF

printf 'File probe artifact written to: %s\n' "$FILE_PROBE_ARTIFACT_PATH"
printf 'oracle_file_probe.sh: PASSED\n'
