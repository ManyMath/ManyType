#!/usr/bin/env python3

import argparse
import ast
import json
import pathlib
import re
import sqlite3
import sys
from typing import Any


ROOT = pathlib.Path(__file__).resolve().parents[1]
TEST_VECTORS = ROOT / "test_vectors"

STORE_ROOT_RE = re.compile(
    r"store_change root id=(?P<id>\S+) space_id=(?P<space_id>\S+) "
    r"object_id=(?P<object_id>\S+) change_type=(?P<change_type>\S+) "
    r"payload_len=(?P<payload_len>\d+)"
)
STORE_TREE_RE = re.compile(
    r"store_change tree id=(?P<id>\S+) space_id=(?P<space_id>\S+) "
    r"object_id=(?P<object_id>\S+) tree_head_ids=(?P<parents>\[[^\]]*\]) "
    r"snapshot=(?P<snapshot>true|false) read_key_id=(?P<read_key_id>\S+) "
    r"snapshot_base_id=(?P<snapshot_base_id>\S*) changes_data_len=(?P<changes_data_len>\d+)"
)
FULL_SYNC_REQUEST_RE = re.compile(
    r"full sync request \([^)]+\) for (?P<space_id>\S+)/(?P<object_id>\S+) "
    r"heads=(?P<heads>\[[^\]]*\]) snapshot_path=(?P<snapshot_path>\[[^\]]*\]) "
    r"change_ids=(?P<change_ids>\[[^\]]*\])(?: has_root_change=(?P<has_root_change>true|false))?"
)
FULL_SYNC_RESPONSE_RE = re.compile(
    r"full sync response (?P<space_id>\S+)/(?P<object_id>\S+) root_id=(?P<root_id>\S+) "
    r"heads=(?P<heads>\[[^\]]*\]) change_ids=(?P<change_ids>\[[^\]]*\]) "
    r"snapshot_path=(?P<snapshot_path>\[[^\]]*\])"
)


def load_json(path: pathlib.Path) -> dict:
    with path.open() as f:
        return json.load(f)


def parse_list(text: str) -> list[str]:
    try:
        value = ast.literal_eval(text)
    except (SyntaxError, ValueError):
        return []
    if isinstance(value, list):
        return [str(item) for item in value]
    return []


def decode_blob_id(value: bytes | str) -> str:
    if isinstance(value, str):
        return value
    if len(value) >= 2 and value[0] == 0x03 and value[-1] == 0x00:
        return value[1:-1].decode()
    return value.decode(errors="ignore")


def extract_string_field(data: bytes, key: str) -> str | None:
    marker = key.encode() + b"\x00\x03"
    idx = data.find(marker)
    if idx < 0:
        return None
    start = idx + len(marker)
    end = data.find(b"\x00", start)
    if end < 0:
        return None
    return data[start:end].decode(errors="ignore")


def read_official_object_doc(
    anytype_root: pathlib.Path,
    object_id: str,
) -> dict[str, Any] | None:
    try:
        account_dirs = [p for p in anytype_root.iterdir() if p.is_dir()]
    except PermissionError as exc:
        return {"error": f"permission denied listing {anytype_root}: {exc}"}
    for account_dir in account_dirs:
        objectstore = account_dir / "objectstore"
        try:
            exists = objectstore.exists()
        except PermissionError as exc:
            return {"error": f"permission denied reading {objectstore}: {exc}"}
        if not exists:
            continue
        try:
            db_paths = list(objectstore.glob("*/objects.db"))
        except PermissionError as exc:
            return {"error": f"permission denied reading {objectstore}: {exc}"}
        for db_path in db_paths:
            con = sqlite3.connect(db_path)
            try:
                objects_rows = con.execute("SELECT id, data FROM _objects_docs").fetchall()
                heads_rows = con.execute("SELECT id, data FROM _headsState_docs").fetchall()
            finally:
                con.close()

            object_row = next(
                (
                    data
                    for raw_id, data in objects_rows
                    if decode_blob_id(raw_id) == object_id
                ),
                None,
            )
            heads_row = next(
                (
                    data
                    for raw_id, data in heads_rows
                    if decode_blob_id(raw_id) == object_id
                ),
                None,
            )
            if object_row is None and heads_row is None:
                continue

            return {
                "db_path": str(db_path),
                "name": extract_string_field(object_row, "name")
                if object_row is not None
                else None,
                "space_id": extract_string_field(object_row, "spaceId")
                if object_row is not None
                else None,
                "heads_hash": extract_string_field(heads_row, "h")
                if heads_row is not None
                else None,
            }
    return None


