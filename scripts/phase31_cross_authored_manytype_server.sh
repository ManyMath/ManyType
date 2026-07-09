#!/usr/bin/env bash

set -euo pipefail

# Cross-authored verification (manytype_server infra):
# - Manytype creates+edits a note in its space against manytype_server
# - Official anytype-cli joins that space via invite and re-reads the Manytype-authored edit

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
LOCK_FILE="$ROOT_DIR/docker/any-sync/oracle.lock.env"
if [[ -f "$LOCK_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$LOCK_FILE"
fi
ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-${ANYTYPE_CLI_IMAGE:-ghcr.io/anyproto/anytype-cli:latest}}"
PORT="${PORT:-33141}"
ARTIFACT_PATH="${PHASE31_CROSS_AUTHORED_MANYTYPE_SERVER_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase31-cross-authored-manytype-server.json}"
MANYTYPE_SEED_SYNC_CAPTURE="$ROOT_DIR/test_vectors/phase31-cross-authored-manytype-server-manytype-seed-sync.json"
MANYTYPE_EDIT_SYNC_CAPTURE="$ROOT_DIR/test_vectors/phase31-cross-authored-manytype-server-manytype-edit-sync.json"
OFFICIAL_SHOW_JSON="$ROOT_DIR/test_vectors/phase31-cross-authored-manytype-server-official-show.json"
OFFICIAL_JOIN_JSON="$ROOT_DIR/test_vectors/phase31-cross-authored-manytype-server-official-join.json"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
NETWORK_YML="$TMPDIR/network.yml"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
PROBE_DIR="$ROOT_DIR/scripts/official_client_grpc_probe"
CLI_NAME="phase31-anytype-cli-manytype-server-$$"
CLI_LOG_FILE="$TMPDIR/anytype-cli.log"
SERVER_PID=""

cleanup() {
  if docker ps -a --format '{{.Names}}' | grep -Fxq "$CLI_NAME"; then
    docker logs "$CLI_NAME" >"$CLI_LOG_FILE" 2>&1 || true
  fi
  docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
  if [[ -n "${SERVER_PID:-}" ]]; then
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

mkdir -p "$ROOT_DIR/test_vectors"
mkdir -p "$MANYTYPE_HOME" "$OFFICIAL_ROOT"

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

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

printf 'Building manytype_server...\n'
(cd "$RUST_DIR" && cargo build -p manytype_server >/dev/null)

cat >"$TMPDIR/server.toml" <<EOF
deployment_mode = "development"
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0404040404040404040404040404040404040404040404040404040404040404"
network_id = "manytype-phase31"
EOF

printf 'Starting manytype_server on 127.0.0.1:%s...\n' "$PORT"
stdbuf -oL -eL "$RUST_DIR/target/debug/manytype_server" "$TMPDIR/server.toml" >"$TMPDIR/server.log" 2>&1 &
SERVER_PID=$!
if ! wait_for_server_ready "$TMPDIR/server.log"; then
  printf 'FAIL: server did not become ready\n' >&2
  sed -n '1,200p' "$TMPDIR/server.log" >&2 || true
  exit 1
fi

PEER_ID="$(sed -n 's/.*Server peer ID: //p' "$TMPDIR/server.log" | tail -1)"
if [[ -z "$PEER_ID" ]]; then
  printf 'FAIL: could not parse server peer id\n' >&2
  exit 1
fi

cat >"$NETWORK_YML" <<EOF
id: manytype-v2.3
networkId: manytype-phase31
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

printf 'Preparing Manytype CLI temp home...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" init >/dev/null

printf 'Manytype creates and syncs a note against manytype_server...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" --server "127.0.0.1:$PORT" create "phase31-manytype-server-create" >"$TMPDIR/manytype-create.txt"
OBJECT_ID="$(sed -n 's/^Created object: //p' "$TMPDIR/manytype-create.txt" | head -1)"
if [[ -z "$OBJECT_ID" ]]; then
  printf 'FAIL: could not parse object id from Manytype create output\n' >&2
  cat "$TMPDIR/manytype-create.txt" >&2 || true
  exit 1
fi
printf 'Seeding Manytype space to manytype_server...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_YML" \
  --wait-seconds 2 >/dev/null
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SEED_SYNC_CAPTURE" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null

SPACE_INFO_JSON="$(HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart")"
SPACE_ID="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["space_id"])' <<<"$SPACE_INFO_JSON")"
ACCOUNT_SEED_HEX="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["account_seed_hex"])' <<<"$SPACE_INFO_JSON")"

(cd "$ROOT_DIR/scripts/phase31_invite_gen" && go run . --account-seed-hex "$ACCOUNT_SEED_HEX" --space-id "$SPACE_ID" --space-name "phase31-cross-authored-manytype-server" --creator-name "manytype") >"$INVITE_JSON"

printf 'Publishing invite to manytype_server...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_space_invite_publish.dart" \
  --network-config "$NETWORK_YML" \
  --invite-json "$INVITE_JSON" \
  --permissions writer >"$PUBLISH_JSON"

INVITE_URL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["invite_url"])' "$PUBLISH_JSON")"

