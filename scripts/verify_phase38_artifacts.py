#!/usr/bin/env python3

"""Phase 38 offline verifier for test_vectors/phase38/*.json artifacts.

Asserts structural properties of three scenario JSONs + their paired
MANYTYPE_SYNC_CAPTURE_PATH sync-capture JSONs. Mirrors
scripts/verify_phase37_artifacts.py: the sync-capture validator body is
copied verbatim from phase37 so the same required RPC method set applies.
"""

import argparse
import json
import pathlib
import sys

from artifact_paths import repo_path


ROOT = pathlib.Path(__file__).resolve().parents[1]
TEST_VECTORS = ROOT / "test_vectors" / "phase38"


def load_path(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def validate_manytype_sync_artifact(path: pathlib.Path, label: str) -> str:
    """Copy of scripts/verify_phase37_artifacts.py:validate_manytype_sync_artifact.

    Required top-level keys: captured_at, coordinator_address, events,
    network_config_path, official_interop_mode, space_id.

    Required RPC methods in events (full paths, matches phase37):
    NetworkConfiguration, SpaceStatusCheck, SpaceSign, SpacePush, HeadSync.
    An ObjectSync match is expected plus a terminal 'sync-complete' event.
    """
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


def _require_keys(data: dict, keys: set, label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing artifact keys: {missing}")


def validate_phase38_status_create(path: pathlib.Path) -> str:
    label = "phase38 scenario-A status-create"
    data = load_path(path)
    _require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "relation_key",
            "target_object_id",
            "option_id",
            "expected_option_name",
            "expected_option_color",
            "expected_selectdict_updated",
            "expected_status_value",
            "expected_render",
            "post_replay_resolved",
            "roundtrip_observed",
            "manytype_sync_capture_path",
            "success",
        },
        label,
    )
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")
    if data.get("expected_selectdict_updated") is not True:
        raise SystemExit(f"[{label}] expected_selectdict_updated != True")
    if data.get("post_replay_resolved") is not True:
        raise SystemExit(f"[{label}] post_replay_resolved != True")
    if data.get("roundtrip_observed") is not True:
        raise SystemExit(f"[{label}] roundtrip_observed != True")
    if data.get("expected_option_name") != "Done":
        raise SystemExit(
            f"[{label}] expected_option_name={data.get('expected_option_name')!r}, expected 'Done'"
        )
    if data.get("expected_option_color") != "red":
        raise SystemExit(
            f"[{label}] expected_option_color={data.get('expected_option_color')!r}, expected 'red'"
        )
    if data.get("expected_render") != "[status] Done (red)":
        raise SystemExit(
            f"[{label}] expected_render={data.get('expected_render')!r}, "
            "expected '[status] Done (red)'"
        )
    if data.get("expected_status_value") != data.get("option_id"):
        raise SystemExit(
            f"[{label}] expected_status_value {data.get('expected_status_value')!r} "
            f"!= option_id {data.get('option_id')!r}"
        )
    sync_capture_path = data.get("manytype_sync_capture_path", "")
    if not sync_capture_path:
        raise SystemExit(f"[{label}] manytype_sync_capture_path is empty")
    validate_manytype_sync_artifact(repo_path(sync_capture_path), f"{label} sync")
    return f"[{label}] artifact ok ({data['target_object_id']})"


def validate_phase38_tag_multi(path: pathlib.Path) -> str:
    label = "phase38 scenario-B tag-multi"
    data = load_path(path)
    _require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "relation_key",
            "target_object_id",
            "expected_tag_count",
            "expected_tag_ids",
            "expected_tag_names_ordered",
            "expected_render",
            "post_replay_resolved",
            "roundtrip_observed",
            "manytype_sync_capture_path",
            "success",
        },
        label,
    )
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")
    if data.get("expected_tag_count") != 3:
        raise SystemExit(
            f"[{label}] expected_tag_count={data.get('expected_tag_count')!r}, expected 3"
        )
    tag_ids = data.get("expected_tag_ids", [])
    if not isinstance(tag_ids, list) or len(tag_ids) != 3:
        raise SystemExit(f"[{label}] expected_tag_ids length != 3: {tag_ids}")
    if data.get("expected_tag_names_ordered") != ["Alpha", "Beta", "Gamma"]:
        raise SystemExit(
            f"[{label}] expected_tag_names_ordered={data.get('expected_tag_names_ordered')!r}, "
            "expected ['Alpha', 'Beta', 'Gamma']"
        )
    if data.get("expected_render") != "[taglist] Alpha, Beta, Gamma":
        raise SystemExit(
            f"[{label}] expected_render={data.get('expected_render')!r}, "
            "expected '[taglist] Alpha, Beta, Gamma'"
        )
    if data.get("post_replay_resolved") is not True:
        raise SystemExit(f"[{label}] post_replay_resolved != True")
    if data.get("roundtrip_observed") is not True:
        raise SystemExit(f"[{label}] roundtrip_observed != True")
    sync_capture_path = data.get("manytype_sync_capture_path", "")
    if not sync_capture_path:
        raise SystemExit(f"[{label}] manytype_sync_capture_path is empty")
    validate_manytype_sync_artifact(repo_path(sync_capture_path), f"{label} sync")
    return f"[{label}] artifact ok ({data['target_object_id']})"


