import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/structured_replay.dart';
import 'package:manytype_cli/src/sync_service.dart';
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
    final result = await replayObjectBlocks(db, config, 'missing-object-id');
    expect(result, isNull);
  });

  test('exposes the primary text block, hides structural blocks', () async {
    final created = await createCommand('Hello structured world', db, config);

    final result = await replayObjectBlocks(db, config, created.objectId);
    expect(result, isNotNull);
    expect(result!.objectId, created.objectId);

    final blockIds = result.blocks.map((b) => b.id);
    expect(blockIds, isNot(contains('header')));
    expect(blockIds, isNot(contains('featuredRelations')));

    final title = result.blocks.singleWhere((b) => b.id == 'title');
    expect(title.text, 'Hello structured world');
    expect(title.style, Block_Content_Text_Style.Title);
    expect(title.checked, isNull);
  });

  test('reflects a checkbox block with its checked state', () async {
    final created = await createCommand(
      'Buy milk',
      db,
      config,
      checkbox: true,
    );

    final result = await replayObjectBlocks(db, config, created.objectId);
    final checkboxBlock = result!.blocks.singleWhere(
      (b) => b.style == Block_Content_Text_Style.Checkbox,
    );
    expect(checkboxBlock.text, 'Buy milk');
    expect(checkboxBlock.checked, isFalse);
  });

  test('reflects a BlockUpdate(blockSetText) mutation on next replay',
      () async {
    final created = await createCommand(
      'Buy milk',
      db,
      config,
      checkbox: true,
    );
    final before = await replayObjectBlocks(db, config, created.objectId);
    final blockId = before!.blocks
        .singleWhere((b) => b.style == Block_Content_Text_Style.Checkbox)
        .id;

    await editCommand(
      created.objectId,
      null,
      db,
      config,
      networkConfigPath: 'unused-network.yml',
      syncService: _NoopSyncService(),
      blockId: blockId,
      setChecked: true,
    );

    final after = await replayObjectBlocks(db, config, created.objectId);
    final updated = after!.blocks.singleWhere((b) => b.id == blockId);
    expect(updated.checked, isTrue);
    expect(updated.text, 'Buy milk');
  });
}

class _NoopSyncService extends SyncService {
  @override
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
    String? networkConfigContent,
  }) async {}
}
