#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase60"
ARTIFACT_PATH="$ARTIFACT_DIR/manytype-server-delete-compatibility.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
MAIN_SYNC_CAPTURE="$ARTIFACT_DIR/official_to_manytype_sync.json"
REOPEN_SYNC_CAPTURE="$ARTIFACT_DIR/official_to_manytype_reopen-sync.json"
PREDELETE_READ_PATH="$ARTIFACT_DIR/official_to_manytype_predelete-read.txt"
LIST_ABSENCE_PATH="$ARTIFACT_DIR/official_to_manytype_postdelete-list.txt"
READ_REFUSAL_PATH="$ARTIFACT_DIR/official_to_manytype_postdelete-read.txt"
REOPEN_LIST_ABSENCE_PATH="$ARTIFACT_DIR/official_to_manytype_reopen-list.txt"
REOPEN_READ_REFUSAL_PATH="$ARTIFACT_DIR/official_to_manytype_reopen-read.txt"
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
CLI_NAME="phase60-anytype-cli-$$"
LOCAL_SERVER_PORT=33160
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

run_network_cli() {
  local home="$1"
  shift
  HOME="$home" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
    --server "127.0.0.1:${LOCAL_SERVER_PORT}" \
    --network-config "$NETWORK_YML" \
    "$@"
}

run_local_cli() {
  local home="$1"
  shift
  HOME="$home" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" "$@"
}

wait_for_manytype_predelete_read() {
  local home="$1"
  local capture_path="$2"
  local output_path="$3"
  local attempts_var_name="$4"
  local i
  for i in $(seq 1 20); do
    MANYTYPE_SYNC_CAPTURE_PATH="$capture_path" \
      run_network_cli "$home" read --sync "$OBJECT_ID" >"$output_path" || true
    if EXPECTED_OBJECT_ID="$OBJECT_ID" python3 - "$output_path" <<'PY'
import os
import pathlib
import sys

text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
expected = os.environ["EXPECTED_OBJECT_ID"]
ok = (
    f"Object: {expected}" in text
    or f"Name: phase60 official deletion target" in text
)
raise SystemExit(0 if ok else 1)
PY
    then
      printf -v "$attempts_var_name" '%s' "$i"
      return 0
    fi
    sleep 2
  done
  return 1
}

wait_for_manytype_delete_observation() {
  local home="$1"
  local sync_capture_path="$2"
  local list_output_path="$3"
  local read_output_path="$4"
  local attempts_var_name="$5"
  local i
  for i in $(seq 1 20); do
    MANYTYPE_SYNC_CAPTURE_PATH="$sync_capture_path" run_network_cli "$home" sync >/dev/null || true
    run_local_cli "$home" list >"$list_output_path" 2>&1 || true
    run_local_cli "$home" read "$OBJECT_ID" >"$read_output_path" 2>&1 || true
    if EXPECTED_OBJECT_ID="$OBJECT_ID" python3 - "$list_output_path" "$read_output_path" <<'PY'
import os
import pathlib
import re
import sys

list_text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
read_text = pathlib.Path(sys.argv[2]).read_text(encoding="utf-8", errors="replace")
object_id = os.environ["EXPECTED_OBJECT_ID"]
rows = [
    line
    for line in list_text.splitlines()
    if re.match(r"^bafy[a-z0-9]+\s{2,}\S+\s{2,}.+", line)
]
list_rows = "\n".join(rows)
read_ok = (
    f"Object {object_id} has been deleted or archived" in read_text
    or f"Object not found: {object_id}" in read_text
)
ok = object_id not in list_rows and read_ok
raise SystemExit(0 if ok else 1)
PY
    then
      printf -v "$attempts_var_name" '%s' "$i"
      return 0
    fi
    sleep 2
  done
  return 1
}

printf '=== Phase 60: official -> Manytype delete compatibility ===\n\n'

