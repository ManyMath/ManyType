import 'dart:typed_data';

import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:test/test.dart';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, TreeChange;

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

  test('edit --text updates both object name and title block text', () async {
    await createCommand('Original title', db, config);

    final objectId = await _findObjectIdByName(db, config, 'Original title');
    expect(objectId, isNotNull);

    await editCommand(
      objectId!,
      'Updated title',
      db,
      config,
      networkConfigPath: 'unused-network.yml',
      syncService: _NoopSyncService(),
    );

    final replayed = await _replayObject(db, config, objectId);
    expect(replayed.snapshot.details.fields['name']?.stringValue,
        equals('Updated title'));

    final titleBlock = replayed.snapshot.blocks.firstWhere(
      (block) => block.id == 'title',
    );
    expect(titleBlock.hasText(), isTrue);
    expect(titleBlock.text.text, equals('Updated title'));

    final treeKey = await _treeKeyForObject(config, objectId);
    final changes = await db.getChangesForObject(objectId);
    expect(changes, hasLength(3));

    final rawTreeChange = RawTreeChange.fromBuffer(changes.last.rawBytes);
    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
    final decoded = await aesGcmDecrypt(
      treeKey,
      Uint8List.fromList(treeChange.changesData),
    );
    final change = changes_proto.Change.fromBuffer(decoded);

    expect(
      change.content.any(
        (content) =>
            content.hasDetailsSet() &&
            content.detailsSet.key == 'name' &&
            content.detailsSet.value.stringValue == 'Updated title',
      ),
      isTrue,
    );

    final titleUpdate = change.content
        .where((content) => content.hasBlockUpdate())
        .expand((content) => content.blockUpdate.events)
        .map(Event_Message.fromBuffer)
        .firstWhere(
          (event) =>
              event.hasBlockSetText() && event.blockSetText.id == 'title',
        );
    expect(titleUpdate.blockSetText.text.value, equals('Updated title'));
  });

  test('edit writes generic string details via detailsSet', () async {
    await createCommand('Object title', db, config);

    final objectId = await _findObjectIdByName(db, config, 'Object title');
    expect(objectId, isNotNull);

    await editCommand(
      objectId!,
      null,
      db,
      config,
      networkConfigPath: 'unused-network.yml',
      syncService: _NoopSyncService(),
      relationKey: 'description',
      stringValue: 'Phase 46 description',
    );

    final replayed = await _replayObject(db, config, objectId);
    expect(
      replayed.snapshot.details.fields['description']?.stringValue,
      equals('Phase 46 description'),
    );

    final treeKey = await _treeKeyForObject(config, objectId);
    final changes = await db.getChangesForObject(objectId);
    final rawTreeChange = RawTreeChange.fromBuffer(changes.last.rawBytes);
    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
    final decoded = await aesGcmDecrypt(
      treeKey,
      Uint8List.fromList(treeChange.changesData),
    );
    final change = changes_proto.Change.fromBuffer(decoded);

    expect(
      change.content.any(
        (content) =>
            content.hasDetailsSet() &&
            content.detailsSet.key == 'description' &&
            content.detailsSet.value.stringValue == 'Phase 46 description',
      ),
      isTrue,
    );
  });

  test('edit writes generic string-list details via detailsSet', () async {
    await createCommand('List object', db, config);

    final objectId = await _findObjectIdByName(db, config, 'List object');
    expect(objectId, isNotNull);

    await editCommand(
      objectId!,
      null,
      db,
      config,
      networkConfigPath: 'unused-network.yml',
      syncService: _NoopSyncService(),
      relationKey: 'featuredRelations',
      stringListValue: const ['description', 'sourceObject'],
    );

    final replayed = await _replayObject(db, config, objectId);
    final detail = replayed.snapshot.details.fields['featuredRelations'];
    expect(detail, isNotNull);
    expect(
      detail!.listValue.values.map((value) => value.stringValue),
      orderedEquals(const ['description', 'sourceObject']),
    );

    final treeKey = await _treeKeyForObject(config, objectId);
    final changes = await db.getChangesForObject(objectId);
    final rawTreeChange = RawTreeChange.fromBuffer(changes.last.rawBytes);
    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
    final decoded = await aesGcmDecrypt(
      treeKey,
      Uint8List.fromList(treeChange.changesData),
    );
    final change = changes_proto.Change.fromBuffer(decoded);

    final featuredRelationsSet = change.content.firstWhere(
      (content) =>
          content.hasDetailsSet() &&
          content.detailsSet.key == 'featuredRelations',
    );
    expect(
      featuredRelationsSet.detailsSet.value.listValue.values
          .map((value) => value.stringValue),
      orderedEquals(const ['description', 'sourceObject']),
    );
  });
}

class _NoopSyncService extends SyncService {
  @override
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
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
