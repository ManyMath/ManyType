#!/usr/bin/env python3

"""Offline validator for the Phase 50 teardown-truth artifact bundle."""

from __future__ import annotations

import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
ARTIFACT_DIR = ROOT / "test_vectors" / "phase50"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def require_status(data: dict, path: list[str], expected: str, label: str) -> None:
    node = data
    for key in path:
        if key not in node:
            raise SystemExit(f"[{label}] missing path: {'.'.join(path)}")
        node = node[key]
    if not isinstance(node, dict) or node.get("ok") is not True:
        raise SystemExit(f"[{label}] expected ok result at {'.'.join(path)}")
    value = node.get("value", {})
    if value.get("status") != expected:
        raise SystemExit(
            f"[{label}] expected {expected} at {'.'.join(path)}, got {value.get('status')}"
        )


def require_response_ok(data: dict, response: dict, label: str) -> None:
    if response.get("ok") is not True:
        raise SystemExit(f"[{label}] expected successful response, got {response.get('error')}")
    timestamp = response.get("value", {}).get("to_be_deleted_timestamp", 0)
    if not isinstance(timestamp, int) or timestamp <= 0:
        raise SystemExit(f"[{label}] missing positive to_be_deleted_timestamp")
    request = data["initial"].get("request") or {}
    if not request.get("payload_id"):
        raise SystemExit(f"[{label}] missing request payload_id")
    if not request.get("peer_id"):
        raise SystemExit(f"[{label}] missing request peer_id")


def validate_runtime_metadata(path: pathlib.Path) -> str:
    label = "phase50 runtime metadata"
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
    if not data["official_cli"].get("repo_digest"):
        raise SystemExit(f"[{label}] official_cli.repo_digest is empty")
    if not data["network_config"].get("network_id"):
        raise SystemExit(f"[{label}] network_config.network_id is empty")
    binaries = data.get("binaries", {})
    if binaries.get("manytype_quic_ffi", {}).get("exists") is not True:
        raise SystemExit(f"[{label}] manytype_quic_ffi binary is missing")
    if binaries.get("manytype_server_debug", {}).get("exists") is not True:
        raise SystemExit(f"[{label}] manytype_server_debug binary is missing")
    if binaries.get("official_client_probe", {}).get("exists") is not True:
        raise SystemExit(f"[{label}] official_client_probe binary is missing")
    if len(data.get("artifacts", [])) < 5:
        raise SystemExit(f"[{label}] expected at least 5 artifact records")
    return f"[{label}] ok"


def validate_capture(path: pathlib.Path, label: str) -> dict:
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "action",
            "surface",
            "coordinator_address",
            "space_id",
            "initial",
            "after_reconnect",
        },
        label,
    )
    return data


def validate_oracle_space(path: pathlib.Path) -> str:
    label = "phase50 oracle space delete"
    data = validate_capture(path, label)
    if data.get("action") != "space-delete":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    if data.get("surface") != "self-hosted-official":
        raise SystemExit(f"[{label}] unexpected surface: {data.get('surface')}")
    require_response_ok(data, data["initial"]["response"], label)
    require_status(data, ["initial", "pre_status"], "SpaceStatusCreated", label)
    require_status(data, ["initial", "post_status"], "SpaceStatusPendingDeletion", label)
    require_status(
        data,
        ["after_reconnect", "post_status"],
        "SpaceStatusDeleted",
        label,
    )
    return f"[{label}] ok"


def validate_local_space(path: pathlib.Path) -> str:
    label = "phase50 local space delete"
    data = validate_capture(path, label)
    if data.get("action") != "space-delete":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    if data.get("surface") != "manytype_server":
        raise SystemExit(f"[{label}] unexpected surface: {data.get('surface')}")
    require_response_ok(data, data["initial"]["response"], label)
    require_status(data, ["initial", "pre_status"], "SpaceStatusCreated", label)
    require_status(data, ["initial", "post_status"], "SpaceStatusCreated", label)
    require_status(
        data,
        ["after_reconnect", "post_status"],
        "SpaceStatusCreated",
        label,
    )
    reconnect_log = data["after_reconnect"]["post_deletion_log"]
    if reconnect_log.get("ok") is not True:
        raise SystemExit(f"[{label}] expected deletion log read to succeed")
    if reconnect_log.get("value", {}).get("count") != 0:
        raise SystemExit(f"[{label}] deletion log should stay empty on stubbed local surface")
    return f"[{label}] ok"


