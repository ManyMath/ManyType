import 'dart:io';
import 'dart:typed_data';

import 'package:libcompress/libcompress.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

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
  try {
    final config = await CliConfig.load();
    final identity = await Identity.fromMnemonic(config.mnemonic);
    final accountKeyPair = await ed25519KeyPairFromSeed(identity.accountSeed);
    final accountPrivRaw = Uint8List(64)
      ..setRange(0, 32, identity.accountSeed)
      ..setRange(32, 64, accountKeyPair.publicKey);
    final spaceKey = await deriveSpaceKey(accountPrivRaw);
    treeKey = await deriveTreeKey(spaceKey, objectId);
  } catch (_) {
    treeKey = null;
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
  await _printSnapshotMetadata(changes, treeKey: treeKey, smartBlockType: smartBlockType);

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
Future<void> _printSnapshotMetadata(
  List<Change> changes, {
  required Uint8List? treeKey,
  int? smartBlockType,
}) async {
  for (final change in changes) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(change.rawBytes);
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

      final snapData = changeProto.snapshot.data;

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

      // Text/checkbox/header blocks in the snapshot — prefixes each with
      // the stable block id so users can pass it to `edit --block-id`.
      _printSnapshotBlocks(snapData);

      // Found snapshot -- stop looking.
      return;
    } catch (_) {
      continue;
    }
  }
}

/// Walk the snapshot's block list and render user-visible text blocks with
/// their stable block ID as an `[id]` prefix. Structural / container blocks
/// (smartblock root, header layout, title, featuredRelations, dataview) are
/// skipped so the output stays focused on blocks the user can mutate via
/// `edit --block-id <id>`.
void _printSnapshotBlocks(SmartBlockSnapshotBase snapData) {
  // Structural blocks with well-known fixed ids (see
  // manytype_core/lib/src/crdt/block.dart createMinimalPageSnapshotBase).
  const structuralIds = <String>{
    'header',
    'title',
    'featuredRelations',
  };

  for (final block in snapData.blocks) {
    if (structuralIds.contains(block.id)) continue;
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
