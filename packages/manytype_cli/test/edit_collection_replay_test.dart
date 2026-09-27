import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, RootChange, TreeChange;
import 'package:manytype_protocol/models.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';
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

  test('collection edits see members added beside a concurrent snapshot',
      () async {
    // Bootstraps the space (ACL root) that edits need.
    await createCommand('Seed', db, config);
    final identity = await Identity.fromMnemonic(testMnemonic);
    final objectId = await _insertRoot(db, identity.spaceId);

    final base = await _insertChange(
      db,
      objectId,
      [objectId],
      _collectionSnapshot(objectId, ['a']),
      timestamp: 100,
      isSnapshot: true,
    );
    await _insertChange(
      db,
      objectId,
      [base],
      changes_proto.Change(content: [
        buildStoreSliceUpdateAdd(key: 'objects', ids: ['b'], afterId: 'a'),
      ]),
      timestamp: 200,
    );
    // Snapshot made on another device from base, without 'b', and replayed
    // after the add.
    await _insertChange(
      db,
      objectId,
      [base],
      _collectionSnapshot(objectId, ['a']),
      timestamp: 300,
      isSnapshot: true,
    );

    final result = await editCommand(
      objectId,
      null,
      db,
      config,
      syncService: _NoopSyncService(),
      collectionMoveId: 'b',
    );
    expect(result.collectionChangeId, isNotNull);

    final accountPrivRaw = Uint8List(64)
      ..setRange(0, 32, identity.accountSeed)
      ..setRange(32, 64, identity.accountKeyPair.publicKey);
    final treeKey =
        await deriveTreeKey(await deriveSpaceKey(accountPrivRaw), objectId);
    final replayed = await replayObjectState(
      rawTreeChanges: [
        for (final change in await db.getChangesForObject(objectId))
          Uint8List.fromList(change.rawBytes),
      ],
      treeKey: treeKey,
    );
    expect(
      replayed.snapshot.collections.fields['objects']!.listValue.values
          .map((value) => value.stringValue),
      ['b', 'a'],
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

/// Insert a Page root change and its object row; returns the object id.
Future<String> _insertRoot(ManytypeDatabase db, String spaceId) async {
  final raw = Uint8List.fromList(RawTreeChange(
    payload: RootChange(
      spaceId: spaceId,
      changeType: 'anytype.object',
      // SmartBlockType 16 (Page).
      changePayload: const [0x08, 0x10],
    ).writeToBuffer(),
  ).writeToBuffer());
  final id = await computeCid(raw);
  await db.insertObject(id, spaceId);
  await db.insertChange(id, id, raw, '[]');
  return id;
}

/// Insert a plaintext TreeChange; returns its id (the CID of its bytes).
Future<String> _insertChange(
  ManytypeDatabase db,
  String objectId,
  List<String> parents,
  changes_proto.Change change, {
  required int timestamp,
  bool isSnapshot = false,
}) async {
  final raw = Uint8List.fromList(RawTreeChange(
    payload: TreeChange(
      treeHeadIds: parents,
      changesData: change.writeToBuffer(),
      timestamp: Int64(timestamp),
      isSnapshot: isSnapshot,
    ).writeToBuffer(),
  ).writeToBuffer());
  final id = await computeCid(raw);
  await db.insertChange(id, objectId, raw, jsonEncode(parents));
  return id;
}

changes_proto.Change _collectionSnapshot(String objectId, List<String> ids) =>
    changes_proto.Change(
      snapshot: changes_proto.Change_Snapshot(
        data: SmartBlockSnapshotBase(
          blocks: [
            Block(id: objectId, childrenIds: ['dataview']),
            createDataviewBlock('dataview', ['ot-page'], isCollection: true),
          ],
          collections: Struct(fields: [
            MapEntry(
              'objects',
              Value(
                listValue: ListValue(values: [
                  for (final id in ids) Value(stringValue: id),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
