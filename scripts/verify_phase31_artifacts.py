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


def validate_official_roundtrip(path: pathlib.Path) -> str:
    data = load_path(path)
    required = {
        "captured_at",
        "harness_script",
        "server_peer_id",
        "harness_exit_code",
        "object_id",
        "required_markers",
        "observed_markers",
        "error_lines",
        "success",
        "server_log_excerpt",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"phase31 official artifact missing keys: {missing}")

    peer_id = data.get("server_peer_id", "")
    if not isinstance(peer_id, str) or not peer_id.startswith("12D3KooW"):
        raise SystemExit("phase31 official artifact peer ID is not libp2p-encoded")

    if data.get("harness_exit_code") != 0:
        raise SystemExit(f"phase31 official harness_exit_code={data['harness_exit_code']}")

    required_markers = set(data.get("required_markers", []))
    observed_markers = set(data.get("observed_markers", []))
    missing_markers = sorted(required_markers - observed_markers)
    if missing_markers:
        raise SystemExit(f"phase31 official artifact missing markers: {missing_markers}")

    if data.get("error_lines"):
        raise SystemExit(f"phase31 official artifact recorded server errors: {data['error_lines']}")

    if not data.get("object_id"):
        raise SystemExit("phase31 official artifact missing object_id")

    if not data.get("success"):
        raise SystemExit("phase31 official artifact success is false")

    return f"phase31 official ok ({len(observed_markers)} markers)"


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


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--official",
        default=str(TEST_VECTORS / "phase31-official-note-roundtrip.json"),
        help="Path to the official-client roundtrip artifact to validate.",
    )
    parser.add_argument(
        "--manytype-create",
        default=str(TEST_VECTORS / "phase31-manytype-cli-create.json"),
        help="Path to the Manytype CLI create+sync artifact to validate.",
    )
    parser.add_argument(
        "--manytype-edit",
        default=str(TEST_VECTORS / "phase31-manytype-cli-edit.json"),
        help="Path to the Manytype CLI edit+sync artifact to validate.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    results = [
        validate_official_roundtrip(pathlib.Path(args.official)),
        validate_manytype_sync_artifact(pathlib.Path(args.manytype_create), "phase31 manytype create"),
        validate_manytype_sync_artifact(pathlib.Path(args.manytype_edit), "phase31 manytype edit"),
    ]
    for result in results:
        print(result)
    print("phase31 artifacts: PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())

