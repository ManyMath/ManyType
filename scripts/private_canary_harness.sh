#!/usr/bin/env bash
set -euo pipefail

# Local native-protocol proof only. This exercises the real QUIC FFI, server,
# CRDT, and file paths but deliberately does not claim a ManyTier deployment.

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
artifact_path="${1:-$root_dir/build/private-canary/local-two-home.json}"
fixture="$(mktemp -d "${TMPDIR:-/tmp}/manytype-private-canary.XXXXXX")"
home_a="$fixture/home-a"
home_b="$fixture/home-b"
home_unauthorized="$fixture/home-unauthorized"
server_data="$fixture/server-data"
server_config="$fixture/server.toml"
server_log="$fixture/server.log"
network_config="$fixture/network.yml"
backup_dir="$fixture/server-backup"
server_pid=""

cleanup() {
  if [[ -n "$server_pid" ]]; then
    kill -TERM "$server_pid" >/dev/null 2>&1 || true
    wait "$server_pid" >/dev/null 2>&1 || true
  fi
  if [[ "${KEEP_CANARY_FIXTURE:-0}" == "1" ]]; then
    printf 'Kept canary fixture: %s\n' "$fixture"
  else
    rm -rf "$fixture"
  fi
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

for command in awk cargo cmp curl dart git grep python3 sed shasum; do
  command -v "$command" >/dev/null 2>&1 || fail "$command is required"
done

source_sha="$(git -C "$root_dir" rev-parse HEAD)"
source_tree_clean=true
if [[ -n "$(git -C "$root_dir" status --porcelain)" ]]; then
  source_tree_clean=false
  if [[ "${ALLOW_DIRTY_CANARY_SOURCE:-0}" != "1" ]]; then
    fail "tracked source changes are present; commit them or set ALLOW_DIRTY_CANARY_SOURCE=1 for a development run"
  fi
fi

read -r quic_port health_port < <(python3 - <<'PY'
import socket

with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as udp:
    udp.bind(("127.0.0.1", 0))
    quic = udp.getsockname()[1]
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as tcp:
    tcp.bind(("127.0.0.1", 0))
    health = tcp.getsockname()[1]
print(quic, health)
PY
)

case "$(uname -s)" in
  Darwin) ffi_library="$root_dir/rust/target/release/libmanytype_quic_ffi.dylib" ;;
  Linux) ffi_library="$root_dir/rust/target/release/libmanytype_quic_ffi.so" ;;
  *) fail "unsupported native canary host: $(uname -s)" ;;
esac
server_binary="$root_dir/rust/target/release/manytype_server"

printf 'Building locked native client transport and server...\n'
(cd "$root_dir/rust" &&
  cargo build --release --locked -p manytype_quic_ffi -p manytype_server >/dev/null)
[[ -x "$server_binary" ]] || fail "server binary is missing"
[[ -s "$ffi_library" ]] || fail "native FFI library is missing"
server_binary_sha="$(shasum -a 256 "$server_binary" | awk '{print $1}')"
ffi_library_sha="$(shasum -a 256 "$ffi_library" | awk '{print $1}')"

run_cli() {
  local home="$1"
  shift
  HOME="$home" MANYTYPE_QUIC_FFI_PATH="$ffi_library" \
    dart run "$root_dir/packages/manytype_cli/bin/manytype.dart" "$@"
}

mkdir -p "$home_a" "$home_b" "$home_unauthorized"
run_cli "$home_a" init >/dev/null
mkdir -p "$home_b/.manytype"
cp "$home_a/.manytype/config.toml" "$home_b/.manytype/config.toml"

identity_json="$fixture/identity.json"
HOME="$home_a" dart run \
  "$root_dir/packages/manytype_cli/tool/phase31_identity_dump.dart" \
  --public-only >"$identity_json"
read -r client_peer account_identity space_id < <(python3 - "$identity_json" <<'PY'
import json
import sys

identity = json.load(open(sys.argv[1]))
for forbidden in ("account_seed_hex", "identity_seed_hex"):
    if forbidden in identity:
        raise SystemExit(f"public identity export contains {forbidden}")
print(identity["peer_id"], identity["account_identity_hex"], identity["space_id"])
PY
)

cat >"$server_config" <<EOF
deployment_mode = "private_canary"
network_id = "manytype-local-private-canary"
quic_listen = "127.0.0.1:$quic_port"
health_listen = "127.0.0.1:$health_port"
data_dir = "$server_data"
allowed_peer_ids = ["$client_peer"]
allowed_account_identities = ["$account_identity"]

