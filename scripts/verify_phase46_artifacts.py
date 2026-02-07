#!/usr/bin/env python3

"""Offline validator for the Phase 46 bounded object/edit artifact bundle."""

from __future__ import annotations

import argparse
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
ARTIFACT_DIR = ROOT / "test_vectors" / "phase46"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def read_text(path: pathlib.Path) -> str:
    if not path.exists():
        raise SystemExit(f"missing text artifact: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def validate_manytype_sync_artifact(path: pathlib.Path, label: str) -> str:
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "coordinator_address",
            "events",
            "network_config_path",
            "official_interop_mode",
            "space_id",
        },
        label,
    )

    events = data.get("events", [])
    if not isinstance(events, list) or not events:
        raise SystemExit(f"[{label}] has no events")

    methods = {
        event.get("method", "")
        for event in events
        if event.get("type") in {"unary_rpc", "stream_rpc"}
    }
    required_methods = {
        "/coordinator.Coordinator/NetworkConfiguration",
        "/coordinator.Coordinator/SpaceStatusCheck",
        "/coordinator.Coordinator/SpaceSign",
        "/spacesync.SpaceSync/SpacePush",
        "/spacesync.SpaceSync/HeadSync",
    }
    missing_methods = sorted(required_methods - methods)
    if missing_methods:
        raise SystemExit(f"[{label}] missing required RPC methods: {missing_methods}")

    if not any("ObjectSync" in method for method in methods):
        raise SystemExit(f"[{label}] missing ObjectSync RPC evidence")
    if not any(event.get("type") == "sync-complete" for event in events):
        raise SystemExit(f"[{label}] missing sync-complete event")

    return f"[{label}] ok"


def validate_runtime_metadata(path: pathlib.Path) -> str:
    label = "phase46 runtime metadata"
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
    if data["binaries"]["manytype_quic_ffi"].get("exists") is not True:
        raise SystemExit(f"[{label}] manytype_quic_ffi binary is missing")
    if data["binaries"]["official_client_probe"].get("exists") is not True:
        raise SystemExit(f"[{label}] official_client_probe binary is missing")
    return f"[{label}] ok"


def validate_bundle(path: pathlib.Path) -> str:
    label = "phase46 bundle"
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "accepted_edit_set",
            "manytype_to_official",
            "official_to_manytype",
            "metadata_path",
            "success",
        },
        label,
    )
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")

    accepted = data["accepted_edit_set"]
    if accepted.get("string_detail_key") != "description":
        raise SystemExit(f"[{label}] unexpected string_detail_key")
    if accepted.get("string_list_detail_key") != "featuredRelations":
        raise SystemExit(f"[{label}] unexpected string_list_detail_key")
    if accepted.get("string_list_value") != ["description", "sourceObject"]:
        raise SystemExit(f"[{label}] unexpected string_list_value")

    manytype_to_official = data["manytype_to_official"]
    require_keys(
        manytype_to_official,
        {"object_id", "description", "show_path", "restart_show_path", "sync_capture_path"},
        f"{label} manytype_to_official",
    )
    first_show = load_json(pathlib.Path(manytype_to_official["show_path"]))
    restart_show = load_json(pathlib.Path(manytype_to_official["restart_show_path"]))
    for show, show_label in (
        (first_show, "initial show"),
        (restart_show, "restart show"),
    ):
        root_details = show.get("root_details", {})
        if root_details.get("description") != manytype_to_official["description"]:
            raise SystemExit(f"[{label}] {show_label} description mismatch")
        if root_details.get("featuredRelations") != ["description", "sourceObject"]:
            raise SystemExit(f"[{label}] {show_label} featuredRelations mismatch")

    validate_manytype_sync_artifact(
        pathlib.Path(manytype_to_official["sync_capture_path"]),
        f"{label} manytype_to_official sync",
    )

    official_to_manytype = data["official_to_manytype"]
    require_keys(
        official_to_manytype,
        {"object_id", "description", "read_path", "reopen_read_path", "sync_capture_path"},
        f"{label} official_to_manytype",
    )
    expected_description = official_to_manytype["description"]
    for read_path, read_label in (
        (official_to_manytype["read_path"], "Manytype read"),
        (official_to_manytype["reopen_read_path"], "Manytype reopen read"),
    ):
        text = read_text(pathlib.Path(read_path))
        if f"[description] {expected_description}" not in text:
            raise SystemExit(f"[{label}] {read_label} missing description line")
        if "[featuredRelations] description, sourceObject" not in text:
            raise SystemExit(f"[{label}] {read_label} missing featuredRelations line")

    validate_manytype_sync_artifact(
        pathlib.Path(official_to_manytype["sync_capture_path"]),
        f"{label} official_to_manytype sync",
    )
    validate_runtime_metadata(pathlib.Path(data["metadata_path"]))
    return f"[{label}] ok"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline validator for the Phase 46 bounded object/edit artifact bundle."
    )
    parser.add_argument(
        "--bundle",
        default=str(ARTIFACT_DIR / "bounded-object-edit-roundtrip.json"),
        help="Path to the Phase 46 top-level artifact bundle.",
    )
    parser.add_argument(
        "--metadata",
        default=str(ARTIFACT_DIR / "runtime-metadata.json"),
        help="Path to the Phase 46 runtime metadata artifact.",
    )
    args = parser.parse_args()

    results = [
        validate_bundle(pathlib.Path(args.bundle)),
        validate_runtime_metadata(pathlib.Path(args.metadata)),
    ]
    for result in results:
        print(result)
    print("phase46 artifacts: PASSED")


if __name__ == "__main__":
    main()
