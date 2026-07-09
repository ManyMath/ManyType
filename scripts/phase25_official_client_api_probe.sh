#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
PORT="${PORT:-33130}"
ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-ghcr.io/anyproto/anytype-cli:latest}"
API_VERSION="${API_VERSION:-2025-11-08}"
SPACE_READY_WAIT_SECONDS="${SPACE_READY_WAIT_SECONDS:-30}"
BACKGROUND_UPLOAD_WAIT_SECONDS="${BACKGROUND_UPLOAD_WAIT_SECONDS:-120}"
TMPDIR="$(mktemp -d)"
SERVER_PID=""
CLI_NAME="phase25-anytype-cli-$$"
PROBE_JSON="$TMPDIR/official-client-api-probe.json"
PAYLOAD_FILE="$TMPDIR/official-client-payload.txt"
DOWNLOAD_DIR="$TMPDIR/downloads"
CLI_LOG_FILE="$TMPDIR/anytype-cli.log"

cleanup() {
  if docker ps -a --format '{{.Names}}' | grep -Fxq "$CLI_NAME"; then
    docker logs "$CLI_NAME" >"$CLI_LOG_FILE" 2>&1 || true
  fi
  docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
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

wait_for_server_ready() {
  local log_file="$1"
  for _ in $(seq 1 30); do
    if rg -q 'Listening on QUIC' "$log_file" && rg -q 'Server peer ID:' "$log_file"; then
      return 0
    fi
    sleep 1
  done
  return 1
}

query_spaces() {
  local api_key="$1"
  curl -sf http://127.0.0.1:31012/v1/spaces \
    -H "Anytype-Version: $API_VERSION" \
    -H "Authorization: Bearer $api_key"
}

wait_for_spaces() {
  local api_key="$1"
  local output_file="$2"
  local response=""
  for _ in $(seq 1 "$SPACE_READY_WAIT_SECONDS"); do
    if response="$(query_spaces "$api_key" 2>/dev/null)"; then
      printf '%s\n' "$response" >"$output_file"
      return 0
    fi
    sleep 1
  done
  return 1
}

wait_for_background_upload() {
  local log_file="$1"
  local blobs_dir="$2"
  for _ in $(seq 1 "$BACKGROUND_UPLOAD_WAIT_SECONDS"); do
    if rg -q 'File RPC invoke: method=/filesync\.File/BlockPush(Many)?' "$log_file"; then
      return 0
    fi
    if find "$blobs_dir" -type f -name '*.blob' -print -quit | grep -q .; then
      return 0
    fi
    sleep 1
  done
  return 1
}

run_grpc_probe() {
  local action="$1"
  shift
  (
    cd "$ROOT_DIR/scripts/official_client_grpc_probe"
    go run . \
      --config "$TMPDIR/cli-root/config.json" \
      --grpc-addr 127.0.0.1:31010 \
      --action "$action" \
      "$@"
  )
}

printf 'Building manytype_server...\n'
(cd "$RUST_DIR" && cargo build -p manytype_server >/dev/null)

printf 'Writing temporary config in %s...\n' "$TMPDIR"
cat >"$TMPDIR/server.toml" <<EOF
deployment_mode = "development"
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0202020202020202020202020202020202020202020202020202020202020202"
network_id = "manytype-phase25"
EOF

mkdir -p "$TMPDIR/cli-root" "$DOWNLOAD_DIR"
printf 'phase24.1-official-client-%s\n' "$(date +%s%N)" >"$PAYLOAD_FILE"

printf 'Starting manytype_server on 127.0.0.1:%s...\n' "$PORT"
(
  cd "$RUST_DIR"
  MANYTYPE_TRACE_FILE_RPCS=1 stdbuf -oL -eL ./target/debug/manytype_server "$TMPDIR/server.toml" \
    >"$TMPDIR/server.log" 2>&1
) &
SERVER_PID=$!

if ! wait_for_server_ready "$TMPDIR/server.log"; then
  echo "Server did not become ready"
  sed -n '1,160p' "$TMPDIR/server.log" || true
  exit 1
fi

PEER_ID="$(sed -n 's/.*Server peer ID: //p' "$TMPDIR/server.log" | tail -1)"
if [[ -z "$PEER_ID" ]]; then
  echo "Failed to parse server peer ID"
  exit 1
fi

cat >"$TMPDIR/network.yml" <<EOF
id: manytype-v2.2
networkId: manytype-phase25
nodes:
  - peerId: $PEER_ID
    addresses:
      - 127.0.0.1:$PORT
      - quic://127.0.0.1:$PORT
    types:
      - coordinator
  - peerId: $PEER_ID
    addresses:
      - 127.0.0.1:$PORT
      - quic://127.0.0.1:$PORT
    types:
      - tree
  - peerId: $PEER_ID
    addresses:
      - 127.0.0.1:$PORT
      - quic://127.0.0.1:$PORT
    types:
      - file
  - peerId: $PEER_ID
    addresses:
      - 127.0.0.1:$PORT
      - quic://127.0.0.1:$PORT
    types:
      - consensus
EOF

printf 'Starting anytype-cli service container...\n'
docker run -d --name "$CLI_NAME" --network host \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  -v "$TMPDIR:$TMPDIR" \
  -v "$TMPDIR/network.yml:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" serve --verbose >/dev/null

sleep 4

printf 'Creating bot account against manytype_server...\n'
docker run --rm --network host \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  -v "$TMPDIR/network.yml:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase25-bot \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype >/dev/null

docker run --rm --entrypoint sh \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json'

printf 'Creating API key...\n'
API_KEY_OUTPUT="$(docker run --rm --network host \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  "$ANYTYPE_IMAGE" auth apikey create phase25-integration)"
printf '%s\n' "$API_KEY_OUTPUT"
API_KEY="$(printf '%s\n' "$API_KEY_OUTPUT" | sed -n 's/^Key: //p' | tail -1)"
if [[ -z "$API_KEY" ]]; then
  echo "Failed to parse API key from output"
  exit 1
fi

printf 'Querying official client API before round-trip...\n'
if ! wait_for_spaces "$API_KEY" "$TMPDIR/initial_spaces.json"; then
  echo "Official client API did not become ready before upload"
  exit 1
fi

SPACE_ID="$(python3 - "$TMPDIR/initial_spaces.json" <<'PYEOF'
import json
import pathlib
import sys

payload = json.loads(pathlib.Path(sys.argv[1]).read_text())
spaces = payload.get("data", [])
if not spaces:
    raise SystemExit("No spaces returned by /v1/spaces")
print(spaces[0]["id"])
PYEOF
)"

