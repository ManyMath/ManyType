@TestOn('browser')
library;

// M015/S04: web parity for the multi-account model: localStorage-backed
// registry plus per-account OPFS/IndexedDB database isolation, mirroring
// M014/S02's persistence_test.dart harness.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/wasm.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/store/database_web.dart' as database_web;
import 'package:sqlite3/wasm.dart';
import 'package:test/test.dart';

const _mnemonicA =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
const _mnemonicB =
    'guilt universe cup credit night tissue pencil window brother ecology marriage over';

late int _assetServerPort;
WasmSqlite3? _sqlite3;

Future<WasmSqlite3> _loadSqlite3() async {
  if (_sqlite3 != null) return _sqlite3!;
  final sqlite = await WasmSqlite3.loadFromUrl(
    Uri.parse('http://localhost:$_assetServerPort/sqlite3.wasm'),
  );
  _sqlite3 = sqlite;
  return sqlite;
}

Future<(QueryExecutor, IndexedDbFileSystem)> _openPersistent(
  String dbName, {
  bool freshSqliteRuntime = false,
}) async {
  final sqlite = freshSqliteRuntime
      ? await WasmSqlite3.loadFromUrl(
          Uri.parse('http://localhost:$_assetServerPort/sqlite3.wasm'),
        )
      : await _loadSqlite3();
  final idb = await IndexedDbFileSystem.open(dbName: dbName);
  sqlite.registerVirtualFileSystem(idb);
  final executor = WasmDatabase(
    sqlite3: sqlite,
    path: '/$dbName',
    fileSystem: idb,
  );
  return (executor, idb);
}

