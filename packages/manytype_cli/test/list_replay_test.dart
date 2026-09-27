import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_cli/src/commands/list.dart';
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
  late String spaceId;

  setUpAll(() async {
    await configureWebTestDatabaseAssets();
  });

  setUp(() async {
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
    config =
        CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:33020');
    spaceId = (await Identity.fromMnemonic(testMnemonic)).spaceId;
  });

  tearDown(() async {
    await db.close();
  });

  test('a concurrent snapshot does not hide a sibling-branch rename', () async {
    final objectId = await _insertRoot(db, spaceId);
    final base = await _insertChange(
      db,
      objectId,
      [objectId],
      _snapshot({'name': 'Original'}),
      timestamp: 100,
      isSnapshot: true,
    );
    await _insertChange(
      db,
      objectId,
      [base],
      _content([_detailsSet('name', Value(stringValue: 'Edited'))]),
      timestamp: 200,
    );
    // Snapshot made on another device from base, without the rename, and
    // replayed after it.
    await _insertChange(
      db,
      objectId,
      [base],
      _snapshot({'name': 'Original'}),
      timestamp: 300,
      isSnapshot: true,
    );

    final meta = (await listCommand(db, config)).singleWhere(
      (object) => object.id == objectId,
    );
    expect(meta.name, 'Edited');
  });

  test('detailsUnset and a valueless detailsSet remove listed details',
      () async {
    final objectId = await _insertRoot(db, spaceId);
    final base = await _insertChange(
      db,
      objectId,
      [objectId],
      _snapshot({'name': 'Doc', 'tag': 'x', 'status': 'y'}),
      timestamp: 100,
      isSnapshot: true,
    );
    await _insertChange(
      db,
      objectId,
      [base],
      _content([
        changes_proto.Change_Content(
          detailsUnset: changes_proto.Change_DetailsUnset(key: 'tag'),
        ),
        _detailsSet('status', null),
      ]),
      timestamp: 200,
    );

    final meta = (await listCommand(db, config)).singleWhere(
      (object) => object.id == objectId,
    );
    expect(meta.details.keys, ['name']);
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

changes_proto.Change _snapshot(Map<String, String> details) =>
    changes_proto.Change(
      snapshot: changes_proto.Change_Snapshot(
        data: SmartBlockSnapshotBase(
          details: Struct(fields: [
            for (final entry in details.entries)
              MapEntry(entry.key, Value(stringValue: entry.value)),
          ]),
        ),
      ),
    );

changes_proto.Change _content(List<changes_proto.Change_Content> content) =>
    changes_proto.Change(content: content);

changes_proto.Change_Content _detailsSet(String key, Value? value) =>
    changes_proto.Change_Content(
      detailsSet: changes_proto.Change_DetailsSet(key: key, value: value),
    );
