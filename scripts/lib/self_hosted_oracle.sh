#!/usr/bin/env bash

set -euo pipefail

ORACLE_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ORACLE_LOCK_FILE="$ORACLE_ROOT_DIR/docker/any-sync/oracle.lock.env"
ORACLE_PREFLIGHT="$ORACLE_ROOT_DIR/scripts/self_hosted_oracle_preflight.sh"
ORACLE_COMPOSE_DIR="$ORACLE_ROOT_DIR/docker/any-sync"
ORACLE_NETWORK_CONFIG="$ORACLE_ROOT_DIR/docker/any-sync/etc/client.yml"
ORACLE_FFI_LIB="$ORACLE_ROOT_DIR/rust/target/release/libmanytype_quic_ffi.so"

# shellcheck disable=SC1090
source "$ORACLE_LOCK_FILE"

ORACLE_ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-$ANYTYPE_CLI_IMAGE}"

oracle_fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

oracle_run_preflight() {
  bash "$ORACLE_PREFLIGHT" --quiet
}

oracle_export_runtime_env() {
  export LD_LIBRARY_PATH="$ORACLE_ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
}

oracle_compose_up() {
  (cd "$ORACLE_COMPOSE_DIR" && docker compose up -d >/dev/null)
}

oracle_compose_ip() {
  local service="$1"
  (cd "$ORACLE_COMPOSE_DIR" && docker compose ps -q "$service" | xargs docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
}

oracle_populate_add_host_args() {
  local -n target="$1"
  target=(
    --add-host "any-sync-node-1:$(oracle_compose_ip any-sync-node-1)"
    --add-host "any-sync-node-2:$(oracle_compose_ip any-sync-node-2)"
    --add-host "any-sync-node-3:$(oracle_compose_ip any-sync-node-3)"
    --add-host "any-sync-coordinator:$(oracle_compose_ip any-sync-coordinator)"
    --add-host "any-sync-filenode:$(oracle_compose_ip any-sync-filenode)"
    --add-host "any-sync-consensusnode:$(oracle_compose_ip any-sync-consensusnode)"
  )
}

oracle_run_cli() {
  local home="$1"
  shift
  HOME="$home" dart run "$ORACLE_ROOT_DIR/packages/manytype_cli/bin/manytype.dart" "$@"
}

oracle_seed_live_space() {
  local home="$1"
  local network_config="$2"
  local wait_seconds="${3:-10}"
  HOME="$home" dart run "$ORACLE_ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
    --network-config "$network_config" \
    --wait-seconds "$wait_seconds" >/dev/null
}

oracle_identity_json() {
  local home="$1"
  HOME="$home" dart run "$ORACLE_ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart"
}

oracle_json_file_field() {
  local file="$1"
  local key="$2"
  python3 - "$file" "$key" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1]))
value = data.get(sys.argv[2], "")
if value is None:
    value = ""
print(value)
PY
}

oracle_json_stdin_field() {
  local key="$1"
  python3 -c '
import json
import sys

data = json.load(sys.stdin)
value = data.get(sys.argv[1], "")
if value is None:
    value = ""
print(value)
' "$key"
}

oracle_generate_invite_json() {
  local account_seed_hex="$1"
  local space_id="$2"
  local space_name="$3"
  local creator_name="$4"
  local output_path="$5"
  (cd "$ORACLE_ROOT_DIR/scripts/phase31_invite_gen" && go run . \
    --account-seed-hex "$account_seed_hex" \
    --space-id "$space_id" \
    --space-name "$space_name" \
    --creator-name "$creator_name") >"$output_path"
}

oracle_generate_invite_from_home() {
  local home="$1"
  local space_name="$2"
  local creator_name="$3"
  local output_path="$4"
  local identity_json
  identity_json="$(oracle_identity_json "$home")"
  local space_id
  local account_seed_hex
  space_id="$(printf '%s' "$identity_json" | oracle_json_stdin_field space_id)"
  account_seed_hex="$(printf '%s' "$identity_json" | oracle_json_stdin_field account_seed_hex)"
  oracle_generate_invite_json "$account_seed_hex" "$space_id" "$space_name" "$creator_name" "$output_path"
}

oracle_publish_invite() {
  local home="$1"
  local network_config="$2"
  local invite_json="$3"
  local output_path="$4"
  local permissions="${5:-writer}"
  HOME="$home" dart run "$ORACLE_ROOT_DIR/packages/manytype_cli/tool/phase31_space_invite_publish.dart" \
    --network-config "$network_config" \
    --invite-json "$invite_json" \
    --permissions "$permissions" >"$output_path"
}

oracle_invite_url_from_json() {
  local file="$1"
  oracle_json_file_field "$file" invite_url
}

