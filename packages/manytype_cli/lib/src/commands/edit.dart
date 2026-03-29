import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:libcompress/src/snappy/snappy_codec.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, TreeChange;
import 'package:path/path.dart' as p;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

import '../acl_codec.dart';
import '../collection_keys.dart';
import '../config.dart';
import '../identity.dart';
import '../store/database.dart';
import '../sync_service.dart';
import 'file_transfer.dart';

final _snappy = SnappyCodec();

Future<void> editCommand(
  String objectId,
  String? newText,
  ManytypeDatabase db,
  CliConfig config, {
  required String networkConfigPath,
  SyncService? syncService,
  bool checkbox = false,
  String? checkboxText,
  String? relationKey,
  String? stringValue,
  List<String>? stringListValue,
  String? boolValue,
  String? dateValue,
  String? fileRelationPath,
  String? objectIdValue,
  String? blockId,
  String? setText,
  bool? setChecked,
  Block_Content_Text_Style? setStyle,
  String? status,
  List<String>? tagIds,
  List<String> tagAdds = const <String>[],
  List<String> tagRemoves = const <String>[],
  String? collectionAddId,
  String? collectionRemoveId,
  String? collectionMoveId,
  String afterId = '',
}) async {
  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    print('Object not found locally — run `manytype sync` first');
    exit(1);
  }

  syncService ??= SyncService();
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
  final fallbackAclHeadId = await _findAclRootId(db, allObjects, spaceId);

  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  final treeKey = await deriveTreeKey(spaceKey, objectId);
  final treeWriteMetadata = _resolveTreeWriteMetadata(
    freshChanges,
    currentHeads,
    fallbackAclHeadId: fallbackAclHeadId,
    fallbackSnapshotBaseId: snapshotBaseId,
  );
  final aclHeadId = treeWriteMetadata.aclHeadId;
  snapshotBaseId = treeWriteMetadata.snapshotBaseId;
  final readKeyId = treeWriteMetadata.readKeyId;

  var latestHeads = currentHeads;
  String? textChangeId;

  // If newText is provided, update both the canonical object name and the
  // primary rendered text block so official clients observe the same value.
  if (newText != null) {
    final textBlockId =
        await _resolvePrimaryTextBlockId(freshChanges, treeKey) ?? 'title';
    final changeContents = <changes_proto.Change_Content>[
      changes_proto.Change_Content(
        detailsSet: changes_proto.Change_DetailsSet(
          key: 'name',
          value: Value(stringValue: newText),
        ),
      ),
      changes_proto.Change_Content(
        blockUpdate: changes_proto.Change_BlockUpdate(
          events: [buildBlockSetTextEvent(textBlockId, newText)],
        ),
      ),
    ];
    final editChangeData = marshalChangeContent(changeContents);

    final treeChange = await buildTreeChange(
      currentHeads: latestHeads,
      aclHeadId: aclHeadId,
      snapshotBaseId: snapshotBaseId,
      changesData: await aesGcmEncrypt(treeKey, editChangeData),
      identityPrivateKey: identity.accountSeed,
      readKeyId: readKeyId,
    );

    await db.insertChange(
      treeChange.id,
      objectId,
      treeChange.rawChange,
      jsonEncode(latestHeads),
    );

    textChangeId = treeChange.id;
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
      readKeyId: readKeyId,
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
  _FileRelationWriteResult? fileRelationResult;
  Value? expectedRelationValue;

  // If a relation key is provided, build a DetailsSet with the typed Value.
  if (relationKey != null) {
    Value relationValue;
    if (fileRelationPath != null) {
      fileRelationResult = await _createFileObjectForRelation(
        db: db,
        config: config,
        networkConfigPath: networkConfigPath,
        identity: identity,
        spaceId: spaceId,
        spaceKey: spaceKey,
        aclHeadId: aclHeadId,
        sourcePath: fileRelationPath,
      );
      relationValue = Value(stringValue: fileRelationResult.fileObjectId);
    } else if (stringValue != null) {
      relationValue = Value(stringValue: stringValue);
    } else if (stringListValue != null) {
      relationValue = Value(
        listValue: ListValue(
          values: stringListValue
              .map((value) => Value(stringValue: value))
              .toList(),
        ),
      );
    } else if (boolValue != null) {
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
      final rawBytesList =
          freshChanges.map((r) => Uint8List.fromList(r.rawBytes)).toList();
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
    expectedRelationValue = relationValue.deepCopy();

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
      readKeyId: readKeyId,
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
  String? collectionChangeId;
  String? collectionChangeDescription;

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
      readKeyId: readKeyId,
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

  if (collectionAddId != null ||
      collectionRemoveId != null ||
      collectionMoveId != null) {
    final collectionState = await _loadCollectionState(
      freshChanges,
      treeKey,
    );
    if (collectionState == null) {
      print('Error: object $objectId is not a collection');
      exit(1);
    }

    final storeKey = collectionState.storeKey;
    final memberIds = collectionState.memberIds;
    final memberId = collectionAddId ?? collectionRemoveId ?? collectionMoveId!;

    changes_proto.Change_Content? collectionOp;
    if (collectionAddId != null) {
      if (!memberIds.contains(collectionAddId)) {
        collectionOp = buildStoreSliceUpdateAdd(
          key: storeKey,
          ids: [collectionAddId],
        );
      }
      collectionChangeDescription = 'collection-add=$collectionAddId';
    } else if (collectionRemoveId != null) {
      if (memberIds.contains(collectionRemoveId)) {
        collectionOp = buildStoreSliceUpdateRemove(
          key: storeKey,
          ids: [collectionRemoveId],
        );
      }
      collectionChangeDescription = 'collection-remove=$collectionRemoveId';
    } else {
      if (!memberIds.contains(memberId)) {
        print(
          'Error: collection member $memberId is not present in $objectId',
        );
        exit(1);
      }
      collectionOp = buildStoreSliceUpdateMove(
        key: storeKey,
        ids: [memberId],
        afterId: afterId,
      );
      collectionChangeDescription = 'collection-move=$memberId after=$afterId';
    }

    if (collectionOp != null) {
      final collectionData = marshalChangeContent([collectionOp]);
      final collectionTreeChange = await buildTreeChange(
        currentHeads: latestHeads,
        aclHeadId: aclHeadId,
        snapshotBaseId: snapshotBaseId,
        changesData: await aesGcmEncrypt(treeKey, collectionData),
        identityPrivateKey: identity.accountSeed,
        readKeyId: readKeyId,
      );

      await db.insertChange(
        collectionTreeChange.id,
        objectId,
        collectionTreeChange.rawChange,
        jsonEncode(latestHeads),
      );

      collectionChangeId = collectionTreeChange.id;
      latestHeads = [collectionTreeChange.id];
    }
  }

  await syncService.sync(db, config, networkConfigPath: networkConfigPath);

  // Verify text change updates both the object name and the rendered text.
  if (newText != null) {
    final verifyChanges = await db.getChangesForObject(objectId);
    final replayed = await replayObjectState(
      rawTreeChanges: verifyChanges
          .map((row) => Uint8List.fromList(row.rawBytes))
          .toList(growable: false),
      treeKey: treeKey,
    );
    final actualName =
        replayed.snapshot.details.fields['name']?.stringValue.trim() ?? '';
    final actualText = _extractPrimaryTextBlockText(replayed.snapshot) ?? '';
    if (actualName != newText || actualText != newText) {
      print(
        'Verification failed: name="$actualName" text="$actualText" '
        'does not match expected "$newText"',
      );
      exit(1);
    }
  }
  if (relationKey != null && fileRelationResult != null) {
    final verifyChanges = await db.getChangesForObject(objectId);
    final actualDetails = await replayObjectDetails(
      rawTreeChanges: verifyChanges
          .map((row) => Uint8List.fromList(row.rawBytes))
          .toList(growable: false),
      treeKey: treeKey,
    );
    final actualValue = actualDetails[relationKey];
    if (!_detailValuesEqual(actualValue, expectedRelationValue)) {
      print(
        'Verification failed: relation $relationKey does not match the '
        'expected value after sync',
      );
      exit(1);
    }
    final fileObjectChanges =
        await db.getChangesForObject(fileRelationResult.fileObjectId);
    if (fileObjectChanges.isEmpty) {
      print(
        'Verification failed: FileObject ${fileRelationResult.fileObjectId} '
        'is missing locally after sync',
      );
      exit(1);
    }
  } else if (relationKey != null && expectedRelationValue != null) {
    final verifyChanges = await db.getChangesForObject(objectId);
    final actualDetails = await replayObjectDetails(
      rawTreeChanges: verifyChanges
          .map((row) => Uint8List.fromList(row.rawBytes))
          .toList(growable: false),
      treeKey: treeKey,
    );
    final actualValue = actualDetails[relationKey];
    if (!_detailValuesEqual(actualValue, expectedRelationValue)) {
      print(
        'Verification failed: relation $relationKey does not match the '
        'expected value after sync',
      );
      exit(1);
    }
  }

  print('Edited object: $objectId');
  if (textChangeId != null) print('Text change: $textChangeId');
  if (blockChangeId != null) print('Block change: $blockChangeId');
  if (relationChangeId != null) {
    if (fileRelationResult != null) {
      final mimeSuffix = _hasSpecificMime(fileRelationResult.mime)
          ? ' (${fileRelationResult.mime})'
          : '';
      print(
        'Relation change: $relationChangeId '
        '($relationKey = ${fileRelationResult.fileObjectId})',
      );
      print(
        'FileObject: ${fileRelationResult.fileObjectId} '
        '[${fileRelationResult.fileName}$mimeSuffix, '
        'cid=${fileRelationResult.cid}, '
        '${fileRelationResult.uploaded ? "uploaded" : "existing-blob"}]',
      );
    } else if (stringValue != null) {
      print('Set detail: $relationKey = $stringValue');
    } else if (stringListValue != null) {
      print('Set detail list: $relationKey = [${stringListValue.join(", ")}]');
    } else if (status != null) {
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
      print(
          'Relation change: $relationChangeId ($relationKey = $displayValue)');
    }
  }
  if (blockUpdateChangeId != null) {
    print(
      'Block update: $blockUpdateChangeId (block-id=$blockId, $blockUpdateDescription)',
    );
  }
  if (collectionChangeDescription != null) {
    if (collectionChangeId != null) {
      print(
        'Collection change: $collectionChangeId ($collectionChangeDescription)',
      );
    } else {
      print('Collection change: no-op ($collectionChangeDescription)');
    }
  }
}

Future<({String storeKey, List<String> memberIds})?> _loadCollectionState(
  List<Change> changes,
  Uint8List treeKey,
) async {
  final blocks = <String, Block>{};
  final collections = <String, List<String>>{};

  for (final stored in changes) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(stored.rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;

      final TreeChange treeChange;
      try {
        treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      } catch (_) {
        continue;
      }
      if (treeChange.changesData.isEmpty) continue;

      final decoded = await _decodeTreeChangeData(
        treeChange,
        treeKey,
      );
      final change = changes_proto.Change.fromBuffer(decoded);

      if (change.hasSnapshot()) {
        blocks
          ..clear()
          ..addEntries(
            change.snapshot.data.blocks.map(
              (block) => MapEntry(block.id, block.deepCopy()),
            ),
          );
        collections
          ..clear()
          ..addAll(_collectionsFromSnapshot(change.snapshot.data.collections));
        continue;
      }

      for (final content in change.content) {
        if (content.hasBlockCreate()) {
          for (final block in content.blockCreate.blocks) {
            blocks[block.id] = block.deepCopy();
          }
        }
        if (content.hasStoreSliceUpdate()) {
          final key = content.storeSliceUpdate.key;
          final current =
              List<String>.from(collections[key] ?? const <String>[]);
          switch (content.storeSliceUpdate.whichOperation()) {
            case changes_proto.Change_StoreSliceUpdate_Operation.add:
              _insertAfterId(
                current,
                content.storeSliceUpdate.add.afterId,
                content.storeSliceUpdate.add.ids,
              );
              collections[key] = current;
              break;
            case changes_proto.Change_StoreSliceUpdate_Operation.remove:
              current.removeWhere(content.storeSliceUpdate.remove.ids.contains);
              collections[key] = current;
              break;
            case changes_proto.Change_StoreSliceUpdate_Operation.move:
              current.removeWhere(content.storeSliceUpdate.move.ids.contains);
              _insertAfterId(
                current,
                content.storeSliceUpdate.move.afterId,
                content.storeSliceUpdate.move.ids,
              );
              collections[key] = current;
              break;
            case changes_proto.Change_StoreSliceUpdate_Operation.notSet:
              break;
          }
        }
      }
    } catch (_) {
      continue;
    }
  }

  Block? dataviewBlock;
  for (final block in blocks.values) {
    if (block.hasDataview() && block.dataview.isCollection) {
      dataviewBlock = block;
      break;
    }
  }
  if (dataviewBlock == null || dataviewBlock.dataview.views.isEmpty) {
    return null;
  }

  final storeKey = resolveCollectionStoreKeyFromLists(
    dataviewBlock.dataview,
    collections,
  );
  return (
    storeKey: storeKey,
    memberIds: List<String>.from(
      collections[storeKey] ?? const <String>[],
    ),
  );
}

bool _detailValuesEqual(Value? actual, Value? expected) {
  if (actual == null || expected == null) {
    return actual == expected;
  }
  if (actual.hasStringValue() && expected.hasStringValue()) {
    return actual.stringValue == expected.stringValue;
  }
  if (actual.hasBoolValue() && expected.hasBoolValue()) {
    return actual.boolValue == expected.boolValue;
  }
  if (actual.hasNumberValue() && expected.hasNumberValue()) {
    return actual.numberValue == expected.numberValue;
  }
  if (actual.hasListValue() && expected.hasListValue()) {
    final actualValues = actual.listValue.values
        .where((value) => value.hasStringValue())
        .map((value) => value.stringValue)
        .toList(growable: false);
    final expectedValues = expected.listValue.values
        .where((value) => value.hasStringValue())
        .map((value) => value.stringValue)
        .toList(growable: false);
    return _stringListsEqual(actualValues, expectedValues);
  }
  return false;
}

bool _stringListsEqual(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

Future<Uint8List> _decodeTreeChangeData(
  TreeChange treeChange,
  Uint8List treeKey,
) async {
  var data = Uint8List.fromList(treeChange.changesData);
  if (treeChange.readKeyId.isNotEmpty) {
    data = await aesGcmDecrypt(treeKey, data);
  }
  if (treeChange.dataType == '1/s') {
    data = _snappy.decompress(data);
  }
  return data;
}

Map<String, List<String>> _collectionsFromSnapshot(Struct snapshotCollections) {
  final collections = <String, List<String>>{};
  for (final entry in snapshotCollections.fields.entries) {
    if (!entry.value.hasListValue()) continue;
    collections[entry.key] = entry.value.listValue.values
        .where((value) => value.hasStringValue())
        .map((value) => value.stringValue)
        .toList();
  }
  return collections;
}

void _insertAfterId(
  List<String> current,
  String afterId,
  Iterable<String> ids,
) {
  final values = ids.toList();
  if (values.isEmpty) return;

  if (afterId.isEmpty) {
    current.insertAll(0, values);
    return;
  }

  final index = current.indexOf(afterId);
  if (index < 0) {
    current.addAll(values);
    return;
  }
  current.insertAll(index + 1, values);
}

Future<String?> _resolvePrimaryTextBlockId(
  List<Change> changes,
  Uint8List treeKey,
) async {
  final replayed = await replayObjectState(
    rawTreeChanges: changes
        .map((change) => Uint8List.fromList(change.rawBytes))
        .toList(growable: false),
    treeKey: treeKey,
  );
  return _primaryTextBlockId(replayed.snapshot);
}

String? _primaryTextBlockId(SmartBlockSnapshotBase snapshot) {
  for (final block in snapshot.blocks) {
    if (block.id == 'title' && block.hasText()) {
      return block.id;
    }
  }
  for (final block in snapshot.blocks) {
    if (block.hasText()) {
      return block.id;
    }
  }
  return null;
}

String? _extractPrimaryTextBlockText(SmartBlockSnapshotBase snapshot) {
  final blockId = _primaryTextBlockId(snapshot);
  if (blockId == null) {
    return null;
  }
  for (final block in snapshot.blocks) {
    if (block.id == blockId && block.hasText()) {
      return block.text.text.trim();
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
    for (final change in changes) {
      try {
        final aclRoot = tryDecodeAclRootFromRawRecordBytes(
          Uint8List.fromList(change.rawBytes),
        );
        if (aclRoot != null && aclRoot.spaceId == spaceId) {
          return object.id;
        }
      } catch (_) {
        continue;
      }
    }
  }
  throw StateError('Space bootstrap is missing an ACL root');
}

class _FileRelationWriteResult {
  const _FileRelationWriteResult({
    required this.fileObjectId,
    required this.cid,
    required this.fileName,
    required this.mime,
    required this.uploaded,
  });

  final String fileObjectId;
  final String cid;
  final String fileName;
  final String mime;
  final bool uploaded;
}

Future<_FileRelationWriteResult> _createFileObjectForRelation({
  required ManytypeDatabase db,
  required CliConfig config,
  required String networkConfigPath,
  required Identity identity,
  required String spaceId,
  required Uint8List spaceKey,
  required String aclHeadId,
  required String sourcePath,
}) async {
  final sourceFile = File(sourcePath);
  if (!await sourceFile.exists()) {
    throw StateError('Source file not found: $sourcePath');
  }

  final bytes = await sourceFile.readAsBytes();
  final rawName = p.basename(sourceFile.path).trim();
  final fileName = rawName.isEmpty ? 'attachment' : rawName;
  final mime = _inferMimeType(fileName);
  final layout = _layoutForMime(mime);
  final fileType = _fileBlockTypeForMime(mime);
  final addedAt = Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000);

  final rootChange = await buildRootChange(
    spaceId: spaceId,
    aclHeadId: aclHeadId,
    identityPrivateKey: identity.accountSeed,
    changePayload: _encodeObjectChangePayloadSmartblockType(
      SmartBlockType.FileObject.value,
    ),
  );
  final fileObjectId = rootChange.id;

  final uploadResult = await uploadBlobWithNetworkConfig(
    db,
    config,
    networkConfigPath: networkConfigPath,
    identity: identity,
    fileId: fileObjectId,
    bytes: bytes,
  );

  final snapshotBase = createMinimalPageSnapshotBase(
    objectId: fileObjectId,
    title: fileName,
  );
  snapshotBase.details = Struct()
    ..fields['name'] = Value(stringValue: fileName)
    ..fields['layout'] = Value(numberValue: layout.toDouble())
    ..fields['mime'] = Value(stringValue: mime)
    ..fields['sizeInBytes'] = Value(numberValue: bytes.length.toDouble())
    ..fields['tag'] = Value(listValue: ListValue())
    ..fields['internalFlags'] = Value(listValue: ListValue());
  snapshotBase.fileInfo = FileInfo(fileId: fileObjectId);

  final headerBlock =
      snapshotBase.blocks.firstWhere((block) => block.id == 'header');
  headerBlock.childrenIds.add('file');
  snapshotBase.blocks.add(
    Block(
      id: 'file',
      file: Block_Content_File(
        hash: uploadResult.cid,
        name: fileName,
        type: fileType,
        mime: mime,
        size: Int64(bytes.length),
        addedAt: addedAt,
        state: Block_Content_File_State.Done,
        style: Block_Content_File_Style.Auto,
        targetObjectId: fileObjectId,
      ),
    ),
  );

  final snapshotChangeBytes = Uint8List.fromList(
    changes_proto.Change(
      snapshot: changes_proto.Change_Snapshot(
        data: snapshotBase,
        fileKeys: [
          changes_proto.Change_FileKeys(hash: uploadResult.cid),
        ],
      ),
    ).writeToBuffer(),
  );
  final fileTreeKey = await deriveTreeKey(spaceKey, fileObjectId);
  final snapshotChange = await buildTreeChange(
    currentHeads: [rootChange.id],
    aclHeadId: aclHeadId,
    snapshotBaseId: rootChange.id,
    changesData: await aesGcmEncrypt(fileTreeKey, snapshotChangeBytes),
    identityPrivateKey: identity.accountSeed,
    isSnapshot: true,
    readKeyId: aclHeadId,
  );

  await db.insertObject(fileObjectId, spaceId);
  await db.insertChange(
    rootChange.id,
    fileObjectId,
    rootChange.rawChange,
    jsonEncode([]),
  );
  await db.insertChange(
    snapshotChange.id,
    fileObjectId,
    snapshotChange.rawChange,
    jsonEncode([rootChange.id]),
  );
  await db.upsertAttachmentRef(
    spaceId: spaceId,
    objectId: fileObjectId,
    fileId: fileObjectId,
    cid: uploadResult.cid,
  );

  return _FileRelationWriteResult(
    fileObjectId: fileObjectId,
    cid: uploadResult.cid,
    fileName: fileName,
    mime: mime,
    uploaded: uploadResult.uploaded,
  );
}

String _inferMimeType(String fileName) {
  final extension = p.extension(fileName).toLowerCase();
  return switch (extension) {
    '.pdf' => 'application/pdf',
    '.png' => 'image/png',
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.gif' => 'image/gif',
    '.webp' => 'image/webp',
    '.bmp' => 'image/bmp',
    '.svg' => 'image/svg+xml',
    '.tif' || '.tiff' => 'image/tiff',
    '.heic' => 'image/heic',
    '.heif' => 'image/heif',
    '.mp3' => 'audio/mpeg',
    '.wav' => 'audio/wav',
    '.ogg' => 'audio/ogg',
    '.m4a' => 'audio/mp4',
    '.aac' => 'audio/aac',
    '.flac' => 'audio/flac',
    '.mp4' => 'video/mp4',
    '.mov' => 'video/quicktime',
    '.m4v' => 'video/x-m4v',
    '.webm' => 'video/webm',
    '.mkv' => 'video/x-matroska',
    '.avi' => 'video/x-msvideo',
    _ => 'application/octet-stream',
  };
}

int _layoutForMime(String mime) {
  if (mime == 'application/pdf') {
    return 20;
  }
  if (mime.startsWith('image/')) {
    return 8;
  }
  if (mime.startsWith('audio/')) {
    return 15;
  }
  if (mime.startsWith('video/')) {
    return 16;
  }
  return 6;
}

Block_Content_File_Type _fileBlockTypeForMime(String mime) {
  if (mime == 'application/pdf') {
    return Block_Content_File_Type.PDF;
  }
  if (mime.startsWith('image/')) {
    return Block_Content_File_Type.Image;
  }
  if (mime.startsWith('audio/')) {
    return Block_Content_File_Type.Audio;
  }
  if (mime.startsWith('video/')) {
    return Block_Content_File_Type.Video;
  }
  return Block_Content_File_Type.File;
}

bool _hasSpecificMime(String mime) =>
    mime.isNotEmpty && mime != 'application/octet-stream';

Uint8List _encodeVarint(int value) {
  var v = value;
  final out = <int>[];
  while (v >= 0x80) {
    out.add((v & 0x7f) | 0x80);
    v >>= 7;
  }
  out.add(v & 0x7f);
  return Uint8List.fromList(out);
}

Uint8List _encodeObjectChangePayloadSmartblockType(int smartBlockType) {
  final bytes = BytesBuilder()
    ..addByte(0x08)
    ..add(_encodeVarint(smartBlockType));
  return bytes.toBytes();
}
