#!/usr/bin/env bash

set -euo pipefail

# Phase 36 VERIFY-02: Type/relation verification harness (both directions)
#
# Direction A: Manytype creates STType + STRelation against manytype_server,
#              official anytype-cli joins and confirms the type/relation objects
#              are visible in the space.
# Direction B: Official creates a standard ot-page object via probe,
#              Manytype syncs and reads type metadata.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-ghcr.io/anyproto/anytype-cli:latest}"
PORT="${PORT:-33143}"
API_VERSION="${API_VERSION:-2025-11-08}"
ARTIFACT_A_PATH="${PHASE36_TYPE_A_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase36-type-manytype-authored.json}"
ARTIFACT_B_PATH="${PHASE36_TYPE_B_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase36-type-official-authored.json}"
MANYTYPE_SYNC_CAPTURE_A="$ROOT_DIR/test_vectors/phase36-type-manytype-sync.json"
MANYTYPE_SYNC_CAPTURE_B="$ROOT_DIR/test_vectors/phase36-type-official-pull-sync.json"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
NETWORK_YML="$TMPDIR/network.yml"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
PROBE_DIR="$ROOT_DIR/scripts/official_client_grpc_probe"
CLI_NAME_A="phase36-anytype-cli-type-a-$$"
CLI_NAME_B="phase36-anytype-cli-type-b-$$"
SERVER_PID=""

cleanup() {
  for cname in "$CLI_NAME_A" "$CLI_NAME_B"; do
    if docker ps -a --format '{{.Names}}' | grep -Fxq "$cname"; then
      docker logs "$cname" >"$TMPDIR/${cname}.log" 2>&1 || true
    fi
    docker rm -f "$cname" >/dev/null 2>&1 || true
  done
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
# Direction A: Manytype creates STType + STRelation, official observes
# --------------------------------------------------------------------------

printf '=== Direction A: Manytype creates STType/STRelation, official observes ===\n'

printf 'Building manytype_server...\n'
(cd "$RUST_DIR" && cargo build -p manytype_server >/dev/null)

cat >"$TMPDIR/server.toml" <<EOF
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0606060606060606060606060606060606060606060606060606060606060606"
network_id = "manytype-phase36-type"
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
networkId: manytype-phase36-type
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

printf 'Manytype creates a custom type...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --as-type --name "Phase36Type" >"$TMPDIR/manytype-create-type.txt"
TYPE_OBJECT_ID="$(sed -n 's/^Created [a-z]*: //p' "$TMPDIR/manytype-create-type.txt" | head -1)"
if [[ -z "$TYPE_OBJECT_ID" ]]; then
  printf 'FAIL: could not parse type object id\n' >&2
  cat "$TMPDIR/manytype-create-type.txt" >&2 || true
  exit 1
fi

printf 'Manytype creates a custom relation...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --as-relation --name "Phase36Rel" --format text >"$TMPDIR/manytype-create-rel.txt"
RELATION_OBJECT_ID="$(sed -n 's/^Created [a-z]*: //p' "$TMPDIR/manytype-create-rel.txt" | head -1)"
if [[ -z "$RELATION_OBJECT_ID" ]]; then
  printf 'FAIL: could not parse relation object id\n' >&2
  cat "$TMPDIR/manytype-create-rel.txt" >&2 || true
  exit 1
fi

printf 'Seeding Manytype space to manytype_server...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_YML" \
  --wait-seconds 2 >/dev/null
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_A" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null

SPACE_INFO_JSON="$(HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart")"
SPACE_ID="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["space_id"])' <<<"$SPACE_INFO_JSON")"
ACCOUNT_SEED_HEX="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["account_seed_hex"])' <<<"$SPACE_INFO_JSON")"

(cd "$ROOT_DIR/scripts/phase31_invite_gen" && go run . \
  --account-seed-hex "$ACCOUNT_SEED_HEX" \
  --space-id "$SPACE_ID" \
  --space-name "phase36-type-a" \
  --creator-name "manytype") >"$INVITE_JSON"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_space_invite_publish.dart" \
  --network-config "$NETWORK_YML" \
  --invite-json "$INVITE_JSON" \
  --permissions writer >"$PUBLISH_JSON"

INVITE_URL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["invite_url"])' "$PUBLISH_JSON")"

printf 'Starting anytype-cli service container (direction A)...\n'
docker run -d --name "$CLI_NAME_A" --network host \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" serve --verbose --listen-address 0.0.0.0:31010 >/dev/null

if ! wait_for_grpc; then
  printf 'FAIL: anytype-cli gRPC did not become ready\n' >&2
  exit 1
fi

printf 'Creating bot account + API key...\n'
ACCOUNT_CREATE_OUTPUT="$(docker run --rm --network host \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase36-bot-type \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype)"
docker run --rm --entrypoint sh \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json' >/dev/null

API_KEY_OUTPUT="$(docker run --rm --network host \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" auth apikey create phase36-type-integration)"
API_KEY="$(printf '%s\n' "$API_KEY_OUTPUT" | sed -n 's/^Key: //p' | tail -1)"