[limits]
max_connections = 8
max_streams_per_connection = 8
connection_setup_timeout_seconds = 15
stream_setup_timeout_seconds = 10
stream_io_timeout_seconds = 30
max_frame_bytes = 2097152
max_message_bytes = 8388608
max_blob_bytes = 4194304
max_space_storage_bytes = 67108864
max_account_storage_bytes = 67108864
max_total_storage_bytes = 134217728
max_sync_state_bytes = 67108864
max_file_index_bytes = 33554432
EOF

: >"$server_log"
start_server() {
  "$server_binary" serve --config "$server_config" >>"$server_log" 2>&1 &
  server_pid="$!"
  for _ in $(seq 1 100); do
    if ! kill -0 "$server_pid" >/dev/null 2>&1; then
      cat "$server_log" >&2
      fail "server exited before becoming ready"
    fi
    if curl --fail --silent --max-time 1 \
      "http://127.0.0.1:$health_port/readyz" >/dev/null 2>&1; then
      return
    fi
    sleep 0.1
  done
  cat "$server_log" >&2
  fail "server did not become ready"
}

stop_server() {
  if [[ -n "$server_pid" ]]; then
    kill -TERM "$server_pid"
    wait "$server_pid"
    server_pid=""
  fi
}

start_server
server_peer="$(python3 - "$server_log" <<'PY'
import json
import sys

for line in open(sys.argv[1]):
    try:
        event = json.loads(line)
    except json.JSONDecodeError:
        continue
    fields = event.get("fields", event)
    if fields.get("event") == "server_ready":
        print(fields["peer_id"])
        break
PY
)"
[[ -n "$server_peer" ]] || fail "server peer ID was not recorded"

cat >"$network_config" <<EOF
id: local-private-canary
networkId: manytype-local-private-canary
nodes:
  - peerId: $server_peer
    addresses:
      - quic://127.0.0.1:$quic_port
    types:
      - coordinator
      - tree
      - consensus
      - file
EOF

# The network-config path intentionally uses the official multi-node discovery
# flow, whose preflight requires an already-live space. Establish immutable
# ownership once through the single-node private endpoint before exercising the
# network-config path for every synchronized mutation below.
run_cli "$home_a" --server "127.0.0.1:$quic_port" sync \
  >"$fixture/bootstrap-a.txt"

payload="$fixture/canary-attachment.bin"
printf 'ManyType private canary attachment\nline two\n' >"$payload"
payload_sha="$(shasum -a 256 "$payload" | awk '{print $1}')"

run_cli "$home_a" create --as-relation --name attachment --format file \
  >"$fixture/create-relation.txt"
relation_id="$(sed -n 's/^Created [^:]*: //p' "$fixture/create-relation.txt" | head -1)"
[[ -n "$relation_id" ]] || fail "could not parse relation ID"

run_cli "$home_a" create "Canary from device A" >"$fixture/create-target.txt"
object_id="$(sed -n 's/^Created [^:]*: //p' "$fixture/create-target.txt" | head -1)"
[[ -n "$object_id" ]] || fail "could not parse object ID"

run_cli "$home_a" --network-config "$network_config" edit \
  --id "$object_id" --relation attachment --file-relation "$payload" \
  >"$fixture/edit-a.txt"
file_object_id="$(sed -n 's/^FileObject: \([^ ]*\) .*/\1/p' "$fixture/edit-a.txt" | head -1)"
cid="$(sed -n 's/^FileObject: .*cid=\([^,]*\).*/\1/p' "$fixture/edit-a.txt" | head -1)"
[[ -n "$file_object_id" && -n "$cid" ]] || fail "could not parse uploaded file evidence"

run_cli "$home_b" --network-config "$network_config" sync \
  >"$fixture/sync-b.txt"
run_cli "$home_b" read "$object_id" >"$fixture/read-b-initial.txt"
grep -Fq 'Canary from device A' "$fixture/read-b-initial.txt" ||
  fail "device B did not replay device A text"
grep -Fq 'canary-attachment.bin' "$fixture/read-b-initial.txt" ||
  fail "device B did not replay attachment metadata"
download_b="$fixture/download-b.bin"
run_cli "$home_b" --network-config "$network_config" file-open \
  --file-id "$file_object_id" --cid "$cid" --output "$download_b" \
  >"$fixture/open-b.txt"
cmp "$payload" "$download_b" || fail "device B attachment bytes differ"

