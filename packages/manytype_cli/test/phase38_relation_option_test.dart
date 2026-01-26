// Phase 38: STRelationOption trees + status/tag relation values
//
// Dart test per 38-CONTEXT D-17. Shells out to the two-home harness at
// `scripts/phase38_relation_option_harness.sh` + offline verifier at
// `scripts/verify_phase38_artifacts.py`.
//
// SLOW (~60-120s) because the harness builds `cargo build -p manytype_server`
// and runs three scenarios end-to-end against a live local server. Tagged
// `slow` + `harness` so default `dart test` runs remain fast; opt in with
// `dart test ... --tags slow` (or `--tags harness`).

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'phase38 harness + verifier green',
    () async {
      final repoRoot = _findRepoRoot();

      // 1. Run the two-home harness.
      final harnessResult = await Process.run(
        'bash',
        ['scripts/phase38_relation_option_harness.sh'],
        workingDirectory: repoRoot,
      );
      expect(
        harnessResult.exitCode,
        0,
        reason: 'phase38 harness failed:\n'
            'STDOUT:\n${harnessResult.stdout}\n'
            'STDERR:\n${harnessResult.stderr}',
      );
      expect(
        harnessResult.stdout.toString(),
        contains('phase38 harness: PASSED'),
        reason: 'harness did not print PASSED marker',
      );

      // 2. Run the offline verifier against the artifacts the harness wrote.
      final verifierResult = await Process.run(
        'python3',
        ['scripts/verify_phase38_artifacts.py'],
        workingDirectory: repoRoot,
      );
      expect(
        verifierResult.exitCode,
        0,
        reason: 'phase38 verifier failed:\n'
            'STDOUT:\n${verifierResult.stdout}\n'
            'STDERR:\n${verifierResult.stderr}',
      );
      expect(
        verifierResult.stdout.toString(),
        contains('phase38 artifacts: PASSED'),
      );
    },
    timeout: const Timeout(Duration(minutes: 10)),
    tags: ['slow', 'harness'],
  );
}

/// Walk up from the current working directory until we find the repo root
/// (the directory containing both `scripts/phase38_relation_option_harness.sh`
/// and `packages/`). Matches Phase 37's test helper philosophy.
String _findRepoRoot() {
  Directory dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    if (File(
              '${dir.path}/scripts/phase38_relation_option_harness.sh',
            ).existsSync() &&
        Directory('${dir.path}/packages').existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError(
    'Could not locate repo root: '
    'scripts/phase38_relation_option_harness.sh not found '
    'walking up from ${Directory.current.path}',
  );
}
