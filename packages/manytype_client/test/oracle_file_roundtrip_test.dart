@TestOn(
    'vm') // shells out via Process.run to a bash harness + live docker oracle stack
library;

import 'dart:io';

import 'package:test/test.dart';

import 'support/repo_root.dart';

void main() {
  test('docker oracle round-trip uploads, downloads, and reopens from cache',
      () async {
    final rootDir = findRepoRoot();
    if (!await _oraclePrereqsAvailable(rootDir)) {
      markTestSkipped('docker oracle round-trip prerequisites unavailable');
      return;
    }

    final tempHome = await Directory.systemTemp.createTemp('manytype_oracle_');
    addTearDown(() => tempHome.delete(recursive: true));

    final payload = 'phase22-live-${DateTime.now().microsecondsSinceEpoch}';
    final payloadFile = File('${tempHome.path}/payload.txt');
    await payloadFile.writeAsString(payload);

    final env = {
      ...Platform.environment,
      'HOME': tempHome.path,
      'LD_LIBRARY_PATH':
          '$rootDir/rust/target/release${Platform.environment['LD_LIBRARY_PATH'] != null ? ':${Platform.environment['LD_LIBRARY_PATH']}' : ''}',
    };

    Future<ProcessResult> runCli(List<String> args) {
      return Process.run(
        'dart',
        ['run', 'packages/manytype_cli/bin/manytype.dart', ...args],
        workingDirectory: rootDir,
        environment: env,
      );
    }

    final init = await runCli(['init']);
    expect(init.exitCode, 0, reason: init.stderr.toString());

    final create = await runCli(['create', 'seed']);
    expect(create.exitCode, 0, reason: create.stderr.toString());

    final upload = await runCli([
      '--network-config',
      'docker/any-sync/etc/client.yml',
      'file-upload',
      '--file-id',
      'phase22-live',
      payloadFile.path,
    ]);
    expect(upload.exitCode, 0, reason: upload.stderr.toString());
    final uploadStdout = upload.stdout.toString();
    final cidMatch = RegExp(r'cid=([a-z0-9]+)').firstMatch(uploadStdout);
    expect(cidMatch, isNotNull, reason: uploadStdout);
    final cid = cidMatch!.group(1)!;

    final firstOpen = await runCli([
      '--network-config',
      'docker/any-sync/etc/client.yml',
      'file-open',
      '--file-id',
      'phase22-live',
      '--cid',
      cid,
    ]);
    expect(firstOpen.exitCode, 0, reason: firstOpen.stderr.toString());
    expect(firstOpen.stdout.toString(), contains('(network)'));

    final secondOpen = await runCli([
      '--network-config',
      'docker/any-sync/etc/client.yml',
      'file-open',
      '--file-id',
      'phase22-live',
      '--cid',
      cid,
    ]);
    expect(secondOpen.exitCode, 0, reason: secondOpen.stderr.toString());
    expect(secondOpen.stdout.toString(), contains('(cache)'));

    final outputMatch = RegExp(r'->\s+(.+)$', multiLine: true)
        .firstMatch(secondOpen.stdout.toString());
    expect(outputMatch, isNotNull, reason: secondOpen.stdout.toString());
    final outputFile = File(outputMatch!.group(1)!.trim());
    expect(await outputFile.exists(), isTrue);
    expect(await outputFile.readAsString(), payload);
  });
}

Future<bool> _oraclePrereqsAvailable(String rootDir) async {
  if (!await File('$rootDir/docker/any-sync/etc/client.yml').exists()) {
    return false;
  }
  if (!await File('$rootDir/rust/target/release/libmanytype_quic_ffi.so')
      .exists()) {
    return false;
  }

  final dockerPs = await Process.run(
    'docker',
    ['ps', '--format', '{{.Names}}'],
    workingDirectory: rootDir,
  );
  if (dockerPs.exitCode != 0) {
    return false;
  }
  return dockerPs.stdout
      .toString()
      .split('\n')
      .any((line) => line.trim() == 'any-sync-any-sync-filenode-1');
}
