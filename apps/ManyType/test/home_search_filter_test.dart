@TestOn('vm')
library;

// Unit coverage for the object-list search/filter predicate used by
// home_page.dart's search field: matches display name, type, and detail
// values, case-insensitively, and passes everything through on an empty
// query.

import 'package:flutter_test/flutter_test.dart';
import 'package:manytype/src/home/home_page.dart';
import 'package:manytype_cli/manytype_cli.dart';

ObjectMeta _meta({
  required String id,
  String? name,
  List<String> types = const [],
  Map<String, String> details = const {},
}) => ObjectMeta(id: id, name: name, types: types, details: details);

void main() {
  group('filterObjects', () {
    final metas = <ObjectMeta>[
      _meta(id: '1', name: 'Grocery list for the week', types: ['Page']),
      _meta(id: '2', name: 'Quarterly budget planning', types: ['Page']),
      _meta(
        id: '3',
        name: 'Untitled',
        types: ['Task'],
        details: {'notes': 'Pick up grocery items on the way home'},
      ),
    ];

    test('empty query returns everything unchanged', () {
      expect(filterObjectsForSearch(metas, ''), same(metas));
      expect(filterObjectsForSearch(metas, '   '), same(metas));
    });

    test('matches display name case-insensitively', () {
      final result = filterObjectsForSearch(metas, 'GROCERY');
      expect(result.map((m) => m.id), containsAll(<String>['1', '3']));
      expect(result, hasLength(2));
    });

    test('matches object type', () {
      final result = filterObjectsForSearch(metas, 'task');
      expect(result.single.id, '3');
    });

    test('matches detail values', () {
      final result = filterObjectsForSearch(metas, 'way home');
      expect(result.single.id, '3');
    });

    test('no match returns an empty list', () {
      expect(filterObjectsForSearch(metas, 'nonexistent-xyz'), isEmpty);
    });
  });
}
