#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
PORT="${PORT:-33140}"
ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-ghcr.io/anyproto/anytype-cli:latest}"
API_VERSION="${API_VERSION:-2025-11-08}"
TMPDIR="$(mktemp -d)"
SERVER_PID=""
CLI_NAME="phase30-anytype-cli-$$"
CLI_LOG_FILE="$TMPDIR/anytype-cli.log"

cleanup() {
  if docker ps -a --format '{{.Names}}' | grep -Fxq "$CLI_NAME"; then
    docker logs "$CLI_NAME" >"$CLI_LOG_FILE" 2>&1 || true
  fi
  docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
  stop_server
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

start_server() {
  local log_file="$1"
  pushd "$RUST_DIR" >/dev/null
  stdbuf -oL -eL ./target/debug/manytype_server "$TMPDIR/server.toml" \
    >"$log_file" 2>&1 &
  SERVER_PID=$!
  popd >/dev/null
  if ! wait_for_server_ready "$log_file"; then
    echo "Server did not become ready"
    sed -n '1,200p' "$log_file" || true
    exit 1
  fi
}

stop_server() {
  if [[ -z "${SERVER_PID:-}" ]]; then
    return 0
  fi

  kill "$SERVER_PID" >/dev/null 2>&1 || true
  for _ in $(seq 1 10); do
    if ! kill -0 "$SERVER_PID" >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
  if kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    kill -9 "$SERVER_PID" >/dev/null 2>&1 || true
  fi
  wait "$SERVER_PID" 2>/dev/null || true
  SERVER_PID=""
}

start_official_client() {
  docker run -d --name "$CLI_NAME" --network host \
    -v "$TMPDIR/cli-root:/root/.anytype" \
    -v "$TMPDIR/network.yml:/etc/anytype/network.yml:ro" \
    "$ANYTYPE_IMAGE" serve --verbose >/dev/null
  sleep 4
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
  for _ in $(seq 1 30); do
    if query_spaces "$api_key" >"$output_file" 2>/dev/null; then
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

assert_no_server_errors() {
  local log_file="$1"
  if rg -n 'ERROR manytype_server|unknown method|RPC error|Stream error|Connection error' "$log_file"; then
    echo "Server log contains interop errors"
    exit 1
  fi
}

printf '=== Phase 30: Official-to-Server note round-trip ===\n\n'

printf 'Building manytype_server...\n'
(cd "$RUST_DIR" && cargo build -p manytype_server >/dev/null)

printf 'Writing temporary config in %s...\n' "$TMPDIR"
cat >"$TMPDIR/server.toml" <<EOF
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0303030303030303030303030303030303030303030303030303030303030303"
network_id = "manytype-phase30"
EOF

mkdir -p "$TMPDIR/cli-root"

printf 'Starting manytype_server on 127.0.0.1:%s...\n' "$PORT"
start_server "$TMPDIR/server-1.log"

PEER_ID="$(sed -n 's/.*Server peer ID: //p' "$TMPDIR/server-1.log" | tail -1)"
if [[ -z "$PEER_ID" ]]; then
  echo "Failed to parse server peer ID"
  exit 1
fi

cat >"$TMPDIR/network.yml" <<EOF
id: manytype-v2.3
networkId: manytype-phase30
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
start_official_client

printf 'Creating bot account against manytype_server...\n'
ACCOUNT_CREATE_OUTPUT="$(docker run --rm --network host \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  -v "$TMPDIR/network.yml:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase30-bot \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype)"

# Extract the bot account key from the boxed output (base64 payload).
ACCOUNT_KEY="$(printf '%s\n' "$ACCOUNT_CREATE_OUTPUT" | grep -oE '[A-Za-z0-9+/]{20,}={0,2}' | head -1)"
if [[ -z "$ACCOUNT_KEY" ]]; then
  echo "Failed to parse account key from auth create output"
  printf '%s\n' "$ACCOUNT_CREATE_OUTPUT"
  exit 1
fi

docker run --rm --entrypoint sh \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json'

printf 'Creating API key...\n'
API_KEY_OUTPUT="$(docker run --rm --network host \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  "$ANYTYPE_IMAGE" auth apikey create phase30-integration)"
API_KEY="$(printf '%s\n' "$API_KEY_OUTPUT" | sed -n 's/^Key: //p' | tail -1)"
if [[ -z "$API_KEY" ]]; then
  echo "Failed to parse API key from output"
  printf '%s\n' "$API_KEY_OUTPUT"
  exit 1
fi

printf 'Querying spaces...\n'
if ! wait_for_spaces "$API_KEY" "$TMPDIR/spaces.json"; then
  echo "Official client API did not become ready"
  exit 1
fi

SPACE_ID="$(python3 - "$TMPDIR/spaces.json" <<'PYEOF'
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

ORIGINAL_TEXT="phase30-create-$(date +%s%N)"
UPDATED_TEXT="phase30-updated-$(date +%s%N)"

printf 'Creating note object: %s\n' "$ORIGINAL_TEXT"
run_grpc_probe object-create --space-id "$SPACE_ID" --name "$ORIGINAL_TEXT" >"$TMPDIR/create.json"
OBJECT_ID="$(python3 - "$TMPDIR/create.json" <<'PYEOF'
import json
import pathlib
import sys

payload = json.loads(pathlib.Path(sys.argv[1]).read_text())
obj = payload.get("object_id")
if not obj:
    raise SystemExit("Missing object_id in probe output")
print(obj)
PYEOF
)"

