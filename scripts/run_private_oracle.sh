#!/usr/bin/env bash
# Manual oracle lane: all daemon, source, data and process state belongs to this run.
set -euo pipefail
: "${RUNNER_TEMP:?Run on the dedicated private oracle runner}"
: "${PRIMARY_SERVER:?Primary forge identity is required}"
test "$PRIMARY_SERVER" = https://git.manymath.com
for tool in dockerd-rootless.sh docker rustup flutter dart python3 git; do
  command -v "$tool" >/dev/null
done
rustup run 1.94.0 rustc --version
# No connection to the user's default Docker daemon is made.
unset DOCKER_CONTEXT DOCKER_TLS_VERIFY DOCKER_CERT_PATH
oracle_state="$(mktemp -d "$RUNNER_TEMP/manytype-oracle.XXXXXXXX")"
chmod 700 "$oracle_state"
export DOCKER_HOST="unix://$oracle_state/docker.sock"
export DOCKER_CONFIG="$oracle_state/docker-config"
export XDG_RUNTIME_DIR="$oracle_state/runtime"
mkdir -m 700 "$DOCKER_CONFIG" "$XDG_RUNTIME_DIR" "$oracle_state/source"
server_pid= daemon_pid= server_identity= daemon_identity=

pid_identity() {
  python3 - "$1" <<'PY'
from pathlib import Path
import sys
try:
    fields = Path(f'/proc/{int(sys.argv[1])}/stat').read_text().rsplit(')', 1)[1].split()
    print(fields[1] + ':' + fields[19])  # parent PID and kernel start time
except (FileNotFoundError, ProcessLookupError):
    pass
PY
}
stop_owned_child() {
  local pid="$1" identity="$2" current
  [[ -n "$pid" && -n "$identity" ]] || return 0
  current="$(pid_identity "$pid")"
  [[ "$current" = "$identity" && "${current%%:*}" = "$$" ]] || return 0
  kill -TERM "$pid" 2>/dev/null || true
  for _ in $(seq 1 10); do
    current="$(pid_identity "$pid")"
    [[ "$current" = "$identity" ]] || break
    sleep 1
  done
  if [[ "$(pid_identity "$pid")" = "$identity" ]]; then
    kill -KILL "$pid" 2>/dev/null || true
  fi
  wait "$pid" 2>/dev/null || true
}
cleanup() {
  local status=$?
  trap - EXIT INT TERM
  stop_owned_child "$server_pid" "$server_identity"
  stop_owned_child "$daemon_pid" "$daemon_identity"
  printf 'Private oracle state and logs retained at %s\n' "$oracle_state"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# A fresh daemon and fresh source snapshot prevent global container-name and
# bind-mounted storage collisions with any existing user oracle stack.
dockerd-rootless.sh --host "$DOCKER_HOST" --data-root "$oracle_state/docker-data" \
  --exec-root "$oracle_state/docker-exec" --pidfile "$oracle_state/dockerd.pid" \
  >"$oracle_state/docker.log" 2>&1 &
daemon_pid=$!
daemon_identity="$(pid_identity "$daemon_pid")"
for _ in $(seq 1 60); do
  if docker info >/dev/null 2>&1; then break; fi
  test "$(pid_identity "$daemon_pid")" = "$daemon_identity"
  sleep 1
done
docker info >/dev/null
# Fail closed if the socket unexpectedly resolves to a reused daemon.
test "$(docker info --format '{{.DockerRootDir}}')" = "$oracle_state/docker-data"
test -z "$(docker ps -aq)"
test -z "$(docker volume ls -q)"
repo_root="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)"
git -C "$repo_root" archive HEAD | tar -x -C "$oracle_state/source"
cd "$oracle_state/source"
export RUSTUP_TOOLCHAIN=1.94.0
export CARGO_HOME="$oracle_state/cargo"
export CARGO_BUILD_JOBS=3
export DASH__SUPPRESS_ANALYTICS=true FLUTTER_SUPPRESS_ANALYTICS=true
cargo build --locked --release --manifest-path rust/Cargo.toml -p manytype_quic_ffi -p manytype_server
flutter pub get --enforce-lockfile
bash scripts/self_hosted_oracle_pin.sh
(cd docker/any-sync && make -s start)
for _ in $(seq 1 60); do
  status="$(docker inspect -f '{{.State.Health.Status}}' any-sync-netcheck-1 2>/dev/null || true)"
  [[ "$status" = healthy ]] && break
  sleep 10
done
test "$status" = healthy
bash scripts/self_hosted_oracle_preflight.sh
(cd rust && exec ./target/release/manytype_server manytype_server/test_config.toml) \
  >"$oracle_state/server.log" 2>&1 &
server_pid=$!
server_identity="$(pid_identity "$server_pid")"
for _ in $(seq 1 30); do
  if python3 scripts/read_server_ready.py "$oracle_state/server.log" >/dev/null 2>&1; then break; fi
  test "$(pid_identity "$server_pid")" = "$server_identity"
  sleep 1
done
python3 scripts/read_server_ready.py "$oracle_state/server.log"
export LD_LIBRARY_PATH="$PWD/rust/target/release"
dart run melos run test:oracle --no-select
# No compose down --volumes: stopping our daemon leaves only this run's data.
