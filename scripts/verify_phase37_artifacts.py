#!/usr/bin/env python3

"""Offline validator for phase37 BlockUpdate test_vectors artifacts."""

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


def _validate_blockupdate_common(
    path: pathlib.Path,
    expected_field: str,
    label: str,
) -> dict:
    data = load_path(path)
    required = {
        "captured_at",
        "scenario",
        "object_id",
        "block_id",
        "mutation",
        "expected_block_update_variant",
        "expected_field",
        "expected_value",
        "post_mutation_block_id_unchanged",
        "roundtrip_observed",
        "manytype_sync_capture_path",
        "success",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"{label} missing keys: {missing}")

    if data.get("expected_block_update_variant") != "blockSetText":
        raise SystemExit(
            f"{label} expected_block_update_variant={data.get('expected_block_update_variant')!r}, "
            "expected 'blockSetText'"
        )

    if data.get("expected_field") != expected_field:
        raise SystemExit(
            f"{label} expected_field={data.get('expected_field')!r}, "
            f"expected {expected_field!r}"
        )

    if not data.get("post_mutation_block_id_unchanged"):
        raise SystemExit(f"{label} post_mutation_block_id_unchanged is falsy")

    if not data.get("roundtrip_observed"):
        raise SystemExit(f"{label} roundtrip_observed is falsy")

    if data.get("success") is not True:
        raise SystemExit(f"{label} success is not True")

    sync_capture_path = data.get("manytype_sync_capture_path", "")
    if not sync_capture_path:
        raise SystemExit(f"{label} manytype_sync_capture_path is empty")
    validate_manytype_sync_artifact(pathlib.Path(sync_capture_path), f"{label} sync")

    return data


def validate_blockupdate_checked(path: pathlib.Path) -> str:
    data = _validate_blockupdate_common(
        path, "checked", "phase37 blockupdate checkbox"
    )
    if data.get("expected_value") is not True:
        raise SystemExit(
            f"phase37 blockupdate checkbox expected_value={data.get('expected_value')!r}, "
            "expected True"
        )
    return f"phase37 blockupdate checkbox ok ({data['object_id']})"


def validate_blockupdate_text(path: pathlib.Path) -> str:
    data = _validate_blockupdate_common(
        path, "text", "phase37 blockupdate text"
    )
    expected_value = data.get("expected_value")
    if not isinstance(expected_value, str) or not expected_value:
        raise SystemExit(
            "phase37 blockupdate text expected_value must be a non-empty string"
        )
    return f"phase37 blockupdate text ok ({data['object_id']})"


def validate_blockupdate_style(path: pathlib.Path) -> str:
    data = _validate_blockupdate_common(
        path, "style", "phase37 blockupdate style"
    )
    expected_value = data.get("expected_value")
    if not isinstance(expected_value, str) or not expected_value:
        raise SystemExit(
            "phase37 blockupdate style expected_value must be a non-empty string"
        )
    return f"phase37 blockupdate style ok ({data['object_id']})"


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Offline validator for phase37 BlockUpdate test_vectors artifacts."
    )
    parser.add_argument(
        "--checkbox",
        default=str(TEST_VECTORS / "phase37-blockupdate-checkbox.json"),
        help="Path to the checkbox mutation artifact.",
    )
    parser.add_argument(
        "--text",
        default=str(TEST_VECTORS / "phase37-blockupdate-text.json"),
        help="Path to the text rewrite artifact.",
    )
    parser.add_argument(
        "--style",
        default=str(TEST_VECTORS / "phase37-blockupdate-style.json"),
        help="Path to the style change artifact.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    results = [
        validate_blockupdate_checked(pathlib.Path(args.checkbox)),
        validate_blockupdate_text(pathlib.Path(args.text)),
        validate_blockupdate_style(pathlib.Path(args.style)),
    ]
    for result in results:
        print(result)
    print("phase37 artifacts: PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
