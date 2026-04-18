import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show AclRoot, Key, KeyType, RawTreeChange, RawTreeChangeWithId, TreeChange;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

import '../acl_codec.dart';
import '../collection_keys.dart';
import '../config.dart';
import '../identity.dart';
import '../store/database.dart' hide Change;

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

/// Protobuf encoding for anytype `model.ObjectChangePayload` with only
/// `smartBlockType` set.
///
/// We intentionally omit the `key` field when empty to match official
/// marshaling behavior (empty strings are not serialized).
Uint8List _encodeObjectChangePayloadSmartblockType(int smartBlockType) {
  // field 1 (varint): smartBlockType => tag = 0x08
  final bytes = BytesBuilder()
    ..addByte(0x08)
    ..add(_encodeVarint(smartBlockType));
  return bytes.toBytes();
}

/// Convert a human-readable name to a URL-safe unique key.
String _toUniqueKey(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'-+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

/// Map a CLI format string to a [RelationFormat] enum value.
///
/// Phase 38: `status` and `tag` are recognized as valid formats so that
/// `create --as-relation --format status` / `--format tag` produces a
/// parent STRelation whose RelationFormat enum matches what read.dart's
/// `_formatOptionRelationValue` intercepts. Without this, `--as-relation`
/// defaults to `longtext` and status/tag option resolution never activates
/// on reads (the generic relation path runs instead).
RelationFormat _parseRelationFormat(String? format) {
  return switch (format?.toLowerCase()) {
    'text' || null => RelationFormat.longtext,
    'shorttext' => RelationFormat.shorttext,
    'number' => RelationFormat.number,
    'date' => RelationFormat.date,
    'file' => RelationFormat.file,
    'checkbox' => RelationFormat.checkbox,
    'url' => RelationFormat.url,
    'email' => RelationFormat.email,
    'phone' => RelationFormat.phone,
    'object' => RelationFormat.object,
    'status' => RelationFormat.status,
    'tag' => RelationFormat.tag,
    _ => RelationFormat.longtext,
  };
}

/// Records that a newly-created STRelationOption was appended to its parent
/// STRelation's `selectDict` (Phase 38: only set for `--as-relation-option`).
class AppendedRelationOption {
  const AppendedRelationOption({
    required this.parentStRelationId,
    required this.selectDictSize,
  });

  final String parentStRelationId;
  final int selectDictSize;
}

/// Result of [createCommand].
class CreateResult {
  const CreateResult({
    required this.objectId,
    required this.spaceId,
    required this.objectKind,
    required this.displayName,
    required this.changeCount,
    required this.spaceInitialized,
    this.appendedOption,
  });

  final String objectId;
  final String spaceId;
  final String objectKind;
  final String displayName;
  final int changeCount;
  final bool spaceInitialized;
  final AppendedRelationOption? appendedOption;
}

/// Create a new text object and persist to local store.
///
/// Builds an ObjectTree with a signed root change and a text block change,
/// then persists both changes to the drift SQLite database.
///
/// Per D-08: identity derived fresh from mnemonic.
/// Per D-07: persisted as normalized objects + changes rows.
Future<CreateResult> createCommand(
  String text,
  ManytypeDatabase db,
  CliConfig config, {
  bool checkbox = false,
  bool numberedList = false,
  bool toggle = false,
  bool quote = false,
  bool callout = false,
  bool asType = false,
  bool asRelation = false,
  bool asSet = false,
  bool asCollection = false,
  bool asTemplate = false,
  bool asRelationOption = false,
  String? name,
  String? format,
  String? sourceType,
  String? forRelation,
  String? targetObjectType,
  String? templateId,
  String? color,
  bool textProvided = true,
}) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = identity.spaceId;
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);

  // Check if space needs initialization (first object)
  final existingObjects = await db.getObjectsBySpace(spaceId);

  String aclHeadId;
  final spaceInitialized = existingObjects.isEmpty;
  if (spaceInitialized) {
    final aclRoot = await _buildDerivedAclRoot(
      spaceId: spaceId,
      accountSeed: identity.accountSeed,
      accountPublicKey: identity.accountKeyPair.publicKey,
    );
    final settingsRoot = await buildRootChange(
      spaceId: spaceId,
      aclHeadId: aclRoot.id,
      identityPrivateKey: identity.accountSeed,
      changeType: 'any-sync.space',
    );

    await db.insertObject(aclRoot.id, spaceId);
    await db.insertChange(
      aclRoot.id,
      aclRoot.id,
      aclRoot.payload,
      jsonEncode([]),
    );
    await db.insertObject(settingsRoot.id, spaceId);
    await db.insertChange(
      settingsRoot.id,
      settingsRoot.id,
      settingsRoot.rawChange,
      jsonEncode([]),
    );

    // Official Anytype clients expect these mandatory derived objects to exist
    // in every regular space (Home/Archive/Widgets/Workspace). Joined spaces do
    // not auto-create them, so missing trees prevents the space from loading.
    final derivedRoots = <({RawTreeChangeWithId root, String title})>[
      (
        root: await buildDerivedRootChange(
          spaceId: spaceId,
          changePayload: _encodeObjectChangePayloadSmartblockType(32),
        ),
        title: 'Home',
      ),
      (
        root: await buildDerivedRootChange(
          spaceId: spaceId,
          changePayload: _encodeObjectChangePayloadSmartblockType(48),
        ),
        title: 'Archive',
      ),
      (
        root: await buildDerivedRootChange(
          spaceId: spaceId,
          changePayload: _encodeObjectChangePayloadSmartblockType(112),
        ),
        title: 'Widgets',
      ),
      (
        root: await buildDerivedRootChange(
          spaceId: spaceId,
          changePayload: _encodeObjectChangePayloadSmartblockType(518),
        ),
        title: 'Workspace',
      ),
    ];
    for (final derived in derivedRoots) {
      await db.insertObject(derived.root.id, spaceId);
      await db.insertChange(
        derived.root.id,
        derived.root.id,
        derived.root.rawChange,
        jsonEncode([]),
      );

      // A derived root by itself can be treated as an "empty derived tree" and
      // ignored by official any-sync nodes. Add one minimal signed change so
      // the tree materializes remotely and joined spaces can load.
      final bootstrapContent = marshalChangeContent([
        Change_Content(
          detailsSet: Change_DetailsSet(
            key: 'title',
            value: Value(stringValue: derived.title),
          ),
        ),
      ]);
      final bootstrapChange = await buildTreeChange(
        currentHeads: [derived.root.id],
        aclHeadId: aclRoot.id,
        snapshotBaseId: derived.root.id,
        changesData: await aesGcmEncrypt(
          await deriveTreeKey(spaceKey, derived.root.id),
          bootstrapContent,
        ),
        identityPrivateKey: identity.accountSeed,
        readKeyId: aclRoot.id,
      );
      await db.insertChange(
        bootstrapChange.id,
        derived.root.id,
        bootstrapChange.rawChange,
        jsonEncode([derived.root.id]),
      );
    }

    aclHeadId = aclRoot.id;
  } else {
    aclHeadId = await _findAclRootId(db, existingObjects, spaceId);
  }

  // Determine SmartBlockType based on the requested creation mode.
  final int smartBlockTypeValue;
  if (asType) {
    smartBlockTypeValue = SmartBlockType.STType.value;
  } else if (asRelation) {
    smartBlockTypeValue = SmartBlockType.STRelation.value;
  } else if (asTemplate) {
    smartBlockTypeValue = SmartBlockType.Template.value;
  } else if (asRelationOption) {
    // Phase 38: STRelationOption SmartBlock (529 / 0x211)
    smartBlockTypeValue = smartBlockTypeRelationOption;
  } else {
    // Both sets and plain pages use Page SmartBlockType
    smartBlockTypeValue = SmartBlockType.Page.value;
  }

  // Build root change for new object tree
  final rootChange = await buildRootChange(
    spaceId: spaceId,
    aclHeadId: aclHeadId,
    identityPrivateKey: identity.accountSeed,
    changePayload: _encodeObjectChangePayloadSmartblockType(
      smartBlockTypeValue,
    ),
  );

  final objectId = rootChange.id;
  var displayName = name ?? text;

  // Build a minimal snapshot for official client compatibility.
  //
  // Official clients can treat some incremental BlockCreate-only histories as
  // "empty trees" during bootstrap. Creating a snapshot TreeChange ensures the
  // object materializes with a valid smartblock root + layout + content blocks.
  final SmartBlockSnapshotBase snapshotBase;
  if (templateId != null) {
    final prepared = await _buildSnapshotFromTemplate(
      db,
      spaceKey: spaceKey,
      templateId: templateId,
      objectId: objectId,
      requestedText: text,
      textProvided: textProvided,
    );
    snapshotBase = prepared.snapshot;
    displayName = prepared.displayName;
  } else {
    snapshotBase = createMinimalPageSnapshotBase(
      objectId: objectId,
      title: displayName,
    );
  }

  final rng = Random.secure();
  String _blockId(String prefix) =>
      '$prefix${rng.nextInt(0xFFFFFF).toRadixString(16)}';

  if (asType) {
    snapshotBase.objectTypes.add('ot-objectType');
    snapshotBase.details = Struct()
      ..fields['name'] = Value(stringValue: displayName)
      ..fields['uniqueKey'] = Value(stringValue: _toUniqueKey(displayName))
      ..fields['layout'] = Value(numberValue: 4.0)
      ..fields['tag'] = Value(listValue: ListValue())
      ..fields['internalFlags'] = Value(listValue: ListValue());
  } else if (asRelation) {
    snapshotBase.objectTypes.add('ot-relation');
    snapshotBase.details = Struct()
      ..fields['name'] = Value(stringValue: displayName)
      ..fields['uniqueKey'] = Value(stringValue: _toUniqueKey(displayName))
      ..fields['layout'] = Value(numberValue: 5.0)
      ..fields['relationFormat'] =
          Value(numberValue: _parseRelationFormat(format).value.toDouble())
      ..fields['tag'] = Value(listValue: ListValue())
      ..fields['internalFlags'] = Value(listValue: ListValue());
  } else if (asSet) {
    snapshotBase.objectTypes.add('ot-page');
    snapshotBase.details = Struct()
      ..fields['name'] = Value(stringValue: displayName)
      ..fields['layout'] = Value(numberValue: 3.0)
      ..fields['tag'] = Value(listValue: ListValue())
      ..fields['internalFlags'] = Value(listValue: ListValue());

    // Add Dataview block for set objects
    final dvBlockId = 'dv-${rng.nextInt(0xFFFFFF).toRadixString(16)}';
    final dvBlock = createDataviewBlock(dvBlockId, [sourceType ?? 'ot-page']);
    snapshotBase.blocks.add(dvBlock);
    // Insert Dataview block ID into header's childrenIds
    final headerBlock = snapshotBase.blocks.firstWhere((b) => b.id == 'header');
    headerBlock.childrenIds.add(dvBlockId);
  } else if (asCollection) {
    snapshotBase.objectTypes.add('ot-page');
    snapshotBase.details = Struct()
      ..fields['name'] = Value(stringValue: displayName)
      ..fields['layout'] = Value(numberValue: 14.0)
      ..fields['tag'] = Value(listValue: ListValue())
      ..fields['internalFlags'] = Value(listValue: ListValue());
    snapshotBase.collections = Struct()
      ..fields[officialCollectionStoreKey] = Value(listValue: ListValue());

    final dvBlockId = 'dv-${rng.nextInt(0xFFFFFF).toRadixString(16)}';
    final dvBlock = createDataviewBlock(
      dvBlockId,
      const <String>[],
      isCollection: true,
      viewId: officialCollectionViewId,
    );
    snapshotBase.blocks.add(dvBlock);
    final headerBlock = snapshotBase.blocks.firstWhere((b) => b.id == 'header');
    headerBlock.childrenIds.add(dvBlockId);
  } else if (asRelationOption) {
    // Phase 38: STRelationOption snapshot. bin/manytype.dart guarantees
    // forRelation/color are non-null and color is palette-validated.
    assert(forRelation != null, 'bin/manytype.dart validation guarantees this');
    assert(color != null, 'bin/manytype.dart validation guarantees this');
    snapshotBase.objectTypes.add('ot-relationOption');
    snapshotBase.details = buildRelationOptionDetails(
      name: displayName,
      color: color!,
      relationKey: forRelation!,
    );
  } else if (asTemplate) {
    assert(
      targetObjectType != null,
      'bin/manytype.dart validation guarantees this',
    );
    final targetType = await _resolveTargetObjectType(
      db,
      spaceKey: spaceKey,
      objectId: targetObjectType!,
    );
    snapshotBase.objectTypes
      ..clear()
      ..addAll(['ot-template', targetType.uniqueKey]);
    snapshotBase.details = Struct()
      ..fields['name'] = Value(stringValue: displayName)
      ..fields['targetObjectType'] = Value(
        stringValue: targetType.objectId,
      )
      ..fields['templateNamePrefillType'] = Value(
        numberValue: TemplateNamePrefillType.FromTemplateName.value.toDouble(),
      )
      ..fields['layout'] = Value(numberValue: 0.0)
      ..fields['tag'] = Value(listValue: ListValue())
      ..fields['internalFlags'] = Value(listValue: ListValue());
  } else {
    if (templateId == null) {
      snapshotBase.objectTypes.add('ot-page');
      snapshotBase.details = Struct()
        ..fields['name'] = Value(stringValue: text)
        ..fields['tag'] = Value(listValue: ListValue())
        ..fields['internalFlags'] = Value(listValue: ListValue());
    }
  }

  final initialContentBlocks = <Block>[];
  if (checkbox) {
    initialContentBlocks
        .add(createListBlock(_blockId('cb-'), text, checkbox: true));
  }
  if (numberedList) {
    initialContentBlocks
        .add(createListBlock(_blockId('num-'), text, numbered: true));
  }
  if (toggle) {
    initialContentBlocks.add(createToggleBlock(_blockId('tog-'), text));
  }
  if (quote) {
    initialContentBlocks.add(createQuoteBlock(_blockId('qt-'), text));
  }
  if (callout) {
    initialContentBlocks.add(createCalloutBlock(_blockId('co-'), text));
  }
  if (initialContentBlocks.isNotEmpty) {
    final headerBlock = snapshotBase.blocks.firstWhere((b) => b.id == 'header');
    headerBlock.childrenIds.addAll(
      initialContentBlocks.map((block) => block.id),
    );
    snapshotBase.blocks.addAll(initialContentBlocks);
  }

  final snapshotChangeBytes = Uint8List.fromList(
    Change(snapshot: Change_Snapshot(data: snapshotBase)).writeToBuffer(),
  );
  final treeKey = await deriveTreeKey(spaceKey, objectId);

  final treeChange = await buildTreeChange(
    currentHeads: [rootChange.id],
    aclHeadId: aclHeadId,
    snapshotBaseId: rootChange.id,
    changesData: await aesGcmEncrypt(treeKey, snapshotChangeBytes),
    identityPrivateKey: identity.accountSeed,
    isSnapshot: true,
    readKeyId: aclHeadId,
  );

  // Persist to local store
  await db.insertObject(objectId, spaceId);
  await db.insertChange(
    rootChange.id,
    objectId,
    rootChange.rawChange, // raw bytes
    jsonEncode([]), // root has no parents
  );
  await db.insertChange(
    treeChange.id,
    objectId,
    treeChange.rawChange, // raw bytes
    jsonEncode([rootChange.id]), // parent is root
  );

  int changeCount = 2;
  AppendedRelationOption? appendedOption;

  // Phase 38: atomic parent STRelation selectDict update (D-04). Executed
  // only for --as-relation-option. Finds the parent STRelation locally by
  // matching `uniqueKey` / `relationKey` against forRelation, replays its
  // details via replayObjectDetails, appends the new Relation_Option to
  // `selectDict`, and writes a DetailsSet on the parent's tree. This
  // prevents the dangling-reference class of bug called out in STATE.md : 
  // the option ID is referenceable the moment the STRelationOption exists.
  if (asRelationOption) {
    final allObjects = await db.getNonDeletedObjectsBySpace(spaceId);
    String? parentStRelationId;
    Uint8List? parentTreeKey;
    Map<String, Value>? parentDetails;

    for (final obj in allObjects) {
      if (obj.id == objectId) continue;
      final parentRawChanges = await db.getChangesForObject(obj.id);
      if (parentRawChanges.isEmpty) continue;
      final rawBytesList =
          parentRawChanges.map((r) => Uint8List.fromList(r.rawBytes)).toList();
      // Filter by smart_block_type == STRelation (527) via the root-change
      // varint helper shipped by Plan 01. This matches the list.dart pattern.
      final sbType = extractRootSmartBlockType(rawBytesList);
      if (sbType != SmartBlockType.STRelation.value) continue;

      final candidateTreeKey = await deriveTreeKey(spaceKey, obj.id);
      final Map<String, Value> candidateDetails;
      try {
        candidateDetails = await replayObjectDetails(
          rawTreeChanges: rawBytesList,
          treeKey: candidateTreeKey,
        );
      } catch (_) {
        continue;
      }

      // Match by uniqueKey (create.dart's existing STRelation pattern) or
      // relationKey as a defensive fallback. Accept exact match or a
      // `rel-<key>` prefixed form in case official clients stored it that
      // way.
      final storedUnique = candidateDetails['uniqueKey']?.stringValue ?? '';
      final storedRelKey = candidateDetails['relationKey']?.stringValue ?? '';
      final matches = storedUnique == forRelation ||
          storedUnique == 'rel-$forRelation' ||
          storedRelKey == forRelation ||
          storedRelKey == 'rel-$forRelation';
      if (!matches) continue;

      parentStRelationId = obj.id;
      parentTreeKey = candidateTreeKey;
      parentDetails = candidateDetails;
      break;
    }

    if (parentStRelationId == null) {
      throw StateError(
        'Cannot find parent STRelation with key "$forRelation" in the local '
        'store. Sync first, or create the relation via '
        '`create --as-relation --name <key>`. Dangling references prevented.',
      );
    }

    // Build the new Relation_Option proto entry. Relation.Option fields:
    // 1=id, 2=text, 3=color, 5=relationKey.
    final newOption = Relation_Option()
      ..id = objectId
      ..text = displayName
      ..color = color!
      ..relationKey = forRelation!;

    final currentSelectDict = parentDetails!['selectDict'];
    final updatedSelectDict =
        appendOptionToSelectDict(currentSelectDict, newOption);

    // Locate the parent's snapshot base (its root change: parents.isEmpty).
    final parentChanges = await db.getChangesForObject(parentStRelationId);
    String? parentSnapshotBaseId;
    for (final c in parentChanges) {
      final parents = jsonDecode(c.parentHeads) as List;
      if (parents.isEmpty) {
        parentSnapshotBaseId = c.id;
        break;
      }
    }
    if (parentSnapshotBaseId == null) {
      throw StateError(
        'Parent STRelation $parentStRelationId is missing a root change',
      );
    }

    final parentLatestHeads = await db.getObjectHeads(parentStRelationId);
    if (parentLatestHeads.isEmpty) {
      throw StateError(
        'Parent STRelation $parentStRelationId has no heads: cannot append',
      );
    }

    var parentWriteAclHeadId = aclHeadId;
    var parentWriteSnapshotBaseId = parentSnapshotBaseId;
    var parentWriteReadKeyId = aclHeadId;
    final parentHeadSet = parentLatestHeads.toSet();
    for (final stored in parentChanges.reversed) {
      if (!parentHeadSet.contains(stored.id)) {
        continue;
      }
      try {
        final rawTreeChange = RawTreeChange.fromBuffer(stored.rawBytes);
        if (rawTreeChange.payload.isEmpty) {
          continue;
        }
        final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
        if (treeChange.aclHeadId.isNotEmpty) {
          parentWriteAclHeadId = treeChange.aclHeadId;
        }
        if (treeChange.isSnapshot) {
          parentWriteSnapshotBaseId = stored.id;
        } else if (treeChange.snapshotBaseId.isNotEmpty) {
          parentWriteSnapshotBaseId = treeChange.snapshotBaseId;
        }
        if (treeChange.readKeyId.isNotEmpty) {
          parentWriteReadKeyId = treeChange.readKeyId;
        } else {
          parentWriteReadKeyId = parentWriteAclHeadId;
        }
        break;
      } catch (_) {
        continue;
      }
    }

    final detailsContent = Change_Content(
      detailsSet: Change_DetailsSet(
        key: 'selectDict',
        value: updatedSelectDict,
      ),
    );
    final detailsData = marshalChangeContent([detailsContent]);

    final parentTreeChange = await buildTreeChange(
      currentHeads: parentLatestHeads,
      aclHeadId: parentWriteAclHeadId,
      snapshotBaseId: parentWriteSnapshotBaseId,
      changesData: await aesGcmEncrypt(parentTreeKey!, detailsData),
      identityPrivateKey: identity.accountSeed,
      readKeyId: parentWriteReadKeyId,
    );

    await db.insertChange(
      parentTreeChange.id,
      parentStRelationId,
      parentTreeChange.rawChange,
      jsonEncode(parentLatestHeads),
    );

    appendedOption = AppendedRelationOption(
      parentStRelationId: parentStRelationId,
      selectDictSize: updatedSelectDict.listValue.values.length,
    );
  }

  final objectKind = asType
      ? 'type'
      : asRelation
          ? 'relation'
          : asSet
              ? 'set'
              : asCollection
                  ? 'collection'
                  : asTemplate
                      ? 'template'
                      : templateId != null
                          ? 'object'
                          : asRelationOption
                              ? 'relation-option'
                              : 'object';
  return CreateResult(
    objectId: objectId,
    spaceId: spaceId,
    objectKind: objectKind,
    displayName: displayName,
    changeCount: changeCount,
    spaceInitialized: spaceInitialized,
    appendedOption: appendedOption,
  );
}

