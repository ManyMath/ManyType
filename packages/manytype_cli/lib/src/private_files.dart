import 'dart:io';

/// Creates [path] and any missing parents. On Linux and macOS each directory
/// this call creates is restricted to its owner (0700).
Future<void> createPrivateDirectory(String path) async {
  final created = <String>[];
  var current = Directory(path).absolute;
  while (!await current.exists()) {
    created.add(current.path);
    final parent = current.parent;
    if (parent.path == current.path) break;
    current = parent;
  }
  if (created.isEmpty) return;
  await Directory(path).create(recursive: true);
  await _chmod('700', created);
}

/// Replaces [path] with [content] through a temporary file in the same
/// directory, creating the directory with [createPrivateDirectory] if needed.
///
/// On Linux and macOS the temporary file is restricted to its owner (0600)
/// before any content is written, so secrets such as a mnemonic never sit in
/// a file other users can read. [beforeReplace] runs after the temporary file
/// is flushed and before it replaces [path].
Future<void> writePrivateFileAtomically(
  String path,
  String content, {
  Future<void> Function(String path)? beforeReplace,
}) async {
  await createPrivateDirectory(File(path).parent.path);
  final temporary = File(
    '$path.tmp-${DateTime.now().microsecondsSinceEpoch}-$pid',
  );
  try {
    await temporary.create(exclusive: true);
    await _chmod('600', [temporary.path]);
    await temporary.writeAsString(content, flush: true);
    await beforeReplace?.call(path);
    await temporary.rename(path);
  } finally {
    if (await temporary.exists()) await temporary.delete();
  }
}

// dart:io has no chmod. Other platforms rely on their own per-user or per-app
// isolation, as does a host that cannot start a chmod process at all.
Future<void> _chmod(String mode, List<String> paths) async {
  if (!Platform.isLinux && !Platform.isMacOS) return;
  final ProcessResult result;
  try {
    result = await Process.run('chmod', ['--', mode, ...paths]);
  } on ProcessException {
    return;
  }
  if (result.exitCode != 0) {
    throw FileSystemException(
      'chmod $mode failed: ${result.stderr}'.trim(),
      paths.first,
    );
  }
}
