#!/usr/bin/env python3

import argparse
import json
import pathlib
import re
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
TEST_VECTORS = ROOT / "test_vectors"


def load(name: str) -> dict:
    return load_path(TEST_VECTORS / name)


def load_path(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def validate_phase11() -> str:
    data = load("phase11-netcheck-artifact.json")
    required = {
        "captured_at",
        "server_addr",
        "server_peer_id",
        "command",
        "netcheck_success",
        "netcheck_output",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"phase11 artifact missing keys: {missing}")
    if not data["server_peer_id"].startswith("12D3KooW"):
        raise SystemExit("phase11 artifact peer ID is not libp2p-encoded")
    if not data["netcheck_success"]:
        raise SystemExit("phase11 artifact netcheck_success is false")
    if re.search(r"netcheck\s+success", data["netcheck_output"]) is None:
        raise SystemExit("phase11 artifact does not contain netcheck success output")
    return f"phase11 ok ({data['server_addr']})"


def validate_phase12_artifact(path: pathlib.Path) -> str:
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
        raise SystemExit(f"phase12 artifact missing keys: {missing_keys}")

    events = data.get("events", [])
    methods = [event.get("method", "") for event in events if event.get("type") == "unary_rpc"]
    method_set = set(methods)
    required_methods = {
        "/coordinator.Coordinator/NetworkConfiguration",
        "/coordinator.Coordinator/SpaceStatusCheck",
        "/coordinator.Coordinator/SpaceSign",
        "/spacesync.SpaceSync/SpacePush",
        "/spacesync.SpaceSync/HeadSync",
        "/spacesync.SpaceSync/StoreDiff",
    }
    missing = sorted(required_methods - method_set)
    if missing:
        raise SystemExit(f"phase12 artifact missing methods: {missing}")

    def index(method: str) -> int:
        try:
            return methods.index(method)
        except ValueError:
            return -1

    network_index = index("/coordinator.Coordinator/NetworkConfiguration")
    status_index = index("/coordinator.Coordinator/SpaceStatusCheck")
    sign_index = index("/coordinator.Coordinator/SpaceSign")
    push_index = index("/spacesync.SpaceSync/SpacePush")
    headsync_index = index("/spacesync.SpaceSync/HeadSync")
    storediff_index = index("/spacesync.SpaceSync/StoreDiff")

    if not (
        network_index >= 0
        and status_index > network_index
        and sign_index > status_index
        and push_index > sign_index
    ):
        raise SystemExit(
            "phase12 artifact has invalid RPC ordering; expected "
            "NetworkConfiguration -> SpaceStatusCheck -> SpaceSign -> SpacePush"
        )
    if headsync_index <= push_index:
        raise SystemExit("phase12 artifact must run HeadSync after SpacePush")
    if storediff_index <= headsync_index:
        raise SystemExit("phase12 artifact must run StoreDiff after HeadSync")

    if not any(event.get("type") == "sync-complete" for event in events):
        raise SystemExit("phase12 artifact missing sync-complete event")
    if not any(
        event.get("type") in {"stream_rpc", "official-object-sync-skipped"} for event in events
    ):
        raise SystemExit("phase12 artifact missing store/object follow-up evidence")
    return f"phase12 ok ({path.name}, {len(events)} events)"


def validate_phase12() -> str:
    return validate_phase12_artifact(TEST_VECTORS / "oracle-capture-artifact.json")


def validate_phase13() -> str:
    data = load("phase13-official-client-bootstrap.json")
    required = {
        "captured_at",
        "harness_script",
        "server_peer_id",
        "harness_exit_code",
        "required_markers",
        "observed_markers",
        "error_lines",
        "success",
        "server_log_excerpt",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"phase13 artifact missing keys: {missing}")
    if not data["server_peer_id"].startswith("12D3KooW"):
        raise SystemExit("phase13 artifact peer ID is not libp2p-encoded")
    if data["harness_exit_code"] != 0:
        raise SystemExit(f"phase13 harness_exit_code={data['harness_exit_code']}")
    missing_markers = sorted(set(data["required_markers"]) - set(data["observed_markers"]))
    if missing_markers:
        raise SystemExit(f"phase13 artifact missing markers: {missing_markers}")
    if data["error_lines"]:
        raise SystemExit(f"phase13 artifact recorded server errors: {data['error_lines']}")
    if not data["success"]:
        raise SystemExit("phase13 artifact success is false")
    return f"phase13 ok ({len(data['observed_markers'])} markers)"


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--phase12-artifact",
        default=str(TEST_VECTORS / "oracle-capture-artifact.json"),
        help="Path to the canonical Phase 12 artifact to validate.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    results = [
        validate_phase11(),
        validate_phase12_artifact(pathlib.Path(args.phase12_artifact)),
        validate_phase13(),
    ]
    for result in results:
        print(result)
    print("nyquist artifacts: PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