class _ResolvedTargetObjectType {
  final String objectId;
  final String uniqueKey;

  const _ResolvedTargetObjectType({
    required this.objectId,
    required this.uniqueKey,
  });
}

class _PreparedSnapshot {
  final SmartBlockSnapshotBase snapshot;
  final String displayName;

  const _PreparedSnapshot({
    required this.snapshot,
    required this.displayName,
  });
}

Future<_ResolvedTargetObjectType> _resolveTargetObjectType(
  ManytypeDatabase db, {
  required Uint8List spaceKey,
  required String objectId,
}) async {
  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    throw StateError('Target object type not found: $objectId');
  }

  final rawTreeChanges =
      changes.map((change) => Uint8List.fromList(change.rawBytes)).toList();
  final smartBlockType = extractRootSmartBlockType(rawTreeChanges);
  if (smartBlockType != SmartBlockType.STType.value) {
    throw StateError(
      'Target object $objectId is not an STType (smart block type '
      '$smartBlockType)',
    );
  }

  final treeKey = await deriveTreeKey(spaceKey, objectId);
  final details = await replayObjectDetails(
    rawTreeChanges: rawTreeChanges,
    treeKey: treeKey,
  );
  final uniqueKey = details['uniqueKey']?.stringValue.trim() ?? '';
  if (uniqueKey.isEmpty) {
    throw StateError(
      'Target object type $objectId does not expose a uniqueKey detail',
    );
  }

  return _ResolvedTargetObjectType(
    objectId: objectId,
    uniqueKey: uniqueKey,
  );
}

