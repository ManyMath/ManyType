#!/usr/bin/env python3

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import pathlib
import subprocess


ROOT = pathlib.Path(__file__).resolve().parents[1]
LOCK_FILE = ROOT / "docker" / "any-sync" / "oracle.lock.env"
FFI_LIB = ROOT / "rust" / "target" / "release" / "libmanytype_quic_ffi.so"
MANYTYPE_SERVER_BIN = ROOT / "rust" / "target" / "debug" / "manytype_server"


def parse_env_file(path: pathlib.Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip().strip('"')
    return values


def run(args: list[str]) -> str:
    return subprocess.check_output(args, cwd=ROOT, text=True).strip()


def optional_run(args: list[str]) -> str:
    try:
        return run(args)
    except subprocess.CalledProcessError:
        return ""


def sha256(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def display_path(path: pathlib.Path) -> str:
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def file_record(path: pathlib.Path) -> dict[str, object]:
    return {
        "path": display_path(path),
        "sha256": sha256(path),
        "mtime": dt.datetime.fromtimestamp(path.stat().st_mtime, dt.timezone.utc)
        .isoformat()
        .replace("+00:00", "Z"),
        "size": path.stat().st_size,
    }


def binary_record(path: pathlib.Path) -> dict[str, object]:
    record: dict[str, object] = {"path": display_path(path), "exists": path.exists()}
    if path.exists():
        record.update(file_record(path))
    return record


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Write self-hosted oracle runtime metadata for a sign-off run."
    )
    parser.add_argument("--output", required=True)
    parser.add_argument("--scenario", required=True)
    parser.add_argument("--network-config", required=True)
    parser.add_argument("--image", required=True)
    parser.add_argument("--probe-binary")
    parser.add_argument("--artifact", action="append", default=[])
    args = parser.parse_args()

    output_path = pathlib.Path(args.output)
    network_config = pathlib.Path(args.network_config)
    probe_binary = pathlib.Path(args.probe_binary) if args.probe_binary else None

    lock = parse_env_file(LOCK_FILE)
    docker_env = parse_env_file(ROOT / "docker" / "any-sync" / ".env")

    git_commit = optional_run(["git", "rev-parse", "HEAD"])
    git_branch = optional_run(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    git_dirty = bool(optional_run(["git", "status", "--short"]))

    image_inspect = json.loads(run(["docker", "image", "inspect", args.image]))[0]
    labels = image_inspect.get("Config", {}).get("Labels") or {}
    repo_digests = image_inspect.get("RepoDigests") or []

    artifacts = [pathlib.Path(path) for path in args.artifact]
    metadata = {
        "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
        "scenario": args.scenario,
        "git": {
            "branch": git_branch,
            "commit": git_commit,
            "dirty": git_dirty,
        },
        "oracle_lock": {
            "path": str(LOCK_FILE.relative_to(ROOT)),
            "any_sync_versions": {
                key: lock.get(key, "")
                for key in (
                    "ANY_SYNC_NODE_VERSION",
                    "ANY_SYNC_FILENODE_VERSION",
                    "ANY_SYNC_COORDINATOR_VERSION",
                    "ANY_SYNC_CONSENSUSNODE_VERSION",
                )
            },
            "anytype_cli_image": lock.get("ANYTYPE_CLI_IMAGE", ""),
            "anytype_cli_tag": lock.get("ANYTYPE_CLI_TAG", ""),
            "anytype_cli_revision": lock.get("ANYTYPE_CLI_REVISION", ""),
            "resolved_image": args.image,
        },
        "official_cli": {
            "image_id": image_inspect.get("Id", ""),
            "repo_digest": repo_digests[0] if repo_digests else "",
            "version": labels.get("org.opencontainers.image.version", ""),
            "revision": labels.get("org.opencontainers.image.revision", ""),
            "source": labels.get("org.opencontainers.image.source", ""),
        },
        "docker_any_sync_env": {
            "path": "docker/any-sync/.env",
            "versions": {
                key: docker_env.get(key, "")
                for key in (
                    "ANY_SYNC_NODE_VERSION",
                    "ANY_SYNC_FILENODE_VERSION",
                    "ANY_SYNC_COORDINATOR_VERSION",
                    "ANY_SYNC_CONSENSUSNODE_VERSION",
                )
            },
        },
        "network_config": {
            "path": str(network_config.relative_to(ROOT)),
            "sha256": sha256(network_config),
            "mtime": dt.datetime.fromtimestamp(
                network_config.stat().st_mtime, dt.timezone.utc
            )
            .isoformat()
            .replace("+00:00", "Z"),
            "network_id": next(
                (
                    line.split(":", 1)[1].strip()
                    for line in network_config.read_text().splitlines()
                    if line.startswith("networkId:")
                ),
                "",
            ),
        },
        "binaries": {
            "manytype_quic_ffi": binary_record(FFI_LIB),
            "manytype_server_debug": binary_record(MANYTYPE_SERVER_BIN),
            "official_client_probe": (
                binary_record(probe_binary) if probe_binary else {"path": "", "exists": False}
            ),
        },
        "artifacts": [file_record(path) for path in artifacts if path.exists()],
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(metadata, indent=2) + "\n")


if __name__ == "__main__":
    main()
