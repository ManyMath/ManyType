import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/structured_replay.dart';
import 'package:manytype_protocol/models.dart';
import 'package:test/test.dart';

import 'web/web_db_test_helpers.dart';

void main() {
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  late ManytypeDatabase db;
  late CliConfig config;

  setUpAll(() async {
    await configureWebTestDatabaseAssets();
  });

  setUp(() async {
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
    config =
        CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:33020');
  });

  tearDown(() async {
    await db.close();
  });

  test('returns null for an object with no local changes', () async {
    final result = await replayObjectRelations(db, config, 'missing-object-id');
    expect(result, isNull);
  });

  test('reflects a string relation value', () async {
    final created = await createCommand('Original text', db, config);
    await editRelationOffline(
      created.objectId,
      db,
      config,
      relationKey: 'description',
      stringValue: 'A description',
    );

    final result = await replayObjectRelations(db, config, created.objectId);
    final view = result!.relations.singleWhere((r) => r.key == 'description');
    expect(view.stringValue, 'A description');
    expect(view.boolValue, isNull);
  });

  test('reflects a bool relation value', () async {
    final created = await createCommand('Original text', db, config);
    await editRelationOffline(
      created.objectId,
      db,
      config,
      relationKey: 'isFavorite',
      boolValue: 'true',
    );

    final result = await replayObjectRelations(db, config, created.objectId);
    final view = result!.relations.singleWhere((r) => r.key == 'isFavorite');
    expect(view.format, RelationFormat.checkbox);
    expect(view.boolValue, isTrue);
  });

  test('reflects a date relation value as unix seconds', () async {
    final created = await createCommand('Original text', db, config);
    await editRelationOffline(
      created.objectId,
      db,
      config,
      relationKey: 'dueDate',
      dateValue: '1700000000',
    );

    final result = await replayObjectRelations(db, config, created.objectId);
    final view = result!.relations.singleWhere((r) => r.key == 'dueDate');
    expect(view.dateValue, 1700000000);
  });

  test('preserves an object-reference relation format from STRelation',
      () async {
    const relationKey = 'assignee';
    await createCommand(
      'Assignee',
      db,
      config,
      asRelation: true,
      format: 'object',
    );
    final person = await createCommand('Ada Lovelace', db, config);
    final target = await createCommand('Review draft', db, config);
    await editRelationOffline(
      target.objectId,
      db,
      config,
      relationKey: relationKey,
      objectIdValue: person.objectId,
    );

    final result = await replayObjectRelations(db, config, target.objectId);
    final view = result!.relations.singleWhere((r) => r.key == relationKey);
    expect(view.format, RelationFormat.object);
    expect(view.objectIdValue, person.objectId);
    expect(view.stringValue, isNull);
  });

  test('resolves a status relation value to its option name/color', () async {
    const relationKey = 'priority';
    await createCommand(
      'Priority',
      db,
      config,
      asRelation: true,
      format: 'status',
    );
    final optionObj = await createCommand(
      'High',
      db,
      config,
      asRelationOption: true,
      forRelation: relationKey,
      color: 'red',
    );
    final target = await createCommand('A task', db, config);
    await editRelationOffline(
      target.objectId,
      db,
      config,
      relationKey: relationKey,
      status: optionObj.objectId,
    );

    final result = await replayObjectRelations(db, config, target.objectId);
    final view = result!.relations.singleWhere((r) => r.key == relationKey);
    expect(view.format, RelationFormat.status);
    expect(view.statusOptionId, optionObj.objectId);
    expect(view.statusName, 'High');
    expect(view.statusColor, 'red');
  });

  test('resolves tag relation values, in stored order', () async {
    const relationKey = 'labels';
    await createCommand(
      'Labels',
      db,
      config,
      asRelation: true,
      format: 'tag',
    );
    final optA = await createCommand(
      'Urgent',
      db,
      config,
      asRelationOption: true,
      forRelation: relationKey,
      color: 'red',
    );
    final optB = await createCommand(
      'Later',
      db,
      config,
      asRelationOption: true,
      forRelation: relationKey,
      color: 'blue',
    );
    final target = await createCommand('A task', db, config);
    await editRelationOffline(
      target.objectId,
      db,
      config,
      relationKey: relationKey,
      stringListValue: [optA.objectId, optB.objectId],
    );

    final result = await replayObjectRelations(db, config, target.objectId);
    final view = result!.relations.singleWhere((r) => r.key == relationKey);
    expect(view.format, RelationFormat.tag);
    expect(view.tagOptions.map((o) => o.name), ['Urgent', 'Later']);
    expect(view.tagOptions.map((o) => o.color), ['red', 'blue']);
  });

  test('surfaces an orphaned tag option id alongside a resolved one', () async {
    const relationKey = 'labels';
    await createCommand(
      'Labels',
      db,
      config,
      asRelation: true,
      format: 'tag',
    );
    final optA = await createCommand(
      'Urgent',
      db,
      config,
      asRelationOption: true,
      forRelation: relationKey,
      color: 'red',
    );
    final target = await createCommand('A task', db, config);
    await editRelationOffline(
      target.objectId,
      db,
      config,
      relationKey: relationKey,
      stringListValue: [optA.objectId, 'opt-not-synced-locally'],
    );

    final result = await replayObjectRelations(db, config, target.objectId);
    final view = result!.relations.singleWhere((r) => r.key == relationKey);
    expect(view.format, RelationFormat.tag);
    expect(view.tagOptions[0].name, 'Urgent');
    expect(view.tagOptions[1].optionId, 'opt-not-synced-locally');
    expect(view.tagOptions[1].name, isNull);
  });

  test('excludes structural targetObjectType/sourceObject keys', () async {
    final typeObj = await createCommand('Task', db, config, asType: true);
    final template = await createCommand(
      'Task Template',
      db,
      config,
      asTemplate: true,
      targetObjectType: typeObj.objectId,
    );

    final result = await replayObjectRelations(db, config, template.objectId);
    expect(
      result!.relations.map((r) => r.key),
      isNot(contains('targetObjectType')),
    );
  });
}
