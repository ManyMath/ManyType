@TestOn('vm')
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/spacesync.dart';
import 'package:test/test.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

void main() {
  late Directory tempDir;
  late ManytypeDatabase db;
  late CliConfig config;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manytype_pull_validate_');
    AccountRegistry.testBaseDirOverride = tempDir.path;
    CliConfig.testConfigDirOverride = tempDir.path;
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
    config = CliConfig(mnemonic: _mnemonic, serverAddress: '127.0.0.1:1');
  });

  tearDown(() async {
    await db.close();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('a pulled change cannot overwrite or move an existing change row',
      () async {
    final created = await createCommand('hello', db, config);
    final before = await db.getChangesForObject(created.objectId);
    final victim = before.last;

    await storePulledChanges(
      db,
      created.spaceId,
      'attacker-object',
      _frame([
        _headUpdate(created.spaceId, 'attacker-object', [
          RawTreeChangeWithId(id: victim.id, rawChange: [1, 2, 3]),
          RawTreeChangeWithId(id: victim.id, rawChange: victim.rawBytes),
        ]),
      ]),
    );

    final after = await db.getChangesForObject(created.objectId);
    expect(after.map((change) => change.id), before.map((change) => change.id));
    expect(after.last.rawBytes, victim.rawBytes);
    expect(await db.getChangesForObject('attacker-object'), isEmpty);
  });

  test('drops pulled changes whose id is empty or not the CID of their bytes',
      () async {
    final valid = _rawTreeChange([1]);
    final mislabeled = _rawTreeChange([2]);
    final unlabeled = _rawTreeChange([3]);

    await storePulledChanges(
      db,
      'space-a',
      'obj-1',
      _frame([
        _headUpdate('space-a', 'obj-1', [
          RawTreeChangeWithId(id: await computeCid(valid), rawChange: valid),
          RawTreeChangeWithId(
            id: await computeCid(valid),
            rawChange: mislabeled,
          ),
          RawTreeChangeWithId(id: '', rawChange: unlabeled),
        ]),
      ]),
    );

    final stored = await db.getChangesForObject('obj-1');
    expect(stored.map((change) => change.id), [await computeCid(valid)]);
    expect(stored.single.rawBytes, valid);
  });

  test('insertChange keeps the first row and refuses to move it', () async {
    await db.insertObject('obj-1', 'space-a');
    await db.insertObject('obj-2', 'space-a');
    await db.insertChange('cid-1', 'obj-1', [1], '[]');
    await db.insertChange('cid-1', 'obj-1', [2], '[]');

    await expectLater(
      db.insertChange('cid-1', 'obj-2', [1], '[]'),
      throwsA(isA<StateError>()),
    );
    final stored = await db.getChangesForObject('obj-1');
    expect(stored.single.rawBytes, [1]);
    expect(await db.getChangesForObject('obj-2'), isEmpty);
  });

  test('ignores settings deletes from a tree whose id is not its root CID',
      () async {
    final spaceKey = Uint8List.fromList(List<int>.filled(32, 7));
    await db.insertObject('victim', 'space-a');
    final fakeSettingsRoot = RawTreeChange(
      payload: RootChange(
        spaceId: 'space-a',
        changeType: 'anytype.space',
      ).writeToBuffer(),
    ).writeToBuffer();
    final deleteChange = RawTreeChange(
      payload: TreeChange(
        changesData: SettingsData(
          content: [
            SpaceSettingsContent(objectDelete: ObjectDelete(id: 'victim')),
          ],
        ).writeToBuffer(),
      ).writeToBuffer(),
    ).writeToBuffer();

    await storePulledChanges(
      db,
      'space-a',
      'not-the-settings-tree',
      _frame([
        Uint8List.fromList(fakeSettingsRoot),
        Uint8List.fromList(deleteChange),
      ]),
      spaceKey: spaceKey,
    );

    expect(await db.isObjectDeleted('victim'), isFalse);
  });
}

Uint8List _rawTreeChange(List<int> changesData) => Uint8List.fromList(
      RawTreeChange(
        payload: TreeChange(changesData: changesData).writeToBuffer(),
      ).writeToBuffer(),
    );

Uint8List _headUpdate(
  String spaceId,
  String objectId,
  List<RawTreeChangeWithId> changes,
) =>
    Uint8List.fromList(
      ObjectSyncMessage(
        spaceId: spaceId,
        objectId: objectId,
        payload: TreeSyncMessage(
          content: TreeSyncContentValue(
            headUpdate: TreeHeadUpdate(
              heads: [for (final change in changes) change.id],
              changes: changes,
            ),
          ),
        ).writeToBuffer(),
      ).writeToBuffer(),
    );

Uint8List _frame(List<Uint8List> messages) {
  final builder = BytesBuilder();
  for (final message in messages) {
    builder.add(
      (ByteData(4)..setUint32(0, message.length, Endian.little))
          .buffer
          .asUint8List(),
    );
    builder.add(message);
  }
  return builder.toBytes();
}
