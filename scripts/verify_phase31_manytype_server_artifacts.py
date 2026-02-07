#!/usr/bin/env python3

import argparse
import json
import pathlib
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
TEST_VECTORS = ROOT / "test_vectors"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def validate_sync_capture(
    path: pathlib.Path,
    label: str,
    *,
    require_space_push: bool,
) -> str:
    data = load_json(path)
    required = {
        "captured_at",
        "coordinator_address",
        "events",
        "network_config_path",
        "official_interop_mode",
        "space_id",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"{label} missing keys: {missing}")

    if data.get("official_interop_mode") is not True:
        raise SystemExit(f"{label} official_interop_mode is not true")

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
        "/spacesync.SpaceSync/HeadSync",
    }
    if require_space_push:
        required_methods.add("/spacesync.SpaceSync/SpacePush")
    missing_methods = sorted(required_methods - methods)
    if missing_methods:
        raise SystemExit(f"{label} missing required RPC methods: {missing_methods}")

    if not any("ObjectSync" in method for method in methods):
        raise SystemExit(f"{label} missing ObjectSync evidence")

    return f"{label} ok ({len(events)} events)"


def validate_official_show(
    path: pathlib.Path,
    *,
    expected_object_id: str,
    expected_text: str,
) -> str:
    data = load_json(path)
    required = {"action", "block_id", "object_id", "text"}
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"official show artifact missing keys: {missing}")

    if data.get("action") != "object-show-text":
        raise SystemExit("official show artifact action is not object-show-text")

    if data.get("object_id") != expected_object_id:
        raise SystemExit(
            f"official show artifact object_id={data.get('object_id')!r} "
            f"expected {expected_object_id!r}"
        )

    if data.get("text") != expected_text:
        raise SystemExit(
            f"official show artifact text={data.get('text')!r} "
            f"expected {expected_text!r}"
        )

    if not data.get("block_id"):
        raise SystemExit("official show artifact missing block_id")

    return f"official show ok (block {data['block_id']})"


def validate_join_artifact(path: pathlib.Path) -> str:
    if not path.exists():
        return f"official join skipped (missing {path.name})"
    data = load_json(path)
    if data.get("action") != "space-join":
        raise SystemExit("official join artifact action is not space-join")
    if data.get("error_code"):
        raise SystemExit(
            f"official join artifact recorded error_code={data['error_code']!r}"
        )
    if not data.get("space_id"):
        raise SystemExit("official join artifact missing space_id")
    return "official join ok"


def validate_top_level(path: pathlib.Path) -> tuple[dict, list[str]]:
    data = load_json(path)
    required = {
        "captured_at",
        "scenario",
        "space_id",
        "object_id",
        "updated_text",
        "official_observed_text",
        "manytype_seed_sync_capture_path",
        "manytype_edit_sync_capture_path",
        "official_probe",
        "success",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"top-level phase31 manytype_server artifact missing keys: {missing}")

    if data.get("success") is not True:
        raise SystemExit("top-level phase31 manytype_server artifact success is not true")

    updated_text = data.get("updated_text", "")
    observed_text = data.get("official_observed_text", "")
    if not updated_text or observed_text != updated_text:
        raise SystemExit(
            f"official observed text {observed_text!r} does not match updated text {updated_text!r}"
        )

    official_probe = data.get("official_probe")
    if not isinstance(official_probe, dict):
        raise SystemExit("top-level phase31 manytype_server artifact official_probe is not an object")

    if "show_result_path" not in official_probe:
        raise SystemExit("top-level phase31 manytype_server artifact missing official_probe.show_result_path")

    results = [
        f"top-level artifact ok ({data['object_id']})",
    ]
    return data, results


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate the Phase 45 manytype_server cross-authored artifact bundle.",
    )
    parser.add_argument(
        "--artifact",
        default=str(TEST_VECTORS / "phase31-cross-authored-manytype-server.json"),
        help="Top-level artifact path.",
    )
    parser.add_argument(
        "--official-show",
        default=None,
        help="Official object-show-text JSON path. Defaults to artifact metadata.",
    )
    parser.add_argument(
        "--official-join",
        default=str(TEST_VECTORS / "phase31-cross-authored-manytype-server-official-join.json"),
        help="Official space-join JSON path.",
    )
    parser.add_argument(
        "--manytype-seed",
        default=None,
        help="Manytype seed sync capture path. Defaults to artifact metadata.",
    )
    parser.add_argument(
        "--manytype-edit",
        default=None,
        help="Manytype edit sync capture path. Defaults to artifact metadata.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    artifact_path = pathlib.Path(args.artifact)
    artifact, results = validate_top_level(artifact_path)

    official_show_path = pathlib.Path(
        args.official_show or artifact["official_probe"]["show_result_path"]
    )
    manytype_seed_path = pathlib.Path(
        args.manytype_seed or artifact["manytype_seed_sync_capture_path"]
    )
    manytype_edit_path = pathlib.Path(
        args.manytype_edit or artifact["manytype_edit_sync_capture_path"]
    )
    official_join_path = pathlib.Path(args.official_join)

    results.append(
        validate_official_show(
            official_show_path,
            expected_object_id=artifact["object_id"],
            expected_text=artifact["updated_text"],
        )
    )
    results.append(validate_join_artifact(official_join_path))
    results.append(
        validate_sync_capture(
            manytype_seed_path,
            "manytype seed sync",
            require_space_push=True,
        )
    )
    results.append(
        validate_sync_capture(
            manytype_edit_path,
            "manytype edit sync",
            require_space_push=False,
        )
    )

    for result in results:
        print(result)
    print("phase31 manytype_server artifacts: PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
