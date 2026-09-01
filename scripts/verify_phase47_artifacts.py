#!/usr/bin/env python3

"""Offline validator for the Phase 47 object deletion artifact bundle."""

from __future__ import annotations

import argparse
import json
import pathlib
import re

from artifact_paths import repo_path


ROOT = pathlib.Path(__file__).resolve().parents[1]
ARTIFACT_DIR = ROOT / "test_vectors" / "phase47"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    with path.open() as f:
        return json.load(f)


def read_text(path: pathlib.Path) -> str:
    if not path.exists():
        raise SystemExit(f"missing text artifact: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


def extract_manytype_list_rows(text: str) -> str:
    rows = [
        line
        for line in text.splitlines()
        if re.match(r"^bafy[a-z0-9]+\s{2,}\S+\s{2,}.+", line)
    ]
    return "\n".join(rows)


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def validate_manytype_sync_artifact(path: pathlib.Path, label: str) -> str:
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "coordinator_address",
            "events",
            "network_config_path",
            "official_interop_mode",
            "space_id",
        },
        label,
    )

    events = data.get("events", [])
    if not isinstance(events, list) or not events:
        raise SystemExit(f"[{label}] has no events")

    methods = {
        event.get("method", "")
        for event in events
        if event.get("type") in {"unary_rpc", "stream_rpc"}
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
        raise SystemExit(f"[{label}] missing required RPC methods: {missing_methods}")

    if not any("ObjectSync" in method for method in methods):
        raise SystemExit(f"[{label}] missing ObjectSync RPC evidence")
    if not any(event.get("type") == "sync-complete" for event in events):
        raise SystemExit(f"[{label}] missing sync-complete event")

    return f"[{label}] ok"


def validate_runtime_metadata(path: pathlib.Path) -> str:
    label = "phase47 runtime metadata"
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "git",
            "oracle_lock",
            "official_cli",
            "docker_any_sync_env",
            "network_config",
            "binaries",
            "artifacts",
        },
        label,
    )
    if not data["official_cli"].get("repo_digest"):
        raise SystemExit(f"[{label}] official_cli.repo_digest is empty")
    if not data["network_config"].get("network_id"):
        raise SystemExit(f"[{label}] network_config.network_id is empty")
    if data["binaries"]["manytype_quic_ffi"].get("exists") is not True:
        raise SystemExit(f"[{label}] manytype_quic_ffi binary is missing")
    if data["binaries"]["official_client_probe"].get("exists") is not True:
        raise SystemExit(f"[{label}] official_client_probe binary is missing")
    return f"[{label}] ok"


def validate_official_search(
    path: pathlib.Path,
    object_id: str,
    object_name: str,
    expected_present: bool,
    label: str,
) -> str:
    data = load_json(path)
    require_keys(
        data,
        {"action", "space_id", "query", "record_count", "object_ids", "names", "records"},
        label,
    )
    if data.get("action") != "object-search":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    if data.get("query") != object_name:
        raise SystemExit(f"[{label}] unexpected query: {data.get('query')}")
    object_ids = data.get("object_ids", [])
    if not isinstance(object_ids, list):
        raise SystemExit(f"[{label}] object_ids is not a list")
    present = object_id in object_ids
    if present != expected_present:
        raise SystemExit(
            f"[{label}] expected present={expected_present} but saw present={present}"
        )
    return f"[{label}] ok"


