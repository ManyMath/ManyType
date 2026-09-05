#!/usr/bin/env bash

set -euo pipefail

# Prerequisites:
#   1. cargo build -p manytype_quic_ffi --release
#   2. dart pub get in packages/manytype_cli/
#   3. network.anytype.io.yml exists at repo root
#
# Output goes to a fresh temp dir. To refresh the checked-in fixture, set
# LIVE_ARTIFACT_PATH to the absolute path of
# test_vectors/live-file-node-probe-artifact.json.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIVE_ARTIFACT_PATH="${LIVE_ARTIFACT_PATH:-$(mktemp -d)/live-file-node-probe-artifact.json}"
TMPDIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMPDIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if [[ ! -f "$ROOT_DIR/network.anytype.io.yml" ]]; then
  printf 'FAIL: network.anytype.io.yml not found\n' >&2
  exit 1
fi
rm -f "$LIVE_ARTIFACT_PATH"

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export ROOT_DIR
export TMPDIR
export LIVE_ARTIFACT_PATH

printf 'Running read-only live file-node probe against network.anytype.io...\n'

timeout 120s bash -lc '
  set -euo pipefail
  export HOME="$TMPDIR"
  export MANYTYPE_FILE_CAPTURE_PATH="$LIVE_ARTIFACT_PATH"
  cd "$ROOT_DIR"
  dart run packages/manytype_cli/bin/manytype.dart init >/dev/null
  dart run packages/manytype_cli/bin/manytype.dart \
    --network-config network.anytype.io.yml \
    probe-file-node \
    --read-only
'

if [[ ! -f "$LIVE_ARTIFACT_PATH" ]]; then
  printf 'FAIL: live file probe artifact was not written: %s\n' "$LIVE_ARTIFACT_PATH" >&2
  exit 1
fi

python3 - "$LIVE_ARTIFACT_PATH" <<'PYEOF'
import json
import sys

data = json.load(open(sys.argv[1]))
if data.get("read_only") is not True:
    print("FAIL: live artifact is not marked read_only", file=sys.stderr)
    sys.exit(1)

events = data.get("events", [])
methods = {
    (event.get("method") or "")
    for event in events
    if event.get("type") in {"unary_rpc", "rpc_error"}
}
required = {
    "/coordinator.Coordinator/NetworkConfiguration",
    "/filesync.File/Check",
    "/filesync.File/BlocksCheck",
    "/filesync.File/BlockGet",
}
missing = required - methods
if missing:
    print("FAIL: live artifact missing required probe methods:", missing, file=sys.stderr)
    sys.exit(1)

if "/filesync.File/BlockPush" in methods:
    print("FAIL: read-only live artifact must not contain BlockPush", file=sys.stderr)
    sys.exit(1)

resolved = [event for event in events if event.get("type") == "resolved_file_node"]
if not resolved:
    print("FAIL: live artifact missing resolved_file_node event", file=sys.stderr)
    sys.exit(1)

print(
    f"OK: live file probe artifact contains {len(events)} events and only read-only file RPCs"
)
PYEOF

printf 'Live file probe artifact written to: %s\n' "$LIVE_ARTIFACT_PATH"
printf 'live_file_node_probe.sh: PASSED\n'
