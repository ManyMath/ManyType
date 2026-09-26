import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/models.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';
import 'package:test/test.dart';

final _seed = Uint8List.fromList(List.generate(32, (i) => i + 1));

Future<RawTreeChangeWithId> _root() => buildRootChange(
      spaceId: 'space-1',
      aclHeadId: 'acl-1',
      identityPrivateKey: _seed,
      // SmartBlockType 16 (Page).
      changePayload: const [0x08, 0x10],
    );

Future<RawTreeChangeWithId> _change(
  List<String> parents,
  Change change, {
  bool isSnapshot = false,
}) =>
    buildTreeChange(
      currentHeads: parents,
      aclHeadId: 'acl-1',
      snapshotBaseId: '',
      changesData: Uint8List.fromList(change.writeToBuffer()),
      identityPrivateKey: _seed,
      isSnapshot: isSnapshot,
    );

Change _snapshot(String text) => Change(
      snapshot: Change_Snapshot(
        data: SmartBlockSnapshotBase(blocks: [
          Block(id: 'obj', childrenIds: ['t']),
          Block(id: 't', text: Block_Content_Text(text: text)),
        ]),
      ),
    );

Change _setText(String text) => Change(content: [
      Change_Content(
        blockUpdate: Change_BlockUpdate(events: [
          Event_Message(
            blockSetText: Event_Block_Set_Text(
              id: 't',
              text: Event_Block_Set_Text_TextValue(value: text),
            ),
          ).writeToBuffer(),
        ]),
      ),
    ]);

Future<SmartBlockSnapshotBase> _replay(
  List<RawTreeChangeWithId> changes,
) async {
  final replayed = await replayObjectState(
    rawTreeChanges: [
      for (final change in changes) Uint8List.fromList(change.rawChange),
    ],
    treeKey: Uint8List(32),
  );
  return replayed.snapshot;
}

Future<String> _replayedText(List<RawTreeChangeWithId> changes) async {
  final snapshot = await _replay(changes);
  return snapshot.blocks.firstWhere((b) => b.id == 't').text.text;
}

/// Replay [content] on top of a snapshot whose root block carries the tree
/// id, as in real objects: root -> [p1, p2], p1 -> [x]. The root block is
/// keyed as 'root' in the result.
Future<Map<String, Block>> _replayOnTree(
  List<Change_Content> Function(String rootId) content,
) async {
  final root = await _root();
  final base = await _change(
    [root.id],
    Change(
      snapshot: Change_Snapshot(
        data: SmartBlockSnapshotBase(blocks: [
          Block(id: root.id, childrenIds: ['p1', 'p2']),
          Block(id: 'p1', childrenIds: ['x']),
          Block(id: 'p2'),
          Block(id: 'x'),
        ]),
      ),
    ),
    isSnapshot: true,
  );
  final change = await _change([base.id], Change(content: content(root.id)));
  final snapshot = await _replay([root, base, change]);
  return {
    for (final block in snapshot.blocks)
      block.id == root.id ? 'root' : block.id: block,
  };
}

