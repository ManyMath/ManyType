#!/usr/bin/env python3

"""Offline validator for the Phase 48 service-surface artifact bundle."""

from __future__ import annotations

import argparse
import json
import pathlib

from artifact_paths import repo_path


ROOT = pathlib.Path(__file__).resolve().parents[1]
ARTIFACT_DIR = ROOT / "test_vectors" / "phase48"


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
    label = "phase48 runtime metadata"
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
    return f"[{label}] ok"


def validate_oracle_acl(path: pathlib.Path) -> str:
    label = "phase48 oracle acl"
    data = load_json(path)
    require_keys(
        data,
        {
            "action",
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
    if data.get("action") != "oracle-acl":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    record_ids = data["record_ids_after_accept"]
    if not isinstance(record_ids, list) or len(record_ids) != 4:
        raise SystemExit(f"[{label}] expected 4 record ids after accept")
    if record_ids[0] != data["acl_root_id"]:
        raise SystemExit(f"[{label}] root id mismatch in later read")
    if record_ids[-1] != data["accept_record_id"]:
        raise SystemExit(f"[{label}] accept record missing from later read")
    if data["accept_record_id"] not in data["tail_after_join_ids"]:
        raise SystemExit(
            f"[{label}] tail_after_join_ids does not include accept_record_id"
        )
    if data["joiner_permission"] != "Writer":
        raise SystemExit(f"[{label}] joiner_permission mismatch")
    if data["joiner_status"] != "active":
        raise SystemExit(f"[{label}] joiner_status mismatch")
    return f"[{label}] ok"


def validate_local_consensus(bootstrap_path: pathlib.Path, continue_path: pathlib.Path) -> str:
    label = "phase48 local consensus"
    bootstrap = load_json(bootstrap_path)
    cont = load_json(continue_path)
    require_keys(
        bootstrap,
        {
            "action",
            "space_id",
            "root_id",
            "first_record_id",
            "record_ids_after_first",
            "tail_after_root_ids",
        },
        f"{label} bootstrap",
    )
    require_keys(
        cont,
        {
            "action",
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
    if bootstrap.get("action") != "local-consensus-bootstrap":
        raise SystemExit(f"[{label}] unexpected bootstrap action")
    if cont.get("action") != "local-consensus-continue":
        raise SystemExit(f"[{label}] unexpected continue action")
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
    label = "phase48 local space pull"
    bootstrap = load_json(bootstrap_path)
    refetch = load_json(refetch_path)
    require_keys(
        bootstrap,
        {
            "action",
            "space_id",
            "acl_root_id",
            "invite_record_id",
            "space_header_id",
            "acl_payload_id",
            "acl_record_ids",
        },
        f"{label} bootstrap",
    )
    require_keys(
        refetch,
        {
            "action",
            "space_id",
            "acl_root_id",
            "invite_record_id",
            "space_header_id",
            "acl_payload_id",
            "acl_record_ids",
        },
        f"{label} refetch",
    )
    if bootstrap.get("action") != "local-space-pull-bootstrap":
        raise SystemExit(f"[{label}] unexpected bootstrap action")
    if refetch.get("action") != "local-space-pull-refetch":
        raise SystemExit(f"[{label}] unexpected refetch action")
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
    label = "phase48 bundle"
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
    if data.get("scenario") != "phase48 service-surface baseline":
        raise SystemExit(f"[{label}] unexpected scenario")
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")

    oracle_acl = data["oracle_acl"]
    local_consensus = data["local_consensus"]
    local_space_pull = data["local_space_pull"]
    require_keys(oracle_acl, {"space_id", "accept_record_id", "artifact_path"}, f"{label} oracle_acl")
    require_keys(
        local_consensus,
        {"space_id", "first_record_id", "second_record_id", "bootstrap_path", "continue_path"},
        f"{label} local_consensus",
    )
    require_keys(
        local_space_pull,
        {"space_id", "invite_record_id", "bootstrap_path", "refetch_path"},
        f"{label} local_space_pull",
    )
    validate_oracle_acl(repo_path(oracle_acl["artifact_path"]))
    validate_local_consensus(
        repo_path(local_consensus["bootstrap_path"]),
        repo_path(local_consensus["continue_path"]),
    )
    validate_local_space_pull(
        repo_path(local_space_pull["bootstrap_path"]),
        repo_path(local_space_pull["refetch_path"]),
    )
    validate_runtime_metadata(repo_path(data["metadata_path"]))
    return f"[{label}] ok"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline validator for the Phase 48 service-surface artifact bundle."
    )
    parser.add_argument(
        "--bundle",
        default=str(ARTIFACT_DIR / "service-surface-baseline.json"),
        help="Path to the Phase 48 top-level artifact bundle.",
    )
    parser.add_argument(
        "--metadata",
        default=str(ARTIFACT_DIR / "runtime-metadata.json"),
        help="Path to the Phase 48 runtime metadata artifact.",
    )
    args = parser.parse_args()

    results = [
        validate_bundle(pathlib.Path(args.bundle)),
        validate_runtime_metadata(pathlib.Path(args.metadata)),
    ]
    for result in results:
        print(result)
    print("phase48 artifacts: PASSED")


if __name__ == "__main__":
    main()
