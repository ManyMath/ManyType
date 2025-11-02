#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
PORT="${PORT:-33220}"
ANYSYNC_TOOLS_IMAGE="${ANYSYNC_TOOLS_IMAGE:-ghcr.io/anyproto/any-sync-tools:latest}"
ARTIFACT_PATH="${PHASE11_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase11-netcheck-artifact.json}"
TMPDIR="$(mktemp -d)"
SERVER_PID=""

cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  if [[ "${KEEP_TMPDIR:-0}" != "1" ]]; then
    rm -rf "$TMPDIR" >/dev/null 2>&1 || true
  else
    printf 'Kept tempdir: %s\n' "$TMPDIR"
  fi
}
trap cleanup EXIT

printf 'Building manytype_server...\n'
(cd "$RUST_DIR" && cargo build -p manytype_server >/dev/null)

printf 'Writing temporary config in %s...\n' "$TMPDIR"
cat >"$TMPDIR/server.toml" <<EOF
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0101010101010101010101010101010101010101010101010101010101010101"
network_id = "manytype-nyquist"
EOF

printf 'Starting manytype_server on 127.0.0.1:%s...\n' "$PORT"
(
  cd "$RUST_DIR"
  stdbuf -oL -eL ./target/debug/manytype_server "$TMPDIR/server.toml" \
    >"$TMPDIR/server.log" 2>&1
) &
SERVER_PID=$!

for _ in $(seq 1 30); do
  if rg -q 'Listening on QUIC' "$TMPDIR/server.log" \
    && rg -q 'Server peer ID:' "$TMPDIR/server.log"; then
    break
  fi
  sleep 1
done

if ! rg -q 'Listening on QUIC' "$TMPDIR/server.log"; then
  printf 'Server did not become ready\n' >&2
  sed -n '1,160p' "$TMPDIR/server.log" || true
  exit 1
fi

PEER_ID="$(sed -n 's/.*Server peer ID: //p' "$TMPDIR/server.log" | tail -1)"
if [[ -z "$PEER_ID" ]]; then
  printf 'Failed to parse server peer ID\n' >&2
  exit 1
fi

printf 'Running any-sync-netcheck against manytype_server...\n'
docker run --rm --network host \
  "$ANYSYNC_TOOLS_IMAGE" \
  any-sync-netcheck -addrs "quic://127.0.0.1:$PORT" -v \
  >"$TMPDIR/netcheck.log" 2>&1

if ! python3 - "$TMPDIR/netcheck.log" <<'PY'
import pathlib
import re
import sys

text = pathlib.Path(sys.argv[1]).read_text()
if not re.search(r"netcheck\s+success", text):
    raise SystemExit(1)
PY
then
  printf 'Netcheck did not report success\n' >&2
  sed -n '1,200p' "$TMPDIR/netcheck.log" || true
  exit 1
fi

mkdir -p "$(dirname "$ARTIFACT_PATH")"
python3 - "$ARTIFACT_PATH" "$PEER_ID" "$PORT" "$TMPDIR/netcheck.log" "$ANYSYNC_TOOLS_IMAGE" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path = pathlib.Path(sys.argv[1])
peer_id = sys.argv[2]
port = int(sys.argv[3])
netcheck_log = pathlib.Path(sys.argv[4]).read_text()
image = sys.argv[5]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "server_addr": f"quic://127.0.0.1:{port}",
    "server_peer_id": peer_id,
    "docker_image": image,
    "command": f"docker run --rm --network host {image} any-sync-netcheck -addrs quic://127.0.0.1:{port} -v",
    "netcheck_success": __import__("re").search(r"netcheck\s+success", netcheck_log) is not None,
    "netcheck_output": netcheck_log,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_PATH" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1]))
if not data.get("netcheck_success"):
    raise SystemExit("artifact missing netcheck_success=true")
import re
if re.search(r"netcheck\s+success", data.get("netcheck_output", "")) is None:
    raise SystemExit("artifact missing netcheck success output")
print(f"OK: captured Phase 11 netcheck artifact for {data['server_addr']}")
PY

printf 'Phase 11 netcheck artifact written to: %s\n' "$ARTIFACT_PATH"
printf 'phase11_netcheck_capture.sh: PASSED\n'
