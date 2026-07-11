@TestOn(
    'vm') // reads/writes real files under a temp base dir via dart:io: no browser filesystem equivalent used here
library;

import 'dart:io';
import 'dart:convert';

import 'package:manytype_cli/src/account_profile.dart' show AccountProfile;
import 'package:manytype_cli/src/account_registry_native.dart';
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
      AccountRegistry.resetLifecycleTestState();
      AccountRegistry.testBaseDirOverride = tempBase.path;
    });

    tearDown(() async {
      AccountRegistry.configureRecoveryPhraseStore(null);
      AccountRegistry.resetLifecycleTestState();
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

    test('duplicate create fails without rewriting existing resources',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'original',
      );
      final config = File(AccountRegistry.accountConfigPath(profile.id));
      final database = File(AccountRegistry.accountDbPath(profile.id));
      await database.writeAsString('existing workspace');
      final originalConfig = await config.readAsString();

      await expectLater(
        AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'replacement',
        ),
        throwsStateError,
      );

      final accounts = await AccountRegistry.listAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.single.displayName, 'original');
      expect(await config.readAsString(), originalConfig);
      expect(await database.readAsString(), 'existing workspace');
    });

    test('orphaned account storage is never overwritten by create', () async {
      final id = await AccountProfile.deriveAccountId(mnemonicA);
      final config = File(AccountRegistry.accountConfigPath(id));
      await config.parent.create(recursive: true);
      await config.writeAsString('preserve me');

      await expectLater(
        AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'replacement',
        ),
        throwsStateError,
      );

      expect(await config.readAsString(), 'preserve me');
      expect(await AccountRegistry.listAccounts(), isEmpty);
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

    test('registry replacement failure preserves the previous complete file',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'original',
      );
      final before = await File(AccountRegistry.registryPath).readAsString();
      var injected = false;
      AccountRegistry.testBeforeAtomicReplaceHook = (path) async {
        if (!injected && path == AccountRegistry.registryPath) {
          injected = true;
          throw StateError('injected registry replace failure');
        }
      };

      await expectLater(
        AccountRegistry.renameAccount(profile.id, 'replacement'),
        throwsStateError,
      );
      AccountRegistry.testBeforeAtomicReplaceHook = null;

      expect(await File(AccountRegistry.registryPath).readAsString(), before);
      expect((await AccountRegistry.listAccounts()).single.displayName,
          'original');
    });

    test('current-pointer replacement failure preserves the prior selection',
        () async {
      final profileA = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );
      final profileB = await AccountRegistry.createAccount(
        mnemonic: mnemonicB,
        displayName: 'personal',
      );
      await AccountRegistry.setCurrentAccountId(profileA.id);
      var injected = false;
      AccountRegistry.testBeforeAtomicReplaceHook = (path) async {
        if (!injected && path == AccountRegistry.currentPath) {
          injected = true;
          throw StateError('injected current replace failure');
        }
      };

      await expectLater(
        AccountRegistry.setCurrentAccountId(profileB.id),
        throwsStateError,
      );
      AccountRegistry.testBeforeAtomicReplaceHook = null;

      expect(await AccountRegistry.getCurrentAccountId(), profileA.id);
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

      test('write-then-fail migration rolls back the new secure copy',
          () async {
        AccountRegistry.configureRecoveryPhraseStore(null);
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'legacy',
        );
        final configPath = AccountRegistry.accountConfigPath(profile.id);
        final original = await File(configPath).readAsString();

        secureStore.writeThenFail = true;
        AccountRegistry.configureRecoveryPhraseStore(secureStore);

        await expectLater(
          AccountRegistry.loadConfig(profile.id),
          throwsA(isA<StateError>()),
        );
        expect(await File(configPath).readAsString(), original);
        expect(secureStore.values, isNot(contains(profile.id)));
        expect(secureStore.deleteCalls, 1);
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

      test('write-then-fail creation removes the newly persisted secret',
          () async {
        secureStore.writeThenFail = true;

        await expectLater(
          AccountRegistry.createAccount(
            mnemonic: mnemonicA,
            displayName: 'work',
          ),
          throwsA(isA<StateError>()),
        );

        final id = await AccountProfile.deriveAccountId(mnemonicA);
        expect(secureStore.values, isNot(contains(id)));
        expect(secureStore.deleteCalls, 1);
        expect(await AccountRegistry.listAccounts(), isEmpty);
        expect(
            await Directory(AccountRegistry.accountDir(id)).exists(), isFalse);
      });

      test('duplicate secure create preserves secret, config, and database',
          () async {
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'original',
        );
        final config = File(AccountRegistry.accountConfigPath(profile.id));
        final database = File(AccountRegistry.accountDbPath(profile.id));
        await database.writeAsString('existing workspace');
        final originalConfig = await config.readAsString();

        await expectLater(
          AccountRegistry.createAccount(
            mnemonic: mnemonicA,
            displayName: 'replacement',
          ),
          throwsStateError,
        );

        expect(secureStore.values[profile.id], mnemonicA);
        expect(secureStore.deleteCalls, 0);
        expect(await config.readAsString(), originalConfig);
        expect(await database.readAsString(), 'existing workspace');
        expect((await AccountRegistry.listAccounts()).single.displayName,
            'original');
      });

      test('concurrent duplicate creates serialize before resource preflight',
          () async {
        Future<Object> capture(Future<AccountProfile> future) {
          return future.then<Object>(
            (value) => value,
            onError: (Object error) => error,
          );
        }

        final outcomes = await Future.wait<Object>(<Future<Object>>[
          capture(AccountRegistry.createAccount(
            mnemonic: mnemonicA,
            displayName: 'first',
          )),
          capture(AccountRegistry.createAccount(
            mnemonic: mnemonicA,
            displayName: 'second',
          )),
        ]);

        final profile = outcomes.whereType<AccountProfile>().single;
        expect(outcomes.whereType<StateError>(), hasLength(1));
        expect((await AccountRegistry.listAccounts()).single.displayName,
            profile.displayName);
        expect(secureStore.values[profile.id], mnemonicA);
        expect(secureStore.deleteCalls, 0);
      });

      test('concurrent remove then recreate observes lifecycle call order',
          () async {
        final original = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'original',
        );
        final database = File(AccountRegistry.accountDbPath(original.id));
        await database.writeAsString('old workspace');

        final removal = AccountRegistry.removeAccount(original.id);
        final recreation = AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'recreated',
        );

        await removal;
        final recreated = await recreation;
        expect(recreated.id, original.id);
        expect((await AccountRegistry.listAccounts()).single.displayName,
            'recreated');
        expect(await database.exists(), isFalse);
        expect(secureStore.values[recreated.id], mnemonicA);
        expect(secureStore.deleteCalls, 1);
      });

      test('preexisting staged data aborts removal before intent or mutation',
          () async {
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'work',
        );
        await AccountRegistry.setCurrentAccountId(profile.id);
        final config = File(AccountRegistry.accountConfigPath(profile.id));
        final database = File(AccountRegistry.accountDbPath(profile.id));
        await database.writeAsString('workspace');
        final journal =
            File(AccountRegistry.accountRemovalJournalPath(profile.id));
        final stagedDirectory = Directory(
          p.join(journal.parent.path, 'account-data'),
        );
        await stagedDirectory.create(recursive: true);
        final staleMarker = File(p.join(stagedDirectory.path, 'stale'));
        await staleMarker.writeAsString('preserve stale data');

        await expectLater(
          AccountRegistry.removeAccount(profile.id),
          throwsStateError,
        );

        expect(await journal.exists(), isFalse);
        expect(await config.exists(), isTrue);
        expect(await database.readAsString(), 'workspace');
        expect(await staleMarker.readAsString(), 'preserve stale data');
        expect(
            await File(AccountRegistry.currentPath).readAsString(), profile.id);
        expect(secureStore.values[profile.id], mnemonicA);
      });

      test('no-store process cannot begin removing a platform-owned account',
          () async {
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'work',
        );
        await AccountRegistry.setCurrentAccountId(profile.id);
        final config = File(AccountRegistry.accountConfigPath(profile.id));
        final database = File(AccountRegistry.accountDbPath(profile.id));
        await database.writeAsString('workspace');
        AccountRegistry.configureRecoveryPhraseStore(null);

        await expectLater(
          AccountRegistry.removeAccount(profile.id),
          throwsStateError,
        );

        expect(await config.exists(), isTrue);
        expect(await database.readAsString(), 'workspace');
        expect(
            await File(AccountRegistry.currentPath).readAsString(), profile.id);
        expect(secureStore.values[profile.id], mnemonicA);
        expect(
          await File(
            AccountRegistry.accountRemovalJournalPath(profile.id),
          ).exists(),
          isFalse,
        );
        AccountRegistry.configureRecoveryPhraseStore(secureStore);
        expect((await AccountRegistry.listAccounts()).single.id, profile.id);
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

      test('delete-success-then-throw is recognized as a committed removal',
          () async {
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'work',
        );
        await AccountRegistry.setCurrentAccountId(profile.id);
        final database = File(AccountRegistry.accountDbPath(profile.id));
        await database.writeAsString('workspace');
        secureStore.deleteThenFail = true;

        await AccountRegistry.removeAccount(profile.id);

        expect(await AccountRegistry.listAccounts(), isEmpty);
        expect(await AccountRegistry.getCurrentAccountId(), isNull);
        expect(await database.exists(), isFalse);
        expect(secureStore.values, isNot(contains(profile.id)));
        expect(secureStore.deleteCalls, 1);
        expect(
          await File(
            AccountRegistry.accountRemovalJournalPath(profile.id),
          ).exists(),
          isFalse,
        );
      });

      test('tampered recovery staging path is rejected without touching data',
          () async {
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'work',
        );
        await AccountRegistry.setCurrentAccountId(profile.id);
        final config = File(AccountRegistry.accountConfigPath(profile.id));
        final database = File(AccountRegistry.accountDbPath(profile.id));
        await database.writeAsString('workspace');
        AccountRegistry.testAccountRemovalStageHook = (stage) async {
          if (stage == AccountRemovalStage.intentPersisted) {
            throw const AccountRemovalInterruption(
              AccountRemovalStage.intentPersisted,
            );
          }
        };

        await expectLater(
          AccountRegistry.removeAccount(profile.id),
          throwsA(isA<AccountRemovalInterruption>()),
        );
        AccountRegistry.testAccountRemovalStageHook = null;
        final journal =
            File(AccountRegistry.accountRemovalJournalPath(profile.id));
        final decoded =
            jsonDecode(await journal.readAsString()) as Map<String, dynamic>;
        final entries = decoded['entries']! as List<dynamic>;
        (entries.first as Map<String, dynamic>)['stagedPath'] =
            p.join(tempBase.path, 'attacker-controlled-stage');
        await journal.writeAsString(jsonEncode(decoded), flush: true);

        await expectLater(AccountRegistry.listAccounts(), throwsStateError);

        expect(await config.exists(), isTrue);
        expect(await database.readAsString(), 'workspace');
        expect(
            await File(AccountRegistry.currentPath).readAsString(), profile.id);
        expect(secureStore.values[profile.id], mnemonicA);
        expect(
          await Directory(
            p.join(tempBase.path, 'attacker-controlled-stage'),
          ).exists(),
          isFalse,
        );
      });

      test('relocated recovery journal is rejected without touching data',
          () async {
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'work',
        );
        final database = File(AccountRegistry.accountDbPath(profile.id));
        await database.writeAsString('workspace');
        AccountRegistry.testAccountRemovalStageHook = (stage) async {
          if (stage == AccountRemovalStage.intentPersisted) {
            throw const AccountRemovalInterruption(
              AccountRemovalStage.intentPersisted,
            );
          }
        };

        await expectLater(
          AccountRegistry.removeAccount(profile.id),
          throwsA(isA<AccountRemovalInterruption>()),
        );
        AccountRegistry.testAccountRemovalStageHook = null;
        final journal =
            File(AccountRegistry.accountRemovalJournalPath(profile.id));
        final relocatedDirectory = Directory(
          p.join(AccountRegistry.pendingRemovalsDir, 'relocated'),
        );
        await journal.parent.rename(relocatedDirectory.path);
        final relocatedJournal = File(
          p.join(relocatedDirectory.path, 'intent.json'),
        );

        await expectLater(AccountRegistry.listAccounts(), throwsStateError);

        expect(await relocatedJournal.exists(), isTrue);
        expect(await database.readAsString(), 'workspace');
        expect(secureStore.values[profile.id], mnemonicA);
      });

      for (final stage in <AccountRemovalStage>[
        AccountRemovalStage.intentPersisted,
        AccountRemovalStage.dataStaged,
        AccountRemovalStage.registryUpdated,
        AccountRemovalStage.currentPointerUpdated,
      ]) {
        test('failure after ${stage.name} rolls back every account resource',
            () async {
          final profile = await AccountRegistry.createAccount(
            mnemonic: mnemonicA,
            displayName: 'work',
          );
          await AccountRegistry.setCurrentAccountId(profile.id);
          final database = File(AccountRegistry.accountDbPath(profile.id));
          await database.writeAsString('workspace');
          AccountRegistry.testAccountRemovalStageHook = (reached) async {
            if (reached == stage) {
              throw StateError('injected failure after ${stage.name}');
            }
          };

          await expectLater(
            AccountRegistry.removeAccount(profile.id),
            throwsStateError,
          );
          AccountRegistry.testAccountRemovalStageHook = null;

          expect(await database.readAsString(), 'workspace');
          expect(
            (await AccountRegistry.listAccounts()).map((account) => account.id),
            contains(profile.id),
          );
          expect(await AccountRegistry.getCurrentAccountId(), profile.id);
          expect(secureStore.values[profile.id], mnemonicA);
          expect(
            await File(
              AccountRegistry.accountRemovalJournalPath(profile.id),
            ).exists(),
            isFalse,
          );
        });
      }

      for (final stage in AccountRemovalStage.values) {
        test('restart resumes an interruption after ${stage.name}', () async {
          final profile = await AccountRegistry.createAccount(
            mnemonic: mnemonicA,
            displayName: 'work',
          );
          await AccountRegistry.setCurrentAccountId(profile.id);
          final database = File(AccountRegistry.accountDbPath(profile.id));
          await database.writeAsString('workspace');
          AccountRegistry.testAccountRemovalStageHook = (reached) async {
            if (reached == stage) {
              throw AccountRemovalInterruption(stage);
            }
          };

          await expectLater(
            AccountRegistry.removeAccount(profile.id),
            throwsA(isA<AccountRemovalInterruption>()),
          );
          AccountRegistry.testAccountRemovalStageHook = null;

          final journal = File(
            AccountRegistry.accountRemovalJournalPath(profile.id),
          );
          expect(await journal.exists(), isTrue);
          final journalContent = await journal.readAsString();
          expect(journalContent, isNot(contains(mnemonicA)));
          expect(journalContent, isNot(contains('mnemonic')));

          // A new process's first registry read resumes the durable intent.
          expect(await AccountRegistry.listAccounts(), isEmpty);
          expect(await AccountRegistry.getCurrentAccountId(), isNull);
          expect(secureStore.values, isNot(contains(profile.id)));
          expect(await database.exists(), isFalse);
          expect(await journal.exists(), isFalse);
        });
      }

      test(
          'restart finishes a crash after secret deletion but before commit marker',
          () async {
        final profile = await AccountRegistry.createAccount(
          mnemonic: mnemonicA,
          displayName: 'work',
        );
        await AccountRegistry.setCurrentAccountId(profile.id);
        final journalPath =
            AccountRegistry.accountRemovalJournalPath(profile.id);
        var journalWritesAfterCurrent = 0;
        AccountRegistry.testAccountRemovalStageHook = (stage) async {
          if (stage == AccountRemovalStage.currentPointerUpdated) {
            AccountRegistry.testBeforeAtomicReplaceHook = (path) async {
              if (path != journalPath) return;
              journalWritesAfterCurrent++;
              if (journalWritesAfterCurrent == 2) {
                throw const AccountRemovalInterruption(
                  AccountRemovalStage.securePhraseDeleted,
                );
              }
            };
          }
        };

        await expectLater(
          AccountRegistry.removeAccount(profile.id),
          throwsA(isA<AccountRemovalInterruption>()),
        );
        expect(secureStore.values, isNot(contains(profile.id)));
        expect(await File(journalPath).readAsString(), contains('committing'));
        AccountRegistry.testAccountRemovalStageHook = null;
        AccountRegistry.testBeforeAtomicReplaceHook = null;

        AccountRegistry.configureRecoveryPhraseStore(null);
        await expectLater(AccountRegistry.listAccounts(), throwsStateError);
        expect(await File(journalPath).readAsString(), contains('committing'));
        expect(
          await Directory(AccountRegistry.accountDir(profile.id)).exists(),
          isFalse,
        );
        expect(
          await Directory(
            p.join(File(journalPath).parent.path, 'account-data'),
          ).exists(),
          isTrue,
        );

        AccountRegistry.configureRecoveryPhraseStore(secureStore);

        expect(await AccountRegistry.listAccounts(), isEmpty);
        expect(await File(journalPath).exists(), isFalse);
        expect(secureStore.deleteCalls, 2);
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

      test('secure delete failure restores migrated files and sidecars',
          () async {
        final profile = await AccountRegistry.migrateLegacyAccount(
          legacyConfigPath: legacyConfigFile.path,
          legacyDbPath: legacyDbFile.path,
          legacyMnemonic: mnemonicA,
        );
        final secureStore = _MemoryRecoveryPhraseStore();
        AccountRegistry.configureRecoveryPhraseStore(secureStore);
        await AccountRegistry.loadConfig(profile!.id);
        final migratedConfig = await legacyConfigFile.readAsString();
        final wal = File('${legacyDbFile.path}-wal');
        await wal.writeAsString('wal bytes');
        secureStore.failDeletes = true;

        await expectLater(
          AccountRegistry.removeAccount(profile.id),
          throwsStateError,
        );

        expect(await legacyConfigFile.readAsString(), migratedConfig);
        expect(await legacyDbFile.readAsString(), 'legacy db bytes');
        expect(await wal.readAsString(), 'wal bytes');
        expect((await AccountRegistry.listAccounts()).single.id, profile.id);
        expect(await AccountRegistry.getCurrentAccountId(), profile.id);
        expect(secureStore.values[profile.id], mnemonicA);
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
  bool writeThenFail = false;
  bool failDeletes = false;
  bool deleteThenFail = false;
  int deleteCalls = 0;

  @override
  Future<void> delete(String accountId) async {
    deleteCalls++;
    if (failDeletes) throw StateError('injected secure delete failure');
    values.remove(accountId);
    if (deleteThenFail) {
      throw StateError('injected secure delete-after-removal failure');
    }
  }

  @override
  Future<String?> read(String accountId) async => values[accountId];

  @override
  Future<void> write(String accountId, String recoveryPhrase) async {
    if (failWrites) throw StateError('injected secure write failure');
    values[accountId] = recoveryPhrase;
    if (writeThenFail) {
      throw StateError('injected secure write-after-persist failure');
    }
  }
}
