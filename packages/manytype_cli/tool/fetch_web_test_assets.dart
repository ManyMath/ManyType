import 'dart:io';

import 'package:yaml/yaml.dart';

Future<void> main() async {
  final packageDir = Directory.current;
  final lockFile = _findPubspecLock(packageDir);
  if (lockFile == null) {
    stderr.writeln('Error: Could not find pubspec.lock');
    exit(1);
  }

  final lockContent = loadYaml(lockFile.readAsStringSync()) as YamlMap;
  final packages = lockContent['packages'] as YamlMap;
  final sqlite3Entry = packages['sqlite3'] as YamlMap?;
  if (sqlite3Entry == null) {
    stderr.writeln('Error: sqlite3 not found in pubspec.lock');
    exit(1);
  }
  final version = sqlite3Entry['version'] as String;
  print('sqlite3 version from pubspec.lock: $version');

  final assetsDir = Directory('${packageDir.path}/test/web_assets');
  if (!assetsDir.existsSync()) {
    assetsDir.createSync(recursive: true);
  }

  final wasmUrl =
      'https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-$version/sqlite3.wasm';
  print('Downloading sqlite3.wasm from $wasmUrl ...');
  final wasmFile = File('${assetsDir.path}/sqlite3.wasm');
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(wasmUrl));
    final response = await request.close();
    if (response.statusCode != 200) {
      stderr.writeln(
          'Error: Failed to download sqlite3.wasm (HTTP ${response.statusCode})');
      exit(1);
    }
    final bytes = await response
        .fold<List<int>>([], (prev, chunk) => prev..addAll(chunk));
    wasmFile.writeAsBytesSync(bytes);
    print('sqlite3.wasm downloaded (${bytes.length} bytes)');

    final sha256Result = await Process.run('sha256sum', [wasmFile.path]);
    final sha256 = (sha256Result.stdout as String).split(' ').first.trim();
    print('sha256: $sha256');

    print('Compiling drift_worker.dart.js ...');
    final compileResult = await Process.run(
      'dart',
      [
        'compile',
        'js',
        'tool/drift_web_worker.dart',
        '-o',
        'test/web_assets/drift_worker.dart.js',
      ],
      workingDirectory: packageDir.path,
    );
    if (compileResult.exitCode != 0) {
      stderr.writeln('Error: dart compile js failed');
      stderr.writeln(compileResult.stderr);
      exit(1);
    }
    stdout.write(compileResult.stdout);
    print('drift_worker.dart.js compiled successfully');

    final now = DateTime.now().toUtc().toIso8601String();
    final provenanceDir = Directory('${packageDir.path}/test/web_assets');
    if (!provenanceDir.existsSync()) {
      provenanceDir.createSync(recursive: true);
    }
    final provenancePath = '${provenanceDir.path}/asset-provenance.md';
    final provenance = StringBuffer()
      ..writeln('# Asset Provenance')
      ..writeln()
      ..writeln('## sqlite3.wasm')
      ..writeln('- **version**: $version')
      ..writeln('- **source**: $wasmUrl')
      ..writeln('- **sha256**: $sha256')
      ..writeln('- **size**: ${bytes.length} bytes')
      ..writeln('- **fetched**: $now')
      ..writeln()
      ..writeln('## drift_worker.dart.js')
      ..writeln(
          '- **compile command**: `dart compile js tool/drift_web_worker.dart -o test/web_assets/drift_worker.dart.js`')
      ..writeln('- **compiled**: $now')
      ..writeln('- **working directory**: packages/manytype_cli');
    File(provenancePath).writeAsStringSync(provenance.toString());
    print('Asset provenance written to $provenancePath');
  } finally {
    client.close();
  }
}

File? _findPubspecLock(Directory from) {
  var dir = from;
  for (var i = 0; i < 10; i++) {
    final candidate = File('${dir.path}/pubspec.lock');
    if (candidate.existsSync()) return candidate;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return null;
}
