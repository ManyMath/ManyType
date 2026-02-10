#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase65"
ARTIFACT_PATH="$ARTIFACT_DIR/v210-signoff.json"
LOCK_FILE="$ROOT_DIR/docker/any-sync/oracle.lock.env"
SIGNOFF_STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# shellcheck disable=SC1090
source "$LOCK_FILE"

mkdir -p "$ARTIFACT_DIR"
rm -f "$ARTIFACT_PATH"

printf '=== Phase 65: wider matrix and split sign-off ===\n\n'

printf 'Running Phase 62 scope-freeze gate...\n'
bash "$ROOT_DIR/scripts/phase62_scope_freeze_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase62_scope_freeze.py"
python3 "$ROOT_DIR/scripts/verify_self_hosted_oracle_metadata.py" \
  --metadata "$ROOT_DIR/test_vectors/phase62/runtime-metadata.json"

printf 'Running Phase 63 self-hosted collection compatibility gate...\n'
bash "$ROOT_DIR/scripts/phase63_manytype_to_official_collection_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase63_self_hosted_collection_compat.py"
python3 "$ROOT_DIR/scripts/verify_self_hosted_oracle_metadata.py" \
  --metadata "$ROOT_DIR/test_vectors/phase63/runtime-metadata.json"

printf 'Running Phase 64 manytype_server collection compatibility gate...\n'
bash "$ROOT_DIR/scripts/phase64_official_to_manytype_collection_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase64_manytype_server_collection_compat.py"
python3 "$ROOT_DIR/scripts/verify_self_hosted_oracle_metadata.py" \
  --metadata "$ROOT_DIR/test_vectors/phase64/runtime-metadata.json"

python3 - "$ROOT_DIR" "$ARTIFACT_PATH" "$SIGNOFF_STARTED_AT" <<'PY'
from __future__ import annotations

import datetime as dt
import hashlib
import json
import pathlib
import subprocess
import sys


ROOT = pathlib.Path(sys.argv[1])
OUTPUT = pathlib.Path(sys.argv[2])
SIGNOFF_STARTED_AT = sys.argv[3]


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
        "exists": path.exists(),
        "sha256": sha256(path) if path.exists() else "",
        "mtime": (
            dt.datetime.fromtimestamp(path.stat().st_mtime, dt.timezone.utc)
            .isoformat()
            .replace("+00:00", "Z")
            if path.exists()
            else ""
        ),
        "size": path.stat().st_size if path.exists() else 0,
    }


def load_json(path: pathlib.Path) -> dict:
    return json.loads(path.read_text())


lock = parse_env_file(ROOT / "docker" / "any-sync" / "oracle.lock.env")
phase62 = load_json(ROOT / "test_vectors" / "phase62" / "collection-slice-baseline.json")
phase63 = load_json(
    ROOT / "test_vectors" / "phase63" / "self-hosted-collection-compatibility.json"
)
phase64 = load_json(
    ROOT / "test_vectors" / "phase64" / "manytype-server-collection-compatibility.json"
)

report = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "signoff_started_at": SIGNOFF_STARTED_AT,
    "scenario": "v2.10 wider matrix and split sign-off",
    "requirements_completed": ["COMP-09", "COMP-10", "COMP-11", "COMP-12"],
    "freshness_window_seconds": 14400,
    "accepted_slice": phase62["accepted_slice"],
    "current_inputs": {
        "git": {
            "branch": optional_run(["git", "rev-parse", "--abbrev-ref", "HEAD"]),
            "commit": optional_run(["git", "rev-parse", "HEAD"]),
            "dirty": bool(optional_run(["git", "status", "--short"])),
        },
        "oracle_lock": {
            "path": "docker/any-sync/oracle.lock.env",
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
        },
        "binaries": {
            "manytype_quic_ffi_release": file_record(
                ROOT / "rust" / "target" / "release" / "libmanytype_quic_ffi.so"
            ),
            "manytype_server_debug": file_record(
                ROOT / "rust" / "target" / "debug" / "manytype_server"
            ),
        },
    },
    "scope_and_baseline": {
        "phase": 62,
        "artifact_path": "test_vectors/phase62/collection-slice-baseline.json",
        "metadata_path": "test_vectors/phase62/runtime-metadata.json",
        "account_delete": phase62["scope_decisions"]["account_delete"],
        "candidate_ranking": phase62["candidate_ranking"],
    },
    "official_stack_track": {
        "status": "passed",
        "scenarios": [
            {
                "phase": 63,
                "name": "manytype-authored bounded collection slice on the self-hosted official stack",
                "truth_surface": phase63["truth_surface"],
                "artifact_path": "test_vectors/phase63/self-hosted-collection-compatibility.json",
                "verifier": "scripts/verify_phase63_self_hosted_collection_compat.py",
                "requirements": ["M2O-07", "M2O-08", "M2O-09"],
            }
        ],
    },
    "manytype_server_track": {
        "status": "passed",
        "scenarios": [
            {
                "phase": 64,
                "name": "official-authored bounded collection slice on manytype_server",
                "truth_surface": phase64["truth_surface"],
                "artifact_path": "test_vectors/phase64/manytype-server-collection-compatibility.json",
                "diagnostics_path": display_path(
                    pathlib.Path(phase64["official_to_manytype"]["diagnostics_path"])
                ),
                "verifier": "scripts/verify_phase64_manytype_server_collection_compat.py",
                "requirements": ["O2M-07", "O2M-08", "O2M-09"],
            }
        ],
    },
    "verifiers": [
        "scripts/verify_phase62_scope_freeze.py",
        "scripts/verify_phase63_self_hosted_collection_compat.py",
        "scripts/verify_phase64_manytype_server_collection_compat.py",
        "scripts/verify_self_hosted_oracle_metadata.py",
        "scripts/verify_phase65_signoff.py",
    ],
    "success": True,
}

OUTPUT.write_text(json.dumps(report, indent=2) + "\n")
PY

printf 'Phase 65 sign-off artifact written to %s\n' "$ARTIFACT_PATH"
printf 'phase65 harness: PASSED\n'
