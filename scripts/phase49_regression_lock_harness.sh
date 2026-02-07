#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_DIR="$ROOT_DIR/test_vectors/phase49"
ARTIFACT_PATH="$ARTIFACT_DIR/v26-signoff.json"
LOCK_FILE="$ROOT_DIR/docker/any-sync/oracle.lock.env"

# shellcheck disable=SC1090
source "$LOCK_FILE"

PHASE45_ANYTYPE_IMAGE="${ANYTYPE_IMAGE:-$ANYTYPE_CLI_IMAGE}"
SIGNOFF_STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p "$ARTIFACT_DIR"

printf '=== Phase 49: regression lock and milestone sign-off ===\n\n'

printf 'Building release binaries for sign-off...\n'
(cd "$ROOT_DIR/rust" && cargo build -p manytype_quic_ffi -p manytype_server --release >/dev/null)

printf 'Running oracle preflight...\n'
bash "$ROOT_DIR/scripts/self_hosted_oracle_preflight.sh" --quiet

printf 'Running Phase 45 manytype_server sentinel...\n'
ANYTYPE_IMAGE="$PHASE45_ANYTYPE_IMAGE" bash "$ROOT_DIR/scripts/phase31_cross_authored_manytype_server.sh"
python3 "$ROOT_DIR/scripts/verify_phase31_manytype_server_artifacts.py"

printf 'Running Phase 46 official-stack gate...\n'
bash "$ROOT_DIR/scripts/phase46_bounded_object_edit_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase46_artifacts.py"
python3 "$ROOT_DIR/scripts/verify_self_hosted_oracle_metadata.py" \
  --metadata "$ROOT_DIR/test_vectors/phase46/runtime-metadata.json"

printf 'Running Phase 47 official-stack gate...\n'
bash "$ROOT_DIR/scripts/phase47_object_deletion_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase47_artifacts.py"
python3 "$ROOT_DIR/scripts/verify_self_hosted_oracle_metadata.py" \
  --metadata "$ROOT_DIR/test_vectors/phase47/runtime-metadata.json"

printf 'Running Phase 48 mixed-track gate...\n'
bash "$ROOT_DIR/scripts/phase48_service_surface_harness.sh"
python3 "$ROOT_DIR/scripts/verify_phase48_artifacts.py"
python3 "$ROOT_DIR/scripts/verify_self_hosted_oracle_metadata.py" \
  --metadata "$ROOT_DIR/test_vectors/phase48/runtime-metadata.json"

python3 - "$ROOT_DIR" "$ARTIFACT_PATH" "$SIGNOFF_STARTED_AT" "$PHASE45_ANYTYPE_IMAGE" <<'PY'
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
PHASE45_ANYTYPE_IMAGE = sys.argv[4]


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
phase31 = load_json(ROOT / "test_vectors" / "phase31-cross-authored-manytype-server.json")
phase46 = load_json(ROOT / "test_vectors" / "phase46" / "bounded-object-edit-roundtrip.json")
phase47 = load_json(ROOT / "test_vectors" / "phase47" / "object-deletion-roundtrip.json")
phase48 = load_json(ROOT / "test_vectors" / "phase48" / "service-surface-baseline.json")

phase46_metadata = ROOT / "test_vectors" / "phase46" / "runtime-metadata.json"
phase47_metadata = ROOT / "test_vectors" / "phase47" / "runtime-metadata.json"
phase48_metadata = ROOT / "test_vectors" / "phase48" / "runtime-metadata.json"

report = {
    "captured_at": dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z"),
    "signoff_started_at": SIGNOFF_STARTED_AT,
    "scenario": "v2.6 regression lock and milestone sign-off",
    "requirements_completed": ["V26-01", "V26-02", "V26-03", "V26-04"],
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
        "phase45_anytype_image": PHASE45_ANYTYPE_IMAGE,
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
    "official_stack_track": {
        "status": "passed",
        "scenarios": [
            {
                "phase": 46,
                "name": "bounded object/detail roundtrip",
                "proof_mode": "restart-or-reopen",
                "bundle_path": "test_vectors/phase46/bounded-object-edit-roundtrip.json",
                "runtime_metadata_path": display_path(phase46_metadata),
                "verifier": "scripts/verify_phase46_artifacts.py",
                "requirements": ["EDIT-01", "EDIT-02", "EDIT-03"],
            },
            {
                "phase": 47,
                "name": "object deletion roundtrip",
                "proof_mode": "restart-or-reopen",
                "bundle_path": "test_vectors/phase47/object-deletion-roundtrip.json",
                "runtime_metadata_path": display_path(phase47_metadata),
                "verifier": "scripts/verify_phase47_artifacts.py",
                "requirements": ["DEL-01", "DEL-02", "DEL-03"],
            },
            {
                "phase": 48,
                "name": "oracle acl lifecycle later-read",
                "proof_mode": "later-read",
                "bundle_path": "test_vectors/phase48/service-surface-baseline.json",
                "artifact_path": display_path(pathlib.Path(phase48["oracle_acl"]["artifact_path"])),
                "runtime_metadata_path": display_path(phase48_metadata),
                "verifier": "scripts/verify_phase48_artifacts.py",
                "requirements": ["SRV-01", "SRV-04"],
            },
        ],
    },
    "manytype_server_track": {
        "status": "passed",
        "scenarios": [
            {
                "phase": 45,
                "name": "latest-head observation sentinel",
                "proof_mode": "reconnect-reread",
                "bundle_path": "test_vectors/phase31-cross-authored-manytype-server.json",
                "artifact_path": display_path(
                    pathlib.Path(phase31["official_probe"]["show_result_path"])
                ),
                "verifier": "scripts/verify_phase31_manytype_server_artifacts.py",
                "requirements": ["OBS-01", "OBS-02", "OBS-03"],
            },
            {
                "phase": 48,
                "name": "local consensus restart continuation",
                "proof_mode": "restart",
                "bundle_path": "test_vectors/phase48/service-surface-baseline.json",
                "artifact_path": display_path(
                    pathlib.Path(phase48["local_consensus"]["continue_path"])
                ),
                "verifier": "scripts/verify_phase48_artifacts.py",
                "requirements": ["SRV-02", "SRV-04"],
            },
            {
                "phase": 48,
                "name": "local space pull continuity",
                "proof_mode": "restart",
                "bundle_path": "test_vectors/phase48/service-surface-baseline.json",
                "artifact_path": display_path(
                    pathlib.Path(phase48["local_space_pull"]["refetch_path"])
                ),
                "verifier": "scripts/verify_phase48_artifacts.py",
                "requirements": ["SRV-03", "SRV-04"],
            },
        ],
    },
    "verifiers": [
        "scripts/verify_phase31_manytype_server_artifacts.py",
        "scripts/verify_phase46_artifacts.py",
        "scripts/verify_phase47_artifacts.py",
        "scripts/verify_phase48_artifacts.py",
        "scripts/verify_self_hosted_oracle_metadata.py",
    ],
    "success": True,
}

OUTPUT.write_text(json.dumps(report, indent=2) + "\n")
PY

printf 'Phase 49 sign-off artifact written to %s\n' "$ARTIFACT_PATH"
printf 'phase49 harness: PASSED\n'
