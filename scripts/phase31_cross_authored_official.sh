#!/usr/bin/env bash

set -euo pipefail

# Cross-authored verification (official infra):
# - Manytype space publishes an invite
# - Official anytype-cli joins that space and creates+edits a note (official-authored)
# - Manytype syncs and re-reads the official-authored edit

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ANYTYPE_IMAGE="$ORACLE_ANYTYPE_IMAGE"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
ARTIFACT_PATH="${PHASE31_CROSS_AUTHORED_OFFICIAL_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase31-cross-authored-official.json}"
METADATA_PATH="${ARTIFACT_PATH%.json}-metadata.json"
MANYTYPE_SEED_SYNC_CAPTURE="$ROOT_DIR/test_vectors/phase31-cross-authored-official-manytype-seed-sync.json"
MANYTYPE_PULL_SYNC_CAPTURE="$ROOT_DIR/test_vectors/phase31-cross-authored-official-manytype-pull-sync.json"
OFFICIAL_JOIN_JSON="$ROOT_DIR/test_vectors/phase31-cross-authored-official-official-join.json"
OFFICIAL_CREATE_JSON="$ROOT_DIR/test_vectors/phase31-cross-authored-official-official-create.json"
OFFICIAL_EDIT_JSON="$ROOT_DIR/test_vectors/phase31-cross-authored-official-official-edit.json"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
OFFICIAL_ROOT="$TMPDIR/anytype-root"
NETWORK_YML="$TMPDIR/network.yml"
INVITE_JSON="$TMPDIR/invite.json"
PUBLISH_JSON="$TMPDIR/publish.json"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
CLI_NAME="phase31-anytype-cli-official-$$"
CLI_LOG_FILE="$TMPDIR/anytype-cli.log"

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

mkdir -p "$ROOT_DIR/test_vectors"
mkdir -p "$MANYTYPE_HOME" "$OFFICIAL_ROOT"
cp "$NETWORK_CONFIG_SRC" "$NETWORK_YML"

oracle_run_preflight
oracle_export_runtime_env

printf 'Starting official any-sync stack...\n'
oracle_compose_up
oracle_build_probe_binary "$PROBE_BIN"

# anytype-cli runs in `--network host` so it can expose the local gRPC API on
# 127.0.0.1:31010. The any-sync docker compose services are reachable via their
# bridge-network IPs; map those hostnames explicitly so the official client can
# resolve `any-sync-*` addresses from `client.yml`.
ADD_HOST_ARGS=()
oracle_populate_add_host_args ADD_HOST_ARGS

ORIGINAL_TEXT="phase31-official-seed-$(date +%s%N)"
UPDATED_TEXT="phase31-official-updated-$(date +%s%N)"

printf 'Preparing Manytype CLI temp home...\n'
mkdir -p "$MANYTYPE_HOME"
oracle_run_cli "$MANYTYPE_HOME" init >/dev/null
oracle_run_cli "$MANYTYPE_HOME" create "$ORIGINAL_TEXT" >/dev/null

printf 'Seeding Manytype space to official stack...\n'
oracle_seed_live_space "$MANYTYPE_HOME" "$NETWORK_CONFIG_SRC" 10

printf 'Syncing Manytype space to official stack...\n'
MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SEED_SYNC_CAPTURE" HOME="$MANYTYPE_HOME" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

printf 'Computing Manytype identity + generating invite material...\n'
SPACE_INFO_JSON="$(oracle_identity_json "$MANYTYPE_HOME")"
SPACE_ID="$(printf '%s' "$SPACE_INFO_JSON" | oracle_json_stdin_field space_id)"
oracle_generate_invite_from_home "$MANYTYPE_HOME" "phase31-cross-authored-official" "manytype" "$INVITE_JSON"

printf 'Publishing invite (ACL record + file-node blob)...\n'
oracle_publish_invite "$MANYTYPE_HOME" "$NETWORK_YML" "$INVITE_JSON" "$PUBLISH_JSON" writer

