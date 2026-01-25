import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, TreeChange;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

import '../acl_codec.dart';
import '../config.dart';
import '../identity.dart';
import '../store/database.dart';
import '../sync_service.dart';

Future<void> editCommand(
  String objectId,
  String? newText,
  ManytypeDatabase db,
  CliConfig config, {
  required String networkConfigPath,
  bool checkbox = false,
  String? checkboxText,
  String? relationKey,
  String? boolValue,
  String? dateValue,
  String? objectIdValue,
  String? blockId,
  String? setText,
  bool? setChecked,
  Block_Content_Text_Style? setStyle,
  String? status,
  List<String>? tagIds,
  List<String> tagAdds = const <String>[],
  List<String> tagRemoves = const <String>[],
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

  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  final treeKey = await deriveTreeKey(spaceKey, objectId);

  var latestHeads = currentHeads;
  String? nameChangeId;

  // If newText is provided, update the page title via DetailsSet.
  if (newText != null) {
    final changeContent = changes_proto.Change_Content(
      detailsSet: changes_proto.Change_DetailsSet(
        key: 'name',
        value: Value(stringValue: newText),
      ),
    );
    final editChangeData = marshalChangeContent([changeContent]);

    final treeChange = await buildTreeChange(
      currentHeads: latestHeads,
      aclHeadId: aclHeadId,
      snapshotBaseId: snapshotBaseId,
      changesData: await aesGcmEncrypt(treeKey, editChangeData),
      identityPrivateKey: identity.accountSeed,
      readKeyId: aclHeadId,
    );

    await db.insertChange(
      treeChange.id,
      objectId,
      treeChange.rawChange,
      jsonEncode(latestHeads),
    );

    nameChangeId = treeChange.id;
    latestHeads = [treeChange.id];
  }

  String? blockChangeId;

  // If checkbox flag is set, append a checkbox block via BlockCreate.
  if (checkbox) {
    final rng = Random.secure();
    final blockId = 'cb-${rng.nextInt(0xFFFFFF).toRadixString(16)}';
    final cbText = checkboxText ?? 'Todo';
    final blockOp = changes_proto.Change_Content(
      blockCreate: changes_proto.Change_BlockCreate(
        targetId: 'header',
        position: Block_Position.Inner,
        blocks: [createListBlock(blockId, cbText, checkbox: true)],
      ),
    );
    final blockChangeData = marshalChangeContent([blockOp]);

    final blockTreeChange = await buildTreeChange(
      currentHeads: latestHeads,
      aclHeadId: aclHeadId,
      snapshotBaseId: snapshotBaseId,
      changesData: await aesGcmEncrypt(treeKey, blockChangeData),
      identityPrivateKey: identity.accountSeed,
      readKeyId: aclHeadId,
    );

    await db.insertChange(
      blockTreeChange.id,
      objectId,
      blockTreeChange.rawChange,
      jsonEncode(latestHeads),
    );

    blockChangeId = blockTreeChange.id;
    latestHeads = [blockTreeChange.id];
  }

  String? relationChangeId;

  // If a relation key is provided, build a DetailsSet with the typed Value.
  if (relationKey != null) {
    Value relationValue;
    if (boolValue != null) {
      relationValue = Value(boolValue: boolValue == 'true');
    } else if (dateValue != null) {
      relationValue = Value(numberValue: int.parse(dateValue).toDouble());
    } else if (objectIdValue != null) {
      relationValue = Value(stringValue: objectIdValue);
    } else if (status != null) {
      // Phase 38 D-05: single-value status write.
      relationValue = Value(stringValue: status);
    } else if (tagIds != null) {
      // Phase 38 D-06: tag full-replace list_value.
      relationValue = Value(
        listValue: ListValue(
          values: tagIds.map((id) => Value(stringValue: id)).toList(),
        ),
      );
    } else if (tagAdds.isNotEmpty || tagRemoves.isNotEmpty) {
      // Phase 38 D-07: read-modify-write tag delta. Replay the current
      // object details via manytype_core's shared helper, extract the
      // existing list_value for this relation key (if any), apply the
      // deltas idempotently (re-add/no-op, remove-missing/no-op), and
      // write the new full list. Uses `freshChanges` which reflects the
      // post-sync state loaded above.
      final rawBytesList = freshChanges
          .map((r) => Uint8List.fromList(r.rawBytes))
          .toList();
      final currentDetails = await replayObjectDetails(
        rawTreeChanges: rawBytesList,
        treeKey: treeKey,
      );

      final List<String> currentIds;
      final existing = currentDetails[relationKey];
      if (existing != null && existing.hasListValue()) {
        currentIds = existing.listValue.values
            .where((v) => v.hasStringValue())
            .map((v) => v.stringValue)
            .toList();
      } else {
        currentIds = <String>[];
      }

      final newIds = List<String>.from(currentIds);
      for (final id in tagAdds) {
        if (!newIds.contains(id)) newIds.add(id);
      }
      for (final id in tagRemoves) {
        newIds.remove(id);
      }

      relationValue = Value(
        listValue: ListValue(
          values: newIds.map((id) => Value(stringValue: id)).toList(),
        ),
      );
    } else {
      throw StateError('relation requires a typed value');
    }

    final relationContent = changes_proto.Change_Content(
      detailsSet: changes_proto.Change_DetailsSet(
        key: relationKey,
        value: relationValue,
      ),
    );
    final relationData = marshalChangeContent([relationContent]);

    final relationTreeChange = await buildTreeChange(
      currentHeads: latestHeads,
      aclHeadId: aclHeadId,
      snapshotBaseId: snapshotBaseId,
      changesData: await aesGcmEncrypt(treeKey, relationData),
      identityPrivateKey: identity.accountSeed,
      readKeyId: aclHeadId,
    );

    await db.insertChange(
      relationTreeChange.id,
      objectId,
      relationTreeChange.rawChange,
      jsonEncode(latestHeads),
    );

    relationChangeId = relationTreeChange.id;
    latestHeads = [relationTreeChange.id];
  }

  String? blockUpdateChangeId;
  String? blockUpdateDescription;

  // Branch D: BlockUpdate write path (BLKUPD-01/02/03). Absolute semantics
  // per D-07: we do NOT read current block state before writing. ID stability
  // is guaranteed because buildBlockSet* helpers target an existing block by
  // ID and never construct a new one.
  if (blockId != null) {
    final Uint8List eventBytes;
    if (setText != null) {
      eventBytes = buildBlockSetTextEvent(blockId, setText);
      blockUpdateDescription = 'set-text';
    } else if (setChecked != null) {
      eventBytes = buildBlockSetCheckedEvent(blockId, setChecked);
      blockUpdateDescription = 'set-checked=$setChecked';
    } else if (setStyle != null) {
      eventBytes = buildBlockSetStyleEvent(blockId, setStyle);
      blockUpdateDescription = 'set-style=${setStyle.name}';
    } else {
      throw StateError(
        '--block-id requires --set-text, --set-checked, or --set-style',
      );
    }

    final updateContent = changes_proto.Change_Content(
      blockUpdate: changes_proto.Change_BlockUpdate(events: [eventBytes]),
    );
    final updateData = marshalChangeContent([updateContent]);

    final updateTreeChange = await buildTreeChange(
      currentHeads: latestHeads,
      aclHeadId: aclHeadId,
      snapshotBaseId: snapshotBaseId,
      changesData: await aesGcmEncrypt(treeKey, updateData),
      identityPrivateKey: identity.accountSeed,
      readKeyId: aclHeadId,
    );

    await db.insertChange(
      updateTreeChange.id,
      objectId,
      updateTreeChange.rawChange,
      jsonEncode(latestHeads),
    );

    blockUpdateChangeId = updateTreeChange.id;
    latestHeads = [updateTreeChange.id];
  }

  await syncService.sync(db, config, networkConfigPath: networkConfigPath);

  // Verify text change if a name update was made.
  if (newText != null) {
    final verifyChanges = await db.getChangesForObject(objectId);
    final actual = await _extractTextPreviewWithTreeKey(verifyChanges, treeKey);
    if (actual != newText) {
      print(
        'Verification failed: server text "$actual" does not match expected "$newText"',
      );
      exit(1);
    }
  }

  print('Edited object: $objectId');
  if (nameChangeId != null) print('Name change: $nameChangeId');
  if (blockChangeId != null) print('Block change: $blockChangeId');
  if (relationChangeId != null) {
    if (status != null) {
      print('Set status: $relationKey = $status');
    } else if (tagIds != null) {
      print(
        'Set tag: $relationKey = [${tagIds.join(", ")}] (full replace, ${tagIds.length} values)',
      );
    } else if (tagAdds.isNotEmpty || tagRemoves.isNotEmpty) {
      print(
        'Updated tag: $relationKey '
        '(added: ${tagAdds.join(", ")}; removed: ${tagRemoves.join(", ")})',
      );
    } else {
      final displayValue = boolValue ?? dateValue ?? objectIdValue ?? '';
      print('Relation change: $relationChangeId ($relationKey = $displayValue)');
    }
  }
  if (blockUpdateChangeId != null) {
    print(
      'Block update: $blockUpdateChangeId (block-id=$blockId, $blockUpdateDescription)',
    );
  }
}

Future<String> _extractTextPreviewWithTreeKey(
  List<Change> changes,
  Uint8List treeKey,
) async {
  for (final stored in changes.reversed) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(stored.rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;

      final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      if (treeChange.changesData.isEmpty) continue;

      var data = Uint8List.fromList(treeChange.changesData);
      if (treeChange.readKeyId.isNotEmpty) {
        data = await aesGcmDecrypt(treeKey, data);
      }

      final decoded = changes_proto.Change.fromBuffer(data);

      if (decoded.hasSnapshot()) {
        final snapshot = decoded.snapshot.data;
        for (final block in snapshot.blocks) {
          if (block.hasText()) {
            final text = block.text.text.trim();
            if (text.isNotEmpty) return text;
          }
        }
      }

      for (final content in decoded.content) {
        if (content.hasDetailsSet() &&
            content.detailsSet.key == 'name' &&
            content.detailsSet.value.hasStringValue()) {
          final title = content.detailsSet.value.stringValue.trim();
          if (title.isNotEmpty) return title;
        }
        if (content.hasBlockUpdate()) {
          for (final eventBytes in content.blockUpdate.events) {
            try {
              final eventMsg = Event_Message.fromBuffer(eventBytes);
              if (eventMsg.hasBlockSetText()) {
                final text = eventMsg.blockSetText.text.value.trim();
                if (text.isNotEmpty) return text;
              }
            } catch (_) {
              continue;
            }
          }
        }
      }
    } catch (_) {
      continue;
    }
  }

  return '';
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
      final aclRoot =
          tryDecodeAclRootFromRawRecordBytes(Uint8List.fromList(changes.first.rawBytes));
      if (aclRoot != null && aclRoot.spaceId == spaceId) {
        return object.id;
      }
    } catch (_) {
      continue;
    }
  }
  throw StateError('Space bootstrap is missing an ACL root');
}
