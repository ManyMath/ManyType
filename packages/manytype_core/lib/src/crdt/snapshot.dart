import 'dart:typed_data';

import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

import 'block.dart';
import 'change_replay.dart';
import 'object_tree.dart';
import 'tree_builder.dart';

/// Collect current block state by replaying all tree changes in topological
/// order.
Map<String, Block> collectBlockState(ObjectTree tree) =>
    _replayTree(tree).blocks;

/// Create a [SmartBlockSnapshotBase] from the current tree state.
SmartBlockSnapshotBase createSnapshot(ObjectTree tree, String rootId) {
  final replayed = _replayTree(tree);
  return _buildSnapshotBaseFromReplay(replayed, rootId);
}

SmartBlockSnapshotBase _buildSnapshotBaseFromReplay(
  ChangeReplayState replayed,
  String rootId,
) {
  final blocks = replayed.blocks.values.toList()
    ..sort((left, right) => left.id.compareTo(right.id));

  final SmartBlockSnapshotBase snapshot;
  if (replayed.blocks.containsKey(rootId)) {
    snapshot = SmartBlockSnapshotBase()..blocks.addAll(blocks);
  } else {
    // No root block was replayed: hang the top-level blocks off a fresh
    // root + layout skeleton and keep nested blocks under their parents.
    final childIds = {for (final block in blocks) ...block.childrenIds};
    snapshot = createMinimalSnapshot(rootId, [
      for (final block in blocks)
        if (!childIds.contains(block.id)) block,
    ])
      ..blocks.addAll([
        for (final block in blocks)
          if (childIds.contains(block.id)) block,
      ]);
  }
  if (replayed.details.fields.isNotEmpty) {
    snapshot.details = replayed.details.deepCopy();
  }
  if (replayed.collections.fields.isNotEmpty) {
    snapshot.collections = replayed.collections.deepCopy();
  }
  snapshot.objectTypes.addAll(replayed.objectTypes);
  snapshot.relationLinks
      .addAll(replayed.relationLinks.values.map((link) => link.deepCopy()));
  snapshot.removedCollectionKeys.addAll(replayed.removedCollectionKeys);
  if (replayed.originalCreatedTimestamp != null) {
    snapshot.originalCreatedTimestamp = replayed.originalCreatedTimestamp!;
  }
  if (replayed.fileInfo != null) {
    snapshot.fileInfo = replayed.fileInfo!.deepCopy();
  }
  return snapshot;
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
  final replayed = _replayTree(tree);
  final snapshotBase = _buildSnapshotBaseFromReplay(replayed, rootId);
  final fileKeyHashes = replayed.fileKeys.keys.toList()..sort();
  final change = Change(
    snapshot: Change_Snapshot(
      data: snapshotBase,
      fileKeys: [
        for (final hash in fileKeyHashes) replayed.fileKeys[hash]!.deepCopy(),
      ],
    ),
  );
  final changeBytes = Uint8List.fromList(change.writeToBuffer());

  final snapshotChange = await buildTreeChange(
    currentHeads: tree.heads,
    aclHeadId: aclHeadId,
    snapshotBaseId: tree.rootId,
    changesData: changeBytes,
    identityPrivateKey: identityPrivateKey,
    readKeyId: readKeyId,
    isSnapshot: true,
  );

  await tree.addChange(snapshotChange);
  return snapshotChange;
}

ChangeReplayState _replayTree(ObjectTree tree) {
  final state = ChangeReplayState();
  final changes = tree.serialize();

  for (var i = 0; i < changes.length; i++) {
    final rawTreeChange = RawTreeChange.fromBuffer(changes[i].rawChange);

    // The first change is the root change (RootChange proto, not TreeChange).
    if (i == 0) continue;

    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
    state.applyChange(
      changes[i].id,
      treeChange.treeHeadIds,
      Change.fromBuffer(treeChange.changesData),
    );
  }

  return state;
}
