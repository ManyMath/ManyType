import 'dart:typed_data';

import 'package:manytype_core/src/crdt/cid.dart';
import 'package:manytype_core/src/crypto/ed25519.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

/// A signed DAG (directed acyclic graph) of tree changes.
///
/// The ObjectTree is Anytype's core data structure for document state.
/// Each change references its parent changes via [TreeChange.treeHeadIds],
/// forming a DAG. Heads are the set of changes that have no successors --
/// they represent the current tips of the DAG.
///
/// Head tracking rule: when adding a change, its parent IDs are removed
/// from heads (they now have a successor), and the new change ID is added.
class ObjectTree {
  final Map<String, RawTreeChangeWithId> _changes = {};
  final Map<String, List<String>> _childMap = {}; // id -> child ids
  final Set<String> _headIds = {};

  /// The CID of the root change.
  late final String rootId;

  /// Create an ObjectTree from a root change.
  ///
  /// The root change becomes the initial single head.
  ObjectTree.fromRoot(RawTreeChangeWithId rootChange) {
    rootId = rootChange.id;
    _changes[rootId] = rootChange;
    _headIds.add(rootId);
  }

  /// Current head CIDs, sorted for deterministic comparison.
  List<String> get heads => _headIds.toList()..sort();

  /// Add a change to the tree.
  ///
  /// Verifies CID integrity, signature validity, and that all referenced
  /// parent heads exist in the tree. Updates the head set accordingly.
  /// Changes already in the tree are ignored.
  Future<void> addChange(RawTreeChangeWithId change) async {
    if (_changes.containsKey(change.id)) return;

    // 1. Verify CID: computeCid(change.rawChange) == change.id
    final recomputedCid =
        await computeCid(Uint8List.fromList(change.rawChange));
    if (recomputedCid != change.id) {
      throw StateError(
          'CID mismatch: expected ${change.id}, computed $recomputedCid');
    }

    // 2. Decode RawTreeChange from change.rawChange
    final rawTreeChange = RawTreeChange.fromBuffer(change.rawChange);

    // 3. Decode TreeChange from rawTreeChange.payload
    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);

    // 4. Verify Ed25519 signature
    final valid = await ed25519Verify(
      _decodeIdentityPublicKey(treeChange.identity),
      Uint8List.fromList(rawTreeChange.payload),
      Uint8List.fromList(rawTreeChange.signature),
    );
    if (!valid) {
      throw StateError('Invalid signature for change ${change.id}');
    }

    // 5. Check all treeHeadIds exist in _changes
    final parentIds = treeChange.treeHeadIds.toList();
    for (final parentId in parentIds) {
      if (!_changes.containsKey(parentId)) {
        throw StateError(
            'Parent change $parentId not found in tree for ${change.id}');
      }
    }

    // 6. Add to _changes and _childMap
    _changes[change.id] = change;
    for (final parentId in parentIds) {
      (_childMap[parentId] ??= []).add(change.id);
    }

    // 7. Update _headIds: remove each parent from heads, add this change id
    for (final parentId in parentIds) {
      _headIds.remove(parentId);
    }
    _headIds.add(change.id);
  }

  /// Serialize the tree as a list of [RawTreeChangeWithId] in topological order.
  ///
  /// Root change is first, followed by changes in dependency order. Like
  /// any-sync's tree iterator, this is the reverse post-order of a walk from
  /// the root with concurrent children ordered by id, so peers holding the
  /// same changes serialize (and replay) them identically.
  List<RawTreeChangeWithId> serialize() {
    final postOrder = <String>[];
    final visited = <String>{};
    final expanded = <String>{};
    final stack = <String>[rootId];

    while (stack.isNotEmpty) {
      final id = stack.removeLast();
      // Second visit: every descendant has been emitted.
      if (expanded.remove(id)) {
        postOrder.add(id);
        continue;
      }
      if (!visited.add(id)) continue;

      stack.add(id);
      expanded.add(id);
      final children = [...?_childMap[id]]..sort();
      for (final childId in children) {
        if (!visited.contains(childId)) stack.add(childId);
      }
    }

    return [for (final id in postOrder.reversed) _changes[id]!];
  }

  /// Deserialize an ObjectTree from a topologically ordered list of changes.
  ///
  /// The first change must be the root change. Subsequent changes are added
  /// in order, with CID and signature verification.
  static Future<ObjectTree> deserialize(
      List<RawTreeChangeWithId> changes) async {
    if (changes.isEmpty) {
      throw ArgumentError('Cannot deserialize empty change list');
    }

    final tree = ObjectTree.fromRoot(changes.first);

    for (var i = 1; i < changes.length; i++) {
      await tree.addChange(changes[i]);
    }

    return tree;
  }
}

Uint8List _decodeIdentityPublicKey(List<int> identityBytes) {
  try {
    final key = Key.fromBuffer(identityBytes);
    if (key.type == KeyType.Ed25519Public && key.data.length == 32) {
      return Uint8List.fromList(key.data);
    }
  } catch (_) {
    // Fall back to legacy raw 32-byte identities.
  }
  return Uint8List.fromList(identityBytes);
}
