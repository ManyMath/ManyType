import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/manytype_protocol.dart' show AclRoot;

import '../config.dart';
import '../identity.dart';
import '../store/database.dart';
import '../sync_service.dart';
import 'read.dart';

Future<void> editCommand(
  String objectId,
  String newText,
  ManytypeDatabase db,
  CliConfig config, {
  required String networkConfigPath,
}) async {
  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    print('Object not found locally — run `manytype sync` first');
    exit(1);
  }

  final syncService = SyncService();
  await syncService.sync(db, config, networkConfigPath: networkConfigPath);

  final freshChanges = await db.getChangesForObject(objectId);
  final currentHeads = await db.getObjectHeads(objectId);
  if (currentHeads.isEmpty) {
    print('No heads found for object $objectId after sync');
    exit(1);
  }

  String? snapshotBaseId;
  for (final c in freshChanges) {
    final parents = jsonDecode(c.parentHeads) as List;
    if (parents.isEmpty) {
      snapshotBaseId = c.id;
      break;
    }
  }
  if (snapshotBaseId == null) {
    print('Could not find root change for object $objectId');
    exit(1);
  }

  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = identity.spaceId;
  final allObjects = await db.getObjectsBySpace(spaceId);
  final aclHeadId = await _findAclRootId(db, allObjects, spaceId);

  // Block ID 'block-1' is the established convention for locally-created
  // note objects in this repository's object tree builder.
  final textValue = Event_Block_Set_Text_TextValue(value: newText);
  final setText = Event_Block_Set_Text(id: 'block-1', text: textValue);
  final eventMsg = Event_Message(blockSetText: setText);
  final eventBytes = Uint8List.fromList(eventMsg.writeToBuffer());

  final changeContent = Change_Content(
    blockUpdate: Change_BlockUpdate(events: [eventBytes]),
  );
  final editChangeData = marshalChangeContent([changeContent]);

  final treeChange = await buildTreeChange(
    currentHeads: currentHeads,
    aclHeadId: aclHeadId,
    snapshotBaseId: snapshotBaseId,
    changesData: editChangeData,
    identityPrivateKey: identity.accountSeed,
  );

  await db.insertChange(
    treeChange.id,
    objectId,
    treeChange.rawChange,
    jsonEncode(currentHeads),
  );

  await syncService.sync(db, config, networkConfigPath: networkConfigPath);

  final verifyChanges = await db.getChangesForObject(objectId);
  final actual = extractTextPreview(verifyChanges);
  if (actual != newText) {
    print(
      'Verification failed: server text "$actual" does not match expected "$newText"',
    );
    exit(1);
  }

  print('Edited object: $objectId');
  print('New change: ${treeChange.id}');
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
      final rawRecord = RawRecord.fromBuffer(changes.first.rawBytes);
      final aclRoot = AclRoot.fromBuffer(rawRecord.payload);
      if (aclRoot.spaceId == spaceId) {
        return object.id;
      }
    } catch (_) {
      continue;
    }
  }
  throw StateError('Space bootstrap is missing an ACL root');
}
