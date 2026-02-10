import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'phase63 harness + verifier green',
    () async {
      if (Platform.environment['MANYTYPE_RUN_PHASE63'] != '1') {
        print(
          'Skipping phase63 harness test: set MANYTYPE_RUN_PHASE63=1 once '
          'the self-hosted oracle prerequisites are available',
        );
        return;
      }
      if (!await _oraclePrereqsAvailable()) {
        print(
          'Skipping phase63 harness test: docker oracle prerequisites unavailable',
        );
        return;
      }

      final repoRoot = _findRepoRoot();

      final harnessResult = await Process.run(
        'bash',
        ['scripts/phase63_manytype_to_official_collection_harness.sh'],
        workingDirectory: repoRoot,
      );
      expect(
        harnessResult.exitCode,
        0,
        reason: 'phase63 harness failed:\n'
            'STDOUT:\n${harnessResult.stdout}\n'
            'STDERR:\n${harnessResult.stderr}',
      );
      expect(
        harnessResult.stdout.toString(),
        contains('phase63 harness: PASSED'),
      );

      final verifierResult = await Process.run(
        'python3',
        ['scripts/verify_phase63_self_hosted_collection_compat.py'],
        workingDirectory: repoRoot,
      );
      expect(
        verifierResult.exitCode,
        0,
        reason: 'phase63 verifier failed:\n'
            'STDOUT:\n${verifierResult.stdout}\n'
            'STDERR:\n${verifierResult.stderr}',
      );
      expect(
        verifierResult.stdout.toString(),
        contains('phase63 compatibility: PASSED'),
      );
    },
    timeout: const Timeout(Duration(minutes: 45)),
    tags: ['slow', 'harness'],
  );
}

Future<bool> _oraclePrereqsAvailable() async {
  final result = await Process.run(
    'bash',
    ['scripts/self_hosted_oracle_preflight.sh', '--quiet'],
  );
  return result.exitCode == 0;
}

String _findRepoRoot() {
  Directory dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    if (File('${dir.path}/scripts/phase63_manytype_to_official_collection_harness.sh')
            .existsSync() &&
        Directory('${dir.path}/packages').existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError(
    'Could not locate repo root - '
    'scripts/phase63_manytype_to_official_collection_harness.sh not found '
    'walking up from ${Directory.current.path}',
  );
}
