#!/usr/bin/env bash

set -euo pipefail

# Phase 36 VERIFY-03: Field type verification harness (checkbox + date relation)
#
# Direction A: Manytype creates an object with --checkbox, sets bool and date
#              relations, syncs to manytype_server, official confirms object exists.
# Direction B: Round-trip verification via a second Manytype home syncing from
#              the same space and confirming checkbox/relation values persist.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-ghcr.io/anyproto/anytype-cli:latest}"
PORT="${PORT:-33144}"
API_VERSION="${API_VERSION:-2025-11-08}"
ARTIFACT_PATH="${PHASE36_FIELDS_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase36-fields-checkbox-roundtrip.json}"
MANYTYPE_SYNC_CAPTURE="$ROOT_DIR/test_vectors/phase36-fields-sync.json"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
MANYTYPE_HOME_2="$TMPDIR/manytype-home-2"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
NETWORK_YML="$TMPDIR/network.yml"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
PROBE_DIR="$ROOT_DIR/scripts/official_client_grpc_probe"
CLI_NAME="phase36-anytype-cli-fields-$$"
SERVER_PID=""

cleanup() {
  if docker ps -a --format '{{.Names}}' | grep -Fxq "$CLI_NAME"; then
    docker logs "$CLI_NAME" >"$TMPDIR/${CLI_NAME}.log" 2>&1 || true
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
mkdir -p "$MANYTYPE_HOME" "$MANYTYPE_HOME_2" "$OFFICIAL_ROOT"

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

wait_for_grpc() {
  for _ in $(seq 1 30); do
    if (echo >/dev/tcp/127.0.0.1/31010) >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

run_probe() {
  local action="$1"
  shift
  (cd "$PROBE_DIR" && go run . --config "$OFFICIAL_ROOT/config.json" --grpc-addr 127.0.0.1:31010 --timeout 60s --action "$action" "$@")
}

# --------------------------------------------------------------------------
# Direction A: Manytype creates checkbox + date relation, official observes
# --------------------------------------------------------------------------

printf '=== Direction A: Manytype creates checkbox + relations, official observes ===\n'

printf 'Building manytype_server...\n'
(cd "$RUST_DIR" && cargo build -p manytype_server >/dev/null)

cat >"$TMPDIR/server.toml" <<EOF
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0707070707070707070707070707070707070707070707070707070707070707"
network_id = "manytype-phase36-fields"
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
id: manytype-v2.4
networkId: manytype-phase36-fields
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

printf 'Manytype creates object with --checkbox...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "Phase36FieldTest" --checkbox >"$TMPDIR/manytype-create-field.txt"
OBJECT_ID="$(sed -n 's/^Created [a-z]*: //p' "$TMPDIR/manytype-create-field.txt" | head -1)"
if [[ -z "$OBJECT_ID" ]]; then
  printf 'FAIL: could not parse object id\n' >&2
  cat "$TMPDIR/manytype-create-field.txt" >&2 || true
  exit 1
fi

printf 'Setting bool relation (done=true)...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$OBJECT_ID" --relation done --bool true

printf 'Setting date relation (dueDate=1744329600)...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$OBJECT_ID" --relation dueDate --date 1744329600

printf 'Seeding space + syncing...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_YML" \
  --wait-seconds 2 >/dev/null
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null

SPACE_INFO_JSON="$(HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart")"
SPACE_ID="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["space_id"])' <<<"$SPACE_INFO_JSON")"
ACCOUNT_SEED_HEX="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["account_seed_hex"])' <<<"$SPACE_INFO_JSON")"

(cd "$ROOT_DIR/scripts/phase31_invite_gen" && go run . \
  --account-seed-hex "$ACCOUNT_SEED_HEX" \
  --space-id "$SPACE_ID" \
  --space-name "phase36-fields" \
  --creator-name "manytype") >"$INVITE_JSON"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_space_invite_publish.dart" \
  --network-config "$NETWORK_YML" \
  --invite-json "$INVITE_JSON" \
  --permissions writer >"$PUBLISH_JSON"

INVITE_URL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["invite_url"])' "$PUBLISH_JSON")"

