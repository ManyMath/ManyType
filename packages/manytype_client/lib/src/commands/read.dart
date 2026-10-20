import 'dart:typed_data';

import 'package:libcompress/libcompress.dart' show SnappyCodec;
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    show ListValue, Value;

import '../config.dart';
import '../collection_keys.dart';
import '../identity.dart';
import '../store/database.dart';

final _snappy = SnappyCodec();

/// Rendered text report for the `read` command's list-all-objects view
/// (no object ID given). `lines` mirrors exactly what the CLI printed to
/// stdout, one entry per line (including blank separator lines).
class ReadListResult {
  const ReadListResult({required this.spaceId, required this.lines});

  final String spaceId;
  final List<String> lines;
}

/// Rendered text report for the `read` command's single-object detail view.
/// `lines` mirrors exactly what the CLI printed to stdout, one entry per
/// line (including blank separator lines).
class ReadDetailResult {
  const ReadDetailResult({
    required this.objectId,
    required this.lines,
    this.notFound = false,
  });

  final String objectId;
  final List<String> lines;

  /// True when no local changes exist for [objectId]: [lines] then holds
  /// just the "Object not found" message.
  final bool notFound;
}

/// Result of [readCommand]. Exactly one of [listing]/[detail] is non-null,
/// depending on whether an `objectId` was passed.
class ReadResult {
  const ReadResult({this.listing, this.detail});

  final ReadListResult? listing;
  final ReadDetailResult? detail;
}

/// Thrown by [readCommand] when the requested object has been deleted or
/// archived. Distinct from the "not found locally" case (which is not an
/// error: see [ReadDetailResult.notFound]).
class ObjectUnavailableError extends StateError {
  ObjectUnavailableError(this.objectId)
      : super('Object $objectId has been deleted or archived');

  final String objectId;
}

/// Read and display objects from local store.
///
/// Without arguments: lists all objects with text previews.
/// With object ID: shows that object's full content.
Future<ReadResult> readCommand(
  ManytypeDatabase db,
  CliConfig config, {
  String? objectId,
}) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = identity.spaceId;

  if (objectId != null) {
    return ReadResult(detail: await _showObject(db, config, objectId));
  } else {
    return ReadResult(listing: await _listObjects(db, spaceId, config));
  }
}

/// List all objects in the space with text previews.
Future<ReadListResult> _listObjects(
  ManytypeDatabase db,
  String spaceId,
  CliConfig config,
) async {
  final lines = <String>[];
  void emit(String line) => lines.add(line);

  final objects = await db.getNonDeletedObjectsBySpace(spaceId);
  if (objects.isEmpty) {
    emit('No objects found. Create one with: manytype create "your text"');
    return ReadListResult(spaceId: spaceId, lines: lines);
  }

  final spaceKey = await _tryDeriveSpaceKey(config);
  emit('Objects in space ($spaceId):');
  emit('');
  for (final obj in objects) {
    if (await _isObjectArchived(db, obj.id, spaceKey)) {
      continue;
    }
    final changes = await db.getChangesForObject(obj.id);
    final heads = await db.getObjectHeads(obj.id);
    final attachments = await db.getAttachmentRefsByObject(obj.id);
    final treeKey =
        spaceKey == null ? null : await deriveTreeKey(spaceKey, obj.id);
    final textPreview = await extractTextPreview(changes, treeKey: treeKey);

    emit('  ${obj.id}');
    emit('    Created: ${obj.createdAt}');
    emit('    Changes: ${changes.length}');
    emit('    Heads: ${heads.join(", ")}');
    if (textPreview.isNotEmpty) {
      emit('    Text: $textPreview');
    }
    _printAttachmentRefs(attachments, emit, indent: '    ');
    emit('');
  }

  return ReadListResult(spaceId: spaceId, lines: lines);
}

