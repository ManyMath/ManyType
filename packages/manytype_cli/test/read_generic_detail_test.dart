import 'dart:async';
import 'dart:typed_data';

import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/commands/read.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:test/test.dart';

import 'web/web_db_test_helpers.dart';

void main() {
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  late ManytypeDatabase db;
  late CliConfig config;

  setUpAll(() async {
    await configureWebTestDatabaseAssets();
  });

  setUp(() async {
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
    config =
        CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:33020');
  });

  tearDown(() async {
    await db.close();
  });

  test('read renders generic string and string-list details', () async {
    await createCommand('Readable object', db, config);

    final objectId = await _findObjectIdByName(db, config, 'Readable object');
    expect(objectId, isNotNull);

    await editCommand(
      objectId!,
      null,
      db,
      config,
      networkConfigPath: 'unused-network.yml',
      syncService: _NoopSyncService(),
      relationKey: 'description',
      stringValue: 'Readable description',
    );
    await editCommand(
      objectId,
      null,
      db,
      config,
      networkConfigPath: 'unused-network.yml',
      syncService: _NoopSyncService(),
      relationKey: 'featuredRelations',
      stringListValue: const ['description', 'sourceObject'],
    );

    final result = await readCommand(db, config, objectId: objectId);
    final output = result.detail!.lines.join('\n');

    expect(output, contains('[description] Readable description'));
    expect(
      output,
      contains('[featuredRelations] description, sourceObject'),
    );
  });
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

Future<String?> _findObjectIdByName(
  ManytypeDatabase db,
  CliConfig config,
  String expectedName,
) async {
  for (final object in await db.getAllObjects()) {
    try {
      final replayed = await _replayObject(db, config, object.id);
      if (replayed.snapshot.details.fields['name']?.stringValue ==
          expectedName) {
        return object.id;
      }
    } on StateError {
      continue;
    }
  }
  return null;
}

Future<ReplayedObjectState> _replayObject(
  ManytypeDatabase db,
  CliConfig config,
  String objectId,
) async {
  final treeKey = await _treeKeyForObject(config, objectId);
  final rawTreeChanges = (await db.getChangesForObject(objectId))
      .map((change) => Uint8List.fromList(change.rawBytes))
      .toList(growable: false);
  return replayObjectState(
    rawTreeChanges: rawTreeChanges,
    treeKey: treeKey,
  );
}

Future<Uint8List> _treeKeyForObject(CliConfig config, String objectId) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  return deriveTreeKey(spaceKey, objectId);
}
