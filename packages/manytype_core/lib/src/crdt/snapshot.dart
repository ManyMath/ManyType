import 'dart:typed_data';

import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

import 'block.dart';
import 'object_tree.dart';
import 'tree_builder.dart';

/// Collect current block state by replaying all change operations in
/// topological order.
///
/// Iterates through the tree's serialized changes (root first), decoding
/// each change's payload to extract block operations (BlockCreate,
/// BlockRemove). The root change is skipped (it contains a RootChange,
/// not a TreeChange with block operations).
///
/// Returns a map of blockId -> Block representing the final state.
Map<String, Block> collectBlockState(ObjectTree tree) {
  final blocks = <String, Block>{};

  final changes = tree.serialize(); // topological order, root first

  for (var i = 0; i < changes.length; i++) {
    final rawTreeChange = RawTreeChange.fromBuffer(changes[i].rawChange);

    // The first change is the root change (RootChange proto, not TreeChange).
    // Skip it -- it has no block operations.
    if (i == 0) continue;

    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);

    // If this is a snapshot change, load full state from snapshot
    if (treeChange.isSnapshot) {
      final change = Change.fromBuffer(treeChange.changesData);
      if (change.hasSnapshot()) {
        blocks.clear();
        for (final block in change.snapshot.data.blocks) {
          blocks[block.id] = block;
        }
      }
      continue;
    }

    // Decode Change proto from changesData
    final change = Change.fromBuffer(treeChange.changesData);

    // Apply each content operation
    for (final content in change.content) {
      switch (content.whichValue()) {
        case Change_Content_Value.blockCreate:
          for (final block in content.blockCreate.blocks) {
            blocks[block.id] = block;
          }
        case Change_Content_Value.blockRemove:
          for (final id in content.blockRemove.ids) {
            blocks.remove(id);
          }
        default:
          // BlockUpdate, BlockMove, etc. -- not needed for v1 snapshot
          break;
      }
    }
  }

  return blocks;
}

/// Create a [SmartBlockSnapshotBase] from the current tree state.
///
/// Collects all block state via [collectBlockState], then wraps it in
/// the standard root + layout + content structure using [createMinimalSnapshot].
SmartBlockSnapshotBase createSnapshot(ObjectTree tree, String rootId) {
  final blockState = collectBlockState(tree);
  final contentBlocks = blockState.values.toList();
  return createMinimalSnapshot(rootId, contentBlocks);
}

/// Compact the tree by creating a snapshot change that encodes all current
/// state.
///
/// Per Anytype protocol (Pitfall 6): the snapshot TreeChange MUST have
/// `isSnapshot = true` and its `changesData` MUST contain a serialized
/// [Change] proto with the `snapshot` field set to a [Change_Snapshot]
/// containing the full [SmartBlockSnapshotBase].
///
/// Returns the new snapshot change (already added to tree).
Future<RawTreeChangeWithId> compactTree({
  required ObjectTree tree,
  required String rootId,
  required String aclHeadId,
  required Uint8List identityPrivateKey,
  String readKeyId = '',
}) async {
  // 1. Create snapshot from current state
  final snapshotBase = createSnapshot(tree, rootId);

  // 2. Create Change proto with snapshot field
  final change = Change(
    snapshot: Change_Snapshot(data: snapshotBase),
  );
  final changeBytes = Uint8List.fromList(change.writeToBuffer());

  // 3. Build TreeChange with isSnapshot=true
  final snapshotChange = await buildTreeChange(
    currentHeads: tree.heads,
    aclHeadId: aclHeadId,
    snapshotBaseId: tree.rootId,
    changesData: changeBytes,
    identityPrivateKey: identityPrivateKey,
    readKeyId: readKeyId,
    isSnapshot: true,
  );

  // 4. Add to tree
  await tree.addChange(snapshotChange);
  return snapshotChange;
}
