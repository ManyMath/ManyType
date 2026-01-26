import 'dart:io';
import 'dart:typed_data';

import 'package:libcompress/libcompress.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    show Value;

import '../config.dart';
import '../identity.dart';
import '../store/database.dart';

final _snappy = SnappyCodec();

/// Read and display objects from local store.
///
/// Without arguments: lists all objects with text previews.
/// With object ID: shows that object's full content.
Future<void> readCommand(
  ManytypeDatabase db,
  CliConfig config, {
  String? objectId,
}) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = identity.spaceId;

  if (objectId != null) {
    await _showObject(db, objectId);
  } else {
    await _listObjects(db, spaceId);
  }
}

/// List all objects in the space with text previews.
Future<void> _listObjects(ManytypeDatabase db, String spaceId) async {
  final objects = await db.getNonDeletedObjectsBySpace(spaceId);
  if (objects.isEmpty) {
    print('No objects found. Create one with: manytype create "your text"');
    return;
  }

  print('Objects in space ($spaceId):');
  print('');
  for (final obj in objects) {
    final changes = await db.getChangesForObject(obj.id);
    final heads = await db.getObjectHeads(obj.id);
    final attachments = await db.getAttachmentRefsByObject(obj.id);
    final textPreview = extractTextPreview(changes);

    print('  ${obj.id}');
    print('    Created: ${obj.createdAt}');
    print('    Changes: ${changes.length}');
    print('    Heads: ${heads.join(", ")}');
    if (textPreview.isNotEmpty) {
      print('    Text: $textPreview');
    }
    _printAttachmentRefs(attachments, indent: '    ');
    print('');
  }
}

