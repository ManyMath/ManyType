import 'dart:typed_data';

import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/models.dart';

/// Create a text paragraph block.
///
/// Uses [Block_Content_Text_Style.Paragraph] style per Anytype proto format.
Block createTextBlock(String id, String text) {
  return Block(
    id: id,
    text: Block_Content_Text(
      text: text,
      style: Block_Content_Text_Style.Paragraph,
    ),
  );
}

/// Create a header block (level 1, 2, or 3).
///
/// Maps level to [Block_Content_Text_Style.Header1], Header2, or Header3.
/// Defaults to Header1 for invalid levels.
Block createHeaderBlock(String id, String text, int level) {
  final style = switch (level) {
    1 => Block_Content_Text_Style.Header1,
    2 => Block_Content_Text_Style.Header2,
    3 => Block_Content_Text_Style.Header3,
    _ => Block_Content_Text_Style.Header1,
  };
  return Block(
    id: id,
    text: Block_Content_Text(
      text: text,
      style: style,
    ),
  );
}

/// Create a list block (bullet, numbered, or checkbox).
///
/// - Default (no flags): bullet list ([Block_Content_Text_Style.Marked])
/// - [numbered]: ordered list ([Block_Content_Text_Style.Numbered])
/// - [checkbox]: checkbox/todo list ([Block_Content_Text_Style.Checkbox])
///
/// If both [checkbox] and [numbered] are true, checkbox takes precedence.
Block createListBlock(String id, String text,
    {bool numbered = false, bool checkbox = false}) {
  final style = checkbox
      ? Block_Content_Text_Style.Checkbox
      : numbered
          ? Block_Content_Text_Style.Numbered
          : Block_Content_Text_Style.Marked;
  return Block(
    id: id,
    text: Block_Content_Text(
      text: text,
      style: style,
    ),
  );
}

/// Create a minimal SmartBlock snapshot structure.
///
/// Per Anytype's block model, a snapshot contains:
/// 1. A root smartblock block with a layout child
/// 2. A layout block (Column style) with content block children
/// 3. The content blocks themselves
///
/// This is the minimum viable structure for a document snapshot.
SmartBlockSnapshotBase createMinimalSnapshot(
    String rootId, List<Block> contentBlocks) {
  final layoutId = 'layout-$rootId';

  final rootBlock = Block(
    id: rootId,
    smartblock: Block_Content_Smartblock(),
    childrenIds: [layoutId],
  );

  final layoutBlock = Block(
    id: layoutId,
    layout: Block_Content_Layout(
      style: Block_Content_Layout_Style.Column,
    ),
    childrenIds: contentBlocks.map((b) => b.id),
  );

  return SmartBlockSnapshotBase()
    ..blocks.addAll([rootBlock, layoutBlock, ...contentBlocks]);
}

/// Marshal a list of [Change_Content] operations into bytes for
/// [TreeChange.changesData].
///
/// Creates a [Change] proto with the given content operations and serializes
/// it to protobuf bytes.
Uint8List marshalChangeContent(List<Change_Content> operations) {
  final change = Change(content: operations);
  return Uint8List.fromList(change.writeToBuffer());
}
