@TestOn(
    'vm') // shells out via Process.run to a cargo-build + bash harness against a live server (see file header)
library;

import 'dart:io';

import 'package:test/test.dart';

import 'support/oracle_preflight.dart';
import 'support/repo_root.dart';

void main() {
  test(
    'phase46 harness + verifier green',
    () async {
      if (Platform.environment['MANYTYPE_RUN_PHASE46'] != '1') {
        markTestSkipped(
          'set MANYTYPE_RUN_PHASE46=1 once '
          'the self-hosted oracle prerequisites are available',
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
        ['scripts/phase46_bounded_object_edit_harness.sh'],
        workingDirectory: repoRoot,
      );
      expect(
        harnessResult.exitCode,
        0,
        reason: 'phase46 harness failed:\n'
            'STDOUT:\n${harnessResult.stdout}\n'
            'STDERR:\n${harnessResult.stderr}',
      );
      expect(
        harnessResult.stdout.toString(),
        contains('phase46 harness: PASSED'),
      );

      final verifierResult = await Process.run(
        'python3',
        ['scripts/verify_phase46_artifacts.py'],
        workingDirectory: repoRoot,
      );
      expect(
        verifierResult.exitCode,
        0,
        reason: 'phase46 verifier failed:\n'
            'STDOUT:\n${verifierResult.stdout}\n'
            'STDERR:\n${verifierResult.stderr}',
      );
      expect(
        verifierResult.stdout.toString(),
        contains('phase46 artifacts: PASSED'),
      );
    },
    timeout: const Timeout(Duration(minutes: 20)),
    tags: ['slow', 'harness'],
  );
}
