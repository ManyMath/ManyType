@TestOn('vm')
library;

// Runtime proof for the structured block editor's data layer: drives
// create -> replay -> editBlock -> re-replay through the app's riverpod
// providers against the real core, no UI involved. Mirrors
// data_layer_test.dart's temp-dir isolation via
// AccountRegistry.testBaseDirOverride.

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/manytype_cli.dart'
    show
        CliConfig,
        ManytypeSession,
        NewBlockKind,
        ObjectMeta,
        insertBlockOffline,
        listCommand;
import 'package:manytype_protocol/models.dart' show Block_Content_Text_Style;

import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/objects_providers.dart';
import 'package:manytype/src/state/session_provider.dart';
import 'package:manytype/src/state/sync_controller.dart';

const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  late Directory tempBase;
  late ProviderContainer container;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp('manytype_app_test');
    AccountRegistry.testBaseDirOverride = tempBase.path;
    container = ProviderContainer(
      overrides: <Override>[
        syncRunnerProvider.overrideWithValue((_, __) async {}),
      ],
    );
    await container
        .read(accountsControllerProvider)
        .createAndSelect(mnemonic: _testMnemonic, displayName: 'Test');
  });

  tearDown(() async {
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    AccountRegistry.testBaseDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  test(
    'objectBlocksProvider exposes the title block, editBlock mutates it',
    () async {
      final created = await container
          .read(objectsControllerProvider)
          .create('Original title');
      expect(created, isNotNull);

      final before = await container.read(
        objectBlocksProvider(created!.objectId).future,
      );
      expect(before, isNotNull);
      final titleBlock = before!.blocks.singleWhere((b) => b.id == 'title');
      expect(titleBlock.text, 'Original title');

      final editResult = await container
          .read(objectsControllerProvider)
          .editBlock(created.objectId, blockId: 'title', setText: 'New title');
      expect(editResult, isNotNull);

      final after = await container.read(
        objectBlocksProvider(created.objectId).future,
      );
      expect(
        after!.blocks.singleWhere((b) => b.id == 'title').text,
        'New title',
      );

      final session = await container.read(sessionProvider.future);
      final objects = await container.read(
        objectsProvider(session!.identity.spaceId).future,
      );
      expect(
        objects.singleWhere((object) => object.id == created.objectId).name,
        'New title',
      );
    },
  );

  test('concurrent local edits are applied in request order', () async {
    final created = await container
        .read(objectsControllerProvider)
        .create('Original title');
    final controller = container.read(objectsControllerProvider);

    final first = controller.editBlock(
      created!.objectId,
      blockId: 'title',
      setText: 'First title',
    );
    final second = controller.editBlock(
      created.objectId,
      blockId: 'title',
      setText: 'Final title',
    );
    await Future.wait(<Future<Object?>>[first, second]);

    final blocks = await container.read(
      objectBlocksProvider(created.objectId).future,
    );
    expect(
      blocks!.blocks.singleWhere((block) => block.id == 'title').text,
      'Final title',
    );
  });

  test('a local object mutation dirties a previously synced account', () async {
    final accountId = await container.read(currentAccountIdProvider.future);
    final session = await container.read(sessionProvider.future);
    final provider = syncControllerProvider(accountId!);
    final sync = container.read(provider.notifier);
    sync.updateNetworkConfig('''
id: local
networkId: local-net
nodes:
  - peerId: coordinator
    addresses:
      - quic://127.0.0.1:1014
    types:
      - coordinator
''');
    await sync.sync(spaceId: session!.identity.spaceId);
    expect(container.read(provider).status, SyncUiStatus.syncSucceeded);

    await container.read(objectsControllerProvider).create('Local change');

    expect(container.read(provider).status, SyncUiStatus.localChangesPending);
  });

  test('editBlock toggles a checkbox block\'s checked state', () async {
    final created = await container
        .read(objectsControllerProvider)
        .create('Buy milk', kind: NewObjectKind.checkbox);
    expect(created, isNotNull);

    final before = await container.read(
      objectBlocksProvider(created!.objectId).future,
    );
    final checkboxId = before!.blocks
        .singleWhere((b) => b.style == Block_Content_Text_Style.Checkbox)
        .id;
    expect(
      before.blocks.singleWhere((b) => b.id == checkboxId).checked,
      isFalse,
    );

    await container
        .read(objectsControllerProvider)
        .editBlock(created.objectId, blockId: checkboxId, setChecked: true);

    final after = await container.read(
      objectBlocksProvider(created.objectId).future,
    );
    expect(
      after!.blocks.singleWhere((b) => b.id == checkboxId).checked,
      isTrue,
    );
  });

  test(
    'insertBlock appends a new checkbox block after existing content',
    () async {
      final created = await container
          .read(objectsControllerProvider)
          .create('Original title');
      expect(created, isNotNull);

      final before = await container.read(
        objectBlocksProvider(created!.objectId).future,
      );
      final beforeCount = before!.blocks.length;

      final inserted = await container
          .read(objectsControllerProvider)
          .insertBlock(
            created.objectId,
            text: 'Buy milk',
            kind: NewBlockKind.checkbox,
          );
      expect(inserted, isNotNull);

      final after = await container.read(
        objectBlocksProvider(created.objectId).future,
      );
      expect(after!.blocks.length, beforeCount + 1);
      final newBlock = after.blocks.singleWhere(
        (b) => b.id == inserted!.blockId,
      );
      expect(newBlock.style, Block_Content_Text_Style.Checkbox);
      expect(newBlock.text, 'Buy milk');
      expect(newBlock.checked, isFalse);
    },
  );

  test('demo template seeds real editable content once per account', () async {
    final controller = container.read(objectsControllerProvider);
    final objectId = await controller.seedDemoTemplate();
    expect(objectId, isNotNull);

    final blocks = await container.read(objectBlocksProvider(objectId!).future);
    expect(
      blocks!.blocks.singleWhere((block) => block.id == 'title').text,
      demoTemplatePageTitle,
    );
    expect(
      blocks.blocks.any((block) => block.text == demoTemplateIntroText),
      isTrue,
    );
    final templateTask = blocks.blocks.singleWhere(
      (block) => block.text == demoTemplateTaskText,
    );
    expect(templateTask.style, Block_Content_Text_Style.Checkbox);
    expect(templateTask.checked, isFalse);
    final session = await container.read(sessionProvider.future);
    final pages = objectsForSection(
      await container.read(objectsProvider(session!.identity.spaceId).future),
      LibrarySection.pages,
    );
    expect(pages.map((page) => page.id), contains(objectId));

    final relations = await container.read(
      objectRelationsProvider(objectId).future,
    );
    expect(
      relations!.relations.map((relation) => relation.key),
      isNot(contains(demoTemplateMarkerKey)),
    );

    await controller.editBlock(
      objectId,
      blockId: 'title',
      setText: 'Renamed demo page',
    );

    final secondObjectId = await controller.seedDemoTemplate();
    expect(secondObjectId, objectId);
    final objects = await container.read(
      objectsProvider(session.identity.spaceId).future,
    );
    expect(
      objects
          .where(
            (object) =>
                object.details[demoTemplateMarkerKey] ==
                demoTemplateMarkerValue,
          )
          .map((object) => object.id),
      [objectId],
    );
  });

  test(
    'demo template repairs a committed partial seed before marking complete',
    () async {
      final session = await container.read(sessionProvider.future);
      var insertCalls = 0;
      final isolated = ProviderContainer(
        overrides: <Override>[
          sessionProvider.overrideWith((ref) async => session),
          demoTemplateBlockInserterProvider.overrideWithValue((
            openSession,
            objectId, {
            required text,
            required kind,
          }) async {
            final result = await insertBlockOffline(
              objectId,
              openSession.db,
              openSession.config,
              text: text,
              kind: kind,
              identityOverride: openSession.identity,
            );
            insertCalls++;
            if (insertCalls == 1) {
              throw StateError('injected failure after committed insert');
            }
            return result;
          }),
        ],
      );
      addTearDown(isolated.dispose);
      final controller = isolated.read(objectsControllerProvider);

      await expectLater(controller.seedDemoTemplate(), throwsStateError);

      final afterFailure = await listCommand(
        session!.db,
        session.config,
        identityOverride: session.identity,
      );
      final partial = afterFailure.singleWhere(
        (object) => object.displayName == demoTemplatePageTitle,
      );
      expect(partial.details[demoTemplateMarkerKey], isNull);

      final repairedId = await controller.seedDemoTemplate();
      expect(repairedId, partial.id);
      final repaired = await isolated.read(
        objectBlocksProvider(repairedId!).future,
      );
      expect(
        repaired!.blocks.where(
          (block) =>
              block.style == Block_Content_Text_Style.Paragraph &&
              block.text == demoTemplateIntroText,
        ),
        hasLength(1),
      );
      expect(
        repaired.blocks.where(
          (block) =>
              block.style == Block_Content_Text_Style.Checkbox &&
              block.text == demoTemplateTaskText,
        ),
        hasLength(1),
      );

      final completed = await listCommand(
        session.db,
        session.config,
        identityOverride: session.identity,
      );
      expect(
        completed
            .singleWhere((object) => object.id == repairedId)
            .details[demoTemplateMarkerKey],
        demoTemplateMarkerValue,
      );

      expect(await controller.seedDemoTemplate(), repairedId);
      expect(insertCalls, 2, reason: 'a completed retry must not add blocks');
    },
  );

  test(
    'demo seeding reuses the open identity and does not await list refresh',
    () async {
      final openSession = await container.read(sessionProvider.future);
      final identity = openSession!.identity;
      final session = ManytypeSession(
        db: openSession.db,
        config: CliConfig(
          mnemonic: 'invalid mnemonic proves no hidden re-derivation',
          serverAddress: '127.0.0.1:0',
        ),
        identity: identity,
      );
      final stalledObjects = Completer<List<ObjectMeta>>();
      final isolated = ProviderContainer(
        overrides: <Override>[
          sessionProvider.overrideWith((ref) async => session),
          objectsProvider.overrideWith((ref, spaceId) => stalledObjects.future),
        ],
      );
      addTearDown(() async {
        isolated.dispose();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });

      final objectId = await isolated
          .read(objectsControllerProvider)
          .seedDemoTemplate()
          .timeout(const Duration(seconds: 5));

      expect(objectId, isNotNull);
      final objects = await listCommand(
        session.db,
        session.config,
        identityOverride: identity,
      );
      expect(objects.map((object) => object.id), contains(objectId));
    },
  );

  test(
    'editRelation writes a string relation value visible in the detail report',
    () async {
      final created = await container
          .read(objectsControllerProvider)
          .create('Original title');
      expect(created, isNotNull);

      final result = await container
          .read(objectsControllerProvider)
          .editRelation(
            created!.objectId,
            relationKey: 'description',
            stringValue: 'A relation value',
          );
      expect(result, isNotNull);
      expect(result!.relationKey, 'description');

      final detail = await container.read(
        objectDetailProvider(created.objectId).future,
      );
      expect(
        detail!.lines.any((line) => line.contains('A relation value')),
        isTrue,
      );
    },
  );

  test(
    'objectRelationsProvider exposes a string relation value written via editRelation',
    () async {
      final created = await container
          .read(objectsControllerProvider)
          .create('Original title');
      expect(created, isNotNull);

      await container
          .read(objectsControllerProvider)
          .editRelation(
            created!.objectId,
            relationKey: 'description',
            stringValue: 'A relation value',
          );

      final relations = await container.read(
        objectRelationsProvider(created.objectId).future,
      );
      final view = relations!.relations.singleWhere(
        (r) => r.key == 'description',
      );
      expect(view.stringValue, 'A relation value');
    },
  );

  test('editRelation returns null when no session is open', () async {
    container.dispose();
    final freshBase = await Directory.systemTemp.createTemp(
      'manytype_app_test_nosession_relation',
    );
    AccountRegistry.testBaseDirOverride = freshBase.path;
    final freshContainer = ProviderContainer();
    try {
      final result = await freshContainer
          .read(objectsControllerProvider)
          .editRelation(
            'missing-object',
            relationKey: 'description',
            stringValue: 'x',
          );
      expect(result, isNull);
    } finally {
      freshContainer.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await freshBase.delete(recursive: true);
    }
  });

  test('insertBlock returns null when no session is open', () async {
    container.dispose();
    final freshBase = await Directory.systemTemp.createTemp(
      'manytype_app_test_nosession_insert',
    );
    AccountRegistry.testBaseDirOverride = freshBase.path;
    final freshContainer = ProviderContainer();
    try {
      final result = await freshContainer
          .read(objectsControllerProvider)
          .insertBlock('missing-object', text: 'x');
      expect(result, isNull);
    } finally {
      freshContainer.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await freshBase.delete(recursive: true);
    }
  });

  test('editBlock returns null when no session is open', () async {
    container.dispose();
    // A fresh temp dir with no account registered yet: sessionProvider
    // resolves to null (pre-onboarding), matching editBlock's documented
    // null-session contract.
    final freshBase = await Directory.systemTemp.createTemp(
      'manytype_app_test_nosession',
    );
    AccountRegistry.testBaseDirOverride = freshBase.path;
    final freshContainer = ProviderContainer();
    try {
      final result = await freshContainer
          .read(objectsControllerProvider)
          .editBlock('missing-object', blockId: 'title', setText: 'x');
      expect(result, isNull);
    } finally {
      freshContainer.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await freshBase.delete(recursive: true);
    }
  });
}
