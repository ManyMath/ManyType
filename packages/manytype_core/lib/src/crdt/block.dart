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

/// Create a quote block.
///
/// Uses [Block_Content_Text_Style.Quote] style per Anytype proto format.
Block createQuoteBlock(String id, String text) {
  return Block(
    id: id,
    text: Block_Content_Text(
      text: text,
      style: Block_Content_Text_Style.Quote,
    ),
  );
}

/// Create a toggle block.
///
/// Uses [Block_Content_Text_Style.Toggle] style per Anytype proto format.
Block createToggleBlock(String id, String text) {
  return Block(
    id: id,
    text: Block_Content_Text(
      text: text,
      style: Block_Content_Text_Style.Toggle,
    ),
  );
}

/// Create a callout block.
///
/// Uses [Block_Content_Text_Style.Callout] style per Anytype proto format.
Block createCalloutBlock(String id, String text) {
  return Block(
    id: id,
    text: Block_Content_Text(
      text: text,
      style: Block_Content_Text_Style.Callout,
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

/// Create a minimal snapshot base compatible with official Anytype "page" trees.
///
/// The official client bootstraps pages with a 4-block skeleton:
/// - smartblock root (id = object id) -> child "header"
/// - header layout (style Header) -> children ["title", "featuredRelations"]
/// - title text block (id "title", style Title)
/// - featured relations block (id "featuredRelations")
SmartBlockSnapshotBase createMinimalPageSnapshotBase({
  required String objectId,
  String title = '',
}) {
  final rootBlock = Block(
    id: objectId,
    smartblock: Block_Content_Smartblock(),
    childrenIds: const ['header'],
  );

  final headerBlock = Block(
    id: 'header',
    layout: Block_Content_Layout(
      style: Block_Content_Layout_Style.Header,
    ),
    childrenIds: const ['title', 'featuredRelations'],
  );

  final titleBlock = Block(
    id: 'title',
    text: Block_Content_Text(
      text: title,
      style: Block_Content_Text_Style.Title,
    ),
  );

  final featuredRelationsBlock = Block(
    id: 'featuredRelations',
    featuredRelations: Block_Content_FeaturedRelations(),
  );

  return SmartBlockSnapshotBase()
    ..blocks.addAll([
      rootBlock,
      headerBlock,
      titleBlock,
      featuredRelationsBlock,
    ]);
}

/// Create a Dataview block for set/collection objects.
///
/// Sets in Anytype are pages with a Dataview block that references one or more
/// [source] type keys (e.g. 'ot-page') and provides a default table view.
Block createDataviewBlock(String id, List<String> source) {
  return Block(
    id: id,
    dataview: Block_Content_Dataview(
      source: source,
      views: [
        Block_Content_Dataview_View(
          id: 'view-default',
          type: Block_Content_Dataview_View_Type.Table,
          name: 'All',
        ),
      ],
    ),
  );
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
