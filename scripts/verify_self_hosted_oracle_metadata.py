#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import pathlib


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Validate a self-hosted oracle runtime metadata sidecar."
    )
    parser.add_argument("--metadata", required=True)
    args = parser.parse_args()

    path = pathlib.Path(args.metadata)
    if not path.exists():
        raise SystemExit(f"missing metadata: {path}")

    data = json.loads(path.read_text())
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
        "oracle metadata",
    )

    git = data["git"]
    require_keys(git, {"branch", "commit", "dirty"}, "oracle metadata.git")
    if not git["commit"]:
        raise SystemExit("[oracle metadata.git] commit is empty")

    official_cli = data["official_cli"]
    require_keys(
        official_cli,
        {"image_id", "repo_digest", "version", "revision", "source"},
        "oracle metadata.official_cli",
    )
    if not official_cli["repo_digest"]:
        raise SystemExit("[oracle metadata.official_cli] repo_digest is empty")

    network_config = data["network_config"]
    require_keys(
        network_config,
        {"path", "sha256", "mtime", "network_id"},
        "oracle metadata.network_config",
    )
    if not network_config["network_id"]:
        raise SystemExit("[oracle metadata.network_config] network_id is empty")

    binaries = data["binaries"]
    require_keys(
        binaries,
        {"manytype_quic_ffi", "manytype_server_debug", "official_client_probe"},
        "oracle metadata.binaries",
    )
    if binaries["manytype_quic_ffi"].get("exists") is not True:
        raise SystemExit("[oracle metadata.binaries] manytype_quic_ffi is missing")

    artifacts = data["artifacts"]
    if not isinstance(artifacts, list) or not artifacts:
        raise SystemExit("[oracle metadata.artifacts] expected at least one artifact record")

    print(f"oracle metadata: PASSED ({path})")


if __name__ == "__main__":
    main()
