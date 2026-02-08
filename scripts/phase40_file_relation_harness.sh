#!/usr/bin/env bash

set -euo pipefail

# Phase 40: file-as-relation compound write: docker any-sync two-home harness
#
# Proves the Manytype-authored compound write against the self-hosted official
# any-sync stack:
#   1. Create a file-format relation.
#   2. Create a target object.
#   3. Set `--file-relation` on HOME 1 (capturing sync + file-transfer RPCs).
#   4. Re-read on HOME 1.
#   5. Copy the local state to HOME 2, sync from the official stack, and
#      confirm the relation still resolves to a human-readable file label.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

NETWORK_CONFIG="$ROOT_DIR/docker/any-sync/etc/client.yml"
TMPDIR="$(mktemp -d)"
MANYTYPE_HOME="$TMPDIR/manytype-home"
MANYTYPE_HOME_2="$TMPDIR/manytype-home-2"
PAYLOAD_NAME="phase40-$(date +%s%N).pdf"
PAYLOAD_FILE="$TMPDIR/$PAYLOAD_NAME"
SYNC_CAPTURE="$TMPDIR/phase40-sync.json"
TRANSFER_CAPTURE="$TMPDIR/phase40-transfer.json"
EDIT_OUTPUT="$TMPDIR/edit-output.txt"
READ_HOME1="$TMPDIR/read-home1.txt"
READ_HOME2="$TMPDIR/read-home2.txt"

