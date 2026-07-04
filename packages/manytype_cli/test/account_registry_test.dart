@TestOn(
    'vm') // reads/writes real files under a temp base dir via dart:io: no browser filesystem equivalent used here
library;

import 'dart:io';

import 'package:manytype_cli/src/account_profile.dart' show AccountProfile;
import 'package:manytype_cli/src/account_registry.dart';
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