/// Show detailed content for a specific object.
Future<ReadDetailResult> _showObject(
  ManytypeDatabase db,
  CliConfig config,
  String objectId,
) async {
  final lines = <String>[];
  void emit(String line) => lines.add(line);

  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    emit('Object not found: $objectId');
    return ReadDetailResult(objectId: objectId, lines: lines, notFound: true);
  }

  // Official Anytype trees encrypt `TreeChange.changesData` using a tree key
  // derived from the space read key and object ID, and may additionally snappy
  // compress the plaintext when `dataType == "1/s"`.
  Uint8List? treeKey;
  Uint8List? spaceKey;
  String? spaceId;
  final cachedChangesByObject = <String, List<Change>>{};
  try {
    final identity = await Identity.fromMnemonic(config.mnemonic);
    final accountKeyPair = await ed25519KeyPairFromSeed(identity.accountSeed);
    final accountPrivRaw = Uint8List(64)
      ..setRange(0, 32, identity.accountSeed)
      ..setRange(32, 64, accountKeyPair.publicKey);
    spaceKey = await deriveSpaceKey(accountPrivRaw);
    treeKey = await deriveTreeKey(spaceKey, objectId);
    spaceId = identity.spaceId;
  } catch (_) {
    treeKey = null;
  }

  if (await db.isObjectDeleted(objectId) ||
      await _isObjectArchived(db, objectId, spaceKey)) {
    throw ObjectUnavailableError(objectId);
  }

  // Phase 38: Build the STRelationOption index ONCE per read invocation.
  // Scans every non-deleted object in the space, filters roots whose
  // smart_block_type == 529 (STRelationOption), and returns a map from
  // option ID -> ResolvedOption (name + color + relationKey or orphaned
  // sentinel). Used by _formatOptionRelationValue below to resolve status
  // and tag relation values on this object's snapshot details.
  var optIndex = const <String, ResolvedOption>{};
  if (spaceKey != null && spaceId != null) {
    try {
      final spaceObjects = await db.getNonDeletedObjectsBySpace(spaceId);
      final optionInputs = <OptionIndexInput>[];
      for (final obj in spaceObjects) {
        final rawRows = await db.getChangesForObject(obj.id);
        cachedChangesByObject[obj.id] = rawRows;
        final objTreeKey = await deriveTreeKey(spaceKey, obj.id);
        optionInputs.add(OptionIndexInput(
          objectId: obj.id,
          rawTreeChanges:
              rawRows.map((r) => Uint8List.fromList(r.rawBytes)).toList(),
          treeKey: objTreeKey,
        ));
      }
      optIndex = await loadLocalOptionIndex(optionInputs);
    } catch (_) {
      // Option index load failure is non-fatal: fall through with an
      // empty map so status/tag relations render as orphans rather than
      // crashing the whole read path.
      optIndex = const <String, ResolvedOption>{};
    }
  }

  emit('Object: $objectId');
  emit('Changes: ${changes.length}');

  // Extract and display SmartBlockType from root change.
  final smartBlockType = _extractSmartBlockType(changes);
  if (smartBlockType != null) {
    switch (smartBlockType) {
      case 528: // SmartBlockType.STType
        emit('  Kind: [Type]');
      case 521: // SmartBlockType.STRelation
        emit('  Kind: [Relation]');
      case 288: // SmartBlockType.Template
        emit('  Kind: [Template]');
      case 16: // SmartBlockType.Page
        emit('  Kind: [Page]');
      default:
        emit('  Kind: [$smartBlockType]');
    }
  }

  // Extract snapshot metadata (objectTypes, relationLinks, details, Dataview blocks).
  await _printSnapshotMetadata(
    changes,
    emit,
    db: db,
    spaceKey: spaceKey,
    cachedChangesByObject: cachedChangesByObject,
    treeKey: treeKey,
    smartBlockType: smartBlockType,
    optIndex: optIndex,
  );

  _printAttachmentRefs(await db.getAttachmentRefsByObject(objectId), emit);
  emit('');

  for (final change in changes) {
    try {
      // Database rawBytes = serialized RawTreeChange (payload + signature).
      final rawTreeChange = RawTreeChange.fromBuffer(change.rawBytes);
      emit('  Change ${change.id}:');

      if (rawTreeChange.payload.isNotEmpty) {
        // Try as TreeChange first (non-root changes have changesData).
        try {
          final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
          if (treeChange.changesData.isNotEmpty) {
            await _printBlockChanges(
              treeChange,
              emit,
              treeKey: treeKey,
            );
          } else {
            emit('    (no block data)');
          }
        } catch (_) {
          // Root changes use RootChange proto (no changesData).
          emit('    (root change)');
        }
      }
    } catch (e) {
      emit('  Change ${change.id}: (binary, ${change.rawBytes.length} bytes)');
    }
  }

  return ReadDetailResult(objectId: objectId, lines: lines);
}

Future<Uint8List?> _tryDeriveSpaceKey(CliConfig config) async {
  try {
    final identity = await Identity.fromMnemonic(config.mnemonic);
    final accountPrivRaw = Uint8List(64)
      ..setRange(0, 32, identity.accountSeed)
      ..setRange(32, 64, identity.accountKeyPair.publicKey);
    return await deriveSpaceKey(accountPrivRaw);
  } catch (_) {
    return null;
  }
}

