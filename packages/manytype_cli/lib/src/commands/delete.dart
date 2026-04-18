import 'dart:convert';
import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, RootChange, TreeChange;
import 'package:manytype_protocol/spacesync.dart'
    show SettingsData, SpaceSettingsContent, ObjectDelete;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    show Value;

import '../acl_codec.dart';
import '../config.dart';
import '../identity.dart';
import '../store/database.dart';
import '../sync_service.dart';

/// Result of [deleteCommand].
class DeleteResult {
  const DeleteResult({required this.objectId});

  final String objectId;
}

Future<DeleteResult> deleteCommand(
  String objectId,
  ManytypeDatabase db,
  CliConfig config, {
  required String networkConfigPath,
  SyncService? syncService,
}) async {
  final syncServiceRef = syncService ?? SyncService();

  // 1. Verify the object exists locally
  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    throw StateError('Object not found locally -- run `manytype sync` first');
  }

  // Check if already deleted
  if (await db.isObjectDeleted(objectId)) {
    throw StateError('Object $objectId is already deleted');
  }

  // 2. Sync to get latest state
  await syncServiceRef.sync(db, config, networkConfigPath: networkConfigPath);

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
    throw StateError('Could not find settings tree for space');
  }

  // 5. Get current heads for the settings tree
  final settingsHeads = await db.getObjectHeads(settingsPayloadId);
  if (settingsHeads.isEmpty) {
    throw StateError('No heads found for settings tree');
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
    throw StateError('Could not find root change for settings tree');
  }

  final objectHeads = await db.getObjectHeads(objectId);
  if (objectHeads.isEmpty) {
    throw StateError('No heads found for target object');
  }

  final objectChanges = await db.getChangesForObject(objectId);
  final objectRootId = _findRootChangeId(objectChanges);
  if (objectRootId == null) {
    throw StateError('Could not find root change for target object');
  }

  // 6. Archive the target object so official discovery surfaces treat the
  // object as deleted in the same way the official stack does.
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  final objectTreeKey = await deriveTreeKey(spaceKey, objectId);
  final settingsTreeKey = await deriveTreeKey(spaceKey, settingsPayloadId);

  final objectWriteMetadata = _resolveTreeWriteMetadata(
    objectChanges,
    objectHeads,
    fallbackAclHeadId: aclHeadId,
    fallbackSnapshotBaseId: objectRootId,
  );
  final archiveChangeData = marshalChangeContent([
    changes_proto.Change_Content(
      detailsSet: changes_proto.Change_DetailsSet(
        key: 'isArchived',
        value: Value(boolValue: true),
      ),
    ),
  ]);
  final archiveTreeChange = await buildTreeChange(
    currentHeads: objectHeads,
    aclHeadId: objectWriteMetadata.aclHeadId,
    snapshotBaseId: objectWriteMetadata.snapshotBaseId,
    changesData: await aesGcmEncrypt(objectTreeKey, archiveChangeData),
    identityPrivateKey: identity.accountSeed,
    readKeyId: objectWriteMetadata.readKeyId,
  );
  await db.insertChange(
    archiveTreeChange.id,
    objectId,
    archiveTreeChange.rawChange,
    jsonEncode(objectHeads),
  );

  // 7. Build SettingsData with ObjectDelete to preserve local delete
  // semantics and the existing settings-tree contract.
  final settingsData = SettingsData(
    content: [
      SpaceSettingsContent(
        objectDelete: ObjectDelete(id: objectId),
      ),
    ],
  );
  final settingsDataBytes = Uint8List.fromList(settingsData.writeToBuffer());

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
  await syncServiceRef.sync(db, config, networkConfigPath: networkConfigPath);

  return DeleteResult(objectId: objectId);
}

String? _findRootChangeId(List<Change> changes) {
  for (final change in changes) {
    final parents = jsonDecode(change.parentHeads) as List;
    if (parents.isEmpty) {
      return change.id;
    }
  }
  return null;
}

class _TreeWriteMetadata {
  const _TreeWriteMetadata({
    required this.aclHeadId,
    required this.snapshotBaseId,
    required this.readKeyId,
  });

  final String aclHeadId;
  final String snapshotBaseId;
  final String readKeyId;
}

_TreeWriteMetadata _resolveTreeWriteMetadata(
  List<Change> changes,
  List<String> currentHeads, {
  required String fallbackAclHeadId,
  required String fallbackSnapshotBaseId,
}) {
  final currentHeadSet = currentHeads.toSet();

  for (final stored in changes.reversed) {
    if (!currentHeadSet.contains(stored.id)) {
      continue;
    }
    final decoded = _decodeStoredTreeChange(stored);
    if (decoded == null) {
      continue;
    }
    final aclHeadId =
        decoded.aclHeadId.isNotEmpty ? decoded.aclHeadId : fallbackAclHeadId;
    final snapshotBaseId = decoded.isSnapshot
        ? stored.id
        : decoded.snapshotBaseId.isNotEmpty
            ? decoded.snapshotBaseId
            : fallbackSnapshotBaseId;
    final readKeyId =
        decoded.readKeyId.isNotEmpty ? decoded.readKeyId : aclHeadId;
    return _TreeWriteMetadata(
      aclHeadId: aclHeadId,
      snapshotBaseId: snapshotBaseId,
      readKeyId: readKeyId,
    );
  }

  return _TreeWriteMetadata(
    aclHeadId: fallbackAclHeadId,
    snapshotBaseId: fallbackSnapshotBaseId,
    readKeyId: fallbackAclHeadId,
  );
}

TreeChange? _decodeStoredTreeChange(Change stored) {
  try {
    final rawTreeChange = RawTreeChange.fromBuffer(stored.rawBytes);
    if (rawTreeChange.payload.isEmpty) {
      return null;
    }
    return TreeChange.fromBuffer(rawTreeChange.payload);
  } catch (_) {
    return null;
  }
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
