import 'dart:io';

import 'repo_root.dart';

/// Runs `scripts/self_hosted_oracle_preflight.sh --quiet` from the repo root
/// and returns why the docker oracle prerequisites are unavailable, or null
/// when they are all in place. `dart test` runs from the package directory,
/// so the script path must not be resolved against the cwd.
Future<String?> oracleSkipReason() async {
  final result = await Process.run(
    'bash',
    ['scripts/self_hosted_oracle_preflight.sh', '--quiet'],
    workingDirectory: findRepoRoot(),
  );
  if (result.exitCode == 0) return null;
  final detail = result.stderr.toString().trim();
  return 'docker oracle prerequisites unavailable'
      '${detail.isEmpty ? '' : ': $detail'}';
}
