import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, RootChange;
import 'package:manytype_protocol/spacesync.dart'
    show SettingsData, SpaceSettingsContent, ObjectDelete;

import '../acl_codec.dart';
import '../config.dart';
import '../identity.dart';
import '../store/database.dart';
import '../sync_service.dart';

Future<void> deleteCommand(
  String objectId,
  ManytypeDatabase db,
  CliConfig config, {
  required String networkConfigPath,
}) async {
  // 1. Verify the object exists locally
  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    print('Object not found locally -- run `manytype sync` first');
    exit(1);
  }

  // Check if already deleted
  if (await db.isObjectDeleted(objectId)) {
    print('Object $objectId is already deleted');
    exit(1);
  }

  // 2. Sync to get latest state
  final syncService = SyncService();
  await syncService.sync(db, config, networkConfigPath: networkConfigPath);

  // 3. Load identity and derive keys
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = identity.spaceId;
  final allObjects = await db.getObjectsBySpace(spaceId);
  final aclHeadId = await _findAclRootId(db, allObjects, spaceId);

  // 4. Find settings tree via changeType == 'any-sync.space' or 'anytype.space'
  String? settingsPayloadId;
  for (final obj in allObjects) {
    final objChanges = await db.getChangesForObject(obj.id);
    if (objChanges.isEmpty) continue;
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(objChanges.first.rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;
      final rootChange = RootChange.fromBuffer(rawTreeChange.payload);
      if (rootChange.spaceId == spaceId &&
          (rootChange.changeType == 'anytype.space' ||
              rootChange.changeType == 'any-sync.space')) {
        settingsPayloadId = obj.id;
        break;
      }
    } catch (_) {
      continue;
    }
  }
  if (settingsPayloadId == null) {
    print('Could not find settings tree for space');
    exit(1);
  }

  // 5. Get current heads for the settings tree
  final settingsHeads = await db.getObjectHeads(settingsPayloadId);
  if (settingsHeads.isEmpty) {
    print('No heads found for settings tree');
    exit(1);
  }

  // Find root change ID for settings tree (snapshotBaseId)
  final settingsChanges = await db.getChangesForObject(settingsPayloadId);
  String? settingsRootId;
  for (final c in settingsChanges) {
    final parents = jsonDecode(c.parentHeads) as List;
    if (parents.isEmpty) {
      settingsRootId = c.id;
      break;
    }
  }
  if (settingsRootId == null) {
    print('Could not find root change for settings tree');
    exit(1);
  }

  // 6. Build SettingsData with ObjectDelete
  final settingsData = SettingsData(
    content: [
      SpaceSettingsContent(
        objectDelete: ObjectDelete(id: objectId),
      ),
    ],
  );
  final settingsDataBytes = Uint8List.fromList(settingsData.writeToBuffer());

  // 7. Derive tree key for the SETTINGS TREE (not the target object!)
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  final settingsTreeKey = await deriveTreeKey(spaceKey, settingsPayloadId);

  // 8. Build encrypted TreeChange for the settings tree
  final treeChange = await buildTreeChange(
    currentHeads: settingsHeads,
    aclHeadId: aclHeadId,
    snapshotBaseId: settingsRootId,
    changesData: await aesGcmEncrypt(settingsTreeKey, settingsDataBytes),
    identityPrivateKey: identity.accountSeed,
    readKeyId: aclHeadId,
  );

  // 9. Insert change for the settings tree object (NOT the target object)
  await db.insertChange(
    treeChange.id,
    settingsPayloadId,
    treeChange.rawChange,
    jsonEncode(settingsHeads),
  );

  // 10. Mark target object as deleted locally
  await db.markObjectDeleted(objectId);

  // 11. Sync to push the settings tree change
  await syncService.sync(db, config, networkConfigPath: networkConfigPath);

  print('Deleted $objectId');
}

Future<String> _findAclRootId(
  ManytypeDatabase db,
  List<StoredObject> objects,
  String spaceId,
) async {
  for (final object in objects) {
    final changes = await db.getChangesForObject(object.id);
    if (changes.isEmpty) continue;
    try {
      final aclRoot = tryDecodeAclRootFromRawRecordBytes(
          Uint8List.fromList(changes.first.rawBytes));
      if (aclRoot != null && aclRoot.spaceId == spaceId) {
        return object.id;
      }
    } catch (_) {
      continue;
    }
  }
  throw StateError('Space bootstrap is missing an ACL root');
}
