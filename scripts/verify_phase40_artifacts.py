#!/usr/bin/env python3

"""Offline validator for Phase 40 file-relation artifacts."""

import argparse
import json
import pathlib

from artifact_paths import repo_path


ROOT = pathlib.Path(__file__).resolve().parents[1]
TEST_VECTORS = ROOT / "test_vectors" / "phase40"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def validate_runtime_metadata(path: pathlib.Path, label: str) -> str:
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
    if not isinstance(data.get("artifacts"), list) or not data["artifacts"]:
        raise SystemExit(f"[{label}] artifacts is empty")
    return f"[{label}] ok"


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
        raise SystemExit(f"[{label}] events is empty")

    methods = {
        event.get("method", "")
        for event in events
        if event.get("type") in ("unary_rpc", "stream_rpc")
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
        raise SystemExit(f"[{label}] missing RPC methods: {missing_methods}")
    if not any("ObjectSync" in method for method in methods):
        raise SystemExit(f"[{label}] missing ObjectSync RPC evidence")
    if not any(event.get("type") == "sync-complete" for event in events):
        raise SystemExit(f"[{label}] missing sync-complete event")

    return f"[{label}] ok ({len(events)} events)"


def validate_file_transfer_artifact(path: pathlib.Path, label: str) -> str:
    data = load_json(path)
    require_keys(data, {"captured_at", "events"}, label)

    events = data.get("events", [])
    if not isinstance(events, list) or not events:
        raise SystemExit(f"[{label}] events is empty")

    methods = {
        event.get("method", "")
        for event in events
        if event.get("type") == "unary_rpc"
    }
    required_methods = {
        "/coordinator.Coordinator/NetworkConfiguration",
        "/filesync.File/BlocksCheck",
        "/filesync.File/BlockPush",
    }
    missing_methods = sorted(required_methods - methods)
    if missing_methods:
        raise SystemExit(f"[{label}] missing file-transfer methods: {missing_methods}")

    upload_results = [event for event in events if event.get("type") == "upload_result"]
    if not upload_results:
        raise SystemExit(f"[{label}] missing upload_result note")
    latest = upload_results[-1]
    if latest.get("uploaded") is not True:
        raise SystemExit(f"[{label}] upload_result.uploaded != True")
    if latest.get("availability") != "NotExists":
        raise SystemExit(
            f"[{label}] upload_result.availability={latest.get('availability')!r}, "
            "expected 'NotExists'"
        )
    if not latest.get("cid"):
        raise SystemExit(f"[{label}] upload_result.cid is empty")

    return f"[{label}] ok ({len(events)} events)"


def validate_roundtrip_artifact(path: pathlib.Path) -> str:
    label = "phase40 roundtrip"
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "relation_key",
            "relation_object_id",
            "target_object_id",
            "file_object_id",
            "cid",
            "source_name",
            "source_mime",
            "expected_render",
            "observed_on_home2",
            "manytype_sync_capture_path",
            "file_transfer_capture_path",
            "read_home1_path",
            "read_home2_path",
            "metadata_path",
            "success",
        },
        label,
    )
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")
    if data.get("observed_on_home2") is not True:
        raise SystemExit(f"[{label}] observed_on_home2 != True")
    if data.get("relation_key") != "attachment":
        raise SystemExit(f"[{label}] relation_key != 'attachment'")
    if data.get("source_mime") != "application/pdf":
        raise SystemExit(f"[{label}] source_mime != 'application/pdf'")
    if not data.get("file_object_id"):
        raise SystemExit(f"[{label}] file_object_id is empty")
    if not data.get("cid"):
        raise SystemExit(f"[{label}] cid is empty")

    expected_render = data["expected_render"]
    read_home1 = repo_path(data["read_home1_path"])
    read_home2 = repo_path(data["read_home2_path"])
    for name, read_path in (("home1", read_home1), ("home2", read_home2)):
        if not read_path.exists():
            raise SystemExit(f"[{label}] missing {name} read artifact: {read_path}")
        content = read_path.read_text()
        if expected_render not in content:
            raise SystemExit(
                f"[{label}] expected render not present in {name} read artifact: "
                f"{expected_render!r}"
            )

    validate_manytype_sync_artifact(
        repo_path(data["manytype_sync_capture_path"]),
        f"{label} sync",
    )
    validate_file_transfer_artifact(
        repo_path(data["file_transfer_capture_path"]),
        f"{label} transfer",
    )
    validate_runtime_metadata(repo_path(data["metadata_path"]), f"{label} metadata")

    return f"[{label}] artifact ok ({data['target_object_id']})"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline validator for Phase 40 file relation artifacts."
    )
    parser.add_argument(
        "--artifact",
        default=str(TEST_VECTORS / "file-relation-roundtrip.json"),
    )
    args = parser.parse_args()

    result = validate_roundtrip_artifact(pathlib.Path(args.artifact))
    print(result)
    print("phase40 artifacts: PASSED")


if __name__ == "__main__":
    main()
