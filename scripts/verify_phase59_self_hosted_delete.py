#!/usr/bin/env python3

"""Offline verifier for the Phase 59 self-hosted delete artifact."""

from __future__ import annotations

import argparse
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_ARTIFACT = ROOT / "test_vectors" / "phase59" / "self-hosted-delete-compatibility.json"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    return json.loads(path.read_text())


def read_text(path: pathlib.Path) -> str:
    if not path.exists():
        raise SystemExit(f"missing text artifact: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


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


def validate_official_search(
    path: pathlib.Path,
    object_id: str,
    object_name: str,
    expected_present: bool,
    label: str,
) -> None:
    data = load_json(path)
    require_keys(
        data,
        {"action", "space_id", "query", "record_count", "object_ids", "names", "records"},
        label,
    )
    if data.get("action") != "object-search":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    if data.get("query") != object_name:
        raise SystemExit(f"[{label}] unexpected query: {data.get('query')}")
    object_ids = data.get("object_ids", [])
    if not isinstance(object_ids, list):
        raise SystemExit(f"[{label}] object_ids is not a list")
    present = object_id in object_ids
    if present != expected_present:
        raise SystemExit(
            f"[{label}] expected present={expected_present} but saw present={present}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 59 self-hosted delete artifact."
    )
    parser.add_argument(
        "--artifact",
        default=str(DEFAULT_ARTIFACT),
        help="Path to the Phase 59 self-hosted delete artifact.",
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
            "phase47_bundle_path",
            "metadata_path",
            "success",
        },
        "phase59 compatibility",
    )
    if artifact["scenario"] != "phase59 manytype to official self-hosted delete compatibility":
        raise SystemExit("[phase59 compatibility] unexpected scenario")
    if artifact["truth_surface"] != "self-hosted-official":
        raise SystemExit("[phase59 compatibility] unexpected truth surface")
    if artifact["success"] is not True:
        raise SystemExit("[phase59 compatibility] success != true")

    accepted_slice = artifact["accepted_slice"]
    if accepted_slice.get("mutation_family") != "archive-backed object deletion":
        raise SystemExit("[phase59 accepted slice] unexpected mutation family")
    if accepted_slice.get("bounded_object_type") != "page":
        raise SystemExit("[phase59 accepted slice] unexpected bounded object type")

    scenario = artifact["manytype_to_official"]
    require_keys(
        scenario,
        {
            "object_id",
            "object_name",
            "presence_search_path",
            "delete_output_path",
            "delete_sync_capture_path",
            "absence_search_path",
            "restart_absence_search_path",
        },
        "phase59 manytype_to_official",
    )

    validate_official_search(
        pathlib.Path(scenario["presence_search_path"]),
        scenario["object_id"],
        scenario["object_name"],
        True,
        "phase59 presence search",
    )
    validate_official_search(
        pathlib.Path(scenario["absence_search_path"]),
        scenario["object_id"],
        scenario["object_name"],
        False,
        "phase59 post-delete search",
    )
    validate_official_search(
        pathlib.Path(scenario["restart_absence_search_path"]),
        scenario["object_id"],
        scenario["object_name"],
        False,
        "phase59 restart search",
    )

    delete_output = read_text(pathlib.Path(scenario["delete_output_path"]))
    if f"Deleted {scenario['object_id']}" not in delete_output:
        raise SystemExit("[phase59 compatibility] delete output missing deleted confirmation")

    validate_manytype_sync_artifact(
        pathlib.Path(scenario["delete_sync_capture_path"]),
        "phase59 manytype_to_official sync",
    )

    for path in (
        pathlib.Path(artifact["phase47_bundle_path"]),
        pathlib.Path(artifact["metadata_path"]),
    ):
        if not path.exists():
            raise SystemExit(f"[phase59 compatibility] missing referenced file: {path}")

    print("[phase59 compatibility] ok")
    print("phase59 compatibility: PASSED")


if __name__ == "__main__":
    main()