def parse_server_log(server_log: pathlib.Path, object_id: str) -> dict[str, Any]:
    stored_changes: list[dict[str, Any]] = []
    requests: list[dict[str, Any]] = []
    responses: list[dict[str, Any]] = []

    for line_no, raw_line in enumerate(server_log.read_text().splitlines(), start=1):
        if object_id not in raw_line:
            continue

        root_match = STORE_ROOT_RE.search(raw_line)
        if root_match and root_match.group("object_id") == object_id:
            stored_changes.append(
                {
                    "kind": "root",
                    "line": line_no,
                    "id": root_match.group("id"),
                    "space_id": root_match.group("space_id"),
                    "parents": [],
                    "snapshot": False,
                    "snapshot_base_id": None,
                    "payload_len": int(root_match.group("payload_len")),
                    "raw": raw_line,
                }
            )
            continue

        tree_match = STORE_TREE_RE.search(raw_line)
        if tree_match and tree_match.group("object_id") == object_id:
            stored_changes.append(
                {
                    "kind": "tree",
                    "line": line_no,
                    "id": tree_match.group("id"),
                    "space_id": tree_match.group("space_id"),
                    "parents": parse_list(tree_match.group("parents")),
                    "snapshot": tree_match.group("snapshot") == "true",
                    "snapshot_base_id": tree_match.group("snapshot_base_id") or None,
                    "read_key_id": tree_match.group("read_key_id") or None,
                    "changes_data_len": int(tree_match.group("changes_data_len")),
                    "raw": raw_line,
                }
            )
            continue

        request_match = FULL_SYNC_REQUEST_RE.search(raw_line)
        if request_match and request_match.group("object_id") == object_id:
            requests.append(
                {
                    "line": line_no,
                    "space_id": request_match.group("space_id"),
                    "heads": parse_list(request_match.group("heads")),
                    "snapshot_path": parse_list(request_match.group("snapshot_path")),
                    "change_ids": parse_list(request_match.group("change_ids")),
                    "has_root_change": request_match.group("has_root_change") == "true",
                    "raw": raw_line,
                }
            )
            continue

        response_match = FULL_SYNC_RESPONSE_RE.search(raw_line)
        if response_match and response_match.group("object_id") == object_id:
            responses.append(
                {
                    "line": line_no,
                    "space_id": response_match.group("space_id"),
                    "root_id": response_match.group("root_id"),
                    "heads": parse_list(response_match.group("heads")),
                    "change_ids": parse_list(response_match.group("change_ids")),
                    "snapshot_path": parse_list(response_match.group("snapshot_path")),
                    "raw": raw_line,
                }
            )

    return {
        "stored_changes": stored_changes,
        "full_sync_requests": requests,
        "full_sync_responses": responses,
    }


def build_summary(
    *,
    tempdir: pathlib.Path,
    object_id: str,
    artifact_path: pathlib.Path | None,
    official_show_path: pathlib.Path | None,
) -> dict[str, Any]:
    server_log = tempdir / "server.log"
    if not server_log.exists():
        raise SystemExit(f"missing server log: {server_log}")

    parsed = parse_server_log(server_log, object_id)
    anytype_root = tempdir / "anytype-root"
    official_index = read_official_object_doc(anytype_root, object_id) if anytype_root.exists() else None

    artifact = load_json(artifact_path) if artifact_path and artifact_path.exists() else None
    official_show = (
        load_json(official_show_path)
        if official_show_path and official_show_path.exists()
        else None
    )

    return {
        "tempdir": str(tempdir),
        "object_id": object_id,
        "artifact": artifact,
        "official_show": official_show,
        "official_index": official_index,
        **parsed,
    }


