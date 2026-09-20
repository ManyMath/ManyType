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
  final Map<String, List<String>> _parentMap = {}; // id -> parent ids
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
    _parentMap[rootId] = []; // root has no parents
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

    // 6. Add to _changes and _parentMap
    _changes[change.id] = change;
    _parentMap[change.id] = parentIds;

    // 7. Update _headIds: remove each parent from heads, add this change id
    for (final parentId in parentIds) {
      _headIds.remove(parentId);
    }
    _headIds.add(change.id);
  }

  /// Serialize the tree as a list of [RawTreeChangeWithId] in topological order.
  ///
  /// Root change is first, followed by changes in dependency order.
  List<RawTreeChangeWithId> serialize() {
    final result = <RawTreeChangeWithId>[];
    final visited = <String>{};

    void visit(String id) {
      if (visited.contains(id)) return;
      visited.add(id);

      // Visit parents first (topological ordering)
      final parents = _parentMap[id] ?? [];
      for (final parentId in parents) {
        visit(parentId);
      }

      result.add(_changes[id]!);
    }

    // Start from heads to ensure all reachable nodes are visited
    for (final headId in _headIds) {
      visit(headId);
    }

    return result;
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
