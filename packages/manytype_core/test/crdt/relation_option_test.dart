import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, RootChange, TreeChange;
import 'package:manytype_protocol/models.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';
import 'package:test/test.dart';

/// Encode an unsigned integer as a protobuf varint.
List<int> _encodeVarint(int value) {
  final out = <int>[];
  var v = value;
  while (v >= 0x80) {
    out.add((v & 0x7F) | 0x80);
    v >>= 7;
  }
  out.add(v & 0x7F);
  return out;
}

/// Build a [RawTreeChange] blob whose payload is a [RootChange] carrying a
/// `changePayload` that begins with the `SmartBlockType` varint tagged as
/// proto field 1 (tag byte `0x08`). This is the exact shape that
/// [extractRootSmartBlockType] scans.
Uint8List _rootRawTreeChangeWithSbType(int sbType) {
  final changePayload = <int>[0x08, ..._encodeVarint(sbType)];
  final root = RootChange()..changePayload = changePayload;
  final raw = RawTreeChange()..payload = root.writeToBuffer();
  return Uint8List.fromList(raw.writeToBuffer());
}

/// Build a [RawTreeChange] blob whose payload is a plaintext
/// (un-encrypted, un-compressed) [TreeChange] wrapping a [Change] with a
/// single snapshot carrying the given [details]. Matches the test helper
/// used by `snapshot_details_test.dart` so `loadLocalOptionIndex`'s
/// internal call to `replayObjectDetails` exercises its merge logic.
Uint8List _snapshotRawTreeChange(Map<String, Value> details) {
  final struct = Struct();
  details.forEach((k, v) => struct.fields[k] = v);
  final change = changes_proto.Change()
    ..snapshot = (changes_proto.Change_Snapshot()
      ..data = (SmartBlockSnapshotBase()..details = struct));
  final tc = TreeChange()
    ..changesData = change.writeToBuffer()
    ..readKeyId = ''
    ..dataType = '';
  final raw = RawTreeChange()..payload = tc.writeToBuffer();
  return Uint8List.fromList(raw.writeToBuffer());
}

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

  group('extractRootSmartBlockType', () {
    test('returns -1 for empty input', () {
      expect(extractRootSmartBlockType(const <Uint8List>[]), -1);
    });

    test('decodes single-byte varint (small smart_block_type)', () {
      // 16 / 0x10 fits in a single-byte varint.
      final raw = _rootRawTreeChangeWithSbType(16);
      expect(extractRootSmartBlockType(<Uint8List>[raw]), 16);
    });

    test(
        'decodes multi-byte varint 529 (STRelationOption = 0x211, '
        'two-byte encoding)', () {
      final raw = _rootRawTreeChangeWithSbType(smartBlockTypeRelationOption);
      expect(
        extractRootSmartBlockType(<Uint8List>[raw]),
        smartBlockTypeRelationOption,
      );
    });

    test('decodes multi-byte varint 528 (STType)', () {
      final raw = _rootRawTreeChangeWithSbType(528);
      expect(extractRootSmartBlockType(<Uint8List>[raw]), 528);
    });
  });

  group('loadLocalOptionIndex', () {
    final emptyKey = Uint8List(32);

    test('empty input list returns an empty map', () async {
      final out = await loadLocalOptionIndex(const <OptionIndexInput>[]);
      expect(out, isEmpty);
    });

    test(
        'single STRelationOption input -> ResolvedOption with name/color/'
        'relationKey and isOrphaned=false', () async {
      final input = OptionIndexInput(
        objectId: 'opt-done',
        rawTreeChanges: <Uint8List>[
          _rootRawTreeChangeWithSbType(smartBlockTypeRelationOption),
          _snapshotRawTreeChange(<String, Value>{
            'name': Value(stringValue: 'Done'),
            'text': Value(stringValue: 'Done'),
            'relationOptionColor': Value(stringValue: 'red'),
            'color': Value(stringValue: 'red'),
            'relationKey': Value(stringValue: 'status'),
          }),
        ],
        treeKey: emptyKey,
      );

      final out = await loadLocalOptionIndex(<OptionIndexInput>[input]);
      expect(out.keys, contains('opt-done'));
      final resolved = out['opt-done']!;
      expect(resolved.id, 'opt-done');
      expect(resolved.name, 'Done');
      expect(resolved.color, 'red');
      expect(resolved.relationKey, 'status');
      expect(resolved.isOrphaned, isFalse);
    });

    test('non-option sbType is excluded from the result', () async {
      // 528 is STType, not STRelationOption.
      final input = OptionIndexInput(
        objectId: 'type-abc',
        rawTreeChanges: <Uint8List>[
          _rootRawTreeChangeWithSbType(528),
          _snapshotRawTreeChange(<String, Value>{
            'name': Value(stringValue: 'SomeType'),
          }),
        ],
        treeKey: emptyKey,
      );
      final out = await loadLocalOptionIndex(<OptionIndexInput>[input]);
      expect(out, isEmpty);
    });

    test(
        'STRelationOption with missing details yields isOrphaned=true',
        () async {
      final input = OptionIndexInput(
        objectId: 'opt-broken',
        rawTreeChanges: <Uint8List>[
          _rootRawTreeChangeWithSbType(smartBlockTypeRelationOption),
          // No snapshot change at all: replay returns an empty map.
        ],
        treeKey: emptyKey,
      );
      final out = await loadLocalOptionIndex(<OptionIndexInput>[input]);
      expect(out.keys, contains('opt-broken'));
      final resolved = out['opt-broken']!;
      expect(resolved.name, isNull);
      expect(resolved.color, isNull);
      expect(resolved.relationKey, isNull);
      expect(resolved.isOrphaned, isTrue);
    });

    test('mixed inputs return only the option entries', () async {
      final optionInput = OptionIndexInput(
        objectId: 'opt-a',
        rawTreeChanges: <Uint8List>[
          _rootRawTreeChangeWithSbType(smartBlockTypeRelationOption),
          _snapshotRawTreeChange(<String, Value>{
            'name': Value(stringValue: 'A'),
            'color': Value(stringValue: 'blue'),
            'relationKey': Value(stringValue: 'tag'),
          }),
        ],
        treeKey: emptyKey,
      );
      final nonOptionInput = OptionIndexInput(
        objectId: 'page-b',
        rawTreeChanges: <Uint8List>[
          _rootRawTreeChangeWithSbType(16),
          _snapshotRawTreeChange(<String, Value>{
            'name': Value(stringValue: 'B'),
          }),
        ],
        treeKey: emptyKey,
      );
      final out = await loadLocalOptionIndex(
        <OptionIndexInput>[optionInput, nonOptionInput],
      );
      expect(out.keys.toSet(), <String>{'opt-a'});
      expect(out['opt-a']!.name, 'A');
      expect(out['opt-a']!.color, 'blue');
      expect(out['opt-a']!.relationKey, 'tag');
    });
  });
}
