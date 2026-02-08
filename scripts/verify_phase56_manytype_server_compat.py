#!/usr/bin/env python3

"""Offline verifier for the Phase 56 manytype_server compatibility artifact."""

from __future__ import annotations

import argparse
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_ARTIFACT = ROOT / "test_vectors" / "phase56" / "manytype-server-compatibility.json"


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
        description="Offline verifier for the Phase 56 manytype_server compatibility artifact."
    )
    parser.add_argument(
        "--artifact",
        default=str(DEFAULT_ARTIFACT),
        help="Path to the Phase 56 manytype_server compatibility artifact.",
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
            "official_to_manytype",
            "metadata_path",
            "success",
        },
        "phase56 compatibility",
    )
    if artifact["scenario"] != "phase56 official to manytype compatibility":
        raise SystemExit("[phase56 compatibility] unexpected scenario")
    if artifact["truth_surface"] != "manytype_server":
        raise SystemExit("[phase56 compatibility] unexpected truth surface")
    if artifact["success"] is not True:
        raise SystemExit("[phase56 compatibility] success != true")

    accepted_slice = artifact["accepted_slice"]
    if accepted_slice.get("detail_keys") != ["description", "featuredRelations"]:
        raise SystemExit("[phase56 accepted slice] unexpected detail keys")
    if accepted_slice.get("featured_relations_value") != ["description", "sourceObject"]:
        raise SystemExit("[phase56 accepted slice] unexpected featuredRelations value")
    if accepted_slice.get("official_post_edit_reread_required") is not True:
        raise SystemExit("[phase56 accepted slice] post-edit official reread requirement missing")
    if accepted_slice.get("manytype_observation_retry_required") is not True:
        raise SystemExit("[phase56 accepted slice] retry requirement missing")

    scenario = artifact["official_to_manytype"]
    require_keys(
        scenario,
        {
            "object_id",
            "description",
            "featured_relations",
            "official_show_path",
            "read_path",
            "reopen_read_path",
            "main_sync_capture_path",
            "reopen_sync_capture_path",
            "diagnostics_path",
            "main_observed_attempt",
            "reopen_observed_attempt",
        },
        "phase56 official_to_manytype",
    )
    if scenario["featured_relations"] != ["description", "sourceObject"]:
        raise SystemExit("[phase56 official_to_manytype] unexpected featuredRelations")
    if int(scenario["main_observed_attempt"]) < 1:
        raise SystemExit("[phase56 official_to_manytype] invalid main observed attempt")
    if int(scenario["reopen_observed_attempt"]) < 1:
        raise SystemExit("[phase56 official_to_manytype] invalid reopen observed attempt")

    show = load_json(pathlib.Path(scenario["official_show_path"]))
    root = show.get("root_details", {})
    if root.get("description") != scenario["description"]:
        raise SystemExit("[phase56 compatibility] official show description mismatch")
    if root.get("featuredRelations") != ["description", "sourceObject"]:
        raise SystemExit("[phase56 compatibility] official show featuredRelations mismatch")

    for path, label in (
        (pathlib.Path(scenario["read_path"]), "main Manytype read"),
        (pathlib.Path(scenario["reopen_read_path"]), "reopen Manytype read"),
    ):
        text = read_text(path)
        if f"[description] {scenario['description']}" not in text:
            raise SystemExit(f"[phase56 compatibility] {label} missing description line")
        if "[featuredRelations] description, sourceObject" not in text:
            raise SystemExit(f"[phase56 compatibility] {label} missing featuredRelations line")

    validate_manytype_sync_artifact(
        pathlib.Path(scenario["main_sync_capture_path"]),
        "phase56 main sync",
    )
    validate_manytype_sync_artifact(
        pathlib.Path(scenario["reopen_sync_capture_path"]),
        "phase56 reopen sync",
    )

    diagnostics = load_json(pathlib.Path(scenario["diagnostics_path"]))
    require_keys(
        diagnostics,
        {"stored_changes", "full_sync_responses"},
        "phase56 diagnostics",
    )
    stored_changes = diagnostics.get("stored_changes", [])
    if not any(change.get("kind") == "tree" for change in stored_changes):
        raise SystemExit("[phase56 diagnostics] expected at least one tree change")
    responses = diagnostics.get("full_sync_responses", [])
    if not responses:
        raise SystemExit("[phase56 diagnostics] missing full_sync_responses")
    if not any(response.get("change_ids") for response in responses):
        raise SystemExit("[phase56 diagnostics] expected at least one response with change_ids")

    metadata_path = pathlib.Path(artifact["metadata_path"])
    if not metadata_path.exists():
        raise SystemExit(f"[phase56 compatibility] missing metadata: {metadata_path}")

    print("[phase56 compatibility] ok")
    print("phase56 compatibility: PASSED")


if __name__ == "__main__":
    main()