INVITE_URL="$(oracle_invite_url_from_json "$PUBLISH_JSON")"

printf 'Starting anytype-cli service container...\n'
oracle_start_cli_service "$CLI_NAME" "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS

if ! oracle_wait_for_grpc; then
  printf 'FAIL: anytype-cli gRPC did not become ready on 127.0.0.1:31010\n' >&2
  docker logs "$CLI_NAME" | tail -200 >&2 || true
  exit 1
fi

ACCOUNT_KEY="$(oracle_create_official_account "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS phase31-bot)"
[[ -n "$ACCOUNT_KEY" ]] || oracle_fail 'official account key is empty after auth create'

printf 'Waiting for authenticated anytype-cli session...\n'
if ! oracle_wait_for_cli_session "$OFFICIAL_ROOT" "$NETWORK_YML" ADD_HOST_ARGS; then
  printf 'FAIL: anytype-cli session did not become ready\n' >&2
  docker logs "$CLI_NAME" | tail -200 >&2 || true
  exit 1
fi

run_probe() {
  local action="$1"
  shift
  oracle_run_probe_binary "$PROBE_BIN" "$OFFICIAL_ROOT" "$action" "$@"
}

NETWORK_ID="$(sed -n 's/^networkId: //p' "$NETWORK_YML" | head -1)"
if [[ -z "$NETWORK_ID" ]]; then
  printf 'FAIL: could not parse networkId from %s\n' "$NETWORK_YML" >&2
  exit 1
fi

printf 'Joining Manytype space via invite (gRPC SpaceJoin)...\n'
run_probe space-join --invite-url "$INVITE_URL" --network-id "$NETWORK_ID" --space-id "$SPACE_ID" >"$OFFICIAL_JOIN_JSON"
JOIN_ERROR_CODE="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error_code",""))' "$OFFICIAL_JOIN_JSON")"
if [[ -n "$JOIN_ERROR_CODE" ]]; then
  printf 'FAIL: SpaceJoin returned error (%s)\n' "$JOIN_ERROR_CODE" >&2
  cat "$OFFICIAL_JOIN_JSON" >&2 || true
  exit 1
fi

OFFICIAL_SPACE_ID="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("space_id",""))' "$OFFICIAL_JOIN_JSON")"
if [[ -z "$OFFICIAL_SPACE_ID" ]]; then
  OFFICIAL_SPACE_ID="$SPACE_ID"
fi

printf 'Waiting briefly for joined space to be ready...\n'
sleep 5

printf 'Official creates a note in the shared space...\n'
CREATE_OK=0
for attempt in $(seq 1 3); do
  PROBE_TIMEOUT=180s run_probe object-create --space-id "$OFFICIAL_SPACE_ID" --name "$ORIGINAL_TEXT" >"$OFFICIAL_CREATE_JSON" || true
  CREATE_ERR="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error_code",""))' "$OFFICIAL_CREATE_JSON" 2>/dev/null || true)"
  OBJECT_ID="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("object_id",""))' "$OFFICIAL_CREATE_JSON" 2>/dev/null || true)"
  if [[ -z "$CREATE_ERR" && -n "$OBJECT_ID" ]]; then
    CREATE_OK=1
    break
  fi
  printf 'Retrying official object-create (attempt %s/3)...\n' "$attempt" >&2
  sleep 5
done
if [[ "$CREATE_OK" != "1" ]]; then
  printf 'FAIL: official object-create did not succeed\n' >&2
  cat "$OFFICIAL_CREATE_JSON" >&2 || true
  exit 1
fi
if [[ -z "$OBJECT_ID" ]]; then
  printf 'FAIL: could not parse object_id from official object-create output\n' >&2
  cat "$OFFICIAL_CREATE_JSON" >&2 || true
  exit 1
fi