mkdir -p "$ARTIFACT_DIR" "$MANYTYPE_HOME" "$MANYTYPE_REOPEN_HOME/.manytype" "$OFFICIAL_ROOT"
rm -f "$ARTIFACT_DIR"/*.json "$ARTIFACT_DIR"/*.txt

oracle_run_preflight
oracle_export_runtime_env

printf 'Building binaries...\n'
(cd "$ROOT_DIR/rust" && cargo build -p manytype_quic_ffi --release >/dev/null)
(cd "$ROOT_DIR/rust" && cargo build -p manytype_server >/dev/null)
oracle_build_probe_binary "$PROBE_BIN"

cat >"$SERVER_CONFIG" <<EOF
quic_listen = "127.0.0.1:${LOCAL_SERVER_PORT}"
db_path = "${TMPDIR}/manytype-server.redb"
identity_seed = "0505050505050505050505050505050505050505050505050505050505050505"
network_id = "manytype-phase60"
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
id: local-phase60
networkId: manytype-phase60
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
oracle_run_cli "$MANYTYPE_HOME" --server "127.0.0.1:${LOCAL_SERVER_PORT}" create phase60-seed >"$TMPDIR/seed.txt"
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
  --space-name phase60-manytype-server \
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
oracle_create_official_account "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS phase60-bot >/dev/null
oracle_wait_for_cli_session "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS || fail 'official CLI session did not become ready'

printf 'Joining Manytype space via invite...\n'
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" space-join \
  --invite-url "$INVITE_URL" \
  --network-id manytype-phase60 \
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
  --object-id "$TYPE_ID" >"$ARTIFACT_DIR/official_to_manytype_preload-type-show.json"

printf 'Authoring the bounded delete slice from the official client...\n'
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" object-create \
  --space-id "$SPACE_ID" \
  --name 'phase60 official deletion target' >"$ARTIFACT_DIR/official_to_manytype_create.json"
OBJECT_ID="$(python3 - "$ARTIFACT_DIR/official_to_manytype_create.json" <<'PY'
import json,sys
j=json.load(open(sys.argv[1]))
assert not j.get("error_code"), j
print(j["object_id"])
PY
)"
[[ -n "$OBJECT_ID" ]] || fail 'could not parse official-created object id'

PREDELETE_ATTEMPT=""
printf 'Waiting for Manytype to observe the official-authored object before delete...\n'
if ! wait_for_manytype_predelete_read "$MANYTYPE_HOME" "$MAIN_SYNC_CAPTURE" "$PREDELETE_READ_PATH" PREDELETE_ATTEMPT; then
  fail 'Manytype did not observe the official-authored object before delete'
fi

printf 'Deleting the object from the official client...\n'
oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" object-delete \
  --space-id "$SPACE_ID" \
  --object-id "$OBJECT_ID" >"$ARTIFACT_DIR/official_to_manytype_delete.json"
DELETE_ERROR_CODE="$(python3 - "$ARTIFACT_DIR/official_to_manytype_delete.json" <<'PY'
import json,sys
j=json.load(open(sys.argv[1]))
print(j.get("error_code", ""))
PY
)"
DELETE_ATTEMPTED="$(python3 - "$ARTIFACT_DIR/official_to_manytype_delete.json" <<'PY'
import json,sys
j=json.load(open(sys.argv[1]))
print("true" if j.get("delete_attempted") else "false")
PY
)"
[[ -z "$DELETE_ERROR_CODE" ]] || fail "official object-delete returned error ($DELETE_ERROR_CODE)"
[[ "$DELETE_ATTEMPTED" == "true" ]] || fail 'official object-delete did not reach delete step'

MAIN_ATTEMPT=""
printf 'Waiting for Manytype to observe deletion on the current home...\n'
if ! wait_for_manytype_delete_observation \
  "$MANYTYPE_HOME" \
  "$MAIN_SYNC_CAPTURE" \
  "$LIST_ABSENCE_PATH" \
  "$READ_REFUSAL_PATH" \
  MAIN_ATTEMPT; then
  fail 'Manytype did not observe official-authored deletion on the current home'
fi

REOPEN_ATTEMPT=""
printf 'Waiting for a fresh Manytype home to observe deletion...\n'
if ! wait_for_manytype_delete_observation \
  "$MANYTYPE_REOPEN_HOME" \
  "$REOPEN_SYNC_CAPTURE" \
  "$REOPEN_LIST_ABSENCE_PATH" \
  "$REOPEN_READ_REFUSAL_PATH" \
  REOPEN_ATTEMPT; then
  fail 'Fresh Manytype home did not retain official-authored deletion'
fi

write_diagnostics

python3 - \
  "$ARTIFACT_PATH" \
  "$OBJECT_ID" \
  "$ARTIFACT_DIR/official_to_manytype_preload-type-show.json" \
  "$ARTIFACT_DIR/official_to_manytype_create.json" \
  "$PREDELETE_READ_PATH" \
  "$ARTIFACT_DIR/official_to_manytype_delete.json" \
  "$MAIN_SYNC_CAPTURE" \
  "$LIST_ABSENCE_PATH" \
  "$READ_REFUSAL_PATH" \
  "$REOPEN_SYNC_CAPTURE" \
  "$REOPEN_LIST_ABSENCE_PATH" \
  "$REOPEN_READ_REFUSAL_PATH" \
  "$DIAGNOSTICS_JSON_PATH" \
  "$RUNTIME_METADATA_PATH" \
  "$MAIN_ATTEMPT" \
  "$REOPEN_ATTEMPT" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    object_id,
    type_preload_path,
    create_output_path,
    predelete_read_path,
    delete_output_path,
    main_sync_capture_path,
    list_absence_path,
    read_refusal_path,
    reopen_sync_capture_path,
    reopen_list_absence_path,
    reopen_read_refusal_path,
    diagnostics_path,
    metadata_path,
    main_attempt,
    reopen_attempt,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase60 official to manytype delete compatibility",
    "accepted_slice": {
        "object_family": "page-rooted objects only",
        "mutation_family": "archive-backed object deletion",
        "bounded_object_type": "page",
        "manytype_list_absence_required": True,
        "manytype_read_refusal_required": True,
        "fresh_home_reread_required": True,
    },
    "truth_surface": "manytype_server",
    "official_to_manytype": {
        "object_id": object_id,
        "object_name": "phase60 official deletion target",
        "type_preload_path": type_preload_path,
        "create_output_path": create_output_path,
        "predelete_read_path": predelete_read_path,
        "delete_output_path": delete_output_path,
        "main_sync_capture_path": main_sync_capture_path,
        "list_absence_path": list_absence_path,
        "read_refusal_path": read_refusal_path,
        "reopen_sync_capture_path": reopen_sync_capture_path,
        "reopen_list_absence_path": reopen_list_absence_path,
        "reopen_read_refusal_path": reopen_read_refusal_path,
        "diagnostics_path": diagnostics_path,
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
  "phase60 official to manytype delete compatibility" \
  "$NETWORK_YML" \
  "$PROBE_BIN" \
  "$ARTIFACT_PATH" \
  "$ARTIFACT_DIR/official_to_manytype_preload-type-show.json" \
  "$ARTIFACT_DIR/official_to_manytype_create.json" \
  "$PREDELETE_READ_PATH" \
  "$ARTIFACT_DIR/official_to_manytype_delete.json" \
  "$MAIN_SYNC_CAPTURE" \
  "$LIST_ABSENCE_PATH" \
  "$READ_REFUSAL_PATH" \
  "$REOPEN_SYNC_CAPTURE" \
  "$REOPEN_LIST_ABSENCE_PATH" \
  "$REOPEN_READ_REFUSAL_PATH" \
  "$DIAGNOSTICS_JSON_PATH"

printf 'Phase 60 artifact written to %s\n' "$ARTIFACT_PATH"
printf 'phase60 harness: PASSED\n'