Future<_PreparedSnapshot> _buildSnapshotFromTemplate(
  ManytypeDatabase db, {
  required Uint8List spaceKey,
  required String templateId,
  required String objectId,
  required String requestedText,
  required bool textProvided,
}) async {
  final changes = await db.getChangesForObject(templateId);
  if (changes.isEmpty) {
    throw StateError('Template not found: $templateId');
  }

  final rawTreeChanges =
      changes.map((change) => Uint8List.fromList(change.rawBytes)).toList();
  final templateTreeKey = await deriveTreeKey(spaceKey, templateId);
  final replayed = await replayObjectState(
    rawTreeChanges: rawTreeChanges,
    treeKey: templateTreeKey,
  );
  if (replayed.smartBlockType != SmartBlockType.Template.value) {
    throw StateError(
      'Object $templateId is not a template (smart block type '
      '${replayed.smartBlockType})',
    );
  }

  final targetObjectTypeId =
      _stringDetail(replayed.snapshot.details, 'targetObjectType');
  if (targetObjectTypeId.isEmpty) {
    throw StateError('Template $templateId is missing targetObjectType');
  }
  final targetType = await _resolveTargetObjectType(
    db,
    spaceKey: spaceKey,
    objectId: targetObjectTypeId,
  );

  final templateName = _stringDetail(replayed.snapshot.details, 'name');
  final prefillType = replayed
          .snapshot.details.fields['templateNamePrefillType']?.numberValue
          .toInt() ??
      TemplateNamePrefillType.Empty.value;
  final displayName = textProvided
      ? requestedText
      : (prefillType == TemplateNamePrefillType.FromTemplateName.value &&
              templateName.isNotEmpty
          ? templateName
          : 'Untitled');

  final snapshot = replayed.snapshot.deepCopy();
  snapshot.objectTypes
    ..clear()
    ..add(targetType.uniqueKey);
  for (final block in snapshot.blocks) {
    if (block.id == templateId) {
      block.id = objectId;
    }
    for (var i = 0; i < block.childrenIds.length; i++) {
      if (block.childrenIds[i] == templateId) {
        block.childrenIds[i] = objectId;
      }
    }
  }

  final details = snapshot.details.deepCopy()
    ..fields.remove('targetObjectType')
    ..fields.remove('templateIsBundled')
    ..fields.remove('templateNamePrefillType')
    ..fields.remove('templatePlaceholders')
    ..fields['sourceObject'] = Value(stringValue: templateId)
    ..fields['type'] = Value(stringValue: targetObjectTypeId)
    ..fields['name'] = Value(stringValue: displayName);
  snapshot.details = details;
  _rewriteTitleBlock(snapshot, displayName);

  return _PreparedSnapshot(
    snapshot: snapshot,
    displayName: displayName,
  );
}

