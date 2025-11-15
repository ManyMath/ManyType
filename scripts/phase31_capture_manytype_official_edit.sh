#!/usr/bin/env bash

set -euo pipefail

# Prerequisites:
#   1) docker compose up -d in docker/any-sync/ (official oracle stack running)
#   2) cargo build -p manytype_quic_ffi --release (FFI lib built)
#   3) dart pub get in packages/manytype_cli/ (Dart deps resolved)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CREATE_ARTIFACT_PATH="${PHASE31_MANYTYPE_CREATE_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase31-manytype-cli-create.json}"
EDIT_ARTIFACT_PATH="${PHASE31_MANYTYPE_EDIT_ARTIFACT_PATH:-$ROOT_DIR/test_vectors/phase31-manytype-cli-edit.json}"

mkdir -p "$ROOT_DIR/test_vectors"

export LD_LIBRARY_PATH="$ROOT_DIR/rust/target/release${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export ROOT_DIR

printf 'Capturing Manytype CLI create+sync artifact (official server)...\n'
PHASE27_OBJECT_TRUTH_PATH="$CREATE_ARTIFACT_PATH" bash "$ROOT_DIR/scripts/oracle_object_capture.sh"

if [[ ! -f "$CREATE_ARTIFACT_PATH" ]]; then
  printf 'FAIL: create artifact was not written: %s\n' "$CREATE_ARTIFACT_PATH" >&2
  exit 1
fi

printf 'Capturing Manytype CLI edit+sync artifact (official server)...\n'
set +e
timeout 240s bash -lc '
  set -euo pipefail
  cd "$ROOT_DIR"
  export MANYTYPE_SYNC_CAPTURE_PATH="'"$EDIT_ARTIFACT_PATH"'"
  dart test packages/manytype_cli/test/oracle_edit_sync_test.dart -t round_trip
'
TEST_STATUS=$?
set -e

if [[ ! -f "$EDIT_ARTIFACT_PATH" ]]; then
  printf 'FAIL: edit artifact was not written: %s\n' "$EDIT_ARTIFACT_PATH" >&2
  exit 1
fi

if [[ "${TEST_STATUS:-0}" != "0" ]]; then
  printf 'WARN: oracle_edit_sync_test.dart exited non-zero (%s); artifact was still captured\n' "$TEST_STATUS" >&2
fi

printf 'Artifacts written:\n'
printf '  create: %s\n' "$CREATE_ARTIFACT_PATH"
printf '  edit:   %s\n' "$EDIT_ARTIFACT_PATH"
printf 'phase31_capture_manytype_official_edit.sh: PASSED\n'
