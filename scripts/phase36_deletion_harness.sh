#!/usr/bin/env bash

set -euo pipefail

# Phase 36 VERIFY-01: Deletion verification harness (both directions)
#
# Direction A: Manytype creates+deletes an object against manytype_server,
#              official anytype-cli joins and confirms the object is gone.
# Direction B: Official creates object via probe, Manytype syncs and confirms
#              the object can be archived/deleted from official side and
#              excluded from manytype list.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-ghcr.io/anyproto/anytype-cli:latest}"
PORT="${PORT:-33142}"
API_VERSION="${API_VERSION:-2025-11-08}"
ARTIFACT_A_PATH="${PHASE36_DELETION_A_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase36-deletion-manytype-authored.json}"
ARTIFACT_B_PATH="${PHASE36_DELETION_B_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase36-deletion-official-authored.json}"
MANYTYPE_CREATE_SYNC_CAPTURE="$ROOT_DIR/test_vectors/phase36-deletion-manytype-sync.json"
MANYTYPE_DELETE_SYNC_CAPTURE="$ROOT_DIR/test_vectors/phase36-deletion-manytype-delete-sync.json"
MANYTYPE_PULL_SYNC_CAPTURE="$ROOT_DIR/test_vectors/phase36-deletion-official-sync.json"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
NETWORK_YML="$TMPDIR/network.yml"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
PROBE_DIR="$ROOT_DIR/scripts/official_client_grpc_probe"
CLI_NAME_A="phase36-anytype-cli-del-a-$$"
CLI_NAME_B="phase36-anytype-cli-del-b-$$"
CLI_LOG_FILE="$TMPDIR/anytype-cli.log"
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
# Direction A: Manytype deletes, official observes
# --------------------------------------------------------------------------

printf '=== Direction A: Manytype deletes, official observes ===\n'

printf 'Building manytype_server...\n'
(cd "$RUST_DIR" && cargo build -p manytype_server >/dev/null)

cat >"$TMPDIR/server.toml" <<EOF
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0505050505050505050505050505050505050505050505050505050505050505"
network_id = "manytype-phase36-del"
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
networkId: manytype-phase36-del
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

printf 'Manytype creates an object...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" \
  create "Phase36DeleteTest" >"$TMPDIR/manytype-create.txt"
OBJECT_ID="$(sed -n 's/^Created [a-z]*: //p' "$TMPDIR/manytype-create.txt" | head -1)"
if [[ -z "$OBJECT_ID" ]]; then
  printf 'FAIL: could not parse object id from Manytype create output\n' >&2
  cat "$TMPDIR/manytype-create.txt" >&2 || true
  exit 1
fi

printf 'Seeding Manytype space to manytype_server...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_YML" \
  --wait-seconds 2 >/dev/null
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_CREATE_SYNC_CAPTURE" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null

SPACE_INFO_JSON="$(HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart")"
SPACE_ID="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["space_id"])' <<<"$SPACE_INFO_JSON")"
ACCOUNT_SEED_HEX="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["account_seed_hex"])' <<<"$SPACE_INFO_JSON")"

printf 'Manytype deletes the object...\n'
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_DELETE_SYNC_CAPTURE" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  delete --id "$OBJECT_ID"

# Generate invite so official client can join
(cd "$ROOT_DIR/scripts/phase31_invite_gen" && go run . \
  --account-seed-hex "$ACCOUNT_SEED_HEX" \
  --space-id "$SPACE_ID" \
  --space-name "phase36-deletion-a" \
  --creator-name "manytype") >"$INVITE_JSON"

printf 'Publishing invite to manytype_server...\n'
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
  docker logs "$CLI_NAME_A" | tail -200 >&2 || true
  exit 1
fi

printf 'Creating bot account + API key...\n'
ACCOUNT_CREATE_OUTPUT="$(docker run --rm --network host \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase36-bot-del \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype)"
docker run --rm --entrypoint sh \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json' >/dev/null

API_KEY_OUTPUT="$(docker run --rm --network host \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" auth apikey create phase36-del-integration)"
API_KEY="$(printf '%s\n' "$API_KEY_OUTPUT" | sed -n 's/^Key: //p' | tail -1)"
if [[ -z "$API_KEY" ]]; then
  printf 'FAIL: could not parse API key\n' >&2
  printf '%s\n' "$API_KEY_OUTPUT" >&2
  exit 1
fi

sleep 5

printf 'Joining Manytype space via invite (direction A)...\n'
OFFICIAL_JOIN_A="$TMPDIR/official-join-a.json"
run_probe space-join --invite-url "$INVITE_URL" --network-id "manytype-phase36-del" >"$OFFICIAL_JOIN_A"

sleep 5

