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

  // Build root change for new object tree
  final rootChange = await buildRootChange(
    spaceId: spaceId,
    aclHeadId: aclHeadId,
    identityPrivateKey: identity.accountSeed,
    changePayload: _encodeObjectChangePayloadSmartblockType(
      SmartBlockType.Page.value,
    ),
  );

  final objectId = rootChange.id;

  // Build a minimal snapshot for official client compatibility.
  //
  // Official clients can treat some incremental BlockCreate-only histories as
  // "empty trees" during bootstrap. Creating a snapshot TreeChange ensures the
  // object materializes with a valid smartblock root + layout + content blocks.
  final snapshotBase = createMinimalPageSnapshotBase(
    objectId: objectId,
    title: text,
  );
  snapshotBase.objectTypes.add('ot-page');
  snapshotBase.details = Struct()
    ..fields['name'] = Value(stringValue: text)
    ..fields['tag'] = Value(listValue: ListValue())
    ..fields['internalFlags'] = Value(listValue: ListValue());
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
  final rng = Random.secure();
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

  print('Created object: $objectId');
  print('Text: $text');
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
