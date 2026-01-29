import 'package:test/test.dart';

import 'package:manytype_cli/src/commands/list.dart';

void main() {
  group('matchesObjectMetaFilters', () {
    test('matches template filtered by target type detail', () {
      final meta = ObjectMeta(
        id: 'tmpl-1',
        types: const ['ot-template', 'project'],
        name: 'Project Template',
        details: const {
          'targetObjectType': 'type-project',
        },
      );

      expect(
        matchesObjectMetaFilters(
          meta,
          typeFilter: 'ot-template',
          whereFilter: 'targetObjectType=type-project',
        ),
        isTrue,
      );
    });

    test('rejects non-template objects for template-only filter', () {
      final meta = ObjectMeta(
        id: 'obj-1',
        types: const ['project'],
        name: 'Project 1',
        details: const {
          'targetObjectType': 'type-project',
        },
      );

      expect(
        matchesObjectMetaFilters(
          meta,
          typeFilter: 'ot-template',
          whereFilter: 'targetObjectType=type-project',
        ),
        isFalse,
      );
    });

    test('rejects template with wrong target object type', () {
      final meta = ObjectMeta(
        id: 'tmpl-2',
        types: const ['ot-template', 'project'],
        name: 'Project Template',
        details: const {
          'targetObjectType': 'type-task',
        },
      );

      expect(
        matchesObjectMetaFilters(
          meta,
          typeFilter: 'ot-template',
          whereFilter: 'targetObjectType=type-project',
        ),
        isFalse,
      );
    });
  });
}
