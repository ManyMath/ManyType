import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/events.dart';
import 'package:manytype_protocol/models.dart';
import 'package:test/test.dart';

void main() {
  group('buildBlockSetCheckedEvent', () {
    test('round-trips via Event_Message.fromBuffer with checked=true', () {
      final bytes = buildBlockSetCheckedEvent('cb-abc', true);
      final event = Event_Message.fromBuffer(bytes);
      expect(event.whichValue(), equals(Event_Message_Value.blockSetText));
      expect(event.blockSetText.id, equals('cb-abc'));
      expect(event.blockSetText.hasChecked(), isTrue);
      expect(event.blockSetText.checked.value, isTrue);
      expect(event.blockSetText.hasText(), isFalse);
      expect(event.blockSetText.hasStyle(), isFalse);
    });

    test('round-trips with checked=false', () {
      final bytes = buildBlockSetCheckedEvent('cb-def', false);
      final event = Event_Message.fromBuffer(bytes);
      expect(event.blockSetText.id, equals('cb-def'));
      expect(event.blockSetText.hasChecked(), isTrue);
      expect(event.blockSetText.checked.value, isFalse);
    });
  });

  group('buildBlockSetTextEvent', () {
    test('round-trips new text content without style or checked', () {
      final bytes = buildBlockSetTextEvent('para-1', 'hello world');
      final event = Event_Message.fromBuffer(bytes);
      expect(event.whichValue(), equals(Event_Message_Value.blockSetText));
      expect(event.blockSetText.id, equals('para-1'));
      expect(event.blockSetText.hasText(), isTrue);
      expect(event.blockSetText.text.value, equals('hello world'));
      expect(event.blockSetText.hasChecked(), isFalse);
      expect(event.blockSetText.hasStyle(), isFalse);
    });
  });

  group('buildBlockSetStyleEvent', () {
    test('round-trips Header2 without text or checked', () {
      final bytes = buildBlockSetStyleEvent(
        'para-1',
        Block_Content_Text_Style.Header2,
      );
      final event = Event_Message.fromBuffer(bytes);
      expect(event.whichValue(), equals(Event_Message_Value.blockSetText));
      expect(event.blockSetText.id, equals('para-1'));
      expect(event.blockSetText.hasStyle(), isTrue);
      expect(
        event.blockSetText.style.value,
        equals(Block_Content_Text_Style.Header2),
      );
      expect(event.blockSetText.hasText(), isFalse);
      expect(event.blockSetText.hasChecked(), isFalse);
    });
  });

  group('parseStyleName', () {
    test('maps accepted names to enum values', () {
      expect(
        parseStyleName('paragraph'),
        equals(Block_Content_Text_Style.Paragraph),
      );
      expect(
        parseStyleName('header1'),
        equals(Block_Content_Text_Style.Header1),
      );
      expect(
        parseStyleName('header2'),
        equals(Block_Content_Text_Style.Header2),
      );
      expect(
        parseStyleName('header3'),
        equals(Block_Content_Text_Style.Header3),
      );
      expect(
        parseStyleName('quote'),
        equals(Block_Content_Text_Style.Quote),
      );
      expect(
        parseStyleName('checkbox'),
        equals(Block_Content_Text_Style.Checkbox),
      );
      expect(
        parseStyleName('numbered'),
        equals(Block_Content_Text_Style.Numbered),
      );
      expect(
        parseStyleName('toggle'),
        equals(Block_Content_Text_Style.Toggle),
      );
      expect(
        parseStyleName('callout'),
        equals(Block_Content_Text_Style.Callout),
      );
    });

    test('is case-insensitive', () {
      expect(
        parseStyleName('HeAdEr2'),
        equals(Block_Content_Text_Style.Header2),
      );
      expect(
        parseStyleName('PARAGRAPH'),
        equals(Block_Content_Text_Style.Paragraph),
      );
    });

    test('returns null for unknown or excluded names', () {
      expect(parseStyleName('header4'), isNull);
      expect(parseStyleName('title'), isNull);
      expect(parseStyleName('code'), isNull);
      expect(parseStyleName(''), isNull);
      expect(parseStyleName('bogus'), isNull);
    });
  });

  group('acceptedStyleNames', () {
    test('matches the curated 9-name ordered list (D-06)', () {
      expect(
        acceptedStyleNames,
        equals(<String>[
          'paragraph',
          'header1',
          'header2',
          'header3',
          'checkbox',
          'numbered',
          'toggle',
          'quote',
          'callout',
        ]),
      );
    });
  });
}
