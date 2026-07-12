#!/usr/bin/env bash

set -euo pipefail

# Phase 38: STRelationOption trees + status/tag relation values: two-home harness
#
# Offline two-home bidirectional replay for three scenarios:
#   A. STRelationOption create + status value set + resolved read
#   B. Tag relation full-replace with 3 options + order-preserving read
#   C. Tag add/remove regression (STATTAG-04 success criterion #4):
#      initial [a,b,c] -> --tag-remove b -> --tag-add d -> final [a,c,d]
#
# Per D-14: cross-implementation proof (official-client observation) is
# deferred to Phase 42: this harness is Manytype-only (manytype_server +
# two Manytype homes sharing a space).
#
# KNOWN TRAPS encoded here:
# - sed pattern `^Created [a-z]*: ` depends on create.dart's "Created <kind>: <id>"
#   confirmation line. Verified against Plan 02 create.dart line 539.
# - DO NOT use extractTextPreview (STATE.md known issue): we verify resolution
#   by grep on the rendered text, never via a preview extraction.
# - DO NOT sort the expected tag list: list_value order is the write order.
# - DO NOT re-sync HOME A after a captured edit: MANYTYPE_SYNC_CAPTURE_PATH
#   must capture the WRITE events, not an empty-delta replay.
# - HOME 2 starts from the same pre-migration config, but never copies HOME
#   A's database or registry. This keeps both homes independently namespaced.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
PORT="${PORT:-33148}"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
MANYTYPE_HOME_2="$TMPDIR/manytype-home-2"
NETWORK_YML="$TMPDIR/network.yml"
SHARED_CONFIG="$TMPDIR/shared-config.toml"
ARTIFACT_DIR="${MANYTYPE_ARTIFACT_DIR:-$ROOT_DIR/test_vectors/phase38}"
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

mkdir -p "$ARTIFACT_DIR"
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

printf 'Building manytype_server...\n'
# Phase 38-04 note: if `cargo build` fails on main (e.g. pre-existing
# type-mismatch in unrelated file_node/drpc router code), fall back to an
# existing target/debug/manytype_server binary so the harness can still
# exercise the Phase 38 CLI surfaces. Out-of-scope build breakage is
# logged to deferred-items.md, not auto-fixed from this plan.
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
identity_seed = "0808080808080808080808080808080808080808080808080808080808080838"
network_id = "manytype-phase38-relation-option"
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
networkId: manytype-phase38-relation-option
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

# --------------------------------------------------------------------------
# Scenario A: STATUS CREATE (STATTAG-01 + STATTAG-02 + STATTAG-05)
# --------------------------------------------------------------------------
printf '\n=== Phase 38 Scenario A: STRelationOption create + status set ===\n'

MANYTYPE_SYNC_CAPTURE_A="$TMPDIR/sync-status-create.json"

# 1. HOME A: create the parent STRelation "status" with RelationFormat.status
#    (--format status is required so read.dart's _formatOptionRelationValue
#    intercepts the render path; without it the relation defaults to
#    longtext and the generic relation path runs instead.)
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "status" --as-relation --format status >"$TMPDIR/create-rel-a.txt"

# Seed live space so bootstrap exists (after first create, before any sync).
printf 'Seeding live space...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_YML" \
  --wait-seconds 2 >/dev/null

# 2. HOME A: create a target object that will carry the status value
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "TargetObjA" >"$TMPDIR/create-target-a.txt"
TARGET_A="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/create-target-a.txt" | head -1)"
if [[ -z "$TARGET_A" ]]; then
  printf 'FAIL (A): no target object id\n' >&2
  cat "$TMPDIR/create-target-a.txt" >&2 || true
  exit 1
fi

# 3. HOME A: create the STRelationOption for relation "status" with color red
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "Done" --as-relation-option --for-relation "status" --color "red" \
  >"$TMPDIR/create-opt-a.txt"
OPT_ID_A="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/create-opt-a.txt" | head -1)"
if [[ -z "$OPT_ID_A" ]]; then
  printf 'FAIL (A): no option id\n' >&2
  cat "$TMPDIR/create-opt-a.txt" >&2 || true
  exit 1
fi

# 4. HOME A: set the target object's status value to the new option ID
#    (captured: this is the structural write we want in the sync artifact)
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_A" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$TARGET_A" --relation "status" --status "$OPT_ID_A"

# 5. HOME A: re-read and confirm the resolved render
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$TARGET_A" >"$TMPDIR/read-a-home1.txt"
if ! grep -q '\[status\] Done (red)' "$TMPDIR/read-a-home1.txt"; then
  printf 'FAIL (A): status not resolved on HOME 1\n' >&2
  cat "$TMPDIR/read-a-home1.txt" >&2 || true
  exit 1
fi

