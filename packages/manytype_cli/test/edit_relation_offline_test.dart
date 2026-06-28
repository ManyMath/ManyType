import 'dart:typed_data';

import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart'
    show deriveSpaceKey, deriveTreeKey, replayObjectDetails;
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

  test('writes a string relation value without any network dependency',
      () async {
    final created = await createCommand('Original text', db, config);

    final result = await editRelationOffline(
      created.objectId,
      db,
      config,
      relationKey: 'description',
      stringValue: 'A description',
    );
    expect(result.relationKey, 'description');
  });

  test('written string relation value is visible on replay', () async {
    final created = await createCommand('Original text', db, config);
    await editRelationOffline(
      created.objectId,
      db,
      config,
      relationKey: 'description',
      stringValue: 'A description',
    );

    final changes = await db.getChangesForObject(created.objectId);
    final identity = await Identity.fromMnemonic(config.mnemonic);
    final accountPrivRaw = Uint8List(64)
      ..setRange(0, 32, identity.accountSeed)
      ..setRange(32, 64, identity.accountKeyPair.publicKey);
    final spaceKey = await deriveSpaceKey(accountPrivRaw);
    final treeKey = await deriveTreeKey(spaceKey, created.objectId);
    final details = await replayObjectDetails(
      rawTreeChanges:
          changes.map((c) => Uint8List.fromList(c.rawBytes)).toList(),
      treeKey: treeKey,
    );
    expect(details['description']?.stringValue, 'A description');
  });

  test('writes a bool relation value', () async {
    final created = await createCommand('Original text', db, config);
    final result = await editRelationOffline(
      created.objectId,
      db,
      config,
      relationKey: 'isFavorite',
      boolValue: 'true',
    );
    expect(result.relationKey, 'isFavorite');
  });

  test('writes a tag/string-list relation value (full replace)', () async {
    final created = await createCommand('Original text', db, config);
    final result = await editRelationOffline(
      created.objectId,
      db,
      config,
      relationKey: 'tag',
      stringListValue: ['opt-a', 'opt-b'],
    );
    expect(result.relationKey, 'tag');
  });

  test('throws when no typed value is specified', () async {
    final created = await createCommand('Original text', db, config);
    expect(
      () => editRelationOffline(
        created.objectId,
        db,
        config,
        relationKey: 'description',
      ),
      throwsStateError,
    );
  });

  test('throws for an object with no local changes', () async {
    expect(
      () => editRelationOffline(
        'missing-object-id',
        db,
        config,
        relationKey: 'description',
        stringValue: 'x',
      ),
      throwsStateError,
    );
  });
}