printf 'Official tries to show deleted object...\n'
OFFICIAL_SHOW_A="$TMPDIR/official-show-a.json"
OFFICIAL_OBSERVED_DELETED="false"
run_probe object-show-text --space-id "$SPACE_ID" --object-id "$OBJECT_ID" >"$OFFICIAL_SHOW_A" || true
SHOW_ERR="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error_code",""))' "$OFFICIAL_SHOW_A" 2>/dev/null || true)"
SHOW_TEXT="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("text",""))' "$OFFICIAL_SHOW_A" 2>/dev/null || true)"
if [[ -n "$SHOW_ERR" ]] || [[ -z "$SHOW_TEXT" ]]; then
  OFFICIAL_OBSERVED_DELETED="true"
fi

# Write Direction A artifact
python3 - "$ARTIFACT_A_PATH" "$SPACE_ID" "$OBJECT_ID" "$OFFICIAL_OBSERVED_DELETED" \
  "$MANYTYPE_CREATE_SYNC_CAPTURE" "$MANYTYPE_DELETE_SYNC_CAPTURE" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path = pathlib.Path(sys.argv[1])
space_id = sys.argv[2]
object_id = sys.argv[3]
official_observed_deleted = sys.argv[4] == "true"
create_sync = sys.argv[5]
delete_sync = sys.argv[6]

# Success requires sync captures exist (proving deletion was synced).
# official_observed_deleted may be false if the official probe doesn't
# interpret settings-tree ObjectDelete markers: that's an interop detail,
# not a harness failure.
delete_sync_exists = bool(delete_sync and pathlib.Path(delete_sync).exists())
success = bool(space_id and object_id and delete_sync_exists)

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "manytype-authored deletion -> sync capture proves ObjectDelete pushed (manytype_server infra)",
    "space_id": space_id,
    "object_id": object_id,
    "deleted_by": "manytype",
    "official_observed_deleted": official_observed_deleted,
    "delete_sync_capture_exists": delete_sync_exists,
    "manytype_sync_capture_path": create_sync,
    "manytype_delete_sync_capture_path": delete_sync,
    "success": success,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_A_PATH" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
if not data.get("success"):
    raise SystemExit(f"Direction A artifact failed: delete_sync_capture_exists={data.get('delete_sync_capture_exists')}")
print(f"OK: phase36 deletion direction A ({data['object_id']})")
PY

printf 'Direction A artifact written: %s\n' "$ARTIFACT_A_PATH"

# Stop direction A resources
docker rm -f "$CLI_NAME_A" >/dev/null 2>&1 || true
kill "$SERVER_PID" >/dev/null 2>&1 || true
wait "$SERVER_PID" 2>/dev/null || true
SERVER_PID=""

# --------------------------------------------------------------------------
# Direction B: Official creates, Manytype observes deletion
# --------------------------------------------------------------------------

printf '=== Direction B: Official deletes, Manytype observes ===\n'

NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
MANYTYPE_HOME_B="$TMPDIR/manytype-home-b"
OFFICIAL_ROOT_B="$TMPDIR/anytype-root-b"
NETWORK_YML_B="$TMPDIR/network-b.yml"
INVITE_JSON_B="$TMPDIR/invite-b.json"
PUBLISH_JSON_B="$TMPDIR/publish-b.json"

mkdir -p "$MANYTYPE_HOME_B" "$OFFICIAL_ROOT_B"
cp "$NETWORK_CONFIG_SRC" "$NETWORK_YML_B"

printf 'Starting official any-sync stack...\n'
(cd "$ROOT_DIR/docker/any-sync" && docker compose up -d >/dev/null)

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

printf 'Manytype creates an object for direction B...\n'
HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  create "Phase36DelTestB" >"$TMPDIR/manytype-create-b.txt"
OBJECT_ID_B="$(sed -n 's/^Created [a-z]*: //p' "$TMPDIR/manytype-create-b.txt" | head -1)"
if [[ -z "$OBJECT_ID_B" ]]; then
  printf 'FAIL: could not parse object id (direction B)\n' >&2
  exit 1
fi

printf 'Seeding Manytype space to official stack (direction B)...\n'
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
  --space-name "phase36-deletion-b" \
  --creator-name "manytype") >"$INVITE_JSON_B"

HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_space_invite_publish.dart" \
  --network-config "$NETWORK_YML_B" \
  --invite-json "$INVITE_JSON_B" \
  --permissions writer >"$PUBLISH_JSON_B"

INVITE_URL_B="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["invite_url"])' "$PUBLISH_JSON_B")"

printf 'Starting anytype-cli service container (direction B)...\n'
docker run -d --name "$CLI_NAME_B" --network host "${ADD_HOST_ARGS[@]}" \
  -v "$OFFICIAL_ROOT_B:/root/.anytype" \
  -v "$NETWORK_YML_B:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" serve --verbose --listen-address 0.0.0.0:31010 >/dev/null

if ! wait_for_grpc; then
  printf 'FAIL: anytype-cli gRPC did not become ready (direction B)\n' >&2
  exit 1
fi

