#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase56"
ARTIFACT_PATH="$ARTIFACT_DIR/manytype-server-compatibility.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
MAIN_SYNC_CAPTURE="$ARTIFACT_DIR/official_to_manytype_main-sync.json"
REOPEN_SYNC_CAPTURE="$ARTIFACT_DIR/official_to_manytype_reopen-sync.json"
MAIN_READ_PATH="$ARTIFACT_DIR/official_to_manytype_read.txt"
REOPEN_READ_PATH="$ARTIFACT_DIR/official_to_manytype_reopen-read.txt"
OFFICIAL_SHOW_PATH="$ARTIFACT_DIR/official_to_manytype_show.json"
DIAGNOSTICS_JSON_PATH="$ARTIFACT_DIR/official_to_manytype_diagnostics.json"
DIAGNOSTICS_TEXT_PATH="$ARTIFACT_DIR/official_to_manytype_diagnostics.txt"
TMPDIR="$(mktemp -d)"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
SERVER_CONFIG="$TMPDIR/manytype-server.toml"
SERVER_LOG="$TMPDIR/server.log"
NETWORK_YML="$TMPDIR/network.yml"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
MANYTYPE_HOME="$TMPDIR/manytype-home"
MANYTYPE_REOPEN_HOME="$TMPDIR/manytype-home-reopen"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
CLI_NAME="phase56-anytype-cli-$$"
LOCAL_SERVER_PORT=33158
LOCAL_SERVER_PID=""
OBJECT_ID=""
SPACE_ID=""

cleanup() {
  docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
  if [[ -n "$LOCAL_SERVER_PID" ]]; then
    kill "$LOCAL_SERVER_PID" >/dev/null 2>&1 || true
    wait "$LOCAL_SERVER_PID" >/dev/null 2>&1 || true
  fi
  if [[ "${KEEP_TMPDIR:-0}" != "1" ]]; then
    rm -rf "$TMPDIR" >/dev/null 2>&1 || true
  else
    printf 'Kept tempdir: %s\n' "$TMPDIR"
  fi
}
trap cleanup EXIT

