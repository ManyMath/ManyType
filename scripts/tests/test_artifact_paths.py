"""Captured artifact paths must be portable without changing native path rules."""
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import artifact_paths


class ArtifactPathsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='artifact-paths-')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name).resolve()
        root_patch = patch.object(artifact_paths, 'ROOT', self.root)
        root_patch.start()
        self.addCleanup(root_patch.stop)

    def test_foreign_absolute_capture_spellings(self):
        expected = self.root / 'test_vectors' / 'phase31' / 'capture.json'
        for captured in (
            '/home/user/old-checkout/test_vectors/phase31/capture.json',
            r'C:\Users\capturer\checkout\test_vectors\phase31\capture.json',
            'D:/old-checkout/test_vectors/phase31/capture.json',
            r'\\capture-server\share\checkout\test_vectors\phase31\capture.json',
            '//capture-server/share/checkout/test_vectors/phase31/capture.json',
        ):
            with self.subTest(captured=captured):
                self.assertEqual(artifact_paths.repo_path(captured), expected)

    def test_relative_paths_are_unchanged(self):
        for captured in ('test_vectors/capture.json', '../test_vectors/capture.json',
                         r'C:test_vectors\capture.json', r'\test_vectors\capture.json'):
            with self.subTest(captured=captured):
                self.assertEqual(artifact_paths.repo_path(captured), Path(captured))

    def test_native_paths_in_this_checkout_are_unchanged(self):
        # An existing alternative must not cause a native path to be remapped.
        (self.root / 'test_vectors').mkdir()
        (self.root / 'test_vectors' / 'capture.json').touch()
        captured = self.root / 'nested' / 'test_vectors' / 'capture.json'
        self.assertEqual(artifact_paths.repo_path(captured), captured)
        self.assertEqual(artifact_paths.repo_path(str(captured)), captured)

    def test_unknown_absolute_paths_are_unchanged(self):
        for captured in ('/foreign/capture.json', r'C:\foreign\capture.json',
                         '/foreign/not_test_vectors/capture.json'):
            with self.subTest(captured=captured):
                self.assertEqual(artifact_paths.repo_path(captured), Path(captured))

    def test_first_existing_candidate_wins(self):
        outer = self.root / 'scripts' / 'nested' / 'test_vectors' / 'capture.json'
        inner = self.root / 'test_vectors' / 'capture.json'
        for candidate in (outer, inner):
            candidate.parent.mkdir(parents=True)
            candidate.touch()
        captured = '/foreign/scripts/nested/test_vectors/capture.json'
        self.assertEqual(artifact_paths.repo_path(captured), outer)
        outer.unlink()
        self.assertEqual(artifact_paths.repo_path(captured), inner)

    def test_missing_candidates_use_deepest_repo_directory(self):
        captured = r'C:\foreign\scripts\nested\test_vectors\missing.json'
        self.assertEqual(artifact_paths.repo_path(captured),
                         self.root / 'test_vectors' / 'missing.json')


if __name__ == '__main__':
    unittest.main()
