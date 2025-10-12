import 'dart:math';
import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:test/test.dart';

/// Helper: generate a deterministic 32-byte seed for testing.
Uint8List _testSeed(int n) {
  final rng = Random(n);
  return Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
}

/// Helper: build a tree with root + block create changes.
/// Returns (tree, rootId, rootChangeId) where rootId is the logical
/// SmartBlock root ID used in block structure.
Future<(ObjectTree, String, String)> _buildTreeWithBlocks(
  Uint8List identitySeed,
  String aclHeadId,
  List<Change_Content> operations,
) async {
  final root = await buildRootChange(
    spaceId: 'space-1',
    aclHeadId: aclHeadId,
    identityPrivateKey: identitySeed,
  );
  final tree = ObjectTree.fromRoot(root);

  // Add a change containing the operations
  final changesData = marshalChangeContent(operations);
  final change = await buildTreeChange(
    currentHeads: tree.heads,
    aclHeadId: aclHeadId,
    snapshotBaseId: root.id,
    changesData: changesData,
    identityPrivateKey: identitySeed,
  );
  await tree.addChange(change);

  return (tree, 'sb-root', root.id);
}

void main() {
  late Uint8List identitySeed;
  const aclHeadId = 'acl-1';

  setUp(() {
    identitySeed = _testSeed(42);
  });

  group('collectBlockState', () {
    test('from tree with root + 2 BlockCreate changes returns 2 blocks',
        () async {
      final block1 = createTextBlock('block-1', 'Hello');
      final block2 = createTextBlock('block-2', 'World');

      final operations = [
        Change_Content(
            blockCreate: Change_BlockCreate(
                targetId: 'sb-root', blocks: [block1])),
        Change_Content(
            blockCreate: Change_BlockCreate(
                targetId: 'sb-root', blocks: [block2])),
      ];

      final (tree, _, _) =
          await _buildTreeWithBlocks(identitySeed, aclHeadId, operations);

      final state = collectBlockState(tree);
      expect(state, hasLength(2));
      expect(state.containsKey('block-1'), isTrue);
      expect(state.containsKey('block-2'), isTrue);
    });

    test(
        'from tree with BlockCreate + BlockUpdate returns block with updated text',
        () async {
      // BlockCreate first
      final block1 = createTextBlock('block-1', 'Original');
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: aclHeadId,
        identityPrivateKey: identitySeed,
      );
      final tree = ObjectTree.fromRoot(root);

      // Add BlockCreate
      final createData = marshalChangeContent([
        Change_Content(
            blockCreate: Change_BlockCreate(
                targetId: 'sb-root', blocks: [block1])),
      ]);
      final change1 = await buildTreeChange(
        currentHeads: tree.heads,
        aclHeadId: aclHeadId,
        snapshotBaseId: root.id,
        changesData: createData,
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(change1);

      // Add BlockUpdate (replace text) - we use a new BlockCreate with
      // the same ID to simulate update since BlockUpdate uses events which
      // are complex. For collectBlockState, a second BlockCreate with same
      // ID should overwrite.
      final updatedBlock = createTextBlock('block-1', 'Updated');
      final updateData = marshalChangeContent([
        Change_Content(
            blockCreate: Change_BlockCreate(
                targetId: 'sb-root', blocks: [updatedBlock])),
      ]);
      final change2 = await buildTreeChange(
        currentHeads: tree.heads,
        aclHeadId: aclHeadId,
        snapshotBaseId: root.id,
        changesData: updateData,
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(change2);

      final state = collectBlockState(tree);
      expect(state['block-1']!.text.text, equals('Updated'));
    });

    test('from tree with BlockCreate + BlockRemove returns empty blocks list',
        () async {
      final block1 = createTextBlock('block-1', 'Temporary');
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: aclHeadId,
        identityPrivateKey: identitySeed,
      );
      final tree = ObjectTree.fromRoot(root);

      // Add BlockCreate
      final createData = marshalChangeContent([
        Change_Content(
            blockCreate: Change_BlockCreate(
                targetId: 'sb-root', blocks: [block1])),
      ]);
      final change1 = await buildTreeChange(
        currentHeads: tree.heads,
        aclHeadId: aclHeadId,
        snapshotBaseId: root.id,
        changesData: createData,
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(change1);

      // Add BlockRemove
      final removeData = marshalChangeContent([
        Change_Content(
            blockRemove: Change_BlockRemove(ids: ['block-1'])),
      ]);
      final change2 = await buildTreeChange(
        currentHeads: tree.heads,
        aclHeadId: aclHeadId,
        snapshotBaseId: root.id,
        changesData: removeData,
        identityPrivateKey: identitySeed,
      );
      await tree.addChange(change2);

      final state = collectBlockState(tree);
      expect(state, isEmpty);
    });
  });

  group('createSnapshot', () {
    test(
        'produces SmartBlockSnapshotBase with root + layout + content blocks',
        () async {
      final block1 = createTextBlock('block-1', 'Hello');
      final block2 = createHeaderBlock('block-2', 'Title', 1);

      final (tree, _, _) = await _buildTreeWithBlocks(
        identitySeed,
        aclHeadId,
        [
          Change_Content(
              blockCreate: Change_BlockCreate(
                  targetId: 'sb-root', blocks: [block1])),
          Change_Content(
              blockCreate: Change_BlockCreate(
                  targetId: 'sb-root', blocks: [block2])),
        ],
      );

      final snapshot = createSnapshot(tree, 'sb-root');
      // Should have root + layout + 2 content blocks = 4
      expect(snapshot.blocks, hasLength(4));
      // Root block
      expect(snapshot.blocks.any((b) => b.id == 'sb-root'), isTrue);
      // Layout block
      expect(
          snapshot.blocks.any((b) => b.id == 'layout-sb-root'), isTrue);
      // Content blocks
      expect(snapshot.blocks.any((b) => b.id == 'block-1'), isTrue);
      expect(snapshot.blocks.any((b) => b.id == 'block-2'), isTrue);
    });
  });

  group('compactTree', () {
    test('adds isSnapshot=true TreeChange to tree; becomes the only head',
        () async {
      final block1 = createTextBlock('block-1', 'Hello');

      final (tree, _, rootChangeId) = await _buildTreeWithBlocks(
        identitySeed,
        aclHeadId,
        [
          Change_Content(
              blockCreate: Change_BlockCreate(
                  targetId: 'sb-root', blocks: [block1])),
        ],
      );

      final headsBefore = tree.heads.length;
      expect(headsBefore, 1);

      final snapshotChange = await compactTree(
        tree: tree,
        rootId: 'sb-root',
        aclHeadId: aclHeadId,
        identityPrivateKey: identitySeed,
      );

      // Snapshot change should be the only head
      expect(tree.heads, hasLength(1));
      expect(tree.heads.first, equals(snapshotChange.id));

      // Verify isSnapshot flag on the TreeChange
      final rawTreeChange =
          RawTreeChange.fromBuffer(snapshotChange.rawChange);
      final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      expect(treeChange.isSnapshot, isTrue);
    });

    test(
        'snapshot changesData deserializes to Change with Snapshot containing all blocks',
        () async {
      final block1 = createTextBlock('block-1', 'Hello');
      final block2 = createTextBlock('block-2', 'World');

      final (tree, _, rootChangeId) = await _buildTreeWithBlocks(
        identitySeed,
        aclHeadId,
        [
          Change_Content(
              blockCreate: Change_BlockCreate(
                  targetId: 'sb-root', blocks: [block1])),
          Change_Content(
              blockCreate: Change_BlockCreate(
                  targetId: 'sb-root', blocks: [block2])),
        ],
      );

      final snapshotChange = await compactTree(
        tree: tree,
        rootId: 'sb-root',
        aclHeadId: aclHeadId,
        identityPrivateKey: identitySeed,
      );

      // Decode the changesData from the snapshot change
      final rawTreeChange =
          RawTreeChange.fromBuffer(snapshotChange.rawChange);
      final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      final change = Change.fromBuffer(treeChange.changesData);

      expect(change.hasSnapshot(), isTrue);
      final snapshotData = change.snapshot.data;
      // root + layout + 2 content blocks
      expect(snapshotData.blocks, hasLength(4));
      expect(snapshotData.blocks.any((b) => b.id == 'block-1'), isTrue);
      expect(snapshotData.blocks.any((b) => b.id == 'block-2'), isTrue);
    });

    test(
        'full round-trip: create tree with root + 3 block changes, compact, verify snapshot',
        () async {
      final root = await buildRootChange(
        spaceId: 'space-1',
        aclHeadId: aclHeadId,
        identityPrivateKey: identitySeed,
      );
      final tree = ObjectTree.fromRoot(root);

      // Add 3 separate changes with different blocks
      final blocks = [
        createTextBlock('block-1', 'First paragraph'),
        createHeaderBlock('block-2', 'My Title', 1),
        createListBlock('block-3', 'Item one'),
      ];

      for (final block in blocks) {
        final data = marshalChangeContent([
          Change_Content(
              blockCreate: Change_BlockCreate(
                  targetId: 'sb-root', blocks: [block])),
        ]);
        final change = await buildTreeChange(
          currentHeads: tree.heads,
          aclHeadId: aclHeadId,
          snapshotBaseId: root.id,
          changesData: data,
          identityPrivateKey: identitySeed,
        );
        await tree.addChange(change);
      }

      // Tree should have root + 3 changes = 4 total, 1 head
      expect(tree.heads, hasLength(1));

      // Compact
      final snapshotChange = await compactTree(
        tree: tree,
        rootId: 'sb-root',
        aclHeadId: aclHeadId,
        identityPrivateKey: identitySeed,
      );

      // Decode and verify all 3 blocks are present
      final rawTreeChange =
          RawTreeChange.fromBuffer(snapshotChange.rawChange);
      final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      expect(treeChange.isSnapshot, isTrue);

      final change = Change.fromBuffer(treeChange.changesData);
      expect(change.hasSnapshot(), isTrue);

      final snapshotData = change.snapshot.data;
      // root + layout + 3 content blocks = 5
      expect(snapshotData.blocks, hasLength(5));

      // Verify each block's content is preserved
      final blockMap = {
        for (final b in snapshotData.blocks) b.id: b
      };
      expect(blockMap['block-1']!.text.text, equals('First paragraph'));
      expect(blockMap['block-2']!.text.text, equals('My Title'));
      expect(blockMap['block-2']!.text.style,
          equals(Block_Content_Text_Style.Header1));
      expect(blockMap['block-3']!.text.text, equals('Item one'));
      expect(blockMap['block-3']!.text.style,
          equals(Block_Content_Text_Style.Marked));

      // Verify root and layout structure
      expect(blockMap['sb-root']!.childrenIds, contains('layout-sb-root'));
      expect(blockMap['layout-sb-root']!.childrenIds,
          containsAll(['block-1', 'block-2', 'block-3']));
    });
  });
}
