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

  test('appends a plain text block without any network dependency', () async {
    final created = await createCommand('Original text', db, config);

    final result = await insertBlockOffline(
      created.objectId,
      db,
      config,
      text: 'A new paragraph',
    );

    final after = await replayObjectBlocks(db, config, created.objectId);
    final inserted = after!.blocks.singleWhere((b) => b.id == result.blockId);
    expect(inserted.text, 'A new paragraph');
    expect(inserted.style, Block_Content_Text_Style.Paragraph);
  });

  test('appends a checkbox block', () async {
    final created = await createCommand('Original text', db, config);

    final result = await insertBlockOffline(
      created.objectId,
      db,
      config,
      text: 'Buy milk',
      kind: NewBlockKind.checkbox,
    );

    final after = await replayObjectBlocks(db, config, created.objectId);
    final inserted = after!.blocks.singleWhere((b) => b.id == result.blockId);
    expect(inserted.style, Block_Content_Text_Style.Checkbox);
    expect(inserted.checked, isFalse);
  });

  test('appends toggle/quote/callout/numbered blocks with distinct styles',
      () async {
    final created = await createCommand('Original text', db, config);

    final toggle = await insertBlockOffline(
      created.objectId,
      db,
      config,
      text: 'Toggle me',
      kind: NewBlockKind.toggle,
    );
    final quote = await insertBlockOffline(
      created.objectId,
      db,
      config,
      text: 'A quote',
      kind: NewBlockKind.quote,
    );
    final callout = await insertBlockOffline(
      created.objectId,
      db,
      config,
      text: 'A callout',
      kind: NewBlockKind.callout,
    );
    final numbered = await insertBlockOffline(
      created.objectId,
      db,
      config,
      text: 'Item one',
      kind: NewBlockKind.numbered,
    );

    final after = await replayObjectBlocks(db, config, created.objectId);
    Block_Content_Text_Style styleOf(String id) =>
        after!.blocks.singleWhere((b) => b.id == id).style;
    expect(styleOf(toggle.blockId), Block_Content_Text_Style.Toggle);
    expect(styleOf(quote.blockId), Block_Content_Text_Style.Quote);
    expect(styleOf(callout.blockId), Block_Content_Text_Style.Callout);
    expect(styleOf(numbered.blockId), Block_Content_Text_Style.Numbered);
  });

  test('inserted blocks are appended after existing content, in order',
      () async {
    final created = await createCommand('Original text', db, config);

    final first = await insertBlockOffline(
      created.objectId,
      db,
      config,
      text: 'First',
    );
    final second = await insertBlockOffline(
      created.objectId,
      db,
      config,
      text: 'Second',
    );

    final after = await replayObjectBlocks(db, config, created.objectId);
    final ids = after!.blocks.map((b) => b.id).toList();
    expect(
      ids.indexOf(first.blockId) < ids.indexOf(second.blockId),
      isTrue,
    );
  });

  test('throws for an object with no local changes', () async {
    expect(
      () => insertBlockOffline(
        'missing-object-id',
        db,
        config,
        text: 'x',
      ),
      throwsStateError,
    );
  });
}