cleanup() {
  if [[ "${KEEP_TMPDIR:-0}" != "1" ]]; then
    rm -rf "$TMPDIR" >/dev/null 2>&1 || true
  else
    printf 'Kept tempdir: %s\n' "$TMPDIR"
  fi
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

run_cli() {
  local home="$1"
  shift
  oracle_run_cli "$home" "$@"
}

extract_created_id() {
  local file="$1"
  sed -n 's/^Created [a-z-]*: //p' "$file" | head -1
}

printf '=== Phase 40: file relation round-trip against docker any-sync ===\n\n'

oracle_run_preflight

mkdir -p "$ROOT_DIR/test_vectors/phase40" "$MANYTYPE_HOME" "$MANYTYPE_HOME_2"
printf 'phase40-pdf-payload-%s\n' "$(date +%s%N)" >"$PAYLOAD_FILE"

oracle_export_runtime_env

printf 'Preparing HOME 1...\n'
run_cli "$MANYTYPE_HOME" init >/dev/null

printf 'Creating file-format relation...\n'
run_cli "$MANYTYPE_HOME" \
  create --as-relation --name "attachment" --format file >"$TMPDIR/create-relation.txt"
RELATION_ID="$(extract_created_id "$TMPDIR/create-relation.txt")"
[[ -n "$RELATION_ID" ]] || fail 'could not parse relation object id'

printf 'Seeding live space...\n'
oracle_seed_live_space "$MANYTYPE_HOME" "$NETWORK_CONFIG" 2

printf 'Creating target page...\n'
run_cli "$MANYTYPE_HOME" create "Phase40 Target" >"$TMPDIR/create-target.txt"
TARGET_ID="$(extract_created_id "$TMPDIR/create-target.txt")"
[[ -n "$TARGET_ID" ]] || fail 'could not parse target object id'

printf 'Writing file relation on HOME 1...\n'
HOME="$MANYTYPE_HOME" \
MANYTYPE_SYNC_CAPTURE_PATH="$SYNC_CAPTURE" \
MANYTYPE_FILE_TRANSFER_CAPTURE_PATH="$TRANSFER_CAPTURE" \
dart run "$ROOT_DIR/packages/manytype_cli/bin/manytype.dart" \
  --network-config "$NETWORK_CONFIG" \
  edit --id "$TARGET_ID" --relation "attachment" --file-relation "$PAYLOAD_FILE" \
  >"$EDIT_OUTPUT"

FILE_OBJECT_ID="$(sed -n 's/^FileObject: \([^ ]*\) .*/\1/p' "$EDIT_OUTPUT" | head -1)"
CID="$(sed -n 's/^FileObject: .*cid=\([^],]*\).*/\1/p' "$EDIT_OUTPUT" | head -1)"
[[ -n "$FILE_OBJECT_ID" ]] || fail 'could not parse FileObject ID from edit output'
[[ -n "$CID" ]] || fail 'could not parse CID from edit output'

printf 'Reading HOME 1...\n'
run_cli "$MANYTYPE_HOME" --network-config "$NETWORK_CONFIG" read "$TARGET_ID" >"$READ_HOME1"
grep -Fq "[attachment] $PAYLOAD_NAME (application/pdf)" "$READ_HOME1" || {
  cat "$READ_HOME1" >&2
  fail 'HOME 1 did not resolve the file relation'
}

printf 'Copying state to HOME 2 and syncing...\n'
cp -r "$MANYTYPE_HOME/.manytype" "$MANYTYPE_HOME_2/.manytype"
run_cli "$MANYTYPE_HOME_2" --network-config "$NETWORK_CONFIG" sync >/dev/null
run_cli "$MANYTYPE_HOME_2" --network-config "$NETWORK_CONFIG" read "$TARGET_ID" >"$READ_HOME2"
grep -Fq "[attachment] $PAYLOAD_NAME (application/pdf)" "$READ_HOME2" || {
  cat "$READ_HOME2" >&2
  fail 'HOME 2 did not resolve the file relation after sync'
}

ARTIFACT_JSON="$ROOT_DIR/test_vectors/phase40/file-relation-roundtrip.json"
ARTIFACT_SYNC="$ROOT_DIR/test_vectors/phase40/file-relation-roundtrip-sync.json"
ARTIFACT_TRANSFER="$ROOT_DIR/test_vectors/phase40/file-relation-roundtrip-transfer.json"
ARTIFACT_HOME1="$ROOT_DIR/test_vectors/phase40/read-home1.txt"
ARTIFACT_HOME2="$ROOT_DIR/test_vectors/phase40/read-home2.txt"
ARTIFACT_METADATA="$ROOT_DIR/test_vectors/phase40/runtime-metadata.json"

cp "$SYNC_CAPTURE" "$ARTIFACT_SYNC"
cp "$TRANSFER_CAPTURE" "$ARTIFACT_TRANSFER"
cp "$READ_HOME1" "$ARTIFACT_HOME1"
cp "$READ_HOME2" "$ARTIFACT_HOME2"

python3 - "$ARTIFACT_JSON" \
  "$RELATION_ID" \
  "$TARGET_ID" \
  "$FILE_OBJECT_ID" \
  "$CID" \
  "$PAYLOAD_NAME" \
  "$ARTIFACT_SYNC" \
  "$ARTIFACT_TRANSFER" \
  "$ARTIFACT_HOME1" \
  "$ARTIFACT_HOME2" \
  "$ARTIFACT_METADATA" <<'PY'
import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    relation_id,
    target_id,
    file_object_id,
    cid,
    payload_name,
    sync_capture_path,
    transfer_capture_path,
    read_home1_path,
    read_home2_path,
    metadata_path,
) = sys.argv[1:]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase40 file relation round-trip through docker any-sync",
    "relation_key": "attachment",
    "relation_object_id": relation_id,
    "target_object_id": target_id,
    "file_object_id": file_object_id,
    "cid": cid,
    "source_name": payload_name,
    "source_mime": "application/pdf",
    "expected_render": f"[attachment] {payload_name} (application/pdf)",
    "observed_on_home2": True,
    "manytype_sync_capture_path": sync_capture_path,
    "file_transfer_capture_path": transfer_capture_path,
    "read_home1_path": read_home1_path,
    "read_home2_path": read_home2_path,
    "metadata_path": metadata_path,
    "success": True,
}
pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

oracle_write_metadata \
  "$ARTIFACT_METADATA" \
  "phase40 file relation round-trip through the self-hosted official Any-Sync stack" \
  "$NETWORK_CONFIG" \
  "" \
  "$ARTIFACT_JSON" \
  "$ARTIFACT_SYNC" \
  "$ARTIFACT_TRANSFER" \
  "$ARTIFACT_HOME1" \
  "$ARTIFACT_HOME2"

printf '\nArtifacts written:\n'
printf '  %s\n' "$ARTIFACT_JSON"
printf '  %s\n' "$ARTIFACT_SYNC"
printf '  %s\n' "$ARTIFACT_TRANSFER"
printf '  %s\n' "$ARTIFACT_HOME1"
printf '  %s\n' "$ARTIFACT_HOME2"
printf '  %s\n' "$ARTIFACT_METADATA"
printf '\nphase40 harness: PASSED\n'
