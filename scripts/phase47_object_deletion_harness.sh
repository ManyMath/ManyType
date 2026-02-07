#!/usr/bin/env bash

set -euo pipefail

# Phase 47: bounded page-object deletion parity against the self-hosted
# official stack.
#
# Proof directions:
#   - Manytype-authored delete -> official object search absence, including
#     official service restart
#   - official-authored delete -> Manytype list/read disappearance, including a
#     fresh Manytype home

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase47"
TOP_LEVEL_ARTIFACT="$ARTIFACT_DIR/object-deletion-roundtrip.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
MANYTYPE_REOPEN_HOME="$TMPDIR/manytype-home-reopen"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
NETWORK_YML="$TMPDIR/network.yml"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
CLI_NAME="phase47-anytype-cli-$$"
OFFICIAL_SPACE_ID=""
SPACE_ID=""
API_KEY=""
PREFIX=""
MANYTYPE_WAIT_CMD_TIMEOUT_SECONDS="${MANYTYPE_WAIT_CMD_TIMEOUT_SECONDS:-45}"
OFFICIAL_PROBE_WAIT_TIMEOUT="${OFFICIAL_PROBE_WAIT_TIMEOUT:-15s}"
OFFICIAL_PROBE_WAIT_ATTEMPTS="${OFFICIAL_PROBE_WAIT_ATTEMPTS:-20}"

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

run_wait_cli() {
  local home="$1"
  shift
  python3 - "$ROOT_DIR" "$home" "$MANYTYPE_WAIT_CMD_TIMEOUT_SECONDS" "$@" <<'PY'
import os
import subprocess
import sys

repo_root, home, timeout_seconds, *args = sys.argv[1:]
env = os.environ.copy()
env["HOME"] = home
cmd = [
    "dart",
    "run",
    f"{repo_root}/packages/manytype_cli/bin/manytype.dart",
    *args,
]

try:
    result = subprocess.run(
        cmd,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=float(timeout_seconds),
        check=False,
    )
    sys.stdout.buffer.write(result.stdout)
    raise SystemExit(result.returncode)
except subprocess.TimeoutExpired as exc:
    if exc.stdout:
        sys.stdout.buffer.write(exc.stdout)
    raise SystemExit(124)
PY
}

