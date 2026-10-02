@TestOn('linux || mac-os')
library;

import 'dart:io';

import 'package:manytype_cli/src/account_registry_native.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/operator_flow_support.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

void main() {
  late Directory tempDir;
  late String baseDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manytype_private_files_');
    baseDir = p.join(tempDir.path, 'home', '.manytype');
    AccountRegistry.resetLifecycleTestState();
    AccountRegistry.testBaseDirOverride = baseDir;
    CliConfig.testConfigDirOverride = baseDir;
  });

  tearDown(() async {
    AccountRegistry.resetLifecycleTestState();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempDir.delete(recursive: true);
  });

  test('init creates an owner-only config dir and config file', () async {
    await CliConfig.initialize();

    expect(_mode(p.join(tempDir.path, 'home')), 0x1c0);
    expect(_mode(baseDir), 0x1c0);
    expect(_mode(CliConfig.configPath), 0x180);
  });

  test('account storage is owner-only', () async {
    final profile = await AccountRegistry.createAccount(
      mnemonic: _mnemonic,
      displayName: 'work',
    );
    await AccountRegistry.setCurrentAccountId(profile.id);

    expect(_mode(baseDir), 0x1c0);
    expect(_mode(AccountRegistry.accountsDir), 0x1c0);
    expect(_mode(AccountRegistry.accountDir(profile.id)), 0x1c0);
    expect(_mode(AccountRegistry.accountConfigPath(profile.id)), 0x180);
    expect(_mode(AccountRegistry.registryPath), 0x180);
    expect(_mode(AccountRegistry.currentPath), 0x180);
  });

  test('continuation state files are owner-only', () async {
    final statePath = p.join(tempDir.path, 'state.json');

    await writeJsonFile(statePath, {'mnemonic': _mnemonic});

    expect(_mode(statePath), 0x180);
    expect(await File(statePath).readAsString(), contains(_mnemonic));
  });
}

int _mode(String path) => FileStat.statSync(path).mode & 0x1ff;
