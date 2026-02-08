#!/usr/bin/env python3

"""Offline verifier for the Phase 58 scope-freeze artifact."""

from __future__ import annotations

import argparse
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_ARTIFACT = ROOT / "test_vectors" / "phase58" / "bounded-delete-baseline.json"


def load_json(path: pathlib.Path) -> dict:
    if not path.exists():
        raise SystemExit(f"missing artifact: {path}")
    return json.loads(path.read_text())


def require_keys(data: dict, keys: set[str], label: str) -> None:
    missing = sorted(keys - set(data.keys()))
    if missing:
        raise SystemExit(f"[{label}] missing keys: {missing}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Offline verifier for the Phase 58 scope-freeze artifact."
    )
    parser.add_argument(
        "--artifact",
        default=str(DEFAULT_ARTIFACT),
        help="Path to the Phase 58 bounded-delete baseline artifact.",
    )
    args = parser.parse_args()

    artifact_path = pathlib.Path(args.artifact)
    artifact = load_json(artifact_path)

    require_keys(
        artifact,
        {
            "captured_at",
            "scenario",
            "accepted_slice",
            "scope_decisions",
            "oracle_baseline",
            "evidence_references",
            "metadata_path",
            "success",
        },
        "phase58 scope freeze",
    )
    if artifact["scenario"] != "phase58 bounded delete tranche freeze and oracle baseline":
        raise SystemExit("[phase58 scope freeze] unexpected scenario")
    if artifact["success"] is not True:
        raise SystemExit("[phase58 scope freeze] success != true")

    accepted_slice = artifact["accepted_slice"]
    require_keys(
        accepted_slice,
        {
            "object_family",
            "mutation_family",
            "bounded_object_type",
            "manytype_to_official_truth_surface",
            "official_to_manytype_truth_surface",
            "excluded_variants",
        },
        "phase58 accepted slice",
    )
    if accepted_slice["mutation_family"] != "archive-backed object deletion":
        raise SystemExit("[phase58 accepted slice] unexpected mutation family")
    if accepted_slice["bounded_object_type"] != "page":
        raise SystemExit("[phase58 accepted slice] unexpected bounded object type")
    if accepted_slice["manytype_to_official_truth_surface"]["label"] != "self-hosted-official":
        raise SystemExit("[phase58 accepted slice] unexpected manytype_to_official truth surface")
    if accepted_slice["official_to_manytype_truth_surface"]["label"] != "manytype_server":
        raise SystemExit("[phase58 accepted slice] unexpected official_to_manytype truth surface")
    if "AccountDelete parity" not in accepted_slice["excluded_variants"]:
        raise SystemExit("[phase58 accepted slice] AccountDelete exclusion missing")

    scope_decisions = artifact["scope_decisions"]
    require_keys(
        scope_decisions,
        {"account_delete", "official_to_manytype_server_requirement"},
        "phase58 scope decisions",
    )
    account_delete = scope_decisions["account_delete"]
    require_keys(
        account_delete,
        {
            "decision",
            "reason",
            "official_capture_path",
            "local_capture_path",
            "source_phase50_path",
        },
        "phase58 account delete",
    )
    if account_delete["decision"] != "defer":
        raise SystemExit("[phase58 account delete] decision != defer")
    for field in ("official_capture_path", "local_capture_path", "source_phase50_path"):
        if not pathlib.Path(account_delete[field]).exists():
            raise SystemExit(
                f"[phase58 account delete] missing referenced file: {account_delete[field]}"
            )

    local_requirement = scope_decisions["official_to_manytype_server_requirement"]
    for key in (
        "manytype_list_absence_required",
        "manytype_read_refusal_required",
        "fresh_home_reread_required",
    ):
        if local_requirement.get(key) is not True:
            raise SystemExit(f"[phase58 scope decisions] {key} != true")

    oracle_baseline = artifact["oracle_baseline"]
    require_keys(
        oracle_baseline,
        {"preflight", "network_config_path", "client_yml_ready", "exercised_binaries"},
        "phase58 oracle baseline",
    )
    if oracle_baseline["preflight"] != "passed":
        raise SystemExit("[phase58 oracle baseline] preflight != passed")
    if oracle_baseline["client_yml_ready"] is not True:
        raise SystemExit("[phase58 oracle baseline] client_yml_ready != true")
    if not pathlib.Path(oracle_baseline["network_config_path"]).exists():
        raise SystemExit("[phase58 oracle baseline] network config missing")

    evidence = artifact["evidence_references"]
    require_keys(
        evidence,
        {
            "phase47_bundle_path",
            "phase47_manytype_to_official_presence_search_path",
            "phase47_manytype_to_official_absence_search_path",
            "phase47_manytype_to_official_restart_absence_search_path",
            "phase47_official_to_manytype_predelete_read_path",
            "phase47_official_to_manytype_list_absence_path",
            "phase47_official_to_manytype_read_refusal_path",
            "phase47_official_to_manytype_reopen_read_refusal_path",
        },
        "phase58 evidence references",
    )
    for value in evidence.values():
        if not pathlib.Path(value).exists():
            raise SystemExit(f"[phase58 evidence references] missing referenced file: {value}")

    metadata_path = pathlib.Path(artifact["metadata_path"])
    if not metadata_path.exists():
        raise SystemExit(f"[phase58 scope freeze] missing metadata: {metadata_path}")

    print("[phase58 scope freeze] ok")
    print("phase58 scope freeze: PASSED")


if __name__ == "__main__":
    main()
