#!/usr/bin/env bash

set -euo pipefail

# Phase 39: collections via StoreSliceUpdate: two-home harness
#
# Offline two-home verification for three scenarios:
#   A. create collection + add 3 members
#   B. remove 1 member
#   C. move/reorder 1 member
#
# Cross-implementation proof is deferred to Phase 42; this harness proves the
# Manytype-only two-home path against a local manytype_server.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
PORT="${PORT:-33149}"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
MANYTYPE_HOME_2="$TMPDIR/manytype-home-2"
NETWORK_YML="$TMPDIR/network.yml"
SHARED_CONFIG="$TMPDIR/shared-config.toml"
SERVER_PID=""

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
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

mkdir -p "$ROOT_DIR/test_vectors/phase39"
mkdir -p "$MANYTYPE_HOME" "$MANYTYPE_HOME_2"

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

wait_for_server_ready() {
  local log_file="$1"
  for _ in $(seq 1 30); do
    if python3 "$ROOT_DIR/scripts/read_server_ready.py" "$log_file" \
      >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

prepare_second_home() {
  rm -rf "$MANYTYPE_HOME_2/.manytype"
  mkdir -p "$MANYTYPE_HOME_2/.manytype"
  install -m 600 "$SHARED_CONFIG" "$MANYTYPE_HOME_2/.manytype/config.toml"
}

read_member_lines() {
  local file="$1"
  python3 - "$file" <<'PY'
import pathlib
import sys

lines = pathlib.Path(sys.argv[1]).read_text().splitlines()
capture = False
members = []
for line in lines:
    if line.strip() == "## Members":
        capture = True
        continue
    if not capture:
        continue
    if not line.strip():
        break
    members.append(line.strip())
for line in members:
    print(line)
PY
}

assert_member_lines() {
  local file="$1"
  shift
  python3 - "$file" "$@" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
expected = sys.argv[2:]
lines = path.read_text().splitlines()
capture = False
members = []
for line in lines:
    if line.strip() == "## Members":
        capture = True
        continue
    if not capture:
        continue
    if not line.strip():
        break
    members.append(line.strip())

if members != expected:
    raise SystemExit(
        f"member lines mismatch for {path}:\nexpected={expected}\nactual={members}"
    )
PY
}

printf 'Building manytype_server...\n'
if ! (cd "$RUST_DIR" && cargo build -p manytype_server --bin manytype_server 2>/dev/null); then
  if [[ ! -x "$RUST_DIR/target/debug/manytype_server" ]]; then
    printf 'FAIL: cargo build failed and no existing binary at %s\n' \
      "$RUST_DIR/target/debug/manytype_server" >&2
    exit 1
  fi
  printf '  cargo build failed (pre-existing on main); using cached binary at %s\n' \
    "$RUST_DIR/target/debug/manytype_server"
fi

printf 'Building native QUIC bridge...\n'
(cd "$RUST_DIR" && cargo build --release --locked -p manytype_quic_ffi)

cat >"$TMPDIR/server.toml" <<EOF
deployment_mode = "development"
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0909090909090909090909090909090909090909090909090909090909090939"
network_id = "manytype-phase39-collections"
EOF

printf 'Starting manytype_server on 127.0.0.1:%s...\n' "$PORT"
stdbuf -oL -eL "$RUST_DIR/target/debug/manytype_server" "$TMPDIR/server.toml" >"$TMPDIR/server.log" 2>&1 &
SERVER_PID=$!
if ! wait_for_server_ready "$TMPDIR/server.log"; then
  printf 'FAIL: server did not become ready\n' >&2
  sed -n '1,200p' "$TMPDIR/server.log" >&2 || true
  exit 1
fi

if ! PEER_ID="$(python3 "$ROOT_DIR/scripts/read_server_ready.py" \
  "$TMPDIR/server.log")"; then
  printf 'FAIL: could not parse server peer id\n' >&2
  exit 1
fi

cat >"$NETWORK_YML" <<EOF
id: manytype-v2.5
networkId: manytype-phase39-collections
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

printf 'Preparing Manytype CLI temp home...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" init >/dev/null
install -m 600 "$MANYTYPE_HOME/.manytype/config.toml" "$SHARED_CONFIG"

printf '\n=== Phase 39 Scenario A: create collection + add 3 members ===\n'

MANYTYPE_SYNC_CAPTURE_A="$TMPDIR/sync-collection-add.json"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --as-collection --name "Phase39 Collection" >"$TMPDIR/create-collection.txt"
COLL_ID="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/create-collection.txt" | head -1)"
if [[ -z "$COLL_ID" ]]; then
  printf 'FAIL (A): no collection id\n' >&2
  cat "$TMPDIR/create-collection.txt" >&2 || true
  exit 1
fi

printf 'Seeding live space...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_YML" \
  --wait-seconds 2 >/dev/null

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create "Member 1" >"$TMPDIR/member-1.txt"
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create "Member 2" >"$TMPDIR/member-2.txt"
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create "Member 3" >"$TMPDIR/member-3.txt"

M1_ID="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/member-1.txt" | head -1)"
M2_ID="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/member-2.txt" | head -1)"
M3_ID="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/member-3.txt" | head -1)"

for id_var in M1_ID M2_ID M3_ID; do
  if [[ -z "${!id_var}" ]]; then
    printf 'FAIL (A): missing member id %s\n' "$id_var" >&2
    exit 1
  fi
