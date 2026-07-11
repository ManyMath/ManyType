@TestOn(
    'vm') // reads/writes real files under a temp base dir via dart:io: no browser filesystem equivalent used here
library;

import 'dart:io';

import 'package:manytype_cli/src/account_profile.dart' show AccountProfile;
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/account_sync_metadata.dart';
import 'package:manytype_cli/src/recovery_phrase_store.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  // Known BIP-39 test vector mnemonics (also used in identity_test.dart).
  const mnemonicA =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  const mnemonicB =
      'guilt universe cup credit night tissue pencil window brother ecology marriage over';

  group('AccountRegistry', () {
    late Directory tempBase;

    setUp(() async {
      tempBase = await Directory.systemTemp
          .createTemp('manytype_account_registry_test_');
      AccountRegistry.testBaseDirOverride = tempBase.path;
    });

    tearDown(() async {
      AccountRegistry.configureRecoveryPhraseStore(null);
      AccountRegistry.testBaseDirOverride = null;
      if (await tempBase.exists()) {
        await tempBase.delete(recursive: true);
      }
    });

    test('accountDir/accountConfigPath/accountDbPath are namespaced per id',
        () {
      final dirA = AccountRegistry.accountDir('idA');
      final dirB = AccountRegistry.accountDir('idB');
      expect(dirA, isNot(dirB));
      expect(AccountRegistry.accountConfigPath('idA'), startsWith(dirA));
      expect(AccountRegistry.accountDbPath('idA'), startsWith(dirA));
    });

    test(
        'createAccount writes a config.toml with the mnemonic under accounts/<id>/',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );

      final configFile = File(AccountRegistry.accountConfigPath(profile.id));
      expect(await configFile.exists(), isTrue);
      final content = await configFile.readAsString();
      expect(content, contains(mnemonicA));
    });

    test('two accounts created side by side do not cross-contaminate',
        () async {
      final profileA = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );
      final profileB = await AccountRegistry.createAccount(
        mnemonic: mnemonicB,
        displayName: 'personal',
      );

      expect(profileA.id, isNot(profileB.id));

      final contentA =
          await File(AccountRegistry.accountConfigPath(profileA.id))
              .readAsString();
      final contentB =
          await File(AccountRegistry.accountConfigPath(profileB.id))
              .readAsString();
      expect(contentA, contains(mnemonicA));
      expect(contentA, isNot(contains(mnemonicB)));
      expect(contentB, contains(mnemonicB));
      expect(contentB, isNot(contains(mnemonicA)));

      final accounts = await AccountRegistry.listAccounts();
      expect(
          accounts.map((a) => a.id), containsAll([profileA.id, profileB.id]));
    });

    test('registerAccount is idempotent for the same id', () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );
      await AccountRegistry.createAccount(
          mnemonic: mnemonicA, displayName: 'work-renamed');

      final accounts = await AccountRegistry.listAccounts();
      expect(accounts.where((a) => a.id == profile.id).length, 1);
      expect(accounts.firstWhere((a) => a.id == profile.id).displayName,
          'work-renamed');
    });

    test('createAccountIfNew never overwrites or creates excluded IDs',
        () async {
      final original = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'original',
      );
      final duplicate = await AccountRegistry.createAccountIfNew(
        mnemonic: mnemonicA,
        displayName: 'replacement',
      );

      expect(duplicate, isNull);
      final accounts = await AccountRegistry.listAccounts();
      expect(accounts.single.id, original.id);
      expect(accounts.single.displayName, 'original');

      final excludedId = await AccountProfile.deriveAccountId(mnemonicB);
      final excluded = await AccountRegistry.createAccountIfNew(
        mnemonic: mnemonicB,
        displayName: 'excluded',
        excludedAccountIds: <String>{excludedId},
      );
      expect(excluded, isNull);
      expect(await AccountRegistry.listAccounts(), hasLength(1));
    });

    test('starter-template pending state persists until explicitly cleared',
        () async {
      final profile = await AccountRegistry.createAccountIfNew(
        mnemonic: mnemonicA,
        displayName: 'demo',
        pendingStarterTemplate: true,
      );

      expect(profile, isNotNull);
      expect(
        (await AccountRegistry.listAccounts()).single.pendingStarterTemplate,
        isTrue,
      );

      await AccountRegistry.setStarterTemplatePending(profile!.id, false);

      expect(
        (await AccountRegistry.listAccounts()).single.pendingStarterTemplate,
        isFalse,
      );
    });

    test('current pointer defaults to null, then reflects setCurrentAccountId',
        () async {
      expect(await AccountRegistry.getCurrentAccountId(), isNull);

      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );
      await AccountRegistry.setCurrentAccountId(profile.id);

      expect(await AccountRegistry.getCurrentAccountId(), profile.id);
    });

    test('removeAccount deletes the on-disk directory and registry entry',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );
      expect(await Directory(AccountRegistry.accountDir(profile.id)).exists(),
          isTrue);

      await AccountRegistry.removeAccount(profile.id);

      expect(await Directory(AccountRegistry.accountDir(profile.id)).exists(),
          isFalse);
      final accounts = await AccountRegistry.listAccounts();
      expect(accounts.where((a) => a.id == profile.id), isEmpty);
    });

    test(
        'removeAccount clears the current pointer if it named the removed account',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );
      await AccountRegistry.setCurrentAccountId(profile.id);

      await AccountRegistry.removeAccount(profile.id);

      expect(await AccountRegistry.getCurrentAccountId(), isNull);
    });

    test('renameAccount updates the registered display name', () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );

      await AccountRegistry.renameAccount(profile.id, 'personal');

      final accounts = await AccountRegistry.listAccounts();
      expect(accounts.firstWhere((a) => a.id == profile.id).displayName,
          'personal');
    });

    test('renameAccount throws for an unknown id', () async {
      expect(
        () => AccountRegistry.renameAccount('does-not-exist', 'x'),
        throwsStateError,
      );
    });

    test('updateServerAddress rewrites config.toml, preserving the mnemonic',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );

      await AccountRegistry.updateServerAddress(profile.id, '10.0.0.5:33020');

      final config = await AccountRegistry.loadConfig(profile.id);
      expect(config.serverAddress, '10.0.0.5:33020');
      expect(config.mnemonic, mnemonicA);
    });

    test('updateServerAddress throws for an unknown id', () async {
      expect(
        () => AccountRegistry.updateServerAddress('does-not-exist', 'x'),
        throwsStateError,
      );
    });

    group('platform recovery phrase storage', () {
      late _MemoryRecoveryPhraseStore secureStore;

      setUp(() {
        secureStore = _MemoryRecoveryPhraseStore();
        AccountRegistry.configureRecoveryPhraseStore(secureStore);
      });

      test('new accounts keep the phrase out of config.toml', () async {
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'work',
        );

        final content = await File(
          AccountRegistry.accountConfigPath(profile.id),
        ).readAsString();
        expect(content, isNot(contains(mnemonicA)));
        expect(content, contains('recovery_phrase_store = "platform"'));
        expect(secureStore.values[profile.id], mnemonicA);
        expect(
            (await AccountRegistry.loadConfig(profile.id)).mnemonic, mnemonicA);
      });

      test('account secrets are isolated and forget deletes only its secret',
          () async {
        final profileA = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'work',
        );
        final profileB = await AccountRegistry.createAccount(
          mnemonic: mnemonicB,
          displayName: 'personal',
        );

        expect(secureStore.values[profileA.id], mnemonicA);
        expect(secureStore.values[profileB.id], mnemonicB);

        await AccountRegistry.removeAccount(profileA.id);

        expect(secureStore.values, isNot(contains(profileA.id)));
        expect(secureStore.values[profileB.id], mnemonicB);
        expect((await AccountRegistry.loadConfig(profileB.id)).mnemonic,
            mnemonicB);
      });

      test('legacy plaintext migrates on first load without changing identity',
          () async {
        AccountRegistry.configureRecoveryPhraseStore(null);
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'legacy',
        );
        final configPath = AccountRegistry.accountConfigPath(profile.id);
        expect(await File(configPath).readAsString(), contains(mnemonicA));

        AccountRegistry.configureRecoveryPhraseStore(secureStore);
        final config = await AccountRegistry.loadConfig(profile.id);

        expect(config.mnemonic, mnemonicA);
        expect(
            await AccountProfile.deriveAccountId(config.mnemonic), profile.id);
        expect(secureStore.values[profile.id], mnemonicA);
        final migrated = await File(configPath).readAsString();
        expect(migrated, isNot(contains(mnemonicA)));
        expect(migrated, contains('recovery_phrase_store = "platform"'));
      });

      test('secure-storage write failure leaves legacy plaintext untouched',
          () async {
        AccountRegistry.configureRecoveryPhraseStore(null);
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'legacy',
        );
        final configPath = AccountRegistry.accountConfigPath(profile.id);
        final original = await File(configPath).readAsString();

        secureStore.failWrites = true;
        AccountRegistry.configureRecoveryPhraseStore(secureStore);

        await expectLater(
          AccountRegistry.loadConfig(profile.id),
          throwsA(isA<StateError>()),
        );
        expect(await File(configPath).readAsString(), original);
        expect(secureStore.values, isNot(contains(profile.id)));
      });

      test('secure-storage creation failure leaves no partial account',
          () async {
        secureStore.failWrites = true;

        await expectLater(
          AccountRegistry.createAccount(
            mnemonic: mnemonicA,
            displayName: 'work',
          ),
          throwsA(isA<StateError>()),
        );

        final id = await AccountProfile.deriveAccountId(mnemonicA);
        expect(await AccountRegistry.listAccounts(), isEmpty);
        expect(await File(AccountRegistry.accountConfigPath(id)).exists(),
            isFalse);
      });

      test('secure-storage delete failure leaves the account and data intact',
          () async {
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'work',
        );
        final db = File(AccountRegistry.accountDbPath(profile.id));
        await db.writeAsString('workspace');
        secureStore.failDeletes = true;

        await expectLater(
          AccountRegistry.removeAccount(profile.id),
          throwsA(isA<StateError>()),
        );

        expect(await db.readAsString(), 'workspace');
        expect(
          (await AccountRegistry.listAccounts()).map((account) => account.id),
          contains(profile.id),
        );
        expect(secureStore.values[profile.id], mnemonicA);
      });

      test('a secure/plaintext mismatch refuses destructive migration',
          () async {
        AccountRegistry.configureRecoveryPhraseStore(null);
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'legacy',
        );
        final original = await File(
          AccountRegistry.accountConfigPath(profile.id),
        ).readAsString();
        secureStore.values[profile.id] = mnemonicB;
        AccountRegistry.configureRecoveryPhraseStore(secureStore);

        await expectLater(
          AccountRegistry.loadConfig(profile.id),
          throwsA(isA<StateError>()),
        );

        expect(
          await File(AccountRegistry.accountConfigPath(profile.id))
              .readAsString(),
          original,
        );
        expect(secureStore.values[profile.id], mnemonicB);
      });
    });

    test('sync metadata persists per account and forget removes it', () async {
      final profileA = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );
      final profileB = await AccountRegistry.createAccount(
        mnemonic: mnemonicB,
        displayName: 'personal',
      );
      final configuredAt = DateTime.utc(2026, 7, 13, 19);
      final syncedAt = configuredAt.add(const Duration(minutes: 5));
      await AccountRegistry.saveSyncMetadata(
        profileA.id,
        AccountSyncMetadata(
          networkConfigContent: 'network-a',
          configuredAt: configuredAt,
          lastSuccessfulSyncAt: syncedAt,
          pendingLocalChanges: true,
        ),
      );
      await AccountRegistry.saveSyncMetadata(
        profileB.id,
        AccountSyncMetadata(
          networkConfigContent: 'network-b',
          configuredAt: configuredAt,
        ),
      );

      final metadataA = await AccountRegistry.loadSyncMetadata(profileA.id);
      final metadataB = await AccountRegistry.loadSyncMetadata(profileB.id);
      expect(metadataA.networkConfigContent, 'network-a');
      expect(metadataA.lastSuccessfulSyncAt, syncedAt);
      expect(metadataA.pendingLocalChanges, isTrue);
      expect(metadataB.networkConfigContent, 'network-b');
      expect(metadataB.lastSuccessfulSyncAt, isNull);

      await AccountRegistry.removeAccount(profileA.id);
      final restoredA = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'restored',
      );
      expect(restoredA.id, profileA.id);
      expect(
        await AccountRegistry.loadSyncMetadata(restoredA.id),
        isA<AccountSyncMetadata>()
            .having((value) => value.isConfigured, 'configured', isFalse)
            .having(
              (value) => value.lastSuccessfulSyncAt,
              'last successful sync',
              isNull,
            ),
      );
      expect(
        (await AccountRegistry.loadSyncMetadata(profileB.id))
            .networkConfigContent,
        'network-b',
      );
    });

    group('migrateLegacyAccount', () {
      late File legacyConfigFile;
      late File legacyDbFile;

      setUp(() async {
        legacyConfigFile = File(p.join(tempBase.path, 'config.toml'));
        await legacyConfigFile.writeAsString(
          'mnemonic = "$mnemonicA"\nserver_address = "127.0.0.1:33020"\n',
        );
        legacyDbFile = File(p.join(tempBase.path, 'store.db'));
        await legacyDbFile.writeAsString('legacy db bytes');
      });

      test(
          'registers the legacy config/db paths without moving or copying them',
          () async {
        final profile = await AccountRegistry.migrateLegacyAccount(
          legacyConfigPath: legacyConfigFile.path,
          legacyDbPath: legacyDbFile.path,
          legacyMnemonic: mnemonicA,
        );

        expect(profile, isNotNull);
        expect(profile!.mnemonic, mnemonicA);

        // The original files are untouched: no copy/move happened.
        expect(await legacyConfigFile.exists(), isTrue);
        expect(await legacyDbFile.exists(), isTrue);
        expect(await legacyDbFile.readAsString(), 'legacy db bytes');

        final accounts = await AccountRegistry.listAccounts();
        final summary = accounts.firstWhere((a) => a.id == profile.id);
        expect(summary.configPathOverride, legacyConfigFile.path);
        expect(summary.dbPathOverride, legacyDbFile.path);
      });

      test('sets the migrated account as current', () async {
        final profile = await AccountRegistry.migrateLegacyAccount(
          legacyConfigPath: legacyConfigFile.path,
          legacyDbPath: legacyDbFile.path,
          legacyMnemonic: mnemonicA,
        );

        expect(await AccountRegistry.getCurrentAccountId(), profile!.id);
      });

      test('removeAccount deletes migrated config and database files',
          () async {
        final profile = await AccountRegistry.migrateLegacyAccount(
          legacyConfigPath: legacyConfigFile.path,
          legacyDbPath: legacyDbFile.path,
          legacyMnemonic: mnemonicA,
        );
        final wal = File('${legacyDbFile.path}-wal');
        final shm = File('${legacyDbFile.path}-shm');
        await wal.writeAsString('wal bytes');
        await shm.writeAsString('shm bytes');

        await AccountRegistry.removeAccount(profile!.id);

        expect(await legacyConfigFile.exists(), isFalse);
        expect(await legacyDbFile.exists(), isFalse);
        expect(await wal.exists(), isFalse);
        expect(await shm.exists(), isFalse);
        expect(await AccountRegistry.listAccounts(), isEmpty);
        expect(await AccountRegistry.getCurrentAccountId(), isNull);
      });

      test('is idempotent: a second call is a no-op once any account exists',
          () async {
        final first = await AccountRegistry.migrateLegacyAccount(
          legacyConfigPath: legacyConfigFile.path,
          legacyDbPath: legacyDbFile.path,
          legacyMnemonic: mnemonicA,
        );
        expect(first, isNotNull);

        final second = await AccountRegistry.migrateLegacyAccount(
          legacyConfigPath: legacyConfigFile.path,
          legacyDbPath: legacyDbFile.path,
          legacyMnemonic: mnemonicA,
        );
        expect(second, isNull);

        final accounts = await AccountRegistry.listAccounts();
        expect(accounts.length, 1);
      });

      test('is a no-op if an account already exists from account create',
          () async {
        await AccountRegistry.createAccount(
            mnemonic: mnemonicB, displayName: 'work');

        final migrated = await AccountRegistry.migrateLegacyAccount(
          legacyConfigPath: legacyConfigFile.path,
          legacyDbPath: legacyDbFile.path,
          legacyMnemonic: mnemonicA,
        );

        expect(migrated, isNull);
        final accounts = await AccountRegistry.listAccounts();
        expect(accounts.length, 1);
      });
    });
  });
}

class _MemoryRecoveryPhraseStore implements RecoveryPhraseStore {
  final Map<String, String> values = <String, String>{};
  bool failWrites = false;
  bool failDeletes = false;

  @override
  Future<void> delete(String accountId) async {
    if (failDeletes) throw StateError('injected secure delete failure');
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