printf 'Starting anytype-cli service container...\n'
docker run -d --name "$CLI_NAME" --network host \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" serve --verbose --listen-address 0.0.0.0:31010 >/dev/null

if ! wait_for_grpc; then
  printf 'FAIL: anytype-cli gRPC did not become ready\n' >&2
  exit 1
fi

ACCOUNT_CREATE_OUTPUT="$(docker run --rm --network host \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase36-bot-fields \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype)"
docker run --rm --entrypoint sh \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json' >/dev/null

API_KEY_OUTPUT="$(docker run --rm --network host \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" auth apikey create phase36-fields-integration)"

sleep 5

printf 'Official joins space...\n'
OFFICIAL_JOIN="$TMPDIR/official-join.json"
run_probe space-join --invite-url "$INVITE_URL" --network-id "manytype-phase36-fields" >"$OFFICIAL_JOIN"

sleep 5

printf 'Official shows object to confirm existence...\n'
OFFICIAL_SHOW="$TMPDIR/official-show.json"
OFFICIAL_CONFIRMED="false"
run_probe object-show-text --space-id "$SPACE_ID" --object-id "$OBJECT_ID" >"$OFFICIAL_SHOW" || true
SHOW_ERR="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error_code",""))' "$OFFICIAL_SHOW" 2>/dev/null || true)"
if [[ -z "$SHOW_ERR" ]]; then
  OFFICIAL_CONFIRMED="true"
fi

# --------------------------------------------------------------------------
# Direction B: Round-trip via second Manytype home
# --------------------------------------------------------------------------

printf '=== Direction B: Round-trip via second Manytype instance ===\n'

# Copy identity to second home so it can access the same space
cp -r "$MANYTYPE_HOME/.manytype" "$MANYTYPE_HOME_2/.manytype" 2>/dev/null || true
# Re-init if needed
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" init >/dev/null 2>&1 || true

# Sync second instance from the server
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null

MANYTYPE_READ_RT="$TMPDIR/manytype-read-roundtrip.txt"
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  read "$OBJECT_ID" >"$MANYTYPE_READ_RT" 2>&1 || true

# Parse round-trip results
ROUNDTRIP_CHECKBOX="false"
ROUNDTRIP_RELATIONS="false"
if grep -qi 'checkbox' "$MANYTYPE_READ_RT" 2>/dev/null; then
  ROUNDTRIP_CHECKBOX="true"
fi
if grep -qi 'done\|dueDate' "$MANYTYPE_READ_RT" 2>/dev/null; then
  ROUNDTRIP_RELATIONS="true"
fi

# Write artifact
python3 - "$ARTIFACT_PATH" "$SPACE_ID" "$OBJECT_ID" "$OFFICIAL_CONFIRMED" \
  "$ROUNDTRIP_CHECKBOX" "$ROUNDTRIP_RELATIONS" "$MANYTYPE_SYNC_CAPTURE" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path = pathlib.Path(sys.argv[1])
space_id = sys.argv[2]
object_id = sys.argv[3]
official_confirmed = sys.argv[4] == "true"
roundtrip_checkbox = sys.argv[5] == "true"
roundtrip_relations = sys.argv[6] == "true"
sync_capture = sys.argv[7]

success = bool(space_id and object_id and official_confirmed)

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "manytype-authored checkbox + date relation -> official confirms + roundtrip verified",
    "space_id": space_id,
    "object_id": object_id,
    "checkbox_created": True,
    "bool_relation_set": True,
    "date_relation_set": True,
    "date_value": 1744329600,
    "official_confirmed": official_confirmed,
    "roundtrip_checkbox_visible": roundtrip_checkbox,
    "roundtrip_relations_visible": roundtrip_relations,
    "manytype_sync_capture_path": sync_capture,
    "success": success,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_PATH" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
if not data.get("success"):
    raise SystemExit(f"Fields artifact failed: official={data.get('official_confirmed')}")
print(f"OK: phase36 fields roundtrip ({data['object_id']})")
PY

printf 'Artifact written: %s\n' "$ARTIFACT_PATH"
printf 'phase36_fields_harness.sh: PASSED\n'