Future<bool> _isObjectArchived(
  ManytypeDatabase db,
  String objectId,
  Uint8List? spaceKey,
) async {
  if (spaceKey == null) {
    return false;
  }

  try {
    final changes = await db.getChangesForObject(objectId);
    if (changes.isEmpty) {
      return false;
    }
    final treeKey = await deriveTreeKey(spaceKey, objectId);
    final details = await replayObjectDetails(
      rawTreeChanges:
          changes.map((change) => Uint8List.fromList(change.rawBytes)).toList(),
      treeKey: treeKey,
    );
    final isArchived = details['isArchived'];
    return isArchived != null &&
        isArchived.hasBoolValue() &&
        isArchived.boolValue;
  } catch (_) {
    return false;
  }
}

void _printAttachmentRefs(
  List<StoredAttachmentRef> attachments,
  void Function(String) emit, {
  String indent = '',
}) {
  if (attachments.isEmpty) {
    return;
  }

  emit('${indent}Attachments:');
  for (final attachment in attachments) {
    final cidLabel =
        attachment.cid.isEmpty ? 'metadata only' : 'cid=${attachment.cid}';
    emit('${indent}  ${attachment.fileId} ($cidLabel)');
  }
}

/// Extract text content preview from the most recent non-root change.
///
/// [treeKey] decrypts changesData when the change's `readKeyId` is set (the
/// normal case for every locally-created object -- there is no plaintext
/// path). Pass `null` only when the space key/tree key couldn't be derived;
/// encrypted changes are then skipped rather than surfaced as empty.
Future<String> extractTextPreview(
  List<Change> changes, {
  Uint8List? treeKey,
}) async {
  for (final change in changes.reversed) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(change.rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;

      final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      if (treeChange.changesData.isNotEmpty) {
        final decoded = await _decodeTreeChangeChangesData(
          treeChange,
          treeKey: treeKey,
        );
        final text = _extractTextFromDecodedChangeBytes(decoded);
        if (text.isNotEmpty) return text;
      }
    } catch (_) {
      continue;
    }
  }
  return '';
}

/// Extract text from Change proto bytes.
///
/// Checks the snapshot first: `create` embeds the initial title/text
/// directly in the root snapshot's details/blocks rather than emitting a
/// follow-up `BlockCreate` change, so a freshly-created object's only
/// change is a snapshot with no `content` entries at all.
String _extractTextFromDecodedChangeBytes(Uint8List decoded) {
  try {
    final change = changes_proto.Change.fromBuffer(decoded);
    if (change.hasSnapshot()) {
      final snapData = change.snapshot.data;
      if (snapData.hasDetails()) {
        final name = snapData.details.fields['name'];
        if (name != null && name.hasStringValue()) {
          final title = name.stringValue.trim();
          if (title.isNotEmpty) return title;
        }
      }
      for (final block in snapData.blocks) {
        if (block.hasText()) {
          final text = block.text.text.trim();
          if (text.isNotEmpty) return text;
        }
      }
    }
    for (final content in change.content) {
      if (content.hasDetailsSet() &&
          content.detailsSet.key == 'name' &&
          content.detailsSet.value.hasStringValue()) {
        final title = content.detailsSet.value.stringValue.trim();
        if (title.isNotEmpty) {
          return title;
        }
      }
      if (content.hasBlockCreate()) {
        for (final block in content.blockCreate.blocks) {
          if (block.hasText()) {
            return block.text.text;
          }
        }
      }
      if (content.hasBlockUpdate()) {
        for (final eventBytes in content.blockUpdate.events) {
          try {
            final eventMsg = Event_Message.fromBuffer(eventBytes);
            if (eventMsg.hasBlockSetText()) {
              return eventMsg.blockSetText.text.value;
            }
          } catch (_) {
            continue;
          }
        }
      }
    }
  } catch (_) {}
  return '';
}

