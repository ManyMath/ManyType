#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rust_dir="$(cd "$script_dir/../.." && pwd)"
binary="${1:-$rust_dir/target/release/manytype_server}"
fixture="$(mktemp -d "$script_dir/.test-fixture.XXXXXX")"
server_pid=""

cleanup() {
  if [[ -n "$server_pid" ]]; then
    kill -TERM "$server_pid" >/dev/null 2>&1 || true
    wait "$server_pid" >/dev/null 2>&1 || true
  fi
  rm -rf "$fixture"
}
trap cleanup EXIT

for command in curl grep sed; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "$command is required for deployment validation" >&2
    exit 1
  }
done
[[ -x "$binary" ]] || {
  echo "release binary is missing: $binary" >&2
  exit 1
}

peer_one="12D3KooWGHMiFc5JJNpGWJxaqUd7ozGQASZz2TU9PwfGGjqjrc5J"
account="0303030303030303030303030303030303030303030303030303030303030303"
base_port=$((43000 + ($$ % 1000) * 2))
quic_port="$base_port"
health_port=$((base_port + 1))
data_dir="$fixture/data"
escaped_data_dir="${data_dir//\//\\/}"
config="$fixture/server.toml"

sed \
  -e "s/DATA_DIR/$escaped_data_dir/g" \
  -e "s/ACCOUNT_DEVICE_PEER_ID/$peer_one/g" \
  -e "s/ACCOUNT_IDENTITY_HEX/$account/g" \
  -e "s/0.0.0.0:33020/127.0.0.1:$quic_port/g" \
  -e "s/127.0.0.1:33021/127.0.0.1:$health_port/g" \
  "$script_dir/server.toml.example" >"$config"

"$binary" check-config --config "$config" | grep -Fq 'configuration valid'
sed 's/deployment_mode = "private_canary"/deployment_mode = "production"/' \
  "$config" >"$fixture/production.toml"
if "$binary" check-config --config "$fixture/production.toml" >/dev/null 2>&1; then
  echo "production configuration was accepted" >&2
  exit 1
fi

grep -Fq 'StateDirectoryMode=0700' "$script_dir/manytype-server.service"
grep -Fq 'UMask=0077' "$script_dir/manytype-server.service"
grep -Fq 'NoNewPrivileges=true' "$script_dir/manytype-server.service"
grep -Fq 'ProtectSystem=strict' "$script_dir/manytype-server.service"
grep -Fq 'CapabilityBoundingSet=' "$script_dir/manytype-server.service"
if command -v systemd-analyze >/dev/null 2>&1; then
  systemd-analyze verify "$script_dir/manytype-server.service" >/dev/null
fi

log="$fixture/server.log"
"$binary" serve --config "$config" >"$log" 2>&1 &
server_pid=$!
ready=0
for _ in $(seq 1 50); do
  if curl --fail --silent --output "$fixture/ready.json" \
    --max-time 2 "http://127.0.0.1:$health_port/readyz"; then
    ready=1
    break
  fi
  sleep 0.1
done
if [[ "$ready" != "1" ]]; then
  cat "$log" >&2
  echo "server did not become ready" >&2
  exit 1
fi

test "$(cat "$fixture/ready.json")" = '{"status":"ready"}'
test "$(curl --fail --silent "http://127.0.0.1:$health_port/healthz")" = '{"status":"ok"}'
test "$(curl --silent --output /dev/null --write-out '%{http_code}' \
  "http://127.0.0.1:$health_port/config")" = "404"
grep -Fq '"event":"server_ready"' "$log"
test "$(wc -c <"$data_dir/identity.key" | tr -d '[:space:]')" = "32"
if stat -f '%Lp' "$data_dir/identity.key" >/dev/null 2>&1; then
  test "$(stat -f '%Lp' "$data_dir/identity.key")" = "600"
else
  test "$(stat -c '%a' "$data_dir/identity.key")" = "600"
fi
if "$binary" backup --config "$config" --output "$fixture/live-backup" >/dev/null 2>&1; then
  echo "backup succeeded while the server held the data lock" >&2
  exit 1
fi

kill -TERM "$server_pid"
wait "$server_pid"
server_pid=""
grep -Fq '"event":"shutdown_complete"' "$log"

"$binary" backup --config "$config" --output "$fixture/backup" \
  | grep -Fq 'backup created'
test -f "$fixture/backup/manifest.json"
test ! -e "$fixture/backup/identity.key"
rm -rf "$data_dir/sync" "$data_dir/files"
"$binary" restore --config "$config" --input "$fixture/backup" --force \
  | grep -Fq 'backup restored'
test -f "$data_dir/sync/global.redb"
test -f "$data_dir/files/files.redb"

echo "Verified fail-closed config, health, graceful shutdown, locking, backup, and restore."
