import 'dart:convert';
import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show AclRoot, Key, KeyType;

import '../config.dart';
import '../identity.dart';
import '../store/database.dart';

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
  CliConfig config,
) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = identity.spaceId;

  // Check if space needs initialization (first object)
  final existingObjects = await db.getObjectsBySpace(spaceId);

  String aclHeadId;
  if (existingObjects.isEmpty) {
    final aclRoot = await _buildDerivedAclRoot(
      spaceId: spaceId,
      accountSeed: identity.accountSeed,
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
  );

  final objectId = rootChange.id;

  // Build tree change with text block content.
  // Create a text block and wrap it in a BlockCreate change.
  final textBlock = createTextBlock('block-1', text);
  final changeContent = Change_Content(
    blockCreate: Change_BlockCreate(
      targetId: objectId,
      position: Block_Position.Bottom,
      blocks: [textBlock],
    ),
  );
  final changeData = marshalChangeContent([changeContent]);

  final treeChange = await buildTreeChange(
    currentHeads: [rootChange.id],
    aclHeadId: aclHeadId,
    snapshotBaseId: rootChange.id,
    changesData: changeData,
    identityPrivateKey: identity.accountSeed,
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

  print('Created object: $objectId');
  print('Text: $text');
  print('Changes: 2 (root + content)');
}

Future<RawRecordWithId> _buildDerivedAclRoot({
  required String spaceId,
  required Uint8List accountSeed,
}) async {
  final accountKeyPair = await ed25519KeyPairFromSeed(accountSeed);
  final identity = _marshalEd25519PublicKey(accountKeyPair.publicKey);
  final identitySignature =
      await ed25519Sign(accountSeed, accountKeyPair.publicKey);
  final aclRoot = AclRoot(
    identity: identity,
    masterKey: identity,
    spaceId: spaceId,
    identitySignature: identitySignature,
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

Uint8List _marshalEd25519PublicKey(Uint8List publicKey) => Uint8List.fromList(
      Key(
        type: KeyType.Ed25519Public,
        data: publicKey,
      ).writeToBuffer(),
    );