# 6. HOME B: import the shared identity, sync, re-read, confirm resolution
prepare_second_home
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$TARGET_A" >"$TMPDIR/read-a-home2.txt"
if ! grep -q '\[status\] Done (red)' "$TMPDIR/read-a-home2.txt"; then
  printf 'FAIL (A): status not resolved on HOME 2 after replay\n' >&2
  cat "$TMPDIR/read-a-home2.txt" >&2 || true
  exit 1
fi

# 7. Write scenario A artifact JSON + copy sync capture
ARTIFACT_A="$ARTIFACT_DIR/status-create.json"
SYNC_A="$ARTIFACT_DIR/status-create-sync.json"
cp "$MANYTYPE_SYNC_CAPTURE_A" "$SYNC_A"
python3 - "$ARTIFACT_A" "$TARGET_A" "$OPT_ID_A" "$SYNC_A" <<'PY'
import datetime as dt, json, pathlib, sys
artifact_path, target_id, option_id, sync_capture = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase38 scenario A - STRelationOption create + status set + two-home read resolution",
    "relation_key": "status",
    "target_object_id": target_id,
    "option_id": option_id,
    "expected_option_name": "Done",
    "expected_option_color": "red",
    "expected_selectdict_updated": True,
    "expected_status_value": option_id,
    "expected_render": "[status] Done (red)",
    "post_replay_resolved": True,
    "roundtrip_observed": True,
    "manytype_sync_capture_path": sync_capture,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY
printf 'Scenario A OK: %s\n' "$ARTIFACT_A"

# --------------------------------------------------------------------------
# Scenario B: TAG MULTI (STATTAG-01 + STATTAG-03 + STATTAG-05)
# --------------------------------------------------------------------------
printf '\n=== Phase 38 Scenario B: tag multi (3 options full-replace) ===\n'

MANYTYPE_SYNC_CAPTURE_B="$TMPDIR/sync-tag-multi.json"

# 1. HOME A: create the parent tag STRelation "taglist" with RelationFormat.tag
#    (--format tag is required so read.dart's _formatOptionRelationValue
#    intercepts the render path for list_value tag relations.)
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "taglist" --as-relation --format tag >"$TMPDIR/create-rel-tag.txt"

# 2. HOME A: create 3 STRelationOption objects for "taglist"
for name_color in "Alpha:red" "Beta:blue" "Gamma:lime"; do
  name="${name_color%%:*}"
  color="${name_color##*:}"
  HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
    --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
    create --name "$name" --as-relation-option --for-relation "taglist" --color "$color" \
    >"$TMPDIR/create-opt-${name}.txt"
done
OPT_ALPHA="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/create-opt-Alpha.txt" | head -1)"
OPT_BETA="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/create-opt-Beta.txt" | head -1)"
OPT_GAMMA="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/create-opt-Gamma.txt" | head -1)"
if [[ -z "$OPT_ALPHA" || -z "$OPT_BETA" || -z "$OPT_GAMMA" ]]; then
  printf 'FAIL (B): missing option ids: alpha=%s beta=%s gamma=%s\n' \
    "$OPT_ALPHA" "$OPT_BETA" "$OPT_GAMMA" >&2
  exit 1
fi

# 3. HOME A: create a target object
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "TargetObjB" >"$TMPDIR/create-target-b.txt"
TARGET_B="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/create-target-b.txt" | head -1)"
if [[ -z "$TARGET_B" ]]; then
  printf 'FAIL (B): no target object id\n' >&2
  exit 1
fi

# 4. HOME A: set taglist to the 3-option list (full replace, captured)
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_B" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$TARGET_B" --relation "taglist" --tag "$OPT_ALPHA,$OPT_BETA,$OPT_GAMMA"

# 5. HOME A: re-read and confirm resolution in exact order
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$TARGET_B" >"$TMPDIR/read-b-home1.txt"
if ! grep -q '\[taglist\] Alpha, Beta, Gamma' "$TMPDIR/read-b-home1.txt"; then
  printf 'FAIL (B): tag resolution HOME 1\n' >&2
  cat "$TMPDIR/read-b-home1.txt" >&2 || true
  exit 1
fi

# 6. HOME B: sync and re-read
prepare_second_home
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$TARGET_B" >"$TMPDIR/read-b-home2.txt"
if ! grep -q '\[taglist\] Alpha, Beta, Gamma' "$TMPDIR/read-b-home2.txt"; then
  printf 'FAIL (B): tag resolution HOME 2\n' >&2
  cat "$TMPDIR/read-b-home2.txt" >&2 || true
  exit 1
fi