def render_text(summary: dict[str, Any]) -> str:
    lines = [
        f"tempdir: {summary['tempdir']}",
        f"object_id: {summary['object_id']}",
    ]

    artifact = summary.get("artifact")
    if artifact:
        lines.append(
            f"artifact: updated_text={artifact.get('updated_text')} "
            f"official_observed_text={artifact.get('official_observed_text')} "
            f"success={artifact.get('success')}"
        )

    official_show = summary.get("official_show")
    if official_show:
        lines.append(
            f"official_show: block_id={official_show.get('block_id')} "
            f"text={official_show.get('text')!r}"
        )

    official_index = summary.get("official_index")
    if official_index:
        if official_index.get("error"):
            lines.append(f"official_index: {official_index['error']}")
        else:
            lines.append(
                f"official_index: name={official_index.get('name')!r} "
                f"heads_hash={official_index.get('heads_hash')} "
                f"space_id={official_index.get('space_id')}"
            )

    lines.append("stored_changes:")
    for change in summary["stored_changes"]:
        if change["kind"] == "root":
            lines.append(
                f"  - root {change['id']} payload_len={change['payload_len']} "
                f"(line {change['line']})"
            )
        else:
            lines.append(
                f"  - tree {change['id']} parents={change['parents']} "
                f"snapshot={change['snapshot']} "
                f"snapshot_base_id={change['snapshot_base_id']} "
                f"changes_data_len={change['changes_data_len']} "
                f"(line {change['line']})"
            )

    lines.append("full_sync_requests:")
    for req in summary["full_sync_requests"]:
        lines.append(
            f"  - heads={req['heads']} snapshot_path={req['snapshot_path']} "
            f"change_ids={req['change_ids']} has_root_change={req['has_root_change']} "
            f"(line {req['line']})"
        )

    lines.append("full_sync_responses:")
    for rsp in summary["full_sync_responses"]:
        lines.append(
            f"  - root_id={rsp['root_id']} heads={rsp['heads']} "
            f"change_ids={rsp['change_ids']} snapshot_path={rsp['snapshot_path']} "
            f"(line {rsp['line']})"
        )

    return "\n".join(lines)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Summarize a preserved manytype_server Phase 45 tempdir in terms of "
            "stored changes, full-sync shapes, and official client indexed state."
        )
    )
    parser.add_argument(
        "--tempdir",
        required=True,
        help="Preserved tempdir from KEEP_TMPDIR=1 harness output.",
    )
    parser.add_argument(
        "--object-id",
        default=None,
        help="Target object ID. Defaults to the object_id in --artifact when available.",
    )
    parser.add_argument(
        "--artifact",
        default=str(TEST_VECTORS / "phase31-cross-authored-manytype-server.json"),
        help="Optional top-level artifact JSON path.",
    )
    parser.add_argument(
        "--official-show",
        default=str(TEST_VECTORS / "phase31-cross-authored-manytype-server-official-show.json"),
        help="Optional official object-show-text JSON path.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit machine-readable JSON instead of text.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    tempdir = pathlib.Path(args.tempdir)
    artifact_path = pathlib.Path(args.artifact) if args.artifact else None
    official_show_path = pathlib.Path(args.official_show) if args.official_show else None

    artifact = (
        load_json(artifact_path)
        if artifact_path and artifact_path.exists()
        else None
    )
    object_id = args.object_id or (artifact or {}).get("object_id")
    if not object_id:
        raise SystemExit("--object-id is required when --artifact is absent or lacks object_id")

    summary = build_summary(
        tempdir=tempdir,
        object_id=object_id,
        artifact_path=artifact_path,
        official_show_path=official_show_path,
    )

    if args.json:
        print(json.dumps(summary, indent=2))
    else:
        print(render_text(summary))
    return 0


if __name__ == "__main__":
    sys.exit(main())