wait_for_grpc() {
  for _ in $(seq 1 30); do
    if (echo >/dev/tcp/127.0.0.1/31010) >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

wait_for_cli_session() {
  for _ in $(seq 1 30); do
    if docker run --rm --network host \
      -v "$OFFICIAL_ROOT:/root/.anytype" \
      "$ANYTYPE_IMAGE" space list >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

start_cli_service() {
  docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
  docker run -d --name "$CLI_NAME" --network host \
    -v "$OFFICIAL_ROOT:/root/.anytype" \
    -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
    "$ANYTYPE_IMAGE" serve --verbose --listen-address 0.0.0.0:31010 >/dev/null
}

printf 'Creating bot account + API key (against manytype_server)...\n'
printf 'Starting anytype-cli service container...\n'
start_cli_service

if ! wait_for_grpc; then
  printf 'FAIL: anytype-cli gRPC did not become ready on 127.0.0.1:31010\n' >&2
  docker logs "$CLI_NAME" | tail -200 >&2 || true
  exit 1
fi

ACCOUNT_CREATE_OUTPUT="$(docker run --rm --network host \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase31-bot \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype)"
ACCOUNT_KEY="$(printf '%s\n' "$ACCOUNT_CREATE_OUTPUT" | grep -oE '[A-Za-z0-9+/]{20,}={0,2}' | head -1)"
if [[ -z "$ACCOUNT_KEY" ]]; then
  printf 'FAIL: could not parse account key\n' >&2
  printf '%s\n' "$ACCOUNT_CREATE_OUTPUT" >&2
  exit 1
fi

docker run --rm --entrypoint sh \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json' >/dev/null

printf 'Waiting for authenticated anytype-cli session...\n'
if ! wait_for_cli_session; then
  printf 'FAIL: anytype-cli session did not become ready\n' >&2
  docker logs "$CLI_NAME" | tail -200 >&2 || true
  exit 1
fi

sleep 5

run_probe() {
  local action="$1"
  shift
  (cd "$PROBE_DIR" && go run . --config "$OFFICIAL_ROOT/config.json" --grpc-addr 127.0.0.1:31010 --timeout 60s --action "$action" "$@")
}

UPDATED_TEXT="phase31-manytype-server-updated-$(date +%s%N)"

printf 'Joining Manytype space via invite (gRPC SpaceJoin)...\n'
run_probe space-join --invite-url "$INVITE_URL" --network-id "manytype-phase31" --space-id "$SPACE_ID" >"$OFFICIAL_JOIN_JSON"
JOIN_ERROR_CODE="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error_code",""))' "$OFFICIAL_JOIN_JSON")"
if [[ -n "$JOIN_ERROR_CODE" ]]; then
  printf 'FAIL: SpaceJoin returned error (%s)\n' "$JOIN_ERROR_CODE" >&2
  cat "$OFFICIAL_JOIN_JSON" >&2 || true
  exit 1
fi

printf 'Manytype edits note text...\n'
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_EDIT_SYNC_CAPTURE" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" \
  --network-config "$NETWORK_YML" \
  edit --id "$OBJECT_ID" --text "$UPDATED_TEXT" >/dev/null

printf 'Official re-reads note text...\n'
READY=0
for attempt in $(seq 1 60); do
  run_probe object-show-text --space-id "$SPACE_ID" --object-id "$OBJECT_ID" >"$OFFICIAL_SHOW_JSON" || true
  SHOW_ERR="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error_code",""))' "$OFFICIAL_SHOW_JSON" 2>/dev/null || true)"
  OFFICIAL_TEXT="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("text",""))' "$OFFICIAL_SHOW_JSON" 2>/dev/null || true)"
  if [[ -z "$SHOW_ERR" && "$OFFICIAL_TEXT" == "$UPDATED_TEXT" ]]; then
    READY=1
    break
  fi
  printf 'Waiting for official to observe update (attempt %s/60)...\n' "$attempt" >&2
  sleep 2
done
if [[ "$READY" != "1" ]]; then
  printf 'FAIL: official client did not observe Manytype-authored update\n' >&2
  cat "$OFFICIAL_SHOW_JSON" >&2 || true
  exit 1
fi

mkdir -p "$(dirname "$ARTIFACT_PATH")"
python3 - "$ARTIFACT_PATH" "$SPACE_ID" "$OBJECT_ID" "$UPDATED_TEXT" "$OFFICIAL_TEXT" "$INVITE_URL" "$MANYTYPE_SEED_SYNC_CAPTURE" "$MANYTYPE_EDIT_SYNC_CAPTURE" "$OFFICIAL_SHOW_JSON" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path = pathlib.Path(sys.argv[1])
space_id = sys.argv[2]
object_id = sys.argv[3]
updated_text = sys.argv[4]
official_text = sys.argv[5]
invite_url = sys.argv[6]
manytype_seed_capture = sys.argv[7]
manytype_edit_capture = sys.argv[8]
official_show_path = sys.argv[9]

success = bool(space_id and object_id and official_text == updated_text)

artifact = {
  "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00","Z"),
  "scenario": "manytype-authored -> official-observed (manytype_server infra)",
  "space_id": space_id,
  "object_id": object_id,
  "updated_text": updated_text,
  "official_observed_text": official_text,
  "invite_url": invite_url,
  "manytype_seed_sync_capture_path": manytype_seed_capture,
  "manytype_edit_sync_capture_path": manytype_edit_capture,
  "official_probe": {
    "show_result_path": official_show_path,
  },
  "success": success,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_PATH" <<'PY'
import json,sys
data=json.load(open(sys.argv[1]))
if not data.get("success"):
  raise SystemExit(f"cross-authored manytype_server artifact failed: observed={data.get('official_observed_text')!r}")
print(f"OK: phase31 cross-authored manytype_server ({data['object_id']})")
PY

printf 'Artifact written: %s\n' "$ARTIFACT_PATH"
printf 'phase31_cross_authored_manytype_server.sh: PASSED\n'
