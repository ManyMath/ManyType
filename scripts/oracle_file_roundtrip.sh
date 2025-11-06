#!/usr/bin/env bash

set -euo pipefail

# Prerequisites:
#   1. docker compose up -d in docker/any-sync/ (oracle stack must be running)
#   2. cargo build -p manytype_quic_ffi --release (FFI lib must be built)
#   3. dart pub get in packages/manytype_cli/ (Dart deps resolved)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROUNDTRIP_ARTIFACT_PATH="${ROUNDTRIP_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/file-roundtrip-artifact.json}"
TMPDIR="$(mktemp -d)"
PAYLOAD_FILE="$TMPDIR/payload.txt"
PAYLOAD="phase22-live-$(date +%s%N)"

cleanup() {
  rm -rf "$TMPDIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

printf '%s' "$PAYLOAD" > "$PAYLOAD_FILE"

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export ROOT_DIR
export TMPDIR
export ROUNDTRIP_ARTIFACT_PATH
export PAYLOAD
export PAYLOAD_FILE

rm -f "$ROUNDTRIP_ARTIFACT_PATH"

printf 'Running file round-trip against docker oracle...\n'

timeout 180s bash -lc '
  set -euo pipefail
  export HOME="$TMPDIR"
  export MANYTYPE_FILE_TRANSFER_CAPTURE_PATH="$ROUNDTRIP_ARTIFACT_PATH"
  cd "$ROOT_DIR"
  dart run packages/manytype_cli/bin/manytype.dart init >/dev/null
  dart run packages/manytype_cli/bin/manytype.dart create seed >/dev/null
  UPLOAD_OUTPUT=$(dart run packages/manytype_cli/bin/manytype.dart \
    --network-config docker/any-sync/etc/client.yml \
    file-upload \
    --file-id phase22-live \
    "$PAYLOAD_FILE")
  printf "%s\n" "$UPLOAD_OUTPUT"
  CID=$(printf "%s\n" "$UPLOAD_OUTPUT" | sed -n "s/.*cid=\([^)]*\).*/\1/p")
  if [[ -z "$CID" ]]; then
    printf "FAIL: could not parse CID from upload output\n" >&2
    exit 1
  fi
  dart run packages/manytype_cli/bin/manytype.dart \
    --network-config docker/any-sync/etc/client.yml \
    file-open \
    --file-id phase22-live \
    --cid "$CID"
  SECOND_OPEN=$(dart run packages/manytype_cli/bin/manytype.dart \
    --network-config docker/any-sync/etc/client.yml \
    file-open \
    --file-id phase22-live \
    --cid "$CID")
  printf "%s\n" "$SECOND_OPEN"
'

if [[ ! -f "$ROUNDTRIP_ARTIFACT_PATH" ]]; then
  printf 'FAIL: round-trip artifact was not written: %s\n' "$ROUNDTRIP_ARTIFACT_PATH" >&2
  exit 1
fi

python3 - "$ROUNDTRIP_ARTIFACT_PATH" "$PAYLOAD" <<'PYEOF'
import json
import sys

data = json.load(open(sys.argv[1]))
payload = sys.argv[2]
events = data.get("events", [])
methods = [e.get("method", "") for e in events if e.get("type") == "unary_rpc"]
required = {
    "/coordinator.Coordinator/NetworkConfiguration",
    "/filesync.File/BlocksCheck",
    "/filesync.File/BlockPush",
    "/filesync.File/BlockGet",
}
missing = required - set(methods)
if missing:
    print("FAIL: artifact missing required round-trip methods:", missing, file=sys.stderr)
    sys.exit(1)

if methods.count("/filesync.File/BlockGet") != 1:
    print("FAIL: expected exactly one BlockGet (second open must hit cache)", file=sys.stderr)
    sys.exit(1)

event_types = [e.get("type", "") for e in events]
if "cache_hit" not in event_types:
    print("FAIL: artifact missing cache_hit event", file=sys.stderr)
    sys.exit(1)
if "cache_miss" not in event_types:
    print("FAIL: artifact missing cache_miss event", file=sys.stderr)
    sys.exit(1)

writes = [e for e in events if e.get("type") == "wrote_output"]
sources = {e.get("source") for e in writes}
if {"network", "cache"} - sources:
    print("FAIL: expected wrote_output events for both network and cache sources", file=sys.stderr)
    sys.exit(1)

print(
    f"OK: round-trip artifact contains {len(events)} events, upload/download/cache hit are all present "
    f"for payload {payload}"
)
PYEOF

printf 'Round-trip artifact written to: %s\n' "$ROUNDTRIP_ARTIFACT_PATH"
printf 'oracle_file_roundtrip.sh: PASSED\n'