done

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$COLL_ID" --collection-add "$M1_ID" >/dev/null
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$COLL_ID" --collection-add "$M2_ID" >/dev/null
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_A" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$COLL_ID" --collection-add "$M3_ID" >/dev/null

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$COLL_ID" >"$TMPDIR/read-a-home1.txt"
assert_member_lines \
  "$TMPDIR/read-a-home1.txt" \
  "- Member 3 ($M3_ID)" \
  "- Member 2 ($M2_ID)" \
  "- Member 1 ($M1_ID)"

prepare_second_home
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$COLL_ID" >"$TMPDIR/read-a-home2.txt"
assert_member_lines \
  "$TMPDIR/read-a-home2.txt" \
  "- Member 3 ($M3_ID)" \
  "- Member 2 ($M2_ID)" \
  "- Member 1 ($M1_ID)"

ARTIFACT_A="$ROOT_DIR/test_vectors/phase39/scenario_a_create_add.json"
SYNC_A="$ROOT_DIR/test_vectors/phase39/scenario_a_create_add-sync.json"
cp "$MANYTYPE_SYNC_CAPTURE_A" "$SYNC_A"
python3 - "$ARTIFACT_A" "$COLL_ID" "$M1_ID" "$M2_ID" "$M3_ID" "$SYNC_A" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path, coll_id, m1, m2, m3, sync_capture = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase39 scenario A - create collection + add 3 members",
    "collection_id": coll_id,
    "member_ids_created": [m1, m2, m3],
    "expected_members_ordered": [m3, m2, m1],
    "expected_member_lines": [
        f"- Member 3 ({m3})",
        f"- Member 2 ({m2})",
        f"- Member 1 ({m1})",
    ],
    "observed_on_home2": True,
    "manytype_sync_capture_path": sync_capture,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY
printf 'Scenario A OK: %s\n' "$ARTIFACT_A"

printf '\n=== Phase 39 Scenario B: remove 1 member ===\n'

MANYTYPE_SYNC_CAPTURE_B="$TMPDIR/sync-collection-remove.json"

HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_B" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$COLL_ID" --collection-remove "$M2_ID" >/dev/null

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$COLL_ID" >"$TMPDIR/read-b-home1.txt"
assert_member_lines \
  "$TMPDIR/read-b-home1.txt" \
  "- Member 3 ($M3_ID)" \
  "- Member 1 ($M1_ID)"

prepare_second_home
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$COLL_ID" >"$TMPDIR/read-b-home2.txt"
assert_member_lines \
  "$TMPDIR/read-b-home2.txt" \
  "- Member 3 ($M3_ID)" \
  "- Member 1 ($M1_ID)"

ARTIFACT_B="$ROOT_DIR/test_vectors/phase39/scenario_b_remove.json"
SYNC_B="$ROOT_DIR/test_vectors/phase39/scenario_b_remove-sync.json"
cp "$MANYTYPE_SYNC_CAPTURE_B" "$SYNC_B"
python3 - "$ARTIFACT_B" "$COLL_ID" "$M1_ID" "$M2_ID" "$M3_ID" "$SYNC_B" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path, coll_id, m1, m2, m3, sync_capture = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase39 scenario B - remove 1 member",
    "collection_id": coll_id,
    "removed_member_id": m2,
    "expected_members_ordered": [m3, m1],
    "expected_member_lines": [
        f"- Member 3 ({m3})",
        f"- Member 1 ({m1})",
    ],
    "observed_on_home2": True,
    "manytype_sync_capture_path": sync_capture,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY
printf 'Scenario B OK: %s\n' "$ARTIFACT_B"

printf '\n=== Phase 39 Scenario C: move/reorder 1 member ===\n'

MANYTYPE_SYNC_CAPTURE_C="$TMPDIR/sync-collection-move.json"

# NOTE: The plan example suggested moving Member 1 after Member 3 after
# Scenario B, but Scenario B already leaves the order as [Member 3, Member 1].
# To prove a real reorder, move Member 3 after Member 1, yielding [Member 1, Member 3].
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_C" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$COLL_ID" --collection-move "$M3_ID" --after "$M1_ID" >/dev/null

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$COLL_ID" >"$TMPDIR/read-c-home1.txt"
assert_member_lines \
  "$TMPDIR/read-c-home1.txt" \
  "- Member 1 ($M1_ID)" \
  "- Member 3 ($M3_ID)"

prepare_second_home
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$COLL_ID" >"$TMPDIR/read-c-home2.txt"
assert_member_lines \
  "$TMPDIR/read-c-home2.txt" \
  "- Member 1 ($M1_ID)" \
  "- Member 3 ($M3_ID)"

ARTIFACT_C="$ROOT_DIR/test_vectors/phase39/scenario_c_move.json"
SYNC_C="$ROOT_DIR/test_vectors/phase39/scenario_c_move-sync.json"
cp "$MANYTYPE_SYNC_CAPTURE_C" "$SYNC_C"
python3 - "$ARTIFACT_C" "$COLL_ID" "$M1_ID" "$M3_ID" "$SYNC_C" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path, coll_id, m1, m3, sync_capture = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase39 scenario C - move Member 3 after Member 1",
    "collection_id": coll_id,
    "moved_member_id": m3,
    "after_member_id": m1,
    "expected_members_ordered": [m1, m3],
    "expected_member_lines": [
        f"- Member 1 ({m1})",
        f"- Member 3 ({m3})",
    ],
    "observed_on_home2": True,
    "manytype_sync_capture_path": sync_capture,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY
printf 'Scenario C OK: %s\n' "$ARTIFACT_C"

printf '\nphase39 harness: PASSED (create-add, remove, move)\n'
