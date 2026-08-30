#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK_FILE="$ROOT_DIR/docker/any-sync/oracle.lock.env"
OVERRIDE_FILE="$ROOT_DIR/docker/any-sync/.env.override"
VERSION_KEYS=(
  ANY_SYNC_NODE_VERSION
  ANY_SYNC_FILENODE_VERSION
  ANY_SYNC_COORDINATOR_VERSION
  ANY_SYNC_CONSENSUSNODE_VERSION
)

for arg in "$@"; do
  case "$arg" in
    --help|-h)
      cat <<'EOF'
Usage: self_hosted_oracle_pin.sh

Writes the locked any-sync versions from docker/any-sync/oracle.lock.env into
docker/any-sync/.env.override and pulls the pinned official Anytype CLI image.
Run it before `make start` so the stack matches self_hosted_oracle_preflight.sh.
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

command -v docker >/dev/null 2>&1 || {
  printf 'FAIL: missing command: docker\n' >&2
  exit 1
}

# Keep any local overrides; only the locked version keys are replaced.
tmp_override="$(mktemp)"
trap 'rm -f "$tmp_override"' EXIT
if [[ -f "$OVERRIDE_FILE" ]]; then
  key_pattern="$(IFS='|'; printf '%s' "${VERSION_KEYS[*]}")"
  grep -Ev "^(${key_pattern})=" "$OVERRIDE_FILE" >"$tmp_override" || true
fi
for key in "${VERSION_KEYS[@]}"; do
  printf '%s=%s\n' "$key" "${!key}" >>"$tmp_override"
done
cp "$tmp_override" "$OVERRIDE_FILE"
printf 'Pinned any-sync versions in %s\n' "$OVERRIDE_FILE"

if ! docker image inspect "$ANYTYPE_CLI_IMAGE" >/dev/null 2>&1; then
  docker pull --quiet "$ANYTYPE_CLI_IMAGE" >/dev/null
fi
printf 'Official Anytype CLI image available: %s\n' "$ANYTYPE_CLI_IMAGE"