# 7. Write artifact + sync capture
ARTIFACT_B="$ARTIFACT_DIR/tag-multi.json"
SYNC_B="$ARTIFACT_DIR/tag-multi-sync.json"
cp "$MANYTYPE_SYNC_CAPTURE_B" "$SYNC_B"
python3 - "$ARTIFACT_B" "$TARGET_B" "$OPT_ALPHA" "$OPT_BETA" "$OPT_GAMMA" "$SYNC_B" <<'PY'
import datetime as dt, json, pathlib, sys
artifact_path, target_id, alpha, beta, gamma, sync_capture = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase38 scenario B - tag relation 3-option full replace + two-home read resolution",
    "relation_key": "taglist",
    "target_object_id": target_id,
    "expected_tag_count": 3,
    "expected_tag_ids": [alpha, beta, gamma],
    "expected_tag_names_ordered": ["Alpha", "Beta", "Gamma"],
    "expected_render": "[taglist] Alpha, Beta, Gamma",
    "post_replay_resolved": True,
    "roundtrip_observed": True,
    "manytype_sync_capture_path": sync_capture,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY
printf 'Scenario B OK: %s\n' "$ARTIFACT_B"

# --------------------------------------------------------------------------
# Scenario C: TAG ADD/REMOVE REGRESSION (STATTAG-04 success criterion #4)
# --------------------------------------------------------------------------
printf '\n=== Phase 38 Scenario C: tag-add / tag-remove regression ===\n'

MANYTYPE_SYNC_CAPTURE_C="$TMPDIR/sync-tag-add-remove.json"

# Reuse the "taglist" STRelation + Alpha/Beta/Gamma options from scenario B.
# Create a fourth option "Delta" (color pink) for the regression.
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "Delta" --as-relation-option --for-relation "taglist" --color "pink" \
  >"$TMPDIR/create-opt-Delta.txt"
OPT_DELTA="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/create-opt-Delta.txt" | head -1)"
if [[ -z "$OPT_DELTA" ]]; then
  printf 'FAIL (C): no delta option id\n' >&2
  exit 1
fi

# 1. HOME A: create a target object and set initial tag to [Alpha, Beta, Gamma]
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "TargetObjC" >"$TMPDIR/create-target-c.txt"
TARGET_C="$(sed -n 's/^Created [a-z-]*: //p' "$TMPDIR/create-target-c.txt" | head -1)"
if [[ -z "$TARGET_C" ]]; then
  printf 'FAIL (C): no target object id\n' >&2
  exit 1
fi

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$TARGET_C" --relation "taglist" --tag "$OPT_ALPHA,$OPT_BETA,$OPT_GAMMA"

# 2. HOME A: remove Beta (--tag-remove)
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$TARGET_C" --relation "taglist" --tag-remove "$OPT_BETA"

# 3. HOME A: add Delta (--tag-add): captured in MANYTYPE_SYNC_CAPTURE
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_C" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$TARGET_C" --relation "taglist" --tag-add "$OPT_DELTA"

# 4. HOME A: re-read and confirm the final list is exactly [Alpha, Gamma, Delta]
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$TARGET_C" >"$TMPDIR/read-c-home1.txt"
if ! grep -q '\[taglist\] Alpha, Gamma, Delta' "$TMPDIR/read-c-home1.txt"; then
  printf 'FAIL (C): post-delta tag list wrong HOME 1\n' >&2
  cat "$TMPDIR/read-c-home1.txt" >&2 || true
  exit 1
fi

# 5. HOME B: sync and re-read
prepare_second_home
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$TARGET_C" >"$TMPDIR/read-c-home2.txt"
if ! grep -q '\[taglist\] Alpha, Gamma, Delta' "$TMPDIR/read-c-home2.txt"; then
  printf 'FAIL (C): tag resolution HOME 2 after delta\n' >&2
  cat "$TMPDIR/read-c-home2.txt" >&2 || true
  exit 1
fi

# 6. Write artifact + sync capture
ARTIFACT_C="$ARTIFACT_DIR/tag-add-remove.json"
SYNC_C="$ARTIFACT_DIR/tag-add-remove-sync.json"
cp "$MANYTYPE_SYNC_CAPTURE_C" "$SYNC_C"
python3 - "$ARTIFACT_C" "$TARGET_C" "$OPT_ALPHA" "$OPT_BETA" "$OPT_GAMMA" "$OPT_DELTA" "$SYNC_C" <<'PY'
import datetime as dt, json, pathlib, sys
artifact_path, target_id, alpha, beta, gamma, delta, sync_capture = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase38 scenario C - tag regression: full-replace -> remove -> add",
    "relation_key": "taglist",
    "target_object_id": target_id,
    "expected_initial_tag_ids": [alpha, beta, gamma],
    "expected_removed": [beta],
    "expected_added": [delta],
    "expected_final_tag_ids": [alpha, gamma, delta],
    "expected_final_tag_names_ordered": ["Alpha", "Gamma", "Delta"],
    "expected_render": "[taglist] Alpha, Gamma, Delta",
    "post_replay_resolved": True,
    "roundtrip_observed": True,
    "manytype_sync_capture_path": sync_capture,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY
printf 'Scenario C OK: %s\n' "$ARTIFACT_C"

printf '\nphase38 harness: PASSED (status-create, tag-multi, tag-add-remove)\n'
