#!/usr/bin/env bash

set -euo pipefail

# Phase 46: bounded page-rooted object/detail expansion against the
# self-hosted official stack.
#
# Accepted edit set:
#   - description (string detail)
#   - featuredRelations (string-list detail)
#
# Proof directions:
#   - Manytype-authored -> official-observed, including official service restart
#   - official-authored -> Manytype-observed, including a fresh Manytype home

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
FINAL_ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase46"
FINAL_TOP_LEVEL_ARTIFACT="$FINAL_ARTIFACT_DIR/bounded-object-edit-roundtrip.json"
FINAL_RUNTIME_METADATA_PATH="$FINAL_ARTIFACT_DIR/runtime-metadata.json"

TMPDIR="$(mktemp -d)"
ARTIFACT_DIR="$TMPDIR/phase46-artifacts"
TOP_LEVEL_ARTIFACT="$ARTIFACT_DIR/bounded-object-edit-roundtrip.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
MANYTYPE_HOME="$TMPDIR/manytype-home"
MANYTYPE_REOPEN_HOME="$TMPDIR/manytype-home-reopen"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
NETWORK_YML="$TMPDIR/network.yml"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
CLI_NAME="phase46-anytype-cli-$$"
OFFICIAL_SPACE_ID=""
SPACE_ID=""
API_KEY=""
PREFIX=""
OFFICIAL_PROBE_WAIT_TIMEOUT="${OFFICIAL_PROBE_WAIT_TIMEOUT:-15s}"
OFFICIAL_PROBE_WAIT_ATTEMPTS="${OFFICIAL_PROBE_WAIT_ATTEMPTS:-20}"
PHASE46_SETTLE_SECONDS="${PHASE46_SETTLE_SECONDS:-12}"

cleanup() {
  if docker ps -a --format '{{.Names}}' | grep -Fxq "$CLI_NAME"; then
    docker logs "$CLI_NAME" >"$TMPDIR/anytype-cli.log" 2>&1 || true
  fi
  docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
  if [[ "${KEEP_TMPDIR:-0}" != "1" ]]; then
    rm -rf "$TMPDIR" >/dev/null 2>&1 || true
  else
    printf 'Kept tempdir: %s\n' "$TMPDIR"
  fi
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

run_cli() {
  local home="$1"
  shift
  oracle_run_cli "$home" "$@"
}

run_probe() {
  local action="$1"
  shift
  oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" "$action" "$@"
}

extract_created_id() {
  local file="$1"
  sed -n 's/^Created [^:]*: //p' "$file" | head -1
}

json_get() {
  local file="$1"
  local key="$2"
  python3 - "$file" "$key" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1]))
value = data.get(sys.argv[2], "")
if value is True:
    print("true")
elif value is False:
    print("false")
elif value is None:
    print("")
else:
    print(value)
PY
}

wait_for_spaces_api() {
  local api_key="$1"
  local output_file="$2"
  local i
  for i in $(seq 1 60); do
    if curl -sf http://127.0.0.1:31012/v1/spaces \
      -H "Anytype-Version: 2025-11-08" \
      -H "Authorization: Bearer $api_key" >"$output_file" 2>/dev/null; then
      return 0
    fi
    sleep 1
  done
  return 1
}

wait_for_official_show() {
  local object_id="$1"
  local output_file="$2"
  local expr="$3"
  local failure_message="$4"
  local i

  for i in $(seq 1 "$OFFICIAL_PROBE_WAIT_ATTEMPTS"); do
    PROBE_TIMEOUT="$OFFICIAL_PROBE_WAIT_TIMEOUT" \
      run_probe object-show --space-id "$OFFICIAL_SPACE_ID" --object-id "$object_id" >"$output_file" || true
    local error_code=""
    if [[ ! -s "$output_file" ]]; then
      printf 'Waiting for official object-show (attempt %s/%s)...\n' "$i" "$OFFICIAL_PROBE_WAIT_ATTEMPTS"
      sleep 2
      continue
    fi
    if [[ -f "$output_file" ]]; then
      error_code="$(json_get "$output_file" error_code 2>/dev/null || true)"
    fi
    if [[ -z "$error_code" ]]; then
      if python3 - "$output_file" "$expr" <<'PY'
import json
import os
import sys

data = json.load(open(sys.argv[1]))
expr = sys.argv[2]
safe = {"any": any, "all": all, "len": len, "sorted": sorted, "str": str}
scope = {"__builtins__": {}, "data": data, "env": os.environ, **safe}
ok = eval(expr, scope, {})
raise SystemExit(0 if ok else 1)
PY
      then
        return 0
      fi
    fi
    printf 'Waiting for official object-show (attempt %s/%s)...\n' "$i" "$OFFICIAL_PROBE_WAIT_ATTEMPTS"
    sleep 2
  done

  fail "$failure_message"
}

