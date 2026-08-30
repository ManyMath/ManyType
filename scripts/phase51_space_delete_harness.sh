#!/usr/bin/env bash

set -euo pipefail

# Phase 51 - bounded SpaceDelete parity.
#
# Accepted proof surface:
#   - self-hosted official Any-Sync via reconnect-backed coordinator status reread
#
# Required explicit rejection:
#   - local manytype_server remains unsupported and must be reported as such

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase51"
TOP_LEVEL_ARTIFACT="$ARTIFACT_DIR/space-delete-parity.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"

TMPDIR="$(mktemp -d)"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
LOCAL_SERVER_CONFIG="$TMPDIR/local-manytype-server.toml"
LOCAL_NETWORK_CONFIG="$TMPDIR/local-network.yml"
LOCAL_SERVER_LOG="$TMPDIR/local-manytype-server.log"
LOCAL_DB_PATH="$TMPDIR/local-manytype-server.redb"
LOCAL_SERVER_BIN="$ROOT_DIR/rust/target/release/manytype_server"
LOCAL_SERVER_PORT=33160
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
deployment_mode = "development"
quic_listen = "127.0.0.1:${LOCAL_SERVER_PORT}"
db_path = "${LOCAL_DB_PATH}"
identity_seed = "0505050505050505050505050505050505050505050505050505050505050505"
network_id = "manytype-phase51"
EOF

  cat >"$LOCAL_NETWORK_CONFIG" <<EOF
id: local-phase51
networkId: manytype-phase51
nodes:
  - peerId: local-phase51
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

capture_space_delete() {
  local home="$1"
  local network_config="$2"
  local wait_seconds="$3"
  local expected_exit="$4"
  local output_path="$5"
  local stderr_path="$6"

  set +e
  HOME="$home" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
    --network-config "$network_config" \
    space-delete \
    --wait-seconds "$wait_seconds" \
    --json >"$output_path" 2>"$stderr_path"
  local status=$?
  set -e

  if [[ "$status" -ne "$expected_exit" ]]; then
    fail "space-delete exited $status (expected $expected_exit); stderr: $(cat "$stderr_path")"
  fi
}

printf '=== Phase 51: bounded SpaceDelete parity ===\n\n'

mkdir -p "$ARTIFACT_DIR"

oracle_run_preflight
oracle_export_runtime_env

rm -f "$TOP_LEVEL_ARTIFACT" "$RUNTIME_METADATA_PATH"
rm -f "$ARTIFACT_DIR"/*.json

printf 'Building release binaries...\n'
(cd "$ROOT_DIR/rust" && cargo build -p manytype_quic_ffi -p manytype_server --release >/dev/null)
[[ -x "$LOCAL_SERVER_BIN" ]] || fail 'manytype_server release binary missing after build'

printf 'Building official probe binary for runtime metadata...\n'
oracle_build_probe_binary "$PROBE_BIN"

printf 'Starting self-hosted official any-sync stack...\n'
oracle_compose_up

printf 'Capturing supported official SpaceDelete flow...\n'
seed_home "$TMPDIR/oracle-space-home" "phase51 official space seed" "$NETWORK_CONFIG_SRC" 2
capture_space_delete \
  "$TMPDIR/oracle-space-home" \
  "$NETWORK_CONFIG_SRC" \
  6 \
  0 \
  "$ARTIFACT_DIR/official_space_delete.json" \
  "$TMPDIR/official-space-delete.stderr"

printf 'Preparing local manytype_server config...\n'
write_local_server_files

printf 'Starting local manytype_server...\n'
start_local_server

printf 'Capturing explicit unsupported local-server result...\n'
seed_home "$TMPDIR/local-space-home" "phase51 local space seed" "$LOCAL_NETWORK_CONFIG" 1
capture_space_delete \
  "$TMPDIR/local-space-home" \
  "$LOCAL_NETWORK_CONFIG" \
  2 \
  2 \
  "$ARTIFACT_DIR/local_space_delete_rejected.json" \
  "$TMPDIR/local-space-delete.stderr"

python3 - \
  "$TOP_LEVEL_ARTIFACT" \
  "$ARTIFACT_DIR/official_space_delete.json" \
  "$ARTIFACT_DIR/local_space_delete_rejected.json" \
  "$RUNTIME_METADATA_PATH" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path, official_path, local_path, metadata_path = sys.argv[1:]

official = json.load(open(official_path))
local = json.load(open(local_path))

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase51 bounded space delete",
    "accepted_truth_surface": "self-hosted-official",
    "proof_mode": "coordinator-status-reread",
    "official_supported_flow": {
        "outcome": official["assessment"]["outcome"],
        "space_id": official["space_id"],
        "artifact_path": official_path,
    },
    "local_rejected_flow": {
        "outcome": local["assessment"]["outcome"],
        "observed_surface_label": local["assessment"]["observed_surface_label"],
        "space_id": local["space_id"],
        "artifact_path": local_path,
    },
    "metadata_path": metadata_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase51 bounded space delete" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$TOP_LEVEL_ARTIFACT" \
  "$ARTIFACT_DIR/official_space_delete.json" \
  "$ARTIFACT_DIR/local_space_delete_rejected.json"

printf 'Runtime metadata written to %s\n' "$RUNTIME_METADATA_PATH"
printf 'Phase 51 artifact written to %s\n' "$TOP_LEVEL_ARTIFACT"
printf 'phase51 harness: PASSED\n'
