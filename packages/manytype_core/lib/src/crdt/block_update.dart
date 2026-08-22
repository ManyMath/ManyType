import 'dart:typed_data';

import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/models.dart';

/// Build a serialized Event_Message that sets an existing checkbox block's
/// checked state. Returned bytes are ready to append to
/// Change_BlockUpdate.events. Absolute (not a flip) per D-07.
Uint8List buildBlockSetCheckedEvent(String blockId, bool checked) {
  final event = Event_Message()
    ..blockSetText = (Event_Block_Set_Text()
      ..id = blockId
      ..checked = (Event_Block_Set_Text_Checked()..value = checked));
  return Uint8List.fromList(event.writeToBuffer());
}

/// Build a serialized Event_Message that rewrites an existing block's text.
/// Marks are NOT preserved (D-09: MVP limitation).
Uint8List buildBlockSetTextEvent(String blockId, String text) {
  final event = Event_Message()
    ..blockSetText = (Event_Block_Set_Text()
      ..id = blockId
      ..text = (Event_Block_Set_Text_TextValue()..value = text));
  return Uint8List.fromList(event.writeToBuffer());
}

/// Build a serialized Event_Message that changes an existing text block's style.
/// Block-level style only; range-based marks are deferred (D-08).
Uint8List buildBlockSetStyleEvent(
  String blockId,
  Block_Content_Text_Style style,
) {
  final event = Event_Message()
    ..blockSetText = (Event_Block_Set_Text()
      ..id = blockId
      ..style = (Event_Block_Set_Text_Style()..value = style));
  return Uint8List.fromList(event.writeToBuffer());
}

/// Accepted symbolic style names for the CLI `--set-style` flag (D-06).
///
/// curated subset: Title (7), Code (6), Description (12),
/// Marked (9), ToggleHeader1-3 (14-16), Header4 (4) are excluded.
const List<String> acceptedStyleNames = <String>[
  'paragraph',
  'header1',
  'header2',
  'header3',
  'checkbox',
  'numbered',
  'toggle',
  'quote',
  'callout',
];

/// Resolve a symbolic style name (case-insensitive) to its
/// [Block_Content_Text_Style] enum value, or null if not in the accepted set.
Block_Content_Text_Style? parseStyleName(String name) {
  switch (name.toLowerCase()) {
    case 'paragraph':
      return Block_Content_Text_Style.Paragraph;
    case 'header1':
      return Block_Content_Text_Style.Header1;
    case 'header2':
      return Block_Content_Text_Style.Header2;
    case 'header3':
      return Block_Content_Text_Style.Header3;
    case 'checkbox':
      return Block_Content_Text_Style.Checkbox;
    case 'numbered':
      return Block_Content_Text_Style.Numbered;
    case 'toggle':
      return Block_Content_Text_Style.Toggle;
    case 'quote':
      return Block_Content_Text_Style.Quote;
    case 'callout':
      return Block_Content_Text_Style.Callout;
    default:
      return null;
  }
}