void main() {
  group('replayObjectState snapshots', () {
    test('a concurrent snapshot does not discard sibling-branch edits',
        () async {
      final root = await _root();
      final s0 =
          await _change([root.id], _snapshot('original'), isSnapshot: true);
      final a1 = await _change([s0.id], _setText('edited-by-A'));
      // Snapshot made on another device from s0, without a1.
      final s1 =
          await _change([s0.id], _snapshot('original'), isSnapshot: true);

      expect(await _replayedText([root, s0, a1, s1]), 'edited-by-A');
    });

    test('a snapshot built on every replayed change resets state', () async {
      final root = await _root();
      final s0 =
          await _change([root.id], _snapshot('original'), isSnapshot: true);
      final a1 = await _change([s0.id], _setText('edited'));
      final s1 =
          await _change([a1.id], _snapshot('compacted'), isSnapshot: true);

      expect(await _replayedText([root, s0, a1, s1]), 'compacted');
    });
  });
  group('replayObjectState content', () {
    test('a detailsSet without a value deletes the detail', () async {
      final root = await _root();
      final set = await _change(
        [root.id],
        Change(content: [
          Change_Content(
            detailsSet: Change_DetailsSet(
              key: 'tag',
              value: Value(stringValue: 'x'),
            ),
          ),
        ]),
      );
      final clear = await _change(
        [set.id],
        Change(content: [
          Change_Content(detailsSet: Change_DetailsSet(key: 'tag')),
        ]),
      );

      final snapshot = await _replay([root, set, clear]);
      expect(snapshot.details.fields.containsKey('tag'), isFalse);
    });

    test('blockCreate without a target inserts into the root', () async {
      final appended = await _replayOnTree((_) => [
            Change_Content(
                blockCreate: Change_BlockCreate(blocks: [Block(id: 'n')])),
          ]);
      expect(appended['root']!.childrenIds, ['p1', 'p2', 'n']);

      final prepended = await _replayOnTree((_) => [
            Change_Content(
              blockCreate: Change_BlockCreate(
                position: Block_Position.InnerFirst,
                blocks: [Block(id: 'n')],
              ),
            ),
          ]);
      expect(prepended['root']!.childrenIds, ['n', 'p1', 'p2']);
    });

    test('blockCreate keeps an existing root and moves re-created blocks',
        () async {
      final blocks = await _replayOnTree((_) => [
            Change_Content(
              blockCreate: Change_BlockCreate(
                targetId: 'p2',
                position: Block_Position.Inner,
                blocks: [Block(id: 'x')],
              ),
            ),
          ]);
      expect(blocks['p1']!.childrenIds, isEmpty);
      expect(blocks['p2']!.childrenIds, ['x']);

      final recreated = await _replayOnTree((rootId) => [
            Change_Content(
              blockCreate: Change_BlockCreate(blocks: [
                Block(id: rootId),
                Block(id: 'n'),
              ]),
            ),
          ]);
      expect(recreated['root']!.childrenIds, ['p1', 'p2', 'n']);
    });

    test('blockDuplicate is ignored', () async {
      final blocks = await _replayOnTree((_) => [
            Change_Content(
              blockDuplicate: Change_BlockDuplicate(
                targetId: 'p2',
                position: Block_Position.Inner,
                ids: ['x', 'missing'],
              ),
            ),
          ]);
      expect(blocks['p1']!.childrenIds, ['x']);
      expect(blocks['p2']!.childrenIds, isEmpty);
    });

    test('relationAdd keeps an existing relation link', () async {
      final root = await _root();
      final change = await _change(
        [root.id],
        Change(content: [
          Change_Content(
            relationAdd: Change_RelationAdd(relationLinks: [
              RelationLink(key: 'status', format: RelationFormat.status),
            ]),
          ),
          Change_Content(
            relationAdd: Change_RelationAdd(relationLinks: [
              RelationLink(key: 'status', format: RelationFormat.tag),
            ]),
          ),
        ]),
      );

      final snapshot = await _replay([root, change]);
      expect(snapshot.relationLinks, hasLength(1));
      expect(snapshot.relationLinks.single.format, RelationFormat.status);
    });

    test('collection slice updates follow heart slice semantics', () async {
      final root = await _root();
      final change = await _change(
        [root.id],
        Change(content: [
          Change_Content(
            storeKeySet: Change_StoreKeySet(
              path: ['objects'],
              value: Value(
                listValue: ListValue(values: [
                  Value(stringValue: 'a'),
                  Value(stringValue: 'b'),
                ]),
              ),
            ),
          ),
          buildStoreSliceUpdateAdd(key: 'objects', ids: ['x'], afterId: 'gone'),
          buildStoreSliceUpdateMove(key: 'objects', ids: ['b', 'gone']),
        ]),
      );

      final snapshot = await _replay([root, change]);
      final objects = snapshot.collections.fields['objects']!.listValue.values
          .map((value) => value.stringValue);
      expect(objects, ['b', 'x', 'a']);
    });
  });
}