/// Show detailed content for a specific object.
Future<void> _showObject(ManytypeDatabase db, String objectId) async {
  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    print('Object not found: $objectId');
    return;
  }

  if (await db.isObjectDeleted(objectId)) {
    print('Object $objectId has been deleted');
    exit(1);
  }

  // Official Anytype trees encrypt `TreeChange.changesData` using a tree key
  // derived from the space read key and object ID, and may additionally snappy
  // compress the plaintext when `dataType == "1/s"`.
  Uint8List? treeKey;
  Uint8List? spaceKeyForIndex;
  String? spaceIdForIndex;
  try {
    final config = await CliConfig.load();
    final identity = await Identity.fromMnemonic(config.mnemonic);
    final accountKeyPair = await ed25519KeyPairFromSeed(identity.accountSeed);
    final accountPrivRaw = Uint8List(64)
      ..setRange(0, 32, identity.accountSeed)
      ..setRange(32, 64, accountKeyPair.publicKey);
    final spaceKey = await deriveSpaceKey(accountPrivRaw);
    treeKey = await deriveTreeKey(spaceKey, objectId);
    spaceKeyForIndex = spaceKey;
    spaceIdForIndex = identity.spaceId;
  } catch (_) {
    treeKey = null;
  }

  // Phase 38: Build the STRelationOption index ONCE per read invocation.
  // Scans every non-deleted object in the space, filters roots whose
  // smart_block_type == 529 (STRelationOption), and returns a map from
  // option ID -> ResolvedOption (name + color + relationKey or orphaned
  // sentinel). Used by _formatOptionRelationValue below to resolve status
  // and tag relation values on this object's snapshot details.
  var optIndex = const <String, ResolvedOption>{};
  if (spaceKeyForIndex != null && spaceIdForIndex != null) {
    try {
      final spaceObjects =
          await db.getNonDeletedObjectsBySpace(spaceIdForIndex);
      final optionInputs = <OptionIndexInput>[];
      for (final obj in spaceObjects) {
        final rawRows = await db.getChangesForObject(obj.id);
        final objTreeKey = await deriveTreeKey(spaceKeyForIndex, obj.id);
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

  print('Object: $objectId');
  print('Changes: ${changes.length}');

  // Extract and display SmartBlockType from root change.
  final smartBlockType = _extractSmartBlockType(changes);
  if (smartBlockType != null) {
    switch (smartBlockType) {
      case 528: // SmartBlockType.STType
        print('  Kind: [Type]');
      case 521: // SmartBlockType.STRelation
        print('  Kind: [Relation]');
      case 16: // SmartBlockType.Page
        print('  Kind: [Page]');
      default:
        print('  Kind: [$smartBlockType]');
    }
  }

  // Extract snapshot metadata (objectTypes, relationLinks, details, Dataview blocks).
  await _printSnapshotMetadata(
    changes,
    treeKey: treeKey,
    smartBlockType: smartBlockType,
    optIndex: optIndex,
  );

  _printAttachmentRefs(await db.getAttachmentRefsByObject(objectId));
  print('');

  for (final change in changes) {
    try {
      // Database rawBytes = serialized RawTreeChange (payload + signature).
      final rawTreeChange = RawTreeChange.fromBuffer(change.rawBytes);
      print('  Change ${change.id}:');

      if (rawTreeChange.payload.isNotEmpty) {
        // Try as TreeChange first (non-root changes have changesData).
        try {
          final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
          if (treeChange.changesData.isNotEmpty) {
            await _printBlockChanges(
              treeChange,
              treeKey: treeKey,
            );
          } else {
            print('    (no block data)');
          }
        } catch (_) {
          // Root changes use RootChange proto (no changesData).
          print('    (root change)');
        }
      }
    } catch (e) {
      print('  Change ${change.id}: (binary, ${change.rawBytes.length} bytes)');
    }
  }
}

void _printAttachmentRefs(
  List<StoredAttachmentRef> attachments, {
  String indent = '',
}) {
  if (attachments.isEmpty) {
    return;
  }

  print('${indent}Attachments:');
  for (final attachment in attachments) {
    final cidLabel =
        attachment.cid.isEmpty ? 'metadata only' : 'cid=${attachment.cid}';
    print('${indent}  ${attachment.fileId} ($cidLabel)');
  }
}

/// Extract text content preview from the most recent non-root change.
String extractTextPreview(List<Change> changes) {
  for (final change in changes.reversed) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(change.rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;

      final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      if (treeChange.changesData.isNotEmpty) {
        final decoded = _decodeChangesDataForPreview(treeChange);
        final text = _extractTextFromDecodedChangeBytes(decoded);
        if (text.isNotEmpty) return text;
      }
    } catch (_) {
      continue;
    }
  }
  return '';
}

Uint8List _decodeChangesDataForPreview(TreeChange treeChange) {
  if (treeChange.readKeyId.isNotEmpty) {
    return Uint8List(0);
  }
  var data = Uint8List.fromList(treeChange.changesData);
  if (treeChange.dataType == '1/s') {
    data = _snappy.decompress(data);
  }
  return data;
}

/// Extract text from Change proto bytes.
String _extractTextFromDecodedChangeBytes(Uint8List decoded) {
  try {
    final change = changes_proto.Change.fromBuffer(decoded);
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

/// Extract and print metadata from the first snapshot change in the tree.
///
/// After finding the snapshot, iterates through all subsequent non-snapshot
/// changes and applies BlockCreate / BlockUpdate(blockSetText) deltas so
/// `_printSnapshotBlocks` can render the *current* replayed state (Phase 37:
/// BlockUpdate mutations must be visible on re-read).
Future<void> _printSnapshotMetadata(
  List<Change> changes, {
  required Uint8List? treeKey,
  int? smartBlockType,
  Map<String, ResolvedOption> optIndex = const <String, ResolvedOption>{},
}) async {
  // Locate the first snapshot change.
  int? snapshotIndex;
  changes_proto.Change? snapshotChangeProto;
  for (var i = 0; i < changes.length; i++) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(changes[i].rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;

      TreeChange treeChange;
      try {
        treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      } catch (_) {
        continue; // Root change -- skip.
      }
      if (treeChange.changesData.isEmpty) continue;

      final decoded = await _decodeTreeChangeChangesData(
        treeChange,
        treeKey: treeKey,
      );
      final changeProto = changes_proto.Change.fromBuffer(decoded);
      if (!changeProto.hasSnapshot()) continue;
      snapshotIndex = i;
      snapshotChangeProto = changeProto;
      break;
    } catch (_) {
      continue;
    }
  }
  if (snapshotIndex == null || snapshotChangeProto == null) return;

  final snapData = snapshotChangeProto.snapshot.data;

  // objectTypes
  if (snapData.objectTypes.isNotEmpty) {
    print('  Type: ${snapData.objectTypes.join(', ')}');
  }

  // relationLinks
  if (snapData.relationLinks.isNotEmpty) {
    print('  Relations: ${snapData.relationLinks.map((l) => l.key).join(', ')}');
  }

  // Type/Relation-specific details from snapshot.
  if (snapData.hasDetails()) {
    final fields = snapData.details.fields;
    if (fields.containsKey('name')) {
      print('  Name: ${fields['name']!.stringValue}');
    }
    if (smartBlockType == 521 && fields.containsKey('relationFormat')) {
      print('  Format: ${_formatName(fields['relationFormat']!.numberValue)}');
    }
  }

  // Dataview blocks in snapshot.
  for (final block in snapData.blocks) {
    if (block.hasDataview()) {
      final dv = block.dataview;
      final sources = dv.source.join(', ');
      final viewCount = dv.views.length;
      print('  [Dataview] source: $sources, views: $viewCount');
    }
  }

  // Build mutable block state from snapshot, then replay subsequent
  // non-snapshot changes' BlockCreate and BlockUpdate(blockSetText) deltas.
  // Also replay DetailsSet into a merged details map so Phase 38 status/tag
  // option rendering reflects post-snapshot edit values.
  final blockState = <String, Block>{};
  final blockOrder = <String>[];
  for (final block in snapData.blocks) {
    blockState[block.id] = block.deepCopy();
    blockOrder.add(block.id);
  }
  // Start merged details from the snapshot's details, replay DetailsSet
  // deltas on top.
  final mergedDetails = <String, Value>{};
  if (snapData.hasDetails()) {
    for (final entry in snapData.details.fields.entries) {
      mergedDetails[entry.key] = entry.value;
    }
  }

  for (var i = snapshotIndex + 1; i < changes.length; i++) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(changes[i].rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;
      TreeChange treeChange;
      try {
        treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      } catch (_) {
        continue;
      }
      if (treeChange.changesData.isEmpty) continue;

      final decoded = await _decodeTreeChangeChangesData(
        treeChange,
        treeKey: treeKey,
      );
      final changeProto = changes_proto.Change.fromBuffer(decoded);
      // Skip downstream snapshots: we only show the first snapshot's
      // blocks plus deltas to keep CLI read deterministic.
      if (changeProto.hasSnapshot()) continue;

      for (final content in changeProto.content) {
        if (content.hasDetailsSet()) {
          final key = content.detailsSet.key;
          final val = content.detailsSet.value;
          mergedDetails[key] = val;
        }
        if (content.hasBlockCreate()) {
          for (final newBlock in content.blockCreate.blocks) {
            if (!blockState.containsKey(newBlock.id)) {
              blockOrder.add(newBlock.id);
            }
            blockState[newBlock.id] = newBlock.deepCopy();
          }
        }
        if (content.hasBlockUpdate()) {
          for (final eventBytes in content.blockUpdate.events) {
            try {
              final eventMsg = Event_Message.fromBuffer(eventBytes);
              if (eventMsg.hasBlockSetText()) {
                final set = eventMsg.blockSetText;
                final target = blockState[set.id];
                if (target == null) continue;
                if (!target.hasText()) {
                  target.text = Block_Content_Text();
                }
                if (set.hasText()) target.text.text = set.text.value;
                if (set.hasStyle()) target.text.style = set.style.value;
                if (set.hasChecked()) {
                  target.text.checked = set.checked.value;
                }
              }
            } catch (_) {
              continue;
            }
          }
        }
      }
    } catch (_) {
      continue;
    }
  }

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
  for (final link in snapData.relationLinks) {
    if (link.format != RelationFormat.status &&
        link.format != RelationFormat.tag) {
      continue;
    }
    final val = mergedDetails[link.key];
    if (val == null) continue;
    final rendered = _formatOptionRelationValue(val, optIndex);
    print('  [${link.key}] $rendered');
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
      print('  [${entry.key}] $rendered');
      renderedRelationKeys.add(entry.key);
    }
  }

  _printSnapshotBlocks(blockOrder, blockState);
}

