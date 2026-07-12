#!/usr/bin/env python3

import json
import pathlib
import sys


def read_peer_id(log_path: pathlib.Path) -> str:
    for line in log_path.read_text().splitlines():
        try:
            record = json.loads(line)
        except json.JSONDecodeError:
            continue

        fields = record.get("fields")
        if not isinstance(fields, dict) or fields.get("event") != "server_ready":
            continue

        peer_id = fields.get("peer_id")
        if isinstance(peer_id, str) and peer_id:
            return peer_id

    raise ValueError("no structured server_ready event with a peer_id")


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {pathlib.Path(sys.argv[0]).name} SERVER_LOG", file=sys.stderr)
        return 2

    try:
        peer_id = read_peer_id(pathlib.Path(sys.argv[1]))
    except (OSError, ValueError) as error:
        print(error, file=sys.stderr)
        return 1

    print(peer_id)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