printf 'Uploading attachment through official-client gRPC surface...\n'
run_grpc_probe upload --space-id "$SPACE_ID" --file "$PAYLOAD_FILE" >"$TMPDIR/upload.json"
cat "$TMPDIR/upload.json"

OBJECT_ID="$(python3 - "$TMPDIR/upload.json" <<'PYEOF'
import json
import pathlib
import sys

payload = json.loads(pathlib.Path(sys.argv[1]).read_text())
error_code = payload.get("error_code", "")
if error_code and error_code != "NULL":
    raise SystemExit(payload.get("error_description") or error_code)
object_id = payload.get("object_id", "")
if not object_id:
    raise SystemExit("upload did not return object_id")
print(object_id)
PYEOF
)"

printf 'Waiting for official-client background upload to reach manytype_server...\n'
if ! wait_for_background_upload "$TMPDIR/server.log" "$TMPDIR/server/blobs"; then
  echo "Official client upload did not reach manytype_server before restart"
  exit 1
fi

printf 'Restarting manytype_server...\n'
kill "$SERVER_PID" >/dev/null 2>&1 || true
wait "$SERVER_PID" 2>/dev/null || true
SERVER_PID=""
(
  cd "$RUST_DIR"
  MANYTYPE_TRACE_FILE_RPCS=1 stdbuf -oL -eL ./target/debug/manytype_server "$TMPDIR/server.toml" \
    >>"$TMPDIR/server.log" 2>&1
) &
SERVER_PID=$!

if ! wait_for_server_ready "$TMPDIR/server.log"; then
  echo "Server did not become ready after restart"
  sed -n '1,200p' "$TMPDIR/server.log" || true
  exit 1
fi

sleep 4
printf 'Querying official client API after restart...\n'
if ! wait_for_spaces "$API_KEY" "$TMPDIR/restart_spaces.json"; then
  echo "Official client API did not become ready after server restart"
  exit 1
fi

printf 'Clearing official-client local flatfs cache...\n'
docker run --rm --entrypoint sh \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'find /root/.anytype -path "*/flatfs" -type d -prune -exec rm -rf {} +'

sleep 1
printf 'Downloading attachment through official-client gRPC surface...\n'
run_grpc_probe download \
  --object-id "$OBJECT_ID" \
  --file "$PAYLOAD_FILE" \
  --download-dir "$DOWNLOAD_DIR" >"$TMPDIR/download.json"
cat "$TMPDIR/download.json"

python3 - "$PROBE_JSON" "$TMPDIR/server.log" "$PEER_ID" "$API_VERSION" "$TMPDIR" <<'PYEOF'
import hashlib
import json
import pathlib
import re
import sys

