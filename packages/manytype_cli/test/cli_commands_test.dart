@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart' show computeCid;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/repo_root.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

const _otherMnemonic =
    'guilt universe cup credit night tissue pencil window brother ecology '
    'marriage over';

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

  // A CLI that hangs after an error reports exit code -1.
  Future<ProcessResult> cli(List<String> args) async {
    final environment = Map<String, String>.of(Platform.environment)
      ..remove('MANYTYPE_ACCOUNT')
      ..['HOME'] = homeDir.path;
    final process = await Process.start(
      Platform.resolvedExecutable,
      [cliKernel, ...args],
      environment: environment,
      includeParentEnvironment: false,
    );
    final stdoutText = process.stdout.transform(utf8.decoder).join();
    final stderrText = process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode.timeout(
      const Duration(minutes: 1),
      onTimeout: () {
        process.kill();
        return -1;
      },
    );
    return ProcessResult(
      process.pid,
      exitCode,
      await stdoutText,
      await stderrText,
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

    test('current honours --account', () async {
      await AccountRegistry.createAccount(
        mnemonic: _mnemonic,
        displayName: 'work',
      );
      final home = await AccountRegistry.createAccount(
        mnemonic: _otherMnemonic,
        displayName: 'home',
      );
      final work = (await AccountRegistry.listAccounts()).first;
      await AccountRegistry.setCurrentAccountId(work.id);

      final result = await cli(['--account', 'home', 'account', 'current']);

      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect(result.stdout.toString().trim(), 'home\t${home.id}');
    });

    test('list shows a legacy install', () async {
      await writeLegacyConfig();

      final list = await cli(['account', 'list']);

      expect(list.exitCode, 0, reason: '${list.stderr}');
      expect(list.stdout.toString(), startsWith('* default\t'));
    });
  });

  group('edit', () {
    Future<ProcessResult> editRelation(String flag, String value) => cli([
          '--network-config',
          'unused.yml',
          'edit',
          '--id',
          'obj-1',
          '--relation',
          'done',
          flag,
          value,
        ]);

    test('rejects a --bool value other than true or false', () async {
      final result = await editRelation('--bool', 'yes');

      expect(result.exitCode, 64);
      expect(result.stderr.toString(), contains('--bool must be'));
    });

    test('accepts --bool case-insensitively', () async {
      final result = await editRelation('--bool', 'TRUE');

      expect(result.stderr.toString(), isNot(contains('--bool must be')));
    });

    test('rejects a non-integer --date before doing any work', () async {
      final result = await editRelation('--date', 'tomorrow');

      expect(result.exitCode, 64);
      expect(result.stderr.toString(), contains('--date must be'));
      expect(Directory(manytypeDir).existsSync(), isFalse);
    });
  });

  group('list', () {
    for (final where in ['done', '=true']) {
      test('rejects --where "$where"', () async {
        final result = await cli(['list', '--where', where]);

        expect(result.exitCode, 64);
        expect(result.stderr.toString(), contains('--where must be'));
      });
    }
  });

  group('errors', () {
    test('report an unknown option as a usage error', () async {
      final result = await cli(['list', '--bogus']);

      expect(result.exitCode, 64);
      expect(result.stderr.toString(), contains('--bogus'));
      expect(result.stderr.toString(), contains('Usage: manytype list'));
      expect(result.stderr.toString(), isNot(contains('#0')));
    });

    test('report invalid flag combinations as usage errors', () async {
      final result = await cli(['edit', '--id', 'obj-1']);

      expect(result.exitCode, 64);
      expect(result.stderr.toString(), contains('edit requires --text'));
      expect(result.stderr.toString(), contains('Usage: manytype edit'));
    });

    test('report command failures without a stack trace', () async {
      final result = await cli(['list']);

      expect(result.exitCode, 1);
      expect(result.stderr.toString(), startsWith('Error: Config not found'));
      expect(result.stderr.toString(), isNot(contains('#0')));
    });

    test('exit after a failure with the database open', () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: _mnemonic,
        displayName: 'work',
      );
      await AccountRegistry.setCurrentAccountId(profile.id);

      final result = await cli([
        '--network-config',
        'unused.yml',
        'edit',
        '--id',
        'missing-object',
        '--text',
        'hello',
      ]);

      expect(result.exitCode, 1, reason: '${result.stderr}');
      expect(result.stderr.toString(), contains('Object not found locally'));
    });
  });

  group('file-open', () {
    test('writes downloads under the active account', () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: _mnemonic,
        displayName: 'work',
      );
      await AccountRegistry.setCurrentAccountId(profile.id);
      final identity = await Identity.fromMnemonic(_mnemonic);
      final bytes = Uint8List.fromList(utf8.encode('cached blob'));
      final cid = await computeCid(bytes);
      final db = ManytypeDatabase(AccountRegistry.accountDbPath(profile.id));
      await db.cacheBlob(
        spaceId: identity.spaceId,
        fileId: 'file-1',
        cid: cid,
        bytes: bytes,
      );
      await db.close();

      final result = await cli([
        '--network-config',
        'unused.yml',
        'file-open',
        '--file-id',
        'file-1',
        '--cid',
        cid,
      ]);

      expect(result.exitCode, 0, reason: '${result.stderr}');
      final expected = CliConfig.downloadPath(
        'file-1',
        cid,
        downloadsDir: AccountRegistry.accountDownloadsDir(profile.id),
      );
      expect(result.stdout.toString(), contains('-> $expected'));
      expect(File(expected).readAsBytesSync(), bytes);
    });
  });
}
