@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/recovery_phrase_store.dart';

const _legacyMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

void main() {
  late Directory tempBase;
  late _MemoryRecoveryPhraseStore secureStore;
  late ProviderContainer container;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp(
      'manytype_legacy_app_startup_',
    );
    secureStore = _MemoryRecoveryPhraseStore();
    AccountRegistry.testBaseDirOverride = tempBase.path;
    AccountRegistry.configureRecoveryPhraseStore(secureStore);
    CliConfig.testConfigDirOverride = tempBase.path;
    await File(CliConfig.configPath).writeAsString(
      'mnemonic = "$_legacyMnemonic"\n'
      'server_address = "127.0.0.1:33020"\n',
    );
    await File(CliConfig.dbPath).writeAsString('legacy workspace');
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    AccountRegistry.configureRecoveryPhraseStore(null);
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    if (await tempBase.exists()) {
      await tempBase.delete(recursive: true);
    }
  });

  test(
    'initial account gate migrates and secures a legacy-only install',
    () async {
      expect(await AccountRegistry.listAccounts(), isEmpty);
      expect(await AccountRegistry.getCurrentAccountId(), isNull);

      final currentId = await container.read(currentAccountIdProvider.future);

      expect(currentId, isNotNull);
      expect(await AccountRegistry.getCurrentAccountId(), currentId);
      expect(await AccountRegistry.listAccounts(), hasLength(1));
      expect(secureStore.values[currentId], _legacyMnemonic);
      final migratedConfig = await File(CliConfig.configPath).readAsString();
      expect(migratedConfig, isNot(contains(_legacyMnemonic)));
      expect(migratedConfig, contains('recovery_phrase_store = "platform"'));
      expect(await File(CliConfig.dbPath).readAsString(), 'legacy workspace');
    },
  );
}

class _MemoryRecoveryPhraseStore implements RecoveryPhraseStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> delete(String accountId) async {
    values.remove(accountId);
  }

  @override
  Future<String?> read(String accountId) async => values[accountId];

  @override
  Future<void> write(String accountId, String recoveryPhrase) async {
    values[accountId] = recoveryPhrase;
  }
}