/// Print metadata, blocks and collection members from the object's current
/// state, replayed by the shared core replay so `_printSnapshotBlocks`
/// renders every post-snapshot mutation (Phase 37: BlockUpdate mutations must
/// be visible on re-read).
Future<void> _printSnapshotMetadata(
  List<Change> changes,
  void Function(String) emit, {
  required ManytypeDatabase db,
  required Uint8List? spaceKey,
  Map<String, List<Change>> cachedChangesByObject = const {},
  required Uint8List? treeKey,
  int? smartBlockType,
  Map<String, ResolvedOption> optIndex = const <String, ResolvedOption>{},
}) async {
  // Without a tree key, encrypted changes fail to decrypt and are skipped.
  final snapData = await replayObjectSnapshot(
    rawTreeChanges:
        changes.map((change) => Uint8List.fromList(change.rawBytes)).toList(),
    treeKey: treeKey ?? Uint8List(32),
  );

  // objectTypes
  if (snapData.objectTypes.isNotEmpty) {
    emit('  Type: ${snapData.objectTypes.join(', ')}');
  }

  // relationLinks
  if (snapData.relationLinks.isNotEmpty) {
    emit('  Relations: ${snapData.relationLinks.map((l) => l.key).join(', ')}');
  }

  // Type/Relation-specific details from snapshot.
  if (snapData.hasDetails()) {
    final fields = snapData.details.fields;
    if (fields.containsKey('name')) {
      emit('  Name: ${fields['name']!.stringValue}');
    }
    if (smartBlockType == 521 && fields.containsKey('relationFormat')) {
      emit('  Format: ${_formatName(fields['relationFormat']!.numberValue)}');
    }
  }

  // Dataview blocks in snapshot.
  for (final block in snapData.blocks) {
    if (block.hasDataview()) {
      final dv = block.dataview;
      final sources = dv.source.join(', ');
      final viewCount = dv.views.length;
      emit('  [Dataview] source: $sources, views: $viewCount');
    }
  }

  final blockState = <String, Block>{
    for (final block in snapData.blocks) block.id: block,
  };
  final blockOrder = [for (final block in snapData.blocks) block.id];
  final mergedDetails = snapData.details.fields;
  final mergedCollections = snapData.collections.fields;

  // Phase 38: render status and tag relation VALUES using the local
  // STRelationOption index. Two detection paths:
  //
  // 1. Snapshot relationLinks path (Plan 03 original): for each link whose
  //    format is RelationFormat.status/tag, render the value from
  //    mergedDetails via _formatOptionRelationValue.
  // 2. Value-based detection (Phase 38 verification harness fix): Plan 02
  //    does not write a RelationAdd alongside DetailsSet, and
  //    `create --as-relation` only records the relation in the parent
  //    STRelation tree, not in the target object's relationLinks. So for
  //    any merged-details key whose stringValue or listValue-of-strings
  //    matches an ID in the local STRelationOption index, render via
  //    _formatOptionRelationValue too. This is safe because optIndex
  //    only contains STRelationOption object IDs (varint-filtered by
  //    smart_block_type == 529).
  //
  // Format strings (D-10 / D-11 / D-13):
  //   Status: `[<relationKey>] <OptionName> (<color>)`
  //      Tag: `[<relationKey>] <name1>, <name2>, <name3>`
  //   Orphan: `<unknown:xxxxxxxx>`
  final renderedRelationKeys = <String>{};

  // targetObjectType/sourceObject are read from mergedDetails (not just the
  // genesis snapshot) because official-client template application sets
  // sourceObject via a post-creation DetailsSet, not the creation snapshot.
  if (mergedDetails.containsKey('targetObjectType')) {
    final targetTypeId = mergedDetails['targetObjectType']!.stringValue;
    final targetTypeName = await _resolveMemberName(
      db,
      targetTypeId,
      spaceKey: spaceKey,
      cachedChanges: cachedChangesByObject[targetTypeId],
    );
    if (targetTypeName == null) {
      emit('  Target Type: $targetTypeId');
    } else {
      emit('  Target Type: $targetTypeName ($targetTypeId)');
    }
    renderedRelationKeys.add('targetObjectType');
  }
  if (mergedDetails.containsKey('sourceObject')) {
    emit('  Source Template: ${mergedDetails['sourceObject']!.stringValue}');
    renderedRelationKeys.add('sourceObject');
  }

  for (final link in snapData.relationLinks) {
    if (link.format != RelationFormat.status &&
        link.format != RelationFormat.tag) {
      continue;
    }
    final val = mergedDetails[link.key];
    if (val == null) continue;
    final rendered = _formatOptionRelationValue(val, optIndex);
    emit('  [${link.key}] $rendered');
    renderedRelationKeys.add(link.key);
  }
  // Value-based fallback: detect option-relation details whose values
  // point at known option IDs in optIndex.
  if (optIndex.isNotEmpty) {
    for (final entry in mergedDetails.entries) {
      if (renderedRelationKeys.contains(entry.key)) continue;
      final val = entry.value;
      bool looksLikeOptionRef = false;
      if (val.hasStringValue() && optIndex.containsKey(val.stringValue)) {
        looksLikeOptionRef = true;
      } else if (val.hasListValue()) {
        for (final v in val.listValue.values) {
          if (v.hasStringValue() && optIndex.containsKey(v.stringValue)) {
            looksLikeOptionRef = true;
            break;
          }
        }
      }
      if (!looksLikeOptionRef) continue;
      final rendered = _formatOptionRelationValue(val, optIndex);
      emit('  [${entry.key}] $rendered');
      renderedRelationKeys.add(entry.key);
    }
  }

  for (final link in snapData.relationLinks) {
    if (renderedRelationKeys.contains(link.key) ||
        link.format != RelationFormat.file) {
      continue;
    }
    final val = mergedDetails[link.key];
    if (val == null) continue;
    final rendered = await _formatFileRelationValue(
      val,
      db,
      spaceKey: spaceKey,
      cachedChangesByObject: cachedChangesByObject,
      assumeFileRelation: true,
    );
    if (rendered == null) continue;
    emit('  [${link.key}] $rendered');
    renderedRelationKeys.add(link.key);
  }
  if (spaceKey != null) {
    for (final entry in mergedDetails.entries) {
      if (renderedRelationKeys.contains(entry.key)) continue;
      final rendered = await _formatFileRelationValue(
        entry.value,
        db,
        spaceKey: spaceKey,
        cachedChangesByObject: cachedChangesByObject,
        assumeFileRelation: false,
      );
      if (rendered == null) continue;
      emit('  [${entry.key}] $rendered');
      renderedRelationKeys.add(entry.key);
    }
  }
  for (final entry in mergedDetails.entries) {
    if (renderedRelationKeys.contains(entry.key) ||
        _hiddenGenericDetailKeys.contains(entry.key)) {
      continue;
    }
    final rendered = _formatGenericDetailValue(entry.value);
    if (rendered == null) continue;
    emit('  [${entry.key}] $rendered');
    renderedRelationKeys.add(entry.key);
  }

  _printSnapshotBlocks(blockOrder, blockState, emit);
  await _printCollectionMembers(
    db,
    emit,
    spaceKey: spaceKey,
    blocks: blockState.values.toList(growable: false),
    collections: mergedCollections,
    cachedChangesByObject: cachedChangesByObject,
  );
}

