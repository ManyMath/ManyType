"""Protocol-tool selection and canonical-byte regressions, without installers."""
import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    'generate_protocol', Path(__file__).parents[1] / 'generate_protocol.py')
codegen = importlib.util.module_from_spec(spec)
spec.loader.exec_module(codegen)


class ProtocolPortabilityTests(unittest.TestCase):
    def test_explicit_include_is_authoritative_and_must_exist(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            include = root / 'protobuf include'
            schema = include / 'google/protobuf/struct.proto'
            schema.parent.mkdir(parents=True)
            schema.write_bytes(b'syntax = "proto3";\n')
            self.assertEqual(codegen.protocol_include('unused', {
                'PROTOC_INCLUDE': str(include)}), include.resolve())
            with self.assertRaisesRegex(RuntimeError, 'PROTOC_INCLUDE'):
                codegen.protocol_include('unused', {
                    'PROTOC_INCLUDE': str(root / 'missing')})

    def test_include_is_discovered_beside_provisioned_protoc(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            schema = root / 'include/google/protobuf/struct.proto'
            schema.parent.mkdir(parents=True)
            schema.write_bytes(b'fixture\n')
            self.assertEqual(codegen.protocol_include(root / 'bin/protoc', {}),
                             (root / 'include').resolve())

    def test_missing_pinned_formatter_never_uses_a_path_decoy(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'rustfmt').write_bytes(b'wrong formatter')
            with patch.dict(os.environ, {'PATH': str(root)}), patch.object(
                    codegen, 'output', return_value=str(root / 'missing/rustfmt')) as command:
                with self.assertRaisesRegex(RuntimeError, 'no PATH fallback'):
                    codegen.pinned_rustfmt()
            command.assert_called_once_with(
                ['rustup', 'which', '--toolchain', '1.94.0', 'rustfmt'])

    def test_absent_rustfmt_component_fails_without_a_fallback_command(self):
        with patch.object(codegen, 'output', side_effect=subprocess.CalledProcessError(
                1, ['rustup', 'which'])) as command:
            with self.assertRaises(subprocess.CalledProcessError):
                codegen.pinned_rustfmt()
            self.assertEqual(command.call_count, 1)

    def test_selected_formatter_environment_is_child_only(self):
        with tempfile.TemporaryDirectory() as tmp:
            formatter = Path(tmp) / 'pinned-bin/rustfmt'
            formatter.parent.mkdir()
            formatter.write_bytes(b'fixture')
            original = {'PATH': 'other-bin', 'RUSTUP_TOOLCHAIN': 'stable'}
            with patch.object(codegen, 'output', return_value=str(formatter)):
                selected = codegen.pinned_rustfmt()
            env = codegen.generator_environment(selected, original)
            self.assertEqual(original, {'PATH': 'other-bin', 'RUSTUP_TOOLCHAIN': 'stable'})
            self.assertEqual(env['PATH'].split(os.pathsep)[0], str(formatter.parent))
            self.assertEqual(env['RUSTFMT'], str(formatter))
            self.assertEqual(env['RUSTUP_TOOLCHAIN'], '1.94.0')

    def test_rust_name_patch_writes_lf_even_from_crlf_input(self):
        source = ('use block::Content; use block::Content;\n'
                  '    pub enum Content {\n    }\n'
                  'use metadata::Payload; use metadata::Payload;\n'
                  'pub mod metadata {\n    pub enum Payload {\n    }\n}\n')
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'generated.rs'
            path.write_bytes(source.replace('\n', '\r\n').encode())
            codegen.patch_rust(path)
            result = path.read_bytes()
            self.assertNotIn(b'\r', result)
            self.assertEqual(result.count(b'block::ContentOneOf'), 2)
            self.assertEqual(result.count(b'metadata::PayloadOneOf'), 2)
            self.assertIn(b'pub enum PayloadOneOf', result)

    def test_canonicalizes_fresh_output_but_compares_checked_in_bytes_exactly(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            fresh, existing = root / 'fresh', root / 'existing'
            fresh.mkdir(); existing.mkdir()
            (fresh / 'sample.dart').write_bytes(b'// generated\r\n')
            (fresh / 'keep.bin').write_bytes(b'\r\n')
            (existing / 'sample.dart').write_bytes(b'// generated\n')
            codegen.canonical_newlines(fresh)
            self.assertEqual(codegen.generated_files(fresh), codegen.generated_files(existing))
            self.assertEqual((fresh / 'keep.bin').read_bytes(), b'\r\n')
            (existing / 'sample.dart').write_bytes(b'// generated\r\n')
            self.assertNotEqual(codegen.generated_files(fresh), codegen.generated_files(existing))

    def test_plugin_launcher_matches_native_host(self):
        self.assertEqual(codegen.dart_plugin('nt').name, 'protoc-gen-dart.bat')
        self.assertEqual(codegen.dart_plugin('posix').name, 'protoc-gen-dart')
        batch = codegen.dart_plugin('nt').read_text()
        self.assertIn('cd /d "%~dp0..\\tool\\protocol_codegen" || exit /b 1', batch)
        self.assertIn('call dart run protoc_plugin:protoc_plugin %*', batch)
        self.assertIn('exit /b %ERRORLEVEL%', batch)


if __name__ == '__main__':
    unittest.main()
