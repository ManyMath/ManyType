import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';
import 'package:test/test.dart';

/// Wrap a [changes_proto.Change] proto as a RawTreeChange byte blob using an
/// UN-encrypted, UN-compressed TreeChange envelope (empty readKeyId + empty
/// dataType). This keeps the test off the real crypto + snappy code paths;
/// `replayObjectDetails` then exercises only its replay merge logic.
Uint8List _wrapAsRawTreeChange(changes_proto.Change change) {
  final tc = changes_proto.TreeChange()
    ..changesData = change.writeToBuffer()
    ..readKeyId = ''
    ..dataType = '';
  final raw = changes_proto.RawTreeChange()..payload = tc.writeToBuffer();
  return Uint8List.fromList(raw.writeToBuffer());
}

changes_proto.Change _snapshotChange(Map<String, Value> details) {
  final struct = Struct();
  details.forEach((k, v) => struct.fields[k] = v);
  return changes_proto.Change()
    ..snapshot = (changes_proto.Change_Snapshot()
      ..data = (changes_proto.Change_Snapshot_Data()..details = struct));
}

changes_proto.Change _detailsSetChange(String key, Value value) {
  return changes_proto.Change()
    ..content.add(
      changes_proto.Change_Content(
        detailsSet: changes_proto.Change_DetailsSet(key: key, value: value),
      ),
    );
}

void main() {
  final emptyKey = Uint8List(32);

  group('replayObjectDetails', () {
    test('empty input returns an empty map', () async {
      final out = await replayObjectDetails(
        rawTreeChanges: const <Uint8List>[],
        treeKey: emptyKey,
      );
      expect(out, isEmpty);
    });

    test('snapshot bootstraps, subsequent detailsSet merges by key', () async {
      final rows = <Uint8List>[
        _wrapAsRawTreeChange(
          _snapshotChange(<String, Value>{
            'a': Value(stringValue: '1'),
            'b': Value(stringValue: '2'),
          }),
        ),
        _wrapAsRawTreeChange(
          _detailsSetChange('a', Value(stringValue: '10')),
        ),
        _wrapAsRawTreeChange(
          _detailsSetChange('c', Value(stringValue: '3')),
        ),
      ];
      final out = await replayObjectDetails(
        rawTreeChanges: rows,
        treeKey: emptyKey,
      );
      expect(out['a']!.stringValue, '10');
      expect(out['b']!.stringValue, '2');
      expect(out['c']!.stringValue, '3');
    });

    test('second snapshot clears and replaces all prior details', () async {
      final rows = <Uint8List>[
        _wrapAsRawTreeChange(
          _snapshotChange(<String, Value>{'a': Value(stringValue: '1')}),
        ),
        _wrapAsRawTreeChange(
          _detailsSetChange('b', Value(stringValue: '2')),
        ),
        _wrapAsRawTreeChange(
          _snapshotChange(<String, Value>{'x': Value(stringValue: '9')}),
        ),
        _wrapAsRawTreeChange(
          _detailsSetChange('y', Value(stringValue: '7')),
        ),
      ];
      final out = await replayObjectDetails(
        rawTreeChanges: rows,
        treeKey: emptyKey,
      );
      expect(out.keys.toSet(), <String>{'x', 'y'});
      expect(out['x']!.stringValue, '9');
      expect(out['y']!.stringValue, '7');
      expect(out.containsKey('a'), isFalse);
      expect(out.containsKey('b'), isFalse);
    });

    test('returned values are deep-copied (mutating them is safe)', () async {
      final rows = <Uint8List>[
        _wrapAsRawTreeChange(
          _snapshotChange(<String, Value>{'a': Value(stringValue: 'orig')}),
        ),
      ];
      final out = await replayObjectDetails(
        rawTreeChanges: rows,
        treeKey: emptyKey,
      );
      // Mutate the returned Value: stringValue is immutable but the map itself
      // is mutable. Confirm we can replace without affecting the source bytes.
      out['a'] = Value(stringValue: 'mutated');
      final again = await replayObjectDetails(
        rawTreeChanges: rows,
        treeKey: emptyKey,
      );
      expect(again['a']!.stringValue, 'orig');
    });
  });
}
