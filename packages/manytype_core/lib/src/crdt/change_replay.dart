import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:libcompress/libcompress.dart' show SnappyCodec;
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, TreeChange;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

import '../crypto/aes_gcm.dart';
import 'cid.dart';
import 'store_slice.dart';

final _snappy = SnappyCodec();

/// Replay raw tree changes into a [ChangeReplayState].
///
/// [rawTreeChanges] must be in topological order. Encrypted and
/// snappy-compressed TreeChanges are transparently decoded with [treeKey];
/// the root change (whose id is the root block id) and changes without data
/// are skipped. With [skipUnreadable], a change that cannot be decoded is
/// skipped instead of failing the whole replay.
Future<ChangeReplayState> replayRawTreeChanges(
  List<Uint8List> rawTreeChanges,
  Uint8List treeKey, {
  bool skipUnreadable = false,
}) async {
  final state = ChangeReplayState(
    rootId:
        rawTreeChanges.isEmpty ? '' : await computeCid(rawTreeChanges.first),
  );

  for (final rawChange in rawTreeChanges) {
    try {
      await _replayRawTreeChange(state, rawChange, treeKey);
    } catch (_) {
      if (!skipUnreadable) rethrow;
    }
  }

  return state;
}

Future<void> _replayRawTreeChange(
  ChangeReplayState state,
  Uint8List rawChange,
  Uint8List treeKey,
) async {
  final rawTreeChange = RawTreeChange.fromBuffer(rawChange);
  if (rawTreeChange.payload.isEmpty) {
    return;
  }

  final TreeChange treeChange;
  try {
    treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
  } catch (_) {
    // Root change or non-tree payload.
    return;
  }
  if (treeChange.changesData.isEmpty) {
    return;
  }

  var data = Uint8List.fromList(treeChange.changesData);
  if (treeChange.readKeyId.isNotEmpty) {
    data = await aesGcmDecrypt(treeKey, data);
  }
  if (treeChange.dataType == '1/s') {
    data = _snappy.decompress(data);
  }

  state.applyChange(
    await computeCid(rawChange),
    treeChange.treeHeadIds,
    Change.fromBuffer(data),
  );
}

void _applyContent(ChangeReplayState state, Change_Content content) {
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
    case Change_Content_Value.relationAdd:
      for (final link in content.relationAdd.relationLinks) {
        state.relationLinks.putIfAbsent(link.key, link.deepCopy);
      }
      break;
    case Change_Content_Value.relationRemove:
      for (final key in content.relationRemove.relationKey) {
        state.relationLinks.remove(key);
      }
      break;
    case Change_Content_Value.detailsSet:
      if (content.detailsSet.hasValue()) {
        state.details.fields[content.detailsSet.key] =
            content.detailsSet.value.deepCopy();
      } else {
        state.details.fields.remove(content.detailsSet.key);
      }
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
    // Heart's applyChange has no blockDuplicate case, so it is ignored.
    case Change_Content_Value.blockDuplicate:
    case Change_Content_Value.notificationCreate:
    case Change_Content_Value.notificationUpdate:
    case Change_Content_Value.deviceAdd:
    case Change_Content_Value.deviceUpdate:
    case Change_Content_Value.notSet:
      break;
  }
}

void _applyBlockCreate(ChangeReplayState state, Change_BlockCreate create) {
  final ids = <String>[];
  for (final block in create.blocks) {
    // Like heart's changeBlockCreate: an existing root is kept, the root is
    // never inserted anywhere, and re-created blocks leave their old parent.
    if (block.id == state.rootId) {
      if (state.blocks.containsKey(block.id)) continue;
    } else {
      ids.add(block.id);
      _unlinkIds(state, [block.id]);
    }
    state.blocks[block.id] = block.deepCopy();
  }
  _insertIds(state, create.targetId, create.position, ids);
}

void _applyBlockRemove(ChangeReplayState state, Iterable<String> ids) {
  final toRemove = ids.toList();
  _unlinkIds(state, toRemove);
  for (final id in toRemove) {
    state.blocks.remove(id);
  }
}

void _applyBlockMove(
  ChangeReplayState state,
  String targetId,
  Block_Position position,
  Iterable<String> ids,
) {
  final movedIds = ids.toList();
  _unlinkIds(state, movedIds);
  _insertIds(state, targetId, position, movedIds);
}

