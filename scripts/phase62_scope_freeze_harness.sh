#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/self_hosted_oracle.sh"

ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase62"
ARTIFACT_PATH="$ARTIFACT_DIR/collection-slice-baseline.json"
RUNTIME_METADATA_PATH="$ARTIFACT_DIR/runtime-metadata.json"
NETWORK_CONFIG_SRC="$ROOT_DIR/docker/any-sync/etc/client.yml"
PHASE50_ARTIFACT="$ROOT_DIR/test_vectors/phase50/teardown-truth-baseline.json"
PHASE39_ADD_ARTIFACT="$ROOT_DIR/test_vectors/phase39/scenario_a_create_add.json"
PHASE39_REMOVE_ARTIFACT="$ROOT_DIR/test_vectors/phase39/scenario_b_remove.json"
PHASE39_MOVE_ARTIFACT="$ROOT_DIR/test_vectors/phase39/scenario_c_move.json"
PHASE42_M2O_COLLECTION="$ROOT_DIR/test_vectors/phase42/manytype_to_official_collection.json"
PHASE42_O2M_COLLECTION="$ROOT_DIR/test_vectors/phase42/official_to_manytype_collection.json"
PHASE38_STATUS_ARTIFACT="$ROOT_DIR/test_vectors/phase38/status-create.json"
PHASE38_TAG_ARTIFACT="$ROOT_DIR/test_vectors/phase38/tag-multi.json"
PHASE40_FILE_ARTIFACT="$ROOT_DIR/test_vectors/phase40/file-relation-roundtrip.json"
PHASE42_M2O_TEMPLATE="$ROOT_DIR/test_vectors/phase42/manytype_to_official_template.json"
PHASE42_O2M_TEMPLATE="$ROOT_DIR/test_vectors/phase42/official_to_manytype_template.json"
PHASE41_VERIFICATION="$ROOT_DIR/.planning/milestones/v2.5-phases/41-templates-creation-and-application/41-VERIFICATION.md"
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

printf '=== Phase 62: compound tranche freeze and oracle baseline ===\n\n'

mkdir -p "$ARTIFACT_DIR"

for required_path in \
  "$PHASE50_ARTIFACT" \
  "$PHASE39_ADD_ARTIFACT" \
  "$PHASE39_REMOVE_ARTIFACT" \
  "$PHASE39_MOVE_ARTIFACT" \
  "$PHASE42_M2O_COLLECTION" \
  "$PHASE42_O2M_COLLECTION" \
  "$PHASE38_STATUS_ARTIFACT" \
  "$PHASE38_TAG_ARTIFACT" \
  "$PHASE40_FILE_ARTIFACT" \
  "$PHASE42_M2O_TEMPLATE" \
  "$PHASE42_O2M_TEMPLATE" \
  "$PHASE41_VERIFICATION"; do
  [[ -f "$required_path" ]] || fail "missing evidence file: $required_path"
done

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
  "$PHASE39_ADD_ARTIFACT" \
  "$PHASE39_REMOVE_ARTIFACT" \
  "$PHASE39_MOVE_ARTIFACT" \
  "$PHASE42_M2O_COLLECTION" \
  "$PHASE42_O2M_COLLECTION" \
  "$PHASE38_STATUS_ARTIFACT" \
  "$PHASE38_TAG_ARTIFACT" \
  "$PHASE40_FILE_ARTIFACT" \
  "$PHASE42_M2O_TEMPLATE" \
  "$PHASE42_O2M_TEMPLATE" \
  "$PHASE41_VERIFICATION" \
  "$NETWORK_CONFIG_SRC" \
  "$RUNTIME_METADATA_PATH" <<'PY'
from __future__ import annotations

import datetime as dt
import json
import pathlib
import sys

(
    artifact_path,
    phase50_path,
    phase39_add_path,
    phase39_remove_path,
    phase39_move_path,
    phase42_m2o_collection_path,
    phase42_o2m_collection_path,
    phase38_status_path,
    phase38_tag_path,
    phase40_file_path,
    phase42_m2o_template_path,
    phase42_o2m_template_path,
    phase41_verification_path,
    network_config,
    metadata_path,
) = sys.argv[1:]

phase50 = json.loads(pathlib.Path(phase50_path).read_text())