/// Walk the replayed block map in insertion order and render user-visible
/// text blocks with their stable block ID as an `[id]` prefix. Structural /
/// container blocks (header, title, featuredRelations) are skipped so the
/// output stays focused on blocks the user can mutate via
/// `edit --block-id <id>`.
void _printSnapshotBlocks(
  List<String> blockOrder,
  Map<String, Block> blockState,
  void Function(String) emit,
) {
  // Structural blocks with well-known fixed ids (see
  // manytype_core/lib/src/crdt/block.dart createMinimalPageSnapshotBase).
  const structuralIds = <String>{
    'header',
    'title',
    'featuredRelations',
  };

  for (final id in blockOrder) {
    if (structuralIds.contains(id)) continue;
    final block = blockState[id];
    if (block == null) continue;
    // Skip the smartblock root (no text content, serves as container).
    if (!block.hasText()) continue;

    final text = block.text.text;
    final style = block.text.style;
    switch (style) {
      case Block_Content_Text_Style.Checkbox:
        final mark = block.text.checked ? '[x]' : '[ ]';
        emit('    [${block.id}] $mark [Checkbox] $text');
        break;
      case Block_Content_Text_Style.Header1:
        emit('    [${block.id}] [Header1] $text');
        break;
      case Block_Content_Text_Style.Header2:
        emit('    [${block.id}] [Header2] $text');
        break;
      case Block_Content_Text_Style.Header3:
        emit('    [${block.id}] [Header3] $text');
        break;
      case Block_Content_Text_Style.Quote:
        emit('    [${block.id}] [Quote] $text');
        break;
      case Block_Content_Text_Style.Numbered:
        emit('    [${block.id}] [Numbered] $text');
        break;
      case Block_Content_Text_Style.Toggle:
        emit('    [${block.id}] [Toggle] $text');
        break;
      case Block_Content_Text_Style.Callout:
        emit('    [${block.id}] [Callout] $text');
        break;
      case Block_Content_Text_Style.Paragraph:
      default:
        emit('    [${block.id}] [Paragraph] $text');
        break;
    }
  }
}

