import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/commands/list.dart';
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

  test('mutates a block\'s text without any network dependency', () async {
    final created = await createCommand('Original text', db, config);
    final before = await replayObjectBlocks(db, config, created.objectId);
    final titleBlockId = before!.blocks.singleWhere((b) => b.id == 'title').id;

    final result = await editOffline(
      created.objectId,
      db,
      config,
      blockId: titleBlockId,
      setText: 'Edited text',
    );
    expect(result.blockId, titleBlockId);
    expect(result.description, 'rename');

    final after = await replayObjectBlocks(db, config, created.objectId);
    final updated = after!.blocks.singleWhere((b) => b.id == titleBlockId);
    expect(updated.text, 'Edited text');
    final meta = (await listCommand(db, config)).singleWhere(
      (object) => object.id == created.objectId,
    );
    expect(meta.name, 'Edited text');
  });

  test('mutates a checkbox\'s checked state offline', () async {
    final created = await createCommand(
      'Buy milk',
      db,
      config,
      checkbox: true,
    );
    final before = await replayObjectBlocks(db, config, created.objectId);
    final checkboxId = before!.blocks
        .singleWhere((b) => b.style == Block_Content_Text_Style.Checkbox)
        .id;

    await editOffline(
      created.objectId,
      db,
      config,
      blockId: checkboxId,
      setChecked: true,
    );

    final after = await replayObjectBlocks(db, config, created.objectId);
    final updated = after!.blocks.singleWhere((b) => b.id == checkboxId);
    expect(updated.checked, isTrue);
  });

  test('applies multiple offline edits in sequence', () async {
    final created = await createCommand('Step one', db, config);
    final before = await replayObjectBlocks(db, config, created.objectId);
    final titleBlockId = before!.blocks.singleWhere((b) => b.id == 'title').id;

    await editOffline(
      created.objectId,
      db,
      config,
      blockId: titleBlockId,
      setText: 'Step two',
    );
    await editOffline(
      created.objectId,
      db,
      config,
      blockId: titleBlockId,
      setText: 'Step three',
    );

    final after = await replayObjectBlocks(db, config, created.objectId);
    final updated = after!.blocks.singleWhere((b) => b.id == titleBlockId);
    expect(updated.text, 'Step three');
  });

  test('throws when no mutation is specified', () async {
    final created = await createCommand('Original text', db, config);
    final before = await replayObjectBlocks(db, config, created.objectId);
    final titleBlockId = before!.blocks.singleWhere((b) => b.id == 'title').id;

    expect(
      () => editOffline(created.objectId, db, config, blockId: titleBlockId),
      throwsStateError,
    );
  });

  test('throws for an object with no local changes', () async {
    expect(
      () => editOffline(
        'missing-object-id',
        db,
        config,
        blockId: 'title',
        setText: 'x',
      ),
      throwsStateError,
    );
  });
}
