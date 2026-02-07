#!/usr/bin/env python3

"""Offline verifier for the Phase 52 service-surface CLI artifact bundle."""

from __future__ import annotations

import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
ARTIFACT_DIR = ROOT / "test_vectors" / "phase52"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def validate_runtime_metadata(path: pathlib.Path) -> str:
    label = "phase52 runtime metadata"
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
    if len(data.get("artifacts", [])) < 5:
        raise SystemExit(f"[{label}] expected at least 5 artifact records")
    return f"[{label}] ok"


def validate_oracle_acl(path: pathlib.Path) -> str:
    label = "phase52 oracle acl"
    data = load_json(path)
    require_keys(
        data,
        {
            "command",
            "backend_label",
            "backend_requirements",
            "space_id",
            "acl_root_id",
            "invite_record_id",
            "join_record_id",
            "accept_record_id",
            "record_ids_after_accept",
            "tail_after_join_ids",
            "joiner_permission",
            "joiner_status",
        },
        label,
    )
    if data.get("command") != "acl-lifecycle":
        raise SystemExit(f"[{label}] unexpected command")
    if data.get("backend_label") != "self-hosted-official":
        raise SystemExit(f"[{label}] unexpected backend_label")
    if len(data.get("backend_requirements", [])) < 2:
        raise SystemExit(f"[{label}] expected backend requirements")
    record_ids = data["record_ids_after_accept"]
    if not isinstance(record_ids, list) or len(record_ids) != 4:
        raise SystemExit(f"[{label}] expected 4 record ids after accept")
    if record_ids[0] != data["acl_root_id"]:
        raise SystemExit(f"[{label}] root id mismatch in later read")
    if record_ids[-1] != data["accept_record_id"]:
        raise SystemExit(f"[{label}] accept record missing from later read")
    if data["accept_record_id"] not in data["tail_after_join_ids"]:
        raise SystemExit(f"[{label}] tail_after_join_ids missing accept record")
    if data["joiner_permission"] != "Writer":
        raise SystemExit(f"[{label}] joiner_permission mismatch")
    if data["joiner_status"] != "active":
        raise SystemExit(f"[{label}] joiner_status mismatch")
    return f"[{label}] ok"


def validate_local_consensus(bootstrap_path: pathlib.Path, continue_path: pathlib.Path) -> str:
    label = "phase52 local consensus"
    bootstrap = load_json(bootstrap_path)
    cont = load_json(continue_path)
    require_keys(
        bootstrap,
        {
            "command",
            "backend_label",
            "backend_requirements",
            "server_address",
            "log_id",
            "space_id",
            "root_id",
            "first_record_id",
            "record_ids_after_first",
            "tail_after_root_ids",
            "state_path",
        },
        f"{label} bootstrap",
    )
    require_keys(
        cont,
        {
            "command",
            "backend_label",
            "backend_requirements",
            "server_address",
            "state_in",
            "log_id",
            "space_id",
            "root_id",
            "first_record_id",
            "second_record_id",
            "record_ids_before_continue",
            "record_ids_after_continue",
            "tail_after_first_ids",
        },
        f"{label} continue",
    )
    if bootstrap.get("command") != "consensus-bootstrap":
        raise SystemExit(f"[{label}] unexpected bootstrap command")
    if cont.get("command") != "consensus-continue":
        raise SystemExit(f"[{label}] unexpected continue command")
    if bootstrap.get("backend_label") != "manytype_server":
        raise SystemExit(f"[{label}] bootstrap backend label mismatch")
    if cont.get("backend_label") != "manytype_server":
        raise SystemExit(f"[{label}] continue backend label mismatch")
    if bootstrap["log_id"] != bootstrap["space_id"]:
        raise SystemExit(f"[{label}] bootstrap log_id mismatch")
    if cont["log_id"] != cont["space_id"]:
        raise SystemExit(f"[{label}] continue log_id mismatch")
    if bootstrap["space_id"] != cont["space_id"]:
        raise SystemExit(f"[{label}] space_id mismatch")
    if bootstrap["root_id"] != cont["root_id"]:
        raise SystemExit(f"[{label}] root_id mismatch")
    if bootstrap["first_record_id"] != cont["first_record_id"]:
        raise SystemExit(f"[{label}] first_record_id mismatch")
    expected_bootstrap = [bootstrap["root_id"], bootstrap["first_record_id"]]
    if bootstrap["record_ids_after_first"] != expected_bootstrap:
        raise SystemExit(f"[{label}] record_ids_after_first mismatch")
    if bootstrap["tail_after_root_ids"] != [bootstrap["first_record_id"]]:
        raise SystemExit(f"[{label}] tail_after_root_ids mismatch")
    if cont["record_ids_before_continue"] != expected_bootstrap:
        raise SystemExit(f"[{label}] record_ids_before_continue mismatch")
    expected_after = [bootstrap["root_id"], bootstrap["first_record_id"], cont["second_record_id"]]
    if cont["record_ids_after_continue"] != expected_after:
        raise SystemExit(f"[{label}] record_ids_after_continue mismatch")
    if cont["tail_after_first_ids"] != [cont["second_record_id"]]:
        raise SystemExit(f"[{label}] tail_after_first_ids mismatch")
    return f"[{label}] ok"


