@TestOn('vm')
library;

// Unit coverage for the object-list search/filter predicate used by
// home_page.dart's search field: matches display name, type, and detail
// values, case-insensitively, and passes everything through on an empty
// query.

import 'package:flutter_test/flutter_test.dart';
import 'package:manytype/src/home/home_page.dart';
import 'package:manytype/src/state/objects_providers.dart';
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

  group('library sections', () {
    final page = _meta(id: 'page', name: 'Notes', types: ['ot-page']);
    final type = _meta(id: 'type', name: 'Task', types: ['ot-objectType']);
    final relation = _meta(
      id: 'relation',
      name: 'Priority',
      types: ['ot-relation'],
    );
    final relationOption = _meta(
      id: 'option',
      name: 'High',
      types: ['ot-relationOption'],
    );
    final template = _meta(
      id: 'template',
      name: 'Task template',
      types: ['ot-template', 'task'],
    );
    final objects = <ObjectMeta>[
      page,
      type,
      relation,
      relationOption,
      template,
    ];

    test('classifies pages, types, and relations independently', () {
      expect(objectsForSection(objects, LibrarySection.pages), [page]);
      expect(objectsForSection(objects, LibrarySection.types), [type]);
      expect(objectsForSection(objects, LibrarySection.relations), [relation]);
    });

    test('does not expose relation options or templates as pages', () {
      expect(isInternalSchemaSupportObject(relationOption), isTrue);
      expect(isInternalSchemaSupportObject(template), isTrue);
      expect(objectsForSection(objects, LibrarySection.pages), [page]);
    });

    test('uses friendly labels instead of protocol markers', () {
      expect(friendlyObjectType(page), 'Page');
      expect(friendlyObjectType(type), 'Type');
      expect(friendlyObjectType(relation), 'Relation');
    });
  });
}
