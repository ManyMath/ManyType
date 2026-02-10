#!/usr/bin/env python3

"""Offline verifier for the Phase 65 v2.10 sign-off report."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_REPORT = ROOT / "test_vectors" / "phase65" / "v210-signoff.json"
PHASE62_ARTIFACT = ROOT / "test_vectors" / "phase62" / "collection-slice-baseline.json"
PHASE63_ARTIFACT = ROOT / "test_vectors" / "phase63" / "self-hosted-collection-compatibility.json"
PHASE64_ARTIFACT = (
    ROOT / "test_vectors" / "phase64" / "manytype-server-collection-compatibility.json"
)
PHASE62_METADATA = ROOT / "test_vectors" / "phase62" / "runtime-metadata.json"
PHASE63_METADATA = ROOT / "test_vectors" / "phase63" / "runtime-metadata.json"
PHASE64_METADATA = ROOT / "test_vectors" / "phase64" / "runtime-metadata.json"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    return json.loads(path.read_text())


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def parse_iso8601(value: str) -> dt.datetime:
    return dt.datetime.fromisoformat(value.replace("Z", "+00:00"))


def validate_metadata_drift(report: dict, metadata: dict, label: str) -> None:
    current_lock = report["current_inputs"]["oracle_lock"]
    metadata_lock = metadata["oracle_lock"]
    if metadata_lock["anytype_cli_image"] != current_lock["anytype_cli_image"]:
        raise SystemExit(f"[{label}] anytype_cli_image drift detected")
    if metadata_lock["anytype_cli_revision"] != current_lock["anytype_cli_revision"]:
        raise SystemExit(f"[{label}] anytype_cli_revision drift detected")
    if metadata_lock["any_sync_versions"] != current_lock["any_sync_versions"]:
        raise SystemExit(f"[{label}] any_sync_versions drift detected")

    current_binaries = report["current_inputs"]["binaries"]
    metadata_binaries = metadata["binaries"]
    if (
        metadata_binaries["manytype_quic_ffi"]["sha256"]
        != current_binaries["manytype_quic_ffi_release"]["sha256"]
    ):
        raise SystemExit(f"[{label}] manytype_quic_ffi drift detected")
    if (
        metadata_binaries["manytype_server_debug"]["sha256"]
        != current_binaries["manytype_server_debug"]["sha256"]
    ):
        raise SystemExit(f"[{label}] manytype_server_debug drift detected")


def validate_freshness(
    report: dict,
    phase62: dict,
    phase63: dict,
    phase64: dict,
    metadata_files: list[tuple[str, dict]],
) -> None:
    signoff_at = parse_iso8601(report["captured_at"])
    signoff_started_at = parse_iso8601(report["signoff_started_at"])
    freshness_window = int(report["freshness_window_seconds"])

    for label, artifact in (
        ("phase62", phase62),
        ("phase63", phase63),
        ("phase64", phase64),
    ):
        artifact_at = parse_iso8601(artifact["captured_at"])
        age = (signoff_at - artifact_at).total_seconds()
        if age < 0 or age > freshness_window:
            raise SystemExit(f"[phase65 signoff] {label} artifact freshness window exceeded: {age:.0f}s")
        if artifact_at < signoff_started_at - dt.timedelta(seconds=freshness_window):
            raise SystemExit(f"[phase65 signoff] {label} artifact predates sign-off start too far")

    for label, metadata in metadata_files:
        metadata_at = parse_iso8601(metadata["captured_at"])
        age = (signoff_at - metadata_at).total_seconds()
        if age < 0 or age > freshness_window:
            raise SystemExit(f"[phase65 signoff] {label} metadata freshness window exceeded: {age:.0f}s")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 65 v2.10 sign-off report."
    )
    parser.add_argument(
        "--report",
        default=str(DEFAULT_REPORT),
        help="Path to the Phase 65 sign-off report.",
    )
    args = parser.parse_args()

    report = load_json(pathlib.Path(args.report))
    phase62 = load_json(PHASE62_ARTIFACT)
    phase63 = load_json(PHASE63_ARTIFACT)
    phase64 = load_json(PHASE64_ARTIFACT)
    phase62_metadata = load_json(PHASE62_METADATA)
    phase63_metadata = load_json(PHASE63_METADATA)
    phase64_metadata = load_json(PHASE64_METADATA)

    require_keys(
        report,
        {
            "captured_at",
            "signoff_started_at",
            "scenario",
            "requirements_completed",
            "freshness_window_seconds",
            "accepted_slice",
            "current_inputs",
            "scope_and_baseline",
            "official_stack_track",
            "manytype_server_track",
            "verifiers",
            "success",
        },
        "phase65 signoff",
    )
    if report["scenario"] != "v2.10 wider matrix and split sign-off":
        raise SystemExit("[phase65 signoff] unexpected scenario")
    if report["success"] is not True:
        raise SystemExit("[phase65 signoff] success != true")
    if report["requirements_completed"] != ["COMP-09", "COMP-10", "COMP-11", "COMP-12"]:
        raise SystemExit("[phase65 signoff] unexpected requirements_completed")

    accepted_slice = report["accepted_slice"]
    if accepted_slice.get("container_object_type") != "collection":
        raise SystemExit("[phase65 signoff] accepted slice container_object_type drift detected")
    if accepted_slice.get("included_operations") != [
        "create-collection",
        "collection-add",
        "collection-remove",
        "collection-move-front",
    ]:
        raise SystemExit("[phase65 signoff] accepted slice included_operations drift detected")

    official_track = report["official_stack_track"]
    manytype_server_track = report["manytype_server_track"]
    if official_track.get("status") != "passed":
        raise SystemExit("[phase65 signoff] official_stack_track status != passed")
    if manytype_server_track.get("status") != "passed":
        raise SystemExit("[phase65 signoff] manytype_server_track status != passed")

    official_scenarios = official_track.get("scenarios", [])
    if len(official_scenarios) != 1:
        raise SystemExit("[phase65 signoff] expected exactly one official-stack scenario")
    if official_scenarios[0].get("truth_surface") != phase63["truth_surface"]:
        raise SystemExit("[phase65 signoff] official-stack truth surface mismatch")

    local_scenarios = manytype_server_track.get("scenarios", [])
    if len(local_scenarios) != 1:
        raise SystemExit("[phase65 signoff] expected exactly one manytype_server scenario")
    if local_scenarios[0].get("truth_surface") != phase64["truth_surface"]:
        raise SystemExit("[phase65 signoff] manytype_server truth surface mismatch")
    diagnostics_path = pathlib.Path(local_scenarios[0]["diagnostics_path"])
    if not diagnostics_path.exists():
        raise SystemExit(f"[phase65 signoff] missing diagnostics file: {diagnostics_path}")

    scope = report["scope_and_baseline"]
    if scope.get("phase") != 62:
        raise SystemExit("[phase65 signoff] expected scope_and_baseline.phase == 62")
    if scope["account_delete"]["decision"] != "defer":
        raise SystemExit("[phase65 signoff] account_delete decision drift detected")
    if scope.get("candidate_ranking", [])[0].get("candidate") != "collection-membership":
        raise SystemExit("[phase65 signoff] candidate ranking drift detected")

    validate_freshness(
        report,
        phase62,
        phase63,
        phase64,
        [
            ("phase62", phase62_metadata),
            ("phase63", phase63_metadata),
            ("phase64", phase64_metadata),
        ],
    )
    validate_metadata_drift(report, phase62_metadata, "phase62 metadata")
    validate_metadata_drift(report, phase63_metadata, "phase63 metadata")
    validate_metadata_drift(report, phase64_metadata, "phase64 metadata")

    expected_verifiers = [
        "scripts/verify_phase62_scope_freeze.py",
        "scripts/verify_phase63_self_hosted_collection_compat.py",
        "scripts/verify_phase64_manytype_server_collection_compat.py",
        "scripts/verify_self_hosted_oracle_metadata.py",
        "scripts/verify_phase65_signoff.py",
    ]
    if report["verifiers"] != expected_verifiers:
        raise SystemExit("[phase65 signoff] verifier list drift detected")

    print("[phase65 signoff] ok")
    print("phase65 signoff: PASSED")


if __name__ == "__main__":
    main()
