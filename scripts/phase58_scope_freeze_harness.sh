#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase58"
ARTIFACT_PATH="$ARTIFACT_DIR/bounded-delete-baseline.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
PHASE50_ARTIFACT="$ROOT_DIR/test_vectors/phase50/teardown-truth-baseline.json"
PHASE47_ARTIFACT="$ROOT_DIR/test_vectors/phase47/object-deletion-roundtrip.json"
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

printf '=== Phase 58: bounded delete tranche freeze and oracle baseline ===\n\n'

mkdir -p "$ARTIFACT_DIR"

[[ -f "$PHASE50_ARTIFACT" ]] || fail "missing Phase 50 artifact: $PHASE50_ARTIFACT"
[[ -f "$PHASE47_ARTIFACT" ]] || fail "missing Phase 47 artifact: $PHASE47_ARTIFACT"

oracle_run_preflight
oracle_export_runtime_env

rm -f "$ARTIFACT_DIR"/*.json

printf 'Building probe binary for runtime metadata...\n'
oracle_build_probe_binary "$PROBE_BIN"

[[ -f "$NETWORK_CONFIG_SRC" ]] || fail "missing network config: $NETWORK_CONFIG_SRC"
[[ -s "$NETWORK_CONFIG_SRC" ]] || fail "empty network config: $NETWORK_CONFIG_SRC"

python3 - \
  "$ARTIFACT_PATH" \
  "$PHASE50_ARTIFACT" \
  "$PHASE47_ARTIFACT" \
  "$NETWORK_CONFIG_SRC" \
  "$RUNTIME_METADATA_PATH" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import sys

artifact_path, phase50_path, phase47_path, network_config, metadata_path = sys.argv[1:]

phase50 = json.loads(pathlib.Path(phase50_path).read_text())
phase47 = json.loads(pathlib.Path(phase47_path).read_text())

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase58 bounded delete tranche freeze and oracle baseline",
    "accepted_slice": {
        "object_family": "page-rooted objects only",
        "mutation_family": "archive-backed object deletion",
        "bounded_object_type": "page",
        "manytype_to_official_truth_surface": {
            "label": "self-hosted-official",
            "proof_mode": "official-object-search-absence-and-restart-reread",
        },
        "official_to_manytype_truth_surface": {
            "label": "manytype_server",
            "proof_mode": "manytype-list-absence-read-refusal-and-fresh-home-reread",
        },
        "excluded_variants": [
            "AccountDelete parity",
            "SpaceDelete parity changes beyond the shipped bounded command surface",
            "broader object families",
            "additional root-detail edits beyond delete/archive semantics",
            "network.anytype.io milestone gating",
            "operator CLI expansion beyond the existing stable slice",
        ],
    },
    "scope_decisions": {
        "account_delete": {
            "decision": phase50["account_delete"]["decision"],
            "reason": phase50["account_delete"]["reason"],
            "official_capture_path": phase50["account_delete"]["official_capture_path"],
            "local_capture_path": phase50["account_delete"]["local_capture_path"],
            "source_phase50_path": phase50_path,
        },
        "official_to_manytype_server_requirement": {
            "manytype_list_absence_required": True,
            "manytype_read_refusal_required": True,
            "fresh_home_reread_required": True,
            "diagnostics_requirement": (
                "Trace object, head, and observable-state drift through "
                "repo-owned diagnostics instead of raw server logs alone."
            ),
        },
    },
    "oracle_baseline": {
        "preflight": "passed",
        "network_config_path": network_config,
        "client_yml_ready": True,
        "exercised_binaries": [
            "rust/target/release/libmanytype_quic_ffi.so",
            "rust/target/debug/manytype_server",
            "scripts/official_client_grpc_probe",
        ],
    },
    "evidence_references": {
        "phase47_bundle_path": phase47_path,
        "phase47_manytype_to_official_presence_search_path": (
            phase47["manytype_to_official"]["presence_search_path"]
        ),
        "phase47_manytype_to_official_absence_search_path": (
            phase47["manytype_to_official"]["absence_search_path"]
        ),
        "phase47_manytype_to_official_restart_absence_search_path": (
            phase47["manytype_to_official"]["restart_absence_search_path"]
        ),
        "phase47_official_to_manytype_predelete_read_path": (
            phase47["official_to_manytype"]["predelete_read_path"]
        ),
        "phase47_official_to_manytype_list_absence_path": (
            phase47["official_to_manytype"]["list_absence_path"]
        ),
        "phase47_official_to_manytype_read_refusal_path": (
            phase47["official_to_manytype"]["read_refusal_path"]
        ),
        "phase47_official_to_manytype_reopen_read_refusal_path": (
            phase47["official_to_manytype"]["reopen_read_refusal_path"]
        ),
    },
    "metadata_path": metadata_path,
    "success": True,
}

pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase58 bounded delete tranche freeze and oracle baseline" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$ARTIFACT_PATH" \
  "$PHASE50_ARTIFACT" \
  "$PHASE47_ARTIFACT"

printf 'Phase 58 artifact written to %s\n' "$ARTIFACT_PATH"
printf 'phase58 harness: PASSED\n'