printf 'Editing note text: %s\n' "$UPDATED_TEXT"
run_grpc_probe object-edit-text --space-id "$SPACE_ID" --object-id "$OBJECT_ID" --text "$UPDATED_TEXT" >"$TMPDIR/edit.json"

printf 'Waiting for edited text to be observable...\n'
FOUND=0
for _ in $(seq 1 30); do
  run_grpc_probe object-show-text --space-id "$SPACE_ID" --object-id "$OBJECT_ID" >"$TMPDIR/show.json" || true
  TEXT="$(python3 - "$TMPDIR/show.json" <<'PYEOF'
import json
import pathlib
import sys
payload = json.loads(pathlib.Path(sys.argv[1]).read_text())
print(payload.get("text",""))
PYEOF
)"
  if [[ "$TEXT" == "$UPDATED_TEXT" ]]; then
    FOUND=1
    break
  fi
  sleep 2
done
if [[ "$FOUND" != "1" ]]; then
  echo "Edited text was not observed after retries"
  cat "$TMPDIR/show.json" || true
  exit 1
fi

assert_no_server_errors "$TMPDIR/server-1.log"

printf 'Restarting anytype-cli service container...\n'
docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
start_official_client

printf 'Logging in bot account after restart...\n'
LOGIN_OK=0
for _ in $(seq 1 10); do
  if docker run --rm --network host \
    -v "$TMPDIR/cli-root:/root/.anytype" \
    -v "$TMPDIR/network.yml:/etc/anytype/network.yml:ro" \
    "$ANYTYPE_IMAGE" auth login \
    --account-key "$ACCOUNT_KEY" \
    --network-config /etc/anytype/network.yml \
    --path /root/.anytype >/dev/null 2>&1; then
    LOGIN_OK=1
    break
  fi
  sleep 3
done
if [[ "$LOGIN_OK" != "1" ]]; then
  echo "Failed to log in after restart"
  docker run --rm --network host \
    -v "$TMPDIR/cli-root:/root/.anytype" \
    -v "$TMPDIR/network.yml:/etc/anytype/network.yml:ro" \
    "$ANYTYPE_IMAGE" auth login \
    --account-key "$ACCOUNT_KEY" \
    --network-config /etc/anytype/network.yml \
    --path /root/.anytype || true
  exit 1
fi

printf 'Restarting manytype_server...\n'
stop_server
start_server "$TMPDIR/server-2.log"

printf 'Verifying edited text after restart...\n'
run_grpc_probe object-show-text --space-id "$SPACE_ID" --object-id "$OBJECT_ID" >"$TMPDIR/show-after-restart.json"
TEXT_AFTER="$(python3 - "$TMPDIR/show-after-restart.json" <<'PYEOF'
import json
import pathlib
import sys
payload = json.loads(pathlib.Path(sys.argv[1]).read_text())
print(payload.get("text",""))
PYEOF
)"
if [[ "$TEXT_AFTER" != "$UPDATED_TEXT" ]]; then
  echo "Text mismatch after restart"
  echo "expected: $UPDATED_TEXT"
  echo "actual:   $TEXT_AFTER"
  cat "$TMPDIR/show-after-restart.json" || true
  exit 1
fi

assert_no_server_errors "$TMPDIR/server-2.log"

printf '\nHarness passed.\n'
printf 'Object: %s\n' "$OBJECT_ID"
printf 'Text:   %s\n' "$UPDATED_TEXT"