/// Walk the replayed block map in insertion order and render user-visible
/// text blocks with their stable block ID as an `[id]` prefix. Structural /
/// container blocks (header, title, featuredRelations) are skipped so the
/// output stays focused on blocks the user can mutate via
/// `edit --block-id <id>`.
void _printSnapshotBlocks(
  List<String> blockOrder,
  Map<String, Block> blockState,
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
        print('    [${block.id}] $mark [Checkbox] $text');
        break;
      case Block_Content_Text_Style.Header1:
        print('    [${block.id}] [Header1] $text');
        break;
      case Block_Content_Text_Style.Header2:
        print('    [${block.id}] [Header2] $text');
        break;
      case Block_Content_Text_Style.Header3:
        print('    [${block.id}] [Header3] $text');
        break;
      case Block_Content_Text_Style.Quote:
        print('    [${block.id}] [Quote] $text');
        break;
      case Block_Content_Text_Style.Numbered:
        print('    [${block.id}] [Numbered] $text');
        break;
      case Block_Content_Text_Style.Toggle:
        print('    [${block.id}] [Toggle] $text');
        break;
      case Block_Content_Text_Style.Callout:
        print('    [${block.id}] [Callout] $text');
        break;
      case Block_Content_Text_Style.Paragraph:
      default:
        print('    [${block.id}] [Paragraph] $text');
        break;
    }
  }
}

