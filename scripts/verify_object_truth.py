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

def validate_object_truth(path: pathlib.Path) -> str:
    data = load_path(path)
    events = data.get("events", [])
    
    methods_observed = []
    for event in events:
        if "method" in event:
            methods_observed.append(event["method"])
            
    required_sequence = [
        "/coordinator.Coordinator/NetworkConfiguration",
        "/coordinator.Coordinator/SpaceStatusCheck",
        "/coordinator.Coordinator/SpaceSign",
        "/spacesync.SpaceSync/SpacePush",
        "/spacesync.SpaceSync/HeadSync",
    ]
    
    index = 0
    for req in required_sequence:
        try:
            index = methods_observed.index(req, index) + 1
        except ValueError:
            raise SystemExit(f"Missing or out-of-order required RPC: {req}")

    if "/spacesync.SpaceSync/ObjectSyncStream" not in methods_observed and "/spacesync.SpaceSync/ObjectSync" not in methods_observed:
        raise SystemExit("Missing required RPC: ObjectSyncStream or ObjectSync")
        
    return f"object truth artifact ok ({len(events)} events, {len(methods_observed)} RPCs)"

def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "artifact",
        nargs="?",
        default=str(TEST_VECTORS / "phase27-object-truth.json"),
        help="Path to the object truth artifact JSON",
    )
    return parser.parse_args(argv)

def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    try:
        result = validate_object_truth(pathlib.Path(args.artifact))
        print(result)
        print("verify_object_truth: PASSED")
        return 0
    except SystemExit as e:
        print(f"verify_object_truth: FAILED - {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