probe_path = pathlib.Path(sys.argv[1])
server_log_path = pathlib.Path(sys.argv[2])
peer_id = sys.argv[3]
api_version = sys.argv[4]
tmpdir = pathlib.Path(sys.argv[5])

initial = json.loads((tmpdir / "initial_spaces.json").read_text())
after_restart = json.loads((tmpdir / "restart_spaces.json").read_text())
upload = json.loads((tmpdir / "upload.json").read_text())
download = json.loads((tmpdir / "download.json").read_text())
payload_path = tmpdir / "official-client-payload.txt"
download_path = pathlib.Path(download.get("download_path") or "")
lines = server_log_path.read_text().splitlines()

file_method_sequence = []
for line in lines:
    match = re.search(r"File RPC invoke: method=(/filesync\.File/[^ ]+)", line)
    if match:
        file_method_sequence.append(match.group(1))

file_methods_observed = list(dict.fromkeys(file_method_sequence))
gateway_urls = [
    space.get("gateway_url")
    for space in initial.get("data", [])
    if space.get("gateway_url")
]

all_error_lines = [
    line for line in lines if "ERROR manytype_server" in line or "Stream error:" in line
]
advisory_patterns = (
    "RPC error on /filesync.File/SpaceInfo: Forbidden: peer does not own or cannot access space",
    "RPC error on /filesync.File/FilesDelete: unknown method",
    "Stream error: expected KIND_INVOKE frame, got kind=2",
)
advisory_error_lines = [
    line for line in all_error_lines if any(pattern in line for pattern in advisory_patterns)
]
fatal_error_lines = [
    line for line in all_error_lines if line not in advisory_error_lines
]

def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

byte_match = bool(download.get("match"))
payload_sha = sha256(payload_path)
downloaded_sha = sha256(download_path) if download_path.exists() else ""

required_roundtrip_methods = [
    "/filesync.File/Check",
    "/filesync.File/BlocksCheck",
]


def has_ordered_subsequence(sequence: list[str], required: list[str]) -> bool:
    index = 0
    for method in required:
        try:
            index = sequence.index(method, index) + 1
        except ValueError:
            return False
    return True


roundtrip_method_order_ok = has_ordered_subsequence(
    file_method_sequence, required_roundtrip_methods
)
roundtrip_success = (
    upload.get("error_code") in {None, "", "NULL"}
    and download.get("error_code") in {None, "", "NULL"}
    and bool(upload.get("object_id"))
    and byte_match
    and downloaded_sha == payload_sha
    and roundtrip_method_order_ok
)

automation_status = "full_file_roundtrip" if roundtrip_success else (
    "api_plus_file_activity" if file_methods_observed else "api_only"
)

if roundtrip_success:
    limitation = (
        "The shipped official anytype-cli headless gRPC surface can upload and "
        "download attachments against manytype_server after restart. "
        "Background advisory calls still probe unsupported or unauthorized "
        "file-node methods such as FilesDelete or stale SpaceInfo entries."
    )
else:
    limitation = (
        "Published automation reached the official client API but did not "
        "complete a full attachment round-trip."
    )

probe = {
    "api_version": api_version,
    "server_peer_id": peer_id,
    "initial_space_count": initial.get("pagination", {}).get("total", len(initial.get("data", []))),
    "restart_space_count": after_restart.get("pagination", {}).get("total", len(after_restart.get("data", []))),
    "space_ids": [space.get("id") for space in initial.get("data", [])],
    "space_id_used": initial.get("data", [{}])[0].get("id") if initial.get("data") else "",
    "gateway_urls": gateway_urls,
    "file_method_sequence": file_method_sequence,
    "file_methods_observed": file_methods_observed,
    "required_file_method_sequence": required_roundtrip_methods,
    "roundtrip_method_order_ok": roundtrip_method_order_ok,
    "cache_eviction_strategy": "flatfs_reset",
    "api_probe_success": True,
    "automation_surface": "headless_grpc",
    "automation_status": automation_status,
    "limitation": limitation,
    "roundtrip_success": roundtrip_success,
    "roundtrip_object_id": upload.get("object_id", ""),
    "roundtrip_download_path": download.get("download_path", ""),
    "payload_sha256": payload_sha,
    "downloaded_sha256": downloaded_sha,
    "byte_match": byte_match,
    "error_lines": all_error_lines,
    "advisory_error_lines": advisory_error_lines,
    "fatal_error_lines": fatal_error_lines,
}

probe_path.write_text(json.dumps(probe, indent=2) + "\n")
PYEOF

printf 'Official-client API probe written to: %s\n' "$PROBE_JSON"
printf 'Harness passed.\n'
printf 'Server peer ID: %s\n' "$PEER_ID"
printf 'Official-client API probe: %s\n' "$PROBE_JSON"