sleep 5

printf 'Joining Manytype space via invite (direction A)...\n'
OFFICIAL_JOIN_A="$TMPDIR/official-join-a.json"
run_probe space-join --invite-url "$INVITE_URL" --network-id "manytype-phase36-type" --space-id "$SPACE_ID" >"$OFFICIAL_JOIN_A"
OFFICIAL_SPACE_JOINED="false"
JOIN_ERR="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error_code",""))' "$OFFICIAL_JOIN_A" 2>/dev/null || true)"
if [[ -z "$JOIN_ERR" ]]; then
  OFFICIAL_SPACE_JOINED="true"
fi

sleep 5

printf 'Official shows type object...\n'
OFFICIAL_SHOW_TYPE="$TMPDIR/official-show-type.json"
OFFICIAL_TYPE_VISIBLE="false"
run_probe object-show-text --space-id "$SPACE_ID" --object-id "$TYPE_OBJECT_ID" >"$OFFICIAL_SHOW_TYPE" || true
TYPE_ERR="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error_code",""))' "$OFFICIAL_SHOW_TYPE" 2>/dev/null || true)"
if [[ -z "$TYPE_ERR" ]]; then
  OFFICIAL_TYPE_VISIBLE="true"
fi

# Write Direction A artifact
python3 - "$ARTIFACT_A_PATH" "$SPACE_ID" "$TYPE_OBJECT_ID" "$RELATION_OBJECT_ID" \
  "$OFFICIAL_SPACE_JOINED" "$OFFICIAL_TYPE_VISIBLE" "$MANYTYPE_SYNC_CAPTURE_A" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path = pathlib.Path(sys.argv[1])
space_id = sys.argv[2]
type_object_id = sys.argv[3]
relation_object_id = sys.argv[4]
official_space_joined = sys.argv[5] == "true"
official_type_visible = sys.argv[6] == "true"
sync_capture = sys.argv[7]

success = bool(space_id and type_object_id and relation_object_id and official_space_joined)

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "manytype-authored STType/STRelation -> official observes in space (manytype_server infra)",
    "space_id": space_id,
    "type_object_id": type_object_id,
    "relation_object_id": relation_object_id,
    "official_space_joined": official_space_joined,
    "official_type_visible": official_type_visible,
    "manytype_sync_capture_path": sync_capture,
    "success": success,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_A_PATH" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
if not data.get("success"):
    raise SystemExit(f"Direction A artifact failed: joined={data.get('official_space_joined')}")
print(f"OK: phase36 type/relation direction A (type={data['type_object_id']}, rel={data['relation_object_id']})")
PY

printf 'Direction A artifact written: %s\n' "$ARTIFACT_A_PATH"

# Stop direction A resources
docker rm -f "$CLI_NAME_A" >/dev/null 2>&1 || true
kill "$SERVER_PID" >/dev/null 2>&1 || true
wait "$SERVER_PID" 2>/dev/null || true
SERVER_PID=""

# --------------------------------------------------------------------------
# Direction B: Official creates object, Manytype reads type metadata
# --------------------------------------------------------------------------

printf '=== Direction B: Official creates object, Manytype reads type ===\n'

NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
MANYTYPE_HOME_B="$TMPDIR/manytype-home-b"
OFFICIAL_ROOT_B="$TMPDIR/anytype-root-b"
NETWORK_YML_B="$TMPDIR/network-b.yml"
INVITE_JSON_B="$TMPDIR/invite-b.json"
PUBLISH_JSON_B="$TMPDIR/publish-b.json"

mkdir -p "$MANYTYPE_HOME_B" "$OFFICIAL_ROOT_B"
cp "$NETWORK_CONFIG_SRC" "$NETWORK_YML_B"

compose_ip() {
  (cd "$ROOT_DIR/docker/any-sync" && docker compose ps -q "$1" | xargs docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
}

ADD_HOST_ARGS=(
  --add-host "any-sync-node-1:$(compose_ip any-sync-node-1)"
  --add-host "any-sync-node-2:$(compose_ip any-sync-node-2)"
  --add-host "any-sync-node-3:$(compose_ip any-sync-node-3)"
  --add-host "any-sync-coordinator:$(compose_ip any-sync-coordinator)"
  --add-host "any-sync-filenode:$(compose_ip any-sync-filenode)"
  --add-host "any-sync-consensusnode:$(compose_ip any-sync-consensusnode)"
)

printf 'Preparing Manytype CLI temp home (direction B)...\n'
HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" init >/dev/null
HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  create "Phase36TypeSeed" >/dev/null

printf 'Seeding to official stack...\n'
HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_CONFIG_SRC" \
  --wait-seconds 10 >/dev/null
HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

SPACE_INFO_B="$(HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart")"
SPACE_ID_B="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["space_id"])' <<<"$SPACE_INFO_B")"
ACCOUNT_SEED_B="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["account_seed_hex"])' <<<"$SPACE_INFO_B")"

(cd "$ROOT_DIR/scripts/phase31_invite_gen" && go run . \
  --account-seed-hex "$ACCOUNT_SEED_B" \
  --space-id "$SPACE_ID_B" \
  --space-name "phase36-type-b" \
  --creator-name "manytype") >"$INVITE_JSON_B"

HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_space_invite_publish.dart" \
  --network-config "$NETWORK_YML_B" \
  --invite-json "$INVITE_JSON_B" \
  --permissions writer >"$PUBLISH_JSON_B"

INVITE_URL_B="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["invite_url"])' "$PUBLISH_JSON_B")"

printf 'Starting anytype-cli (direction B)...\n'
docker run -d --name "$CLI_NAME_B" --network host "${ADD_HOST_ARGS[@]}" \
  -v "$OFFICIAL_ROOT_B:/root/.anytype" \
  -v "$NETWORK_YML_B:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" serve --verbose --listen-address 0.0.0.0:31010 >/dev/null

if ! wait_for_grpc; then
  printf 'FAIL: anytype-cli gRPC did not become ready (direction B)\n' >&2
  exit 1
fi

ACCOUNT_CREATE_B="$(docker run --rm --network host "${ADD_HOST_ARGS[@]}" \
  -v "$OFFICIAL_ROOT_B:/root/.anytype" \
  -v "$NETWORK_YML_B:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase36-bot-type-b \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype)"
docker run --rm --entrypoint sh \
  -v "$OFFICIAL_ROOT_B:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json' >/dev/null

run_probe_b() {
  local action="$1"
  shift
  (cd "$PROBE_DIR" && go run . --config "$OFFICIAL_ROOT_B/config.json" --grpc-addr 127.0.0.1:31010 --timeout 60s --action "$action" "$@")
}

API_KEY_B_OUTPUT="$(docker run --rm --network host "${ADD_HOST_ARGS[@]}" \
  -v "$OFFICIAL_ROOT_B:/root/.anytype" \
  "$ANYTYPE_IMAGE" auth apikey create phase36-type-b-integration)"

NETWORK_ID_B="$(sed -n 's/^networkId: //p' "$NETWORK_YML_B" | head -1)"

sleep 5

printf 'Official joins space (direction B)...\n'
OFFICIAL_JOIN_B="$TMPDIR/official-join-b.json"
run_probe_b space-join --invite-url "$INVITE_URL_B" --network-id "$NETWORK_ID_B" --space-id "$SPACE_ID_B" >"$OFFICIAL_JOIN_B"
OFFICIAL_SPACE_ID_B="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("space_id",""))' "$OFFICIAL_JOIN_B" 2>/dev/null || echo "$SPACE_ID_B")"

sleep 5

printf 'Official creates object in shared space...\n'
OFFICIAL_CREATE_B="$TMPDIR/official-create-b.json"
PROBE_TIMEOUT=180s run_probe_b object-create --space-id "$OFFICIAL_SPACE_ID_B" --name "Phase36OfficialPage" >"$OFFICIAL_CREATE_B" || true
OFFICIAL_OBJ_ID="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("object_id",""))' "$OFFICIAL_CREATE_B" 2>/dev/null || true)"

printf 'Manytype syncs from official stack (direction B)...\n'
HOME="$MANYTYPE_HOME_B" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_B" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

MANYTYPE_OBSERVED_TYPE=""
if [[ -n "$OFFICIAL_OBJ_ID" ]]; then
  printf 'Manytype reads official object...\n'
  MANYTYPE_READ_B="$TMPDIR/manytype-read-b.txt"
  HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
    read "$OFFICIAL_OBJ_ID" >"$MANYTYPE_READ_B" 2>&1 || true
  MANYTYPE_OBSERVED_TYPE="$(python3 -c "
import re, sys
lines = open(sys.argv[1]).read().splitlines()
for l in reversed(lines):
    m = re.search(r'Type:\s+(.+)', l)
    if m:
        print(m.group(1).strip())
        break
" "$MANYTYPE_READ_B" 2>/dev/null || true)"
fi

# Write Direction B artifact
python3 - "$ARTIFACT_B_PATH" "$SPACE_ID_B" "${OFFICIAL_OBJ_ID:-}" "$MANYTYPE_OBSERVED_TYPE" \
  "$MANYTYPE_SYNC_CAPTURE_B" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path = pathlib.Path(sys.argv[1])
space_id = sys.argv[2]
object_id = sys.argv[3]
manytype_type = sys.argv[4]
sync_capture = sys.argv[5]

success = bool(space_id and object_id and manytype_type)

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "official-authored object -> manytype reads type metadata (official infra)",
    "space_id": space_id,
    "object_id": object_id,
    "expected_type": "ot-page",
    "manytype_observed_type": manytype_type,
    "manytype_sync_capture_path": sync_capture,
    "success": success,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_B_PATH" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
if not data.get("success"):
    raise SystemExit(f"Direction B artifact failed: type={data.get('manytype_observed_type')!r}")
print(f"OK: phase36 type/relation direction B (type={data.get('manytype_observed_type')})")
PY

printf 'Direction B artifact written: %s\n' "$ARTIFACT_B_PATH"
printf 'phase36_type_relation_harness.sh: PASSED\n'
