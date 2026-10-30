#!/usr/bin/env bash
# Run an anytype SDK sync program against a task-owned loopback server.
#
#   scripts/sdk_loopback.sh <project-dir> <entrypoint.dart>
#
# Builds manytype_server from this repository, starts it on a free
# 127.0.0.1 port with a throwaway database, writes a network config that
# points every node type at it, and runs
# `dart run <entrypoint> <network.yml>` from <project-dir>. The program
# loads the QUIC bridge however that project provides it. The server is a
# local test service, so passing is loopback evidence only, not
# compatibility evidence against an official Any-Sync deployment.
set -euo pipefail

if [[ $# -ne 2 ]]; then
  printf 'usage: %s <project-dir> <entrypoint.dart>\n' "$0" >&2
  exit 64
fi
PROJECT_DIR="$(cd "$1" && pwd)"
ENTRYPOINT="$2"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_TARGET_DIR="$(
  cd "$ROOT_DIR/rust"
  cargo metadata --locked --no-deps --format-version 1 |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["target_directory"])'
)"

WORK_DIR="$(mktemp -d)"
SERVER_PID=""
cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

(cd "$ROOT_DIR/rust" && cargo build --locked -p manytype_server --bin manytype_server)

PORT="$(python3 -c 'import socket; s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])')"
# The health listener defaults to a fixed port; a concurrent run on the same
# host would collide with it.
HEALTH_PORT="$(python3 -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])')"
NETWORK_ID="anytype-sdk-loopback"
cat >"$WORK_DIR/server.toml" <<EOF
deployment_mode = "development"
quic_listen = "127.0.0.1:$PORT"
health_listen = "127.0.0.1:$HEALTH_PORT"
db_path = "$WORK_DIR/server.redb"
identity_seed = "$(python3 -c 'import secrets; print(secrets.token_hex(32))')"
network_id = "$NETWORK_ID"
EOF

"$RUST_TARGET_DIR/debug/manytype_server" "$WORK_DIR/server.toml" >"$WORK_DIR/server.log" 2>&1 &
SERVER_PID=$!
PEER_ID=""
for _ in $(seq 1 30); do
  if PEER_ID="$(python3 "$ROOT_DIR/scripts/read_server_ready.py" "$WORK_DIR/server.log" 2>/dev/null)"; then
    break
  fi
  sleep 1
done
if [[ -z "$PEER_ID" ]]; then
  printf 'manytype_server did not become ready\n' >&2
  sed -n '1,100p' "$WORK_DIR/server.log" >&2 || true
  exit 1
fi

{
  printf 'id: %s\nnetworkId: %s\nnodes:\n' "$NETWORK_ID" "$NETWORK_ID"
  for node_type in coordinator tree file consensus; do
    printf '  - peerId: %s\n    addresses:\n      - 127.0.0.1:%s\n    types:\n      - %s\n' \
      "$PEER_ID" "$PORT" "$node_type"
  done
} >"$WORK_DIR/network.yml"

printf 'manytype_server %s listening on 127.0.0.1:%s\n' "$PEER_ID" "$PORT"
(cd "$PROJECT_DIR" && dart run "$ENTRYPOINT" "$WORK_DIR/network.yml")
