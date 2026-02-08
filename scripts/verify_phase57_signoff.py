#!/usr/bin/env python3

"""Offline verifier for the Phase 57 v2.8 sign-off report."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_REPORT = ROOT / "test_vectors" / "phase57" / "v28-signoff.json"
PHASE54_ARTIFACT = ROOT / "test_vectors" / "phase54" / "compatibility-slice-baseline.json"
PHASE55_ARTIFACT = ROOT / "test_vectors" / "phase55" / "self-hosted-compatibility.json"
PHASE56_ARTIFACT = ROOT / "test_vectors" / "phase56" / "manytype-server-compatibility.json"
PHASE54_METADATA = ROOT / "test_vectors" / "phase54" / "runtime-metadata.json"
PHASE55_METADATA = ROOT / "test_vectors" / "phase55" / "runtime-metadata.json"
PHASE56_METADATA = ROOT / "test_vectors" / "phase56" / "runtime-metadata.json"


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
    phase54: dict,
    phase55: dict,
    phase56: dict,
    metadata_files: list[dict],
) -> None:
    signoff_at = parse_iso8601(report["captured_at"])
    signoff_started_at = parse_iso8601(report["signoff_started_at"])
    freshness_window = int(report["freshness_window_seconds"])

    for label, artifact in (
        ("phase54", phase54),
        ("phase55", phase55),
        ("phase56", phase56),
    ):
        artifact_at = parse_iso8601(artifact["captured_at"])
        age = (signoff_at - artifact_at).total_seconds()
        if age < 0 or age > freshness_window:
            raise SystemExit(f"[phase57 signoff] {label} artifact freshness window exceeded: {age:.0f}s")
        if artifact_at < signoff_started_at - dt.timedelta(seconds=freshness_window):
            raise SystemExit(f"[phase57 signoff] {label} artifact predates sign-off start too far")

    for label, metadata in metadata_files:
        metadata_at = parse_iso8601(metadata["captured_at"])
        age = (signoff_at - metadata_at).total_seconds()
        if age < 0 or age > freshness_window:
            raise SystemExit(f"[phase57 signoff] {label} metadata freshness window exceeded: {age:.0f}s")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 57 v2.8 sign-off report."
    )
    parser.add_argument(
        "--report",
        default=str(DEFAULT_REPORT),
        help="Path to the Phase 57 sign-off report.",
    )
    args = parser.parse_args()

    report = load_json(pathlib.Path(args.report))
    phase54 = load_json(PHASE54_ARTIFACT)
    phase55 = load_json(PHASE55_ARTIFACT)
    phase56 = load_json(PHASE56_ARTIFACT)
    phase54_metadata = load_json(PHASE54_METADATA)
    phase55_metadata = load_json(PHASE55_METADATA)
    phase56_metadata = load_json(PHASE56_METADATA)

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
        "phase57 signoff",
    )
    if report["scenario"] != "v2.8 wider matrix and split sign-off":
        raise SystemExit("[phase57 signoff] unexpected scenario")
    if report["success"] is not True:
        raise SystemExit("[phase57 signoff] success != true")
    if report["requirements_completed"] != ["COMP-01", "COMP-02", "COMP-03", "COMP-04"]:
        raise SystemExit("[phase57 signoff] unexpected requirements_completed")

    accepted_slice = report["accepted_slice"]
    if accepted_slice.get("detail_keys") != ["description", "featuredRelations"]:
        raise SystemExit("[phase57 signoff] accepted slice detail keys drift detected")
    if accepted_slice.get("featured_relations_value") != ["description", "sourceObject"]:
        raise SystemExit("[phase57 signoff] accepted slice featuredRelations drift detected")

    official_track = report["official_stack_track"]
    manytype_server_track = report["manytype_server_track"]
    if official_track.get("status") != "passed":
        raise SystemExit("[phase57 signoff] official_stack_track status != passed")
    if manytype_server_track.get("status") != "passed":
        raise SystemExit("[phase57 signoff] manytype_server_track status != passed")

    official_scenarios = official_track.get("scenarios", [])
    if len(official_scenarios) != 1:
        raise SystemExit("[phase57 signoff] expected exactly one official-stack scenario")
    if official_scenarios[0].get("truth_surface") != phase55["truth_surface"]:
        raise SystemExit("[phase57 signoff] official-stack truth surface mismatch")

    local_scenarios = manytype_server_track.get("scenarios", [])
    if len(local_scenarios) != 1:
        raise SystemExit("[phase57 signoff] expected exactly one manytype_server scenario")
    if local_scenarios[0].get("truth_surface") != phase56["truth_surface"]:
        raise SystemExit("[phase57 signoff] manytype_server truth surface mismatch")
    diagnostics_path = pathlib.Path(local_scenarios[0]["diagnostics_path"])
    if not diagnostics_path.exists():
        raise SystemExit(f"[phase57 signoff] missing diagnostics file: {diagnostics_path}")

    scope = report["scope_and_baseline"]
    if scope.get("phase") != 54:
        raise SystemExit("[phase57 signoff] expected scope_and_baseline.phase == 54")
    if scope["account_delete"]["decision"] != "defer":
        raise SystemExit("[phase57 signoff] account_delete decision drift detected")

    validate_freshness(
        report,
        phase54,
        phase55,
        phase56,
        [
            ("phase54", phase54_metadata),
            ("phase55", phase55_metadata),
            ("phase56", phase56_metadata),
        ],
    )
    validate_metadata_drift(report, phase54_metadata, "phase54 metadata")
    validate_metadata_drift(report, phase55_metadata, "phase55 metadata")
    validate_metadata_drift(report, phase56_metadata, "phase56 metadata")

    expected_verifiers = [
        "scripts/verify_phase54_scope_freeze.py",
        "scripts/verify_phase55_self_hosted_compat.py",
        "scripts/verify_phase56_manytype_server_compat.py",
        "scripts/verify_self_hosted_oracle_metadata.py",
        "scripts/verify_phase57_signoff.py",
    ]
    if report["verifiers"] != expected_verifiers:
        raise SystemExit("[phase57 signoff] verifier list drift detected")

    print("[phase57 signoff] ok")
    print("phase57 signoff: PASSED")


if __name__ == "__main__":
    main()
