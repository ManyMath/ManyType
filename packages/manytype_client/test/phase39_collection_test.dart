@TestOn(
    'vm') // shells out via Process.run to a cargo-build + bash harness against a live server (see file header)
library;

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'phase39 harness + verifier green',
    () async {
      final repoRoot = _findRepoRoot();
      final artifactDir = await Directory.systemTemp.createTemp(
        'manytype_phase39_artifacts_',
      );
      addTearDown(() async {
        if (await artifactDir.exists()) {
          await artifactDir.delete(recursive: true);
        }
      });

      final harnessResult = await Process.run(
        'bash',
        ['scripts/phase39_collection_harness.sh'],
        workingDirectory: repoRoot,
        environment: {
          ...Platform.environment,
          'MANYTYPE_ARTIFACT_DIR': artifactDir.path,
        },
      );
      expect(
        harnessResult.exitCode,
        0,
        reason: 'phase39 harness failed:\n'
            'STDOUT:\n${harnessResult.stdout}\n'
            'STDERR:\n${harnessResult.stderr}',
      );
      expect(
        harnessResult.stdout.toString(),
        contains('phase39 harness: PASSED'),
        reason: 'harness did not print PASSED marker',
      );

      final verifierResult = await Process.run(
        'python3',
        [
          'scripts/verify_phase39_artifacts.py',
          '--scenario-a',
          '${artifactDir.path}/scenario_a_create_add.json',
          '--scenario-b',
          '${artifactDir.path}/scenario_b_remove.json',
          '--scenario-c',
          '${artifactDir.path}/scenario_c_move.json',
        ],
        workingDirectory: repoRoot,
      );
      expect(
        verifierResult.exitCode,
        0,
        reason: 'phase39 verifier failed:\n'
            'STDOUT:\n${verifierResult.stdout}\n'
            'STDERR:\n${verifierResult.stderr}',
      );
      expect(
        verifierResult.stdout.toString(),
        contains('phase39 artifacts: PASSED'),
      );
    },
    timeout: const Timeout(Duration(minutes: 10)),
    tags: ['slow', 'harness'],
  );
}

String _findRepoRoot() {
  Directory dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    if (File('${dir.path}/scripts/phase39_collection_harness.sh')
            .existsSync() &&
        Directory('${dir.path}/packages').existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError(
    'Could not locate repo root: '
    'scripts/phase39_collection_harness.sh not found '
    'walking up from ${Directory.current.path}',
  );
}
