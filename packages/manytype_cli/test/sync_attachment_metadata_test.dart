import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:manytype_cli/src/commands/read.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/models.dart' as models;
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/spacesync.dart';
import 'package:test/test.dart';

void main() {
  late ManytypeDatabase db;

  setUp(() {
    db = ManytypeDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('attachment metadata sync', () {
    test('extracts file IDs and hashes from synced raw changes', () {
      final refs = extractAttachmentRefsFromRawChangeBytes(
        _wrapChange(
          changes_proto.Change(
            snapshot: changes_proto.Change_Snapshot(
              data: models.SmartBlockSnapshotBase(
                fileInfo: models.FileInfo(fileId: 'file-1'),
              ),
              fileKeys: [
                changes_proto.Change_FileKeys(hash: 'bafy-metadata-hash'),
              ],
            ),
          ),
        ),
      );

      expect(refs, [
        (fileId: 'file-1', cid: 'bafy-metadata-hash'),
      ]);
    });

    test('stores attachment refs without populating the blob cache', () async {
      final rawChange = _wrapChange(
        changes_proto.Change(
          content: [
            changes_proto.Change_Content(
              setFileInfo: changes_proto.Change_SetFileInfo(
                fileInfo: models.FileInfo(fileId: 'file-1'),
              ),
            ),
          ],
          fileKeys: [
            changes_proto.Change_FileKeys(hash: 'bafy-metadata-hash'),
          ],
        ),
      );

      await storePulledChanges(
        db,
        'space-a',
        'obj-1',
        _lengthPrefixed([rawChange]),
      );

      final refs = await db.getAttachmentRefsByObject('obj-1');
      expect(refs.length, 1);
      expect(refs.single.fileId, 'file-1');
      expect(refs.single.cid, 'bafy-metadata-hash');
      expect(
        await db.getCachedBlob(
          spaceId: 'space-a',
          fileId: 'file-1',
          cid: 'bafy-metadata-hash',
        ),
        isNull,
      );
    });

    test('marks deleted objects from pulled settings-tree deletes', () async {
      const settingsObjectId = 'settings-obj';
      const deletedObjectId = 'obj-1';
      final spaceKey = Uint8List.fromList(List<int>.filled(32, 7));
      final treeKey = await deriveTreeKey(spaceKey, settingsObjectId);

      await db.insertObject(deletedObjectId, 'space-a');

      final settingsDelete = SettingsData(
        content: [
          SpaceSettingsContent(
            objectDelete: ObjectDelete(id: deletedObjectId),
          ),
        ],
      );
      final encryptedDelete = await aesGcmEncrypt(
        treeKey,
        Uint8List.fromList(settingsDelete.writeToBuffer()),
      );
      final deleteChange = RawTreeChange(
        payload: Uint8List.fromList(
          TreeChange(
            changesData: encryptedDelete,
            readKeyId: 'acl-head',
          ).writeToBuffer(),
        ),
      );
      final settingsRoot = RawTreeChange(
        payload: Uint8List.fromList(
          RootChange(
            spaceId: 'space-a',
            changeType: 'anytype.space',
          ).writeToBuffer(),
        ),
      );
      final extraParentlessChange = RawTreeChange(
        payload: Uint8List.fromList(
          TreeChange(
            changesData: Uint8List.fromList([1, 2, 3]),
          ).writeToBuffer(),
        ),
      );

      await storePulledChanges(
        db,
        'space-a',
        settingsObjectId,
        _lengthPrefixed([
          Uint8List.fromList(extraParentlessChange.writeToBuffer()),
          Uint8List.fromList(settingsRoot.writeToBuffer()),
          Uint8List.fromList(deleteChange.writeToBuffer()),
        ]),
        spaceKey: spaceKey,
      );

      expect(await db.isObjectDeleted(deletedObjectId), isTrue);
    });

    test('read command surfaces attachment metadata separately from bytes',
        () async {
      await db.insertObject('obj-1', 'space-a');
      await db.insertChange('change-1', 'obj-1', [1, 2, 3], '[]');
      await db.upsertAttachmentRef(
        spaceId: 'space-a',
        objectId: 'obj-1',
        fileId: 'file-1',
        cid: 'bafy-metadata-hash',
      );

      final output = await _capturePrints(() async {
        await readCommand(
          db,
          CliConfig(
            mnemonic: generateMnemonic(),
            serverAddress: '127.0.0.1:33020',
          ),
          objectId: 'obj-1',
        );
      });

      expect(output, contains('Attachments:'));
      expect(output, contains('file-1 (cid=bafy-metadata-hash)'));
    });
  });
}

Uint8List _wrapChange(changes_proto.Change change) {
  final treeChange = TreeChange(
    changesData: Uint8List.fromList(change.writeToBuffer()),
  );
  final rawTreeChange = RawTreeChange(
    payload: Uint8List.fromList(treeChange.writeToBuffer()),
  );
  return Uint8List.fromList(rawTreeChange.writeToBuffer());
}

Uint8List _lengthPrefixed(List<Uint8List> messages) {
  final builder = BytesBuilder();
  for (final message in messages) {
    final length = ByteData(4)..setUint32(0, message.length, Endian.little);
    builder.add(length.buffer.asUint8List());
    builder.add(message);
  }
  return builder.toBytes();
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
