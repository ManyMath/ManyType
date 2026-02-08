#!/usr/bin/env python3

"""Offline verifier for the Phase 55 self-hosted compatibility artifact."""

from __future__ import annotations

import argparse
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_ARTIFACT = ROOT / "test_vectors" / "phase55" / "self-hosted-compatibility.json"


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


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 55 self-hosted compatibility artifact."
    )
    parser.add_argument(
        "--artifact",
        default=str(DEFAULT_ARTIFACT),
        help="Path to the Phase 55 self-hosted compatibility artifact.",
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
            "phase46_bundle_path",
            "metadata_path",
            "success",
        },
        "phase55 compatibility",
    )
    if artifact["scenario"] != "phase55 manytype to official self-hosted compatibility":
        raise SystemExit("[phase55 compatibility] unexpected scenario")
    if artifact["truth_surface"] != "self-hosted-official":
        raise SystemExit("[phase55 compatibility] unexpected truth surface")
    if artifact["success"] is not True:
        raise SystemExit("[phase55 compatibility] success != true")

    accepted_slice = artifact["accepted_slice"]
    if accepted_slice.get("detail_keys") != ["description", "featuredRelations"]:
        raise SystemExit("[phase55 accepted slice] unexpected detail keys")
    if accepted_slice.get("featured_relations_value") != ["description", "sourceObject"]:
        raise SystemExit("[phase55 accepted slice] unexpected featuredRelations value")

    scenario = artifact["manytype_to_official"]
    require_keys(
        scenario,
        {
            "object_id",
            "description",
            "featured_relations",
            "show_path",
            "restart_show_path",
            "sync_capture_path",
        },
        "phase55 manytype_to_official",
    )
    if scenario["featured_relations"] != ["description", "sourceObject"]:
        raise SystemExit("[phase55 manytype_to_official] unexpected featuredRelations")

    for show_path, label in (
        (pathlib.Path(scenario["show_path"]), "initial show"),
        (pathlib.Path(scenario["restart_show_path"]), "restart show"),
    ):
        show = load_json(show_path)
        root = show.get("root_details", {})
        if root.get("description") != scenario["description"]:
            raise SystemExit(f"[phase55 compatibility] {label} description mismatch")
        if root.get("featuredRelations") != ["description", "sourceObject"]:
            raise SystemExit(f"[phase55 compatibility] {label} featuredRelations mismatch")

    validate_manytype_sync_artifact(
        pathlib.Path(scenario["sync_capture_path"]),
        "phase55 manytype_to_official sync",
    )

    for path in (
        pathlib.Path(artifact["phase46_bundle_path"]),
        pathlib.Path(artifact["metadata_path"]),
    ):
        if not path.exists():
            raise SystemExit(f"[phase55 compatibility] missing referenced file: {path}")

    print("[phase55 compatibility] ok")
    print("phase55 compatibility: PASSED")


if __name__ == "__main__":
    main()
