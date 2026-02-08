#!/usr/bin/env python3

"""Offline verifier for the Phase 61 v2.9 sign-off report."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_REPORT = ROOT / "test_vectors" / "phase61" / "v29-signoff.json"
PHASE58_ARTIFACT = ROOT / "test_vectors" / "phase58" / "bounded-delete-baseline.json"
PHASE59_ARTIFACT = ROOT / "test_vectors" / "phase59" / "self-hosted-delete-compatibility.json"
PHASE60_ARTIFACT = ROOT / "test_vectors" / "phase60" / "manytype-server-delete-compatibility.json"
PHASE58_METADATA = ROOT / "test_vectors" / "phase58" / "runtime-metadata.json"
PHASE59_METADATA = ROOT / "test_vectors" / "phase59" / "runtime-metadata.json"
PHASE60_METADATA = ROOT / "test_vectors" / "phase60" / "runtime-metadata.json"


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


def validate_metadata_drift(
    report: dict,
    metadata: dict,
    label: str,
) -> None:
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
    if metadata_binaries["manytype_quic_ffi"]["sha256"] != current_binaries["manytype_quic_ffi_release"]["sha256"]:
        raise SystemExit(f"[{label}] manytype_quic_ffi drift detected")
    if metadata_binaries["manytype_server_debug"]["sha256"] != current_binaries["manytype_server_debug"]["sha256"]:
        raise SystemExit(f"[{label}] manytype_server_debug drift detected")


def validate_freshness(
    report: dict,
    phase58: dict,
    phase59: dict,
    phase60: dict,
    metadata_files: list[tuple[str, dict]],
) -> None:
    signoff_at = parse_iso8601(report["captured_at"])
    signoff_started_at = parse_iso8601(report["signoff_started_at"])
    freshness_window = int(report["freshness_window_seconds"])

    for label, artifact in (
        ("phase58", phase58),
        ("phase59", phase59),
        ("phase60", phase60),
    ):
        artifact_at = parse_iso8601(artifact["captured_at"])
        age = (signoff_at - artifact_at).total_seconds()
        if age < 0 or age > freshness_window:
            raise SystemExit(f"[phase61 signoff] {label} artifact freshness window exceeded: {age:.0f}s")
        if artifact_at < signoff_started_at - dt.timedelta(seconds=freshness_window):
            raise SystemExit(f"[phase61 signoff] {label} artifact predates sign-off start too far")

    for label, metadata in metadata_files:
        metadata_at = parse_iso8601(metadata["captured_at"])
        age = (signoff_at - metadata_at).total_seconds()
        if age < 0 or age > freshness_window:
            raise SystemExit(f"[phase61 signoff] {label} metadata freshness window exceeded: {age:.0f}s")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 61 v2.9 sign-off report."
    )
    parser.add_argument(
        "--report",
        default=str(DEFAULT_REPORT),
        help="Path to the Phase 61 sign-off report.",
    )
    args = parser.parse_args()

    report = load_json(pathlib.Path(args.report))
    phase58 = load_json(PHASE58_ARTIFACT)
    phase59 = load_json(PHASE59_ARTIFACT)
    phase60 = load_json(PHASE60_ARTIFACT)
    phase58_metadata = load_json(PHASE58_METADATA)
    phase59_metadata = load_json(PHASE59_METADATA)
    phase60_metadata = load_json(PHASE60_METADATA)

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
        "phase61 signoff",
    )
    if report["scenario"] != "v2.9 wider matrix and split sign-off":
        raise SystemExit("[phase61 signoff] unexpected scenario")
    if report["success"] is not True:
        raise SystemExit("[phase61 signoff] success != true")
    if report["requirements_completed"] != ["COMP-05", "COMP-06", "COMP-07", "COMP-08"]:
        raise SystemExit("[phase61 signoff] unexpected requirements_completed")

    accepted_slice = report["accepted_slice"]
    if accepted_slice.get("mutation_family") != "archive-backed object deletion":
        raise SystemExit("[phase61 signoff] accepted slice mutation family drift detected")
    if accepted_slice.get("bounded_object_type") != "page":
        raise SystemExit("[phase61 signoff] accepted slice bounded object type drift detected")

    official_track = report["official_stack_track"]
    manytype_server_track = report["manytype_server_track"]
    if official_track.get("status") != "passed":
        raise SystemExit("[phase61 signoff] official_stack_track status != passed")
    if manytype_server_track.get("status") != "passed":
        raise SystemExit("[phase61 signoff] manytype_server_track status != passed")

    official_scenarios = official_track.get("scenarios", [])
    if len(official_scenarios) != 1:
        raise SystemExit("[phase61 signoff] expected exactly one official-stack scenario")
    if official_scenarios[0].get("truth_surface") != phase59["truth_surface"]:
        raise SystemExit("[phase61 signoff] official-stack truth surface mismatch")

    local_scenarios = manytype_server_track.get("scenarios", [])
    if len(local_scenarios) != 1:
        raise SystemExit("[phase61 signoff] expected exactly one manytype_server scenario")
    if local_scenarios[0].get("truth_surface") != phase60["truth_surface"]:
        raise SystemExit("[phase61 signoff] manytype_server truth surface mismatch")
    diagnostics_path = pathlib.Path(local_scenarios[0]["diagnostics_path"])
    if not diagnostics_path.exists():
        raise SystemExit(f"[phase61 signoff] missing diagnostics file: {diagnostics_path}")

    scope = report["scope_and_baseline"]
    if scope.get("phase") != 58:
        raise SystemExit("[phase61 signoff] expected scope_and_baseline.phase == 58")
    if scope["account_delete"]["decision"] != "defer":
        raise SystemExit("[phase61 signoff] account_delete decision drift detected")

    validate_freshness(
        report,
        phase58,
        phase59,
        phase60,
        [
            ("phase58", phase58_metadata),
            ("phase59", phase59_metadata),
            ("phase60", phase60_metadata),
        ],
    )
    validate_metadata_drift(report, phase58_metadata, "phase58 metadata")
    validate_metadata_drift(report, phase59_metadata, "phase59 metadata")
    validate_metadata_drift(report, phase60_metadata, "phase60 metadata")

    expected_verifiers = [
        "scripts/verify_phase58_scope_freeze.py",
        "scripts/verify_phase59_self_hosted_delete.py",
        "scripts/verify_phase60_manytype_server_delete.py",
        "scripts/verify_self_hosted_oracle_metadata.py",
        "scripts/verify_phase61_signoff.py",
    ]
    if report["verifiers"] != expected_verifiers:
        raise SystemExit("[phase61 signoff] verifier list drift detected")

    print("[phase61 signoff] ok")
    print("phase61 signoff: PASSED")


if __name__ == "__main__":
    main()
