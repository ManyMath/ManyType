import 'dart:io';

/// Walks up from the current working directory until it finds the repo root
/// (the directory containing both `docker/` and `packages/`). Tests must not
/// assume `dart test` is invoked from the repo root: `melos run test` (and
/// running a single package's suite directly) sets the cwd to the package
/// directory instead.
String findRepoRoot() {
  Directory dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    if (Directory('${dir.path}/docker').existsSync() &&
        Directory('${dir.path}/packages').existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError('Could not locate repo root from ${Directory.current.path}');
}
