import 'dart:convert';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/models.dart';

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
    // First object in space: build ACL root with distinct account/master
    // and identity keys.
    final aclRoot = await buildAclRoot(
      spaceId: spaceId,
      masterKeySeed: identity.accountSeed,
      identityPrivateKey: identity.seed,
      readKey: identity.seed,
    );

    // Store ACL root as a special object in the space
    await db.insertObject(aclRoot.id, spaceId);
    await db.insertChange(
      aclRoot.id,
      aclRoot.id,
      aclRoot.payload, // raw bytes of the ACL record
      jsonEncode([]), // ACL root has no parents
    );
    aclHeadId = aclRoot.id;
    print('Initialized space: $spaceId');
  } else {
    // Get existing ACL head (first object is always ACL root).
    // This is a simplification for v1.
    aclHeadId = existingObjects.first.id;
  }

  // Build root change for new object tree
  final rootChange = await buildRootChange(
    spaceId: spaceId,
    aclHeadId: aclHeadId,
    identityPrivateKey: identity.seed,
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
    identityPrivateKey: identity.seed,
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
