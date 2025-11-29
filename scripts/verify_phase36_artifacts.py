#!/usr/bin/env python3

import argparse
import json
import pathlib
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
TEST_VECTORS = ROOT / "test_vectors"


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


def validate_deletion_manytype_authored(path: pathlib.Path) -> str:
    data = load_path(path)
    required = {
        "captured_at",
        "scenario",
        "space_id",
        "object_id",
        "deleted_by",
        "official_observed_deleted",
        "manytype_sync_capture_path",
        "success",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"phase36 deletion (manytype-authored) missing keys: {missing}")

    if data.get("deleted_by") != "manytype":
        raise SystemExit(
            f"phase36 deletion (manytype-authored) deleted_by={data.get('deleted_by')!r}, expected 'manytype'"
        )

    if not data.get("official_observed_deleted"):
        raise SystemExit("phase36 deletion (manytype-authored) official_observed_deleted is falsy")

    if not data.get("success"):
        raise SystemExit("phase36 deletion (manytype-authored) success is false")

    sync_path = pathlib.Path(data["manytype_sync_capture_path"])
    validate_manytype_sync_artifact(sync_path, "phase36 deletion (manytype-authored) sync")

    return "phase36 deletion (manytype-authored) ok"


def validate_deletion_official_authored(path: pathlib.Path) -> str:
    data = load_path(path)
    required = {
        "captured_at",
        "scenario",
        "space_id",
        "object_id",
        "deleted_by",
        "manytype_excluded_from_list",
        "manytype_sync_capture_path",
        "success",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"phase36 deletion (official-authored) missing keys: {missing}")

    if data.get("deleted_by") != "official":
        raise SystemExit(
            f"phase36 deletion (official-authored) deleted_by={data.get('deleted_by')!r}, expected 'official'"
        )

    if not data.get("manytype_excluded_from_list"):
        raise SystemExit("phase36 deletion (official-authored) manytype_excluded_from_list is falsy")

    if not data.get("success"):
        raise SystemExit("phase36 deletion (official-authored) success is false")

    sync_path = pathlib.Path(data["manytype_sync_capture_path"])
    validate_manytype_sync_artifact(sync_path, "phase36 deletion (official-authored) sync")

    return "phase36 deletion (official-authored) ok"


def validate_type_manytype_authored(path: pathlib.Path) -> str:
    data = load_path(path)
    required = {
        "captured_at",
        "scenario",
        "space_id",
        "type_object_id",
        "relation_object_id",
        "official_space_joined",
        "manytype_sync_capture_path",
        "success",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"phase36 type/relation (manytype-authored) missing keys: {missing}")

    type_id = data.get("type_object_id", "")
    if not isinstance(type_id, str) or not type_id:
        raise SystemExit("phase36 type/relation (manytype-authored) type_object_id is empty or not a string")

    relation_id = data.get("relation_object_id", "")
    if not isinstance(relation_id, str) or not relation_id:
        raise SystemExit("phase36 type/relation (manytype-authored) relation_object_id is empty or not a string")

    if not data.get("official_space_joined"):
        raise SystemExit("phase36 type/relation (manytype-authored) official_space_joined is falsy")

    if not data.get("success"):
        raise SystemExit("phase36 type/relation (manytype-authored) success is false")

    sync_path = pathlib.Path(data["manytype_sync_capture_path"])
    validate_manytype_sync_artifact(sync_path, "phase36 type/relation (manytype-authored) sync")

    return "phase36 type/relation (manytype-authored) ok"


def validate_type_official_authored(path: pathlib.Path) -> str:
    data = load_path(path)
    required = {
        "captured_at",
        "scenario",
        "space_id",
        "object_id",
        "expected_type",
        "manytype_observed_type",
        "manytype_sync_capture_path",
        "success",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"phase36 type/relation (official-authored) missing keys: {missing}")

    observed_type = data.get("manytype_observed_type", "")
    if not isinstance(observed_type, str) or not observed_type:
        raise SystemExit("phase36 type/relation (official-authored) manytype_observed_type is empty or not a string")

    if not data.get("success"):
        raise SystemExit("phase36 type/relation (official-authored) success is false")

    sync_path = pathlib.Path(data["manytype_sync_capture_path"])
    validate_manytype_sync_artifact(sync_path, "phase36 type/relation (official-authored) sync")

    return "phase36 type/relation (official-authored) ok"


