#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase55"
ARTIFACT_PATH="$ARTIFACT_DIR/self-hosted-compatibility.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
PHASE46_BUNDLE="$ROOT_DIR/test_vectors/phase46/bounded-object-edit-roundtrip.json"
PHASE46_SHOW="$ROOT_DIR/test_vectors/phase46/manytype_to_official_show.json"
PHASE46_RESTART_SHOW="$ROOT_DIR/test_vectors/phase46/manytype_to_official_restart-show.json"
PHASE46_SYNC="$ROOT_DIR/test_vectors/phase46/manytype_to_official_sync.json"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
TMPDIR="$(mktemp -d)"
PROBE_BIN="$TMPDIR/official_client_grpc_probe"

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

printf '=== Phase 55: Manytype -> official self-hosted compatibility ===\n\n'

mkdir -p "$ARTIFACT_DIR"

oracle_run_preflight
oracle_export_runtime_env

rm -f "$ARTIFACT_DIR"/*.json

printf 'Building probe binary for runtime metadata...\n'
oracle_build_probe_binary "$PROBE_BIN"

printf 'Refreshing the accepted self-hosted bounded-detail proof...\n'
bash "$ROOT_DIR/scripts/phase46_bounded_object_edit_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase46_artifacts.py"

[[ -f "$PHASE46_BUNDLE" ]] || fail "missing Phase 46 bundle after refresh: $PHASE46_BUNDLE"

cp -f "$PHASE46_SHOW" "$ARTIFACT_DIR/manytype_to_official_show.json"
cp -f "$PHASE46_RESTART_SHOW" "$ARTIFACT_DIR/manytype_to_official_restart-show.json"
cp -f "$PHASE46_SYNC" "$ARTIFACT_DIR/manytype_to_official_sync.json"

python3 - \
  "$PHASE46_BUNDLE" \
  "$ARTIFACT_PATH" \
  "$ARTIFACT_DIR/manytype_to_official_show.json" \
  "$ARTIFACT_DIR/manytype_to_official_restart-show.json" \
  "$ARTIFACT_DIR/manytype_to_official_sync.json" \
  "$RUNTIME_METADATA_PATH" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import sys

(
    phase46_bundle,
    artifact_path,
    show_path,
    restart_show_path,
    sync_path,
    metadata_path,
) = sys.argv[1:]

bundle = json.loads(pathlib.Path(phase46_bundle).read_text())
scenario = bundle["manytype_to_official"]

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase55 manytype to official self-hosted compatibility",
    "accepted_slice": {
        "object_family": "page-rooted objects only",
        "detail_keys": ["description", "featuredRelations"],
        "featured_relations_value": ["description", "sourceObject"],
        "proof_mode": "official-object-show-and-restart-reread",
    },
    "truth_surface": "self-hosted-official",
    "manytype_to_official": {
        "object_id": scenario["object_id"],
        "description": scenario["description"],
        "featured_relations": ["description", "sourceObject"],
        "show_path": show_path,
        "restart_show_path": restart_show_path,
        "sync_capture_path": sync_path,
    },
    "phase46_bundle_path": phase46_bundle,
    "metadata_path": metadata_path,
    "success": True,
}

pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase55 manytype to official self-hosted compatibility" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$ARTIFACT_PATH" \
  "$ARTIFACT_DIR/manytype_to_official_show.json" \
  "$ARTIFACT_DIR/manytype_to_official_restart-show.json" \
  "$ARTIFACT_DIR/manytype_to_official_sync.json"

printf 'Phase 55 artifact written to %s\n' "$ARTIFACT_PATH"
printf 'phase55 harness: PASSED\n'