def validate_oracle_account(path: pathlib.Path) -> str:
    label = "phase50 oracle account delete"
    data = validate_capture(path, label)
    if data.get("action") != "account-delete":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    if data.get("surface") != "self-hosted-official":
        raise SystemExit(f"[{label}] unexpected surface: {data.get('surface')}")
    response = data["initial"]["response"]
    if response.get("ok") is not False:
        raise SystemExit(f"[{label}] expected official AccountDelete to fail for scope evidence")
    if "account is deleted" not in response.get("error", "").lower():
        raise SystemExit(f"[{label}] unexpected error: {response.get('error')}")
    require_status(data, ["initial", "pre_status"], "SpaceStatusCreated", label)
    require_status(data, ["initial", "post_status"], "SpaceStatusCreated", label)
    require_status(
        data,
        ["after_reconnect", "post_status"],
        "SpaceStatusCreated",
        label,
    )
    return f"[{label}] ok"


def validate_local_account(path: pathlib.Path) -> str:
    label = "phase50 local account delete"
    data = validate_capture(path, label)
    if data.get("action") != "account-delete":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    if data.get("surface") != "manytype_server":
        raise SystemExit(f"[{label}] unexpected surface: {data.get('surface')}")
    require_response_ok(data, data["initial"]["response"], label)
    require_status(data, ["initial", "pre_status"], "SpaceStatusCreated", label)
    require_status(data, ["initial", "post_status"], "SpaceStatusCreated", label)
    require_status(
        data,
        ["after_reconnect", "post_status"],
        "SpaceStatusCreated",
        label,
    )
    return f"[{label}] ok"


def validate_bundle(path: pathlib.Path) -> str:
    label = "phase50 bundle"
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "space_delete",
            "account_delete",
            "metadata_path",
            "success",
        },
        label,
    )
    if data.get("scenario") != "phase50 teardown truth capture":
        raise SystemExit(f"[{label}] unexpected scenario")
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")

    space_delete = data["space_delete"]
    require_keys(
        space_delete,
        {
            "accepted_truth_surface",
            "proof_mode_label",
            "supported_preconditions",
            "required_observations",
            "official_capture_path",
            "local_capture_path",
        },
        f"{label} space_delete",
    )
    if space_delete.get("accepted_truth_surface") != "self-hosted-official":
        raise SystemExit(f"[{label}] unexpected accepted truth surface")
    if space_delete.get("proof_mode_label") != "coordinator-status-reread":
        raise SystemExit(f"[{label}] unexpected proof_mode_label")

    account_delete = data["account_delete"]
    require_keys(
        account_delete,
        {"decision", "reason", "official_capture_path", "local_capture_path"},
        f"{label} account_delete",
    )
    if account_delete.get("decision") != "defer":
        raise SystemExit(f"[{label}] AccountDelete should be deferred")
    return f"[{label}] ok"


def main() -> None:
    results = [
        validate_runtime_metadata(ARTIFACT_DIR / "runtime-metadata.json"),
        validate_oracle_space(ARTIFACT_DIR / "oracle_space_delete.json"),
        validate_oracle_account(ARTIFACT_DIR / "oracle_account_delete.json"),
        validate_local_space(ARTIFACT_DIR / "local_space_delete.json"),
        validate_local_account(ARTIFACT_DIR / "local_account_delete.json"),
        validate_bundle(ARTIFACT_DIR / "teardown-truth-baseline.json"),
    ]
    for result in results:
        print(result)
    print("phase50 teardown truth: PASSED")


if __name__ == "__main__":
    main()
