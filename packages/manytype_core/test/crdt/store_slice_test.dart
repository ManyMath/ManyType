import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart';
import 'package:test/test.dart';

/// Expectations pin heart's `slice.ApplyChanges` (util/slice/diff.go).
void main() {
  List<String> apply(List<String> current, Change_Content content) =>
      applyStoreSliceUpdate(current, content.storeSliceUpdate);

  group('applyStoreSliceUpdate add', () {
    test('inserts after an existing afterId', () {
      final add = buildStoreSliceUpdateAdd(key: 'k', ids: ['x'], afterId: 'a');
      expect(apply(['a', 'b'], add), ['a', 'x', 'b']);
    });

    test('prepends when afterId is empty or not found', () {
      final first = buildStoreSliceUpdateAdd(key: 'k', ids: ['x']);
      final missing =
          buildStoreSliceUpdateAdd(key: 'k', ids: ['x'], afterId: 'missing');
      expect(apply(['a', 'b'], first), ['x', 'a', 'b']);
      expect(apply(['a', 'b'], missing), ['x', 'a', 'b']);
    });

    test('drops duplicates already in the slice before applying', () {
      final add = buildStoreSliceUpdateAdd(key: 'k', ids: ['x'], afterId: 'b');
      expect(apply(['a', 'b', 'a'], add), ['a', 'b', 'x']);
    });
  });

  group('applyStoreSliceUpdate move', () {
    test('only re-inserts ids that were already in the slice', () {
      final move =
          buildStoreSliceUpdateMove(key: 'k', ids: ['c', 'z'], afterId: 'a');
      expect(apply(['a', 'b', 'c'], move), ['a', 'c', 'b']);
    });

    test('moves to the front when afterId is not found', () {
      final move =
          buildStoreSliceUpdateMove(key: 'k', ids: ['c'], afterId: 'missing');
      expect(apply(['a', 'b', 'c'], move), ['c', 'a', 'b']);
    });
  });

  test('remove filters every listed id', () {
    final remove = buildStoreSliceUpdateRemove(key: 'k', ids: ['a', 'c', 'z']);
    expect(apply(['a', 'b', 'c'], remove), ['b']);
  });
}