void _applyBlockUpdateEvent(ChangeReplayState state, List<int> eventBytes) {
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
  ChangeReplayState state,
  String targetId,
  Block_Position position,
  List<String> ids,
) {
  if (ids.isEmpty) return;
  if (targetId.isEmpty) {
    // Like heart's InsertTo: no target means the root, inner positions only.
    if (state.rootId.isNotEmpty) {
      _insertIds(
        state,
        state.rootId,
        position == Block_Position.InnerFirst
            ? Block_Position.InnerFirst
            : Block_Position.Inner,
        ids,
      );
    }
    return;
  }

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

void _unlinkIds(ChangeReplayState state, List<String> ids) {
  if (ids.isEmpty) return;
  final idSet = ids.toSet();
  for (final block in state.blocks.values) {
    block.childrenIds.removeWhere(idSet.contains);
  }
}

Block? _findParent(ChangeReplayState state, String childId) {
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
  final current = applyStoreSliceUpdate(
    _readStringList(collections.fields[update.key]),
    update,
  );
  collections.fields[update.key] = Value(
    listValue: ListValue(
      values: current.map((value) => Value(stringValue: value)).toList(),
    ),
  );
}

List<String> _readStringList(Value? value) {
  if (value != null && value.hasStringValue() && value.stringValue.isNotEmpty) {
    return [value.stringValue];
  }
  if (value == null || !value.hasListValue()) {
    return <String>[];
  }
  return value.listValue.values
      .where((item) => item.hasStringValue())
      .map((item) => item.stringValue)
      .toList();
}

/// Object state accumulated while replaying tree changes.
///
/// Shared by [replayRawTreeChanges] and the in-memory ObjectTree replay in
/// `snapshot.dart` so both apply changes with the same rules.
class ChangeReplayState {
  ChangeReplayState({this.rootId = ''});

  /// Id of the object's root block, i.e. the tree id.
  final String rootId;

  final blocks = <String, Block>{};
  final relationLinks = <String, RelationLink>{};
  final details = Struct();
  final collections = Struct();
  final objectTypes = <String>[];
  final removedCollectionKeys = <String>{};
  final fileKeys = <String, Change_FileKeys>{};

  FileInfo? fileInfo;
  Int64? originalCreatedTimestamp;

  final _heads = <String>{};

  /// Apply tree change [changeId], whose parents are [parentIds].
  ///
  /// Mirrors heart's `BuildState`: snapshot data is only loaded when the
  /// snapshot supersedes everything replayed so far, i.e. its parents cover
  /// the current heads. A concurrent snapshot only contributes its content and
  /// file keys, so edits replayed from sibling branches survive.
  void applyChange(String changeId, List<String> parentIds, Change change) {
    final supersedesReplayed = _heads.every(parentIds.contains);
    _heads
      ..removeAll(parentIds)
      ..add(changeId);
    if (change.hasSnapshot() && supersedesReplayed) {
      loadSnapshot(change.snapshot);
      return;
    }

    if (change.fileKeys.isNotEmpty) {
      upsertFileKeys(change.fileKeys);
    }
    for (final content in change.content) {
      applyContent(content);
    }
  }

  void applyContent(Change_Content content) => _applyContent(this, content);

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
        data.blocks.map((block) => MapEntry(block.id, block.deepCopy())),
      );
    relationLinks
      ..clear()
      ..addEntries(
        data.relationLinks.map((link) => MapEntry(link.key, link.deepCopy())),
      );
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

  SmartBlockSnapshotBase toSnapshot() {
    final snapshot = SmartBlockSnapshotBase()
      ..blocks.addAll(blocks.values.map((block) => block.deepCopy()))
      ..details = details.deepCopy()
      ..collections = collections.deepCopy()
      ..objectTypes.addAll(objectTypes)
      ..relationLinks.addAll(
        relationLinks.values.map((link) => link.deepCopy()),
      )
      ..removedCollectionKeys.addAll(removedCollectionKeys);
    if (fileInfo != null) {
      snapshot.fileInfo = fileInfo!.deepCopy();
    }
    if (originalCreatedTimestamp != null) {
      snapshot.originalCreatedTimestamp = originalCreatedTimestamp!;
    }
    return snapshot;
  }
}
