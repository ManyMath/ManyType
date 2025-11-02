#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HARNESS="$ROOT_DIR/scripts/phase13_official_client_harness.sh"
ARTIFACT_PATH="${PHASE13_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase13-official-client-bootstrap.json}"
TMPDIR="$(mktemp -d)"
HARNESS_TMPDIR=""

cleanup() {
  if [[ -n "$HARNESS_TMPDIR" && -d "$HARNESS_TMPDIR" ]]; then
    if [[ "${KEEP_TMPDIR:-0}" != "1" ]]; then
      rm -rf "$HARNESS_TMPDIR" >/dev/null 2>&1 || true
    else
      printf 'Kept harness tempdir: %s\n' "$HARNESS_TMPDIR"
    fi
  fi
  if [[ "${KEEP_TMPDIR:-0}" != "1" ]]; then
    rm -rf "$TMPDIR" >/dev/null 2>&1 || true
  else
    printf 'Kept wrapper tempdir: %s\n' "$TMPDIR"
  fi
}
trap cleanup EXIT

printf 'Running Phase 13 official-client harness...\n'
set +e
KEEP_TMPDIR=1 bash "$HARNESS" 2>&1 | tee "$TMPDIR/harness.out"
HARNESS_STATUS=${PIPESTATUS[0]}
set -e

HARNESS_TMPDIR="$(sed -n 's/^Kept tempdir: //p' "$TMPDIR/harness.out" | tail -1)"
if [[ -z "$HARNESS_TMPDIR" || ! -d "$HARNESS_TMPDIR" ]]; then
  printf 'Failed to parse harness tempdir from output\n' >&2
  exit 1
fi

SERVER_LOG="$HARNESS_TMPDIR/server.log"
if [[ ! -f "$SERVER_LOG" ]]; then
  printf 'Harness server log was not found: %s\n' "$SERVER_LOG" >&2
  exit 1
fi

PEER_ID="$(sed -n 's/^Server peer ID: //p' "$TMPDIR/harness.out" | tail -1)"
if [[ -z "$PEER_ID" ]]; then
  PEER_ID="$(sed -n 's/.*Server peer ID: //p' "$SERVER_LOG" | tail -1)"
fi
if [[ -z "$PEER_ID" ]]; then
  printf 'Failed to parse server peer ID from harness output\n' >&2
  exit 1
fi

mkdir -p "$(dirname "$ARTIFACT_PATH")"
python3 - "$ARTIFACT_PATH" "$HARNESS" "$PEER_ID" "$SERVER_LOG" "$HARNESS_STATUS" <<'PY'
import datetime as dt
import json
import pathlib
import re
import sys

artifact_path = pathlib.Path(sys.argv[1])
harness_script = sys.argv[2]
peer_id = sys.argv[3]
server_log_path = pathlib.Path(sys.argv[4])
harness_status = int(sys.argv[5])

required_markers = [
    "Credential handshake complete",
    "Proto handshake complete",
    "sync: headsync for",
    "sync: received ObjectSyncMessage",
]
error_re = re.compile(r"ERROR manytype_server|unknown method|RPC error|Stream error|Connection error")

lines = server_log_path.read_text().splitlines()
observed_markers = [marker for marker in required_markers if any(marker in line for line in lines)]
excerpt = [line for line in lines if any(marker in line for marker in required_markers)]
error_lines = [line for line in lines if error_re.search(line)]
success = harness_status == 0 and len(observed_markers) == len(required_markers) and not error_lines

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "harness_script": harness_script,
    "server_peer_id": peer_id,
    "harness_exit_code": harness_status,
    "required_markers": required_markers,
    "observed_markers": observed_markers,
    "error_lines": error_lines,
    "success": success,
    "server_log_excerpt": excerpt,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_PATH" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1]))
missing = sorted(set(data["required_markers"]) - set(data["observed_markers"]))
if data.get("harness_exit_code") != 0:
    raise SystemExit(f"harness exited non-zero: {data['harness_exit_code']}")
if missing:
    raise SystemExit(f"artifact missing markers: {missing}")
if data.get("error_lines"):
    raise SystemExit(f"artifact recorded server errors: {data['error_lines']}")
print(f"OK: captured Phase 13 bootstrap artifact for {data['server_peer_id']}")
PY

printf 'Phase 13 bootstrap artifact written to: %s\n' "$ARTIFACT_PATH"
printf 'phase13_capture.sh: PASSED\n'
