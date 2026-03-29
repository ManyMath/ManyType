import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:test/test.dart';
import 'package:manytype_cli/src/store/database.dart';

import 'web/web_db_test_helpers.dart';

void main() {
  late ManytypeDatabase db;

  setUpAll(() async {
    await configureWebTestDatabaseAssets();
  });

  setUp(() async {
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
  });

  tearDown(() async {
    await db.close();
  });

  group('ManytypeDatabase', () {
    test('insert and retrieve object', () async {
      await db.insertObject('obj-1', 'space-abc');

      final all = await db.getAllObjects();
      expect(all.length, 1);
      expect(all.first.id, 'obj-1');
      expect(all.first.spaceId, 'space-abc');
      expect(all.first.createdAt, isNotNull);
    });

    test('insert and retrieve changes for object', () async {
      await db.insertObject('obj-1', 'space-abc');
      await db.insertChange('change-1', 'obj-1', [1, 2, 3], '[]');
      await db.insertChange('change-2', 'obj-1', [4, 5, 6], '["change-1"]');

      final changes = await db.getChangesForObject('obj-1');
      expect(changes.length, 2);
      expect(changes[0].id, 'change-1');
      expect(changes[0].objectId, 'obj-1');
      expect(changes[0].rawBytes, [1, 2, 3]);
      expect(changes[0].parentHeads, '[]');
      expect(changes[1].id, 'change-2');
      expect(changes[1].rawBytes, [4, 5, 6]);
      expect(changes[1].parentHeads, '["change-1"]');
    });

    test('orders replay changes causally even when IDs are lexically shuffled',
        () async {
      await db.insertObject('obj-1', 'space-abc');
      await db.insertChange('change-z', 'obj-1', [3], '["change-m"]');
      await db.insertChange('change-a', 'obj-1', [1], '[]');
      await db.insertChange('change-m', 'obj-1', [2], '["change-a"]');

      final changes = await db.getChangesForObject('obj-1');
      expect(
        changes.map((change) => change.id).toList(),
        ['change-a', 'change-m', 'change-z'],
      );
    });

    test('getObjectsBySpace filters correctly', () async {
      await db.insertObject('obj-1', 'space-a');
      await db.insertObject('obj-2', 'space-b');
      await db.insertObject('obj-3', 'space-a');

      final spaceA = await db.getObjectsBySpace('space-a');
      expect(spaceA.length, 2);
      expect(spaceA.map((o) => o.id).toSet(), {'obj-1', 'obj-3'});

      final spaceB = await db.getObjectsBySpace('space-b');
      expect(spaceB.length, 1);
      expect(spaceB.first.id, 'obj-2');
    });

    test('getObjectHeads returns last change CID', () async {
      await db.insertObject('obj-1', 'space-a');
      await db.insertChange('cid-aaa', 'obj-1', [1], '[]');
      await db.insertChange('cid-bbb', 'obj-1', [2], '["cid-aaa"]');

      final heads = await db.getObjectHeads('obj-1');
      expect(heads, ['cid-bbb']);
    });

    test('getObjectHeads returns empty for object with no changes', () async {
      await db.insertObject('obj-1', 'space-a');

      final heads = await db.getObjectHeads('obj-1');
      expect(heads, isEmpty);
    });

    test('getSpaceHeads returns all objects with heads', () async {
      await db.insertObject('obj-1', 'space-a');
      await db.insertObject('obj-2', 'space-a');
      await db.insertChange('cid-1', 'obj-1', [1], '[]');
      await db.insertChange('cid-2', 'obj-2', [2], '[]');

      final spaceHeads = await db.getSpaceHeads('space-a');
      expect(spaceHeads.length, 2);
      expect(spaceHeads['obj-1'], ['cid-1']);
      expect(spaceHeads['obj-2'], ['cid-2']);
    });

    test('insertObject ignores re-seeing an existing object id', () async {
      // insertObject uses insertOrIgnore (not insertOrReplace) so that sync
      // frequently re-seeing an existing object row does not clear
      // soft-delete state already applied locally. See delete_test.dart
      // 're-seeing an object row does not clear an existing delete flag'.
      await db.insertObject('obj-1', 'space-a');
      await db.insertObject('obj-1', 'space-b');

      final all = await db.getAllObjects();
      expect(all.length, 1);
      expect(all.first.spaceId, 'space-a');
    });

    test('upserts and retrieves store entries by space', () async {
      await db.upsertStoreEntry(
        keyPeerId: 'peer-b',
        spaceId: 'space-a',
        valueBytes: [2],
        identitySignatureBytes: [20],
        peerSignatureBytes: [21],
      );
      await db.upsertStoreEntry(
        keyPeerId: 'peer-a',
        spaceId: 'space-a',
        valueBytes: [1],
        identitySignatureBytes: [10],
        peerSignatureBytes: [11],
      );
      await db.upsertStoreEntry(
        keyPeerId: 'peer-a',
        spaceId: 'space-a',
        valueBytes: [3],
        identitySignatureBytes: [30],
        peerSignatureBytes: [31],
      );
      await db.upsertStoreEntry(
        keyPeerId: 'peer-c',
        spaceId: 'space-b',
        valueBytes: [4],
        identitySignatureBytes: [40],
        peerSignatureBytes: [41],
      );

      final entries = await db.getStoreEntriesBySpace('space-a');
      expect(entries.map((entry) => entry.keyPeerId).toList(),
          ['peer-a', 'peer-b']);
      expect(entries.first.value, [3]);
      expect(entries.first.identitySignature, [30]);
      expect(entries.first.peerSignature, [31]);
    });

    test('upserts attachment refs and queries them by object and file ID',
        () async {
      await db.insertObject('obj-1', 'space-a');
      await db.insertObject('obj-2', 'space-a');
      await db.upsertAttachmentRef(
        spaceId: 'space-a',
        objectId: 'obj-1',
        fileId: 'file-1',
        cid: 'bafy-a',
      );
      await db.upsertAttachmentRef(
        spaceId: 'space-a',
        objectId: 'obj-1',
        fileId: 'file-1',
        cid: 'bafy-a',
      );
      await db.upsertAttachmentRef(
        spaceId: 'space-a',
        objectId: 'obj-1',
        fileId: 'file-1',
        cid: '',
      );
      await db.upsertAttachmentRef(
        spaceId: 'space-a',
        objectId: 'obj-2',
        fileId: 'file-1',
        cid: 'bafy-b',
      );

      final objectRefs = await db.getAttachmentRefsByObject('obj-1');
      expect(objectRefs.length, 2);
      expect(objectRefs.map((entry) => entry.cid).toList(), ['', 'bafy-a']);

      final fileRefs = await db.getAttachmentRefsByFileId('space-a', 'file-1');
      expect(fileRefs.length, 3);
      expect(fileRefs.map((entry) => entry.objectId).toList(),
          ['obj-1', 'obj-1', 'obj-2']);
    });

    test('stores cached blobs independently from attachment metadata',
        () async {
      await db.insertObject('obj-1', 'space-a');
      await db.upsertAttachmentRef(
        spaceId: 'space-a',
        objectId: 'obj-1',
        fileId: 'file-1',
        cid: 'bafy-a',
      );

      expect(
        await db.getCachedBlob(
          spaceId: 'space-a',
          fileId: 'file-1',
          cid: 'bafy-a',
        ),
        isNull,
      );

      await db.cacheBlob(
        spaceId: 'space-a',
        fileId: 'file-1',
        cid: 'bafy-a',
        bytes: [1, 2, 3],
      );

      final cached = await db.getCachedBlob(
        spaceId: 'space-a',
        fileId: 'file-1',
        cid: 'bafy-a',
      );
      expect(cached, isNotNull);
      expect(cached!.bytes, [1, 2, 3]);
    });
  });
}