/// Print block content from changesData bytes.
Future<void> _printBlockChanges(
  TreeChange treeChange, {
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
          print('    Text (updated): "${val.stringValue}"');
        } else if (val.hasBoolValue()) {
          print('    $key (bool): ${val.boolValue}');
        } else if (val.hasNumberValue()) {
          final dt = DateTime.fromMillisecondsSinceEpoch(
            val.numberValue.toInt() * 1000,
            isUtc: true,
          );
          print('    $key (date): ${dt.toIso8601String().substring(0, 10)}');
        } else if (val.hasStringValue()) {
          print('    $key (object): ${val.stringValue}');
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
                print('    [${block.id}] $mark [Checkbox] $text');
              case Block_Content_Text_Style.Numbered:
                print('    [${block.id}] [Numbered] $text');
              case Block_Content_Text_Style.Toggle:
                print('    [${block.id}] [Toggle] $text');
              case Block_Content_Text_Style.Quote:
                print('    [${block.id}] [Quote] $text');
              case Block_Content_Text_Style.Callout:
                print('    [${block.id}] [Callout] $text');
              default:
                print('    [${block.id}] Text: "$text"');
            }
          }
          if (block.hasDataview()) {
            final dv = block.dataview;
            print('    [${block.id}] [Dataview] source: ${dv.source.join(', ')}, views: ${dv.views.length}');
          }
        }
      }
      if (content.hasBlockUpdate()) {
        for (final eventBytes in content.blockUpdate.events) {
          try {
            final eventMsg = Event_Message.fromBuffer(eventBytes);
            if (eventMsg.hasBlockSetText()) {
              print(
                  '    Text (updated): "${eventMsg.blockSetText.text.value}"');
            }
          } catch (_) {
            continue;
          }
        }
      }
    }
  } catch (e) {
    print('    (could not decode block changes)');
  }
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
