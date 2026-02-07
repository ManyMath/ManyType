#!/usr/bin/env bash

set -euo pipefail

# Phase 48: narrow service-surface baseline.
#
# Proof surfaces:
#   - self-hosted official Any-Sync: ACL lifecycle later-read proof
#   - local manytype_server: direct consensus reread/restart proof
#   - local manytype_server: SpacePull continuity before and after restart

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase48"
TOP_LEVEL_ARTIFACT="$ARTIFACT_DIR/service-surface-baseline.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"

TMPDIR="$(mktemp -d)"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"
LOCAL_SERVER_CONFIG="$TMPDIR/local-manytype-server.toml"
LOCAL_NETWORK_CONFIG="$TMPDIR/local-network.yml"
LOCAL_SERVER_LOG="$TMPDIR/local-manytype-server.log"
LOCAL_DB_PATH="$TMPDIR/local-manytype-server.redb"
LOCAL_SERVER_BIN="$ROOT_DIR/rust/target/release/manytype_server"
LOCAL_SERVER_PORT=33120
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
identity_seed = "0303030303030303030303030303030303030303030303030303030303030303"
network_id = "manytype-phase48"
EOF

  cat >"$LOCAL_NETWORK_CONFIG" <<EOF
id: local-phase48
networkId: manytype-phase48
nodes:
  - peerId: local-phase48
    addresses:
      - quic://127.0.0.1:${LOCAL_SERVER_PORT}
    types:
      - coordinator
      - tree
      - consensus
EOF
}

printf '=== Phase 48: service-surface baseline ===\n\n'

oracle_run_preflight
mkdir -p "$ARTIFACT_DIR"
rm -f "$TOP_LEVEL_ARTIFACT" "$RUNTIME_METADATA_PATH"
rm -f "$ARTIFACT_DIR"/*.json

oracle_export_runtime_env

printf 'Building release binaries...\n'
(cd "$ROOT_DIR/rust" && cargo build -p manytype_quic_ffi -p manytype_server --release >/dev/null)
[[ -x "$LOCAL_SERVER_BIN" ]] || fail 'manytype_server release binary missing after build'

printf 'Building official probe binary for metadata traceability...\n'
oracle_build_probe_binary "$PROBE_BIN"

printf 'Starting self-hosted official any-sync stack...\n'
oracle_compose_up

printf 'Capturing official-oracle ACL lifecycle proof...\n'
dart run "$ROOT_DIR/packages/manytype_cli/tool/phase48_service_surface_capture.dart" \
  --action oracle-acl \
  --network-config "$NETWORK_CONFIG_SRC" \
  >"$ARTIFACT_DIR/oracle_acl.json"

printf 'Preparing local manytype_server config...\n'
write_local_server_files

printf 'Starting local manytype_server...\n'
start_local_server

printf 'Capturing local consensus bootstrap proof...\n'
dart run "$ROOT_DIR/packages/manytype_cli/tool/phase48_service_surface_capture.dart" \
  --action local-consensus-bootstrap \
  --server-address "127.0.0.1:${LOCAL_SERVER_PORT}" \
  --state-out "$TMPDIR/local-consensus-state.json" \
  >"$ARTIFACT_DIR/local_consensus_bootstrap.json"

printf 'Restarting local manytype_server for consensus continuation proof...\n'
start_local_server
dart run "$ROOT_DIR/packages/manytype_cli/tool/phase48_service_surface_capture.dart" \
  --action local-consensus-continue \
  --server-address "127.0.0.1:${LOCAL_SERVER_PORT}" \
  --state-in "$TMPDIR/local-consensus-state.json" \
  >"$ARTIFACT_DIR/local_consensus_continue.json"

printf 'Capturing local SpacePull bootstrap proof...\n'
dart run "$ROOT_DIR/packages/manytype_cli/tool/phase48_service_surface_capture.dart" \
  --action local-space-pull-bootstrap \
  --network-config "$LOCAL_NETWORK_CONFIG" \
  --server-address "127.0.0.1:${LOCAL_SERVER_PORT}" \
  --state-out "$TMPDIR/local-space-pull-state.json" \
  >"$ARTIFACT_DIR/local_space_pull_bootstrap.json"

printf 'Restarting local manytype_server for SpacePull continuity proof...\n'
start_local_server
dart run "$ROOT_DIR/packages/manytype_cli/tool/phase48_service_surface_capture.dart" \
  --action local-space-pull-refetch \
  --state-in "$TMPDIR/local-space-pull-state.json" \
  >"$ARTIFACT_DIR/local_space_pull_refetch.json"

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase48 service-surface baseline" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$TOP_LEVEL_ARTIFACT" \
  "$ARTIFACT_DIR/oracle_acl.json" \
  "$ARTIFACT_DIR/local_consensus_bootstrap.json" \
  "$ARTIFACT_DIR/local_consensus_continue.json" \
  "$ARTIFACT_DIR/local_space_pull_bootstrap.json" \
  "$ARTIFACT_DIR/local_space_pull_refetch.json"

python3 - \
  "$TOP_LEVEL_ARTIFACT" \
  "$ARTIFACT_DIR/oracle_acl.json" \
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
    "scenario": "phase48 service-surface baseline",
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

printf 'Runtime metadata written to %s\n' "$RUNTIME_METADATA_PATH"
printf 'Phase 48 artifact written to %s\n' "$TOP_LEVEL_ARTIFACT"
printf 'phase48 harness: PASSED\n'
