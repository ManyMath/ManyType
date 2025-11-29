#!/usr/bin/env bash

set -euo pipefail

# Phase 36 VERIFY-04: Listing verification harness (type filter after sync)
#
# Creates two page objects, syncs to official any-sync stack, pulls on a fresh
# Manytype home, and verifies `manytype list --type ot-page` returns the
# expected objects while `manytype list --type ot-note` returns none.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
ARTIFACT_PATH="${PHASE36_LISTING_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase36-listing-type-filter.json}"
MANYTYPE_SYNC_CAPTURE="$ROOT_DIR/test_vectors/phase36-listing-sync.json"

TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
MANYTYPE_HOME_2="$TMPDIR/manytype-home-2"

cleanup() {
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

printf 'Starting official any-sync stack...\n'
(cd "$ROOT_DIR/docker/any-sync" && docker compose up -d >/dev/null)

# --------------------------------------------------------------------------
# Create objects and sync to official stack
# --------------------------------------------------------------------------

printf 'Preparing Manytype CLI temp home...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" init >/dev/null

printf 'Creating page objects...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  create "Phase36Page1" >"$TMPDIR/create-page1.txt"
PAGE1_ID="$(sed -n 's/^Created object: //p' "$TMPDIR/create-page1.txt" | head -1)"

HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  create "Phase36Page2" >"$TMPDIR/create-page2.txt"
PAGE2_ID="$(sed -n 's/^Created object: //p' "$TMPDIR/create-page2.txt" | head -1)"

if [[ -z "$PAGE1_ID" || -z "$PAGE2_ID" ]]; then
  printf 'FAIL: could not parse page object IDs\n' >&2
  exit 1
fi

printf 'Created pages: %s, %s\n' "$PAGE1_ID" "$PAGE2_ID"

printf 'Seeding Manytype space to official stack...\n'
HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_seed_live_space.dart" \
  --network-config "$NETWORK_CONFIG_SRC" \
  --wait-seconds 10 >/dev/null

printf 'Syncing to official stack...\n'
HOME="$MANYTYPE_HOME" MANYTYPE_SYNC_CAPTURE_PATH="$MANYTYPE_SYNC_CAPTURE" \
  dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

SPACE_INFO_JSON="$(HOME="$MANYTYPE_HOME" dart run "$ROOT_DIR/packages/manytype_cli/tool/phase31_identity_dump.dart")"
SPACE_ID="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["space_id"])' <<<"$SPACE_INFO_JSON")"

# --------------------------------------------------------------------------
# Pull on fresh home and verify listing
# --------------------------------------------------------------------------

printf 'Setting up second Manytype home for fresh pull...\n'
# Copy identity to second home so it can access the same space
cp -r "$MANYTYPE_HOME/.manytype" "$MANYTYPE_HOME_2/.manytype" 2>/dev/null || true
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" init >/dev/null 2>&1 || true

printf 'Syncing second home from official stack...\n'
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --network-config "$NETWORK_CONFIG_SRC" sync >/dev/null

printf 'Running list --type ot-page...\n'
PAGE_LIST="$TMPDIR/list-page.txt"
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --network-config "$NETWORK_CONFIG_SRC" list --type ot-page >"$PAGE_LIST" 2>&1 || true

printf 'Running list --type ot-note...\n'
NOTE_LIST="$TMPDIR/list-note.txt"
HOME="$MANYTYPE_HOME_2" dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --network-config "$NETWORK_CONFIG_SRC" list --type ot-note >"$NOTE_LIST" 2>&1 || true

# Check results
PAGE_IDS_IN_LIST="false"
NOTE_IDS_ABSENT="false"

if grep -q "$PAGE1_ID" "$PAGE_LIST" && grep -q "$PAGE2_ID" "$PAGE_LIST"; then
  PAGE_IDS_IN_LIST="true"
fi

if ! grep -q "$PAGE1_ID" "$NOTE_LIST" && ! grep -q "$PAGE2_ID" "$NOTE_LIST"; then
  NOTE_IDS_ABSENT="true"
fi

# Write artifact
python3 - "$ARTIFACT_PATH" "$SPACE_ID" "$PAGE1_ID" "$PAGE2_ID" \
  "$PAGE_IDS_IN_LIST" "$NOTE_IDS_ABSENT" \
  "$MANYTYPE_SYNC_CAPTURE" "$PAGE_LIST" "$NOTE_LIST" <<'PY'
import datetime as dt
import json
import pathlib
import sys

artifact_path = pathlib.Path(sys.argv[1])
space_id = sys.argv[2]
page1_id = sys.argv[3]
page2_id = sys.argv[4]
page_ids_in_list = sys.argv[5] == "true"
note_ids_absent = sys.argv[6] == "true"
sync_capture = sys.argv[7]
page_list_path = sys.argv[8]
note_list_path = sys.argv[9]

page_list_output = pathlib.Path(page_list_path).read_text(errors="replace") if pathlib.Path(page_list_path).exists() else ""
note_list_output = pathlib.Path(note_list_path).read_text(errors="replace") if pathlib.Path(note_list_path).exists() else ""

success = bool(space_id and page1_id and page2_id and page_ids_in_list and note_ids_absent)

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "manytype list --type filter after official stack sync",
    "space_id": space_id,
    "created_object_ids": [page1_id, page2_id],
    "page_list_output": page_list_output[:2000],
    "note_list_output": note_list_output[:2000],
    "page_ids_in_list": page_ids_in_list,
    "note_ids_absent": note_ids_absent,
    "manytype_sync_capture_path": sync_capture,
    "success": success,
}

artifact_path.write_text(json.dumps(artifact, indent=2) + "\n")
PY

python3 - "$ARTIFACT_PATH" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
if not data.get("success"):
    raise SystemExit(f"Listing artifact failed: pages_found={data.get('page_ids_in_list')}, notes_absent={data.get('note_ids_absent')}")
print(f"OK: phase36 listing type filter ({data['created_object_ids']})")
PY

printf 'Artifact written: %s\n' "$ARTIFACT_PATH"
printf 'phase36_listing_harness.sh: PASSED\n'
