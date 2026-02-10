#!/usr/bin/env python3

"""Offline verifier for the Phase 63 self-hosted collection artifact."""

from __future__ import annotations

import argparse
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_ARTIFACT = (
    ROOT / "test_vectors" / "phase63" / "self-hosted-collection-compatibility.json"
)


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    return json.loads(path.read_text())


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def validate_manytype_sync_artifact(path: pathlib.Path, label: str) -> None:
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


def show_contains_expected_members(show: dict, expected: list[str], removed: list[str]) -> bool:
    expected_set = set(expected)
    removed_set = set(removed)

    for dataview in show.get("dataviews", []):
        for order in dataview.get("object_orders", []):
            object_ids = order.get("object_ids", [])
            if not isinstance(object_ids, list):
                continue
            filtered = [member for member in object_ids if member in expected_set | removed_set]
            if filtered == expected:
                return True

    links = show.get("root_details", {}).get("links", [])
    if isinstance(links, list):
        filtered_links = [member for member in links if member in expected_set | removed_set]
        if filtered_links == expected:
            return True

    return False


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 63 self-hosted collection artifact."
    )
    parser.add_argument(
        "--artifact",
        default=str(DEFAULT_ARTIFACT),
        help="Path to the Phase 63 self-hosted collection artifact.",
    )
    args = parser.parse_args()

    artifact_path = pathlib.Path(args.artifact)
    artifact = load_json(artifact_path)

    require_keys(
        artifact,
        {
            "captured_at",
            "scenario",
            "accepted_slice",
            "truth_surface",
            "manytype_to_official",
            "metadata_path",
            "success",
        },
        "phase63 compatibility",
    )
    if artifact["scenario"] != "phase63 manytype to official self-hosted collection compatibility":
        raise SystemExit("[phase63 compatibility] unexpected scenario")
    if artifact["truth_surface"] != "self-hosted-official":
        raise SystemExit("[phase63 compatibility] unexpected truth surface")
    if artifact["success"] is not True:
        raise SystemExit("[phase63 compatibility] success != true")

    accepted_slice = artifact["accepted_slice"]
    if accepted_slice.get("container_object_type") != "collection":
        raise SystemExit("[phase63 accepted slice] unexpected container_object_type")
    if accepted_slice.get("included_operations") != [
        "create-collection",
        "collection-add",
        "collection-remove",
        "collection-move-front",
    ]:
        raise SystemExit("[phase63 accepted slice] unexpected included_operations")

    scenario = artifact["manytype_to_official"]
    require_keys(
        scenario,
        {
            "collection_id",
            "member_ids_created",
            "expected_member_ids",
            "show_path",
            "restart_show_path",
            "add_sync_capture_path",
            "move_sync_capture_path",
            "remove_sync_capture_path",
        },
        "phase63 manytype_to_official",
    )
    member_ids_created = scenario["member_ids_created"]
    expected_member_ids = scenario["expected_member_ids"]
    if not isinstance(member_ids_created, list) or len(member_ids_created) != 3:
        raise SystemExit("[phase63 manytype_to_official] expected three created member ids")
    if expected_member_ids != [member_ids_created[2], member_ids_created[1]]:
        raise SystemExit("[phase63 manytype_to_official] unexpected expected_member_ids ordering")
    removed_member_ids = [member_ids_created[0]]

    for show_path, label in (
        (pathlib.Path(scenario["show_path"]), "initial show"),
        (pathlib.Path(scenario["restart_show_path"]), "restart show"),
    ):
        show = load_json(show_path)
        if not show_contains_expected_members(show, expected_member_ids, removed_member_ids):
            raise SystemExit(f"[phase63 compatibility] {label} missing expected collection order")

    for capture_path, label in (
        (pathlib.Path(scenario["add_sync_capture_path"]), "add sync"),
        (pathlib.Path(scenario["move_sync_capture_path"]), "move sync"),
        (pathlib.Path(scenario["remove_sync_capture_path"]), "remove sync"),
    ):
        validate_manytype_sync_artifact(capture_path, f"phase63 {label}")

    metadata_path = pathlib.Path(artifact["metadata_path"])
    if not metadata_path.exists():
        raise SystemExit(f"[phase63 compatibility] missing metadata: {metadata_path}")

    print("[phase63 compatibility] ok")
    print("phase63 compatibility: PASSED")


if __name__ == "__main__":
    main()
