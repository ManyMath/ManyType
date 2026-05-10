import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/models.dart';
import 'package:test/test.dart';

void main() {
  group('createTextBlock', () {
    test('produces Block with text content and Paragraph style', () {
      final block = createTextBlock('text-1', 'Hello world');
      expect(block.id, equals('text-1'));
      expect(block.text.text, equals('Hello world'));
      expect(block.text.style, equals(Block_Content_Text_Style.Paragraph));
    });
  });

  group('createHeaderBlock', () {
    test('level 1 produces Block with Header1 style', () {
      final block = createHeaderBlock('h1', 'Title', 1);
      expect(block.id, equals('h1'));
      expect(block.text.text, equals('Title'));
      expect(block.text.style, equals(Block_Content_Text_Style.Header1));
    });

    test('level 2 produces Block with Header2 style', () {
      final block = createHeaderBlock('h2', 'Subtitle', 2);
      expect(block.text.style, equals(Block_Content_Text_Style.Header2));
    });

    test('level 3 produces Block with Header3 style', () {
      final block = createHeaderBlock('h3', 'Section', 3);
      expect(block.text.style, equals(Block_Content_Text_Style.Header3));
    });
  });

  group('createListBlock', () {
    test('bullet produces Block with Marked style', () {
      final block = createListBlock('li-1', 'Item one');
      expect(block.id, equals('li-1'));
      expect(block.text.text, equals('Item one'));
      expect(block.text.style, equals(Block_Content_Text_Style.Marked));
    });

    test('numbered produces Block with Numbered style', () {
      final block = createListBlock('li-2', 'Step one', numbered: true);
      expect(block.text.style, equals(Block_Content_Text_Style.Numbered));
    });

    test('checkbox produces Block with Checkbox style', () {
      final block = createListBlock('li-3', 'Todo', checkbox: true);
      expect(block.text.style, equals(Block_Content_Text_Style.Checkbox));
    });
  });

  group('createMinimalSnapshot', () {
    test('produces SmartBlockSnapshotBase with root + layout + content blocks',
        () {
      final contentBlocks = [
        createTextBlock('p1', 'First paragraph'),
        createTextBlock('p2', 'Second paragraph'),
      ];
      final snapshot = createMinimalSnapshot('root-1', contentBlocks);

      expect(snapshot.blocks, hasLength(4)); // root + layout + 2 content

      // Root block: smartblock type with layout child
      final rootBlock = snapshot.blocks[0];
      expect(rootBlock.id, equals('root-1'));
      expect(rootBlock.hasSmartblock(), isTrue);
      expect(rootBlock.childrenIds, equals(['layout-root-1']));

      // Layout block: Column style with content block children
      final layoutBlock = snapshot.blocks[1];
      expect(layoutBlock.id, equals('layout-root-1'));
      expect(layoutBlock.hasLayout(), isTrue);
      expect(
          layoutBlock.layout.style, equals(Block_Content_Layout_Style.Column));
      expect(layoutBlock.childrenIds, equals(['p1', 'p2']));

      // Content blocks preserved
      expect(snapshot.blocks[2].id, equals('p1'));
      expect(snapshot.blocks[3].id, equals('p2'));
    });
  });

  group('marshalChangeContent', () {
    test('with BlockCreate operations produces valid bytes', () {
      final block = createTextBlock('p1', 'Hello');
      final content = Change_Content(
        blockCreate: Change_BlockCreate(
          targetId: 'layout-root',
          position: Block_Position.Inner,
          blocks: [block],
        ),
      );

      final bytes = marshalChangeContent([content]);
      expect(bytes, isNotEmpty);

      // Round-trip: deserialize and verify
      final change = Change.fromBuffer(bytes);
      expect(change.content, hasLength(1));
      expect(change.content.first.hasBlockCreate(), isTrue);
      expect(change.content.first.blockCreate.blocks.first.id, equals('p1'));
      expect(change.content.first.blockCreate.blocks.first.text.text,
          equals('Hello'));
    });
  });
}
