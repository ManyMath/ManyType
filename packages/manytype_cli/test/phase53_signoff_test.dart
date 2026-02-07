import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'phase53 harness + verifier green',
    () async {
      if (Platform.environment['MANYTYPE_RUN_PHASE53'] != '1') {
        print(
          'Skipping phase53 harness test: set MANYTYPE_RUN_PHASE53=1 once '
          'the sign-off prerequisites are available',
        );
        return;
      }
      if (!await _oraclePrereqsAvailable()) {
        print(
          'Skipping phase53 harness test: docker oracle prerequisites unavailable',
        );
        return;
      }

      final repoRoot = _findRepoRoot();

      final harnessResult = await Process.run(
        'bash',
        ['scripts/phase53_regression_lock_harness.sh'],
        workingDirectory: repoRoot,
      );
      expect(
        harnessResult.exitCode,
        0,
        reason: 'phase53 harness failed:\n'
            'STDOUT:\n${harnessResult.stdout}\n'
            'STDERR:\n${harnessResult.stderr}',
      );
      expect(
        harnessResult.stdout.toString(),
        contains('phase53 harness: PASSED'),
      );

      final verifierResult = await Process.run(
        'python3',
        ['scripts/verify_phase53_signoff.py'],
        workingDirectory: repoRoot,
      );
      expect(
        verifierResult.exitCode,
        0,
        reason: 'phase53 verifier failed:\n'
            'STDOUT:\n${verifierResult.stdout}\n'
            'STDERR:\n${verifierResult.stderr}',
      );
      expect(
        verifierResult.stdout.toString(),
        contains('phase53 signoff: PASSED'),
      );
    },
    timeout: const Timeout(Duration(minutes: 90)),
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
    if (File('${dir.path}/scripts/phase53_regression_lock_harness.sh')
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
    'scripts/phase53_regression_lock_harness.sh not found '
    'walking up from ${Directory.current.path}',
  );
}