def validate_official_delete(path: pathlib.Path, object_id: str) -> str:
    label = "phase47 official delete"
    data = load_json(path)
    require_keys(
        data,
        {"action", "object_id", "archive_attempted", "archived_first", "delete_attempted"},
        label,
    )
    if data.get("action") != "object-delete":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    if data.get("object_id") != object_id:
        raise SystemExit(f"[{label}] object_id mismatch")
    if data.get("archive_attempted") is not True:
        raise SystemExit(f"[{label}] archive_attempted != true")
    if data.get("delete_attempted") is not True:
        raise SystemExit(f"[{label}] delete_attempted != true")
    if data.get("error_code"):
        raise SystemExit(f"[{label}] unexpected error_code: {data['error_code']}")

    if data.get("archive_succeeded") is True:
        if data.get("archived_first") is not True:
            raise SystemExit(f"[{label}] archived_first should be true when archive_succeeded")
    elif data.get("archive_fallback") is True:
        if data.get("archived_first") is not False:
            raise SystemExit(f"[{label}] archived_first should be false on archive fallback")
        if data.get("archive_error_code") != "UNKNOWN_ERROR":
            raise SystemExit(f"[{label}] unexpected archive_error_code on fallback")
        description = data.get("archive_error_description", "")
        if "root block not found" not in description.lower():
            raise SystemExit(f"[{label}] unexpected archive fallback description")
        if data.get("archive_detail_fallback") is not True:
            raise SystemExit(f"[{label}] missing archive_detail_fallback on archive fallback")
        if data.get("archive_detail_succeeded") is not True:
            raise SystemExit(f"[{label}] archive detail fallback did not succeed")
    else:
        raise SystemExit(f"[{label}] archive step neither succeeded nor recorded fallback")
    return f"[{label}] ok"


def validate_official_create(path: pathlib.Path, object_id: str, object_name: str) -> str:
    label = "phase47 official create"
    data = load_json(path)
    require_keys(data, {"action", "object_id"}, label)
    if data.get("action") != "object-create":
        raise SystemExit(f"[{label}] unexpected action: {data.get('action')}")
    if data.get("object_id") != object_id:
        raise SystemExit(f"[{label}] object_id mismatch")
    if data.get("error_code"):
        raise SystemExit(f"[{label}] unexpected error_code: {data['error_code']}")
    if data.get("object_id") and not object_name:
        raise SystemExit(f"[{label}] object_name missing")
    return f"[{label}] ok"


def validate_manytype_read_contains(
    path: pathlib.Path,
    expected: str,
    label: str,
) -> str:
    text = read_text(path)
    if expected not in text:
        raise SystemExit(f"[{label}] missing expected text: {expected!r}")
    return f"[{label}] ok"


def validate_manytype_list_absence(path: pathlib.Path, object_id: str, label: str) -> str:
    text = read_text(path)
    list_text = extract_manytype_list_rows(text)
    if object_id in list_text:
        raise SystemExit(f"[{label}] still contains deleted object id {object_id}")
    return f"[{label}] ok"


def validate_manytype_read_absence(path: pathlib.Path, object_id: str, label: str) -> str:
    text = read_text(path)
    archived_message = f"Object {object_id} has been deleted or archived"
    not_found_message = f"Object not found: {object_id}"
    if archived_message not in text and not_found_message not in text:
        raise SystemExit(f"[{label}] missing read refusal for {object_id}")
    return f"[{label}] ok"


