#!/usr/bin/env python3

"""Offline verifier for the Phase 64 manytype_server collection artifact."""

from __future__ import annotations

import argparse
import json
import pathlib

from artifact_paths import repo_path


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_ARTIFACT = (
    ROOT / "test_vectors" / "phase64" / "manytype-server-collection-compatibility.json"
)


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


def validate_action_output(
    path: pathlib.Path,
    action: str,
    object_id: str,
    member_ids: list[str] | None = None,
) -> None:
    data = load_json(path)
    require_keys(data, {"action", "object_id"}, f"phase64 {action}")
    if data["action"] != action:
        raise SystemExit(f"[phase64 {action}] unexpected action")
    if data["object_id"] != object_id:
        raise SystemExit(f"[phase64 {action}] object_id mismatch")
    if data.get("error_code"):
        raise SystemExit(f"[phase64 {action}] unexpected error_code: {data['error_code']}")
    if member_ids is not None and data.get("member_ids") != member_ids:
        raise SystemExit(f"[phase64 {action}] member_ids mismatch")


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


def extract_members_section(text: str, label: str) -> str:
    marker = "## Members\n"
    if marker not in text:
        raise SystemExit(f"[{label}] missing Members section")
    section = text.split(marker, 1)[1]
    next_heading = section.find("\n## ")
    if next_heading != -1:
        section = section[:next_heading]
    return section


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 64 manytype_server collection artifact."
    )
    parser.add_argument(
        "--artifact",
        default=str(DEFAULT_ARTIFACT),
        help="Path to the Phase 64 manytype_server collection artifact.",
    )
    args = parser.parse_args()

    artifact = load_json(pathlib.Path(args.artifact))

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
        "phase64 compatibility",
    )
    if artifact["scenario"] != "phase64 official to manytype collection compatibility":
        raise SystemExit("[phase64 compatibility] unexpected scenario")
    if artifact["truth_surface"] != "manytype_server":
        raise SystemExit("[phase64 compatibility] unexpected truth surface")
    if artifact["success"] is not True:
        raise SystemExit("[phase64 compatibility] success != true")

    accepted_slice = artifact["accepted_slice"]
    if accepted_slice.get("container_object_type") != "collection":
        raise SystemExit("[phase64 accepted slice] unexpected container_object_type")
    if accepted_slice.get("included_operations") != [
        "create-collection",
        "collection-add",
        "collection-remove",
        "collection-move-front",
    ]:
        raise SystemExit("[phase64 accepted slice] unexpected included_operations")
    if accepted_slice.get("official_post_mutation_reread_required") is not True:
        raise SystemExit("[phase64 accepted slice] official_post_mutation_reread_required != true")
    if accepted_slice.get("manytype_observation_retry_required") is not True:
        raise SystemExit("[phase64 accepted slice] manytype_observation_retry_required != true")

    scenario = artifact["official_to_manytype"]
    require_keys(
        scenario,
        {
            "collection_id",
            "member_ids_created",
            "expected_member_ids",
            "official_convert_path",
            "official_add_path",
            "official_sort_path",
            "official_remove_path",
            "official_show_path",
            "read_path",
            "reopen_read_path",
            "main_sync_capture_path",
            "reopen_sync_capture_path",
            "diagnostics_path",
            "main_observed_attempt",
            "reopen_observed_attempt",
        },
        "phase64 official_to_manytype",
    )
    collection_id = scenario["collection_id"]
    member_ids_created = scenario["member_ids_created"]
    expected_member_ids = scenario["expected_member_ids"]
    if not isinstance(member_ids_created, list) or len(member_ids_created) != 3:
        raise SystemExit("[phase64 official_to_manytype] expected three created member ids")
    if expected_member_ids != [member_ids_created[2], member_ids_created[1]]:
        raise SystemExit("[phase64 official_to_manytype] unexpected expected_member_ids ordering")
    removed_member_ids = [member_ids_created[0]]
    if int(scenario["main_observed_attempt"]) < 1:
        raise SystemExit("[phase64 official_to_manytype] invalid main_observed_attempt")
    if int(scenario["reopen_observed_attempt"]) < 1:
        raise SystemExit("[phase64 official_to_manytype] invalid reopen_observed_attempt")

    validate_action_output(
        repo_path(scenario["official_convert_path"]),
        "object-to-collection",
        collection_id,
    )
    validate_action_output(
        repo_path(scenario["official_add_path"]),
        "object-collection-add",
        collection_id,
        member_ids_created,
    )
    validate_action_output(
        repo_path(scenario["official_sort_path"]),
        "object-collection-sort",
        collection_id,
        [member_ids_created[2], member_ids_created[1], member_ids_created[0]],
    )
    validate_action_output(
        repo_path(scenario["official_remove_path"]),
        "object-collection-remove",
        collection_id,
        removed_member_ids,
    )

    show = load_json(repo_path(scenario["official_show_path"]))
    if not show_contains_expected_members(show, expected_member_ids, removed_member_ids):
        raise SystemExit("[phase64 compatibility] official show missing expected final member order")

    for path, label in (
        (repo_path(scenario["read_path"]), "main Manytype read"),
        (repo_path(scenario["reopen_read_path"]), "reopen Manytype read"),
    ):
        section = extract_members_section(read_text(path), label)
        ordered_positions = [section.index(member_id) for member_id in expected_member_ids]
        if ordered_positions != sorted(ordered_positions):
            raise SystemExit(f"[phase64 compatibility] {label} missing expected member order")
        for member_id in expected_member_ids:
            if member_id not in section:
                raise SystemExit(f"[phase64 compatibility] {label} missing member {member_id}")
        for member_id in removed_member_ids:
            if member_id in section:
                raise SystemExit(f"[phase64 compatibility] {label} still contains removed member {member_id}")

    validate_manytype_sync_artifact(
        repo_path(scenario["main_sync_capture_path"]),
        "phase64 main sync",
    )
    validate_manytype_sync_artifact(
        repo_path(scenario["reopen_sync_capture_path"]),
        "phase64 reopen sync",
    )

    diagnostics = load_json(repo_path(scenario["diagnostics_path"]))
    require_keys(
        diagnostics,
        {"stored_changes", "full_sync_responses"},
        "phase64 diagnostics",
    )
    stored_changes = diagnostics.get("stored_changes", [])
    if not any(change.get("kind") == "tree" for change in stored_changes):
        raise SystemExit("[phase64 diagnostics] expected at least one tree change")
    responses = diagnostics.get("full_sync_responses", [])
    if not responses:
        raise SystemExit("[phase64 diagnostics] missing full_sync_responses")
    if not any(response.get("change_ids") for response in responses):
        raise SystemExit("[phase64 diagnostics] expected at least one response with change_ids")

    metadata_path = repo_path(artifact["metadata_path"])
    if not metadata_path.exists():
        raise SystemExit(f"[phase64 compatibility] missing metadata: {metadata_path}")

    print("[phase64 compatibility] ok")
    print("phase64 compatibility: PASSED")


if __name__ == "__main__":
    main()