run_wait_cli_local() {
  local home="$1"
  shift
  run_wait_cli "$home" "$@"
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
value = data
for part in sys.argv[2].split("."):
    if isinstance(value, dict):
        value = value.get(part, "")
    else:
        value = ""
        break
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

wait_for_official_search() {
  local query="$1"
  local output_file="$2"
  local expr="$3"
  local failure_message="$4"
  local i

  for i in $(seq 1 "$OFFICIAL_PROBE_WAIT_ATTEMPTS"); do
    PROBE_TIMEOUT="$OFFICIAL_PROBE_WAIT_TIMEOUT" \
      run_probe object-search --space-id "$OFFICIAL_SPACE_ID" --query "$query" >"$output_file" || true
    local error_code=""
    if [[ ! -s "$output_file" ]]; then
      printf 'Waiting for official object-search (attempt %s/%s)...\n' "$i" "$OFFICIAL_PROBE_WAIT_ATTEMPTS"
      sleep 2
      continue
    fi
    error_code="$(json_get "$output_file" error_code 2>/dev/null || true)"
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
    printf 'Waiting for official object-search (attempt %s/%s)...\n' "$i" "$OFFICIAL_PROBE_WAIT_ATTEMPTS"
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
  local mode="${6:-network}"
  local i

  for i in $(seq 1 60); do
    local status=0
    set +e
    if [[ "$mode" == "local" ]]; then
      run_wait_cli_local "$home" read "$object_id" >"$output_file" 2>&1
    else
      run_wait_cli "$home" --network-config "$NETWORK_CONFIG_SRC" read --sync "$object_id" >"$output_file" 2>&1
    fi
    status=$?
    set -e
    if STATUS="$status" python3 - "$output_file" "$expr" <<'PY'
import os
import pathlib
import sys

text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
expr = sys.argv[2]
scope = {"__builtins__": {}, "text": text, "env": os.environ, "int": int, "len": len}
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

wait_for_manytype_list() {
  local home="$1"
  local output_file="$2"
  local expr="$3"
  local failure_message="$4"
  local mode="${5:-network}"
  local i

  for i in $(seq 1 60); do
    local status=0
    set +e
    if [[ "$mode" == "local" ]]; then
      run_wait_cli_local "$home" list >"$output_file" 2>&1
    else
      run_wait_cli "$home" --network-config "$NETWORK_CONFIG_SRC" list >"$output_file" 2>&1
    fi
    status=$?
    set -e
    if STATUS="$status" python3 - "$output_file" "$expr" <<'PY'
import os
import pathlib
import re
import sys

text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
expr = sys.argv[2]
list_lines = [
    line
    for line in text.splitlines()
    if re.match(r"^bafy[a-z0-9]+\s{2,}\S+\s{2,}.+", line)
]
list_text = "\n".join(list_lines)
scope = {
    "__builtins__": {},
    "text": text,
    "list_lines": list_lines,
    "list_text": list_text,
    "env": os.environ,
    "int": int,
    "len": len,
}
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

wait_for_manytype_sync() {
  local home="$1"
  local output_file="$2"
  local failure_message="$3"
  local i

  for i in $(seq 1 20); do
    local status=0
    set +e
    run_wait_cli "$home" --network-config "$NETWORK_CONFIG_SRC" sync >"$output_file" 2>&1
    status=$?
    set -e
    if [[ "$status" -eq 0 ]]; then
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

printf '=== Phase 47: object deletion parity ===\n\n'

oracle_run_preflight
mkdir -p "$ARTIFACT_DIR" "$MANYTYPE_HOME" "$MANYTYPE_REOPEN_HOME" "$OFFICIAL_ROOT"
cp "$NETWORK_CONFIG_SRC" "$NETWORK_YML"
rm -f "$TOP_LEVEL_ARTIFACT" "$RUNTIME_METADATA_PATH"

oracle_export_runtime_env

printf 'Building official probe binary...\n'
oracle_build_probe_binary "$PROBE_BIN"

printf 'Starting official any-sync stack...\n'
oracle_compose_up
ADD_HOST_ARGS=()
oracle_populate_add_host_args ADD_HOST_ARGS

PREFIX="phase47-$(date +%s%N)"
MANYTYPE_OBJECT_NAME="$PREFIX manytype deletion target"
OFFICIAL_OBJECT_NAME="$PREFIX official deletion target"

printf 'Preparing Manytype home...\n'
run_cli "$MANYTYPE_HOME" init >/dev/null
run_cli "$MANYTYPE_HOME" create "${PREFIX}-seed" >"$TMPDIR/manytype-seed-create.txt"
SEED_OBJECT_ID="$(extract_created_id "$TMPDIR/manytype-seed-create.txt")"
[[ -n "$SEED_OBJECT_ID" ]] || fail 'could not parse Manytype seed object id'
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
ACCOUNT_KEY="$(oracle_create_official_account "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS phase47-bot)"
[[ -n "$ACCOUNT_KEY" ]] || fail 'could not parse official account key'

printf 'Waiting for authenticated official CLI session...\n'
if ! oracle_wait_for_cli_session "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS; then
  fail 'official CLI session did not become ready'
fi

API_KEY_OUTPUT="$(oracle_create_official_api_key "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS phase47-integration)"
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

printf 'Scenario 1/2: Manytype-authored delete -> official disappearance...\n'
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  "$MANYTYPE_OBJECT_NAME" >"$TMPDIR/manytype-target-create.txt"
MANYTYPE_OBJECT_ID="$(extract_created_id "$TMPDIR/manytype-target-create.txt")"
[[ -n "$MANYTYPE_OBJECT_ID" ]] || fail 'could not parse Manytype-authored object id'

EXPECTED_OBJECT_ID="$MANYTYPE_OBJECT_ID" \
wait_for_official_search \
  "$MANYTYPE_OBJECT_NAME" \
  "$ARTIFACT_DIR/manytype_to_official_predelete-search.json" \
  'env["EXPECTED_OBJECT_ID"] in data.get("object_ids", [])' \
  'official client never discovered Manytype-authored object before delete'

MANYTYPE_DELETE_CAPTURE="$ARTIFACT_DIR/manytype_to_official_delete-sync.json"
MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_DELETE_CAPTURE" \
  run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" \
    delete --id "$MANYTYPE_OBJECT_ID" >"$ARTIFACT_DIR/manytype_to_official_delete.txt"

EXPECTED_OBJECT_ID="$MANYTYPE_OBJECT_ID" \
wait_for_official_search \
  "$MANYTYPE_OBJECT_NAME" \
  "$ARTIFACT_DIR/manytype_to_official_postdelete-search.json" \
  'env["EXPECTED_OBJECT_ID"] not in data.get("object_ids", [])' \
  'official client still discovered Manytype-deleted object after sync'

printf 'Restarting official client service for reopen proof...\n'
restart_official_service ADD_HOST_ARGS
EXPECTED_OBJECT_ID="$MANYTYPE_OBJECT_ID" \
wait_for_official_search \
  "$MANYTYPE_OBJECT_NAME" \
  "$ARTIFACT_DIR/manytype_to_official_restart-search.json" \
  'env["EXPECTED_OBJECT_ID"] not in data.get("object_ids", [])' \
  'official client rediscovered Manytype-deleted object after restart'

printf 'Scenario 2/2: official-authored delete -> Manytype disappearance...\n'
run_probe object-show --space-id "$OFFICIAL_SPACE_ID" --object-id "$SEED_OBJECT_ID" >"$ARTIFACT_DIR/official_to_manytype_preload-show.json"
PRELOAD_ERROR_CODE="$(json_get "$ARTIFACT_DIR/official_to_manytype_preload-show.json" error_code 2>/dev/null || true)"
[[ -z "$PRELOAD_ERROR_CODE" ]] || fail "official preload object-show returned error ($PRELOAD_ERROR_CODE)"
PRELOAD_TYPE_ID="$(json_get "$ARTIFACT_DIR/official_to_manytype_preload-show.json" root_details.type 2>/dev/null || true)"
[[ -n "$PRELOAD_TYPE_ID" ]] || fail 'official preload object-show did not expose root_details.type'
run_probe object-show --space-id "$OFFICIAL_SPACE_ID" --object-id "$PRELOAD_TYPE_ID" >"$ARTIFACT_DIR/official_to_manytype_preload-type-show.json"
PRELOAD_TYPE_ERROR_CODE="$(json_get "$ARTIFACT_DIR/official_to_manytype_preload-type-show.json" error_code 2>/dev/null || true)"
[[ -z "$PRELOAD_TYPE_ERROR_CODE" ]] || fail "official preload type object-show returned error ($PRELOAD_TYPE_ERROR_CODE)"

run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$OFFICIAL_OBJECT_NAME" >"$ARTIFACT_DIR/official_to_manytype_create.json"
OFFICIAL_CREATE_ERROR_CODE="$(json_get "$ARTIFACT_DIR/official_to_manytype_create.json" error_code 2>/dev/null || true)"
OFFICIAL_OBJECT_ID="$(json_get "$ARTIFACT_DIR/official_to_manytype_create.json" object_id)"
if [[ -n "$OFFICIAL_CREATE_ERROR_CODE" ]]; then
  fail "official object-create returned error ($OFFICIAL_CREATE_ERROR_CODE)"
fi
[[ -n "$OFFICIAL_OBJECT_ID" ]] || fail 'could not parse official-authored object id'

EXPECTED_OBJECT_ID="$OFFICIAL_OBJECT_ID" \
wait_for_manytype_read \
  "$MANYTYPE_HOME" \
  "$OFFICIAL_OBJECT_ID" \
  "$ARTIFACT_DIR/official_to_manytype_predelete-read.txt" \
  'int(env["STATUS"]) == 0 and ("Object: " + env["EXPECTED_OBJECT_ID"]) in text' \
  'Manytype never synced official-authored object before delete'

run_probe object-delete --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_OBJECT_ID" >"$ARTIFACT_DIR/official_to_manytype_delete.json"
DELETE_ERROR_CODE="$(json_get "$ARTIFACT_DIR/official_to_manytype_delete.json" error_code 2>/dev/null || true)"
DELETE_ATTEMPTED="$(json_get "$ARTIFACT_DIR/official_to_manytype_delete.json" delete_attempted 2>/dev/null || true)"
[[ -z "$DELETE_ERROR_CODE" ]] || fail "official object-delete returned error ($DELETE_ERROR_CODE)"
[[ "$DELETE_ATTEMPTED" == "true" ]] || fail 'official object-delete did not reach delete step'

OFFICIAL_SYNC_CAPTURE="$ARTIFACT_DIR/official_to_manytype_sync.json"
MANYTYPE_SYNC_CAPTURE_PATH="$OFFICIAL_SYNC_CAPTURE" \
  run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

EXPECTED_OBJECT_ID="$OFFICIAL_OBJECT_ID" \
  wait_for_manytype_list \
  "$MANYTYPE_HOME" \
  "$ARTIFACT_DIR/official_to_manytype_postdelete-list.txt" \
  'int(env["STATUS"]) == 0 and env["EXPECTED_OBJECT_ID"] not in list_text' \
  'Manytype list still showed the official-deleted object' \
  local

EXPECTED_OBJECT_ID="$OFFICIAL_OBJECT_ID" \
wait_for_manytype_read \
  "$MANYTYPE_HOME" \
  "$OFFICIAL_OBJECT_ID" \
  "$ARTIFACT_DIR/official_to_manytype_postdelete-read.txt" \
  '(int(env["STATUS"]) == 1 and ("Object " + env["EXPECTED_OBJECT_ID"] + " has been deleted or archived") in text) or (int(env["STATUS"]) == 0 and ("Object not found: " + env["EXPECTED_OBJECT_ID"]) in text)' \
  'Manytype read still surfaced the official-deleted object' \
  local

printf 'Creating fresh Manytype home for reopen proof...\n'
mkdir -p "$MANYTYPE_REOPEN_HOME/.manytype"
cp "$MANYTYPE_HOME/.manytype/config.toml" "$MANYTYPE_REOPEN_HOME/.manytype/config.toml"
wait_for_manytype_sync \
  "$MANYTYPE_REOPEN_HOME" \
  "$TMPDIR/official_to_manytype_reopen-sync.txt" \
  'Fresh Manytype home could not sync the official-deleted object state'

EXPECTED_OBJECT_ID="$OFFICIAL_OBJECT_ID" \
  wait_for_manytype_list \
  "$MANYTYPE_REOPEN_HOME" \
  "$ARTIFACT_DIR/official_to_manytype_reopen-list.txt" \
  'int(env["STATUS"]) == 0 and env["EXPECTED_OBJECT_ID"] not in list_text' \
  'Fresh Manytype home still listed the official-deleted object' \
  local

EXPECTED_OBJECT_ID="$OFFICIAL_OBJECT_ID" \
wait_for_manytype_read \
  "$MANYTYPE_REOPEN_HOME" \
  "$OFFICIAL_OBJECT_ID" \
  "$ARTIFACT_DIR/official_to_manytype_reopen-read.txt" \
  '(int(env["STATUS"]) == 1 and ("Object " + env["EXPECTED_OBJECT_ID"] + " has been deleted or archived") in text) or (int(env["STATUS"]) == 0 and ("Object not found: " + env["EXPECTED_OBJECT_ID"]) in text)' \
  'Fresh Manytype home still surfaced the official-deleted object' \
  local

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase47 object deletion roundtrip" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$TOP_LEVEL_ARTIFACT" \
  "$ARTIFACT_DIR/official-join.json" \
  "$ARTIFACT_DIR/manytype_to_official_predelete-search.json" \
  "$ARTIFACT_DIR/manytype_to_official_delete.txt" \
  "$MANYTYPE_DELETE_CAPTURE" \
  "$ARTIFACT_DIR/manytype_to_official_postdelete-search.json" \
  "$ARTIFACT_DIR/manytype_to_official_restart-search.json" \
  "$ARTIFACT_DIR/official_to_manytype_preload-show.json" \
  "$ARTIFACT_DIR/official_to_manytype_preload-type-show.json" \
  "$ARTIFACT_DIR/official_to_manytype_create.json" \
  "$ARTIFACT_DIR/official_to_manytype_predelete-read.txt" \
  "$ARTIFACT_DIR/official_to_manytype_delete.json" \
  "$OFFICIAL_SYNC_CAPTURE" \
  "$ARTIFACT_DIR/official_to_manytype_postdelete-list.txt" \
  "$ARTIFACT_DIR/official_to_manytype_postdelete-read.txt" \
  "$ARTIFACT_DIR/official_to_manytype_reopen-list.txt" \
  "$ARTIFACT_DIR/official_to_manytype_reopen-read.txt"

python3 - \
  "$TOP_LEVEL_ARTIFACT" \
  "$MANYTYPE_OBJECT_ID" \
  "$MANYTYPE_OBJECT_NAME" \
  "$ARTIFACT_DIR/manytype_to_official_predelete-search.json" \
  "$ARTIFACT_DIR/manytype_to_official_delete.txt" \
  "$MANYTYPE_DELETE_CAPTURE" \
  "$ARTIFACT_DIR/manytype_to_official_postdelete-search.json" \
  "$ARTIFACT_DIR/manytype_to_official_restart-search.json" \
  "$OFFICIAL_OBJECT_ID" \
  "$OFFICIAL_OBJECT_NAME" \
  "$ARTIFACT_DIR/official_to_manytype_preload-type-show.json" \
  "$ARTIFACT_DIR/official_to_manytype_create.json" \
  "$ARTIFACT_DIR/official_to_manytype_predelete-read.txt" \
  "$ARTIFACT_DIR/official_to_manytype_delete.json" \
  "$OFFICIAL_SYNC_CAPTURE" \
  "$ARTIFACT_DIR/official_to_manytype_postdelete-list.txt" \
  "$ARTIFACT_DIR/official_to_manytype_postdelete-read.txt" \
  "$ARTIFACT_DIR/official_to_manytype_reopen-list.txt" \
  "$ARTIFACT_DIR/official_to_manytype_reopen-read.txt" \
  "$RUNTIME_METADATA_PATH" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    manytype_object_id,
    manytype_object_name,
    manytype_presence_search_path,
    manytype_delete_output_path,
    manytype_delete_sync_capture_path,
    manytype_absence_search_path,
    manytype_restart_search_path,
    official_object_id,
    official_object_name,
    official_type_preload_output_path,
    official_create_output_path,
    official_predelete_read_path,
    official_delete_output_path,
    official_sync_capture_path,
    official_postdelete_list_path,
    official_postdelete_read_path,
    official_reopen_list_path,
    official_reopen_read_path,
    metadata_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase47 object deletion roundtrip",
    "bounded_object_type": "page",
    "manytype_to_official": {
        "object_id": manytype_object_id,
        "object_name": manytype_object_name,
        "presence_search_path": manytype_presence_search_path,
        "delete_output_path": manytype_delete_output_path,
        "delete_sync_capture_path": manytype_delete_sync_capture_path,
        "absence_search_path": manytype_absence_search_path,
        "restart_absence_search_path": manytype_restart_search_path,
    },
    "official_to_manytype": {
        "object_id": official_object_id,
        "object_name": official_object_name,
        "type_preload_path": official_type_preload_output_path,
        "create_output_path": official_create_output_path,
        "predelete_read_path": official_predelete_read_path,
        "delete_output_path": official_delete_output_path,
        "sync_capture_path": official_sync_capture_path,
        "list_absence_path": official_postdelete_list_path,
        "read_refusal_path": official_postdelete_read_path,
        "reopen_list_absence_path": official_reopen_list_path,
        "reopen_read_refusal_path": official_reopen_read_path,
    },
    "metadata_path": metadata_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Runtime metadata written to %s\n' "$RUNTIME_METADATA_PATH"
printf 'Phase 47 artifact written to %s\n' "$TOP_LEVEL_ARTIFACT"
printf 'phase47 harness: PASSED\n'
