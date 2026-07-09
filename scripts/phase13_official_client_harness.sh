#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
PORT="${PORT:-33120}"
ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-ghcr.io/anyproto/anytype-cli:latest}"
TMPDIR="$(mktemp -d)"
SERVER_PID=""
CLI_NAME="phase13-anytype-cli-$$"

cleanup() {
  docker rm -f "$CLI_NAME" >/dev/null 2>&1 || true
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  if [[ "${KEEP_TMPDIR:-0}" != "1" ]]; then
    rm -rf "$TMPDIR" >/dev/null 2>&1 || true
  else
    printf 'Kept tempdir: %s\n' "$TMPDIR"
  fi
}
trap cleanup EXIT

printf 'Building manytype_server...\n'
(cd "$RUST_DIR" && cargo build -p manytype_server >/dev/null)

printf 'Writing temporary config in %s...\n' "$TMPDIR"
cat >"$TMPDIR/server.toml" <<EOF
deployment_mode = "development"
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0101010101010101010101010101010101010101010101010101010101010101"
network_id = "manytype-dev"
EOF

mkdir -p "$TMPDIR/cli-root"

printf 'Starting manytype_server on 127.0.0.1:%s...\n' "$PORT"
(
  cd "$RUST_DIR"
  stdbuf -oL -eL ./target/debug/manytype_server "$TMPDIR/server.toml" \
    >"$TMPDIR/server.log" 2>&1
) &
SERVER_PID=$!

for _ in $(seq 1 30); do
  if rg -q 'Listening on QUIC' "$TMPDIR/server.log" \
    && rg -q 'Server peer ID:' "$TMPDIR/server.log"; then
    break
  fi
  sleep 1
done

if ! rg -q 'Listening on QUIC' "$TMPDIR/server.log"; then
  echo "Server did not become ready"
  sed -n '1,160p' "$TMPDIR/server.log" || true
  exit 1
fi

PEER_ID="$(sed -n 's/.*Server peer ID: //p' "$TMPDIR/server.log" | tail -1)"
if [[ -z "$PEER_ID" ]]; then
  echo "Failed to parse server peer ID"
  exit 1
fi

cat >"$TMPDIR/network.yml" <<EOF
id: manytype-v1
networkId: manytype-dev
nodes:
  - peerId: $PEER_ID
    addresses:
      - 127.0.0.1:$PORT
      - quic://127.0.0.1:$PORT
    types:
      - coordinator
  - peerId: $PEER_ID
    addresses:
      - 127.0.0.1:$PORT
      - quic://127.0.0.1:$PORT
    types:
      - tree
  - peerId: $PEER_ID
    addresses:
      - 127.0.0.1:$PORT
      - quic://127.0.0.1:$PORT
    types:
      - file
  - peerId: $PEER_ID
    addresses:
      - 127.0.0.1:$PORT
      - quic://127.0.0.1:$PORT
    types:
      - consensus
EOF

printf 'Starting anytype-cli service container...\n'
docker run -d --name "$CLI_NAME" --network host \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  -v "$TMPDIR/network.yml:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" serve --verbose >/dev/null

sleep 4

printf 'Creating bot account against manytype_server...\n'
docker run --rm --network host \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  -v "$TMPDIR/network.yml:/etc/anytype/network.yml:ro" \
  "$ANYTYPE_IMAGE" auth create manytype-bot \
  --network-config /etc/anytype/network.yml \
  --root-path /root/.anytype >/dev/null

sleep 8

printf 'Listing spaces...\n'
docker run --rm --network host \
  -v "$TMPDIR/cli-root:/root/.anytype" \
  "$ANYTYPE_IMAGE" space list >/dev/null

if ! rg -q 'New connection from' "$TMPDIR/server.log"; then
  echo "Official client never reached the server"
  sed -n '1,200p' "$TMPDIR/server.log"
  exit 1
fi

if ! rg -q 'Credential handshake complete' "$TMPDIR/server.log"; then
  echo "Credential handshake was not observed"
  sed -n '1,220p' "$TMPDIR/server.log"
  exit 1
fi

if ! rg -q 'Proto handshake complete' "$TMPDIR/server.log"; then
  echo "Proto handshake was not observed"
  sed -n '1,220p' "$TMPDIR/server.log"
  exit 1
fi

if ! rg -q 'sync: headsync for' "$TMPDIR/server.log"; then
  echo "HeadSync traffic was not observed"
  sed -n '1,260p' "$TMPDIR/server.log"
  exit 1
fi

if ! rg -q 'sync: received ObjectSyncMessage' "$TMPDIR/server.log"; then
  echo "Object sync traffic was not observed"
  sed -n '1,260p' "$TMPDIR/server.log"
  exit 1
fi

if rg -n 'ERROR manytype_server|unknown method|RPC error|Stream error|Connection error' \
  "$TMPDIR/server.log"; then
  echo "Server log contains interop errors"
  exit 1
fi

printf '\nHarness passed.\n'
printf 'Server peer ID: %s\n' "$PEER_ID"
