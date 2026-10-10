@TestOn('vm')
library;

import 'dart:io';

import 'package:manytype_cli/src/account_profile.dart' show AccountProfile;
import 'package:manytype_cli/src/account_registry_native.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/recovery_phrase_store.dart';
import 'package:test/test.dart';

// A platform store such as the iOS Keychain keeps its items across an app
// uninstall, while the account files themselves are removed with the app.
const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

void main() {
  late Directory tempBase;
  late _MemoryRecoveryPhraseStore secureStore;
  late String accountId;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp(
      'manytype_account_reinstall_test_',
    );
    AccountRegistry.resetLifecycleTestState();
    AccountRegistry.testBaseDirOverride = tempBase.path;
    CliConfig.testConfigDirOverride = tempBase.path;
    secureStore = _MemoryRecoveryPhraseStore();
    AccountRegistry.configureRecoveryPhraseStore(secureStore);
    accountId = await AccountProfile.deriveAccountId(_mnemonic);
  });

  tearDown(() async {
    AccountRegistry.resetLifecycleTestState();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    if (await tempBase.exists()) await tempBase.delete(recursive: true);
  });

  test('importing after a reinstall adopts the matching surviving phrase',
      () async {
    secureStore.values[accountId] = _mnemonic;

    final profile = await AccountRegistry.createAccount(
      mnemonic: _mnemonic,
      displayName: 'restored',
    );

    expect(profile.id, accountId);
    expect(secureStore.values[accountId], _mnemonic);
    expect(secureStore.writeCalls, 0);
    expect(secureStore.deleteCalls, 0);
    expect((await AccountRegistry.loadConfig(accountId)).mnemonic, _mnemonic);
    expect(
        (await AccountRegistry.listAccounts()).single.displayName, 'restored');
  });

  test('a failed import keeps the surviving phrase it adopted', () async {
    secureStore.values[accountId] = _mnemonic;
    AccountRegistry.testBeforeAtomicReplaceHook = (path) async {
      if (path == AccountRegistry.registryPath) {
        throw StateError('injected registry replace failure');
      }
    };

    await expectLater(
      AccountRegistry.createAccount(
        mnemonic: _mnemonic,
        displayName: 'restored',
      ),
      throwsStateError,
    );

    expect(secureStore.values[accountId], _mnemonic);
    expect(secureStore.deleteCalls, 0);
    expect(await AccountRegistry.listAccounts(), isEmpty);
  });

  test('a different surviving phrase is never overwritten', () async {
    secureStore.values[accountId] = 'a different recovery phrase';

    await expectLater(
      AccountRegistry.createAccount(
        mnemonic: _mnemonic,
        displayName: 'restored',
      ),
      throwsStateError,
    );

    expect(secureStore.values[accountId], 'a different recovery phrase');
    expect(secureStore.writeCalls, 0);
    expect(secureStore.deleteCalls, 0);
    expect(await AccountRegistry.listAccounts(), isEmpty);
    expect(
      await File(AccountRegistry.accountConfigPath(accountId)).exists(),
      isFalse,
    );
  });
}

class _MemoryRecoveryPhraseStore implements RecoveryPhraseStore {
  final Map<String, String> values = <String, String>{};
  int writeCalls = 0;
  int deleteCalls = 0;

  @override
  Future<void> delete(String accountId) async {
    deleteCalls++;
    values.remove(accountId);
  }

  @override
  Future<String?> read(String accountId) async => values[accountId];

  @override
  Future<void> write(String accountId, String recoveryPhrase) async {
    writeCalls++;
    values[accountId] = recoveryPhrase;
  }
}
