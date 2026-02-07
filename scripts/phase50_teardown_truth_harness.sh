#!/usr/bin/env bash

set -euo pipefail

# Phase 50: teardown truth capture and scope freeze.
#
# Truth surfaces:
#   - self-hosted official Any-Sync: coordinator-backed SpaceDelete lifecycle
#   - local manytype_server: stubbed teardown RPCs with no observable status move
#
# AccountDelete is captured for scope-decision evidence only.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase50"
TOP_LEVEL_ARTIFACT="$ARTIFACT_DIR/teardown-truth-baseline.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"

TMPDIR="$(mktemp -d)"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
LOCAL_SERVER_CONFIG="$TMPDIR/local-manytype-server.toml"
LOCAL_NETWORK_CONFIG="$TMPDIR/local-network.yml"
LOCAL_SERVER_LOG="$TMPDIR/local-manytype-server.log"
LOCAL_DB_PATH="$TMPDIR/local-manytype-server.redb"
LOCAL_SERVER_BIN="$ROOT_DIR/rust/target/release/manytype_server"
LOCAL_SERVER_PORT=33150
LOCAL_SERVER_PID=""

cleanup() {
  stop_local_server
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

stop_local_server() {
  if [[ -n "$LOCAL_SERVER_PID" ]]; then
    kill "$LOCAL_SERVER_PID" >/dev/null 2>&1 || true
    wait "$LOCAL_SERVER_PID" >/dev/null 2>&1 || true
    LOCAL_SERVER_PID=""
  fi
}

wait_for_local_server() {
  local attempts="${1:-30}"
  local delay="${2:-1}"
  local i
  for i in $(seq 1 "$attempts"); do
    if [[ -n "$LOCAL_SERVER_PID" ]] && ! kill -0 "$LOCAL_SERVER_PID" >/dev/null 2>&1; then
      return 1
    fi
    if [[ -f "$LOCAL_SERVER_LOG" ]] && grep -q "Listening on QUIC" "$LOCAL_SERVER_LOG"; then
      return 0
    fi
    sleep "$delay"
  done
  return 1
}

start_local_server() {
  stop_local_server
  "$LOCAL_SERVER_BIN" "$LOCAL_SERVER_CONFIG" >"$LOCAL_SERVER_LOG" 2>&1 &
  LOCAL_SERVER_PID="$!"
  if ! wait_for_local_server 45 1; then
    fail 'local manytype_server did not become ready'
  fi
}

write_local_server_files() {
  cat >"$LOCAL_SERVER_CONFIG" <<EOF
quic_listen = "127.0.0.1:${LOCAL_SERVER_PORT}"
db_path = "${LOCAL_DB_PATH}"
identity_seed = "0404040404040404040404040404040404040404040404040404040404040404"
network_id = "manytype-phase50"
EOF

  cat >"$LOCAL_NETWORK_CONFIG" <<EOF
id: local-phase50
networkId: manytype-phase50
nodes:
  - peerId: local-phase50
    addresses:
      - quic://127.0.0.1:${LOCAL_SERVER_PORT}
      - 127.0.0.1:${LOCAL_SERVER_PORT}
    types:
      - coordinator
      - tree
EOF
}

run_manytype() {
  local home="$1"
  shift
  HOME="$home" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" "$@"
}

seed_home() {
  local home="$1"
  local seed_text="$2"
  local network_config="$3"
  local wait_seconds="${4:-2}"
  mkdir -p "$home"
  run_manytype "$home" init >/dev/null
  run_manytype "$home" create "$seed_text" >/dev/null
  HOME="$home" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
    --network-config "$network_config" \
    --wait-seconds "$wait_seconds" >/dev/null
}

capture_teardown() {
  local home="$1"
  local action="$2"
  local surface="$3"
  local network_config="$4"
  local wait_seconds="$5"
  local output_path="$6"
  HOME="$home" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase50_teardown_capture.dart" \
    --action "$action" \
    --surface "$surface" \
    --network-config "$network_config" \
    --wait-seconds "$wait_seconds" \
    >"$output_path"
}

printf '=== Phase 50: teardown truth capture ===\n\n'

mkdir -p "$ARTIFACT_DIR"
rm -f "$TOP_LEVEL_ARTIFACT" "$RUNTIME_METADATA_PATH"
rm -f "$ARTIFACT_DIR"/*.json

oracle_run_preflight
oracle_export_runtime_env

printf 'Building release binaries...\n'
(cd "$ROOT_DIR/rust" && cargo build -p manytype_quic_ffi -p manytype_server --release >/dev/null)
[[ -x "$LOCAL_SERVER_BIN" ]] || fail 'manytype_server release binary missing after build'

printf 'Building official probe binary for runtime metadata...\n'
oracle_build_probe_binary "$PROBE_BIN"

printf 'Starting self-hosted official any-sync stack...\n'
oracle_compose_up

printf 'Capturing official SpaceDelete truth...\n'
seed_home "$TMPDIR/oracle-space-home" "phase50 oracle space seed" "$NETWORK_CONFIG_SRC" 2
capture_teardown \
  "$TMPDIR/oracle-space-home" \
  "space-delete" \
  "self-hosted-official" \
  "$NETWORK_CONFIG_SRC" \
  6 \
  "$ARTIFACT_DIR/oracle_space_delete.json"

printf 'Capturing official AccountDelete truth...\n'
seed_home "$TMPDIR/oracle-account-home" "phase50 oracle account seed" "$NETWORK_CONFIG_SRC" 2
capture_teardown \
  "$TMPDIR/oracle-account-home" \
  "account-delete" \
  "self-hosted-official" \
  "$NETWORK_CONFIG_SRC" \
  6 \
  "$ARTIFACT_DIR/oracle_account_delete.json"

printf 'Preparing local manytype_server config...\n'
write_local_server_files

printf 'Starting local manytype_server...\n'
start_local_server

printf 'Capturing local SpaceDelete truth...\n'
seed_home "$TMPDIR/local-space-home" "phase50 local space seed" "$LOCAL_NETWORK_CONFIG" 1
capture_teardown \
  "$TMPDIR/local-space-home" \
  "space-delete" \
  "manytype_server" \
  "$LOCAL_NETWORK_CONFIG" \
  2 \
  "$ARTIFACT_DIR/local_space_delete.json"

printf 'Capturing local AccountDelete truth...\n'
seed_home "$TMPDIR/local-account-home" "phase50 local account seed" "$LOCAL_NETWORK_CONFIG" 1
capture_teardown \
  "$TMPDIR/local-account-home" \
  "account-delete" \
  "manytype_server" \
  "$LOCAL_NETWORK_CONFIG" \
  2 \
  "$ARTIFACT_DIR/local_account_delete.json"

python3 - \
  "$TOP_LEVEL_ARTIFACT" \
  "$ARTIFACT_DIR/oracle_space_delete.json" \
  "$ARTIFACT_DIR/oracle_account_delete.json" \
  "$ARTIFACT_DIR/local_space_delete.json" \
  "$ARTIFACT_DIR/local_account_delete.json" \
  "$RUNTIME_METADATA_PATH" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    oracle_space_path,
    oracle_account_path,
    local_space_path,
    local_account_path,
    metadata_path,
) = sys.argv[1:]

oracle_space = json.load(open(oracle_space_path))
oracle_account = json.load(open(oracle_account_path))
local_space = json.load(open(local_space_path))
local_account = json.load(open(local_account_path))

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase50 teardown truth capture",
    "space_delete": {
        "accepted_truth_surface": "self-hosted-official",
        "proof_mode_label": "coordinator-status-reread",
        "supported_preconditions": [
            "bounded owner space already seeded live on the self-hosted official stack",
            "teardown proof is coordinator status based, not object-tree disappearance based",
            "reconnect-backed status observation is required after the delete RPC",
        ],
        "required_observations": [
            "SpaceStatusCheck transitions Created -> PendingDeletion immediately after request",
            "a fresh reconnect observes SpaceStatusDeleted on the self-hosted official stack",
            "manytype_server does not change SpaceStatusCheck or DeletionLog after the same RPC",
        ],
        "official_capture_path": oracle_space_path,
        "local_capture_path": local_space_path,
    },
    "account_delete": {
        "decision": "defer",
        "reason": "Self-hosted official AccountDelete does not provide a bounded replayable acceptance path from the current Manytype truth surface, while manytype_server still reports stub success without observable lifecycle movement.",
        "official_capture_path": oracle_account_path,
        "local_capture_path": local_account_path,
    },
    "metadata_path": metadata_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase50 teardown truth capture" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$TOP_LEVEL_ARTIFACT" \
  "$ARTIFACT_DIR/oracle_space_delete.json" \
  "$ARTIFACT_DIR/oracle_account_delete.json" \
  "$ARTIFACT_DIR/local_space_delete.json" \
  "$ARTIFACT_DIR/local_account_delete.json"

printf 'Runtime metadata written to %s\n' "$RUNTIME_METADATA_PATH"
printf 'Phase 50 artifact written to %s\n' "$TOP_LEVEL_ARTIFACT"
printf 'phase50 harness: PASSED\n'