printf 'Official edits note text...\n'
PROBE_TIMEOUT=60s run_probe object-edit-text --space-id "$OFFICIAL_SPACE_ID" --object-id "$OBJECT_ID" --text "$UPDATED_TEXT" >"$OFFICIAL_EDIT_JSON"
EDIT_ERR="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("error_code",""))' "$OFFICIAL_EDIT_JSON" 2>/dev/null || true)"
if [[ -n "$EDIT_ERR" ]]; then
  printf 'FAIL: official object-edit-text returned error (%s)\n' "$EDIT_ERR" >&2
  cat "$OFFICIAL_EDIT_JSON" >&2 || true
  exit 1
fi

printf 'Manytype sync + re-read...\n'
MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_PULL_SYNC_CAPTURE" HOME="$MANYTYPE_HOME" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

MANYTYPE_READ_OUT="$TMPDIR/manytype-read.txt"
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" read "$OBJECT_ID" >"$MANYTYPE_READ_OUT"

mkdir -p "$(dirname "$ARTIFACT_PATH")"
python3 - "$ARTIFACT_PATH" "$METADATA_PATH" "$SPACE_ID" "$OBJECT_ID" "$UPDATED_TEXT" "$MANYTYPE_READ_OUT" "$INVITE_URL" "$MANYTYPE_PULL_SYNC_CAPTURE" "$OFFICIAL_JOIN_JSON" "$OFFICIAL_CREATE_JSON" "$OFFICIAL_EDIT_JSON" <<'PY'
import datetime as dt
import json
import pathlib
import re
import sys

artifact_path = pathlib.Path(sys.argv[1])
metadata_path = sys.argv[2]
space_id = sys.argv[3]
object_id = sys.argv[4]
updated_text = sys.argv[5]
manytype_read_out = sys.argv[6]
invite_url = sys.argv[7]
manytype_capture = sys.argv[8]
join_result_path = sys.argv[9]
create_result_path = sys.argv[10]
edit_result_path = sys.argv[11]

observed_text = ""
try:
  lines = pathlib.Path(manytype_read_out).read_text(encoding="utf-8", errors="replace").splitlines()
except Exception:
  lines = []

def extract(label: str) -> str:
  pat = re.compile(rf"{re.escape(label)}\s+\"(.*)\"")
  for line in reversed(lines):
    m = pat.search(line)
    if m:
      return m.group(1)
  return ""

observed_text = extract("Text (updated):")
if not observed_text:
  observed_text = extract("Text:")

success = bool(space_id and object_id and observed_text == updated_text)

artifact = {
  "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00","Z"),
  "scenario": "official-authored -> manytype-observed (official infra)",
  "space_id": space_id,
  "object_id": object_id,
  "updated_text": updated_text,
  "manytype_observed_text": observed_text,
  "invite_url": invite_url,
  "official_probe": {
    "join_result_path": join_result_path,
    "create_result_path": create_result_path,
    "edit_result_path": edit_result_path,
  },
  "manytype_sync_capture_path": manytype_capture,
  "metadata_path": metadata_path,
  "success": success,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

oracle_write_metadata \
  "$METADATA_PATH" \
  "official-authored note observed by Manytype on the self-hosted official stack" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$ARTIFACT_PATH" \
  "$MANYTYPE_SEED_SYNC_CAPTURE" \
  "$MANYTYPE_PULL_SYNC_CAPTURE" \
  "$OFFICIAL_JOIN_JSON" \
  "$OFFICIAL_CREATE_JSON" \
  "$OFFICIAL_EDIT_JSON"

python3 - "$ARTIFACT_PATH" <<'PY'
import json,sys
data=json.load(open(sys.argv[1]))
if not data.get("success"):
  raise SystemExit(f"cross-authored official artifact failed: observed={data.get('manytype_observed_text')!r}")
print(f"OK: phase31 cross-authored official ({data['object_id']})")
PY

printf 'Artifact written: %s\n' "$ARTIFACT_PATH"
printf 'Metadata written: %s\n' "$METADATA_PATH"
printf 'phase31_cross_authored_official.sh: PASSED\n'
