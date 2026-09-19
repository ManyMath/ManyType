import 'dart:typed_data';

import 'package:manytype_protocol/models.dart';

import 'change_replay.dart';
import 'relation_option.dart';

/// Fully replayed object state reconstructed from raw tree changes.
class ReplayedObjectState {
  final int smartBlockType;
  final SmartBlockSnapshotBase snapshot;

  const ReplayedObjectState({
    required this.smartBlockType,
    required this.snapshot,
  });
}

/// Replay an encrypted object tree into its latest snapshot-equivalent state.
///
/// This mirrors heart's state build: a snapshot resets state only when it
/// supersedes every change replayed before it (a concurrent snapshot just
/// contributes its content), subsequent changes mutate blocks/details/
/// objectTypes/relationLinks/collections, and encrypted/snappy-compressed
/// TreeChanges are transparently decoded with [treeKey]. [rawTreeChanges]
/// must start with the root change and be in topological order.
Future<ReplayedObjectState> replayObjectState({
  required List<Uint8List> rawTreeChanges,
  required Uint8List treeKey,
}) async {
  final smartBlockType = extractRootSmartBlockType(rawTreeChanges);
  if (smartBlockType < 0) {
    throw StateError('Object is missing a parseable root smart block type');
  }

  final state = await replayRawTreeChanges(rawTreeChanges, treeKey);

  return ReplayedObjectState(
    smartBlockType: smartBlockType,
    snapshot: state.toSnapshot(),
  );
}
