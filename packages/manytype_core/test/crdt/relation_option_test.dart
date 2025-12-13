import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/models.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';
import 'package:test/test.dart';

void main() {
  group('optionColorPalette', () {
    test('has exactly 11 values from anytype-kotlin ThemeColor enum', () {
      expect(optionColorPalette.length, 11);
      expect(
        optionColorPalette,
        containsAll(<String>[
          'default',
          'grey',
          'yellow',
          'orange',
          'red',
          'pink',
          'purple',
          'blue',
          'ice',
          'teal',
          'lime',
        ]),
      );
    });

    test('does NOT contain green (web-only CSS variable)', () {
      expect(optionColorPalette.contains('green'), isFalse);
    });
  });

  group('buildRelationOptionDetails', () {
    test('rejects unknown color with ArgumentError containing "Not in palette"',
        () {
      expect(
        () => buildRelationOptionDetails(
          name: 'Done',
          color: 'green',
          relationKey: 'status',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Not in palette'),
          ),
        ),
      );
    });

    test('accepts the default sentinel as a valid color', () {
      expect(
        () => buildRelationOptionDetails(
          name: 'Any',
          color: 'default',
          relationKey: 'status',
        ),
        returnsNormally,
      );
    });

    test(
        'writes exactly 6 keys: name, text, relationOptionColor, color, '
        'relationKey, layout=13.0', () {
      final s = buildRelationOptionDetails(
        name: 'Done',
        color: 'red',
        relationKey: 'status',
      );
      expect(s.fields.keys.toSet(), <String>{
        'name',
        'text',
        'relationOptionColor',
        'color',
        'relationKey',
        'layout',
      });
      expect(s.fields['name']!.stringValue, 'Done');
      expect(s.fields['text']!.stringValue, 'Done');
      expect(s.fields['relationOptionColor']!.stringValue, 'red');
      expect(s.fields['color']!.stringValue, 'red');
      expect(s.fields['relationKey']!.stringValue, 'status');
      expect(s.fields['layout']!.numberValue, 13.0);
    });
  });

  group('appendOptionToSelectDict', () {
    test('seeds a fresh listValue from null', () {
      final opt = Relation_Option()
        ..id = 'opt-a'
        ..text = 'Alpha'
        ..color = 'red'
        ..relationKey = 'status';
      final result = appendOptionToSelectDict(null, opt);
      expect(result.hasListValue(), isTrue);
      expect(result.listValue.values.length, 1);
      final entry = result.listValue.values.first.structValue;
      expect(entry.fields['id']!.stringValue, 'opt-a');
      expect(entry.fields['text']!.stringValue, 'Alpha');
      expect(entry.fields['color']!.stringValue, 'red');
      expect(entry.fields['relationKey']!.stringValue, 'status');
    });

    test('preserves existing entries in order across three appends', () {
      final first = appendOptionToSelectDict(
        null,
        Relation_Option()
          ..id = 'opt-a'
          ..text = 'A'
          ..color = 'red'
          ..relationKey = 'status',
      );
      final second = appendOptionToSelectDict(
        first,
        Relation_Option()
          ..id = 'opt-b'
          ..text = 'B'
          ..color = 'blue'
          ..relationKey = 'status',
      );
      final third = appendOptionToSelectDict(
        second,
        Relation_Option()
          ..id = 'opt-c'
          ..text = 'C'
          ..color = 'lime'
          ..relationKey = 'status',
      );
      expect(third.listValue.values.length, 3);
      expect(
        third.listValue.values[0].structValue.fields['id']!.stringValue,
        'opt-a',
      );
      expect(
        third.listValue.values[1].structValue.fields['id']!.stringValue,
        'opt-b',
      );
      expect(
        third.listValue.values[2].structValue.fields['id']!.stringValue,
        'opt-c',
      );
    });

    test('accepts empty Value() the same as null', () {
      final result = appendOptionToSelectDict(
        Value(),
        Relation_Option()
          ..id = 'opt-x'
          ..text = 'X'
          ..color = 'grey'
          ..relationKey = 'tag',
      );
      expect(result.listValue.values.length, 1);
      expect(
        result.listValue.values.first.structValue.fields['id']!.stringValue,
        'opt-x',
      );
    });
  });

  group('ResolvedOption', () {
    test('isOrphaned is false when name is present', () {
      expect(
        const ResolvedOption(
          id: 'opt-x',
          name: 'X',
          color: 'red',
          relationKey: 'status',
        ).isOrphaned,
        isFalse,
      );
    });

    test('isOrphaned is true when name is null', () {
      expect(
        const ResolvedOption(
          id: 'opt-x',
          name: null,
          color: null,
          relationKey: null,
        ).isOrphaned,
        isTrue,
      );
    });
  });
}
