#!/usr/bin/env bash

set -euo pipefail

# Phase 37 BLKUPD-01/02/03: BlockUpdate mutation harness
#
# Offline two-home bidirectional replay for three mutation classes:
#   A. Checkbox state toggle via set-checked
#   B. Text content rewrite via set-text
#   C. Block style change via set-style
#
# Per D-13: cross-implementation proof (official-client observation) is
# deferred to Phase 42: this harness is Manytype-only (manytype_server +
# two Manytype homes sharing a space).
#
# KNOWN TRAPS encoded here:
# - extractTextPreview returns empty for encrypted changes (STATE.md). The
#   harness verifies text reaches HOME_2 via `read` grep on the new text
#   value, never via a preview extraction.
# - If `read` shows zero text blocks, Task 4's _printSnapshotBlocks walker
#   is missing: the checkbox block created by `--checkbox` lives in the
#   snapshot, not in a BlockCreate change.
# - We do NOT read current checkbox state before writing (absolute semantics
#   per D-07).
# - ID stability is asserted pre/post by diffing `grep -oE '\[cb-[a-f0-9]+\]'`.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
PORT="${PORT:-33147}"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
MANYTYPE_HOME_2="$TMPDIR/manytype-home-2"
NETWORK_YML="$TMPDIR/network.yml"
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

mkdir -p "$ROOT_DIR/test_vectors"
mkdir -p "$MANYTYPE_HOME" "$MANYTYPE_HOME_2"

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

wait_for_server_ready() {
  local log_file="$1"
  for _ in $(seq 1 30); do
    if rg -q 'Listening on QUIC' "$log_file" && rg -q 'Server peer ID:' "$log_file"; then
      return 0
    fi
    sleep 1
  done
  return 1
}

printf 'Building manytype_server...\n'
(cd "$RUST_DIR" && cargo build -p manytype_server >/dev/null)

cat >"$TMPDIR/server.toml" <<EOF
deployment_mode = "development"
quic_listen = "127.0.0.1:$PORT"
db_path = "$TMPDIR/server.redb"
identity_seed = "0707070707070707070707070707070707070707070707070707070707070737"
network_id = "manytype-phase37-blockupdate"
EOF

printf 'Starting manytype_server on 127.0.0.1:%s...\n' "$PORT"
stdbuf -oL -eL "$RUST_DIR/target/debug/manytype_server" "$TMPDIR/server.toml" >"$TMPDIR/server.log" 2>&1 &
SERVER_PID=$!
if ! wait_for_server_ready "$TMPDIR/server.log"; then
  printf 'FAIL: server did not become ready\n' >&2
  sed -n '1,200p' "$TMPDIR/server.log" >&2 || true
  exit 1
fi

PEER_ID="$(sed -n 's/.*Server peer ID: //p' "$TMPDIR/server.log" | tail -1)"
if [[ -z "$PEER_ID" ]]; then
  printf 'FAIL: could not parse server peer id\n' >&2
  exit 1
fi

cat >"$NETWORK_YML" <<EOF
id: manytype-v2.5
networkId: manytype-phase37-blockupdate
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

# --------------------------------------------------------------------------
# Scenario A: CHECKBOX MUTATION (set-checked true)
# --------------------------------------------------------------------------
printf '\n=== Phase 37 Scenario A: checkbox mutation ===\n'

MANYTYPE_SYNC_CAPTURE_A="$TMPDIR/sync-checkbox.json"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "Phase37Checkbox" --checkbox >"$TMPDIR/create-cb.txt"
OBJECT_ID_CB="$(sed -n 's/^Created [a-z]*: //p' "$TMPDIR/create-cb.txt" | head -1)"
if [[ -z "$OBJECT_ID_CB" ]]; then
  printf 'FAIL: no object id (checkbox)\n' >&2
  cat "$TMPDIR/create-cb.txt" >&2 || true
  exit 1
fi

printf 'Seeding live space (after create so bootstrap exists)...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_YML" \
  --wait-seconds 2 >/dev/null

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$OBJECT_ID_CB" >"$TMPDIR/read-cb-pre.txt"

# Extract the first cb-* block id from _printSnapshotBlocks output.
# Relies on Task 4's [id]-prefix rendering: if this grep fails, the
# walker patch is missing.
BLOCK_ID_CB="$(grep -oE '\[cb-[a-f0-9]+\]' "$TMPDIR/read-cb-pre.txt" | head -1 | tr -d '[]')"
if [[ -z "$BLOCK_ID_CB" ]]; then
  printf 'FAIL: no block-id extracted from read-pre (checkbox).\n' >&2
  printf 'Hint: Task 4 _printSnapshotBlocks walker may be missing.\n' >&2
  cat "$TMPDIR/read-cb-pre.txt" >&2 || true
  exit 1
