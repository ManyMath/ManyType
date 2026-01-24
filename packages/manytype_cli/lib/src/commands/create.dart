import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show AclRoot, Key, KeyType, RawTreeChangeWithId;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

import '../acl_codec.dart';
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
  final bytes = BytesBuilder()..addByte(0x08)..add(_encodeVarint(smartBlockType));
  return bytes.toBytes();
}

/// Convert a human-readable name to a URL-safe unique key.
String _toUniqueKey(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'-+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

/// Map a CLI format string to a [RelationFormat] enum value.
RelationFormat _parseRelationFormat(String? format) {
  return switch (format?.toLowerCase()) {
    'text' || null => RelationFormat.longtext,
    'shorttext' => RelationFormat.shorttext,
    'number' => RelationFormat.number,
    'date' => RelationFormat.date,
    'checkbox' => RelationFormat.checkbox,
    'url' => RelationFormat.url,
    'email' => RelationFormat.email,
    'phone' => RelationFormat.phone,
    'object' => RelationFormat.object,
    _ => RelationFormat.longtext,
  };
}

/// Create a new text object and persist to local store.
///
/// Builds an ObjectTree with a signed root change and a text block change,
/// then persists both changes to the drift SQLite database.
///
/// Per D-08: identity derived fresh from mnemonic.
/// Per D-07: persisted as normalized objects + changes rows.
Future<void> createCommand(
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
  bool asRelationOption = false,
  String? name,
  String? format,
  String? sourceType,
  String? forRelation,
  String? color,
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
  if (existingObjects.isEmpty) {
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
    print('Initialized space: $spaceId');
  } else {
    aclHeadId = await _findAclRootId(db, existingObjects, spaceId);
  }

  // Determine SmartBlockType based on --as-type/--as-relation/--as-set/--as-relation-option flags
  final int smartBlockTypeValue;
  if (asType) {
    smartBlockTypeValue = SmartBlockType.STType.value;
  } else if (asRelation) {
    smartBlockTypeValue = SmartBlockType.STRelation.value;
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
  final displayName = name ?? text;

  // Build a minimal snapshot for official client compatibility.
  //
  // Official clients can treat some incremental BlockCreate-only histories as
  // "empty trees" during bootstrap. Creating a snapshot TreeChange ensures the
  // object materializes with a valid smartblock root + layout + content blocks.
  final snapshotBase = createMinimalPageSnapshotBase(
    objectId: objectId,
    title: displayName,
  );

  final rng = Random.secure();

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
    final dvBlockId =
        'dv-${rng.nextInt(0xFFFFFF).toRadixString(16)}';
    final dvBlock =
        createDataviewBlock(dvBlockId, [sourceType ?? 'ot-page']);
    snapshotBase.blocks.add(dvBlock);
    // Insert Dataview block ID into header's childrenIds
    final headerBlock =
        snapshotBase.blocks.firstWhere((b) => b.id == 'header');
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
  } else {
    snapshotBase.objectTypes.add('ot-page');
    snapshotBase.details = Struct()
      ..fields['name'] = Value(stringValue: text)
      ..fields['tag'] = Value(listValue: ListValue())
      ..fields['internalFlags'] = Value(listValue: ListValue());
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

  // Append block type changes if any block flag is set.
  final blockOps = <Change_Content>[];
  String _blockId(String prefix) =>
      '$prefix${rng.nextInt(0xFFFFFF).toRadixString(16)}';

  if (checkbox) {
    blockOps.add(Change_Content(
      blockCreate: Change_BlockCreate(
        targetId: 'header',
        position: Block_Position.Inner,
        blocks: [createListBlock(_blockId('cb-'), text, checkbox: true)],
      ),
    ));
  }
  if (numberedList) {
    blockOps.add(Change_Content(
      blockCreate: Change_BlockCreate(
        targetId: 'header',
        position: Block_Position.Inner,
        blocks: [createListBlock(_blockId('num-'), text, numbered: true)],
      ),
    ));
  }
  if (toggle) {
    blockOps.add(Change_Content(
      blockCreate: Change_BlockCreate(
        targetId: 'header',
        position: Block_Position.Inner,
        blocks: [createToggleBlock(_blockId('tog-'), text)],
      ),
    ));
  }
  if (quote) {
    blockOps.add(Change_Content(
      blockCreate: Change_BlockCreate(
        targetId: 'header',
        position: Block_Position.Inner,
        blocks: [createQuoteBlock(_blockId('qt-'), text)],
      ),
    ));
  }
  if (callout) {
    blockOps.add(Change_Content(
      blockCreate: Change_BlockCreate(
        targetId: 'header',
        position: Block_Position.Inner,
        blocks: [createCalloutBlock(_blockId('co-'), text)],
      ),
    ));
  }

  int changeCount = 2;
  if (blockOps.isNotEmpty) {
    final blockChangeData = marshalChangeContent(blockOps);
    final blockTreeChange = await buildTreeChange(
      currentHeads: [treeChange.id],
      aclHeadId: aclHeadId,
      snapshotBaseId: rootChange.id,
      changesData: await aesGcmEncrypt(treeKey, blockChangeData),
      identityPrivateKey: identity.accountSeed,
      readKeyId: aclHeadId,
    );
    await db.insertChange(
      blockTreeChange.id,
      objectId,
      blockTreeChange.rawChange,
      jsonEncode([treeChange.id]),
    );
    changeCount++;
  }

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
      final rawBytesList = parentRawChanges
          .map((r) => Uint8List.fromList(r.rawBytes))
          .toList();
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
      final storedUnique =
          candidateDetails['uniqueKey']?.stringValue ?? '';
      final storedRelKey =
          candidateDetails['relationKey']?.stringValue ?? '';
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

    final detailsContent = Change_Content(
      detailsSet: Change_DetailsSet(
        key: 'selectDict',
        value: updatedSelectDict,
      ),
    );
    final detailsData = marshalChangeContent([detailsContent]);

    final parentTreeChange = await buildTreeChange(
      currentHeads: parentLatestHeads,
      aclHeadId: aclHeadId,
      snapshotBaseId: parentSnapshotBaseId,
      changesData: await aesGcmEncrypt(parentTreeKey!, detailsData),
      identityPrivateKey: identity.accountSeed,
      readKeyId: aclHeadId,
    );

    await db.insertChange(
      parentTreeChange.id,
      parentStRelationId,
      parentTreeChange.rawChange,
      jsonEncode(parentLatestHeads),
    );

    print(
      'Appended option $objectId to STRelation $parentStRelationId '
      '(selectDict now has ${updatedSelectDict.listValue.values.length} entries)',
    );
  }

  final objectKind = asType
      ? 'type'
      : asRelation
          ? 'relation'
          : asSet
              ? 'set'
              : asRelationOption
                  ? 'relation-option'
                  : 'object';
  print('Created $objectKind: $objectId');
  print('Text: $displayName');
  print('Changes: $changeCount (root + snapshot${blockOps.isNotEmpty ? ' + blocks' : ''})');
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
