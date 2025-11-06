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


def has_ordered_subsequence(sequence: list[str], required: list[str]) -> bool:
    index = 0
    for method in required:
        try:
            index = sequence.index(method, index) + 1
        except ValueError:
            return False
    return True


def validate_oracle_roundtrip(path: pathlib.Path) -> str:
    data = load_path(path)
    events = data.get("events", [])
    methods = [event.get("method", "") for event in events if event.get("type") == "unary_rpc"]
    required = {
        "/coordinator.Coordinator/NetworkConfiguration",
        "/filesync.File/BlocksCheck",
        "/filesync.File/BlockPush",
        "/filesync.File/BlockGet",
    }
    missing = sorted(required - set(methods))
    if missing:
        raise SystemExit(f"oracle roundtrip artifact missing methods: {missing}")
    if methods.count("/filesync.File/BlockGet") != 1:
        raise SystemExit("oracle roundtrip artifact must contain exactly one BlockGet")
    event_types = {event.get("type", "") for event in events}
    for required_type in {"cache_hit", "cache_miss", "wrote_output"}:
        if required_type not in event_types:
            raise SystemExit(f"oracle roundtrip artifact missing event type: {required_type}")
    return f"oracle roundtrip ok ({len(events)} events)"


def validate_oracle_probe(path: pathlib.Path) -> str:
    data = load_path(path)
    events = data.get("events", [])
    methods = {
        (event.get("method") or "")
        for event in events
        if event.get("type") in {"unary_rpc", "rpc_error"}
    }
    required = {
        "/coordinator.Coordinator/NetworkConfiguration",
        "/filesync.File/Check",
        "/filesync.File/BlocksCheck",
        "/filesync.File/BlockGet",
        "/filesync.File/BlockPush",
    }
    missing = sorted(required - methods)
    if missing:
        raise SystemExit(f"oracle file probe artifact missing methods: {missing}")
    return f"oracle file probe ok ({len(events)} events)"


def validate_live_probe(path: pathlib.Path) -> str:
    data = load_path(path)
    if data.get("read_only") is not True:
        raise SystemExit("live file probe artifact must be marked read_only")
    events = data.get("events", [])
    methods = {
        (event.get("method") or "")
        for event in events
        if event.get("type") in {"unary_rpc", "rpc_error"}
    }
    required = {
        "/coordinator.Coordinator/NetworkConfiguration",
        "/filesync.File/Check",
        "/filesync.File/BlocksCheck",
        "/filesync.File/BlockGet",
    }
    missing = sorted(required - methods)
    if missing:
        raise SystemExit(f"live file probe artifact missing methods: {missing}")
    if "/filesync.File/BlockPush" in methods:
        raise SystemExit("live file probe artifact must not contain BlockPush")
    return f"live file probe ok ({len(events)} events)"


def validate_official_api(path: pathlib.Path) -> str:
    data = load_path(path)
    required_keys = {
        "captured_at",
        "server_peer_id",
        "api_probe_success",
        "initial_space_count",
        "restart_space_count",
        "gateway_urls",
        "automation_status",
        "limitation",
        "required_markers",
        "observed_markers",
        "harness_exit_code",
        "file_methods_observed",
    }
    missing = sorted(required_keys - data.keys())
    if missing:
        raise SystemExit(f"official client artifact missing keys: {missing}")
    if data["harness_exit_code"] != 0:
        raise SystemExit(f"official client harness_exit_code={data['harness_exit_code']}")
    if not data["api_probe_success"]:
        raise SystemExit("official client artifact api_probe_success is false")
    missing_markers = sorted(set(data["required_markers"]) - set(data["observed_markers"]))
    if missing_markers:
        raise SystemExit(f"official client artifact missing markers: {missing_markers}")
    if data["restart_space_count"] < 1:
        raise SystemExit("official client artifact restart_space_count must be >= 1")
    if data["automation_status"] not in {"api_only", "api_plus_file_activity", "full_file_roundtrip"}:
        raise SystemExit(f"official client artifact has unknown automation_status={data['automation_status']}")
    if data.get("fatal_error_lines"):
        raise SystemExit(f"official client artifact has fatal server errors: {data['fatal_error_lines']}")
    if data["automation_status"] == "full_file_roundtrip":
        full_roundtrip_keys = {
            "roundtrip_success",
            "roundtrip_object_id",
            "payload_sha256",
            "downloaded_sha256",
            "byte_match",
            "file_method_sequence",
            "required_file_method_sequence",
            "roundtrip_method_order_ok",
        }
        missing_roundtrip = sorted(full_roundtrip_keys - data.keys())
        if missing_roundtrip:
            raise SystemExit(
                f"official client full roundtrip artifact missing keys: {missing_roundtrip}"
            )
        if not data["roundtrip_success"]:
            raise SystemExit("official client full roundtrip artifact roundtrip_success is false")
        if not data["byte_match"]:
            raise SystemExit("official client full roundtrip artifact byte_match is false")
        if data["downloaded_sha256"] != data["payload_sha256"]:
            raise SystemExit("official client full roundtrip artifact sha256 mismatch")
        required_methods = data["required_file_method_sequence"]
        methods = set(data.get("file_methods_observed", []))
        missing_methods = [method for method in required_methods if method not in methods]
        if missing_methods:
            raise SystemExit(
                f"official client full roundtrip artifact missing file methods: {missing_methods}"
            )
        if not data["roundtrip_method_order_ok"]:
            raise SystemExit("official client full roundtrip artifact roundtrip_method_order_ok is false")
        if not has_ordered_subsequence(data["file_method_sequence"], required_methods):
            raise SystemExit(
                "official client full roundtrip artifact missing required file method ordering"
            )
    return f"official client api ok ({data['automation_status']})"


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--oracle-roundtrip",
        default=str(TEST_VECTORS / "file-roundtrip-artifact.json"),
    )
    parser.add_argument(
        "--oracle-probe",
        default=str(TEST_VECTORS / "file-node-probe-artifact.json"),
    )
    parser.add_argument(
        "--live-probe",
        default=str(TEST_VECTORS / "live-file-node-probe-artifact.json"),
    )
    parser.add_argument(
        "--official-api",
        default=str(TEST_VECTORS / "phase25-official-client-api.json"),
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    results = [
      validate_oracle_roundtrip(pathlib.Path(args.oracle_roundtrip)),
      validate_oracle_probe(pathlib.Path(args.oracle_probe)),
      validate_live_probe(pathlib.Path(args.live_probe)),
      validate_official_api(pathlib.Path(args.official_api)),
    ]
    for result in results:
        print(result)
    print("file artifacts: PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