Future<void> _printCollectionMembers(
  ManytypeDatabase db,
  void Function(String) emit, {
  required Uint8List? spaceKey,
  required List<Block> blocks,
  required Map<String, Value> collections,
  Map<String, List<Change>> cachedChangesByObject = const {},
}) async {
  final dataview = _findCollectionDataview(blocks);
  if (dataview == null) {
    return;
  }

  final viewId = dataview.views.isNotEmpty ? dataview.views.first.id : null;
  final storeKey = viewId == null
      ? null
      : resolveCollectionStoreKeyFromValues(dataview, collections);
  final memberIds = storeKey == null
      ? const <String>[]
      : _readCollectionStringList(collections[storeKey]);

  emit('');
  emit('## Members');
  if (memberIds.isEmpty) {
    emit('(empty)');
    return;
  }

  for (final memberId in memberIds) {
    final memberName = await _resolveMemberName(
      db,
      memberId,
      spaceKey: spaceKey,
      cachedChanges: cachedChangesByObject[memberId],
    );
    emit('- ${memberName ?? '<unknown>'} ($memberId)');
  }
}

Future<String?> _resolveMemberName(
  ManytypeDatabase db,
  String objectId, {
  required Uint8List? spaceKey,
  List<Change>? cachedChanges,
}) async {
  if (spaceKey == null) {
    return null;
  }

  try {
    final changes = cachedChanges ?? await db.getChangesForObject(objectId);
    if (changes.isEmpty) {
      return null;
    }

    final treeKey = await deriveTreeKey(spaceKey, objectId);
    final details = await replayObjectDetails(
      rawTreeChanges:
          changes.map((change) => Uint8List.fromList(change.rawBytes)).toList(),
      treeKey: treeKey,
    );
    final name = details['name'];
    if (name != null && name.hasStringValue()) {
      final value = name.stringValue.trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
  } catch (_) {
    return null;
  }

  return null;
}

Block_Content_Dataview? _findCollectionDataview(List<Block> blocks) {
  for (final block in blocks) {
    if (block.hasDataview() && block.dataview.isCollection) {
      return block.dataview;
    }
  }
  return null;
}

List<String> _readCollectionStringList(Value? value) {
  if (value == null || !value.hasListValue()) {
    return <String>[];
  }
  return value.listValue.values
      .where((item) => item.hasStringValue())
      .map((item) => item.stringValue)
      .toList();
}

/// Print block content from changesData bytes.
Future<void> _printBlockChanges(
  TreeChange treeChange,
  void Function(String) emit, {
  required Uint8List? treeKey,
}) async {
  try {
    final decoded = await _decodeTreeChangeChangesData(
      treeChange,
      treeKey: treeKey,
    );
    final change = changes_proto.Change.fromBuffer(decoded);
    for (final content in change.content) {
      if (content.hasDetailsSet()) {
        final key = content.detailsSet.key;
        final val = content.detailsSet.value;
        if (key == 'name' && val.hasStringValue()) {
          emit('    Text (updated): "${val.stringValue}"');
        } else if (val.hasStringValue()) {
          emit('    $key: ${val.stringValue}');
        } else if (val.hasBoolValue()) {
          emit('    $key (bool): ${val.boolValue}');
        } else if (val.hasNumberValue()) {
          final dt = DateTime.fromMillisecondsSinceEpoch(
            val.numberValue.toInt() * 1000,
            isUtc: true,
          );
          emit('    $key (date): ${dt.toIso8601String().substring(0, 10)}');
        } else if (val.hasListValue()) {
          emit('    $key: ${_formatGenericStringList(val.listValue)}');
        }
      }
      if (content.hasBlockCreate()) {
        for (final block in content.blockCreate.blocks) {
          if (block.hasText()) {
            final style = block.text.style;
            final text = block.text.text;
            switch (style) {
              case Block_Content_Text_Style.Checkbox:
                final mark = block.text.checked ? '[x]' : '[ ]';
                emit('    [${block.id}] $mark [Checkbox] $text');
              case Block_Content_Text_Style.Numbered:
                emit('    [${block.id}] [Numbered] $text');
              case Block_Content_Text_Style.Toggle:
                emit('    [${block.id}] [Toggle] $text');
              case Block_Content_Text_Style.Quote:
                emit('    [${block.id}] [Quote] $text');
              case Block_Content_Text_Style.Callout:
                emit('    [${block.id}] [Callout] $text');
              default:
                emit('    [${block.id}] Text: "$text"');
            }
          }
          if (block.hasDataview()) {
            final dv = block.dataview;
            emit(
                '    [${block.id}] [Dataview] source: ${dv.source.join(', ')}, views: ${dv.views.length}');
          }
        }
      }
      if (content.hasBlockUpdate()) {
        for (final eventBytes in content.blockUpdate.events) {
          try {
            final eventMsg = Event_Message.fromBuffer(eventBytes);
            if (eventMsg.hasBlockSetText()) {
              emit('    Text (updated): "${eventMsg.blockSetText.text.value}"');
            }
          } catch (_) {
            continue;
          }
        }
      }
    }
  } catch (e) {
    emit('    (could not decode block changes)');
  }
}

const _hiddenGenericDetailKeys = <String>{
  'name',
  'id',
  'spaceId',
  'type',
  'tag',
  'internalFlags',
  'createdDate',
  'creator',
  'lastModifiedDate',
  'lastModifiedBy',
  'lastOpenedDate',
  'isFavorite',
  'isArchived',
  'restrictions',
  'syncDate',
  'syncStatus',
  'syncError',
  'coverId',
  'coverScale',
  'coverType',
  'coverX',
  'coverY',
  'snippet',
  'links',
  'backlinks',
  'mentions',
  'resolvedLayout',
};

String? _formatGenericDetailValue(Value val) {
  if (val.hasStringValue()) {
    return val.stringValue;
  }
  if (val.hasListValue()) {
    return _formatGenericStringList(val.listValue);
  }
  return null;
}

String _formatGenericStringList(ListValue list) {
  final values = list.values
      .where((value) => value.hasStringValue())
      .map((value) => value.stringValue)
      .toList(growable: false);
  if (values.isEmpty) {
    return '(empty)';
  }
  return values.join(', ');
}

Future<Uint8List> _decodeTreeChangeChangesData(
  TreeChange treeChange, {
  required Uint8List? treeKey,
}) async {
  var data = Uint8List.fromList(treeChange.changesData);
  if (treeChange.readKeyId.isNotEmpty) {
    if (treeKey == null) {
      throw StateError('missing tree key for encrypted changesData');
    }
    data = await aesGcmDecrypt(treeKey, data);
  }
  if (treeChange.dataType == '1/s') {
    data = _snappy.decompress(data);
  }
  return data;
}

/// Decode a protobuf varint from a byte list (handles multi-byte values like
/// SmartBlockType.STType=528 and STRelation=521 which exceed single-byte range).
int _decodeVarint(List<int> bytes) {
  int result = 0;
  int shift = 0;
  for (final b in bytes) {
    result |= (b & 0x7F) << shift;
    shift += 7;
    if (b < 0x80) break;
  }
  return result;
}

/// Extract SmartBlockType value from the root change's changePayload field.
/// Returns null if the root change cannot be parsed or has no changePayload.
int? _extractSmartBlockType(List<Change> changes) {
  try {
    final rawTreeChange = RawTreeChange.fromBuffer(changes.first.rawBytes);
    if (rawTreeChange.payload.isEmpty) return null;
    final rootChange = RootChange.fromBuffer(rawTreeChange.payload);
    if (rootChange.changePayload.isEmpty) return null;
    final bytes = rootChange.changePayload;
    // changePayload is a proto message where field 1 (tag 0x08) is the
    // SmartBlockType enum value encoded as a varint.
    if (bytes.isEmpty || bytes[0] != 0x08) return null;
    return _decodeVarint(bytes.sublist(1));
  } catch (_) {
    return null;
  }
}

/// Phase 38: format a status/tag relation value using the STRelationOption
/// index.
///
/// Returns the D-10 / D-11 / D-13 format strings:
///  - Status: `<OptionName> (<color>)` for a resolved single option ID, or
///    `<unknown:xxxxxxxx>` for an orphan/not-yet-synced ID.
///  - Tag: `<name1>, <name2>, <name3>` for a list_value of option IDs,
///    preserving the order in which they were stored, with orphan entries
///    rendered inline as `<unknown:xxxxxxxx>`.
///
/// Non-option-shaped values fall through to `val.toString()` as a
/// defensive last resort: callers should gate invocation by checking the
/// RelationFormat enum on the parent relation link before calling this
/// helper.
String _formatOptionRelationValue(
  Value val,
  Map<String, ResolvedOption> optIndex,
) {
  if (val.hasStringValue()) {
    // Status relation: single option ID.
    final id = val.stringValue;
    final opt = optIndex[id];
    if (opt == null || opt.isOrphaned) {
      return '<unknown:${id.length <= 8 ? id : id.substring(0, 8)}>';
    }
    final color = opt.color ?? 'default';
    return '${opt.name} ($color)';
  }
  if (val.hasListValue()) {
    // Tag relation: list of option IDs (order preserved).
    return val.listValue.values.map((v) {
      if (!v.hasStringValue()) return v.toString();
      final id = v.stringValue;
      final opt = optIndex[id];
      if (opt == null || opt.isOrphaned) {
        return '<unknown:${id.length <= 8 ? id : id.substring(0, 8)}>';
      }
      return opt.name!;
    }).join(', ');
  }
  return val.toString();
}

Future<String?> _formatFileRelationValue(
  Value val,
  ManytypeDatabase db, {
  required Uint8List? spaceKey,
  Map<String, List<Change>> cachedChangesByObject = const {},
  required bool assumeFileRelation,
}) async {
  if (val.hasStringValue()) {
    return _formatSingleFileRelationId(
      val.stringValue,
      db,
      spaceKey: spaceKey,
      cachedChangesByObject: cachedChangesByObject,
      assumeFileRelation: assumeFileRelation,
    );
  }
  if (!val.hasListValue()) {
    return assumeFileRelation ? _unknownFileLabel('') : null;
  }

  final rendered = <String>[];
  for (final item in val.listValue.values) {
    if (!item.hasStringValue()) {
      if (!assumeFileRelation) {
        return null;
      }
      rendered.add(_unknownFileLabel(''));
      continue;
    }
    final resolved = await _formatSingleFileRelationId(
      item.stringValue,
      db,
      spaceKey: spaceKey,
      cachedChangesByObject: cachedChangesByObject,
      assumeFileRelation: assumeFileRelation,
    );
    if (resolved == null) {
      if (!assumeFileRelation) {
        return null;
      }
      rendered.add(_unknownFileLabel(item.stringValue));
      continue;
    }
    rendered.add(resolved);
  }
  if (rendered.isEmpty) {
    return assumeFileRelation ? _unknownFileLabel('') : null;
  }
  return rendered.join(', ');
}

Future<String?> _formatSingleFileRelationId(
  String objectId,
  ManytypeDatabase db, {
  required Uint8List? spaceKey,
  Map<String, List<Change>> cachedChangesByObject = const {},
  required bool assumeFileRelation,
}) async {
  final trimmedId = objectId.trim();
  if (trimmedId.isEmpty) {
    return assumeFileRelation ? _unknownFileLabel(trimmedId) : null;
  }
  if (spaceKey == null) {
    return assumeFileRelation ? _unknownFileLabel(trimmedId) : null;
  }

  final changes = cachedChangesByObject[trimmedId] ??
      await db.getChangesForObject(trimmedId);
  if (changes.isEmpty) {
    return assumeFileRelation ? _unknownFileLabel(trimmedId) : null;
  }

  final smartBlockType = _extractSmartBlockType(changes);
  if (smartBlockType != null &&
      smartBlockType != SmartBlockType.FileObject.value) {
    return assumeFileRelation ? _unknownFileLabel(trimmedId) : null;
  }
  if (smartBlockType == null && !assumeFileRelation) {
    return null;
  }

  try {
    final treeKey = await deriveTreeKey(spaceKey, trimmedId);
    final details = await replayObjectDetails(
      rawTreeChanges:
          changes.map((change) => Uint8List.fromList(change.rawBytes)).toList(),
      treeKey: treeKey,
    );
    final name = _stringDetail(details, 'name');
    final mime = _stringDetail(details, 'mime');
    if (name.isNotEmpty) {
      return _hasSpecificMime(mime) ? '$name ($mime)' : name;
    }
    if (_hasSpecificMime(mime)) {
      return mime;
    }
  } catch (_) {
    return assumeFileRelation ? _unknownFileLabel(trimmedId) : null;
  }

  return _unknownFileLabel(trimmedId);
}

String _stringDetail(Map<String, Value> details, String key) {
  final value = details[key];
  if (value == null || !value.hasStringValue()) {
    return '';
  }
  return value.stringValue.trim();
}

bool _hasSpecificMime(String mime) =>
    mime.isNotEmpty && mime != 'application/octet-stream';

String _unknownFileLabel(String objectId) {
  if (objectId.isEmpty) {
    return '<unknown-file>';
  }
  final shortId = objectId.length <= 8 ? objectId : objectId.substring(0, 8);
  return '<unknown-file:$shortId>';
}

/// Map a RelationFormat enum value to a human-readable name.
String _formatName(double numberValue) {
  final intVal = numberValue.toInt();
  const names = {
    0: 'longtext',
    1: 'shorttext',
    2: 'number',
    3: 'status',
    4: 'date',
    5: 'file',
    6: 'checkbox',
    7: 'url',
    8: 'email',
    9: 'phone',
    10: 'emoji',
    11: 'tag',
    100: 'object',
    101: 'relations',
  };
  return names[intVal] ?? 'unknown($intVal)';
}
