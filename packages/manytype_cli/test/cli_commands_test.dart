@TestOn('vm')
library;

import 'dart:io';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/repo_root.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

/// Runs bin/manytype.dart as a subprocess against a throwaway HOME, so these
/// tests never see the real ~/.manytype.
void main() {
  late Directory buildDir;
  late String cliKernel;
  late Directory homeDir;
  late String manytypeDir;

  setUpAll(() async {
    buildDir = await Directory.systemTemp.createTemp('manytype_cli_kernel_');
    cliKernel = p.join(buildDir.path, 'manytype.dill');
    final compile = await Process.run(
      Platform.resolvedExecutable,
      [
        'compile',
        'kernel',
        '--verbosity=error',
        'packages/manytype_cli/bin/manytype.dart',
        '-o',
        cliKernel,
      ],
      workingDirectory: findRepoRoot(),
    );
    expect(compile.exitCode, 0, reason: '${compile.stdout}${compile.stderr}');
  });

  tearDownAll(() async {
    await buildDir.delete(recursive: true);
  });

  setUp(() async {
    homeDir = await Directory.systemTemp.createTemp('manytype_cli_home_');
    manytypeDir = p.join(homeDir.path, '.manytype');
    AccountRegistry.testBaseDirOverride = manytypeDir;
    CliConfig.testConfigDirOverride = manytypeDir;
  });

  tearDown(() async {
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await homeDir.delete(recursive: true);
  });

  Future<ProcessResult> cli(List<String> args) {
    final environment = Map<String, String>.of(Platform.environment)
      ..remove('MANYTYPE_ACCOUNT')
      ..['HOME'] = homeDir.path;
    return Process.run(
      Platform.resolvedExecutable,
      [cliKernel, ...args],
      environment: environment,
      includeParentEnvironment: false,
    );
  }

  Future<void> writeLegacyConfig() async {
    await Directory(manytypeDir).create(recursive: true);
    await File(p.join(manytypeDir, 'config.toml')).writeAsString(
      'mnemonic = "$_mnemonic"\nserver_address = "127.0.0.1:33020"\n',
    );
  }

  group('account', () {
    test('create registers a legacy install before adding a profile', () async {
      await writeLegacyConfig();

      final create = await cli(['account', 'create', '--name', 'work']);
      expect(create.exitCode, 0, reason: '${create.stderr}');
      final list = await cli(['account', 'list']);

      expect(list.exitCode, 0, reason: '${list.stderr}');
      final lines = list.stdout.toString().trim().split('\n');
      expect(lines, hasLength(2));
      expect(lines.first, startsWith('* default\t'));
      expect(lines.last, startsWith('  work\t'));
    });

    test('list shows a legacy install', () async {
      await writeLegacyConfig();

      final list = await cli(['account', 'list']);

      expect(list.exitCode, 0, reason: '${list.stderr}');
      expect(list.stdout.toString(), startsWith('* default\t'));
    });
  });
}
