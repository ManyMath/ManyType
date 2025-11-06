#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HARNESS="$ROOT_DIR/scripts/phase25_official_client_api_probe.sh"
ARTIFACT_PATH="${PHASE25_OFFICIAL_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase25-official-client-api.json}"
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

printf 'Running Phase 25 official-client API probe harness...\n'
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
PROBE_JSON="$HARNESS_TMPDIR/official-client-api-probe.json"
if [[ ! -f "$SERVER_LOG" ]]; then
  printf 'Harness server log was not found: %s\n' "$SERVER_LOG" >&2
  exit 1
fi
if [[ ! -f "$PROBE_JSON" ]]; then
  printf 'Harness probe JSON was not found: %s\n' "$PROBE_JSON" >&2
  exit 1
fi

mkdir -p "$(dirname "$ARTIFACT_PATH")"
python3 - "$ARTIFACT_PATH" "$PROBE_JSON" "$SERVER_LOG" "$HARNESS" "$HARNESS_STATUS" <<'PYEOF'
import datetime as dt
import json
import pathlib
import sys

artifact_path = pathlib.Path(sys.argv[1])
probe_path = pathlib.Path(sys.argv[2])
server_log_path = pathlib.Path(sys.argv[3])
harness_script = sys.argv[4]
harness_status = int(sys.argv[5])

probe = json.loads(probe_path.read_text())
lines = server_log_path.read_text().splitlines()
required_markers = [
    "Credential handshake complete",
    "Proto handshake complete",
]
observed_markers = [marker for marker in required_markers if any(marker in line for line in lines)]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "harness_script": harness_script,
    "harness_exit_code": harness_status,
    "required_markers": required_markers,
    "observed_markers": observed_markers,
    **probe,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PYEOF

python3 - "$ARTIFACT_PATH" <<'PYEOF'
import json
import sys

data = json.load(open(sys.argv[1]))
missing = sorted(set(data["required_markers"]) - set(data["observed_markers"]))
if data.get("harness_exit_code") != 0:
    raise SystemExit(f"harness exited non-zero: {data['harness_exit_code']}")
if missing:
    raise SystemExit(f"artifact missing markers: {missing}")
if data.get("fatal_error_lines"):
    raise SystemExit(f"artifact recorded fatal server errors: {data['fatal_error_lines']}")
if not data.get("api_probe_success"):
    raise SystemExit("artifact api_probe_success is false")
if data.get("automation_status") != "full_file_roundtrip":
    raise SystemExit(f"artifact automation_status={data.get('automation_status')}")
if not data.get("roundtrip_success"):
    raise SystemExit("artifact roundtrip_success is false")
if not data.get("byte_match"):
    raise SystemExit("artifact byte_match is false")
print(
    "OK: captured Phase 25 official-client file roundtrip artifact "
    f"for {data['server_peer_id']} ({data['automation_status']})"
)
PYEOF

printf 'Phase 25 official-client API artifact written to: %s\n' "$ARTIFACT_PATH"
printf 'phase25_capture_official_client_api.sh: PASSED\n'
