import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_cli/src/commands/read.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
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

  test('read shows the replayed state, not the first snapshot plus deltas',
      () async {
    final identity = await Identity.fromMnemonic(testMnemonic);
    final objectId = await _insertRoot(db, identity.spaceId);
    final base = await _insertChange(
      db,
      objectId,
      [objectId],
      _snapshot(objectId),
      timestamp: 100,
      isSnapshot: true,
    );
    await _insertChange(
      db,
      objectId,
      [base],
      changes_proto.Change(content: [
        _detailsSet('name', Value(stringValue: 'Renamed')),
        changes_proto.Change_Content(
          detailsUnset: changes_proto.Change_DetailsUnset(key: 'mood'),
        ),
        _detailsSet('sourceObject', null),
        changes_proto.Change_Content(
          blockRemove: changes_proto.Change_BlockRemove(ids: ['gone']),
        ),
      ]),
      timestamp: 200,
    );
    // Snapshot made on another device from base, replayed after the edits.
    await _insertChange(
      db,
      objectId,
      [base],
      _snapshot(objectId),
      timestamp: 300,
      isSnapshot: true,
    );

    final lines =
        (await readCommand(db, config, objectId: objectId)).detail!.lines;
    expect(lines, contains('  Name: Renamed'));
    expect(lines, contains('    [kept] [Paragraph] kept text'));
    expect(lines.where((line) => line.contains('gone')), isEmpty);
    expect(lines.where((line) => line.contains('[mood]')), isEmpty);
    expect(lines.where((line) => line.contains('Source Template')), isEmpty);
  });
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

changes_proto.Change _snapshot(String objectId) => changes_proto.Change(
      snapshot: changes_proto.Change_Snapshot(
        data: SmartBlockSnapshotBase(
          blocks: [
            Block(id: objectId, childrenIds: ['kept', 'gone']),
            createTextBlock('kept', 'kept text'),
            createTextBlock('gone', 'gone text'),
          ],
          details: Struct(fields: [
            MapEntry('name', Value(stringValue: 'Doc')),
            MapEntry('mood', Value(stringValue: 'calm')),
            MapEntry('sourceObject', Value(stringValue: 'tmpl-1')),
          ]),
        ),
      ),
    );

changes_proto.Change_Content _detailsSet(String key, Value? value) =>
    changes_proto.Change_Content(
      detailsSet: changes_proto.Change_DetailsSet(key: key, value: value),
    );