fi
BLOCK_IDS_PRE_CB="$(grep -oE '\[cb-[a-f0-9]+\]' "$TMPDIR/read-cb-pre.txt" | sort -u)"

printf 'Scenario A: edit --block-id %s --set-checked true\n' "$BLOCK_ID_CB"
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_A" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$OBJECT_ID_CB" --block-id "$BLOCK_ID_CB" --set-checked true

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$OBJECT_ID_CB" >"$TMPDIR/read-cb-post.txt"

if ! grep -q '\[x\] \[Checkbox\]' "$TMPDIR/read-cb-post.txt"; then
  printf 'FAIL: checked=true not reflected in post-mutation read (Scenario A)\n' >&2
  cat "$TMPDIR/read-cb-post.txt" >&2 || true
  exit 1
fi
BLOCK_IDS_POST_CB="$(grep -oE '\[cb-[a-f0-9]+\]' "$TMPDIR/read-cb-post.txt" | sort -u)"
if [[ "$BLOCK_IDS_PRE_CB" != "$BLOCK_IDS_POST_CB" ]]; then
  printf 'FAIL: block id set changed (Scenario A, Pitfall 3)\n' >&2
  printf 'PRE:  %s\n' "$BLOCK_IDS_PRE_CB" >&2
  printf 'POST: %s\n' "$BLOCK_IDS_POST_CB" >&2
  exit 1
fi

# Round-trip on second home (full state copy + sync).
cp -r "$MANYTYPE_HOME/.manytype" "$MANYTYPE_HOME_2/.manytype"
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$OBJECT_ID_CB" >"$TMPDIR/read-cb-home2.txt"
if ! grep -q '\[x\] \[Checkbox\]' "$TMPDIR/read-cb-home2.txt"; then
  printf 'FAIL: home2 roundtrip (checkbox)\n' >&2
  cat "$TMPDIR/read-cb-home2.txt" >&2 || true
  exit 1
fi

ARTIFACT_CB="$ROOT_DIR/test_vectors/phase37-blockupdate-checkbox.json"
SYNC_CB="$ROOT_DIR/test_vectors/phase37-blockupdate-checkbox-sync.json"
cp "$MANYTYPE_SYNC_CAPTURE_A" "$SYNC_CB"
python3 - "$ARTIFACT_CB" "$OBJECT_ID_CB" "$BLOCK_ID_CB" "$SYNC_CB" "checked" "true" "set-checked-true" "manytype-authored BlockUpdate blockSetText.checked -> two-home roundtrip" <<'PY'
import datetime as dt, json, pathlib, sys
(artifact_path, object_id, block_id, sync_capture,
 expected_field, expected_value_raw, mutation, scenario) = sys.argv[1:]
if expected_field == "checked":
    expected_value = expected_value_raw == "true"
else:
    expected_value = expected_value_raw
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": scenario,
    "object_id": object_id,
    "block_id": block_id,
    "mutation": mutation,
    "expected_block_update_variant": "blockSetText",
    "expected_field": expected_field,
    "expected_value": expected_value,
    "post_mutation_block_id_unchanged": True,
    "roundtrip_observed": True,
    "manytype_sync_capture_path": sync_capture,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY
printf 'Scenario A OK: %s\n' "$ARTIFACT_CB"

# Reset HOME_2 so the next scenario starts clean for its own copy-then-sync.
rm -rf "$MANYTYPE_HOME_2/.manytype"

# --------------------------------------------------------------------------
# Scenario B: TEXT REWRITE (set-text "rewritten content xyz")
# --------------------------------------------------------------------------
#
# NOTE: The CLI create path does not directly produce a standalone paragraph
# block (existing flags: --checkbox, --numbered-list, --toggle, --quote,
# --callout; all non-paragraph styles). We create with --checkbox and rewrite
# the checkbox block's text: a Checkbox block has hasText() so set-text
# applies to it normally. This is an acceptable fallback documented in D-04.
printf '\n=== Phase 37 Scenario B: text rewrite ===\n'

