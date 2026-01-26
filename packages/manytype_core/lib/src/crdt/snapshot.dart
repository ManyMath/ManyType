import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

import 'block.dart';
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
  _ReplayState replayed,
  String rootId,
) {
  final contentBlocks = replayed.blocks.values.toList()
    ..sort((left, right) => left.id.compareTo(right.id));

  final snapshot = createMinimalSnapshot(rootId, contentBlocks);
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

_ReplayState _replayTree(ObjectTree tree) {
  final state = _ReplayState();
  final changes = tree.serialize();

  for (var i = 0; i < changes.length; i++) {
    final rawTreeChange = RawTreeChange.fromBuffer(changes[i].rawChange);

    // The first change is the root change (RootChange proto, not TreeChange).
    if (i == 0) continue;

    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);

    if (treeChange.isSnapshot) {
      final change = Change.fromBuffer(treeChange.changesData);
      if (change.hasSnapshot()) {
        state.loadSnapshot(change.snapshot);
      }
      continue;
    }

    final change = Change.fromBuffer(treeChange.changesData);
    if (change.fileKeys.isNotEmpty) {
      state.upsertFileKeys(change.fileKeys);
    }
    for (final content in change.content) {
      _applyContent(state, content);
    }
  }

  return state;
}

void _applyContent(_ReplayState state, Change_Content content) {
  switch (content.whichValue()) {
    case Change_Content_Value.blockCreate:
      _applyBlockCreate(state, content.blockCreate);
      break;
    case Change_Content_Value.blockUpdate:
      for (final eventBytes in content.blockUpdate.events) {
        _applyBlockUpdateEvent(state, eventBytes);
      }
      break;
    case Change_Content_Value.blockRemove:
      _applyBlockRemove(state, content.blockRemove.ids);
      break;
    case Change_Content_Value.blockMove:
      _applyBlockMove(
        state,
        content.blockMove.targetId,
        content.blockMove.position,
        content.blockMove.ids,
      );
      break;
    case Change_Content_Value.blockDuplicate:
      _insertIds(
        state,
        content.blockDuplicate.targetId,
        content.blockDuplicate.position,
        content.blockDuplicate.ids.toList(),
      );
      break;
    case Change_Content_Value.relationAdd:
      for (final link in content.relationAdd.relationLinks) {
        state.relationLinks[link.key] = link.deepCopy();
      }
      break;
    case Change_Content_Value.relationRemove:
      for (final key in content.relationRemove.relationKey) {
        state.relationLinks.remove(key);
      }
      break;
    case Change_Content_Value.detailsSet:
      state.details.fields[content.detailsSet.key] =
          content.detailsSet.value.deepCopy();
      break;
    case Change_Content_Value.detailsUnset:
      state.details.fields.remove(content.detailsUnset.key);
      break;
    case Change_Content_Value.objectTypeAdd:
      state.addObjectType(
        content.objectTypeAdd.key.isNotEmpty
            ? content.objectTypeAdd.key
            : content.objectTypeAdd.url,
      );
      break;
    case Change_Content_Value.objectTypeRemove:
      state.removeObjectType(
        content.objectTypeRemove.key.isNotEmpty
            ? content.objectTypeRemove.key
            : content.objectTypeRemove.url,
      );
      break;
    case Change_Content_Value.storeKeySet:
      _setStructPath(
        state.collections,
        content.storeKeySet.path,
        content.storeKeySet.value.deepCopy(),
      );
      break;
    case Change_Content_Value.storeKeyUnset:
      _removeStructPath(state.collections, content.storeKeyUnset.path);
      if (content.storeKeyUnset.path.isNotEmpty) {
        state.removedCollectionKeys.add(content.storeKeyUnset.path.last);
      }
      break;
    case Change_Content_Value.storeSliceUpdate:
      _applyStoreSliceUpdate(state.collections, content.storeSliceUpdate);
      break;
    case Change_Content_Value.originalCreatedTimestampSet:
      if (content.originalCreatedTimestampSet.ts != Int64.ZERO) {
        state.originalCreatedTimestamp = content.originalCreatedTimestampSet.ts;
      }
      break;
    case Change_Content_Value.setFileInfo:
      state.fileInfo = content.setFileInfo.fileInfo.deepCopy();
      break;
    case Change_Content_Value.notificationCreate:
    case Change_Content_Value.notificationUpdate:
    case Change_Content_Value.deviceAdd:
    case Change_Content_Value.deviceUpdate:
    case Change_Content_Value.notSet:
      break;
  }
}

