#!/usr/bin/env python3

import json
import pathlib
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import verify_file_artifacts as v


class VerifyFileArtifactsTest(unittest.TestCase):
    def _write(self, tmp: pathlib.Path, name: str, payload: dict) -> pathlib.Path:
        path = tmp / name
        path.write_text(json.dumps(payload) + "\n")
        return path

    def test_live_probe_rejects_block_push(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            tmp = pathlib.Path(td)
            path = self._write(
                tmp,
                "live.json",
                {
                    "read_only": True,
                    "events": [
                        {"type": "unary_rpc", "method": "/coordinator.Coordinator/NetworkConfiguration"},
                        {"type": "unary_rpc", "method": "/filesync.File/Check"},
                        {"type": "unary_rpc", "method": "/filesync.File/BlocksCheck"},
                        {"type": "unary_rpc", "method": "/filesync.File/BlockGet"},
                        {"type": "unary_rpc", "method": "/filesync.File/BlockPush"},
                    ],
                },
            )
            with self.assertRaises(SystemExit):
                v.validate_live_probe(path)

    def test_official_api_requires_markers(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            tmp = pathlib.Path(td)
            path = self._write(
                tmp,
                "official.json",
                {
                    "captured_at": "2026-04-06T00:00:00Z",
                    "server_peer_id": "12D3KooWTest",
                    "api_probe_success": True,
                    "initial_space_count": 1,
                    "restart_space_count": 1,
                    "gateway_urls": ["http://127.0.0.1:47800"],
                    "file_methods_observed": [],
                    "automation_status": "api_only",
                    "limitation": "manual step remains",
                    "required_markers": ["Credential handshake complete"],
                    "observed_markers": [],
                    "harness_exit_code": 0,
                },
            )
            with self.assertRaises(SystemExit):
                v.validate_official_api(path)

    def test_official_full_roundtrip_requires_ordered_check_and_blockscheck(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            tmp = pathlib.Path(td)
            path = self._write(
                tmp,
                "official-roundtrip.json",
                {
                    "captured_at": "2026-04-06T00:00:00Z",
                    "server_peer_id": "12D3KooWTest",
                    "api_probe_success": True,
                    "initial_space_count": 1,
                    "restart_space_count": 1,
                    "gateway_urls": ["http://127.0.0.1:47800"],
                    "file_methods_observed": ["/filesync.File/BlocksCheck"],
                    "file_method_sequence": ["/filesync.File/BlocksCheck"],
                    "required_file_method_sequence": [
                        "/filesync.File/Check",
                        "/filesync.File/BlocksCheck",
                    ],
                    "automation_status": "full_file_roundtrip",
                    "limitation": "headless gRPC path works",
                    "required_markers": ["Credential handshake complete"],
                    "observed_markers": ["Credential handshake complete"],
                    "harness_exit_code": 0,
                    "roundtrip_success": True,
                    "roundtrip_object_id": "bafy-object",
                    "payload_sha256": "abc",
                    "downloaded_sha256": "abc",
                    "byte_match": True,
                    "roundtrip_method_order_ok": False,
                    "fatal_error_lines": [],
                },
            )
            with self.assertRaises(SystemExit):
                v.validate_official_api(path)

    def test_official_full_roundtrip_accepts_valid_shape(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            tmp = pathlib.Path(td)
            path = self._write(
                tmp,
                "official-roundtrip-valid.json",
                {
                    "captured_at": "2026-04-06T00:00:00Z",
                    "server_peer_id": "12D3KooWTest",
                    "api_probe_success": True,
                    "initial_space_count": 1,
                    "restart_space_count": 1,
                    "gateway_urls": ["http://127.0.0.1:47800"],
                    "file_methods_observed": [
                        "/filesync.File/Check",
                        "/filesync.File/BlocksCheck",
                        "/filesync.File/AccountInfo",
                    ],
                    "file_method_sequence": [
                        "/filesync.File/Check",
                        "/filesync.File/BlocksCheck",
                        "/filesync.File/AccountInfo",
                    ],
                    "required_file_method_sequence": [
                        "/filesync.File/Check",
                        "/filesync.File/BlocksCheck",
                    ],
                    "automation_status": "full_file_roundtrip",
                    "limitation": "headless gRPC path works",
                    "required_markers": [
                        "Credential handshake complete",
                        "Proto handshake complete",
                    ],
                    "observed_markers": [
                        "Credential handshake complete",
                        "Proto handshake complete",
                    ],
                    "harness_exit_code": 0,
                    "roundtrip_success": True,
                    "roundtrip_object_id": "bafy-object",
                    "payload_sha256": "abc",
                    "downloaded_sha256": "abc",
                    "byte_match": True,
                    "roundtrip_method_order_ok": True,
                    "fatal_error_lines": [],
                },
            )
            self.assertIn("full_file_roundtrip", v.validate_official_api(path))

    def test_oracle_roundtrip_accepts_valid_shape(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            tmp = pathlib.Path(td)
            path = self._write(
                tmp,
                "roundtrip.json",
                {
                    "events": [
                        {"type": "unary_rpc", "method": "/coordinator.Coordinator/NetworkConfiguration"},
                        {"type": "unary_rpc", "method": "/filesync.File/BlocksCheck"},
                        {"type": "unary_rpc", "method": "/filesync.File/BlockPush"},
                        {"type": "unary_rpc", "method": "/filesync.File/BlockGet"},
                        {"type": "cache_miss"},
                        {"type": "cache_hit"},
                        {"type": "wrote_output"},
                    ]
                },
            )
            self.assertIn("oracle roundtrip ok", v.validate_oracle_roundtrip(path))


if __name__ == "__main__":
    unittest.main()