wait_for_manytype_read() {
  local home="$1"
  local object_id="$2"
  local output_file="$3"
  local expr="$4"
  local failure_message="$5"
  local i

  for i in $(seq 1 60); do
    run_cli "$home" --network-config "$NETWORK_CONFIG_SRC" read --sync "$object_id" >"$output_file" || true
    if python3 - "$output_file" "$expr" <<'PY'
import os
import pathlib
import sys

text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
expr = sys.argv[2]
scope = {"__builtins__": {}, "text": text, "env": os.environ, "len": len}
ok = eval(expr, scope, {})
raise SystemExit(0 if ok else 1)
PY
    then
      return 0
    fi
    sleep 2
  done

  fail "$failure_message"
}

restart_official_service() {
  local add_host_args_name="$1"
  docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
  oracle_start_cli_service "$CLI_NAME" "$OFFICIAL_ROOT" "$NETWORK_YML" "$add_host_args_name"
  if ! oracle_wait_for_grpc; then
    fail 'official gRPC service did not become ready after restart'
  fi
  if ! oracle_wait_for_cli_session "$OFFICIAL_ROOT" "$NETWORK_YML" "$add_host_args_name"; then
    fail 'official CLI session did not become ready after restart'
  fi
}

printf '=== Phase 46: bounded object/edit expansion ===\n\n'

oracle_run_preflight
mkdir -p "$FINAL_ARTIFACT_DIR" "$ARTIFACT_DIR" "$MANYTYPE_HOME" "$MANYTYPE_REOPEN_HOME" "$OFFICIAL_ROOT"
cp "$NETWORK_CONFIG_SRC" "$NETWORK_YML"

oracle_export_runtime_env

printf 'Building official probe binary...\n'
oracle_build_probe_binary "$PROBE_BIN"

printf 'Starting official any-sync stack...\n'
oracle_compose_up
ADD_HOST_ARGS=()
oracle_populate_add_host_args ADD_HOST_ARGS

PREFIX="phase46-$(date +%s%N)"
MANYTYPE_DESCRIPTION="$PREFIX manytype description"
MANYTYPE_FEATURED="description,sourceObject"
OFFICIAL_DESCRIPTION="$PREFIX official description"
OFFICIAL_FEATURED="description,sourceObject"

printf 'Preparing Manytype home...\n'
run_cli "$MANYTYPE_HOME" init >/dev/null
run_cli "$MANYTYPE_HOME" create "${PREFIX}-seed" >"$TMPDIR/manytype-seed-create.txt"
oracle_seed_live_space "$MANYTYPE_HOME" "$NETWORK_CONFIG_SRC" 10
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

printf 'Computing invite material...\n'
SPACE_INFO_JSON="$(oracle_identity_json "$MANYTYPE_HOME")"
SPACE_ID="$(printf '%s' "$SPACE_INFO_JSON" | oracle_json_stdin_field space_id)"
oracle_generate_invite_from_home "$MANYTYPE_HOME" "$PREFIX" "manytype" "$INVITE_JSON"
oracle_publish_invite "$MANYTYPE_HOME" "$NETWORK_YML" "$INVITE_JSON" "$PUBLISH_JSON" writer

INVITE_URL="$(oracle_invite_url_from_json "$PUBLISH_JSON")"
NETWORK_ID="$(sed -n 's/^networkId: //p' "$NETWORK_YML" | head -1)"
[[ -n "$INVITE_URL" ]] || fail 'could not parse invite url'
[[ -n "$NETWORK_ID" ]] || fail 'could not parse networkId'

printf 'Starting official anytype-cli service...\n'
oracle_start_cli_service "$CLI_NAME" "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS
if ! oracle_wait_for_grpc; then
  fail 'official gRPC service did not become ready on 127.0.0.1:31010'
fi

printf 'Creating official account...\n'
ACCOUNT_KEY="$(oracle_create_official_account "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS phase46-bot)"
[[ -n "$ACCOUNT_KEY" ]] || fail 'could not parse official account key'

printf 'Waiting for authenticated official CLI session...\n'
if ! oracle_wait_for_cli_session "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS; then
  fail 'official CLI session did not become ready'
fi

API_KEY_OUTPUT="$(oracle_create_official_api_key "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS phase46-integration)"
API_KEY="$(printf '%s\n' "$API_KEY_OUTPUT" | sed -n 's/^Key: //p' | tail -1)"
[[ -n "$API_KEY" ]] || fail 'could not parse official API key'

printf 'Waiting for official HTTP API...\n'
if ! wait_for_spaces_api "$API_KEY" "$TMPDIR/official-spaces.json"; then
  fail 'official spaces API did not become ready on 127.0.0.1:31012'
