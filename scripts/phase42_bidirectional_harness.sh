#!/usr/bin/env bash

set -euo pipefail

# Phase 42: bidirectional verification against the self-hosted official stack.
#
# Produces replayable artifacts for:
#   - Manytype-authored -> official-observed:
#       blockupdate, status/tag, collection, file relation, template
#   - official-authored -> Manytype-observed:
#       blockupdate, status/tag, collection, file relation, template

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-ghcr.io/anyproto/anytype-cli:latest}"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase42"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
NETWORK_YML="$TMPDIR/network.yml"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
CLI_NAME="phase42-anytype-cli-$$"
CLI_LOG_FILE="$TMPDIR/anytype-cli.log"
OFFICIAL_SPACE_ID=""
SPACE_ID=""

cleanup() {
  if docker ps -a --format '{{.Names}}' | grep -Fxq "$CLI_NAME"; then
    docker logs "$CLI_NAME" >"$CLI_LOG_FILE" 2>&1 || true
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
  HOME="$home" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" "$@"
}

run_probe() {
  local action="$1"
  shift
  "$PROBE_BIN" \
    --config "$OFFICIAL_ROOT/config.json" \
    --grpc-addr 127.0.0.1:31010 \
    --timeout "${PROBE_TIMEOUT:-180s}" \
    --action "$action" \
    "$@"
}

extract_created_id() {
  local file="$1"
  sed -n 's/^Created [^:]*: //p' "$file" | head -1
}

extract_checkbox_block_id() {
  local file="$1"
  sed -n 's/^    \[\([^]]*\)\].*\[Checkbox\].*/\1/p' "$file" | head -1
}

derive_unique_key() {
  python3 - "$1" <<'PY'
import re, sys
name = sys.argv[1].strip().lower()
name = re.sub(r'[^a-z0-9]+', '-', name)
name = re.sub(r'-+', '-', name).strip('-')
print(name)
PY
}