def validate_phase38_tag_add_remove(path: pathlib.Path) -> str:
    label = "phase38 scenario-C tag-add-remove"
    data = load_path(path)
    _require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "relation_key",
            "target_object_id",
            "expected_initial_tag_ids",
            "expected_removed",
            "expected_added",
            "expected_final_tag_ids",
            "expected_final_tag_names_ordered",
            "expected_render",
            "post_replay_resolved",
            "roundtrip_observed",
            "manytype_sync_capture_path",
            "success",
        },
        label,
    )
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")

    initial = data.get("expected_initial_tag_ids", [])
    removed_list = data.get("expected_removed", [])
    added_list = data.get("expected_added", [])
    final = data.get("expected_final_tag_ids", [])

    if not isinstance(initial, list) or len(initial) != 3:
        raise SystemExit(f"[{label}] expected_initial_tag_ids length != 3: {initial}")
    if not isinstance(final, list) or len(final) != 3:
        raise SystemExit(f"[{label}] expected_final_tag_ids length != 3: {final}")
    if not isinstance(removed_list, list) or len(removed_list) != 1:
        raise SystemExit(f"[{label}] expected_removed length != 1: {removed_list}")
    if not isinstance(added_list, list) or len(added_list) != 1:
        raise SystemExit(f"[{label}] expected_added length != 1: {added_list}")

    removed = removed_list[0]
    added = added_list[0]

    if removed in final:
        raise SystemExit(
            f"[{label}] removed ID {removed!r} still present in expected_final_tag_ids"
        )
    if added not in final:
        raise SystemExit(
            f"[{label}] added ID {added!r} not present in expected_final_tag_ids"
        )

    # STATTAG-04 regression invariant: the retained IDs (initial minus removed)
    # keep their original order, and the added ID appends at the end.
    retained = [x for x in initial if x != removed]
    if data["expected_final_tag_ids"] != retained + [added]:
        raise SystemExit(
            f"[{label}] expected_final_tag_ids == retained + [added] FAILED: "
            f"final={data['expected_final_tag_ids']} retained={retained} added={added}"
        )

    if data.get("expected_final_tag_names_ordered") != ["Alpha", "Gamma", "Delta"]:
        raise SystemExit(
            f"[{label}] expected_final_tag_names_ordered="
            f"{data.get('expected_final_tag_names_ordered')!r}, "
            "expected ['Alpha', 'Gamma', 'Delta']"
        )
    if data.get("expected_render") != "[taglist] Alpha, Gamma, Delta":
        raise SystemExit(
            f"[{label}] expected_render={data.get('expected_render')!r}, "
            "expected '[taglist] Alpha, Gamma, Delta'"
        )
    if data.get("post_replay_resolved") is not True:
        raise SystemExit(f"[{label}] post_replay_resolved != True")
    if data.get("roundtrip_observed") is not True:
        raise SystemExit(f"[{label}] roundtrip_observed != True")

    sync_capture_path = data.get("manytype_sync_capture_path", "")
    if not sync_capture_path:
        raise SystemExit(f"[{label}] manytype_sync_capture_path is empty")
    validate_manytype_sync_artifact(repo_path(sync_capture_path), f"{label} sync")
    return f"[{label}] artifact ok ({data['target_object_id']})"


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Offline validator for phase38 STRelationOption test_vectors artifacts."
    )
    parser.add_argument(
        "--status-create",
        default=str(TEST_VECTORS / "status-create.json"),
        help="Path to scenario A (status create) artifact.",
    )
    parser.add_argument(
        "--tag-multi",
        default=str(TEST_VECTORS / "tag-multi.json"),
        help="Path to scenario B (tag multi full-replace) artifact.",
    )
    parser.add_argument(
        "--tag-add-remove",
        default=str(TEST_VECTORS / "tag-add-remove.json"),
        help="Path to scenario C (tag add-remove regression, STATTAG-04) artifact.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    results = [
        validate_phase38_status_create(pathlib.Path(args.status_create)),
        validate_phase38_tag_multi(pathlib.Path(args.tag_multi)),
        validate_phase38_tag_add_remove(pathlib.Path(args.tag_add_remove)),
    ]
    for result in results:
        print(result)
    print("phase38 artifacts: PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
