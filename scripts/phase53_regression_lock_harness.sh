#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase53"
ARTIFACT_PATH="$ARTIFACT_DIR/v27-signoff.json"
LOCK_FILE="$ROOT_DIR/docker/any-sync/oracle.lock.env"
SIGNOFF_STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# shellcheck disable=SC1090
source "$LOCK_FILE"

mkdir -p "$ARTIFACT_DIR"

printf '=== Phase 53: regression lock and milestone sign-off ===\n\n'

printf 'Running Phase 50 teardown truth gate...\n'
bash "$ROOT_DIR/scripts/phase50_teardown_truth_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase50_teardown_truth.py"
python3 "$ROOT_DIR/scripts/verify_self_hosted_oracle_metadata.py" \
  --metadata "$ROOT_DIR/test_vectors/phase50/runtime-metadata.json"

printf 'Running Phase 51 bounded SpaceDelete gate...\n'
bash "$ROOT_DIR/scripts/phase51_space_delete_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase51_space_delete.py"
python3 "$ROOT_DIR/scripts/verify_self_hosted_oracle_metadata.py" \
  --metadata "$ROOT_DIR/test_vectors/phase51/runtime-metadata.json"

printf 'Running Phase 52 service-surface CLI gate...\n'
bash "$ROOT_DIR/scripts/phase52_service_cli_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase52_service_cli.py"
python3 "$ROOT_DIR/scripts/verify_self_hosted_oracle_metadata.py" \
  --metadata "$ROOT_DIR/test_vectors/phase52/runtime-metadata.json"

rm -f "$ARTIFACT_PATH"
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
phase50 = load_json(ROOT / "test_vectors" / "phase50" / "teardown-truth-baseline.json")
phase51 = load_json(ROOT / "test_vectors" / "phase51" / "space-delete-parity.json")
phase52 = load_json(ROOT / "test_vectors" / "phase52" / "service-cli-productization.json")

report = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "signoff_started_at": SIGNOFF_STARTED_AT,
    "scenario": "v2.7 regression lock and milestone sign-off",
    "requirements_completed": ["V27-01", "V27-02", "V27-03"],
    "freshness_window_seconds": 14400,
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
            "manytype_server_release": file_record(
                ROOT / "rust" / "target" / "release" / "manytype_server"
            ),
        },
    },
    "scope_decisions": {
        "account_delete": {
            "decision": phase50["account_delete"]["decision"],
            "reason": phase50["account_delete"]["reason"],
            "official_capture_path": display_path(
                pathlib.Path(phase50["account_delete"]["official_capture_path"])
            ),
            "local_capture_path": display_path(
                pathlib.Path(phase50["account_delete"]["local_capture_path"])
            ),
        }
    },
    "official_stack_track": {
        "status": "passed",
        "scenarios": [
            {
                "phase": 50,
                "name": "teardown truth capture and scope freeze",
                "proof_mode": phase50["space_delete"]["proof_mode_label"],
                "bundle_path": "test_vectors/phase50/teardown-truth-baseline.json",
                "artifact_path": display_path(
                    pathlib.Path(phase50["space_delete"]["official_capture_path"])
                ),
                "verifier": "scripts/verify_phase50_teardown_truth.py",
                "requirements": ["TRTH-01", "TRTH-03", "TRTH-04", "TRTH-05"],
            },
            {
                "phase": 51,
                "name": "bounded space delete parity",
                "proof_mode": phase51["proof_mode"],
                "bundle_path": "test_vectors/phase51/space-delete-parity.json",
                "artifact_path": display_path(
                    pathlib.Path(phase51["official_supported_flow"]["artifact_path"])
                ),
                "verifier": "scripts/verify_phase51_space_delete.py",
                "requirements": ["SDEL-01", "SDEL-02", "SDEL-03"],
            },
            {
                "phase": 52,
                "name": "oracle acl lifecycle cli",
                "proof_mode": "later-read",
                "bundle_path": "test_vectors/phase52/service-cli-productization.json",
                "artifact_path": display_path(
                    pathlib.Path(phase52["oracle_acl"]["artifact_path"])
                ),
                "verifier": "scripts/verify_phase52_service_cli.py",
                "requirements": ["OPS-01", "OPS-04"],
            },
        ],
    },
    "manytype_server_track": {
        "status": "passed",
        "scenarios": [
            {
                "phase": 50,
                "name": "local teardown truth capture",
                "proof_mode": "reconnect-reread",
                "bundle_path": "test_vectors/phase50/teardown-truth-baseline.json",
                "artifact_path": display_path(
                    pathlib.Path(phase50["space_delete"]["local_capture_path"])
                ),
                "verifier": "scripts/verify_phase50_teardown_truth.py",
                "requirements": ["TRTH-01", "TRTH-02", "TRTH-05"],
            },
            {
                "phase": 51,
                "name": "local space-delete rejection",
                "proof_mode": "reconnect-reread",
                "bundle_path": "test_vectors/phase51/space-delete-parity.json",
                "artifact_path": display_path(
                    pathlib.Path(phase51["local_rejected_flow"]["artifact_path"])
                ),
                "verifier": "scripts/verify_phase51_space_delete.py",
                "requirements": ["SDEL-03"],
            },
            {
                "phase": 52,
                "name": "local consensus restart continuation",
                "proof_mode": "restart",
                "bundle_path": "test_vectors/phase52/service-cli-productization.json",
                "artifact_path": display_path(
                    pathlib.Path(phase52["local_consensus"]["continue_path"])
                ),
                "verifier": "scripts/verify_phase52_service_cli.py",
                "requirements": ["OPS-02", "OPS-04"],
            },
            {
                "phase": 52,
                "name": "local space pull continuity",
                "proof_mode": "restart",
                "bundle_path": "test_vectors/phase52/service-cli-productization.json",
                "artifact_path": display_path(
                    pathlib.Path(phase52["local_space_pull"]["refetch_path"])
                ),
                "verifier": "scripts/verify_phase52_service_cli.py",
                "requirements": ["OPS-03", "OPS-04"],
            },
        ],
    },
    "verifiers": [
        "scripts/verify_phase50_teardown_truth.py",
        "scripts/verify_phase51_space_delete.py",
        "scripts/verify_phase52_service_cli.py",
        "scripts/verify_self_hosted_oracle_metadata.py",
        "scripts/verify_phase53_signoff.py",
    ],
    "success": True,
}

OUTPUT.write_text(json.dumps(report, indent=2) + "\n")
PY

printf 'Phase 53 sign-off artifact written to %s\n' "$ARTIFACT_PATH"
printf 'phase53 harness: PASSED\n'