void _applyBlockCreate(_ReplayState state, Change_BlockCreate create) {
  final ids = <String>[];
  for (final block in create.blocks) {
    state.blocks[block.id] = block.deepCopy();
    ids.add(block.id);
  }
  _insertIds(state, create.targetId, create.position, ids);
}

void _applyBlockRemove(_ReplayState state, Iterable<String> ids) {
  final toRemove = ids.toList();
  _unlinkIds(state, toRemove);
  for (final id in toRemove) {
    state.blocks.remove(id);
  }
}

void _applyBlockMove(
  _ReplayState state,
  String targetId,
  Block_Position position,
  Iterable<String> ids,
) {
  final movedIds = ids.toList();
  _unlinkIds(state, movedIds);
  _insertIds(state, targetId, position, movedIds);
}

void _applyBlockUpdateEvent(_ReplayState state, List<int> eventBytes) {
  Event_Message event;
  try {
    event = Event_Message.fromBuffer(eventBytes);
  } catch (_) {
    return;
  }

  switch (event.whichValue()) {
    case Event_Message_Value.blockSetFields:
      final block = state.blocks[event.blockSetFields.id];
      if (block != null) {
        block.fields = event.blockSetFields.fields.deepCopy();
      }
      break;
    case Event_Message_Value.blockSetChildrenIds:
      final block = state.blocks[event.blockSetChildrenIds.id];
      if (block != null) {
        block.childrenIds
          ..clear()
          ..addAll(event.blockSetChildrenIds.childrenIds);
      }
      break;
    case Event_Message_Value.blockSetBackgroundColor:
      final block = state.blocks[event.blockSetBackgroundColor.id];
      if (block != null) {
        block.backgroundColor = event.blockSetBackgroundColor.backgroundColor;
      }
      break;
    case Event_Message_Value.blockSetText:
      final block = state.blocks[event.blockSetText.id];
      if (block != null) {
        block.text = block.hasText() ? block.text : Block_Content_Text();
        if (event.blockSetText.hasText()) {
          block.text.text = event.blockSetText.text.value;
        }
        if (event.blockSetText.hasStyle()) {
          block.text.style = event.blockSetText.style.value;
        }
        if (event.blockSetText.hasMarks()) {
          block.text.marks = event.blockSetText.marks.value.deepCopy();
        }
        if (event.blockSetText.hasChecked()) {
          block.text.checked = event.blockSetText.checked.value;
        }
        if (event.blockSetText.hasColor()) {
          block.text.color = event.blockSetText.color.value;
        }
        if (event.blockSetText.hasIconEmoji()) {
          block.text.iconEmoji = event.blockSetText.iconEmoji.value;
        }
        if (event.blockSetText.hasIconImage()) {
          block.text.iconImage = event.blockSetText.iconImage.value;
        }
      }
      break;
    case Event_Message_Value.blockSetAlign:
      final block = state.blocks[event.blockSetAlign.id];
      if (block != null) {
        block.align = event.blockSetAlign.align;
      }
      break;
    case Event_Message_Value.blockSetDiv:
      final block = state.blocks[event.blockSetDiv.id];
      if (block != null) {
        block.div = block.hasDiv() ? block.div : Block_Content_Div();
        if (event.blockSetDiv.hasStyle()) {
          block.div.style = event.blockSetDiv.style.value;
        }
      }
      break;
    case Event_Message_Value.blockSetRelation:
      final block = state.blocks[event.blockSetRelation.id];
      if (block != null) {
        block.relation =
            block.hasRelation() ? block.relation : Block_Content_Relation();
        if (event.blockSetRelation.hasKey()) {
          block.relation.key = event.blockSetRelation.key.value;
        }
      }
      break;
    case Event_Message_Value.blockSetLatex:
      final block = state.blocks[event.blockSetLatex.id];
      if (block != null) {
        block.latex = block.hasLatex() ? block.latex : Block_Content_Latex();
        if (event.blockSetLatex.hasText()) {
          block.latex.text = event.blockSetLatex.text.value;
        }
        if (event.blockSetLatex.hasProcessor()) {
          block.latex.processor = event.blockSetLatex.processor.value;
        }
      }
      break;
    case Event_Message_Value.blockSetVerticalAlign:
      final block = state.blocks[event.blockSetVerticalAlign.id];
      if (block != null) {
        block.verticalAlign = event.blockSetVerticalAlign.verticalAlign;
      }
      break;
    case Event_Message_Value.blockSetTableRow:
      final block = state.blocks[event.blockSetTableRow.id];
      if (block != null) {
        block.tableRow =
            block.hasTableRow() ? block.tableRow : Block_Content_TableRow();
        if (event.blockSetTableRow.hasIsHeader()) {
          block.tableRow.isHeader = event.blockSetTableRow.isHeader.value;
        }
      }
      break;
    case Event_Message_Value.blockSetWidget:
      final block = state.blocks[event.blockSetWidget.id];
      if (block != null) {
        block.widget =
            block.hasWidget() ? block.widget : Block_Content_Widget();
        if (event.blockSetWidget.hasLayout()) {
          block.widget.layout = event.blockSetWidget.layout.value;
        }
        if (event.blockSetWidget.hasLimit()) {
          block.widget.limit = event.blockSetWidget.limit.value;
        }
        if (event.blockSetWidget.hasViewId()) {
          block.widget.viewId = event.blockSetWidget.viewId.value;
        }
      }
      break;
    case Event_Message_Value.notSet:
      break;
  }
}