oracle_build_probe_binary() {
  local output_path="$1"
  (cd "$ORACLE_ROOT_DIR/scripts/official_client_grpc_probe" && go build -o "$output_path" .)
}

oracle_wait_for_tcp() {
  local host="$1"
  local port="$2"
  local attempts="${3:-30}"
  local delay="${4:-1}"
  local i
  for i in $(seq 1 "$attempts"); do
    if (echo >/dev/tcp/"$host"/"$port") >/dev/null 2>&1; then
      return 0
    fi
    sleep "$delay"
  done
  return 1
}

oracle_wait_for_grpc() {
  oracle_wait_for_tcp 127.0.0.1 31010 "${1:-30}" "${2:-1}"
}

oracle_run_official_cli() {
  local official_root="$1"
  local network_yml="$2"
  local add_host_args_name="$3"
  shift 3
  local -n add_host_args="$add_host_args_name"
  docker run --rm --network host "${add_host_args[@]}" \
    -v "$official_root:/root/.anytype" \
    -v "$network_yml:/etc/anytype/network.yml:ro" \
    "$ORACLE_ANYTYPE_IMAGE" "$@"
}

oracle_start_cli_service() {
  local cli_name="$1"
  local official_root="$2"
  local network_yml="$3"
  local add_host_args_name="$4"
  local extra_docker_args_name="${5:-}"
  local -n add_host_args="$add_host_args_name"
  local extra_docker_args=()
  if [[ -n "$extra_docker_args_name" ]]; then
    local -n extra_docker_args_ref="$extra_docker_args_name"
    extra_docker_args=("${extra_docker_args_ref[@]}")
  fi
  docker rm -f "$cli_name" >/dev/null 2>&1 || true
  docker run -d --name "$cli_name" --network host "${add_host_args[@]}" \
    "${extra_docker_args[@]}" \
    -v "$official_root:/root/.anytype" \
    -v "$network_yml:/etc/anytype/network.yml:ro" \
    "$ORACLE_ANYTYPE_IMAGE" serve --verbose --listen-address 0.0.0.0:31010 >/dev/null
}

oracle_fix_official_config_permissions() {
  local official_root="$1"
  docker run --rm --entrypoint sh \
    -v "$official_root:/root/.anytype" \
    "$ORACLE_ANYTYPE_IMAGE" -lc 'chmod 644 /root/.anytype/config.json' >/dev/null
}

oracle_create_official_account() {
  local official_root="$1"
  local network_yml="$2"
  local add_host_args_name="$3"
  local account_name="$4"
  local output
  output="$(
    oracle_run_official_cli "$official_root" "$network_yml" "$add_host_args_name" \
      auth create "$account_name" \
      --network-config /etc/anytype/network.yml \
      --root-path /root/.anytype
  )"
  local account_key
  account_key="$(printf '%s\n' "$output" | grep -oE '[A-Za-z0-9+/]{20,}={0,2}' | head -1)"
  [[ -n "$account_key" ]] || oracle_fail "could not parse account key from auth create output"
  oracle_fix_official_config_permissions "$official_root"
  printf '%s\n' "$account_key"
}

oracle_wait_for_cli_session() {
  local official_root="$1"
  local network_yml="$2"
  local add_host_args_name="$3"
  local attempts="${4:-30}"
  local delay="${5:-1}"
  local i
  for i in $(seq 1 "$attempts"); do
    if oracle_run_official_cli "$official_root" "$network_yml" "$add_host_args_name" space list >/dev/null 2>&1; then
      return 0
    fi
    sleep "$delay"
  done
  return 1
}

oracle_create_official_api_key() {
  local official_root="$1"
  local network_yml="$2"
  local add_host_args_name="$3"
  local label="$4"
  oracle_run_official_cli "$official_root" "$network_yml" "$add_host_args_name" auth apikey create "$label"
}

oracle_run_probe_binary() {
  local probe_binary="$1"
  local official_root="$2"
  local action="$3"
  shift 3
  "$probe_binary" \
    --config "$official_root/config.json" \
    --grpc-addr 127.0.0.1:31010 \
    --timeout "${PROBE_TIMEOUT:-180s}" \
    --action "$action" \
    "$@"
}

oracle_write_metadata() {
  local output_path="$1"
  local scenario="$2"
  local network_config="$3"
  local probe_binary="$4"
  shift 4
  local args=(
    --output "$output_path"
    --scenario "$scenario"
    --network-config "$network_config"
    --image "$ORACLE_ANYTYPE_IMAGE"
  )
  if [[ -n "$probe_binary" ]]; then
    args+=(--probe-binary "$probe_binary")
  fi
  local artifact
  for artifact in "$@"; do
    args+=(--artifact "$artifact")
  done
  python3 "$ORACLE_ROOT_DIR/scripts/self_hosted_oracle_metadata.py" "${args[@]}"
}
