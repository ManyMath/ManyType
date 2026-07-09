#!/usr/bin/env bash

set -euo pipefail

# Phase 52 - service-surface CLI productization.
#
# Accepted proof surfaces:
#   - self-hosted official Any-Sync: ACL lifecycle
#   - local manytype_server: direct consensus continuity
#   - local manytype_server: SpacePull continuity

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase52"
TOP_LEVEL_ARTIFACT="$ARTIFACT_DIR/service-cli-productization.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"

TMPDIR="$(mktemp -d)"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
LOCAL_SERVER_CONFIG="$TMPDIR/local-manytype-server.toml"
LOCAL_NETWORK_CONFIG="$TMPDIR/local-network.yml"
LOCAL_SERVER_LOG="$TMPDIR/local-manytype-server.log"
LOCAL_DB_PATH="$TMPDIR/local-manytype-server.redb"
LOCAL_SERVER_BIN="$ROOT_DIR/rust/target/release/manytype_server"
LOCAL_SERVER_PORT=33170
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
identity_seed = "0606060606060606060606060606060606060606060606060606060606060606"
network_id = "manytype-phase52"
EOF

  cat >"$LOCAL_NETWORK_CONFIG" <<EOF
id: local-phase52
networkId: manytype-phase52
nodes:
  - peerId: local-phase52
    addresses:
      - quic://127.0.0.1:${LOCAL_SERVER_PORT}
      - 127.0.0.1:${LOCAL_SERVER_PORT}
    types:
      - coordinator
      - tree
      - consensus
EOF
}

capture_json_command() {
  local expected_exit="$1"
  local output_path="$2"
  local stderr_path="$3"
  shift 3

  set +e
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" "$@" >"$output_path" 2>"$stderr_path"
  local status=$?
  set -e

  if [[ "$status" -ne "$expected_exit" ]]; then
    fail "command exited $status (expected $expected_exit); stderr: $(cat "$stderr_path")"
  fi
}

printf '=== Phase 52: service-surface CLI productization ===\n\n'

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

printf 'Capturing official ACL lifecycle via CLI command...\n'
capture_json_command \
  0 \
  "$ARTIFACT_DIR/oracle_acl_lifecycle.json" \
  "$TMPDIR/oracle-acl-lifecycle.stderr" \
  --network-config "$NETWORK_CONFIG_SRC" \
  acl-lifecycle \
  --json

printf 'Preparing local manytype_server config...\n'
write_local_server_files

printf 'Starting local manytype_server...\n'
start_local_server

printf 'Capturing local consensus bootstrap via CLI command...\n'
capture_json_command \
  0 \
  "$ARTIFACT_DIR/local_consensus_bootstrap.json" \
  "$TMPDIR/local-consensus-bootstrap.stderr" \
  --server "127.0.0.1:${LOCAL_SERVER_PORT}" \
  consensus-bootstrap \
  --state-out "$TMPDIR/local-consensus-state.json" \
  --json

printf 'Restarting local manytype_server for consensus continuation...\n'
start_local_server
capture_json_command \
  0 \
  "$ARTIFACT_DIR/local_consensus_continue.json" \
  "$TMPDIR/local-consensus-continue.stderr" \
  --server "127.0.0.1:${LOCAL_SERVER_PORT}" \
  consensus-continue \
  --state-in "$TMPDIR/local-consensus-state.json" \
  --json

printf 'Capturing local SpacePull bootstrap via CLI command...\n'
capture_json_command \
  0 \
  "$ARTIFACT_DIR/local_space_pull_bootstrap.json" \
  "$TMPDIR/local-space-pull-bootstrap.stderr" \
  --network-config "$LOCAL_NETWORK_CONFIG" \
  --server "127.0.0.1:${LOCAL_SERVER_PORT}" \
  space-pull-bootstrap \
  --state-out "$TMPDIR/local-space-pull-state.json" \
  --json

printf 'Restarting local manytype_server for SpacePull refetch...\n'
start_local_server
capture_json_command \
  0 \
  "$ARTIFACT_DIR/local_space_pull_refetch.json" \
  "$TMPDIR/local-space-pull-refetch.stderr" \
  --server "127.0.0.1:${LOCAL_SERVER_PORT}" \
  space-pull-refetch \
  --state-in "$TMPDIR/local-space-pull-state.json" \
  --json

python3 - \
  "$TOP_LEVEL_ARTIFACT" \
  "$ARTIFACT_DIR/oracle_acl_lifecycle.json" \
  "$ARTIFACT_DIR/local_consensus_bootstrap.json" \
  "$ARTIFACT_DIR/local_consensus_continue.json" \
  "$ARTIFACT_DIR/local_space_pull_bootstrap.json" \
  "$ARTIFACT_DIR/local_space_pull_refetch.json" \
  "$RUNTIME_METADATA_PATH" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    oracle_acl_path,
    local_consensus_bootstrap_path,
    local_consensus_continue_path,
    local_space_pull_bootstrap_path,
    local_space_pull_refetch_path,
    metadata_path,
) = sys.argv[1:]

oracle_acl = json.load(open(oracle_acl_path))
local_consensus_bootstrap = json.load(open(local_consensus_bootstrap_path))
local_consensus_continue = json.load(open(local_consensus_continue_path))
local_space_pull_bootstrap = json.load(open(local_space_pull_bootstrap_path))
local_space_pull_refetch = json.load(open(local_space_pull_refetch_path))

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase52 service-surface cli productization",
    "oracle_acl": {
        "space_id": oracle_acl["space_id"],
        "acl_root_id": oracle_acl["acl_root_id"],
        "invite_record_id": oracle_acl["invite_record_id"],
        "join_record_id": oracle_acl["join_record_id"],
        "accept_record_id": oracle_acl["accept_record_id"],
        "artifact_path": oracle_acl_path,
    },
    "local_consensus": {
        "space_id": local_consensus_bootstrap["space_id"],
        "log_id": local_consensus_bootstrap["log_id"],
        "root_id": local_consensus_bootstrap["root_id"],
        "first_record_id": local_consensus_bootstrap["first_record_id"],
        "second_record_id": local_consensus_continue["second_record_id"],
        "bootstrap_path": local_consensus_bootstrap_path,
        "continue_path": local_consensus_continue_path,
    },
    "local_space_pull": {
        "space_id": local_space_pull_bootstrap["space_id"],
        "acl_root_id": local_space_pull_bootstrap["acl_root_id"],
        "invite_record_id": local_space_pull_bootstrap["invite_record_id"],
        "bootstrap_path": local_space_pull_bootstrap_path,
        "refetch_path": local_space_pull_refetch_path,
    },
    "metadata_path": metadata_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase52 service-surface cli productization" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$TOP_LEVEL_ARTIFACT" \
  "$ARTIFACT_DIR/oracle_acl_lifecycle.json" \
  "$ARTIFACT_DIR/local_consensus_bootstrap.json" \
  "$ARTIFACT_DIR/local_consensus_continue.json" \
  "$ARTIFACT_DIR/local_space_pull_bootstrap.json" \
  "$ARTIFACT_DIR/local_space_pull_refetch.json"

printf 'Runtime metadata written to %s\n' "$RUNTIME_METADATA_PATH"
printf 'Phase 52 artifact written to %s\n' "$TOP_LEVEL_ARTIFACT"
printf 'phase52 harness: PASSED\n'
