import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:manytype_cli/src/commands/read.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';
import 'package:test/test.dart';

void main() {
  late ManytypeDatabase db;

  setUp(() {
    db = ManytypeDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 40 file relation read', () {
    test('resolves RelationFormat.file values to filename and mime', () async {
      final config = await _testConfig();
      final identity = await Identity.fromMnemonic(config.mnemonic);
      const parentId = 'obj-parent';
      const fileObjectId = 'obj-file';

      await _insertObjectTree(
        db,
        objectId: parentId,
        spaceId: identity.spaceId,
        smartBlockType: SmartBlockType.Page.value,
        snapshot: _parentSnapshot(
          parentId,
          relationKey: 'attachment',
          relationValue: fileObjectId,
          includeRelationLink: true,
        ),
      );
      await _insertObjectTree(
        db,
        objectId: fileObjectId,
        spaceId: identity.spaceId,
        smartBlockType: SmartBlockType.FileObject.value,
        snapshot: _fileSnapshot(
          fileObjectId,
          name: 'spec.pdf',
          mime: 'application/pdf',
        ),
      );

      final output = await _capturePrints(() async {
        await readCommand(db, config, objectId: parentId);
      });

      expect(output, contains('[attachment] spec.pdf (application/pdf)'));
    });

    test('renders unknown-file fallback for missing file objects', () async {
      final config = await _testConfig();
      final identity = await Identity.fromMnemonic(config.mnemonic);
      const parentId = 'obj-parent';
      const missingId = 'missing-file-object';

      await _insertObjectTree(
        db,
        objectId: parentId,
        spaceId: identity.spaceId,
        smartBlockType: SmartBlockType.Page.value,
        snapshot: _parentSnapshot(
          parentId,
          relationKey: 'attachment',
          relationValue: missingId,
          includeRelationLink: true,
        ),
      );

      final output = await _capturePrints(() async {
        await readCommand(db, config, objectId: parentId);
      });

      expect(output, contains('[attachment] <unknown-file:missing->'));
    });

    test('falls back to local FileObject detection without relation links',
        () async {
      final config = await _testConfig();
      final identity = await Identity.fromMnemonic(config.mnemonic);
      const parentId = 'obj-parent';
      const fileObjectId = 'obj-file';

      await _insertObjectTree(
        db,
        objectId: parentId,
        spaceId: identity.spaceId,
        smartBlockType: SmartBlockType.Page.value,
        snapshot: _parentSnapshot(
          parentId,
          relationKey: 'attachment',
          relationValue: fileObjectId,
          includeRelationLink: false,
        ),
      );
      await _insertObjectTree(
        db,
        objectId: fileObjectId,
        spaceId: identity.spaceId,
        smartBlockType: SmartBlockType.FileObject.value,
        snapshot: _fileSnapshot(
          fileObjectId,
          name: 'diagram.png',
          mime: 'image/png',
        ),
      );

      final output = await _capturePrints(() async {
        await readCommand(db, config, objectId: parentId);
      });

      expect(output, contains('[attachment] diagram.png (image/png)'));
    });
  });
}

Future<CliConfig> _testConfig() async {
  return CliConfig(
    mnemonic: generateMnemonic(),
    serverAddress: '127.0.0.1:33020',
  );
}

Future<void> _insertObjectTree(
  ManytypeDatabase db, {
  required String objectId,
  required String spaceId,
  required int smartBlockType,
  required SmartBlockSnapshotBase snapshot,
}) async {
  await db.insertObject(objectId, spaceId);
  await db.insertChange(
    '$objectId-root',
    objectId,
    _wrapRootChange(spaceId: spaceId, smartBlockType: smartBlockType),
    '[]',
  );
  await db.insertChange(
    '$objectId-snapshot',
    objectId,
    _wrapSnapshotChange(snapshot),
    '["$objectId-root"]',
  );
}

SmartBlockSnapshotBase _parentSnapshot(
  String objectId, {
  required String relationKey,
  required String relationValue,
  required bool includeRelationLink,
}) {
  final snapshot = createMinimalPageSnapshotBase(
    objectId: objectId,
    title: 'Parent object',
  );
  snapshot.details = Struct()
    ..fields['name'] = Value(stringValue: 'Parent object')
    ..fields[relationKey] = Value(stringValue: relationValue);
  if (includeRelationLink) {
    snapshot.relationLinks.add(
      RelationLink(
        key: relationKey,
        format: RelationFormat.file,
      ),
    );
  }
  return snapshot;
}

SmartBlockSnapshotBase _fileSnapshot(
  String objectId, {
  required String name,
  required String mime,
}) {
  final snapshot = createMinimalPageSnapshotBase(
    objectId: objectId,
    title: name,
  );
  snapshot.details = Struct()
    ..fields['name'] = Value(stringValue: name)
    ..fields['mime'] = Value(stringValue: mime)
    ..fields['layout'] = Value(numberValue: 6.0);
  return snapshot;
}

Uint8List _wrapRootChange({
  required String spaceId,
  required int smartBlockType,
}) {
  final rootChange = RootChange(
    spaceId: spaceId,
    changePayload: _encodeObjectChangePayloadSmartblockType(smartBlockType),
  );
  final rawTreeChange = RawTreeChange(
    payload: Uint8List.fromList(rootChange.writeToBuffer()),
  );
  return Uint8List.fromList(rawTreeChange.writeToBuffer());
}

Uint8List _wrapSnapshotChange(SmartBlockSnapshotBase snapshot) {
  final change = changes_proto.Change(
    snapshot: changes_proto.Change_Snapshot(data: snapshot),
  );
  final treeChange = TreeChange(
    changesData: Uint8List.fromList(change.writeToBuffer()),
    isSnapshot: true,
  );
  final rawTreeChange = RawTreeChange(
    payload: Uint8List.fromList(treeChange.writeToBuffer()),
  );
  return Uint8List.fromList(rawTreeChange.writeToBuffer());
}

Uint8List _encodeObjectChangePayloadSmartblockType(int smartBlockType) {
  final bytes = BytesBuilder()
    ..addByte(0x08)
    ..add(_encodeVarint(smartBlockType));
  return bytes.toBytes();
}

Uint8List _encodeVarint(int value) {
  var current = value;
  final out = <int>[];
  while (current >= 0x80) {
    out.add((current & 0x7f) | 0x80);
    current >>= 7;
  }
  out.add(current & 0x7f);
  return Uint8List.fromList(out);
}

Future<String> _capturePrints(Future<void> Function() run) async {
  final lines = <String>[];
  await runZoned(
    run,
    zoneSpecification: ZoneSpecification(
      print: (_, __, ___, String line) {
        lines.add(line);
      },
    ),
  );
  return lines.join('\n');
}