def validate_fields_roundtrip(path: pathlib.Path) -> str:
    data = load_path(path)
    required = {
        "captured_at",
        "scenario",
        "space_id",
        "object_id",
        "checkbox_created",
        "bool_relation_set",
        "date_relation_set",
        "date_value",
        "official_confirmed",
        "manytype_sync_capture_path",
        "success",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"phase36 fields roundtrip missing keys: {missing}")

    if not data.get("checkbox_created"):
        raise SystemExit("phase36 fields roundtrip checkbox_created is falsy")

    if not data.get("bool_relation_set"):
        raise SystemExit("phase36 fields roundtrip bool_relation_set is falsy")

    if not data.get("date_relation_set"):
        raise SystemExit("phase36 fields roundtrip date_relation_set is falsy")

    date_value = data.get("date_value")
    if not isinstance(date_value, int):
        raise SystemExit(f"phase36 fields roundtrip date_value={date_value!r} is not an integer")

    if not data.get("success"):
        raise SystemExit("phase36 fields roundtrip success is false")

    sync_path = pathlib.Path(data["manytype_sync_capture_path"])
    validate_manytype_sync_artifact(sync_path, "phase36 fields roundtrip sync")

    return "phase36 fields roundtrip ok"


def validate_listing_type_filter(path: pathlib.Path) -> str:
    data = load_path(path)
    required = {
        "captured_at",
        "scenario",
        "space_id",
        "created_object_ids",
        "page_ids_in_list",
        "note_ids_absent",
        "manytype_sync_capture_path",
        "success",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"phase36 listing type-filter missing keys: {missing}")

    created_ids = data.get("created_object_ids", [])
    if not isinstance(created_ids, list) or not created_ids:
        raise SystemExit("phase36 listing type-filter created_object_ids is empty or not a list")

    if not data.get("page_ids_in_list"):
        raise SystemExit("phase36 listing type-filter page_ids_in_list is falsy")

    if not data.get("note_ids_absent"):
        raise SystemExit("phase36 listing type-filter note_ids_absent is falsy")

    if not data.get("success"):
        raise SystemExit("phase36 listing type-filter success is false")

    sync_path = pathlib.Path(data["manytype_sync_capture_path"])
    validate_manytype_sync_artifact(sync_path, "phase36 listing type-filter sync")

    return "phase36 listing type-filter ok"


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Offline validator for phase36 test_vectors artifacts."
    )
    parser.add_argument(
        "--deletion-manytype",
        default=str(TEST_VECTORS / "phase36-deletion-manytype-authored.json"),
        help="Path to the deletion (manytype-authored) artifact.",
    )
    parser.add_argument(
        "--deletion-official",
        default=str(TEST_VECTORS / "phase36-deletion-official-authored.json"),
        help="Path to the deletion (official-authored) artifact.",
    )
    parser.add_argument(
        "--type-manytype",
        default=str(TEST_VECTORS / "phase36-type-manytype-authored.json"),
        help="Path to the type/relation (manytype-authored) artifact.",
    )
    parser.add_argument(
        "--type-official",
        default=str(TEST_VECTORS / "phase36-type-official-authored.json"),
        help="Path to the type/relation (official-authored) artifact.",
    )
    parser.add_argument(
        "--fields",
        default=str(TEST_VECTORS / "phase36-fields-checkbox-roundtrip.json"),
        help="Path to the fields roundtrip artifact.",
    )
    parser.add_argument(
        "--listing",
        default=str(TEST_VECTORS / "phase36-listing-type-filter.json"),
        help="Path to the listing type-filter artifact.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    results = [
        validate_deletion_manytype_authored(pathlib.Path(args.deletion_manytype)),
        validate_deletion_official_authored(pathlib.Path(args.deletion_official)),
        validate_type_manytype_authored(pathlib.Path(args.type_manytype)),
        validate_type_official_authored(pathlib.Path(args.type_official)),
        validate_fields_roundtrip(pathlib.Path(args.fields)),
        validate_listing_type_filter(pathlib.Path(args.listing)),
    ]
    for result in results:
        print(result)
    print("phase36 artifacts: PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
