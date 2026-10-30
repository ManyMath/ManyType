@TestOn(
    'vm') // shells out via Process.run to a cargo-build + bash harness against a live server (see file header)
library;

import 'dart:io';

import 'package:test/test.dart';

import 'support/oracle_preflight.dart';
import 'support/repo_root.dart';

void main() {
  test(
    'phase49 harness + verifier green',
    () async {
      if (Platform.environment['MANYTYPE_RUN_PHASE49'] != '1') {
        markTestSkipped(
          'set MANYTYPE_RUN_PHASE49=1 once '
          'the sign-off prerequisites are available',
        );
        return;
      }
      final skipReason = await oracleSkipReason();
      if (skipReason != null) {
        markTestSkipped(skipReason);
        return;
      }

      final repoRoot = findRepoRoot();

      final harnessResult = await Process.run(
        'bash',
        ['scripts/phase49_regression_lock_harness.sh'],
        workingDirectory: repoRoot,
      );
      expect(
        harnessResult.exitCode,
        0,
        reason: 'phase49 harness failed:\n'
            'STDOUT:\n${harnessResult.stdout}\n'
            'STDERR:\n${harnessResult.stderr}',
      );
      expect(
        harnessResult.stdout.toString(),
        contains('phase49 harness: PASSED'),
      );

      final verifierResult = await Process.run(
        'python3',
        ['scripts/verify_phase49_signoff.py'],
        workingDirectory: repoRoot,
      );
      expect(
        verifierResult.exitCode,
        0,
        reason: 'phase49 verifier failed:\n'
            'STDOUT:\n${verifierResult.stdout}\n'
            'STDERR:\n${verifierResult.stderr}',
      );
      expect(
        verifierResult.stdout.toString(),
        contains('phase49 signoff: PASSED'),
      );
    },
    timeout: const Timeout(Duration(minutes: 60)),
    tags: ['slow', 'harness'],
  );
}
