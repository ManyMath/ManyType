#!/usr/bin/env python3

"""Offline verifier for the Phase 49 v2.6 sign-off report."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import pathlib
import subprocess


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_REPORT = ROOT / "test_vectors" / "phase49" / "v26-signoff.json"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def parse_env_file(path: pathlib.Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip().strip('"')
    return values


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def run_checked(args: list[str], label: str) -> str:
    result = subprocess.run(
        args,
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise SystemExit(
            f"[{label}] command failed ({result.returncode})\n"
            f"STDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}"
        )
    return result.stdout.strip()


def parse_iso8601(value: str) -> dt.datetime:
    return dt.datetime.fromisoformat(value.replace("Z", "+00:00"))


def compare_binary_record(record: dict, actual_path: pathlib.Path, label: str) -> None:
    require_keys(record, {"path", "exists", "sha256", "mtime", "size"}, label)
    if record.get("exists") is not True:
        raise SystemExit(f"[{label}] exists is not true")
    if not actual_path.exists():
        raise SystemExit(f"[{label}] current file missing: {actual_path}")
    expected_path = str(actual_path.relative_to(ROOT))
    if record["path"] != expected_path:
        raise SystemExit(f"[{label}] path mismatch: {record['path']!r} != {expected_path!r}")
    actual_sha = sha256(actual_path)
    if record["sha256"] != actual_sha:
        raise SystemExit(f"[{label}] sha256 mismatch")
    if record["size"] != actual_path.stat().st_size:
        raise SystemExit(f"[{label}] size mismatch")


def verify_runtime_metadata_against_current(path: pathlib.Path, current_lock: dict[str, str]) -> None:
    data = load_json(path)
    label = f"runtime metadata {path.name}"
    require_keys(
        data,
        {"oracle_lock", "official_cli", "binaries", "network_config", "captured_at"},
        label,
    )

    oracle_lock = data["oracle_lock"]
    require_keys(
        oracle_lock,
        {"any_sync_versions", "anytype_cli_image", "anytype_cli_tag", "anytype_cli_revision"},
        f"{label}.oracle_lock",
    )
    expected_versions = {
        key: current_lock.get(key, "")
        for key in (
            "ANY_SYNC_NODE_VERSION",
            "ANY_SYNC_FILENODE_VERSION",
            "ANY_SYNC_COORDINATOR_VERSION",
            "ANY_SYNC_CONSENSUSNODE_VERSION",
        )
    }
    if oracle_lock["any_sync_versions"] != expected_versions:
        raise SystemExit(f"[{label}] any-sync version drift detected")
    if oracle_lock["anytype_cli_image"] != current_lock.get("ANYTYPE_CLI_IMAGE", ""):
        raise SystemExit(f"[{label}] anytype_cli_image drift detected")
    if oracle_lock["anytype_cli_tag"] != current_lock.get("ANYTYPE_CLI_TAG", ""):
        raise SystemExit(f"[{label}] anytype_cli_tag drift detected")
    if oracle_lock["anytype_cli_revision"] != current_lock.get("ANYTYPE_CLI_REVISION", ""):
        raise SystemExit(f"[{label}] anytype_cli_revision drift detected")

    official_cli = data["official_cli"]
    require_keys(official_cli, {"repo_digest"}, f"{label}.official_cli")
    if official_cli["repo_digest"] != current_lock.get("ANYTYPE_CLI_IMAGE", ""):
        raise SystemExit(f"[{label}] official_cli repo_digest drift detected")

    binaries = data["binaries"]
    require_keys(
        binaries,
        {"manytype_quic_ffi", "manytype_server_debug", "official_client_probe"},
        f"{label}.binaries",
    )
    ffi_path = ROOT / "rust" / "target" / "release" / "libmanytype_quic_ffi.so"
    if binaries["manytype_quic_ffi"].get("sha256") != sha256(ffi_path):
        raise SystemExit(f"[{label}] manytype_quic_ffi drift detected")

    debug_path = ROOT / "rust" / "target" / "debug" / "manytype_server"
    if binaries["manytype_server_debug"].get("sha256") != sha256(debug_path):
        raise SystemExit(f"[{label}] manytype_server_debug drift detected")


def verify_freshness(report: dict, paths: list[pathlib.Path], label: str) -> None:
    signoff_at = parse_iso8601(report["captured_at"])
    max_age = int(report["freshness_window_seconds"])
    for path in paths:
        data = load_json(path)
        captured_at = data.get("captured_at")
        if not captured_at:
            raise SystemExit(f"[{label}] missing captured_at in {path}")
        artifact_at = parse_iso8601(captured_at)
        age = (signoff_at - artifact_at).total_seconds()
        if age < 0:
            raise SystemExit(f"[{label}] artifact captured after sign-off: {path}")
        if age > max_age:
            raise SystemExit(
                f"[{label}] stale artifact {path} age {int(age)}s exceeds {max_age}s"
            )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 49 v2.6 sign-off report."
    )
    parser.add_argument(
        "--report",
        default=str(DEFAULT_REPORT),
        help="Path to the Phase 49 sign-off report.",
    )
    args = parser.parse_args()

    report_path = pathlib.Path(args.report)
    report = load_json(report_path)
    require_keys(
        report,
        {
            "captured_at",
            "signoff_started_at",
            "scenario",
            "requirements_completed",
            "freshness_window_seconds",
            "current_inputs",
            "official_stack_track",
            "manytype_server_track",
            "verifiers",
            "success",
        },
        "phase49 signoff",
    )
    if report["scenario"] != "v2.6 regression lock and milestone sign-off":
        raise SystemExit("[phase49 signoff] unexpected scenario")
    if report["success"] is not True:
        raise SystemExit("[phase49 signoff] success != true")
    if sorted(report["requirements_completed"]) != ["V26-01", "V26-02", "V26-03", "V26-04"]:
        raise SystemExit("[phase49 signoff] unexpected requirements_completed")

    current_inputs = report["current_inputs"]
    require_keys(
        current_inputs,
        {"git", "oracle_lock", "phase45_anytype_image", "binaries"},
        "phase49 current_inputs",
    )
    current_lock = parse_env_file(ROOT / "docker" / "any-sync" / "oracle.lock.env")
    oracle_lock = current_inputs["oracle_lock"]
    require_keys(
        oracle_lock,
        {"path", "any_sync_versions", "anytype_cli_image", "anytype_cli_tag", "anytype_cli_revision"},
        "phase49 current_inputs.oracle_lock",
    )
    if oracle_lock["path"] != "docker/any-sync/oracle.lock.env":
        raise SystemExit("[phase49 current_inputs.oracle_lock] unexpected path")
    expected_versions = {
        key: current_lock.get(key, "")
        for key in (
            "ANY_SYNC_NODE_VERSION",
            "ANY_SYNC_FILENODE_VERSION",
            "ANY_SYNC_COORDINATOR_VERSION",
            "ANY_SYNC_CONSENSUSNODE_VERSION",
        )
    }
    if oracle_lock["any_sync_versions"] != expected_versions:
        raise SystemExit("[phase49 current_inputs.oracle_lock] any-sync version drift detected")
    if oracle_lock["anytype_cli_image"] != current_lock.get("ANYTYPE_CLI_IMAGE", ""):
        raise SystemExit("[phase49 current_inputs.oracle_lock] anytype_cli_image drift detected")
    if oracle_lock["anytype_cli_tag"] != current_lock.get("ANYTYPE_CLI_TAG", ""):
        raise SystemExit("[phase49 current_inputs.oracle_lock] anytype_cli_tag drift detected")
    if oracle_lock["anytype_cli_revision"] != current_lock.get("ANYTYPE_CLI_REVISION", ""):
        raise SystemExit(
            "[phase49 current_inputs.oracle_lock] anytype_cli_revision drift detected"
        )
    if current_inputs["phase45_anytype_image"] != current_lock.get("ANYTYPE_CLI_IMAGE", ""):
        raise SystemExit("[phase49 current_inputs] phase45_anytype_image drift detected")

    binaries = current_inputs["binaries"]
    require_keys(
        binaries,
        {
            "manytype_quic_ffi_release",
            "manytype_server_debug",
            "manytype_server_release",
        },
        "phase49 current_inputs.binaries",
    )
    compare_binary_record(
        binaries["manytype_quic_ffi_release"],
        ROOT / "rust" / "target" / "release" / "libmanytype_quic_ffi.so",
        "phase49 binary ffi",
    )
    compare_binary_record(
        binaries["manytype_server_debug"],
        ROOT / "rust" / "target" / "debug" / "manytype_server",
        "phase49 binary manytype_server_debug",
    )
    compare_binary_record(
        binaries["manytype_server_release"],
        ROOT / "rust" / "target" / "release" / "manytype_server",
        "phase49 binary manytype_server_release",
    )

    official_track = report["official_stack_track"]
    manytype_track = report["manytype_server_track"]
    for track, label, expected_names in (
        (
            official_track,
            "official_stack_track",
            {
                "bounded object/detail roundtrip",
                "object deletion roundtrip",
                "oracle acl lifecycle later-read",
            },
        ),
        (
            manytype_track,
            "manytype_server_track",
            {
                "latest-head observation sentinel",
                "local consensus restart continuation",
                "local space pull continuity",
            },
        ),
    ):
        require_keys(track, {"status", "scenarios"}, f"phase49 {label}")
        if track["status"] != "passed":
            raise SystemExit(f"[phase49 {label}] status != passed")
        scenarios = track["scenarios"]
        if not isinstance(scenarios, list) or len(scenarios) != 3:
            raise SystemExit(f"[phase49 {label}] expected 3 scenarios")
        names = {scenario.get("name", "") for scenario in scenarios}
        if names != expected_names:
            raise SystemExit(f"[phase49 {label}] unexpected scenario names: {sorted(names)}")
        for scenario in scenarios:
            require_keys(
                scenario,
                {"phase", "name", "proof_mode", "bundle_path", "verifier", "requirements"},
                f"phase49 {label} scenario",
            )
            if scenario["proof_mode"] not in {
                "restart-or-reopen",
                "restart",
                "reconnect-reread",
                "later-read",
            }:
                raise SystemExit(
                    f"[phase49 {label}] unsupported proof_mode {scenario['proof_mode']!r}"
                )

    run_checked(
        [
            "python3",
            "scripts/verify_phase31_manytype_server_artifacts.py",
            "--artifact",
            "test_vectors/phase31-cross-authored-manytype-server.json",
        ],
        "phase45 verifier",
    )
    run_checked(
        [
            "python3",
            "scripts/verify_phase46_artifacts.py",
            "--bundle",
            "test_vectors/phase46/bounded-object-edit-roundtrip.json",
            "--metadata",
            "test_vectors/phase46/runtime-metadata.json",
        ],
        "phase46 verifier",
    )
    run_checked(
        [
            "python3",
            "scripts/verify_phase47_artifacts.py",
            "--bundle",
            "test_vectors/phase47/object-deletion-roundtrip.json",
            "--metadata",
            "test_vectors/phase47/runtime-metadata.json",
        ],
        "phase47 verifier",
    )
    run_checked(
        [
            "python3",
            "scripts/verify_phase48_artifacts.py",
            "--bundle",
            "test_vectors/phase48/service-surface-baseline.json",
            "--metadata",
            "test_vectors/phase48/runtime-metadata.json",
        ],
        "phase48 verifier",
    )
    for metadata_path in (
        ROOT / "test_vectors" / "phase46" / "runtime-metadata.json",
        ROOT / "test_vectors" / "phase47" / "runtime-metadata.json",
        ROOT / "test_vectors" / "phase48" / "runtime-metadata.json",
    ):
        run_checked(
            [
                "python3",
                "scripts/verify_self_hosted_oracle_metadata.py",
                "--metadata",
                str(metadata_path.relative_to(ROOT)),
            ],
            f"oracle metadata verifier {metadata_path.name}",
        )
        verify_runtime_metadata_against_current(metadata_path, current_lock)

    verify_freshness(
        report,
        [
            ROOT / "test_vectors" / "phase31-cross-authored-manytype-server.json",
            ROOT / "test_vectors" / "phase46" / "bounded-object-edit-roundtrip.json",
            ROOT / "test_vectors" / "phase46" / "runtime-metadata.json",
            ROOT / "test_vectors" / "phase47" / "object-deletion-roundtrip.json",
            ROOT / "test_vectors" / "phase47" / "runtime-metadata.json",
            ROOT / "test_vectors" / "phase48" / "service-surface-baseline.json",
            ROOT / "test_vectors" / "phase48" / "runtime-metadata.json",
        ],
        "phase49 freshness",
    )

    print("[phase49 signoff] ok")
    print("phase49 signoff: PASSED")


if __name__ == "__main__":
    main()
