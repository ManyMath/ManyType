import 'dart:typed_data';

import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:test/test.dart';

import 'web/account_registry_test_helpers.dart';
import 'web/web_db_test_helpers.dart';

class _FailingSyncService extends SyncService {
  @override
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
    String? networkConfigContent,
  }) {
    fail('sync should not be called');
  }
}

class _NoopSyncService extends SyncService {
  @override
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
    String? networkConfigContent,
  }) async {}
}

void main() {
  setUpAll(() async {
    await configureWebTestDatabaseAssets();
  });

  group('ManytypeSession', () {
    const testMnemonic =
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

    test('close is idempotent when explicit cleanup races disposal', () async {
      final session = ManytypeSession(
        db: ManytypeDatabase.forTesting(await openDatabaseForTesting()),
        config: CliConfig(
          mnemonic: testMnemonic,
          serverAddress: '127.0.0.1:0',
        ),
        identity: await Identity.fromMnemonic(testMnemonic),
      );

      final explicitClose = session.close();
      final disposalClose = session.close();

      expect(identical(explicitClose, disposalClose), isTrue);
      await explicitClose;
    });

    test('exposes a byte-based file-transfer facade with no CLI I/O', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      final session = ManytypeSession(
        db: ManytypeDatabase.forTesting(await openDatabaseForTesting()),
        config: CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:0'),
        identity: identity,
      );
      addTearDown(session.close);

      final payload = Uint8List.fromList('hello session'.codeUnits);
      final cid = await computeCid(payload);
      await session.db.cacheBlob(
        spaceId: identity.spaceId,
        fileId: 'file-1',
        cid: cid,
        bytes: payload,
      );

      // A cached CID resolves without needing a network config to actually
      // connect anywhere: the facade only reaches for the network on a
      // cache miss.
      final opened = await session.fileTransfer.open(
        networkConfigPath: 'unused-because-this-is-a-cache-hit',
        fileId: 'file-1',
        cid: cid,
      );

      expect(opened.fromCache, isTrue);
      expect(opened.bytes, payload);
    });

    test('exposes an object-listing facade with no CLI I/O', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      final session = ManytypeSession(
        db: ManytypeDatabase.forTesting(await openDatabaseForTesting()),
        config: CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:0'),
        identity: identity,
      );
      addTearDown(session.close);

      await createCommand('Session-listed object', session.db, session.config);

      final results = await session.objects.list(
        syncService: _FailingSyncService(),
      );

      expect(
          results.any((meta) => meta.name == 'Session-listed object'), isTrue);
    });

    // M016/scope-item-4: proves create/edit/read are usable end to end
    // through the public ManytypeSession API on both vm and (via
    // `dart test -p chrome`) web, with no CLI subprocess and no live
    // network (edit's mandatory sync step is stubbed out, same trick as
    // test/edit_test.dart's _NoopSyncService).
    test('create -> edit -> read round-trips through session.objects',
        () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      final session = ManytypeSession(
        db: ManytypeDatabase.forTesting(await openDatabaseForTesting()),
        config: CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:0'),
        identity: identity,
      );
      addTearDown(session.close);

      final created = await session.objects.create('Session object');

      await session.objects.edit(
        created.objectId,
        'Session object (edited)',
        syncService: _NoopSyncService(),
      );

      final read = await session.objects.read(objectId: created.objectId);

      expect(read.detail, isNotNull);
      expect(
        read.detail!.lines
            .any((line) => line.contains('Session object (edited)')),
        isTrue,
      );
    });

    test('session.objects.delete removes an object with no CLI I/O', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      final session = ManytypeSession(
        db: ManytypeDatabase.forTesting(await openDatabaseForTesting()),
        config: CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:0'),
        identity: identity,
      );
      addTearDown(session.close);

      final created = await session.objects.create('Session object to delete');

      await session.objects.delete(
        created.objectId,
        syncService: _NoopSyncService(),
      );

      final results = await session.objects.list(
        syncService: _FailingSyncService(),
      );
      expect(results.any((meta) => meta.id == created.objectId), isFalse);
    });

    test('session.accounts drives the account-profile lifecycle', () async {
      await resetAccountRegistryForTest(
        DateTime.now().microsecondsSinceEpoch.toString(),
      );

      final identity = await Identity.fromMnemonic(testMnemonic);
      final session = ManytypeSession(
        db: ManytypeDatabase.forTesting(await openDatabaseForTesting()),
        config: CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:0'),
        identity: identity,
      );
      addTearDown(session.close);

      final created = await session.accounts.create(name: 'work');
      expect(created.displayName, 'work');

      final listed = await session.accounts.list();
      expect(listed.map((a) => a.id), contains(created.id));

      final current = await session.accounts.current();
      expect(current.id, created.id);

      await session.accounts.remove(created.id);
      final afterRemoval = await session.accounts.list();
      expect(afterRemoval.where((a) => a.id == created.id), isEmpty);
    });
  });
}