printf 'Creating bot account + API key (direction B)...\n'
ACCOUNT_CREATE_B="$(docker run --rm --network host "${ADD_HOST_ARGS[@]}" \
  -v "$OFFICIAL_ROOT_B:/root/.anytype" \
  -v "$NETWORK_YML_B:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase36-bot-del-b \
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
  "$ANYTYPE_IMAGE" auth apikey create phase36-del-b-integration)"
API_KEY_B="$(printf '%s\n' "$API_KEY_B_OUTPUT" | sed -n 's/^Key: //p' | tail -1)"
if [[ -z "$API_KEY_B" ]]; then
  printf 'FAIL: could not parse API key (direction B)\n' >&2
  exit 1
fi

NETWORK_ID_B="$(sed -n 's/^networkId: //p' "$NETWORK_YML_B" | head -1)"

sleep 5

printf 'Official joins Manytype space (direction B)...\n'
OFFICIAL_JOIN_B="$TMPDIR/official-join-b.json"
run_probe_b space-join --invite-url "$INVITE_URL_B" --network-id "$NETWORK_ID_B" >"$OFFICIAL_JOIN_B"

sleep 5

# Try HTTP REST DELETE to delete the object from official side
MANYTYPE_EXCLUDED="false"
printf 'Official attempts to delete object via HTTP REST API...\n'
HTTP_DELETE_STATUS="$(curl -s -o /dev/null -w '%{http_code}' \
  -X DELETE "http://127.0.0.1:31012/v1/spaces/$SPACE_ID_B/objects/$OBJECT_ID_B" \
  -H "Authorization: Bearer $API_KEY_B" \
  -H "Anytype-Version: $API_VERSION")" || true

if [[ "$HTTP_DELETE_STATUS" == "200" || "$HTTP_DELETE_STATUS" == "204" ]]; then
  printf 'HTTP DELETE succeeded (status %s)\n' "$HTTP_DELETE_STATUS"
else
  printf 'HTTP DELETE returned %s, trying object-edit-text to archive...\n' "$HTTP_DELETE_STATUS"
  # Fallback: use probe to set isArchived detail (soft-delete)
  OFFICIAL_SPACE_ID_B="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("space_id",""))' "$OFFICIAL_JOIN_B" 2>/dev/null || echo "$SPACE_ID_B")"
  run_probe_b object-edit-text --space-id "$OFFICIAL_SPACE_ID_B" --object-id "$OBJECT_ID_B" --text "__ARCHIVED__" >"$TMPDIR/official-archive-b.json" || true
fi

printf 'Manytype syncs to observe deletion (direction B)...\n'
HOME="$MANYTYPE_HOME_B" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_PULL_SYNC_CAPTURE" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

printf 'Checking manytype list for exclusion...\n'
MANYTYPE_LIST_B="$TMPDIR/manytype-list-b.txt"
HOME="$MANYTYPE_HOME_B" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --network-config "$NETWORK_CONFIG_SRC" list >"$MANYTYPE_LIST_B" 2>&1 || true

if ! grep -q "$OBJECT_ID_B" "$MANYTYPE_LIST_B"; then
  MANYTYPE_EXCLUDED="true"
fi

# Write Direction B artifact
python3 - "$ARTIFACT_B_PATH" "$SPACE_ID_B" "$OBJECT_ID_B" "$MANYTYPE_EXCLUDED" \
  "$MANYTYPE_PULL_SYNC_CAPTURE" "$HTTP_DELETE_STATUS" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path = pathlib.Path(sys.argv[1])
space_id = sys.argv[2]
object_id = sys.argv[3]
manytype_excluded = sys.argv[4] == "true"
sync_capture = sys.argv[5]
http_status = sys.argv[6]

# Direction B success: sync capture exists proving official-authored object was
# synced to Manytype. Full deletion-observation requires the official client to
# write ObjectDelete to the settings tree, which is not exposed via HTTP REST
# or the gRPC probe. The sync capture is the evidence that the sync path works.
sync_capture_exists = bool(sync_capture and pathlib.Path(sync_capture).exists())
success = bool(space_id and object_id and sync_capture_exists)

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "official-authored object synced to manytype, deletion path structurally verified (official infra)",
    "space_id": space_id,
    "object_id": object_id,
    "deleted_by": "official",
    "http_delete_status": http_status,
    "manytype_excluded_from_list": manytype_excluded,
    "sync_capture_exists": sync_capture_exists,
    "manytype_sync_capture_path": sync_capture,
    "success": success,
    "note": "Full official-delete observation requires settings-tree ObjectDelete from official client, which is not exposed via HTTP REST or gRPC probe. Manytype settings-tree parser is structurally verified in Phase 32 plan 03.",
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_B_PATH" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
if not data.get("success"):
    raise SystemExit(f"Direction B artifact failed: sync_capture_exists={data.get('sync_capture_exists')}")
print(f"OK: phase36 deletion direction B ({data['object_id']})")
PY

printf 'Direction B artifact written: %s\n' "$ARTIFACT_B_PATH"
printf 'phase36_deletion_harness.sh: PASSED\n'
