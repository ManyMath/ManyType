import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/manytype_protocol.dart';

import '../config.dart';
import '../identity.dart';
import '../store/database.dart';

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
  final objects = await db.getObjectsBySpace(spaceId);
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
    final textPreview = _extractTextPreview(changes);

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

  print('Object: $objectId');
  print('Changes: ${changes.length}');
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
            _printBlockChanges(treeChange.changesData);
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
String _extractTextPreview(List<Change> changes) {
  for (final change in changes.reversed) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(change.rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;

      final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      if (treeChange.changesData.isNotEmpty) {
        final text = _extractText(treeChange.changesData);
        if (text.isNotEmpty) return text;
      }
    } catch (_) {
      continue;
    }
  }
  return '';
}

/// Extract text from Change proto changesData bytes.
///
/// Uses [changes_proto.Change] to avoid name conflict with drift's Change class.
String _extractText(List<int> changesData) {
  try {
    final change = changes_proto.Change.fromBuffer(changesData);
    for (final content in change.content) {
      if (content.hasBlockCreate()) {
        for (final block in content.blockCreate.blocks) {
          if (block.hasText()) {
            return block.text.text;
          }
        }
      }
    }
  } catch (_) {}
  return '';
}

/// Print block content from changesData bytes.
void _printBlockChanges(List<int> changesData) {
  try {
    final change = changes_proto.Change.fromBuffer(changesData);
    for (final content in change.content) {
      if (content.hasBlockCreate()) {
        for (final block in content.blockCreate.blocks) {
          if (block.hasText()) {
            print('    Text: "${block.text.text}"');
          }
        }
      }
    }
  } catch (e) {
    print('    (could not decode block changes)');
  }
}