json_get() {
  local file="$1"
  local key="$2"
  python3 - "$file" "$key" <<'PY'
import json, sys
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

wait_for_grpc() {
  for _ in $(seq 1 30); do
    if (echo >/dev/tcp/127.0.0.1/31010) >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

query_spaces() {
  local api_key="$1"
  curl -sf http://127.0.0.1:31012/v1/spaces \
    -H "Anytype-Version: 2025-11-08" \
    -H "Authorization: Bearer $api_key"
}

wait_for_spaces_api() {
  local api_key="$1"
  local output_file="$2"
  for _ in $(seq 1 60); do
    if query_spaces "$api_key" >"$output_file" 2>/dev/null; then
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

  for _ in $(seq 1 60); do
    run_probe object-show --space-id "$OFFICIAL_SPACE_ID" --object-id "$object_id" >"$output_file" || true
    local error_code=""
    if [[ -f "$output_file" ]]; then
      error_code="$(json_get "$output_file" error_code 2>/dev/null || true)"
    fi
    if [[ -z "$error_code" ]]; then
      if python3 - "$output_file" "$expr" <<'PY'
import json, os, sys
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
    sleep 2
  done

  fail "$failure_message"
}

wait_for_manytype_read() {
  local object_id="$1"
  local output_file="$2"
  local expr="$3"
  local failure_message="$4"

  for _ in $(seq 1 60); do
    run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" read --sync "$object_id" >"$output_file" || true
    if python3 - "$output_file" "$expr" <<'PY'
import os, pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
expr = sys.argv[2]
safe = {"len": len}
scope = {"__builtins__": {}, "text": text, "env": os.environ, **safe}
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
  local output_file="$1"
  local expr="$2"
  local failure_message="$3"
  shift 3

  for _ in $(seq 1 60); do
    run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" list "$@" >"$output_file" || true
    if python3 - "$output_file" "$expr" <<'PY'
import os, pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
expr = sys.argv[2]
safe = {"len": len}
scope = {"__builtins__": {}, "text": text, "env": os.environ, **safe}
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

compose_ip() {
  (cd "$ROOT_DIR/docker/any-sync" && docker compose ps -q "$1" | xargs docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
}

printf '=== Phase 42: bidirectional v2.5 verification ===\n\n'

[[ -f "$NETWORK_CONFIG_SRC" ]] || fail "missing network config: $NETWORK_CONFIG_SRC"
[[ -f "$ROOT_DIR/rust/target/release/libmanytype_quic_ffi.so" ]] || \
  fail "missing FFI library: $ROOT_DIR/rust/target/release/libmanytype_quic_ffi.so"

mkdir -p "$ARTIFACT_DIR" "$MANYTYPE_HOME" "$OFFICIAL_ROOT"
cp "$NETWORK_CONFIG_SRC" "$NETWORK_YML"

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

printf 'Building official probe binary...\n'
(cd "$ROOT_DIR/scripts/official_client_grpc_probe" && go build -o "$PROBE_BIN" .)

printf 'Starting official any-sync stack...\n'
(cd "$ROOT_DIR/docker/any-sync" && docker compose up -d >/dev/null)

ADD_HOST_ARGS=(
  --add-host "any-sync-node-1:$(compose_ip any-sync-node-1)"
  --add-host "any-sync-node-2:$(compose_ip any-sync-node-2)"
  --add-host "any-sync-node-3:$(compose_ip any-sync-node-3)"
  --add-host "any-sync-coordinator:$(compose_ip any-sync-coordinator)"
  --add-host "any-sync-filenode:$(compose_ip any-sync-filenode)"
  --add-host "any-sync-consensusnode:$(compose_ip any-sync-consensusnode)"
)

PREFIX="phase42-$(date +%s%N)"
MANYTYPE_FILE_NAME="${PREFIX}-manytype.pdf"
OFFICIAL_FILE_NAME="${PREFIX}-official.pdf"
MANYTYPE_FILE_PATH="$TMPDIR/$MANYTYPE_FILE_NAME"
OFFICIAL_FILE_PATH="$TMPDIR/$OFFICIAL_FILE_NAME"
printf 'manytype-file-%s\n' "$PREFIX" >"$MANYTYPE_FILE_PATH"
printf 'official-file-%s\n' "$PREFIX" >"$OFFICIAL_FILE_PATH"

printf 'Preparing Manytype home...\n'
run_cli "$MANYTYPE_HOME" init >/dev/null
run_cli "$MANYTYPE_HOME" create "${PREFIX}-seed" >"$TMPDIR/manytype-seed-create.txt"
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_CONFIG_SRC" \
  --wait-seconds 10 >/dev/null
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

printf 'Computing invite material...\n'
SPACE_INFO_JSON="$(HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart")"
SPACE_ID="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["space_id"])' <<<"$SPACE_INFO_JSON")"
ACCOUNT_SEED_HEX="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["account_seed_hex"])' <<<"$SPACE_INFO_JSON")"

(cd "$ROOT_DIR/scripts/phase31_invite_gen" && go run . \
  --account-seed-hex "$ACCOUNT_SEED_HEX" \
  --space-id "$SPACE_ID" \
  --space-name "$PREFIX" \
  --creator-name "manytype") >"$INVITE_JSON"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_space_invite_publish.dart" \
  --network-config "$NETWORK_YML" \
  --invite-json "$INVITE_JSON" \
  --permissions writer >"$PUBLISH_JSON"

INVITE_URL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["invite_url"])' "$PUBLISH_JSON")"
NETWORK_ID="$(sed -n 's/^networkId: //p' "$NETWORK_YML" | head -1)"
[[ -n "$INVITE_URL" ]] || fail 'could not parse invite url'
[[ -n "$NETWORK_ID" ]] || fail 'could not parse networkId'

printf 'Starting official anytype-cli service...\n'
docker run -d --name "$CLI_NAME" --network host "${ADD_HOST_ARGS[@]}" \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  -v "$TMPDIR:$TMPDIR" \
  -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" serve --verbose --listen-address 0.0.0.0:31010 >/dev/null

if ! wait_for_grpc; then
  printf 'FAIL: anytype-cli gRPC did not become ready on 127.0.0.1:31010\n' >&2
  docker logs "$CLI_NAME" | tail -200 >&2 || true
  exit 1
fi

printf 'Creating official account...\n'
ACCOUNT_CREATE_OUTPUT="$(docker run --rm --network host "${ADD_HOST_ARGS[@]}" \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase42-bot \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype)"

ACCOUNT_KEY="$(printf '%s\n' "$ACCOUNT_CREATE_OUTPUT" | grep -oE '[A-Za-z0-9+/]{20,}={0,2}' | head -1)"
[[ -n "$ACCOUNT_KEY" ]] || fail 'could not parse official account key'

docker run --rm --entrypoint sh \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json' >/dev/null

API_KEY_OUTPUT="$(docker run --rm --network host "${ADD_HOST_ARGS[@]}" \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" auth apikey create phase42-integration)"
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

printf 'Scenario 1/10: Manytype-authored blockupdate -> official observation...\n'
BLOCK_CHECK_TITLE="$PREFIX manytype block check"
BLOCK_STYLE_TITLE="$PREFIX manytype block style"
BLOCK_STYLE_TEXT="$PREFIX manytype style final"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync --checkbox "$BLOCK_CHECK_TITLE" >"$TMPDIR/manytype-block-check-create.txt"
BLOCK_CHECK_OBJECT_ID="$(extract_created_id "$TMPDIR/manytype-block-check-create.txt")"
run_cli "$MANYTYPE_HOME" read "$BLOCK_CHECK_OBJECT_ID" >"$TMPDIR/manytype-block-check-read.txt"
BLOCK_CHECK_BLOCK_ID="$(extract_checkbox_block_id "$TMPDIR/manytype-block-check-read.txt")"
[[ -n "$BLOCK_CHECK_BLOCK_ID" ]] || fail 'could not parse checkbox block id for blockupdate check scenario'

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" \
  edit --id "$BLOCK_CHECK_OBJECT_ID" --block-id "$BLOCK_CHECK_BLOCK_ID" --set-checked true >/dev/null

BLOCK_ID="$BLOCK_CHECK_BLOCK_ID" \
wait_for_official_show \
  "$BLOCK_CHECK_OBJECT_ID" \
  "$ARTIFACT_DIR/manytype_to_official_blockupdate_checked-show.json" \
  'any(block.get("id") == env["BLOCK_ID"] and block.get("style") == "Checkbox" and block.get("checked") is True for block in data.get("text_blocks", []))' \
  'official client did not observe Manytype-authored checkbox mutation'

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync --checkbox "$BLOCK_STYLE_TITLE" >"$TMPDIR/manytype-block-style-create.txt"
BLOCK_STYLE_OBJECT_ID="$(extract_created_id "$TMPDIR/manytype-block-style-create.txt")"
run_cli "$MANYTYPE_HOME" read "$BLOCK_STYLE_OBJECT_ID" >"$TMPDIR/manytype-block-style-read.txt"
BLOCK_STYLE_BLOCK_ID="$(extract_checkbox_block_id "$TMPDIR/manytype-block-style-read.txt")"
[[ -n "$BLOCK_STYLE_BLOCK_ID" ]] || fail 'could not parse checkbox block id for blockupdate style scenario'

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" \
  edit --id "$BLOCK_STYLE_OBJECT_ID" --block-id "$BLOCK_STYLE_BLOCK_ID" --set-style header2 >/dev/null
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" \
  edit --id "$BLOCK_STYLE_OBJECT_ID" --block-id "$BLOCK_STYLE_BLOCK_ID" --set-text "$BLOCK_STYLE_TEXT" >/dev/null

BLOCK_ID="$BLOCK_STYLE_BLOCK_ID" BLOCK_TEXT="$BLOCK_STYLE_TEXT" \
wait_for_official_show \
  "$BLOCK_STYLE_OBJECT_ID" \
  "$ARTIFACT_DIR/manytype_to_official_blockupdate_style-show.json" \
  'any(block.get("id") == env["BLOCK_ID"] and block.get("style") == "Header2" and block.get("text") == env["BLOCK_TEXT"] for block in data.get("text_blocks", []))' \
  'official client did not observe Manytype-authored style/text mutation'

python3 - "$ARTIFACT_DIR/manytype_to_official_blockupdate.json" \
  "$BLOCK_CHECK_OBJECT_ID" \
  "$BLOCK_CHECK_BLOCK_ID" \
  "$BLOCK_STYLE_OBJECT_ID" \
  "$BLOCK_STYLE_BLOCK_ID" \
  "$BLOCK_STYLE_TEXT" \
  "$ARTIFACT_DIR/manytype_to_official_blockupdate_checked-show.json" \
  "$ARTIFACT_DIR/manytype_to_official_blockupdate_style-show.json" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    check_object_id,
    check_block_id,
    style_object_id,
    style_block_id,
    style_text,
    checked_show_path,
    style_show_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "manytype-authored blockupdate observed by official",
    "checkbox_object_id": check_object_id,
    "checkbox_block_id": check_block_id,
    "checkbox_expected_checked": True,
    "style_object_id": style_object_id,
    "style_block_id": style_block_id,
    "style_expected_style": "Header2",
    "style_expected_text": style_text,
    "checked_show_path": checked_show_path,
    "style_show_path": style_show_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Scenario 2/10: Manytype-authored status/tag -> official observation...\n'
MT_STATUS_NAME="$PREFIX manytype status"
MT_TAG_NAME="$PREFIX manytype tag"
MT_STATUS_KEY="$(derive_unique_key "$MT_STATUS_NAME")"
MT_TAG_KEY="$(derive_unique_key "$MT_TAG_NAME")"
MT_STATUS_OPTION_NAME="$PREFIX manytype done"
MT_TAG_OPTION_A_NAME="$PREFIX manytype alpha"
MT_TAG_OPTION_B_NAME="$PREFIX manytype beta"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --as-relation --name "$MT_STATUS_NAME" --format status >"$TMPDIR/manytype-status-relation.txt"
MT_STATUS_RELATION_ID="$(extract_created_id "$TMPDIR/manytype-status-relation.txt")"
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --as-relation --name "$MT_TAG_NAME" --format tag >"$TMPDIR/manytype-tag-relation.txt"
MT_TAG_RELATION_ID="$(extract_created_id "$TMPDIR/manytype-tag-relation.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --as-relation-option --name "$MT_STATUS_OPTION_NAME" --for-relation "$MT_STATUS_KEY" --color orange >"$TMPDIR/manytype-status-option.txt"
MT_STATUS_OPTION_ID="$(extract_created_id "$TMPDIR/manytype-status-option.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --as-relation-option --name "$MT_TAG_OPTION_A_NAME" --for-relation "$MT_TAG_KEY" --color red >"$TMPDIR/manytype-tag-option-a.txt"
MT_TAG_OPTION_A_ID="$(extract_created_id "$TMPDIR/manytype-tag-option-a.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --as-relation-option --name "$MT_TAG_OPTION_B_NAME" --for-relation "$MT_TAG_KEY" --color blue >"$TMPDIR/manytype-tag-option-b.txt"
MT_TAG_OPTION_B_ID="$(extract_created_id "$TMPDIR/manytype-tag-option-b.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  "$PREFIX manytype status-tag target" >"$TMPDIR/manytype-status-tag-target.txt"
MT_STATUS_TAG_OBJECT_ID="$(extract_created_id "$TMPDIR/manytype-status-tag-target.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" \
  edit --id "$MT_STATUS_TAG_OBJECT_ID" --relation "$MT_STATUS_KEY" --status "$MT_STATUS_OPTION_ID" >/dev/null
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" \
  edit --id "$MT_STATUS_TAG_OBJECT_ID" --relation "$MT_TAG_KEY" --tag "$MT_TAG_OPTION_A_ID,$MT_TAG_OPTION_B_ID" >/dev/null

STATUS_KEY="$MT_STATUS_KEY" STATUS_OPTION_ID="$MT_STATUS_OPTION_ID" TAG_KEY="$MT_TAG_KEY" TAG_OPTION_A="$MT_TAG_OPTION_A_ID" TAG_OPTION_B="$MT_TAG_OPTION_B_ID" \
wait_for_official_show \
  "$MT_STATUS_TAG_OBJECT_ID" \
  "$ARTIFACT_DIR/manytype_to_official_status_tag_target-show.json" \
  'data.get("root_details", {}).get(env["STATUS_KEY"]) == env["STATUS_OPTION_ID"] and sorted(data.get("root_details", {}).get(env["TAG_KEY"], [])) == sorted([env["TAG_OPTION_A"], env["TAG_OPTION_B"]])' \
  'official client did not observe Manytype-authored status/tag detail values'

EXPECTED_NAME="$MT_STATUS_OPTION_NAME" EXPECTED_COLOR="orange" \
wait_for_official_show \
  "$MT_STATUS_OPTION_ID" \
  "$ARTIFACT_DIR/manytype_to_official_status_tag_status-option-show.json" \
  'data.get("root_details", {}).get("name") == env["EXPECTED_NAME"] and data.get("root_details", {}).get("color") == env["EXPECTED_COLOR"]' \
  'official client did not observe Manytype-authored status option object'

EXPECTED_NAME="$MT_TAG_OPTION_A_NAME" EXPECTED_COLOR="red" \
wait_for_official_show \
  "$MT_TAG_OPTION_A_ID" \
  "$ARTIFACT_DIR/manytype_to_official_status_tag_tag-option-a-show.json" \
  'data.get("root_details", {}).get("name") == env["EXPECTED_NAME"] and data.get("root_details", {}).get("color") == env["EXPECTED_COLOR"]' \
  'official client did not observe Manytype-authored tag option A object'

EXPECTED_NAME="$MT_TAG_OPTION_B_NAME" EXPECTED_COLOR="blue" \
wait_for_official_show \
  "$MT_TAG_OPTION_B_ID" \
  "$ARTIFACT_DIR/manytype_to_official_status_tag_tag-option-b-show.json" \
  'data.get("root_details", {}).get("name") == env["EXPECTED_NAME"] and data.get("root_details", {}).get("color") == env["EXPECTED_COLOR"]' \
  'official client did not observe Manytype-authored tag option B object'

python3 - "$ARTIFACT_DIR/manytype_to_official_status_tag.json" \
  "$MT_STATUS_RELATION_ID" \
  "$MT_STATUS_KEY" \
  "$MT_STATUS_OPTION_ID" \
  "$MT_TAG_RELATION_ID" \
  "$MT_TAG_KEY" \
  "$MT_TAG_OPTION_A_ID" \
  "$MT_TAG_OPTION_B_ID" \
  "$MT_STATUS_TAG_OBJECT_ID" \
  "$ARTIFACT_DIR/manytype_to_official_status_tag_target-show.json" \
  "$ARTIFACT_DIR/manytype_to_official_status_tag_status-option-show.json" \
  "$ARTIFACT_DIR/manytype_to_official_status_tag_tag-option-a-show.json" \
  "$ARTIFACT_DIR/manytype_to_official_status_tag_tag-option-b-show.json" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    status_relation_id,
    status_key,
    status_option_id,
    tag_relation_id,
    tag_key,
    tag_option_a_id,
    tag_option_b_id,
    object_id,
    target_show_path,
    status_option_show_path,
    tag_option_a_show_path,
    tag_option_b_show_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "manytype-authored status/tag observed by official",
    "status_relation_id": status_relation_id,
    "status_key": status_key,
    "status_option_id": status_option_id,
    "tag_relation_id": tag_relation_id,
    "tag_key": tag_key,
    "tag_option_ids": [tag_option_a_id, tag_option_b_id],
    "object_id": object_id,
    "target_show_path": target_show_path,
    "status_option_show_path": status_option_show_path,
    "tag_option_a_show_path": tag_option_a_show_path,
    "tag_option_b_show_path": tag_option_b_show_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Scenario 3/10: Manytype-authored collection -> official observation...\n'
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --as-collection --name "$PREFIX manytype collection" >"$TMPDIR/manytype-collection-create.txt"
MT_COLLECTION_ID="$(extract_created_id "$TMPDIR/manytype-collection-create.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  "$PREFIX member a" >"$TMPDIR/manytype-member-a.txt"
MT_MEMBER_A_ID="$(extract_created_id "$TMPDIR/manytype-member-a.txt")"
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  "$PREFIX member b" >"$TMPDIR/manytype-member-b.txt"
MT_MEMBER_B_ID="$(extract_created_id "$TMPDIR/manytype-member-b.txt")"
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  "$PREFIX member c" >"$TMPDIR/manytype-member-c.txt"
MT_MEMBER_C_ID="$(extract_created_id "$TMPDIR/manytype-member-c.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" edit --id "$MT_COLLECTION_ID" --collection-add "$MT_MEMBER_A_ID" >/dev/null
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" edit --id "$MT_COLLECTION_ID" --collection-add "$MT_MEMBER_B_ID" >/dev/null
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" edit --id "$MT_COLLECTION_ID" --collection-add "$MT_MEMBER_C_ID" >/dev/null
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" edit --id "$MT_COLLECTION_ID" --collection-move "$MT_MEMBER_C_ID" --after "" >/dev/null
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" edit --id "$MT_COLLECTION_ID" --collection-remove "$MT_MEMBER_A_ID" >/dev/null

MEMBER_B="$MT_MEMBER_B_ID" MEMBER_C="$MT_MEMBER_C_ID" \
wait_for_official_show \
  "$MT_COLLECTION_ID" \
  "$ARTIFACT_DIR/manytype_to_official_collection-show.json" \
  'any(order.get("object_ids") == [env["MEMBER_C"], env["MEMBER_B"]] for dataview in data.get("dataviews", []) for order in dataview.get("object_orders", [])) or [link for link in data.get("root_details", {}).get("links", []) if link in {env["MEMBER_B"], env["MEMBER_C"]}] == [env["MEMBER_C"], env["MEMBER_B"]]' \
  'official client did not observe Manytype-authored collection membership/order'

python3 - "$ARTIFACT_DIR/manytype_to_official_collection.json" \
  "$MT_COLLECTION_ID" \
  "$MT_MEMBER_A_ID" \
  "$MT_MEMBER_B_ID" \
  "$MT_MEMBER_C_ID" \
  "$ARTIFACT_DIR/manytype_to_official_collection-show.json" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path, collection_id, member_a, member_b, member_c, show_path = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "manytype-authored collection observed by official",
    "collection_id": collection_id,
    "member_ids_created": [member_a, member_b, member_c],
    "expected_member_ids": [member_c, member_b],
    "show_path": show_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Scenario 4/10: Manytype-authored file relation -> official observation...\n'
MT_FILE_RELATION_NAME="$PREFIX manytype attachment"
MT_FILE_RELATION_KEY="$(derive_unique_key "$MT_FILE_RELATION_NAME")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --as-relation --name "$MT_FILE_RELATION_NAME" --format file >"$TMPDIR/manytype-file-relation.txt"
MT_FILE_RELATION_ID="$(extract_created_id "$TMPDIR/manytype-file-relation.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  "$PREFIX manytype file target" >"$TMPDIR/manytype-file-target.txt"
MT_FILE_TARGET_ID="$(extract_created_id "$TMPDIR/manytype-file-target.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" \
  edit --id "$MT_FILE_TARGET_ID" --relation "$MT_FILE_RELATION_KEY" --file-relation "$MANYTYPE_FILE_PATH" >"$TMPDIR/manytype-file-edit.txt"
MT_FILE_OBJECT_ID="$(sed -n 's/^FileObject: \([^ ]*\) .*/\1/p' "$TMPDIR/manytype-file-edit.txt" | head -1)"
[[ -n "$MT_FILE_OBJECT_ID" ]] || fail 'could not parse Manytype file object id'

RELATION_KEY="$MT_FILE_RELATION_KEY" FILE_OBJECT_ID="$MT_FILE_OBJECT_ID" \
wait_for_official_show \
  "$MT_FILE_TARGET_ID" \
  "$ARTIFACT_DIR/manytype_to_official_file_relation_target-show.json" \
  'data.get("root_details", {}).get(env["RELATION_KEY"]) == env["FILE_OBJECT_ID"]' \
  'official client did not observe Manytype-authored file relation target detail'

PAYLOAD_NAME="$MANYTYPE_FILE_NAME" \
wait_for_official_show \
  "$MT_FILE_OBJECT_ID" \
  "$ARTIFACT_DIR/manytype_to_official_file_relation_file-show.json" \
  'data.get("root_details", {}).get("name") == env["PAYLOAD_NAME"] or any(block.get("name") == env["PAYLOAD_NAME"] or (block.get("type") == "File" and block.get("state") == "Done" and block.get("target_object_id")) for block in data.get("file_blocks", []))' \
  'official client did not observe Manytype-authored FileObject metadata'

python3 - "$ARTIFACT_DIR/manytype_to_official_file_relation.json" \
  "$MT_FILE_RELATION_ID" \
  "$MT_FILE_RELATION_KEY" \
  "$MT_FILE_TARGET_ID" \
  "$MT_FILE_OBJECT_ID" \
  "$MANYTYPE_FILE_NAME" \
  "$ARTIFACT_DIR/manytype_to_official_file_relation_target-show.json" \
  "$ARTIFACT_DIR/manytype_to_official_file_relation_file-show.json" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    relation_id,
    relation_key,
    target_id,
    file_object_id,
    payload_name,
    target_show_path,
    file_show_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "manytype-authored file relation observed by official",
    "relation_id": relation_id,
    "relation_key": relation_key,
    "target_id": target_id,
    "file_object_id": file_object_id,
    "payload_name": payload_name,
    "target_show_path": target_show_path,
    "file_show_path": file_show_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Scenario 5/10: Manytype-authored template -> official observation + local list filter...\n'
MT_TYPE_NAME="$PREFIX manytype template type"
MT_TEMPLATE_NAME="$PREFIX manytype template"
MT_APPLIED_NAME="$PREFIX manytype applied"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --as-type --name "$MT_TYPE_NAME" >"$TMPDIR/manytype-template-type.txt"
MT_TYPE_ID="$(extract_created_id "$TMPDIR/manytype-template-type.txt")"
MT_TYPE_KEY="$(derive_unique_key "$MT_TYPE_NAME")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --as-template --name "$MT_TEMPLATE_NAME" --target-object-type "$MT_TYPE_ID" --checkbox "$PREFIX template item" >"$TMPDIR/manytype-template-create.txt"
MT_TEMPLATE_ID="$(extract_created_id "$TMPDIR/manytype-template-create.txt")"

run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG_SRC" create --sync \
  --template "$MT_TEMPLATE_ID" "$MT_APPLIED_NAME" >"$TMPDIR/manytype-template-apply.txt"
MT_APPLIED_ID="$(extract_created_id "$TMPDIR/manytype-template-apply.txt")"

TYPE_ID="$MT_TYPE_ID" \
wait_for_official_show \
  "$MT_TEMPLATE_ID" \
  "$ARTIFACT_DIR/manytype_to_official_template_template-show.json" \
  'data.get("smart_block_type") == "Template" and data.get("root_details", {}).get("targetObjectType") == env["TYPE_ID"]' \
  'official client did not observe Manytype-authored template object'

TEMPLATE_ID="$MT_TEMPLATE_ID" APPLIED_TITLE="$MT_APPLIED_NAME" TEMPLATE_ITEM="$PREFIX template item" \
wait_for_official_show \
  "$MT_APPLIED_ID" \
  "$ARTIFACT_DIR/manytype_to_official_template_applied-show.json" \
  'data.get("root_details", {}).get("sourceObject") == env["TEMPLATE_ID"] and any(block.get("text") == env["APPLIED_TITLE"] for block in data.get("text_blocks", [])) and any(block.get("style") == "Checkbox" and block.get("text") == env["TEMPLATE_ITEM"] for block in data.get("text_blocks", []))' \
  'official client did not observe Manytype-authored template clone'

TEMPLATE_NAME="$MT_TEMPLATE_NAME" TEMPLATE_ID="$MT_TEMPLATE_ID" \
wait_for_manytype_list \
  "$ARTIFACT_DIR/manytype_to_official_template_list.txt" \
  'env["TEMPLATE_NAME"] in text and env["TEMPLATE_ID"] in text' \
  'manytype list did not surface the template under target-object-type filtering' \
  --type ot-template --where "targetObjectType=$MT_TYPE_ID"

python3 - "$ARTIFACT_DIR/manytype_to_official_template.json" \
  "$MT_TYPE_ID" \
  "$MT_TYPE_KEY" \
  "$MT_TEMPLATE_ID" \
  "$MT_APPLIED_ID" \
  "$MT_TEMPLATE_NAME" \
  "$ARTIFACT_DIR/manytype_to_official_template_template-show.json" \
  "$ARTIFACT_DIR/manytype_to_official_template_applied-show.json" \
  "$ARTIFACT_DIR/manytype_to_official_template_list.txt" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    type_id,
    type_key,
    template_id,
    applied_id,
    template_name,
    template_show_path,
    applied_show_path,
    list_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "manytype-authored template observed by official and list-filtered locally",
    "type_id": type_id,
    "type_key": type_key,
    "template_id": template_id,
    "applied_id": applied_id,
    "template_name": template_name,
    "template_show_path": template_show_path,
    "applied_show_path": applied_show_path,
    "list_path": list_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Scenario 6/10: official-authored blockupdate -> Manytype observation...\n'
run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official block seed" >"$TMPDIR/official-block-create.json"
OFFICIAL_BLOCK_OBJECT_ID="$(json_get "$TMPDIR/official-block-create.json" object_id)"
[[ -n "$OFFICIAL_BLOCK_OBJECT_ID" ]] || fail 'could not parse official blockupdate object id'

OFFICIAL_BLOCK_UPDATED_TEXT="$PREFIX official block updated"
run_probe object-edit-text --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_BLOCK_OBJECT_ID" --text "$OFFICIAL_BLOCK_UPDATED_TEXT" >"$ARTIFACT_DIR/official_to_manytype_blockupdate_edit.json"
BLOCK_EDIT_ERR="$(json_get "$ARTIFACT_DIR/official_to_manytype_blockupdate_edit.json" error_code 2>/dev/null || true)"
[[ -z "$BLOCK_EDIT_ERR" ]] || fail "official blockupdate returned error ($BLOCK_EDIT_ERR)"

UPDATED_TEXT="$OFFICIAL_BLOCK_UPDATED_TEXT" \
wait_for_manytype_read \
  "$OFFICIAL_BLOCK_OBJECT_ID" \
  "$ARTIFACT_DIR/official_to_manytype_blockupdate_read.txt" \
  'env["UPDATED_TEXT"] in text' \
  'Manytype did not observe official-authored text block mutation'

python3 - "$ARTIFACT_DIR/official_to_manytype_blockupdate.json" \
  "$OFFICIAL_BLOCK_OBJECT_ID" \
  "$OFFICIAL_BLOCK_UPDATED_TEXT" \
  "$ARTIFACT_DIR/official_to_manytype_blockupdate_edit.json" \
  "$ARTIFACT_DIR/official_to_manytype_blockupdate_read.txt" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path, object_id, updated_text, edit_path, read_path = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "official-authored blockupdate observed by Manytype",
    "object_id": object_id,
    "updated_text": updated_text,
    "edit_path": edit_path,
    "read_path": read_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Scenario 7/10: official-authored status/tag -> Manytype observation...\n'
run_probe object-create-relation --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official status" --format status >"$TMPDIR/official-status-relation.json"
OFFICIAL_STATUS_RELATION_ID="$(json_get "$TMPDIR/official-status-relation.json" object_id)"
OFFICIAL_STATUS_KEY="$(json_get "$TMPDIR/official-status-relation.json" relation_key)"
run_probe object-create-relation --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official tag" --format tag >"$TMPDIR/official-tag-relation.json"
OFFICIAL_TAG_RELATION_ID="$(json_get "$TMPDIR/official-tag-relation.json" object_id)"
OFFICIAL_TAG_KEY="$(json_get "$TMPDIR/official-tag-relation.json" relation_key)"

run_probe object-create-relation-option --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official done" --relation-key "$OFFICIAL_STATUS_KEY" --color orange >"$TMPDIR/official-status-option.json"
OFFICIAL_STATUS_OPTION_ID="$(json_get "$TMPDIR/official-status-option.json" object_id)"
run_probe object-create-relation-option --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official alpha" --relation-key "$OFFICIAL_TAG_KEY" --color red >"$TMPDIR/official-tag-option-a.json"
OFFICIAL_TAG_OPTION_A_ID="$(json_get "$TMPDIR/official-tag-option-a.json" object_id)"
run_probe object-create-relation-option --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official beta" --relation-key "$OFFICIAL_TAG_KEY" --color blue >"$TMPDIR/official-tag-option-b.json"
OFFICIAL_TAG_OPTION_B_ID="$(json_get "$TMPDIR/official-tag-option-b.json" object_id)"

run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official status-tag target" >"$TMPDIR/official-status-tag-target.json"
OFFICIAL_STATUS_TAG_OBJECT_ID="$(json_get "$TMPDIR/official-status-tag-target.json" object_id)"

run_probe object-add-relation --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_STATUS_TAG_OBJECT_ID" --relation-keys "$OFFICIAL_STATUS_KEY,$OFFICIAL_TAG_KEY" >"$TMPDIR/official-status-tag-add-relation.json"
run_probe object-set-detail --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_STATUS_TAG_OBJECT_ID" --detail-key "$OFFICIAL_STATUS_KEY" --detail-kind string --detail-value "$OFFICIAL_STATUS_OPTION_ID" >"$TMPDIR/official-status-set.json"
run_probe object-set-detail --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_STATUS_TAG_OBJECT_ID" --detail-key "$OFFICIAL_TAG_KEY" --detail-kind string-list --detail-values "$OFFICIAL_TAG_OPTION_A_ID,$OFFICIAL_TAG_OPTION_B_ID" >"$TMPDIR/official-tag-set.json"

STATUS_LINE="[$OFFICIAL_STATUS_KEY] $PREFIX official done (orange)" TAG_LINE="[$OFFICIAL_TAG_KEY] $PREFIX official alpha, $PREFIX official beta" \
wait_for_manytype_read \
  "$OFFICIAL_STATUS_TAG_OBJECT_ID" \
  "$ARTIFACT_DIR/official_to_manytype_status_tag_read.txt" \
  'env["STATUS_LINE"] in text and env["TAG_LINE"] in text' \
  'Manytype did not resolve official-authored status/tag values'

python3 - "$ARTIFACT_DIR/official_to_manytype_status_tag.json" \
  "$OFFICIAL_STATUS_RELATION_ID" \
  "$OFFICIAL_STATUS_KEY" \
  "$OFFICIAL_STATUS_OPTION_ID" \
  "$OFFICIAL_TAG_RELATION_ID" \
  "$OFFICIAL_TAG_KEY" \
  "$OFFICIAL_TAG_OPTION_A_ID" \
  "$OFFICIAL_TAG_OPTION_B_ID" \
  "$OFFICIAL_STATUS_TAG_OBJECT_ID" \
  "$ARTIFACT_DIR/official_to_manytype_status_tag_read.txt" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    status_relation_id,
    status_key,
    status_option_id,
    tag_relation_id,
    tag_key,
    tag_option_a_id,
    tag_option_b_id,
    object_id,
    read_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "official-authored status/tag observed by Manytype",
    "status_relation_id": status_relation_id,
    "status_key": status_key,
    "status_option_id": status_option_id,
    "tag_relation_id": tag_relation_id,
    "tag_key": tag_key,
    "tag_option_ids": [tag_option_a_id, tag_option_b_id],
    "object_id": object_id,
    "read_path": read_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Scenario 8/10: official-authored collection -> Manytype observation...\n'
run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official collection" >"$TMPDIR/official-collection-base.json"
OFFICIAL_COLLECTION_ID="$(json_get "$TMPDIR/official-collection-base.json" object_id)"
run_probe object-to-collection --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_COLLECTION_ID" >"$TMPDIR/official-collection-convert.json"

run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official member a" >"$TMPDIR/official-member-a.json"
OFFICIAL_MEMBER_A_ID="$(json_get "$TMPDIR/official-member-a.json" object_id)"
run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official member b" >"$TMPDIR/official-member-b.json"
OFFICIAL_MEMBER_B_ID="$(json_get "$TMPDIR/official-member-b.json" object_id)"
run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official member c" >"$TMPDIR/official-member-c.json"
OFFICIAL_MEMBER_C_ID="$(json_get "$TMPDIR/official-member-c.json" object_id)"

run_probe object-collection-add --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_COLLECTION_ID" --ids "$OFFICIAL_MEMBER_A_ID,$OFFICIAL_MEMBER_B_ID,$OFFICIAL_MEMBER_C_ID" >"$TMPDIR/official-collection-add.json"
run_probe object-collection-sort --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_COLLECTION_ID" --ids "$OFFICIAL_MEMBER_C_ID,$OFFICIAL_MEMBER_B_ID,$OFFICIAL_MEMBER_A_ID" >"$TMPDIR/official-collection-sort.json"
run_probe object-collection-remove --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_COLLECTION_ID" --ids "$OFFICIAL_MEMBER_A_ID" >"$TMPDIR/official-collection-remove.json"

MEMBER_C_LINE="- $PREFIX official member c ($OFFICIAL_MEMBER_C_ID)" MEMBER_B_LINE="- $PREFIX official member b ($OFFICIAL_MEMBER_B_ID)" REMOVED_MEMBER_LINE="- $PREFIX official member a ($OFFICIAL_MEMBER_A_ID)" \
wait_for_manytype_read \
  "$OFFICIAL_COLLECTION_ID" \
  "$ARTIFACT_DIR/official_to_manytype_collection_read.txt" \
  '"## Members\n" in text and env["MEMBER_C_LINE"] in text.split("## Members\n", 1)[1] and env["MEMBER_B_LINE"] in text.split("## Members\n", 1)[1] and text.split("## Members\n", 1)[1].index(env["MEMBER_C_LINE"]) < text.split("## Members\n", 1)[1].index(env["MEMBER_B_LINE"]) and env["REMOVED_MEMBER_LINE"] not in text.split("## Members\n", 1)[1]' \
  'Manytype did not observe official-authored collection membership/order'

python3 - "$ARTIFACT_DIR/official_to_manytype_collection.json" \
  "$OFFICIAL_COLLECTION_ID" \
  "$OFFICIAL_MEMBER_A_ID" \
  "$OFFICIAL_MEMBER_B_ID" \
  "$OFFICIAL_MEMBER_C_ID" \
  "$ARTIFACT_DIR/official_to_manytype_collection_read.txt" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path, collection_id, member_a, member_b, member_c, read_path = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "official-authored collection observed by Manytype",
    "collection_id": collection_id,
    "member_ids_created": [member_a, member_b, member_c],
    "expected_member_ids": [member_c, member_b],
    "read_path": read_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Scenario 9/10: official-authored file relation -> Manytype observation...\n'
run_probe object-create-relation --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official attachment" --format file >"$TMPDIR/official-file-relation.json"
OFFICIAL_FILE_RELATION_ID="$(json_get "$TMPDIR/official-file-relation.json" object_id)"
OFFICIAL_FILE_RELATION_KEY="$(json_get "$TMPDIR/official-file-relation.json" relation_key)"

run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official file target" >"$TMPDIR/official-file-target.json"
OFFICIAL_FILE_TARGET_ID="$(json_get "$TMPDIR/official-file-target.json" object_id)"
run_probe object-add-relation --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_FILE_TARGET_ID" --relation-keys "$OFFICIAL_FILE_RELATION_KEY" >"$TMPDIR/official-file-add-relation.json"
run_probe upload --space-id "$OFFICIAL_SPACE_ID" --file "$OFFICIAL_FILE_PATH" >"$TMPDIR/official-file-upload.json"
OFFICIAL_FILE_OBJECT_ID="$(json_get "$TMPDIR/official-file-upload.json" object_id)"
[[ -n "$OFFICIAL_FILE_OBJECT_ID" ]] || fail 'could not parse official file object id'

run_probe object-set-detail --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_FILE_TARGET_ID" --detail-key "$OFFICIAL_FILE_RELATION_KEY" --detail-kind string --detail-value "$OFFICIAL_FILE_OBJECT_ID" >"$TMPDIR/official-file-set-detail.json"

FILE_LINE="[$OFFICIAL_FILE_RELATION_KEY] $OFFICIAL_FILE_NAME" FILE_STEM_LINE="[$OFFICIAL_FILE_RELATION_KEY] ${OFFICIAL_FILE_NAME%.*}" \
wait_for_manytype_read \
  "$OFFICIAL_FILE_TARGET_ID" \
  "$ARTIFACT_DIR/official_to_manytype_file_relation_read.txt" \
  'env["FILE_LINE"] in text or env["FILE_STEM_LINE"] in text' \
  'Manytype did not resolve official-authored file relation'

python3 - "$ARTIFACT_DIR/official_to_manytype_file_relation.json" \
  "$OFFICIAL_FILE_RELATION_ID" \
  "$OFFICIAL_FILE_RELATION_KEY" \
  "$OFFICIAL_FILE_TARGET_ID" \
  "$OFFICIAL_FILE_OBJECT_ID" \
  "$OFFICIAL_FILE_NAME" \
  "$ARTIFACT_DIR/official_to_manytype_file_relation_read.txt" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    relation_id,
    relation_key,
    target_id,
    file_object_id,
    file_name,
    read_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "official-authored file relation observed by Manytype",
    "relation_id": relation_id,
    "relation_key": relation_key,
    "target_id": target_id,
    "file_object_id": file_object_id,
    "file_name": file_name,
    "read_path": read_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf 'Scenario 10/10: official-authored template -> Manytype observation...\n'
run_probe object-create-type --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official type" >"$TMPDIR/official-type.json"
OFFICIAL_TYPE_ID="$(json_get "$TMPDIR/official-type.json" object_id)"
OFFICIAL_TYPE_KEY="$(json_get "$TMPDIR/official-type.json" unique_key)"
[[ -n "$OFFICIAL_TYPE_KEY" ]] || fail 'could not parse official type unique key'

run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official template seed" >"$TMPDIR/official-template-seed.json"
OFFICIAL_TEMPLATE_SOURCE_ID="$(json_get "$TMPDIR/official-template-seed.json" object_id)"
run_probe object-set-object-type --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_TEMPLATE_SOURCE_ID" --object-type-key "$OFFICIAL_TYPE_KEY" >"$TMPDIR/official-template-set-type.json"
run_probe template-create-from-object --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_TEMPLATE_SOURCE_ID" >"$TMPDIR/official-template-create.json"
OFFICIAL_TEMPLATE_ID="$(json_get "$TMPDIR/official-template-create.json" template_id)"
run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$PREFIX official template target" >"$TMPDIR/official-template-applied.json"
OFFICIAL_TEMPLATE_APPLIED_ID="$(json_get "$TMPDIR/official-template-applied.json" object_id)"
run_probe object-set-object-type --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_TEMPLATE_APPLIED_ID" --object-type-key "$OFFICIAL_TYPE_KEY" >"$TMPDIR/official-template-applied-set-type.json"
run_probe object-apply-template --space-id "$OFFICIAL_SPACE_ID" --object-id "$OFFICIAL_TEMPLATE_APPLIED_ID" --template-id "$OFFICIAL_TEMPLATE_ID" >"$TMPDIR/official-template-apply.json"

TYPE_ID="$OFFICIAL_TYPE_ID" \
wait_for_manytype_read \
  "$OFFICIAL_TEMPLATE_ID" \
  "$ARTIFACT_DIR/official_to_manytype_template_template-read.txt" \
  '("Kind: [Template]" in text) and ("Target Type:" in text) and (env["TYPE_ID"] in text)' \
  'Manytype did not recognize official-authored template metadata'

TEMPLATE_ID="$OFFICIAL_TEMPLATE_ID" \
wait_for_manytype_read \
  "$OFFICIAL_TEMPLATE_APPLIED_ID" \
  "$ARTIFACT_DIR/official_to_manytype_template_applied-read.txt" \
  '("Source Template: " + env["TEMPLATE_ID"] in text) or ("sourceObject (object): " + env["TEMPLATE_ID"] in text)' \
  'Manytype did not recognize official-authored template application metadata'

python3 - "$ARTIFACT_DIR/official_to_manytype_template.json" \
  "$OFFICIAL_TYPE_ID" \
  "$OFFICIAL_TYPE_KEY" \
  "$OFFICIAL_TEMPLATE_ID" \
  "$OFFICIAL_TEMPLATE_APPLIED_ID" \
  "$ARTIFACT_DIR/official_to_manytype_template_template-read.txt" \
  "$ARTIFACT_DIR/official_to_manytype_template_applied-read.txt" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    type_id,
    type_key,
    template_id,
    applied_id,
    template_read_path,
    applied_read_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "official-authored template observed by Manytype",
    "type_id": type_id,
    "type_key": type_key,
    "template_id": template_id,
    "applied_id": applied_id,
    "template_read_path": template_read_path,
    "applied_read_path": applied_read_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

printf '\nArtifacts written under %s\n' "$ARTIFACT_DIR"
printf 'phase42 harness: PASSED\n'
