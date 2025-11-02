#!/usr/bin/env python3

import importlib.util
import json
import pathlib
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT_PATH = ROOT / "scripts" / "verify_nyquist_artifacts.py"
TEST_VECTORS = ROOT / "test_vectors"


def load_module():
    spec = importlib.util.spec_from_file_location("verify_nyquist_artifacts", SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class VerifyNyquistArtifactsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.module = load_module()

    def test_phase12_accepts_canonical_oracle_capture_artifact(self):
        result = self.module.validate_phase12_artifact(
            TEST_VECTORS / "oracle-capture-artifact.json"
        )
        self.assertIn("oracle-capture-artifact.json", result)

    def test_phase12_rejects_missing_space_status_check(self):
        artifact = json.loads((TEST_VECTORS / "oracle-capture-artifact.json").read_text())
        artifact["events"] = [
            event
            for event in artifact["events"]
            if event.get("method") != "/coordinator.Coordinator/SpaceStatusCheck"
        ]

        with tempfile.TemporaryDirectory() as tmpdir:
            temp_path = pathlib.Path(tmpdir) / "phase12-missing-status.json"
            temp_path.write_text(json.dumps(artifact))
            with self.assertRaises(SystemExit) as exc:
                self.module.validate_phase12_artifact(temp_path)

        self.assertIn("SpaceStatusCheck", str(exc.exception))

    def test_phase12_rejects_wrong_preflight_order(self):
        artifact = json.loads((TEST_VECTORS / "oracle-capture-artifact.json").read_text())
        unary_indices = [
            idx
            for idx, event in enumerate(artifact["events"])
            if event.get("type") == "unary_rpc"
            and event.get("method")
            in {
                "/coordinator.Coordinator/NetworkConfiguration",
                "/coordinator.Coordinator/SpaceStatusCheck",
                "/coordinator.Coordinator/SpaceSign",
            }
        ]
        self.assertEqual(len(unary_indices), 3)
        network_idx, status_idx, sign_idx = unary_indices
        artifact["events"][status_idx], artifact["events"][sign_idx] = (
            artifact["events"][sign_idx],
            artifact["events"][status_idx],
        )

        with tempfile.TemporaryDirectory() as tmpdir:
            temp_path = pathlib.Path(tmpdir) / "phase12-wrong-order.json"
            temp_path.write_text(json.dumps(artifact))
            with self.assertRaises(SystemExit) as exc:
                self.module.validate_phase12_artifact(temp_path)

        self.assertIn("invalid RPC ordering", str(exc.exception))


if __name__ == "__main__":
    unittest.main()
