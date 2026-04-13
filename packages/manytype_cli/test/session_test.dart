import 'dart:typed_data';

import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:test/test.dart';

import 'web/web_db_test_helpers.dart';

class _FailingSyncService extends SyncService {
  @override
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
  }) {
    fail('sync should not be called');
  }
}

void main() {
  setUpAll(() async {
    await configureWebTestDatabaseAssets();
  });

  group('ManytypeSession', () {
    const testMnemonic =
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

    test('exposes a byte-based file-transfer facade with no CLI I/O',
        () async {
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

      expect(results.any((meta) => meta.name == 'Session-listed object'), isTrue);
    });
  });
}