fi

printf 'Joining shared space from official client...\n'
run_probe space-join --invite-url "$INVITE_URL" --network-id "$NETWORK_ID" --space-id "$SPACE_ID" >"$ARTIFACT_DIR/official-join.json"
JOIN_ERROR_CODE="$(json_get "$ARTIFACT_DIR/official-join.json" error_code 2>/dev/null || true)"
[[ -z "$JOIN_ERROR_CODE" ]] || fail "SpaceJoin returned error ($JOIN_ERROR_CODE)"

OFFICIAL_SPACE_ID="$(json_get "$ARTIFACT_DIR/official-join.json" space_id)"
if [[ -z "$OFFICIAL_SPACE_ID" ]]; then
  OFFICIAL_SPACE_ID="$SPACE_ID"
fi

sleep 5

printf 'Scenario 1/2: Manytype-authored bounded detail edits -> official observation...\n'
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  "$PREFIX manytype target" >"$TMPDIR/manytype-target-create.txt"
MANYTYPE_OBJECT_ID="$(extract_created_id "$TMPDIR/manytype-target-create.txt")"
[[ -n "$MANYTYPE_OBJECT_ID" ]] || fail 'could not parse Manytype-authored object id'

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" \
  edit --id "$MANYTYPE_OBJECT_ID" --relation description --string "$MANYTYPE_DESCRIPTION" >/dev/null
MANYTYPE_SYNC_CAPTURE="$ARTIFACT_DIR/manytype_to_official_sync.json"
MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE" \
  run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" \
    edit --id "$MANYTYPE_OBJECT_ID" --relation featuredRelations --string-list "$MANYTYPE_FEATURED" >/dev/null

# Official `object-show` opens object context and can emit its own head update
# (for example `lastOpenedDate`) as soon as the object becomes visible. If we
# probe immediately, that write can race with the in-flight Manytype edits and
# strand official nodes on an intermediate sibling head before the bounded
# detail changes finish propagating.
printf 'Waiting %ss for Manytype-authored edits to settle across official nodes...\n' "$PHASE46_SETTLE_SECONDS"
sleep "$PHASE46_SETTLE_SECONDS"

EXPECTED_DESCRIPTION="$MANYTYPE_DESCRIPTION" EXPECTED_FEATURED_A="description" EXPECTED_FEATURED_B="sourceObject" \
wait_for_official_show \
  "$MANYTYPE_OBJECT_ID" \
  "$ARTIFACT_DIR/manytype_to_official_show.json" \
  'data.get("root_details", {}).get("description") == env["EXPECTED_DESCRIPTION"] and data.get("root_details", {}).get("featuredRelations") == [env["EXPECTED_FEATURED_A"], env["EXPECTED_FEATURED_B"]]' \
  'official client did not observe Manytype-authored bounded detail edits'

printf 'Restarting official client service for reopen proof...\n'
restart_official_service ADD_HOST_ARGS
EXPECTED_DESCRIPTION="$MANYTYPE_DESCRIPTION" EXPECTED_FEATURED_A="description" EXPECTED_FEATURED_B="sourceObject" \
wait_for_official_show \
  "$MANYTYPE_OBJECT_ID" \
  "$ARTIFACT_DIR/manytype_to_official_restart-show.json" \
  'data.get("root_details", {}).get("description") == env["EXPECTED_DESCRIPTION"] and data.get("root_details", {}).get("featuredRelations") == [env["EXPECTED_FEATURED_A"], env["EXPECTED_FEATURED_B"]]' \
  'official client did not retain Manytype-authored bounded detail edits after restart'

printf 'Scenario 2/2: official-authored bounded detail edits -> Manytype observation...\n'
run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official target" >"$TMPDIR/official-create.json"
OFFICIAL_OBJECT_ID="$(json_get "$TMPDIR/official-create.json" object_id)"
[[ -n "$OFFICIAL_OBJECT_ID" ]] || fail 'could not parse official-authored object id'

run_probe object-set-detail \
  --space-id "$OFFICIAL_SPACE_ID" \
  --object-id "$OFFICIAL_OBJECT_ID" \
  --detail-key description \
  --detail-kind string \
  --detail-value "$OFFICIAL_DESCRIPTION" >"$ARTIFACT_DIR/official_to_manytype_description-set.json"
run_probe object-set-detail \
  --space-id "$OFFICIAL_SPACE_ID" \
  --object-id "$OFFICIAL_OBJECT_ID" \
  --detail-key featuredRelations \
  --detail-kind string-list \
  --detail-values "$OFFICIAL_FEATURED" >"$ARTIFACT_DIR/official_to_manytype_featured-set.json"