void _insertIds(
  _ReplayState state,
  String targetId,
  Block_Position position,
  List<String> ids,
) {
  if (ids.isEmpty || targetId.isEmpty) return;

  final target = state.blocks[targetId];
  switch (position) {
    case Block_Position.Inner:
      if (target != null) {
        target.childrenIds.addAll(ids);
      }
      break;
    case Block_Position.InnerFirst:
      if (target != null) {
        target.childrenIds.insertAll(0, ids);
      }
      break;
    case Block_Position.Top:
    case Block_Position.Left:
      final parent = _findParent(state, targetId);
      if (parent != null) {
        final index = parent.childrenIds.indexOf(targetId);
        if (index >= 0) {
          parent.childrenIds.insertAll(index, ids);
        }
      }
      break;
    case Block_Position.Bottom:
    case Block_Position.Right:
      final parent = _findParent(state, targetId);
      if (parent != null) {
        final index = parent.childrenIds.indexOf(targetId);
        if (index >= 0) {
          parent.childrenIds.insertAll(index + 1, ids);
        }
      }
      break;
    case Block_Position.Replace:
      final parent = _findParent(state, targetId);
      if (parent != null) {
        final index = parent.childrenIds.indexOf(targetId);
        if (index >= 0) {
          parent.childrenIds
            ..removeAt(index)
            ..insertAll(index, ids);
        }
      }
      final replaced = state.blocks[targetId];
      if (replaced != null && ids.isNotEmpty) {
        final firstReplacement = state.blocks[ids.first];
        if (firstReplacement != null && firstReplacement.childrenIds.isEmpty) {
          firstReplacement.childrenIds.addAll(replaced.childrenIds);
        }
      }
      state.blocks.remove(targetId);
      break;
    case Block_Position.None:
      break;
  }
}

void _unlinkIds(_ReplayState state, List<String> ids) {
  if (ids.isEmpty) return;
  final idSet = ids.toSet();
  for (final block in state.blocks.values) {
    block.childrenIds.removeWhere(idSet.contains);
  }
}

Block? _findParent(_ReplayState state, String childId) {
  for (final block in state.blocks.values) {
    if (block.childrenIds.contains(childId)) {
      return block;
    }
  }
  return null;
}

