#!/usr/bin/env python3

"""Offline verifier for the Phase 60 manytype_server delete artifact."""

from __future__ import annotations

import argparse
import json
import pathlib
import re


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_ARTIFACT = ROOT / "test_vectors" / "phase60" / "manytype-server-delete-compatibility.json"


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


def validate_manytype_list_absence(path: pathlib.Path, object_id: str, label: str) -> None:
    text = read_text(path)
    rows = [
        line
        for line in text.splitlines()
        if re.match(r"^bafy[a-z0-9]+\s{2,}\S+\s{2,}.+", line)
    ]
    if object_id in "\n".join(rows):
        raise SystemExit(f"[{label}] still contains deleted object id {object_id}")


def validate_manytype_read_absence(path: pathlib.Path, object_id: str, label: str) -> None:
    text = read_text(path)
    archived_message = f"Object {object_id} has been deleted or archived"
    not_found_message = f"Object not found: {object_id}"
    if archived_message not in text and not_found_message not in text:
        raise SystemExit(f"[{label}] missing read refusal for {object_id}")


def validate_official_delete(path: pathlib.Path, object_id: str) -> None:
    label = "phase60 official delete"
    data = load_json(path)
    require_keys(
        data,
        {"action", "object_id", "archive_attempted", "archived_first", "delete_attempted"},
        label,
    )
    if data.get("action") != "object-delete":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    if data.get("object_id") != object_id:
        raise SystemExit(f"[{label}] object_id mismatch")
    if data.get("archive_attempted") is not True:
        raise SystemExit(f"[{label}] archive_attempted != true")
    if data.get("delete_attempted") is not True:
        raise SystemExit(f"[{label}] delete_attempted != true")
    if data.get("error_code"):
        raise SystemExit(f"[{label}] unexpected error_code: {data['error_code']}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 60 manytype_server delete artifact."
    )
    parser.add_argument(
        "--artifact",
        default=str(DEFAULT_ARTIFACT),
        help="Path to the Phase 60 manytype_server delete artifact.",
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
        "phase60 compatibility",
    )
    if artifact["scenario"] != "phase60 official to manytype delete compatibility":
        raise SystemExit("[phase60 compatibility] unexpected scenario")
    if artifact["truth_surface"] != "manytype_server":
        raise SystemExit("[phase60 compatibility] unexpected truth surface")
    if artifact["success"] is not True:
        raise SystemExit("[phase60 compatibility] success != true")

    accepted_slice = artifact["accepted_slice"]
    if accepted_slice.get("mutation_family") != "archive-backed object deletion":
        raise SystemExit("[phase60 accepted slice] unexpected mutation family")
    if accepted_slice.get("bounded_object_type") != "page":
        raise SystemExit("[phase60 accepted slice] unexpected bounded object type")
    for key in (
        "manytype_list_absence_required",
        "manytype_read_refusal_required",
        "fresh_home_reread_required",
    ):
        if accepted_slice.get(key) is not True:
            raise SystemExit(f"[phase60 accepted slice] {key} != true")

    scenario = artifact["official_to_manytype"]
    require_keys(
        scenario,
        {
            "object_id",
            "object_name",
            "type_preload_path",
            "create_output_path",
            "predelete_read_path",
            "delete_output_path",
            "main_sync_capture_path",
            "list_absence_path",
            "read_refusal_path",
            "reopen_sync_capture_path",
            "reopen_list_absence_path",
            "reopen_read_refusal_path",
            "diagnostics_path",
            "main_observed_attempt",
            "reopen_observed_attempt",
        },
        "phase60 official_to_manytype",
    )
    if int(scenario["main_observed_attempt"]) < 1:
        raise SystemExit("[phase60 official_to_manytype] invalid main observed attempt")
    if int(scenario["reopen_observed_attempt"]) < 1:
        raise SystemExit("[phase60 official_to_manytype] invalid reopen observed attempt")

    validate_official_delete(pathlib.Path(scenario["delete_output_path"]), scenario["object_id"])

    predelete_text = read_text(pathlib.Path(scenario["predelete_read_path"]))
    if f"Object: {scenario['object_id']}" not in predelete_text and scenario["object_name"] not in predelete_text:
        raise SystemExit("[phase60 compatibility] predelete read never surfaced the object")

    validate_manytype_list_absence(
        pathlib.Path(scenario["list_absence_path"]),
        scenario["object_id"],
        "phase60 current-home list",
    )
    validate_manytype_read_absence(
        pathlib.Path(scenario["read_refusal_path"]),
        scenario["object_id"],
        "phase60 current-home read",
    )
    validate_manytype_list_absence(
        pathlib.Path(scenario["reopen_list_absence_path"]),
        scenario["object_id"],
        "phase60 reopen-home list",
    )
    validate_manytype_read_absence(
        pathlib.Path(scenario["reopen_read_refusal_path"]),
        scenario["object_id"],
        "phase60 reopen-home read",
    )

    validate_manytype_sync_artifact(
        pathlib.Path(scenario["main_sync_capture_path"]),
        "phase60 main sync",
    )
    validate_manytype_sync_artifact(
        pathlib.Path(scenario["reopen_sync_capture_path"]),
        "phase60 reopen sync",
    )

    diagnostics = load_json(pathlib.Path(scenario["diagnostics_path"]))
    require_keys(
        diagnostics,
        {"stored_changes", "full_sync_responses"},
        "phase60 diagnostics",
    )
    stored_changes = diagnostics.get("stored_changes", [])
    if not any(change.get("kind") == "tree" for change in stored_changes):
        raise SystemExit("[phase60 diagnostics] expected at least one tree change")
    responses = diagnostics.get("full_sync_responses", [])
    if not responses:
        raise SystemExit("[phase60 diagnostics] missing full_sync_responses")
    if not any(response.get("change_ids") for response in responses):
        raise SystemExit("[phase60 diagnostics] expected at least one response with change_ids")

    metadata_path = pathlib.Path(artifact["metadata_path"])
    if not metadata_path.exists():
        raise SystemExit(f"[phase60 compatibility] missing metadata: {metadata_path}")

    print("[phase60 compatibility] ok")
    print("phase60 compatibility: PASSED")


if __name__ == "__main__":
    main()
