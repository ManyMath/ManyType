#!/usr/bin/env python3

"""Offline verifier for the Phase 51 bounded SpaceDelete artifact bundle."""

from __future__ import annotations

import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
ARTIFACT_DIR = ROOT / "test_vectors" / "phase51"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def require_status(result: dict, expected: str, label: str) -> None:
    if result.get("ok") is not True:
        raise SystemExit(f"[{label}] expected ok status result, got {result.get('error')}")
    actual = result.get("value", {}).get("status")
    if actual != expected:
        raise SystemExit(f"[{label}] expected {expected}, got {actual}")


def validate_runtime_metadata(path: pathlib.Path) -> str:
    label = "phase51 runtime metadata"
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "git",
            "oracle_lock",
            "official_cli",
            "docker_any_sync_env",
            "network_config",
            "binaries",
            "artifacts",
        },
        label,
    )
    if not data["network_config"].get("network_id"):
        raise SystemExit(f"[{label}] network_config.network_id is empty")
    if data["binaries"]["manytype_quic_ffi"].get("exists") is not True:
        raise SystemExit(f"[{label}] manytype_quic_ffi binary is missing")
    if data["binaries"]["official_client_probe"].get("exists") is not True:
        raise SystemExit(f"[{label}] official_client_probe binary is missing")
    if len(data.get("artifacts", [])) < 3:
        raise SystemExit(f"[{label}] expected at least 3 artifact records")
    return f"[{label}] ok"


def validate_report(path: pathlib.Path, label: str) -> dict:
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "command",
            "accepted_contract",
            "assessment",
            "space_id",
            "initial",
            "after_reconnect",
        },
        label,
    )
    if data.get("command") != "space-delete":
        raise SystemExit(f"[{label}] unexpected command")
    contract = data["accepted_contract"]
    if contract.get("truth_surface") != "self-hosted-official":
        raise SystemExit(f"[{label}] unexpected truth surface")
    if contract.get("proof_mode") != "coordinator-status-reread":
        raise SystemExit(f"[{label}] unexpected proof mode")
    return data


def validate_official(path: pathlib.Path) -> str:
    label = "phase51 official space delete"
    data = validate_report(path, label)
    assessment = data["assessment"]
    if assessment.get("supported") is not True:
        raise SystemExit(f"[{label}] expected supported=true")
    if assessment.get("outcome") != "supported-and-verified":
        raise SystemExit(f"[{label}] unexpected outcome")
    require_status(data["initial"]["pre_status"], "SpaceStatusCreated", f"{label} pre")
    response = data["initial"]["response"]
    if response.get("ok") is not True:
        raise SystemExit(f"[{label}] expected successful response")
    timestamp = response.get("value", {}).get("to_be_deleted_timestamp", 0)
    if not isinstance(timestamp, int) or timestamp <= 0:
        raise SystemExit(f"[{label}] missing positive to_be_deleted_timestamp")
    require_status(
        data["initial"]["post_status"],
        "SpaceStatusPendingDeletion",
        f"{label} post",
    )
    require_status(
        data["after_reconnect"]["status"],
        "SpaceStatusDeleted",
        f"{label} reconnect",
    )
    return f"[{label}] ok"


def validate_local_rejection(path: pathlib.Path) -> str:
    label = "phase51 local rejection"
    data = validate_report(path, label)
    assessment = data["assessment"]
    if assessment.get("supported") is not False:
        raise SystemExit(f"[{label}] expected supported=false")
    if assessment.get("outcome") != "unsupported-surface-or-scenario":
        raise SystemExit(f"[{label}] unexpected outcome")
    if assessment.get("observed_surface_label") != "stub-no-op-surface":
        raise SystemExit(f"[{label}] expected stub-no-op surface label")
    require_status(data["initial"]["pre_status"], "SpaceStatusCreated", f"{label} pre")
    response = data["initial"]["response"]
    if response.get("ok") is not True:
        raise SystemExit(f"[{label}] expected successful response")
    require_status(data["initial"]["post_status"], "SpaceStatusCreated", f"{label} post")
    require_status(
        data["after_reconnect"]["status"],
        "SpaceStatusCreated",
        f"{label} reconnect",
    )
    if "stub/no-op" not in assessment.get("reason", ""):
        raise SystemExit(f"[{label}] expected explicit stub/no-op reason")
    return f"[{label}] ok"


def validate_bundle(path: pathlib.Path) -> str:
    label = "phase51 bundle"
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "accepted_truth_surface",
            "proof_mode",
            "official_supported_flow",
            "local_rejected_flow",
            "metadata_path",
            "success",
        },
        label,
    )
    if data.get("scenario") != "phase51 bounded space delete":
        raise SystemExit(f"[{label}] unexpected scenario")
    if data.get("accepted_truth_surface") != "self-hosted-official":
        raise SystemExit(f"[{label}] unexpected accepted truth surface")
    if data.get("proof_mode") != "coordinator-status-reread":
        raise SystemExit(f"[{label}] unexpected proof mode")
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != true")

    official = data["official_supported_flow"]
    local = data["local_rejected_flow"]
    if official.get("outcome") != "supported-and-verified":
        raise SystemExit(f"[{label}] official outcome mismatch")
    if local.get("outcome") != "unsupported-surface-or-scenario":
        raise SystemExit(f"[{label}] local rejection outcome mismatch")
    if local.get("observed_surface_label") != "stub-no-op-surface":
        raise SystemExit(f"[{label}] local rejection label mismatch")

    validate_official(pathlib.Path(official["artifact_path"]))
    validate_local_rejection(pathlib.Path(local["artifact_path"]))
    validate_runtime_metadata(pathlib.Path(data["metadata_path"]))
    return f"[{label}] ok"


def main() -> None:
    results = [
        validate_runtime_metadata(ARTIFACT_DIR / "runtime-metadata.json"),
        validate_official(ARTIFACT_DIR / "official_space_delete.json"),
        validate_local_rejection(ARTIFACT_DIR / "local_space_delete_rejected.json"),
        validate_bundle(ARTIFACT_DIR / "space-delete-parity.json"),
    ]
    for result in results:
        print(result)
    print("phase51 space delete: PASSED")


if __name__ == "__main__":
    main()
