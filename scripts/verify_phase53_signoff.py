#!/usr/bin/env python3

"""Offline verifier for the Phase 53 v2.7 sign-off report."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import pathlib
import subprocess

from artifact_paths import repo_path


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_REPORT = ROOT / "test_vectors" / "phase53" / "v27-signoff.json"
BINARY_HINT = (
    "the sign-off pins the locally built binaries it was captured with; "
    "rerun scripts/phase53_regression_lock_harness.sh to re-sign against this build"
)


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
        raise SystemExit(f"[{label}] current file missing: {actual_path} ({BINARY_HINT})")
    expected_path = str(actual_path.relative_to(ROOT))
    if record["path"] != expected_path:
        raise SystemExit(f"[{label}] path mismatch: {record['path']!r} != {expected_path!r}")
    if record["sha256"] != sha256(actual_path):
        raise SystemExit(f"[{label}] sha256 mismatch ({BINARY_HINT})")
    if record["size"] != actual_path.stat().st_size:
        raise SystemExit(f"[{label}] size mismatch ({BINARY_HINT})")


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
        raise SystemExit(f"[{label}] manytype_quic_ffi drift detected ({BINARY_HINT})")

    debug_path = ROOT / "rust" / "target" / "debug" / "manytype_server"
    if binaries["manytype_server_debug"].get("sha256") != sha256(debug_path):
        raise SystemExit(f"[{label}] manytype_server_debug drift detected ({BINARY_HINT})")


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
        description="Offline verifier for the Phase 53 v2.7 sign-off report."
    )
    parser.add_argument(
        "--report",
        default=str(DEFAULT_REPORT),
        help="Path to the Phase 53 sign-off report.",
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
            "scope_decisions",
            "official_stack_track",
            "manytype_server_track",
            "verifiers",
            "success",
        },
        "phase53 signoff",
    )
    if report["scenario"] != "v2.7 regression lock and milestone sign-off":
        raise SystemExit("[phase53 signoff] unexpected scenario")
    if report["success"] is not True:
        raise SystemExit("[phase53 signoff] success != true")
    if sorted(report["requirements_completed"]) != ["V27-01", "V27-02", "V27-03"]:
        raise SystemExit("[phase53 signoff] unexpected requirements_completed")

    current_inputs = report["current_inputs"]
    require_keys(
        current_inputs,
        {"git", "oracle_lock", "binaries"},
        "phase53 current_inputs",
    )
    current_lock = parse_env_file(ROOT / "docker" / "any-sync" / "oracle.lock.env")
    oracle_lock = current_inputs["oracle_lock"]
    require_keys(
        oracle_lock,
        {"path", "any_sync_versions", "anytype_cli_image", "anytype_cli_tag", "anytype_cli_revision"},
        "phase53 current_inputs.oracle_lock",
    )
    if oracle_lock["path"] != "docker/any-sync/oracle.lock.env":
        raise SystemExit("[phase53 current_inputs.oracle_lock] unexpected path")
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
        raise SystemExit("[phase53 current_inputs.oracle_lock] any-sync version drift detected")
    if oracle_lock["anytype_cli_image"] != current_lock.get("ANYTYPE_CLI_IMAGE", ""):
        raise SystemExit("[phase53 current_inputs.oracle_lock] anytype_cli_image drift detected")
    if oracle_lock["anytype_cli_tag"] != current_lock.get("ANYTYPE_CLI_TAG", ""):
        raise SystemExit("[phase53 current_inputs.oracle_lock] anytype_cli_tag drift detected")
    if oracle_lock["anytype_cli_revision"] != current_lock.get("ANYTYPE_CLI_REVISION", ""):
        raise SystemExit(
            "[phase53 current_inputs.oracle_lock] anytype_cli_revision drift detected"
        )

    binaries = current_inputs["binaries"]
    require_keys(
        binaries,
        {
            "manytype_quic_ffi_release",
            "manytype_server_debug",
            "manytype_server_release",
        },
        "phase53 current_inputs.binaries",
    )
    compare_binary_record(
        binaries["manytype_quic_ffi_release"],
        ROOT / "rust" / "target" / "release" / "libmanytype_quic_ffi.so",
        "phase53 binary ffi",
    )
    compare_binary_record(
        binaries["manytype_server_debug"],
        ROOT / "rust" / "target" / "debug" / "manytype_server",
        "phase53 binary manytype_server_debug",
    )
    compare_binary_record(
        binaries["manytype_server_release"],
        ROOT / "rust" / "target" / "release" / "manytype_server",
        "phase53 binary manytype_server_release",
    )

    phase50 = load_json(ROOT / "test_vectors" / "phase50" / "teardown-truth-baseline.json")
    phase51 = load_json(ROOT / "test_vectors" / "phase51" / "space-delete-parity.json")
    phase52 = load_json(ROOT / "test_vectors" / "phase52" / "service-cli-productization.json")

    scope_decisions = report["scope_decisions"]
    require_keys(scope_decisions, {"account_delete"}, "phase53 scope_decisions")
    account_delete = scope_decisions["account_delete"]
    require_keys(
        account_delete,
        {"decision", "reason", "official_capture_path", "local_capture_path"},
        "phase53 account_delete",
    )
    if account_delete["decision"] != "defer":
        raise SystemExit("[phase53 account_delete] decision must remain defer")
    if account_delete["reason"] != phase50["account_delete"]["reason"]:
        raise SystemExit("[phase53 account_delete] reason drift detected")
    expected_official_account = str(
        repo_path(phase50["account_delete"]["official_capture_path"]).relative_to(ROOT)
    )
    expected_local_account = str(
        repo_path(phase50["account_delete"]["local_capture_path"]).relative_to(ROOT)
    )
    if account_delete["official_capture_path"] != expected_official_account:
        raise SystemExit("[phase53 account_delete] official_capture_path drift detected")
    if account_delete["local_capture_path"] != expected_local_account:
        raise SystemExit("[phase53 account_delete] local_capture_path drift detected")

    official_track = report["official_stack_track"]
    manytype_track = report["manytype_server_track"]
    for track, label, expected_names, expected_count in (
        (
            official_track,
            "official_stack_track",
            {
                "teardown truth capture and scope freeze",
                "bounded space delete parity",
                "oracle acl lifecycle cli",
            },
            3,
        ),
        (
            manytype_track,
            "manytype_server_track",
            {
                "local teardown truth capture",
                "local space-delete rejection",
                "local consensus restart continuation",
                "local space pull continuity",
            },
            4,
        ),
    ):
        require_keys(track, {"status", "scenarios"}, f"phase53 {label}")
        if track["status"] != "passed":
            raise SystemExit(f"[phase53 {label}] status != passed")
        scenarios = track["scenarios"]
        if not isinstance(scenarios, list) or len(scenarios) != expected_count:
            raise SystemExit(f"[phase53 {label}] expected {expected_count} scenarios")
        names = {scenario.get("name", "") for scenario in scenarios}
        if names != expected_names:
            raise SystemExit(f"[phase53 {label}] unexpected scenario names: {sorted(names)}")
        for scenario in scenarios:
            require_keys(
                scenario,
                {"phase", "name", "proof_mode", "bundle_path", "artifact_path", "verifier", "requirements"},
                f"phase53 {label} scenario",
            )
            if scenario["proof_mode"] not in {
                "coordinator-status-reread",
                "reconnect-reread",
                "restart",
                "later-read",
            }:
                raise SystemExit(
                    f"[phase53 {label}] unsupported proof_mode {scenario['proof_mode']!r}"
                )

    expected_artifacts = {
        "teardown truth capture and scope freeze": str(
            repo_path(phase50["space_delete"]["official_capture_path"]).relative_to(ROOT)
        ),
        "bounded space delete parity": str(
            repo_path(phase51["official_supported_flow"]["artifact_path"]).relative_to(ROOT)
        ),
        "oracle acl lifecycle cli": str(
            repo_path(phase52["oracle_acl"]["artifact_path"]).relative_to(ROOT)
        ),
        "local teardown truth capture": str(
            repo_path(phase50["space_delete"]["local_capture_path"]).relative_to(ROOT)
        ),
        "local space-delete rejection": str(
            repo_path(phase51["local_rejected_flow"]["artifact_path"]).relative_to(ROOT)
        ),
        "local consensus restart continuation": str(
            repo_path(phase52["local_consensus"]["continue_path"]).relative_to(ROOT)
        ),
        "local space pull continuity": str(
            repo_path(phase52["local_space_pull"]["refetch_path"]).relative_to(ROOT)
        ),
    }
    for track in (official_track, manytype_track):
        for scenario in track["scenarios"]:
            expected_artifact = expected_artifacts[scenario["name"]]
            if scenario["artifact_path"] != expected_artifact:
                raise SystemExit(
                    f"[phase53 scenario {scenario['name']}] artifact_path drift detected"
                )

    expected_verifiers = [
        "scripts/verify_phase50_teardown_truth.py",
        "scripts/verify_phase51_space_delete.py",
        "scripts/verify_phase52_service_cli.py",
        "scripts/verify_self_hosted_oracle_metadata.py",
        "scripts/verify_phase53_signoff.py",
    ]
    if report["verifiers"] != expected_verifiers:
        raise SystemExit("[phase53 signoff] verifier list drift detected")

    run_checked(["python3", "scripts/verify_phase50_teardown_truth.py"], "phase50 verifier")
    run_checked(["python3", "scripts/verify_phase51_space_delete.py"], "phase51 verifier")
    run_checked(["python3", "scripts/verify_phase52_service_cli.py"], "phase52 verifier")
    for metadata_path in (
        ROOT / "test_vectors" / "phase50" / "runtime-metadata.json",
        ROOT / "test_vectors" / "phase51" / "runtime-metadata.json",
        ROOT / "test_vectors" / "phase52" / "runtime-metadata.json",
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
            ROOT / "test_vectors" / "phase50" / "teardown-truth-baseline.json",
            ROOT / "test_vectors" / "phase50" / "oracle_space_delete.json",
            ROOT / "test_vectors" / "phase50" / "oracle_account_delete.json",
            ROOT / "test_vectors" / "phase50" / "local_space_delete.json",
            ROOT / "test_vectors" / "phase50" / "local_account_delete.json",
            ROOT / "test_vectors" / "phase50" / "runtime-metadata.json",
            ROOT / "test_vectors" / "phase51" / "space-delete-parity.json",
            ROOT / "test_vectors" / "phase51" / "official_space_delete.json",
            ROOT / "test_vectors" / "phase51" / "local_space_delete_rejected.json",
            ROOT / "test_vectors" / "phase51" / "runtime-metadata.json",
            ROOT / "test_vectors" / "phase52" / "service-cli-productization.json",
            ROOT / "test_vectors" / "phase52" / "oracle_acl_lifecycle.json",
            ROOT / "test_vectors" / "phase52" / "local_consensus_bootstrap.json",
            ROOT / "test_vectors" / "phase52" / "local_consensus_continue.json",
            ROOT / "test_vectors" / "phase52" / "local_space_pull_bootstrap.json",
            ROOT / "test_vectors" / "phase52" / "local_space_pull_refetch.json",
            ROOT / "test_vectors" / "phase52" / "runtime-metadata.json",
        ],
        "phase53 freshness",
    )

    print("[phase53 signoff] ok")
    print("phase53 signoff: PASSED")


if __name__ == "__main__":
    main()