def validate_local_space_pull(bootstrap_path: pathlib.Path, refetch_path: pathlib.Path) -> str:
    label = "phase52 local space pull"
    bootstrap = load_json(bootstrap_path)
    refetch = load_json(refetch_path)
    require_keys(
        bootstrap,
        {
            "command",
            "backend_label",
            "backend_requirements",
            "network_config_path",
            "server_address",
            "space_id",
            "acl_root_id",
            "invite_record_id",
            "space_header_id",
            "acl_payload_id",
            "acl_record_ids",
            "state_path",
        },
        f"{label} bootstrap",
    )
    require_keys(
        refetch,
        {
            "command",
            "backend_label",
            "backend_requirements",
            "server_address",
            "state_in",
            "space_id",
            "acl_root_id",
            "invite_record_id",
            "space_header_id",
            "acl_payload_id",
            "acl_record_ids",
        },
        f"{label} refetch",
    )
    if bootstrap.get("command") != "space-pull-bootstrap":
        raise SystemExit(f"[{label}] unexpected bootstrap command")
    if refetch.get("command") != "space-pull-refetch":
        raise SystemExit(f"[{label}] unexpected refetch command")
    if bootstrap.get("backend_label") != "manytype_server":
        raise SystemExit(f"[{label}] bootstrap backend label mismatch")
    if refetch.get("backend_label") != "manytype_server":
        raise SystemExit(f"[{label}] refetch backend label mismatch")
    for key in ("space_id", "acl_root_id", "invite_record_id"):
        if bootstrap[key] != refetch[key]:
            raise SystemExit(f"[{label}] {key} mismatch")
    if bootstrap["space_header_id"] != bootstrap["space_id"]:
        raise SystemExit(f"[{label}] bootstrap space_header_id mismatch")
    if refetch["space_header_id"] != refetch["space_id"]:
        raise SystemExit(f"[{label}] refetch space_header_id mismatch")
    if bootstrap["acl_payload_id"] != bootstrap["acl_root_id"]:
        raise SystemExit(f"[{label}] bootstrap acl_payload_id mismatch")
    if refetch["acl_payload_id"] != refetch["acl_root_id"]:
        raise SystemExit(f"[{label}] refetch acl_payload_id mismatch")
    expected_records = [bootstrap["invite_record_id"]]
    if bootstrap["acl_record_ids"] != expected_records:
        raise SystemExit(f"[{label}] bootstrap acl_record_ids mismatch")
    if refetch["acl_record_ids"] != expected_records:
        raise SystemExit(f"[{label}] refetch acl_record_ids mismatch")
    return f"[{label}] ok"


def validate_bundle(path: pathlib.Path) -> str:
    label = "phase52 bundle"
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "oracle_acl",
            "local_consensus",
            "local_space_pull",
            "metadata_path",
            "success",
        },
        label,
    )
    if data.get("scenario") != "phase52 service-surface cli productization":
        raise SystemExit(f"[{label}] unexpected scenario")
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != true")

    oracle_acl = data["oracle_acl"]
    local_consensus = data["local_consensus"]
    local_space_pull = data["local_space_pull"]
    require_keys(oracle_acl, {"space_id", "accept_record_id", "artifact_path"}, f"{label} oracle_acl")
    require_keys(
        local_consensus,
        {"space_id", "log_id", "first_record_id", "second_record_id", "bootstrap_path", "continue_path"},
        f"{label} local_consensus",
    )
    require_keys(
        local_space_pull,
        {"space_id", "invite_record_id", "bootstrap_path", "refetch_path"},
        f"{label} local_space_pull",
    )
    validate_oracle_acl(pathlib.Path(oracle_acl["artifact_path"]))
    validate_local_consensus(
        pathlib.Path(local_consensus["bootstrap_path"]),
        pathlib.Path(local_consensus["continue_path"]),
    )
    validate_local_space_pull(
        pathlib.Path(local_space_pull["bootstrap_path"]),
        pathlib.Path(local_space_pull["refetch_path"]),
    )
    validate_runtime_metadata(pathlib.Path(data["metadata_path"]))
    return f"[{label}] ok"


def main() -> None:
    results = [
        validate_runtime_metadata(ARTIFACT_DIR / "runtime-metadata.json"),
        validate_oracle_acl(ARTIFACT_DIR / "oracle_acl_lifecycle.json"),
        validate_local_consensus(
            ARTIFACT_DIR / "local_consensus_bootstrap.json",
            ARTIFACT_DIR / "local_consensus_continue.json",
        ),
        validate_local_space_pull(
            ARTIFACT_DIR / "local_space_pull_bootstrap.json",
            ARTIFACT_DIR / "local_space_pull_refetch.json",
        ),
        validate_bundle(ARTIFACT_DIR / "service-cli-productization.json"),
    ]
    for result in results:
        print(result)
    print("phase52 service cli: PASSED")


if __name__ == "__main__":
    main()
