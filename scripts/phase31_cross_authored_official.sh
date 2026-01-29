#!/usr/bin/env bash

set -euo pipefail

# Cross-authored verification (official infra):
# - Manytype space publishes an invite
# - Official anytype-cli joins that space and creates+edits a note (official-authored)
# - Manytype syncs and re-reads the official-authored edit

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-ghcr.io/anyproto/anytype-cli:latest}"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
ARTIFACT_PATH="${PHASE31_CROSS_AUTHORED_OFFICIAL_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase31-cross-authored-official.json}"
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
PROBE_DIR="$ROOT_DIR/scripts/official_client_grpc_probe"
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

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

printf 'Starting official any-sync stack...\n'
(cd "$ROOT_DIR/docker/any-sync" && docker compose up -d >/dev/null)

compose_ip() {
  (cd "$ROOT_DIR/docker/any-sync" && docker compose ps -q "$1" | xargs docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
}

# anytype-cli runs in `--network host` so it can expose the local gRPC API on
# 127.0.0.1:31010. The any-sync docker compose services are reachable via their
# bridge-network IPs; map those hostnames explicitly so the official client can
# resolve `any-sync-*` addresses from `client.yml`.
ADD_HOST_ARGS=(
  --add-host "any-sync-node-1:$(compose_ip any-sync-node-1)"
  --add-host "any-sync-node-2:$(compose_ip any-sync-node-2)"
  --add-host "any-sync-node-3:$(compose_ip any-sync-node-3)"
  --add-host "any-sync-coordinator:$(compose_ip any-sync-coordinator)"
  --add-host "any-sync-filenode:$(compose_ip any-sync-filenode)"
  --add-host "any-sync-consensusnode:$(compose_ip any-sync-consensusnode)"
)

ORIGINAL_TEXT="phase31-official-seed-$(date +%s%N)"
UPDATED_TEXT="phase31-official-updated-$(date +%s%N)"

printf 'Preparing Manytype CLI temp home...\n'
mkdir -p "$MANYTYPE_HOME"
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" init >/dev/null
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" create "$ORIGINAL_TEXT" >/dev/null

printf 'Seeding Manytype space to official stack...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_CONFIG_SRC" \
  --wait-seconds 10 >/dev/null

printf 'Syncing Manytype space to official stack...\n'
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SEED_SYNC_CAPTURE" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

printf 'Computing Manytype identity + generating invite material...\n'
SPACE_INFO_JSON="$(HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart")"
SPACE_ID="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["space_id"])' <<<"$SPACE_INFO_JSON")"
ACCOUNT_SEED_HEX="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["account_seed_hex"])' <<<"$SPACE_INFO_JSON")"

(cd "$ROOT_DIR/scripts/phase31_invite_gen" && go run . --account-seed-hex "$ACCOUNT_SEED_HEX" --space-id "$SPACE_ID" --space-name "phase31-cross-authored-official" --creator-name "manytype") >"$INVITE_JSON"

printf 'Publishing invite (ACL record + file-node blob)...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_space_invite_publish.dart" \
  --network-config "$NETWORK_YML" \
  --invite-json "$INVITE_JSON" \
  --permissions writer >"$PUBLISH_JSON"

INVITE_URL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["invite_url"])' "$PUBLISH_JSON")"

wait_for_grpc() {
  for _ in $(seq 1 30); do
    if (echo >/dev/tcp/127.0.0.1/31010) >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

wait_for_cli_session() {
  for _ in $(seq 1 30); do
    if docker run --rm --network host "${ADD_HOST_ARGS[@]}" \
      -v "$OFFICIAL_ROOT:/root/.anytype" \
      "$ANYTYPE_IMAGE" space list >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

printf 'Creating bot account...\n'
start_cli_service() {
  docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
  docker run -d --name "$CLI_NAME" --network host "${ADD_HOST_ARGS[@]}" \
    -v "$OFFICIAL_ROOT:/root/.anytype" \
    -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
    "$ANYTYPE_IMAGE" serve --verbose --listen-address 0.0.0.0:31010 >/dev/null
}

printf 'Starting anytype-cli service container...\n'
start_cli_service

if ! wait_for_grpc; then
  printf 'FAIL: anytype-cli gRPC did not become ready on 127.0.0.1:31010\n' >&2
  docker logs "$CLI_NAME" | tail -200 >&2 || true
  exit 1
fi

ACCOUNT_CREATE_OUTPUT="$(docker run --rm --network host "${ADD_HOST_ARGS[@]}" \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  -v "$NETWORK_YML:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create phase31-bot \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype)"

ACCOUNT_KEY="$(printf '%s\n' "$ACCOUNT_CREATE_OUTPUT" | grep -oE '[A-Za-z0-9+/]{20,}={0,2}' | head -1)"
if [[ -z "$ACCOUNT_KEY" ]]; then
  printf 'FAIL: could not parse account key from auth create output\n' >&2
  printf '%s\n' "$ACCOUNT_CREATE_OUTPUT" >&2
  exit 1
fi

docker run --rm --entrypoint sh \
  -v "$OFFICIAL_ROOT:/root/.anytype" \
  "$ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json' >/dev/null

printf 'Waiting for authenticated anytype-cli session...\n'
if ! wait_for_cli_session; then
  printf 'FAIL: anytype-cli session did not become ready\n' >&2
  docker logs "$CLI_NAME" | tail -200 >&2 || true
  exit 1
fi

run_probe() {
  local action="$1"
  shift
  local timeout_arg="${PROBE_TIMEOUT:-60s}"
  (cd "$PROBE_DIR" && go run . --config "$OFFICIAL_ROOT/config.json" --grpc-addr 127.0.0.1:31010 --timeout "$timeout_arg" --action "$action" "$@")
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
python3 - "$ARTIFACT_PATH" "$SPACE_ID" "$OBJECT_ID" "$UPDATED_TEXT" "$MANYTYPE_READ_OUT" "$INVITE_URL" "$MANYTYPE_PULL_SYNC_CAPTURE" "$OFFICIAL_JOIN_JSON" "$OFFICIAL_CREATE_JSON" "$OFFICIAL_EDIT_JSON" <<'PY'
import datetime as dt
import json
import pathlib
import re
import sys

artifact_path = pathlib.Path(sys.argv[1])
space_id = sys.argv[2]
object_id = sys.argv[3]
updated_text = sys.argv[4]
manytype_read_out = sys.argv[5]
invite_url = sys.argv[6]
manytype_capture = sys.argv[7]
join_result_path = sys.argv[8]
create_result_path = sys.argv[9]
edit_result_path = sys.argv[10]

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
  "success": success,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_PATH" <<'PY'
import json,sys
data=json.load(open(sys.argv[1]))
if not data.get("success"):
  raise SystemExit(f"cross-authored official artifact failed: observed={data.get('manytype_observed_text')!r}")
print(f"OK: phase31 cross-authored official ({data['object_id']})")
PY

printf 'Artifact written: %s\n' "$ARTIFACT_PATH"
printf 'phase31_cross_authored_official.sh: PASSED\n'
