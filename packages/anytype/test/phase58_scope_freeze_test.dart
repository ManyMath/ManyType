@TestOn(
    'vm') // shells out via Process.run to a cargo-build + bash harness against a live server (see file header)
library;

import 'dart:io';

import 'package:test/test.dart';

import 'support/oracle_preflight.dart';
import 'support/repo_root.dart';

void main() {
  test(
    'phase58 harness + verifier green',
    () async {
      if (Platform.environment['MANYTYPE_RUN_PHASE58'] != '1') {
        markTestSkipped(
          'set MANYTYPE_RUN_PHASE58=1 once '
          'the oracle baseline prerequisites are available',
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
        ['scripts/phase58_scope_freeze_harness.sh'],
        workingDirectory: repoRoot,
      );
      expect(
        harnessResult.exitCode,
        0,
        reason: 'phase58 harness failed:\n'
            'STDOUT:\n${harnessResult.stdout}\n'
            'STDERR:\n${harnessResult.stderr}',
      );
      expect(
        harnessResult.stdout.toString(),
        contains('phase58 harness: PASSED'),
      );

      final verifierResult = await Process.run(
        'python3',
        ['scripts/verify_phase58_scope_freeze.py'],
        workingDirectory: repoRoot,
      );
      expect(
        verifierResult.exitCode,
        0,
        reason: 'phase58 verifier failed:\n'
            'STDOUT:\n${verifierResult.stdout}\n'
            'STDERR:\n${verifierResult.stderr}',
      );
      expect(
        verifierResult.stdout.toString(),
        contains('phase58 scope freeze: PASSED'),
      );
    },
    timeout: const Timeout(Duration(minutes: 15)),
    tags: ['slow', 'harness'],
  );
}