run_cli "$home_b" --network-config "$network_config" edit \
  --id "$object_id" --text 'Edited on device B' >"$fixture/edit-b.txt"
run_cli "$home_a" --network-config "$network_config" sync \
  >"$fixture/sync-a.txt"
run_cli "$home_a" read "$object_id" >"$fixture/read-a-after-b.txt"
grep -Fq 'Edited on device B' "$fixture/read-a-after-b.txt" ||
  fail "device A did not replay device B text"

stop_server
start_server
run_cli "$home_a" --network-config "$network_config" edit \
  --id "$object_id" --text 'Edited on A after restart' \
  >"$fixture/edit-a-after-restart.txt"
run_cli "$home_b" --network-config "$network_config" sync \
  >"$fixture/sync-b-after-restart.txt"
run_cli "$home_b" read "$object_id" >"$fixture/read-b-after-restart.txt"
grep -Fq 'Edited on A after restart' "$fixture/read-b-after-restart.txt" ||
  fail "device B did not replay the post-restart edit"

run_cli "$home_unauthorized" init >/dev/null
if run_cli "$home_unauthorized" --network-config "$network_config" \
  probe-network >"$fixture/unauthorized.txt" 2>&1; then
  fail "non-allowlisted identity reached the private server"
fi
unauthorized_attempt_sha="$(shasum -a 256 "$fixture/unauthorized.txt" | awk '{print $1}')"

stop_server
"$server_binary" backup --config "$server_config" --output "$backup_dir" \
  >/dev/null
rm -rf "$server_data/sync" "$server_data/files"
"$server_binary" restore --config "$server_config" --input "$backup_dir" \
  --force >/dev/null
start_server

# Recreate B's database rather than trusting its local cache. Its copied
# recovery configuration remains independent from A's home.
rm -f "$home_b/.manytype/store.db" \
  "$home_b/.manytype/store.db-shm" "$home_b/.manytype/store.db-wal"
rm -f "$download_b"
run_cli "$home_b" --network-config "$network_config" sync \
  >"$fixture/sync-b-after-restore.txt"
run_cli "$home_b" read "$object_id" >"$fixture/read-b-after-restore.txt"
grep -Fq 'Edited on A after restart' "$fixture/read-b-after-restore.txt" ||
  fail "fresh device B database did not recover CRDT content after restore"
run_cli "$home_b" --network-config "$network_config" file-open \
  --file-id "$file_object_id" --cid "$cid" --output "$download_b" \
  >"$fixture/open-b-after-restore.txt"
cmp "$payload" "$download_b" ||
  fail "fresh device B database did not recover attachment bytes after restore"
stop_server

ready_events="$(grep -Fc '"event":"server_ready"' "$server_log" || true)"
shutdown_events="$(grep -Fc '"event":"shutdown_complete"' "$server_log" || true)"
[[ "$ready_events" == "3" ]] ||
  fail "expected 3 server_ready events, found $ready_events"
[[ "$shutdown_events" == "3" ]] ||
  fail "expected 3 shutdown_complete events, found $shutdown_events"

mkdir -p "$(dirname "$artifact_path")"
captured_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat >"$artifact_path" <<EOF
{
  "captured_at": "$captured_at",
  "scope": "loopback native QUIC protocol evidence; not a ManyTier deployment",
  "git_sha": "$source_sha",
  "source_tree_clean": $source_tree_clean,
  "server_mode": "private_canary",
  "manytier_network_reachable": false,
  "server_binary_sha256": "$server_binary_sha",
  "ffi_library_sha256": "$ffi_library_sha",
  "space_id": "$space_id",
  "client_peer_id": "$client_peer",
  "account_identity_hex": "$account_identity",
  "server_peer_id": "$server_peer",
  "object_id": "$object_id",
  "relation_id": "$relation_id",
  "file_object_id": "$file_object_id",
  "attachment_cid": "$cid",
  "attachment_sha256": "$payload_sha",
  "unauthorized_attempt_sha256": "$unauthorized_attempt_sha",
  "server_ready_events": $ready_events,
  "shutdown_complete_events": $shutdown_events,
  "checks": {
    "fresh_b_replayed_a_crdt": true,
    "b_attachment_bytes_matched": true,
    "a_replayed_b_crdt": true,
    "client_and_server_restart_replayed_crdt": true,
    "unauthorized_identity_rejected": true,
    "backup_restore_replayed_crdt": true,
    "backup_restore_attachment_bytes_matched": true
  },
  "success": true
}
EOF

printf 'Verified local two-home native canary evidence at %s\n' "$artifact_path"