String _stringDetail(Struct details, String key) {
  final value = details.fields[key];
  if (value == null || !value.hasStringValue()) {
    return '';
  }
  return value.stringValue.trim();
}

void _rewriteTitleBlock(SmartBlockSnapshotBase snapshot, String title) {
  for (final block in snapshot.blocks) {
    if (block.id == 'title' && block.hasText()) {
      block.text.text = title;
      return;
    }
  }
}

Future<RawRecordWithId> _buildDerivedAclRoot({
  required String spaceId,
  required Uint8List accountSeed,
  required Uint8List accountPublicKey,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final identity = _marshalEd25519PublicKey(accountPublicKey);
  final identitySignature = await ed25519Sign(accountSeed, accountPublicKey);

  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, accountSeed)
    ..setRange(32, 64, accountPublicKey);
  final readKey = await deriveSpaceKey(accountPrivRaw);
  final readKeyProto = Uint8List.fromList(
    Key(
      type: KeyType.AES,
      data: readKey,
    ).writeToBuffer(),
  );

  final metadataSeed = await slip21Derive(
    accountPrivRaw,
    'm/SLIP-0021/anysync/metadata',
  );
  final metadataKeyPair = await ed25519KeyPairFromSeed(metadataSeed);
  final metadataPubKey = _marshalEd25519PublicKey(metadataKeyPair.publicKey);
  final metadataPrivKeyRaw = Uint8List(64)
    ..setRange(0, 32, metadataSeed)
    ..setRange(32, 64, metadataKeyPair.publicKey);
  final metadataPrivKeyProto = Uint8List.fromList(
    Key(
      type: KeyType.Ed25519Private,
      data: metadataPrivKeyRaw,
    ).writeToBuffer(),
  );
  final encryptedMetadataPrivKey = await aesGcmEncrypt(
    readKey,
    metadataPrivKeyProto,
  );
  final encryptedReadKey = encryptToEd25519PublicKey(
    recipientEd25519PublicKey: accountPublicKey,
    message: readKeyProto,
  );

  // Official any-sync expects owner metadata encrypted to the metadata key
  // (Ed25519 public -> Curve25519 seal). Empty metadata is allowed, but the
  // ciphertext must be decryptable by the derived metadata key.
  final encryptedOwnerMetadata = encryptToEd25519PublicKey(
    recipientEd25519PublicKey: metadataKeyPair.publicKey,
    message: Uint8List(0),
  );

  final aclRoot = AclRoot(
    identity: identity,
    masterKey: identity,
    spaceId: spaceId,
    identitySignature: identitySignature,
    encryptedReadKey: encryptedReadKey,
    metadataPubKey: metadataPubKey,
    encryptedMetadataPrivKey: encryptedMetadataPrivKey,
    encryptedOwnerMetadata: encryptedOwnerMetadata,
    timestamp: Int64(now),
  );
  final aclRootBytes = Uint8List.fromList(aclRoot.writeToBuffer());
  final signature = await ed25519Sign(accountSeed, aclRootBytes);
  final rawRecord = RawRecord(
    payload: aclRootBytes,
    signature: signature,
  );
  final rawRecordBytes = Uint8List.fromList(rawRecord.writeToBuffer());
  final cid = await computeCid(rawRecordBytes);
  return RawRecordWithId(
    payload: rawRecordBytes,
    id: cid,
  );
}

Uint8List _marshalEd25519PublicKey(Uint8List publicKey) => Uint8List.fromList(
      Key(
        type: KeyType.Ed25519Public,
        data: publicKey,
      ).writeToBuffer(),
    );

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
        Uint8List.fromList(changes.first.rawBytes),
      );
      if (aclRoot != null && aclRoot.spaceId == spaceId) {
        return object.id;
      }
    } catch (_) {
      continue;
    }
  }
  throw StateError('Space bootstrap is missing an ACL root');
}