artifact = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "scenario": "phase62 compound tranche freeze and oracle baseline",
    "accepted_slice": {
        "object_family": "collection smartblocks only",
        "mutation_family": "collection membership and ordering via StoreSliceUpdate",
        "container_object_type": "collection",
        "included_operations": [
            "create-collection",
            "collection-add",
            "collection-remove",
            "collection-move-front",
        ],
        "manytype_to_official_truth_surface": {
            "label": "self-hosted-official",
            "proof_mode": "official-object-show-and-restart-reread",
        },
        "official_to_manytype_truth_surface": {
            "label": "manytype_server",
            "proof_mode": "official-object-show-then-manytype-read-and-fresh-home-reread",
        },
        "excluded_variants": [
            "AccountDelete parity",
            "status/tag option flows",
            "file-as-relation binding",
            "template creation or application",
            "set-only source filters",
            "dataview configuration beyond bounded member membership/order",
            "live network.anytype.io milestone gating",
            "operator CLI expansion beyond the existing stable slice",
            "broader object families",
        ],
    },
    "candidate_ranking": [
        {
            "candidate": "collection-membership",
            "decision": "accepted",
            "rank": 1,
            "rationale": (
                "Already grounded locally and bidirectionally, with bounded add/remove/reorder "
                "operations and explicit final-state observation through official dataview order "
                "and Manytype member rereads."
            ),
            "evidence_paths": [
                phase39_add_path,
                phase39_remove_path,
                phase39_move_path,
                phase42_m2o_collection_path,
                phase42_o2m_collection_path,
            ],
        },
        {
            "candidate": "status-tag-option-flows",
            "decision": "deferred",
            "rank": 2,
            "rationale": (
                "Grounded, but the final-state contract spans relation parents, option objects, "
                "and resolution semantics, which is a broader first compound tranche than bounded "
                "collection membership/order."
            ),
            "evidence_paths": [
                phase38_status_path,
                phase38_tag_path,
            ],
        },
        {
            "candidate": "template-application",
            "decision": "deferred",
            "rank": 3,
            "rationale": (
                "Grounded, but the accepted surface would need to freeze type creation, template "
                "state, and applied-clone semantics together, which is a larger semantic boundary "
                "than collection membership/order."
            ),
            "evidence_paths": [
                phase41_verification_path,
                phase42_m2o_template_path,
                phase42_o2m_template_path,
            ],
        },
        {
            "candidate": "file-as-relation-binding",
            "decision": "deferred",
            "rank": 4,
            "rationale": (
                "Grounded, but it drags in file-node and payload-transfer semantics beyond the "
                "narrow collection contract accepted for v2.10."
            ),
            "evidence_paths": [
                phase40_file_path,
            ],
        },
    ],
    "scope_decisions": {
        "account_delete": {
            "decision": phase50["account_delete"]["decision"],
            "reason": phase50["account_delete"]["reason"],
            "official_capture_path": phase50["account_delete"]["official_capture_path"],
            "local_capture_path": phase50["account_delete"]["local_capture_path"],
            "source_phase50_path": phase50_path,
        },
        "official_to_manytype_server_requirement": {
            "official_post_mutation_reread_required": True,
            "fresh_home_reread_required": True,
            "diagnostics_requirement": (
                "Trace collection object, head, and observable member-order drift through "
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
        "phase39_add_path": phase39_add_path,
        "phase39_remove_path": phase39_remove_path,
        "phase39_move_path": phase39_move_path,
        "phase42_manytype_to_official_collection_path": phase42_m2o_collection_path,
        "phase42_official_to_manytype_collection_path": phase42_o2m_collection_path,
        "phase38_status_path": phase38_status_path,
        "phase38_tag_path": phase38_tag_path,
        "phase40_file_relation_path": phase40_file_path,
        "phase41_template_verification_path": phase41_verification_path,
        "phase42_manytype_to_official_template_path": phase42_m2o_template_path,
        "phase42_official_to_manytype_template_path": phase42_o2m_template_path,
    },
    "metadata_path": metadata_path,
    "success": True,
}

pathlib.Path(artifact_path).write_text(json.dumps(artifact, indent=2) + "\n")
PY

oracle_write_metadata \
  "$RUNTIME_METADATA_PATH" \
  "phase62 compound tranche freeze and oracle baseline" \
  "$NETWORK_CONFIG_SRC" \
  "$PROBE_BIN" \
  "$ARTIFACT_PATH" \
  "$PHASE50_ARTIFACT" \
  "$PHASE39_ADD_ARTIFACT" \
  "$PHASE39_REMOVE_ARTIFACT" \
  "$PHASE39_MOVE_ARTIFACT" \
  "$PHASE42_M2O_COLLECTION" \
  "$PHASE42_O2M_COLLECTION"

printf 'Phase 62 artifact written to %s\n' "$ARTIFACT_PATH"
printf 'phase62 harness: PASSED\n'
