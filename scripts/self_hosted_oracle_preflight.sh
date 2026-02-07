#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK_FILE="$ROOT_DIR/docker/any-sync/oracle.lock.env"
ENV_FILE="$ROOT_DIR/docker/any-sync/.env"
CLIENT_YML="$ROOT_DIR/docker/any-sync/etc/client.yml"
FFI_LIB="$ROOT_DIR/rust/target/release/libmanytype_quic_ffi.so"
QUIET=0

for arg in "$@"; do
  case "$arg" in
    --quiet)
      QUIET=1
      ;;
    --help|-h)
      cat <<'EOF'
Usage: self_hosted_oracle_preflight.sh [--quiet]

Validates the repo-owned self-hosted oracle contract before parity harnesses run.
EOF
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "$LOCK_FILE" ]]; then
  printf 'FAIL: missing oracle lock file: %s\n' "$LOCK_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$LOCK_FILE"

log() {
  if [[ "$QUIET" != "1" ]]; then
    printf '%s\n' "$1"
  fi
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing command: $1"
}

env_value() {
  local key="$1"
  sed -n "s/^${key}=//p" "$ENV_FILE" | tail -1 | tr -d '"'
}

require_running_container() {
  local name="$1"
  docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null | grep -Fxq 'true' || \
    fail "required oracle container is not running: $name"
}

require_cmd docker
docker compose version >/dev/null 2>&1 || fail 'docker compose is unavailable'
require_cmd python3
require_cmd sha256sum

[[ -f "$ENV_FILE" ]] || fail "missing docker env file: $ENV_FILE"
[[ -f "$CLIENT_YML" ]] || fail "missing generated client config: $CLIENT_YML"
[[ -s "$CLIENT_YML" ]] || fail "generated client config is empty: $CLIENT_YML"
[[ -f "$FFI_LIB" ]] || fail "missing release FFI library: $FFI_LIB"

grep -q '^networkId:' "$CLIENT_YML" || fail "client.yml is missing networkId: $CLIENT_YML"
grep -q '^nodes:' "$CLIENT_YML" || fail "client.yml is missing nodes: $CLIENT_YML"

if [[ "$ENV_FILE" -nt "$CLIENT_YML" ]]; then
  fail "client.yml is stale relative to docker/any-sync/.env; regenerate the config first"
fi

for key in \
  ANY_SYNC_NODE_VERSION \
  ANY_SYNC_FILENODE_VERSION \
  ANY_SYNC_COORDINATOR_VERSION \
  ANY_SYNC_CONSENSUSNODE_VERSION
do
  expected="${!key}"
  actual="$(env_value "$key")"
  [[ -n "$actual" ]] || fail "missing $key in $ENV_FILE"
  [[ "$actual" == "$expected" ]] || fail "$key=$actual does not match locked value $expected"
done

resolved_image="${ANYTYPE_IMAGE:-$ANYTYPE_CLI_IMAGE}"
docker image inspect "$resolved_image" >/dev/null 2>&1 || \
  fail "official Anytype CLI image is not available locally: $resolved_image"

resolved_digest="$(docker image inspect "$resolved_image" --format '{{join .RepoDigests "\n"}}' | head -1)"
[[ -n "$resolved_digest" ]] || fail "could not resolve repo digest for image: $resolved_image"
[[ "$resolved_digest" == "$ANYTYPE_CLI_IMAGE" ]] || \
  fail "official Anytype CLI digest mismatch: got $resolved_digest expected $ANYTYPE_CLI_IMAGE"

label_version="$(docker image inspect "$resolved_image" --format '{{index .Config.Labels "org.opencontainers.image.version"}}')"
[[ "$label_version" == "$ANYTYPE_CLI_TAG" ]] || \
  fail "official Anytype CLI version mismatch: got $label_version expected $ANYTYPE_CLI_TAG"

label_revision="$(docker image inspect "$resolved_image" --format '{{index .Config.Labels "org.opencontainers.image.revision"}}')"
[[ "$label_revision" == "$ANYTYPE_CLI_REVISION" ]] || \
  fail "official Anytype CLI revision mismatch: got $label_revision expected $ANYTYPE_CLI_REVISION"

for service in \
  any-sync-any-sync-coordinator-1 \
  any-sync-any-sync-filenode-1 \
  any-sync-any-sync-node-1-1 \
  any-sync-any-sync-node-2-1 \
  any-sync-any-sync-node-3-1 \
  any-sync-any-sync-consensusnode-1
do
  require_running_container "$service"
done

client_sha="$(sha256sum "$CLIENT_YML" | awk '{print $1}')"

log 'Self-hosted oracle preflight checks passed:'
log "  lock: $LOCK_FILE"
log "  official-cli: $resolved_digest"
log "  client.yml: $CLIENT_YML ($client_sha)"
log "  ffi: $FFI_LIB"
log 'self_hosted_oracle_preflight: PASSED'