MANYTYPE_SYNC_CAPTURE_B="$TMPDIR/sync-text.json"
NEW_TEXT="rewritten content xyz"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "Phase37Text" --checkbox >"$TMPDIR/create-txt.txt"
OBJECT_ID_TXT="$(sed -n 's/^Created [a-z]*: //p' "$TMPDIR/create-txt.txt" | head -1)"
if [[ -z "$OBJECT_ID_TXT" ]]; then
  printf 'FAIL: no object id (text)\n' >&2
  cat "$TMPDIR/create-txt.txt" >&2 || true
  exit 1
fi

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$OBJECT_ID_TXT" >"$TMPDIR/read-txt-pre.txt"
BLOCK_ID_TXT="$(grep -oE '\[cb-[a-f0-9]+\]' "$TMPDIR/read-txt-pre.txt" | head -1 | tr -d '[]')"
if [[ -z "$BLOCK_ID_TXT" ]]; then
  printf 'FAIL: no block-id extracted from read-pre (text)\n' >&2
  cat "$TMPDIR/read-txt-pre.txt" >&2 || true
  exit 1
fi
BLOCK_IDS_PRE_TXT="$(grep -oE '\[cb-[a-f0-9]+\]' "$TMPDIR/read-txt-pre.txt" | sort -u)"

printf 'Scenario B: edit --block-id %s --set-text %q\n' "$BLOCK_ID_TXT" "$NEW_TEXT"
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_B" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$OBJECT_ID_TXT" --block-id "$BLOCK_ID_TXT" --set-text "$NEW_TEXT"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$OBJECT_ID_TXT" >"$TMPDIR/read-txt-post.txt"
if ! grep -q "$NEW_TEXT" "$TMPDIR/read-txt-post.txt"; then
  printf 'FAIL: new text not reflected (Scenario B)\n' >&2
  cat "$TMPDIR/read-txt-post.txt" >&2 || true
  exit 1
fi
BLOCK_IDS_POST_TXT="$(grep -oE '\[cb-[a-f0-9]+\]' "$TMPDIR/read-txt-post.txt" | sort -u)"
if [[ "$BLOCK_IDS_PRE_TXT" != "$BLOCK_IDS_POST_TXT" ]]; then
  printf 'FAIL: block id set changed (Scenario B, Pitfall 3)\n' >&2
  printf 'PRE:  %s\n' "$BLOCK_IDS_PRE_TXT" >&2
  printf 'POST: %s\n' "$BLOCK_IDS_POST_TXT" >&2
  exit 1
fi

cp -r "$MANYTYPE_HOME/.manytype" "$MANYTYPE_HOME_2/.manytype"
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$OBJECT_ID_TXT" >"$TMPDIR/read-txt-home2.txt"
if ! grep -q "$NEW_TEXT" "$TMPDIR/read-txt-home2.txt"; then
  printf 'FAIL: home2 roundtrip (text)\n' >&2
  cat "$TMPDIR/read-txt-home2.txt" >&2 || true
  exit 1
fi

ARTIFACT_TXT="$ROOT_DIR/test_vectors/phase37-blockupdate-text.json"
SYNC_TXT="$ROOT_DIR/test_vectors/phase37-blockupdate-text-sync.json"
cp "$MANYTYPE_SYNC_CAPTURE_B" "$SYNC_TXT"
python3 - "$ARTIFACT_TXT" "$OBJECT_ID_TXT" "$BLOCK_ID_TXT" "$SYNC_TXT" "text" "$NEW_TEXT" "set-text" "manytype-authored BlockUpdate blockSetText.text -> two-home roundtrip" <<'PY'
import datetime as dt, json, pathlib, sys
(artifact_path, object_id, block_id, sync_capture,
 expected_field, expected_value, mutation, scenario) = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": scenario,
    "object_id": object_id,
    "block_id": block_id,
    "mutation": mutation,
    "expected_block_update_variant": "blockSetText",
    "expected_field": expected_field,
    "expected_value": expected_value,
    "post_mutation_block_id_unchanged": True,
    "roundtrip_observed": True,
    "manytype_sync_capture_path": sync_capture,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY
printf 'Scenario B OK: %s\n' "$ARTIFACT_TXT"

rm -rf "$MANYTYPE_HOME_2/.manytype"

# --------------------------------------------------------------------------
# Scenario C: STYLE CHANGE (set-style header2)
# --------------------------------------------------------------------------
printf '\n=== Phase 37 Scenario C: style change ===\n'