fail() {
  write_diagnostics || true
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

write_diagnostics() {
  if [[ -z "$OBJECT_ID" || ! -f "$SERVER_LOG" ]]; then
    return 0
  fi
  python3 "$ROOT_DIR/scripts/trace_manytype_server_object.py" \
    --tempdir "$TMPDIR" \
    --object-id "$OBJECT_ID" \
    --json >"$DIAGNOSTICS_JSON_PATH" || true
  python3 "$ROOT_DIR/scripts/trace_manytype_server_object.py" \
    --tempdir "$TMPDIR" \
    --object-id "$OBJECT_ID" >"$DIAGNOSTICS_TEXT_PATH" || true
}

wait_for_server_ready() {
  local attempts="${1:-30}"
  local delay="${2:-1}"
  local i
  for i in $(seq 1 "$attempts"); do
    if [[ -n "$LOCAL_SERVER_PID" ]] && ! kill -0 "$LOCAL_SERVER_PID" >/dev/null 2>&1; then
      return 1
    fi
    if [[ -f "$SERVER_LOG" ]] && rg -q 'Listening on QUIC' "$SERVER_LOG" && rg -q 'Server peer ID:' "$SERVER_LOG"; then
      return 0
    fi
    sleep "$delay"
  done
  return 1
}

wait_for_manytype_read() {
  local home="$1"
  local capture_path="$2"
  local output_path="$3"
  local attempts_var_name="$4"
  local i
  for i in $(seq 1 20); do
    MANYTYPE_SYNC_CAPTURE_PATH="$capture_path" \
      HOME="$home" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
      --server "127.0.0.1:${LOCAL_SERVER_PORT}" \
      --network-config "$NETWORK_YML" \
      read --sync "$OBJECT_ID" >"$output_path" || true
    if rg -q '\[description\] phase56 detail description' "$output_path" &&
      rg -q '\[featuredRelations\] description, sourceObject' "$output_path"; then
      printf -v "$attempts_var_name" '%s' "$i"
      return 0
    fi
    sleep 2
  done
  return 1
}

printf '=== Phase 56: official -> Manytype compatibility ===\n\n'

mkdir -p "$ARTIFACT_DIR" "$MANYTYPE_HOME" "$MANYTYPE_REOPEN_HOME/.manytype" "$OFFICIAL_ROOT"
rm -f "$ARTIFACT_DIR"/*.json "$ARTIFACT_DIR"/*.txt

oracle_run_preflight
oracle_export_runtime_env

printf 'Building binaries...\n'
(cd "$ROOT_DIR/rust" && cargo build -p manytype_quic_ffi --release >/dev/null)
(cd "$ROOT_DIR/rust" && cargo build -p manytype_server >/dev/null)
oracle_build_probe_binary "$PROBE_BIN"

cat >"$SERVER_CONFIG" <<EOF
deployment_mode = "development"
quic_listen = "127.0.0.1:${LOCAL_SERVER_PORT}"
db_path = "${TMPDIR}/manytype-server.redb"
identity_seed = "0404040404040404040404040404040404040404040404040404040404040404"
network_id = "manytype-phase56"
EOF

printf 'Starting local manytype_server...\n'
"$ROOT_DIR/rust/target/debug/manytype_server" "$SERVER_CONFIG" >"$SERVER_LOG" 2>&1 &
LOCAL_SERVER_PID="$!"
if ! wait_for_server_ready 45 1; then
  fail 'local manytype_server did not become ready'
fi

PEER_ID="$(sed -n 's/.*Server peer ID: //p' "$SERVER_LOG" | tail -1)"
[[ -n "$PEER_ID" ]] || fail 'could not parse local server peer ID'

cat >"$NETWORK_YML" <<EOF
id: local-phase56
networkId: manytype-phase56
nodes:
  - peerId: $PEER_ID
    addresses:
      - quic://127.0.0.1:${LOCAL_SERVER_PORT}
      - 127.0.0.1:${LOCAL_SERVER_PORT}
    types:
      - coordinator
      - tree
      - file
      - consensus
EOF

printf 'Preparing Manytype home and live space...\n'
oracle_run_cli "$MANYTYPE_HOME" init >/dev/null
oracle_run_cli "$MANYTYPE_HOME" --server "127.0.0.1:${LOCAL_SERVER_PORT}" create phase56-seed >"$TMPDIR/seed.txt"
SEED_OBJECT_ID="$(sed -n 's/^Created object: //p' "$TMPDIR/seed.txt" | head -1)"
[[ -n "$SEED_OBJECT_ID" ]] || fail 'could not parse seed object id'

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_YML" \
  --wait-seconds 2 >/dev/null
oracle_run_cli "$MANYTYPE_HOME" --server "127.0.0.1:${LOCAL_SERVER_PORT}" --network-config "$NETWORK_YML" sync >/dev/null
cp "$MANYTYPE_HOME/.manytype/config.toml" "$MANYTYPE_REOPEN_HOME/.manytype/config.toml"

SPACE_INFO_JSON="$(HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart")"
SPACE_ID="$(printf '%s' "$SPACE_INFO_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["space_id"])')"
ACCOUNT_SEED_HEX="$(printf '%s' "$SPACE_INFO_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["account_seed_hex"])')"
[[ -n "$SPACE_ID" ]] || fail 'could not parse space id'
[[ -n "$ACCOUNT_SEED_HEX" ]] || fail 'could not parse account seed'

(cd "$ROOT_DIR/scripts/phase31_invite_gen" && go run . \
  --account-seed-hex "$ACCOUNT_SEED_HEX" \
  --space-id "$SPACE_ID" \
  --space-name phase56-manytype-server \
  --creator-name manytype) >"$INVITE_JSON"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_space_invite_publish.dart" \
  --network-config "$NETWORK_YML" \
  --invite-json "$INVITE_JSON" \
  --permissions writer >"$PUBLISH_JSON"

INVITE_URL="$(python3 - "$PUBLISH_JSON" <<'PY'
import json,sys
print(json.load(open(sys.argv[1]))['invite_url'])
PY
)"
[[ -n "$INVITE_URL" ]] || fail 'could not parse invite url'

printf 'Starting official anytype-cli service...\n'
ADD_HOST_ARGS=()
oracle_start_cli_service "$CLI_NAME" "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS
oracle_wait_for_grpc || fail 'official gRPC service did not become ready'
oracle_create_official_account "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS phase56-bot >/dev/null
oracle_wait_for_cli_session "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS || fail 'official CLI session did not become ready'

printf 'Joining Manytype space via invite...\n'
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" space-join \
  --invite-url "$INVITE_URL" \
  --network-id manytype-phase56 \
  --space-id "$SPACE_ID" >"$TMPDIR/join.json"
python3 - "$TMPDIR/join.json" <<'PY'
import json,sys
j=json.load(open(sys.argv[1]))
assert not j.get("error_code"), j
PY

sleep 5

printf 'Preloading page type context for official-authored create...\n'
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" object-show \
  --space-id "$SPACE_ID" \
  --object-id "$SEED_OBJECT_ID" >"$TMPDIR/preload-show.json"
TYPE_ID="$(python3 - "$TMPDIR/preload-show.json" <<'PY'
import json,sys
j=json.load(open(sys.argv[1]))
assert not j.get("error_code"), j
print(j["root_details"]["type"])
PY
)"
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" object-show \
  --space-id "$SPACE_ID" \
  --object-id "$TYPE_ID" >"$TMPDIR/preload-type-show.json"

printf 'Authoring the bounded detail slice from the official client...\n'
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" object-create \
  --space-id "$SPACE_ID" \
  --name 'phase56 official target' >"$TMPDIR/create.json"
OBJECT_ID="$(python3 - "$TMPDIR/create.json" <<'PY'
import json,sys
j=json.load(open(sys.argv[1]))
assert not j.get("error_code"), j
print(j["object_id"])
PY
)"
[[ -n "$OBJECT_ID" ]] || fail 'could not parse official-created object id'

oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" object-set-detail \
  --space-id "$SPACE_ID" \
  --object-id "$OBJECT_ID" \
  --detail-key description \
  --detail-kind string \
  --detail-value 'phase56 detail description' >"$TMPDIR/set-description.json"
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" object-set-detail \
  --space-id "$SPACE_ID" \
  --object-id "$OBJECT_ID" \
  --detail-key featuredRelations \
  --detail-kind string-list \
  --detail-values description,sourceObject >"$TMPDIR/set-featured.json"

printf 'Re-reading the official object after the detail writes...\n'
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" object-show \
  --space-id "$SPACE_ID" \
  --object-id "$OBJECT_ID" >"$OFFICIAL_SHOW_PATH"
python3 - "$OFFICIAL_SHOW_PATH" <<'PY'
import json,sys
j=json.load(open(sys.argv[1]))
root=j.get("root_details", {})
assert root.get("description") == "phase56 detail description", root
assert root.get("featuredRelations") == ["description", "sourceObject"], root
PY

MAIN_ATTEMPT=""
printf 'Waiting for Manytype to observe the official-authored detail state...\n'
if ! wait_for_manytype_read "$MANYTYPE_HOME" "$MAIN_SYNC_CAPTURE" "$MAIN_READ_PATH" MAIN_ATTEMPT; then
  fail 'Manytype did not observe official-authored bounded detail edits'
fi

REOPEN_ATTEMPT=""
printf 'Waiting for a fresh Manytype home to observe the official-authored detail state...\n'
if ! wait_for_manytype_read "$MANYTYPE_REOPEN_HOME" "$REOPEN_SYNC_CAPTURE" "$REOPEN_READ_PATH" REOPEN_ATTEMPT; then
  fail 'Fresh Manytype home did not retain the official-authored bounded detail edits'
fi

write_diagnostics

python3 - \
  "$ARTIFACT_PATH" \
  "$OFFICIAL_SHOW_PATH" \
  "$MAIN_READ_PATH" \
  "$REOPEN_READ_PATH" \
  "$MAIN_SYNC_CAPTURE" \
  "$REOPEN_SYNC_CAPTURE" \
  "$DIAGNOSTICS_JSON_PATH" \
  "$RUNTIME_METADATA_PATH" \
  "$OBJECT_ID" \
  "$MAIN_ATTEMPT" \
  "$REOPEN_ATTEMPT" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    official_show_path,
    main_read_path,
    reopen_read_path,
    main_sync_capture,
    reopen_sync_capture,
    diagnostics_json_path,
    metadata_path,
    object_id,
    main_attempt,
    reopen_attempt,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase56 official to manytype compatibility",
    "accepted_slice": {
        "object_family": "page-rooted objects only",
        "detail_keys": ["description", "featuredRelations"],
        "featured_relations_value": ["description", "sourceObject"],
        "official_post_edit_reread_required": True,
        "manytype_observation_retry_required": True,
    },
    "truth_surface": "manytype_server",
    "official_to_manytype": {
        "object_id": object_id,
        "description": "phase56 detail description",
        "featured_relations": ["description", "sourceObject"],
        "official_show_path": official_show_path,
        "read_path": main_read_path,
        "reopen_read_path": reopen_read_path,
        "main_sync_capture_path": main_sync_capture,
        "reopen_sync_capture_path": reopen_sync_capture,
        "diagnostics_path": diagnostics_json_path,
        "main_observed_attempt": int(main_attempt),
        "reopen_observed_attempt": int(reopen_attempt),
    },
    "metadata_path": metadata_path,
    "success": True,
}

pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase56 official to manytype compatibility" \
  "$NETWORK_YML" \
  "$PROBE_BIN" \
  "$ARTIFACT_PATH" \
  "$OFFICIAL_SHOW_PATH" \
  "$MAIN_READ_PATH" \
  "$REOPEN_READ_PATH" \
  "$MAIN_SYNC_CAPTURE" \
  "$REOPEN_SYNC_CAPTURE" \
  "$DIAGNOSTICS_JSON_PATH"

printf 'Phase 56 artifact written to %s\n' "$ARTIFACT_PATH"
printf 'phase56 harness: PASSED\n'
