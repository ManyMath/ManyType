#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase59"
ARTIFACT_PATH="$ARTIFACT_DIR/self-hosted-delete-compatibility.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
PHASE47_BUNDLE="$ROOT_DIR/test_vectors/phase47/object-deletion-roundtrip.json"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
NETWORK_YML="$TMPDIR/network.yml"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
CLI_NAME="phase59-anytype-cli-$$"
OFFICIAL_SPACE_ID=""
SPACE_ID=""
API_KEY=""
PREFIX=""
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
      oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" object-search \
        --space-id "$OFFICIAL_SPACE_ID" \
        --query "$query" >"$output_file" || true
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

printf '=== Phase 59: Manytype -> official self-hosted delete compatibility ===\n\n'

oracle_run_preflight
mkdir -p "$ARTIFACT_DIR" "$MANYTYPE_HOME" "$OFFICIAL_ROOT"
cp "$NETWORK_CONFIG_SRC" "$NETWORK_YML"
rm -f "$ARTIFACT_DIR"/*.json "$ARTIFACT_DIR"/*.txt

oracle_export_runtime_env

printf 'Building official probe binary...\n'
oracle_build_probe_binary "$PROBE_BIN"

printf 'Starting official any-sync stack...\n'
oracle_compose_up
ADD_HOST_ARGS=()
oracle_populate_add_host_args ADD_HOST_ARGS

PREFIX="phase59-$(date +%s%N)"
MANYTYPE_OBJECT_NAME="$PREFIX manytype deletion target"

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
ACCOUNT_KEY="$(oracle_create_official_account "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS phase59-bot)"
[[ -n "$ACCOUNT_KEY" ]] || fail 'could not parse official account key'

printf 'Waiting for authenticated official CLI session...\n'
if ! oracle_wait_for_cli_session "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS; then
  fail 'official CLI session did not become ready'
fi

API_KEY_OUTPUT="$(oracle_create_official_api_key "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS phase59-integration)"
API_KEY="$(printf '%s\n' "$API_KEY_OUTPUT" | sed -n 's/^Key: //p' | tail -1)"
[[ -n "$API_KEY" ]] || fail 'could not parse official API key'

printf 'Waiting for official HTTP API...\n'
if ! wait_for_spaces_api "$API_KEY" "$TMPDIR/official-spaces.json"; then
  fail 'official spaces API did not become ready on 127.0.0.1:31012'
fi

printf 'Joining shared space from official client...\n'
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" space-join \
  --invite-url "$INVITE_URL" \
  --network-id "$NETWORK_ID" \
  --space-id "$SPACE_ID" >"$ARTIFACT_DIR/official-join.json"
JOIN_ERROR_CODE="$(json_get "$ARTIFACT_DIR/official-join.json" error_code 2>/dev/null || true)"
[[ -z "$JOIN_ERROR_CODE" ]] || fail "SpaceJoin returned error ($JOIN_ERROR_CODE)"

OFFICIAL_SPACE_ID="$(json_get "$ARTIFACT_DIR/official-join.json" space_id)"
if [[ -z "$OFFICIAL_SPACE_ID" ]]; then
  OFFICIAL_SPACE_ID="$SPACE_ID"
fi

sleep 5

printf 'Authoring the bounded delete slice from Manytype...\n'
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

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase59 manytype to official self-hosted delete compatibility" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$ARTIFACT_PATH" \
  "$ARTIFACT_DIR/official-join.json" \
  "$ARTIFACT_DIR/manytype_to_official_predelete-search.json" \
  "$ARTIFACT_DIR/manytype_to_official_delete.txt" \
  "$MANYTYPE_DELETE_CAPTURE" \
  "$ARTIFACT_DIR/manytype_to_official_postdelete-search.json" \
  "$ARTIFACT_DIR/manytype_to_official_restart-search.json"

python3 - \
  "$ARTIFACT_PATH" \
  "$MANYTYPE_OBJECT_ID" \
  "$MANYTYPE_OBJECT_NAME" \
  "$ARTIFACT_DIR/manytype_to_official_predelete-search.json" \
  "$ARTIFACT_DIR/manytype_to_official_delete.txt" \
  "$MANYTYPE_DELETE_CAPTURE" \
  "$ARTIFACT_DIR/manytype_to_official_postdelete-search.json" \
  "$ARTIFACT_DIR/manytype_to_official_restart-search.json" \
  "$PHASE47_BUNDLE" \
  "$RUNTIME_METADATA_PATH" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    object_id,
    object_name,
    presence_search_path,
    delete_output_path,
    delete_sync_capture_path,
    absence_search_path,
    restart_absence_search_path,
    phase47_bundle_path,
    metadata_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase59 manytype to official self-hosted delete compatibility",
    "accepted_slice": {
        "object_family": "page-rooted objects only",
        "mutation_family": "archive-backed object deletion",
        "bounded_object_type": "page",
        "proof_mode": "official-object-search-absence-and-restart-reread",
    },
    "truth_surface": "self-hosted-official",
    "manytype_to_official": {
        "object_id": object_id,
        "object_name": object_name,
        "presence_search_path": presence_search_path,
        "delete_output_path": delete_output_path,
        "delete_sync_capture_path": delete_sync_capture_path,
        "absence_search_path": absence_search_path,
        "restart_absence_search_path": restart_absence_search_path,
    },
    "phase47_bundle_path": phase47_bundle_path,
    "metadata_path": metadata_path,
    "success": True,
}

pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Phase 59 artifact written to %s\n' "$ARTIFACT_PATH"
printf 'phase59 harness: PASSED\n'
