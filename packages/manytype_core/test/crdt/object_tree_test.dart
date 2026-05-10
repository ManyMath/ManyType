import 'dart:math';
import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:test/test.dart';

/// Helper: generate a deterministic 32-byte seed for testing.
Uint8List _testSeed(int n) {
  final rng = Random(n);
  return Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
}

void main() {
  late Uint8List identitySeed;

  setUp(() {
    identitySeed = _testSeed(42);
  });

  group('buildRootChange', () {
    test('produces RawTreeChangeWithId with id starting with "bafy"', () async {
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: 'acl-1',
        identityPrivateKey: identitySeed,
      );
      expect(root.id, startsWith('bafy'));
    });

    test('CID verifies (recompute from rawChange bytes matches id)', () async {
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: 'acl-1',
        identityPrivateKey: identitySeed,
      );
      final recomputedCid =
          await computeCid(Uint8List.fromList(root.rawChange));
      expect(recomputedCid, equals(root.id));
    });

    test('signature verifies with identity key', () async {
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: 'acl-1',
        identityPrivateKey: identitySeed,
      );
      // Decode RawTreeChange to get payload and signature
      final rawTreeChange = RawTreeChange.fromBuffer(root.rawChange);
      // Decode RootChange to get identity
      final rootChange = RootChange.fromBuffer(rawTreeChange.payload);
      final identityKey = Key.fromBuffer(rootChange.identity);
      final valid = await ed25519Verify(
        Uint8List.fromList(identityKey.data),
        Uint8List.fromList(rawTreeChange.payload),
        Uint8List.fromList(rawTreeChange.signature),
      );
      expect(valid, isTrue);
    });
  });

  group('ObjectTree', () {
    test('starts with root change as single head', () async {
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: 'acl-1',
        identityPrivateKey: identitySeed,
      );
      final tree = ObjectTree.fromRoot(root);
      expect(tree.heads, hasLength(1));
      expect(tree.heads.first, equals(root.id));
    });

    test('addChange with one parent updates heads', () async {
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: 'acl-1',
        identityPrivateKey: identitySeed,
      );
      final tree = ObjectTree.fromRoot(root);

      final change1 = await buildTreeChange(
        currentHeads: tree.heads,
        aclHeadId: 'acl-1',
        snapshotBaseId: root.id,
        changesData: Uint8List.fromList([1, 2, 3]),
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(change1);
      expect(tree.heads, hasLength(1));
      expect(tree.heads.first, equals(change1.id));
    });

    test('two changes referencing same parent create two heads (DAG fork)',
        () async {
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: 'acl-1',
        identityPrivateKey: identitySeed,
      );
      final tree = ObjectTree.fromRoot(root);

      // Fork: both reference root as parent
      final fork1 = await buildTreeChange(
        currentHeads: [root.id],
        aclHeadId: 'acl-1',
        snapshotBaseId: root.id,
        changesData: Uint8List.fromList([1, 2, 3]),
        identityPrivateKey: identitySeed,
      );
      final fork2 = await buildTreeChange(
        currentHeads: [root.id],
        aclHeadId: 'acl-1',
        snapshotBaseId: root.id,
        changesData: Uint8List.fromList([4, 5, 6]),
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(fork1);
      await tree.addChange(fork2);
      expect(tree.heads, hasLength(2));
      expect(tree.heads, containsAll([fork1.id, fork2.id]));
    });

    test('a change referencing both forked heads merges them into one head',
        () async {
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: 'acl-1',
        identityPrivateKey: identitySeed,
      );
      final tree = ObjectTree.fromRoot(root);

      final fork1 = await buildTreeChange(
        currentHeads: [root.id],
        aclHeadId: 'acl-1',
        snapshotBaseId: root.id,
        changesData: Uint8List.fromList([1, 2, 3]),
        identityPrivateKey: identitySeed,
      );
      final fork2 = await buildTreeChange(
        currentHeads: [root.id],
        aclHeadId: 'acl-1',
        snapshotBaseId: root.id,
        changesData: Uint8List.fromList([4, 5, 6]),
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(fork1);
      await tree.addChange(fork2);
      expect(tree.heads, hasLength(2));

      // Merge: references both forks
      final merge = await buildTreeChange(
        currentHeads: [fork1.id, fork2.id],
        aclHeadId: 'acl-1',
        snapshotBaseId: root.id,
        changesData: Uint8List.fromList([7, 8, 9]),
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(merge);
      expect(tree.heads, hasLength(1));
      expect(tree.heads.first, equals(merge.id));
    });

    test('buildTreeChange with changesData produces valid signed change',
        () async {
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: 'acl-1',
        identityPrivateKey: identitySeed,
      );

      final change = await buildTreeChange(
        currentHeads: [root.id],
        aclHeadId: 'acl-1',
        snapshotBaseId: root.id,
        changesData: Uint8List.fromList([10, 20, 30]),
        identityPrivateKey: identitySeed,
      );

      // Verify CID
      final recomputedCid =
          await computeCid(Uint8List.fromList(change.rawChange));
      expect(recomputedCid, equals(change.id));

      // Verify signature
      final rawTreeChange = RawTreeChange.fromBuffer(change.rawChange);
      final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      final identityKey = Key.fromBuffer(treeChange.identity);
      final valid = await ed25519Verify(
        Uint8List.fromList(identityKey.data),
        Uint8List.fromList(rawTreeChange.payload),
        Uint8List.fromList(rawTreeChange.signature),
      );
      expect(valid, isTrue);

      // Verify data preserved
      expect(treeChange.changesData, equals([10, 20, 30]));
      expect(treeChange.treeHeadIds, equals([root.id]));
    });

    test(
        'full round-trip: build root + 2 text changes, serialize, deserialize, heads match',
        () async {
      // Build root
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: 'acl-1',
        identityPrivateKey: identitySeed,
      );
      final tree = ObjectTree.fromRoot(root);

      // Add two changes linearly
      final change1 = await buildTreeChange(
        currentHeads: tree.heads,
        aclHeadId: 'acl-1',
        snapshotBaseId: root.id,
        changesData: Uint8List.fromList([1, 2, 3]),
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(change1);

      final change2 = await buildTreeChange(
        currentHeads: tree.heads,
        aclHeadId: 'acl-1',
        snapshotBaseId: root.id,
        changesData: Uint8List.fromList([4, 5, 6]),
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(change2);

      // Serialize
      final serialized = tree.serialize();
      expect(serialized, hasLength(3)); // root + 2 changes

      // Deserialize
      final rebuilt = await ObjectTree.deserialize(serialized);
      expect(rebuilt.heads, equals(tree.heads));
      expect(rebuilt.rootId, equals(tree.rootId));
    });
  });
}
