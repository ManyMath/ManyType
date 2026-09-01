#!/usr/bin/env python3

"""Offline validator for test_vectors/phase39/*.json artifacts."""

import argparse
import json
import pathlib

from artifact_paths import repo_path


ROOT = pathlib.Path(__file__).resolve().parents[1]
TEST_VECTORS = ROOT / "test_vectors" / "phase39"


def load_path(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def validate_manytype_sync_artifact(path: pathlib.Path, label: str) -> str:
    data = load_path(path)
    required_keys = {
        "captured_at",
        "coordinator_address",
        "events",
        "network_config_path",
        "official_interop_mode",
        "space_id",
    }
    missing_keys = sorted(required_keys - data.keys())
    if missing_keys:
        raise SystemExit(f"{label} missing keys: {missing_keys}")

    events = data.get("events", [])
    if not isinstance(events, list) or not events:
        raise SystemExit(f"{label} has no events")

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
        raise SystemExit(f"{label} missing required RPC methods: {missing_methods}")

    if not any("ObjectSync" in method for method in methods):
        raise SystemExit(f"{label} missing ObjectSync RPC evidence")

    if not any(event.get("type") == "sync-complete" for event in events):
        raise SystemExit(f"{label} missing sync-complete event")

    return f"{label} ok ({len(events)} events)"


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing artifact keys: {missing}")


def validate_scenario_a(path: pathlib.Path) -> str:
    label = "phase39 scenario-A create-add"
    data = load_path(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "collection_id",
            "member_ids_created",
            "expected_members_ordered",
            "expected_member_lines",
            "observed_on_home2",
            "manytype_sync_capture_path",
            "success",
        },
        label,
    )
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")
    if data.get("observed_on_home2") is not True:
        raise SystemExit(f"[{label}] observed_on_home2 != True")
    if len(data.get("member_ids_created", [])) != 3:
        raise SystemExit(f"[{label}] member_ids_created length != 3")
    ordered = data.get("expected_members_ordered", [])
    created = data.get("member_ids_created", [])
    if ordered != [created[2], created[1], created[0]]:
        raise SystemExit(
            f"[{label}] expected reverse prepend order, got ordered={ordered} created={created}"
        )
    if len(data.get("expected_member_lines", [])) != 3:
        raise SystemExit(f"[{label}] expected_member_lines length != 3")
    validate_manytype_sync_artifact(
        repo_path(data["manytype_sync_capture_path"]),
        f"{label} sync",
    )
    return f"[{label}] artifact ok ({data['collection_id']})"


def validate_scenario_b(path: pathlib.Path) -> str:
    label = "phase39 scenario-B remove"
    data = load_path(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "collection_id",
            "removed_member_id",
            "expected_members_ordered",
            "expected_member_lines",
            "observed_on_home2",
            "manytype_sync_capture_path",
            "success",
        },
        label,
    )
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")
    if data.get("observed_on_home2") is not True:
        raise SystemExit(f"[{label}] observed_on_home2 != True")
    ordered = data.get("expected_members_ordered", [])
    if len(ordered) != 2:
        raise SystemExit(f"[{label}] expected_members_ordered length != 2")
    if data["removed_member_id"] in ordered:
        raise SystemExit(f"[{label}] removed member still present in expected_members_ordered")
    if len(data.get("expected_member_lines", [])) != 2:
        raise SystemExit(f"[{label}] expected_member_lines length != 2")
    validate_manytype_sync_artifact(
        repo_path(data["manytype_sync_capture_path"]),
        f"{label} sync",
    )
    return f"[{label}] artifact ok ({data['collection_id']})"


def validate_scenario_c(path: pathlib.Path) -> str:
    label = "phase39 scenario-C move"
    data = load_path(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "collection_id",
            "moved_member_id",
            "after_member_id",
            "expected_members_ordered",
            "expected_member_lines",
            "observed_on_home2",
            "manytype_sync_capture_path",
            "success",
        },
        label,
    )
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")
    if data.get("observed_on_home2") is not True:
        raise SystemExit(f"[{label}] observed_on_home2 != True")
    ordered = data.get("expected_members_ordered", [])
    if ordered != [data["after_member_id"], data["moved_member_id"]]:
        raise SystemExit(
            f"[{label}] expected_members_ordered does not reflect move semantics: {ordered}"
        )
    if len(data.get("expected_member_lines", [])) != 2:
        raise SystemExit(f"[{label}] expected_member_lines length != 2")
    validate_manytype_sync_artifact(
        repo_path(data["manytype_sync_capture_path"]),
        f"{label} sync",
    )
    return f"[{label}] artifact ok ({data['collection_id']})"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline validator for phase39 collection artifacts."
    )
    parser.add_argument(
        "--scenario-a",
        default=str(TEST_VECTORS / "scenario_a_create_add.json"),
    )
    parser.add_argument(
        "--scenario-b",
        default=str(TEST_VECTORS / "scenario_b_remove.json"),
    )
    parser.add_argument(
        "--scenario-c",
        default=str(TEST_VECTORS / "scenario_c_move.json"),
    )
    args = parser.parse_args()

    results = [
        validate_scenario_a(pathlib.Path(args.scenario_a)),
        validate_scenario_b(pathlib.Path(args.scenario_b)),
        validate_scenario_c(pathlib.Path(args.scenario_c)),
    ]
    for result in results:
        print(result)
    print("phase39 artifacts: PASSED")


if __name__ == "__main__":
    main()