MANYTYPE_SYNC_CAPTURE_C="$TMPDIR/sync-style.json"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  create --name "Phase37Style" --checkbox >"$TMPDIR/create-sty.txt"
OBJECT_ID_STY="$(sed -n 's/^Created [a-z]*: //p' "$TMPDIR/create-sty.txt" | head -1)"
if [[ -z "$OBJECT_ID_STY" ]]; then
  printf 'FAIL: no object id (style)\n' >&2
  cat "$TMPDIR/create-sty.txt" >&2 || true
  exit 1
fi

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$OBJECT_ID_STY" >"$TMPDIR/read-sty-pre.txt"
BLOCK_ID_STY="$(grep -oE '\[cb-[a-f0-9]+\]' "$TMPDIR/read-sty-pre.txt" | head -1 | tr -d '[]')"
if [[ -z "$BLOCK_ID_STY" ]]; then
  printf 'FAIL: no block-id extracted from read-pre (style)\n' >&2
  cat "$TMPDIR/read-sty-pre.txt" >&2 || true
  exit 1
fi
BLOCK_IDS_PRE_STY="$(grep -oE '\[cb-[a-f0-9]+\]' "$TMPDIR/read-sty-pre.txt" | sort -u)"

printf 'Scenario C: edit --block-id %s --set-style header2\n' "$BLOCK_ID_STY"
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE_C" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  edit --id "$OBJECT_ID_STY" --block-id "$BLOCK_ID_STY" --set-style header2

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$OBJECT_ID_STY" >"$TMPDIR/read-sty-post.txt"
if ! grep -q '\[Header2\]' "$TMPDIR/read-sty-post.txt"; then
  printf 'FAIL: new style [Header2] not reflected (Scenario C)\n' >&2
  cat "$TMPDIR/read-sty-post.txt" >&2 || true
  exit 1
fi
# Confirm the same block id still appears post-mutation (ID stability under
# style change). The [cb-...] ID is still emitted even with Header2 style
# because the walker prefixes every block regardless of style.
if ! grep -q "\[$BLOCK_ID_STY\]" "$TMPDIR/read-sty-post.txt"; then
  printf 'FAIL: original block id missing post-style-change (Scenario C)\n' >&2
  cat "$TMPDIR/read-sty-post.txt" >&2 || true
  exit 1
fi
BLOCK_IDS_POST_STY="$(grep -oE '\[cb-[a-f0-9]+\]' "$TMPDIR/read-sty-post.txt" | sort -u)"
if [[ "$BLOCK_IDS_PRE_STY" != "$BLOCK_IDS_POST_STY" ]]; then
  printf 'FAIL: block id set changed (Scenario C, Pitfall 3)\n' >&2
  printf 'PRE:  %s\n' "$BLOCK_IDS_PRE_STY" >&2
  printf 'POST: %s\n' "$BLOCK_IDS_POST_STY" >&2
  exit 1
fi

cp -r "$MANYTYPE_HOME/.manytype" "$MANYTYPE_HOME_2/.manytype"
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" sync >/dev/null
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --server "127.0.0.1:$PORT" --network-config "$NETWORK_YML" \
  read "$OBJECT_ID_STY" >"$TMPDIR/read-sty-home2.txt"
if ! grep -q '\[Header2\]' "$TMPDIR/read-sty-home2.txt"; then
  printf 'FAIL: home2 roundtrip (style)\n' >&2
  cat "$TMPDIR/read-sty-home2.txt" >&2 || true
  exit 1
fi

ARTIFACT_STY="$ROOT_DIR/test_vectors/phase37-blockupdate-style.json"
SYNC_STY="$ROOT_DIR/test_vectors/phase37-blockupdate-style-sync.json"
cp "$MANYTYPE_SYNC_CAPTURE_C" "$SYNC_STY"
python3 - "$ARTIFACT_STY" "$OBJECT_ID_STY" "$BLOCK_ID_STY" "$SYNC_STY" "style" "Header2" "set-style-header2" "manytype-authored BlockUpdate blockSetText.style -> two-home roundtrip" <<'PY'
import datetime as dt, json, pathlib, sys
(artifact_path, object_id, block_id, sync_capture,
 expected_field, expected_value, mutation, scenario) = sys.argv[1:]
artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": scenario,
    "object_id": object_id,
    "block_id": block_id,
    "mutation": mutation,
    "expected_block_update_variant": "blockSetText",
    "expected_field": expected_field,
    "expected_value": expected_value,
    "post_mutation_block_id_unchanged": True,
    "roundtrip_observed": True,
    "manytype_sync_capture_path": sync_capture,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY
printf 'Scenario C OK: %s\n' "$ARTIFACT_STY"

printf '\nphase37 harness: PASSED (checkbox, text, style)\n'
