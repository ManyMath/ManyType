@TestOn('vm')
library;

// Runtime proof for the relation-picker data layer: drives
// create(kind: NewObjectKind.relation) -> spaceRelationsProvider ->
// editRelation(relationKey: <picked relation's uniqueKey>, ...) entirely
// through ObjectsController (the same surface the relation editor's
// relation-key picker now calls), no UI involved. Mirrors
// space_types_test.dart's shape for the analogous STType case.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart' show CliConfig;
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_protocol/models.dart' show RelationFormat;

import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/objects_providers.dart';
import 'package:manytype/src/state/session_provider.dart';

const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  late Directory tempBase;
  late ProviderContainer container;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp('manytype_app_test');
    AccountRegistry.testBaseDirOverride = tempBase.path;
    CliConfig.testConfigDirOverride = tempBase.path;
    container = ProviderContainer();
    await container
        .read(accountsControllerProvider)
        .createAndSelect(mnemonic: _testMnemonic, displayName: 'Test');
  });

  tearDown(() async {
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  test(
    'spaceRelationsProvider only surfaces STRelation objects, not plain ones',
    () async {
      final session = await container.read(sessionProvider.future);
      final spaceId = session!.identity.spaceId;
      final controller = container.read(objectsControllerProvider);

      expect(
        await container.read(spaceRelationsProvider(spaceId).future),
        isEmpty,
      );

      final plainResult = await controller.create('A plain object');
      expect(plainResult, isNotNull);
      expect(
        await container.read(spaceRelationsProvider(spaceId).future),
        isEmpty,
      );

      final relationResult = await controller.create(
        'Priority',
        kind: NewObjectKind.relation,
        relationFormat: NewRelationFormat.status,
      );
      expect(relationResult, isNotNull);
      final relations = await container.read(
        spaceRelationsProvider(spaceId).future,
      );
      expect(relations.map((r) => r.id), [relationResult!.objectId]);
      expect(relations.single.name, 'Priority');
      expect(relations.single.details['uniqueKey'], 'priority');
      // status == RelationFormat.status.value == 3.
      expect(relations.single.details['relationFormat'], '3.0');
    },
  );

  test('editRelation writes a status value keyed by a picked relation\'s '
      'uniqueKey', () async {
    final session = await container.read(sessionProvider.future);
    final spaceId = session!.identity.spaceId;
    final controller = container.read(objectsControllerProvider);

    final relationResult = await controller.create(
      'Priority',
      kind: NewObjectKind.relation,
      relationFormat: NewRelationFormat.status,
    );
    final relations = await container.read(
      spaceRelationsProvider(spaceId).future,
    );
    final uniqueKey = relations.single.details['uniqueKey']!;
    expect(uniqueKey, 'priority');

    final objectResult = await controller.create('My task');
    expect(objectResult, isNotNull);

    final editResult = await controller.editRelation(
      objectResult!.objectId,
      relationKey: uniqueKey,
      status: 'Urgent',
    );
    expect(editResult, isNotNull);

    final detail = await container.read(
      objectDetailProvider(objectResult.objectId).future,
    );
    expect(detail!.lines.any((line) => line.contains('Urgent')), isTrue);
    expect(relationResult, isNotNull);
  });

  test('editRelation writes an object-reference value keyed by a picked '
      'relation', () async {
    final session = await container.read(sessionProvider.future);
    final spaceId = session!.identity.spaceId;
    final controller = container.read(objectsControllerProvider);

    final relationResult = await controller.create(
      'Assignee',
      kind: NewObjectKind.relation,
      relationFormat: NewRelationFormat.object,
    );
    expect(relationResult, isNotNull);
    final relations = await container.read(
      spaceRelationsProvider(spaceId).future,
    );
    final relation = relations.single;
    final uniqueKey = relation.details['uniqueKey']!;
    expect(uniqueKey, 'assignee');
    expect(
      relation.details['relationFormat'],
      RelationFormat.object.value.toDouble().toString(),
    );

    final personResult = await controller.create('Ada Lovelace');
    final taskResult = await controller.create('Review draft');
    expect(personResult, isNotNull);
    expect(taskResult, isNotNull);

    final editResult = await controller.editRelation(
      taskResult!.objectId,
      relationKey: uniqueKey,
      objectIdValue: personResult!.objectId,
    );
    expect(editResult, isNotNull);

    final replayed = await container.read(
      objectRelationsProvider(taskResult.objectId).future,
    );
    final assignee = replayed!.relations.singleWhere(
      (relation) => relation.key == uniqueKey,
    );
    expect(assignee.format, RelationFormat.object);
    expect(assignee.objectIdValue, personResult.objectId);
  });
}