OFFICIAL_SYNC_CAPTURE="$ARTIFACT_DIR/official_to_manytype_sync.json"
MANYTYPE_SYNC_CAPTURE_PATH="$OFFICIAL_SYNC_CAPTURE" \
  run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

EXPECTED_DESCRIPTION="$OFFICIAL_DESCRIPTION" \
wait_for_manytype_read \
  "$MANYTYPE_HOME" \
  "$OFFICIAL_OBJECT_ID" \
  "$ARTIFACT_DIR/official_to_manytype_read.txt" \
  '("[description] " + env["EXPECTED_DESCRIPTION"]) in text and "[featuredRelations] description, sourceObject" in text' \
  'Manytype did not observe official-authored bounded detail edits'

printf 'Creating fresh Manytype home for reopen proof...\n'
mkdir -p "$MANYTYPE_REOPEN_HOME/.manytype"
cp "$MANYTYPE_HOME/.manytype/config.toml" "$MANYTYPE_REOPEN_HOME/.manytype/config.toml"

EXPECTED_DESCRIPTION="$OFFICIAL_DESCRIPTION" \
wait_for_manytype_read \
  "$MANYTYPE_REOPEN_HOME" \
  "$OFFICIAL_OBJECT_ID" \
  "$ARTIFACT_DIR/official_to_manytype_reopen-read.txt" \
  '("[description] " + env["EXPECTED_DESCRIPTION"]) in text and "[featuredRelations] description, sourceObject" in text' \
  'Fresh Manytype home did not retain official-authored bounded detail edits'

find "$ARTIFACT_DIR" -maxdepth 1 -type f -exec cp -f {} "$FINAL_ARTIFACT_DIR"/ \;

oracle_write_metadata \
  "$FINAL_RUNTIME_METADATA_PATH" \
  "phase46 bounded object edit roundtrip" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$FINAL_TOP_LEVEL_ARTIFACT" \
  "$FINAL_ARTIFACT_DIR/official-join.json" \
  "$FINAL_ARTIFACT_DIR/manytype_to_official_show.json" \
  "$FINAL_ARTIFACT_DIR/manytype_to_official_restart-show.json" \
  "$FINAL_ARTIFACT_DIR/official_to_manytype_read.txt" \
  "$FINAL_ARTIFACT_DIR/official_to_manytype_reopen-read.txt" \
  "$FINAL_ARTIFACT_DIR/official_to_manytype_description-set.json" \
  "$FINAL_ARTIFACT_DIR/official_to_manytype_featured-set.json" \
  "$FINAL_ARTIFACT_DIR/manytype_to_official_sync.json" \
  "$FINAL_ARTIFACT_DIR/official_to_manytype_sync.json"

python3 - \
  "$FINAL_TOP_LEVEL_ARTIFACT" \
  "$MANYTYPE_OBJECT_ID" \
  "$MANYTYPE_DESCRIPTION" \
  "$FINAL_ARTIFACT_DIR/manytype_to_official_show.json" \
  "$FINAL_ARTIFACT_DIR/manytype_to_official_restart-show.json" \
  "$FINAL_ARTIFACT_DIR/manytype_to_official_sync.json" \
  "$OFFICIAL_OBJECT_ID" \
  "$OFFICIAL_DESCRIPTION" \
  "$FINAL_ARTIFACT_DIR/official_to_manytype_read.txt" \
  "$FINAL_ARTIFACT_DIR/official_to_manytype_reopen-read.txt" \
  "$FINAL_ARTIFACT_DIR/official_to_manytype_sync.json" \
  "$FINAL_RUNTIME_METADATA_PATH" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    manytype_object_id,
    manytype_description,
    manytype_show_path,
    manytype_restart_show_path,
    manytype_sync_capture_path,
    official_object_id,
    official_description,
    official_read_path,
    official_reopen_read_path,
    official_sync_capture_path,
    metadata_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase46 bounded object/detail roundtrip",
    "accepted_edit_set": {
        "string_detail_key": "description",
        "string_list_detail_key": "featuredRelations",
        "string_list_value": ["description", "sourceObject"],
    },
    "manytype_to_official": {
        "object_id": manytype_object_id,
        "description": manytype_description,
        "show_path": manytype_show_path,
        "restart_show_path": manytype_restart_show_path,
        "sync_capture_path": manytype_sync_capture_path,
    },
    "official_to_manytype": {
        "object_id": official_object_id,
        "description": official_description,
        "read_path": official_read_path,
        "reopen_read_path": official_reopen_read_path,
        "sync_capture_path": official_sync_capture_path,
    },
    "metadata_path": metadata_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Runtime metadata written to %s\n' "$FINAL_RUNTIME_METADATA_PATH"
printf 'Phase 46 artifact written to %s\n' "$FINAL_TOP_LEVEL_ARTIFACT"
printf 'phase46 harness: PASSED\n'
