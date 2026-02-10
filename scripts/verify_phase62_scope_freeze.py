#!/usr/bin/env python3

"""Offline verifier for the Phase 62 collection scope-freeze artifact."""

from __future__ import annotations

import argparse
import json
import pathlib


ROOT = pathlib.Path(__file__).resolve().parents[1]
DEFAULT_ARTIFACT = ROOT / "test_vectors" / "phase62" / "collection-slice-baseline.json"


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
        description="Offline verifier for the Phase 62 collection scope-freeze artifact."
    )
    parser.add_argument(
        "--artifact",
        default=str(DEFAULT_ARTIFACT),
        help="Path to the Phase 62 collection baseline artifact.",
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
            "candidate_ranking",
            "scope_decisions",
            "oracle_baseline",
            "evidence_references",
            "metadata_path",
            "success",
        },
        "phase62 scope freeze",
    )
    if artifact["scenario"] != "phase62 compound tranche freeze and oracle baseline":
        raise SystemExit("[phase62 scope freeze] unexpected scenario")
    if artifact["success"] is not True:
        raise SystemExit("[phase62 scope freeze] success != true")

    accepted_slice = artifact["accepted_slice"]
    require_keys(
        accepted_slice,
        {
            "object_family",
            "mutation_family",
            "container_object_type",
            "included_operations",
            "manytype_to_official_truth_surface",
            "official_to_manytype_truth_surface",
            "excluded_variants",
        },
        "phase62 accepted slice",
    )
    if accepted_slice["container_object_type"] != "collection":
        raise SystemExit("[phase62 accepted slice] unexpected container_object_type")
    if accepted_slice["included_operations"] != [
        "create-collection",
        "collection-add",
        "collection-remove",
        "collection-move-front",
    ]:
        raise SystemExit("[phase62 accepted slice] unexpected included_operations")
    if accepted_slice["manytype_to_official_truth_surface"]["label"] != "self-hosted-official":
        raise SystemExit("[phase62 accepted slice] unexpected manytype_to_official truth surface")
    if accepted_slice["official_to_manytype_truth_surface"]["label"] != "manytype_server":
        raise SystemExit("[phase62 accepted slice] unexpected official_to_manytype truth surface")
    if "AccountDelete parity" not in accepted_slice["excluded_variants"]:
        raise SystemExit("[phase62 accepted slice] AccountDelete exclusion missing")

    ranking = artifact["candidate_ranking"]
    if not isinstance(ranking, list) or len(ranking) < 4:
        raise SystemExit("[phase62 candidate ranking] expected at least four ranked candidates")
    accepted_candidate = ranking[0]
    require_keys(
        accepted_candidate,
        {"candidate", "decision", "rank", "rationale", "evidence_paths"},
        "phase62 candidate ranking accepted",
    )
    if accepted_candidate["candidate"] != "collection-membership":
        raise SystemExit("[phase62 candidate ranking] expected collection-membership first")
    if accepted_candidate["decision"] != "accepted":
        raise SystemExit("[phase62 candidate ranking] expected accepted decision for collection-membership")
    for candidate in ranking:
      require_keys(
          candidate,
          {"candidate", "decision", "rank", "rationale", "evidence_paths"},
          f"phase62 candidate ranking {candidate.get('candidate', '<unknown>')}",
      )
      if not isinstance(candidate["evidence_paths"], list) or not candidate["evidence_paths"]:
          raise SystemExit(
              f"[phase62 candidate ranking] empty evidence_paths for {candidate['candidate']}"
          )
      for evidence_path in candidate["evidence_paths"]:
          if not pathlib.Path(evidence_path).exists():
              raise SystemExit(
                  f"[phase62 candidate ranking] missing evidence for {candidate['candidate']}: {evidence_path}"
              )

    scope_decisions = artifact["scope_decisions"]
    require_keys(
        scope_decisions,
        {"account_delete", "official_to_manytype_server_requirement"},
        "phase62 scope decisions",
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
        "phase62 account delete",
    )
    if account_delete["decision"] != "defer":
        raise SystemExit("[phase62 account delete] decision != defer")
    for field in ("official_capture_path", "local_capture_path", "source_phase50_path"):
        if not pathlib.Path(account_delete[field]).exists():
            raise SystemExit(f"[phase62 account delete] missing referenced file: {account_delete[field]}")

    local_requirement = scope_decisions["official_to_manytype_server_requirement"]
    if local_requirement.get("official_post_mutation_reread_required") is not True:
        raise SystemExit(
            "[phase62 scope decisions] official_post_mutation_reread_required != true"
        )
    if local_requirement.get("fresh_home_reread_required") is not True:
        raise SystemExit("[phase62 scope decisions] fresh_home_reread_required != true")

    oracle_baseline = artifact["oracle_baseline"]
    require_keys(
        oracle_baseline,
        {"preflight", "network_config_path", "client_yml_ready", "exercised_binaries"},
        "phase62 oracle baseline",
    )
    if oracle_baseline["preflight"] != "passed":
        raise SystemExit("[phase62 oracle baseline] preflight != passed")
    if oracle_baseline["client_yml_ready"] is not True:
        raise SystemExit("[phase62 oracle baseline] client_yml_ready != true")
    if not pathlib.Path(oracle_baseline["network_config_path"]).exists():
        raise SystemExit("[phase62 oracle baseline] network config missing")

    evidence = artifact["evidence_references"]
    require_keys(
        evidence,
        {
            "phase39_add_path",
            "phase39_remove_path",
            "phase39_move_path",
            "phase42_manytype_to_official_collection_path",
            "phase42_official_to_manytype_collection_path",
            "phase38_status_path",
            "phase38_tag_path",
            "phase40_file_relation_path",
            "phase41_template_verification_path",
            "phase42_manytype_to_official_template_path",
            "phase42_official_to_manytype_template_path",
        },
        "phase62 evidence references",
    )
    for value in evidence.values():
        if not pathlib.Path(value).exists():
            raise SystemExit(f"[phase62 evidence references] missing referenced file: {value}")

    metadata_path = pathlib.Path(artifact["metadata_path"])
    if not metadata_path.exists():
        raise SystemExit(f"[phase62 scope freeze] missing metadata: {metadata_path}")

    print("[phase62 scope freeze] ok")
    print("phase62 scope freeze: PASSED")


if __name__ == "__main__":
    main()