void main() {
  setUpAll(() async {
    final channel = spawnHybridUri('/test/web/asset_server.dart');
    _assetServerPort = (await channel.stream.first as num).toInt();
  });
  tearDown(() {
    database_web.webDatabaseDeleteOverride = null;
  });

  group('M015/S04 AccountRegistry (localStorage)', () {
    setUp(() {
      // Unique key prefix per test avoids cross-test localStorage bleed
      // within the same browser session (dart test -p chrome runs all
      // tests in one page context).
      AccountRegistry.keyPrefix =
          'manytype-s04-test-${DateTime.now().microsecondsSinceEpoch}';
      database_web.webDatabaseDeleteOverride = (_) async {};
    });

    test('createAccount registers a summary retrievable via listAccounts',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: _mnemonicA,
        displayName: 'work',
      );

      final accounts = await AccountRegistry.listAccounts();
      expect(accounts.map((a) => a.id), contains(profile.id));
      expect(
        accounts.firstWhere((a) => a.id == profile.id).displayName,
        'work',
      );
    });

    test('starter-template pending state survives a registry reload', () async {
      final profile = await AccountRegistry.createAccountIfNew(
        mnemonic: _mnemonicA,
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

    test(
        'two accounts created side by side do not cross-contaminate the registry',
        () async {
      final profileA = await AccountRegistry.createAccount(
        mnemonic: _mnemonicA,
        displayName: 'work',
      );
      final profileB = await AccountRegistry.createAccount(
        mnemonic: _mnemonicB,
        displayName: 'personal',
      );

      expect(profileA.id, isNot(profileB.id));
      final accounts = await AccountRegistry.listAccounts();
      expect(
          accounts.map((a) => a.id), containsAll([profileA.id, profileB.id]));
    });

    test('current pointer defaults to null, then reflects setCurrentAccountId',
        () async {
      expect(await AccountRegistry.getCurrentAccountId(), isNull);

      final profile = await AccountRegistry.createAccount(
        mnemonic: _mnemonicA,
        displayName: 'work',
      );
      await AccountRegistry.setCurrentAccountId(profile.id);

      expect(await AccountRegistry.getCurrentAccountId(), profile.id);
    });

    test('removeAccount clears the registry entry and current pointer',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: _mnemonicA,
        displayName: 'work',
      );
      await AccountRegistry.setCurrentAccountId(profile.id);

      await AccountRegistry.removeAccount(profile.id);

      final accounts = await AccountRegistry.listAccounts();
      expect(accounts.where((a) => a.id == profile.id), isEmpty);
      expect(await AccountRegistry.getCurrentAccountId(), isNull);
    });

    test('removeAccount deletes storage before registry and secret metadata',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: _mnemonicA,
        displayName: 'work',
      );
      await AccountRegistry.setCurrentAccountId(profile.id);
      String? deletedDatabase;
      database_web.webDatabaseDeleteOverride = (databaseName) async {
        deletedDatabase = databaseName;
        expect(
          (await AccountRegistry.listAccounts()).map((account) => account.id),
          contains(profile.id),
        );
        expect(
          (await AccountRegistry.loadConfig(profile.id)).mnemonic,
          _mnemonicA,
        );
      };

      await AccountRegistry.removeAccount(profile.id);

      expect(deletedDatabase, AccountRegistry.accountDbPath(profile.id));
      expect(await AccountRegistry.listAccounts(), isEmpty);
      expect(await AccountRegistry.getCurrentAccountId(), isNull);
      await expectLater(
        AccountRegistry.loadConfig(profile.id),
        throwsStateError,
      );
    });

    test('storage deletion failure leaves the account retryable', () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: _mnemonicA,
        displayName: 'work',
      );
      await AccountRegistry.setCurrentAccountId(profile.id);
      database_web.webDatabaseDeleteOverride = (_) async {
        throw StateError('injected blocked deletion');
      };

      await expectLater(
        AccountRegistry.removeAccount(profile.id),
        throwsStateError,
      );

      expect(
        (await AccountRegistry.listAccounts()).map((account) => account.id),
        contains(profile.id),
      );
      expect(await AccountRegistry.getCurrentAccountId(), profile.id);
      expect(
        (await AccountRegistry.loadConfig(profile.id)).mnemonic,
        _mnemonicA,
      );
    });

    test('sync metadata is account-isolated and removed on forget', () async {
      final profileA = await AccountRegistry.createAccount(
        mnemonic: _mnemonicA,
        displayName: 'work',
      );
      final profileB = await AccountRegistry.createAccount(
        mnemonic: _mnemonicB,
        displayName: 'personal',
      );
      final configuredAt = DateTime.utc(2026, 7, 13, 19);
      await AccountRegistry.saveSyncMetadata(
        profileA.id,
        AccountSyncMetadata(
          networkConfigContent: 'network-a',
          configuredAt: configuredAt,
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

      expect(
        (await AccountRegistry.loadSyncMetadata(profileA.id))
            .networkConfigContent,
        'network-a',
      );
      expect(
        (await AccountRegistry.loadSyncMetadata(profileB.id))
            .networkConfigContent,
        'network-b',
      );

      await AccountRegistry.removeAccount(profileA.id);
      final restored = await AccountRegistry.createAccount(
        mnemonic: _mnemonicA,
        displayName: 'restored',
      );
      expect(
        (await AccountRegistry.loadSyncMetadata(restored.id)).isConfigured,
        isFalse,
      );
      expect(
        (await AccountRegistry.loadSyncMetadata(profileB.id))
            .networkConfigContent,
        'network-b',
      );
    });
  });

  group(
    'M015/S04 per-account OPFS/IndexedDB database isolation',
    () {
      test(
          'two account profiles map to two separate, non-cross-contaminating databases',
          () async {
        AccountRegistry.keyPrefix =
            'manytype-s04-dbiso-${DateTime.now().microsecondsSinceEpoch}';

        final profileA = await AccountRegistry.createAccount(
          mnemonic: _mnemonicA,
          displayName: 'work',
        );
        final profileB = await AccountRegistry.createAccount(
          mnemonic: _mnemonicB,
          displayName: 'personal',
        );

        final dbNameA = AccountRegistry.accountDbPath(profileA.id);
        final dbNameB = AccountRegistry.accountDbPath(profileB.id);
        expect(dbNameA, isNot(dbNameB));

        final (execA, idbA) = await _openPersistent(dbNameA);
        final dbA = ManytypeDatabase.forTesting(execA);
        await dbA.insertObject('obj-account-a', 'space-a');

        final (execB, idbB) = await _openPersistent(dbNameB);
        final dbB = ManytypeDatabase.forTesting(execB);
        await dbB.insertObject('obj-account-b', 'space-b');

        // Account A's database must not see account B's object, and vice
        // versa: real cross-database isolation, not just distinct rows in
        // one shared store.
        final objectsInA = await dbA.getAllObjects();
        final objectsInB = await dbB.getAllObjects();
        expect(objectsInA.map((o) => o.id), equals(['obj-account-a']));
        expect(objectsInB.map((o) => o.id), equals(['obj-account-b']));

        await dbA.close();
        await idbA.close();
        await dbB.close();
        await idbB.close();
      });

      test('forget and reimport does not resurrect IndexedDB rows', () async {
        AccountRegistry.keyPrefix =
            'manytype-s04-forget-${DateTime.now().microsecondsSinceEpoch}';
        final profile = await AccountRegistry.createAccount(
          mnemonic: _mnemonicA,
          displayName: 'work',
        );
        final databaseName = AccountRegistry.accountDbPath(profile.id);
        final (executor, idb) = await _openPersistent(
          databaseName,
          freshSqliteRuntime: true,
        );
        final db = ManytypeDatabase.forTesting(executor);
        await db.insertObject('must-not-return', 'space-a');
        await db.close();
        await idb.close();

        database_web.webDatabaseDeleteOverride =
            IndexedDbFileSystem.deleteDatabase;
        await AccountRegistry.removeAccount(profile.id);
        final restored = await AccountRegistry.createAccount(
          mnemonic: _mnemonicA,
          displayName: 'restored',
        );
        expect(restored.id, profile.id);

        final restoredIdb = await IndexedDbFileSystem.open(
          dbName: AccountRegistry.accountDbPath(restored.id),
        );
        expect(
          restoredIdb.xAccess('/$databaseName', 0),
          0,
          reason: 'the database file must not survive forget + reimport',
        );
        await restoredIdb.close();
      });
    },
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
