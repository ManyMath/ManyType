@TestOn('vm')
library;

import 'dart:io';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/active_account.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/recovery_phrase_store.dart';
import 'package:test/test.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

void main() {
  late Directory tempBase;
  late _MemoryRecoveryPhraseStore secureStore;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp(
      'manytype_secure_legacy_startup_',
    );
    secureStore = _MemoryRecoveryPhraseStore();
    AccountRegistry.testBaseDirOverride = tempBase.path;
    AccountRegistry.configureRecoveryPhraseStore(secureStore);
    CliConfig.testConfigDirOverride = tempBase.path;
    await File(CliConfig.configPath).writeAsString(
      'mnemonic = "$_mnemonic"\n'
      'server_address = "127.0.0.1:33020"\n',
    );
    await File(CliConfig.dbPath).writeAsString('legacy workspace');
  });

  tearDown(() async {
    AccountRegistry.configureRecoveryPhraseStore(null);
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    if (await tempBase.exists()) await tempBase.delete(recursive: true);
  });

  test('first native resolution secures legacy plaintext before returning',
      () async {
    final active = await resolveActiveAccount();
    final accounts = await AccountRegistry.listAccounts();

    expect(accounts, hasLength(1));
    expect(active.config.mnemonic, _mnemonic);
    expect(active.dbPath, CliConfig.dbPath);
    expect(secureStore.values[accounts.single.id], _mnemonic);
    final migratedConfig = await File(CliConfig.configPath).readAsString();
    expect(migratedConfig, isNot(contains(_mnemonic)));
    expect(migratedConfig, contains('recovery_phrase_store = "platform"'));
    expect(await File(CliConfig.dbPath).readAsString(), 'legacy workspace');
    expect(await AccountRegistry.getCurrentAccountId(), accounts.single.id);
  });

  test('secure write failure preserves plaintext for a later retry', () async {
    secureStore.failWrites = true;
    final original = await File(CliConfig.configPath).readAsString();

    await expectLater(resolveActiveAccount(), throwsA(isA<StateError>()));

    expect(await File(CliConfig.configPath).readAsString(), original);
    expect(await File(CliConfig.dbPath).readAsString(), 'legacy workspace');
    expect(secureStore.values, isEmpty);
    expect(await AccountRegistry.listAccounts(), hasLength(1));
  });
}

class _MemoryRecoveryPhraseStore implements RecoveryPhraseStore {
  final Map<String, String> values = <String, String>{};
  bool failWrites = false;

  @override
  Future<void> delete(String accountId) async {
    values.remove(accountId);
  }

  @override
  Future<String?> read(String accountId) async => values[accountId];

  @override
  Future<void> write(String accountId, String recoveryPhrase) async {
    if (failWrites) throw StateError('injected secure write failure');
    values[accountId] = recoveryPhrase;
  }
}