def validate_bundle(path: pathlib.Path) -> str:
    label = "phase47 bundle"
    data = load_json(path)
    require_keys(
        data,
        {
            "captured_at",
            "scenario",
            "bounded_object_type",
            "manytype_to_official",
            "official_to_manytype",
            "metadata_path",
            "success",
        },
        label,
    )
    if data.get("scenario") != "phase47 object deletion roundtrip":
        raise SystemExit(f"[{label}] unexpected scenario")
    if data.get("bounded_object_type") != "page":
        raise SystemExit(f"[{label}] unexpected bounded_object_type")
    if data.get("success") is not True:
        raise SystemExit(f"[{label}] success != True")

    manytype_to_official = data["manytype_to_official"]
    require_keys(
        manytype_to_official,
        {
            "object_id",
            "object_name",
            "presence_search_path",
            "delete_output_path",
            "delete_sync_capture_path",
            "absence_search_path",
            "restart_absence_search_path",
        },
        f"{label} manytype_to_official",
    )
    delete_text = read_text(repo_path(manytype_to_official["delete_output_path"]))
    if f"Deleted {manytype_to_official['object_id']}" not in delete_text:
        raise SystemExit(f"[{label}] Manytype delete output missing deleted id")
    validate_official_search(
        repo_path(manytype_to_official["presence_search_path"]),
        manytype_to_official["object_id"],
        manytype_to_official["object_name"],
        True,
        f"{label} manytype_to_official presence search",
    )
    validate_official_search(
        repo_path(manytype_to_official["absence_search_path"]),
        manytype_to_official["object_id"],
        manytype_to_official["object_name"],
        False,
        f"{label} manytype_to_official absence search",
    )
    validate_official_search(
        repo_path(manytype_to_official["restart_absence_search_path"]),
        manytype_to_official["object_id"],
        manytype_to_official["object_name"],
        False,
        f"{label} manytype_to_official restart absence search",
    )
    validate_manytype_sync_artifact(
        repo_path(manytype_to_official["delete_sync_capture_path"]),
        f"{label} manytype_to_official sync",
    )

    official_to_manytype = data["official_to_manytype"]
    require_keys(
        official_to_manytype,
        {
            "object_id",
            "object_name",
            "create_output_path",
            "predelete_read_path",
            "delete_output_path",
            "sync_capture_path",
            "list_absence_path",
            "read_refusal_path",
            "reopen_list_absence_path",
            "reopen_read_refusal_path",
        },
        f"{label} official_to_manytype",
    )
    validate_official_create(
        repo_path(official_to_manytype["create_output_path"]),
        official_to_manytype["object_id"],
        official_to_manytype["object_name"],
    )
    validate_manytype_read_contains(
        repo_path(official_to_manytype["predelete_read_path"]),
        f"Object: {official_to_manytype['object_id']}",
        f"{label} official_to_manytype predelete read",
    )
    validate_official_delete(
        repo_path(official_to_manytype["delete_output_path"]),
        official_to_manytype["object_id"],
    )
    validate_manytype_sync_artifact(
        repo_path(official_to_manytype["sync_capture_path"]),
        f"{label} official_to_manytype sync",
    )
    validate_manytype_list_absence(
        repo_path(official_to_manytype["list_absence_path"]),
        official_to_manytype["object_id"],
        f"{label} official_to_manytype list absence",
    )
    validate_manytype_read_absence(
        repo_path(official_to_manytype["read_refusal_path"]),
        official_to_manytype["object_id"],
        f"{label} official_to_manytype read refusal",
    )
    validate_manytype_list_absence(
        repo_path(official_to_manytype["reopen_list_absence_path"]),
        official_to_manytype["object_id"],
        f"{label} official_to_manytype reopen list absence",
    )
    validate_manytype_read_absence(
        repo_path(official_to_manytype["reopen_read_refusal_path"]),
        official_to_manytype["object_id"],
        f"{label} official_to_manytype reopen read refusal",
    )

    validate_runtime_metadata(repo_path(data["metadata_path"]))
    return f"[{label}] ok"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline validator for the Phase 47 object deletion artifact bundle."
    )
    parser.add_argument(
        "--bundle",
        default=str(ARTIFACT_DIR / "object-deletion-roundtrip.json"),
        help="Path to the Phase 47 top-level artifact bundle.",
    )
    parser.add_argument(
        "--metadata",
        default=str(ARTIFACT_DIR / "runtime-metadata.json"),
        help="Path to the Phase 47 runtime metadata artifact.",
    )
    args = parser.parse_args()

    results = [
        validate_bundle(pathlib.Path(args.bundle)),
        validate_runtime_metadata(pathlib.Path(args.metadata)),
    ]
    for result in results:
        print(result)
    print("phase47 artifacts: PASSED")


if __name__ == "__main__":
    main()