void _setStructPath(Struct root, List<String> path, Value value) {
  if (path.isEmpty) return;

  var current = root;
  for (final segment in path.take(path.length - 1)) {
    final existing = current.fields[segment];
    if (existing == null || !existing.hasStructValue()) {
      current.fields[segment] = Value(structValue: Struct());
    }
    current = current.fields[segment]!.structValue;
  }
  current.fields[path.last] = value;
}

void _removeStructPath(Struct root, List<String> path) {
  if (path.isEmpty) return;

  var current = root;
  for (final segment in path.take(path.length - 1)) {
    final next = current.fields[segment];
    if (next == null || !next.hasStructValue()) {
      return;
    }
    current = next.structValue;
  }
  current.fields.remove(path.last);
}

void _applyStoreSliceUpdate(
    Struct collections, Change_StoreSliceUpdate update) {
  final current = _readStringList(collections.fields[update.key]);
  switch (update.whichOperation()) {
    case Change_StoreSliceUpdate_Operation.add:
      _insertAfterId(current, update.add.afterId, update.add.ids);
      break;
    case Change_StoreSliceUpdate_Operation.remove:
      current.removeWhere(update.remove.ids.contains);
      break;
    case Change_StoreSliceUpdate_Operation.move:
      current.removeWhere(update.move.ids.contains);
      _insertAfterId(current, update.move.afterId, update.move.ids);
      break;
    case Change_StoreSliceUpdate_Operation.notSet:
      break;
  }
  collections.fields[update.key] = Value(
    listValue: ListValue(
      values: current.map((value) => Value(stringValue: value)).toList(),
    ),
  );
}

List<String> _readStringList(Value? value) {
  if (value == null || !value.hasListValue()) {
    return <String>[];
  }
  return value.listValue.values
      .where((item) => item.hasStringValue())
      .map((item) => item.stringValue)
      .toList();
}

void _insertAfterId(
    List<String> current, String afterId, Iterable<String> ids) {
  final values = ids.toList();
  if (values.isEmpty) return;

  if (afterId.isEmpty) {
    current.insertAll(0, values);
    return;
  }

  final index = current.indexOf(afterId);
  if (index < 0) {
    current.addAll(values);
    return;
  }
  current.insertAll(index + 1, values);
}

class _ReplayState {
  final blocks = <String, Block>{};
  final relationLinks = <String, RelationLink>{};
  final details = Struct();
  final collections = Struct();
  final objectTypes = <String>[];
  final removedCollectionKeys = <String>{};
  final fileKeys = <String, Change_FileKeys>{};

  FileInfo? fileInfo;
  Int64? originalCreatedTimestamp;

  void addObjectType(String value) {
    if (value.isEmpty || objectTypes.contains(value)) return;
    objectTypes.add(value);
  }

  void removeObjectType(String value) {
    objectTypes.remove(value);
  }

  void upsertFileKeys(Iterable<Change_FileKeys> keys) {
    for (final key in keys) {
      final hash = key.hash.trim();
      if (hash.isEmpty) {
        continue;
      }
      fileKeys[hash] = key.deepCopy();
    }
  }

  void loadSnapshot(Change_Snapshot snapshot) {
    final data = snapshot.data;
    blocks
      ..clear()
      ..addEntries(
          data.blocks.map((block) => MapEntry(block.id, block.deepCopy())));
    relationLinks
      ..clear()
      ..addEntries(data.relationLinks
          .map((link) => MapEntry(link.key, link.deepCopy())));
    details.fields
      ..clear()
      ..addAll(data.details.deepCopy().fields);
    collections.fields
      ..clear()
      ..addAll(data.collections.deepCopy().fields);
    objectTypes
      ..clear()
      ..addAll(data.objectTypes);
    removedCollectionKeys
      ..clear()
      ..addAll(data.removedCollectionKeys);
    fileKeys.clear();
    upsertFileKeys(snapshot.fileKeys);
    fileInfo = data.hasFileInfo() ? data.fileInfo.deepCopy() : null;
    originalCreatedTimestamp = data.hasOriginalCreatedTimestamp()
        ? data.originalCreatedTimestamp
        : null;
  }
}
