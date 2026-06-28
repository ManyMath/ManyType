@TestOn('vm')
library;

// Runtime proof for the structured block editor's data layer: drives
// create -> replay -> editBlock -> re-replay through the app's riverpod
// providers against the real core, no UI involved. Mirrors
// data_layer_test.dart's temp-dir isolation via
// AccountRegistry.testBaseDirOverride.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/manytype_cli.dart' show NewBlockKind;
import 'package:manytype_protocol/models.dart' show Block_Content_Text_Style;

import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/objects_providers.dart';

const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  late Directory tempBase;
  late ProviderContainer container;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp('manytype_app_test');
    AccountRegistry.testBaseDirOverride = tempBase.path;
    container = ProviderContainer();
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

  test('objectBlocksProvider exposes the title block, editBlock mutates it',
      () async {
    final created = await container
        .read(objectsControllerProvider)
        .create('Original title');
    expect(created, isNotNull);

    final before =
        await container.read(objectBlocksProvider(created!.objectId).future);
    expect(before, isNotNull);
    final titleBlock = before!.blocks.singleWhere((b) => b.id == 'title');
    expect(titleBlock.text, 'Original title');

    final editResult = await container
        .read(objectsControllerProvider)
        .editBlock(created.objectId, blockId: 'title', setText: 'New title');
    expect(editResult, isNotNull);

    final after =
        await container.read(objectBlocksProvider(created.objectId).future);
    expect(
      after!.blocks.singleWhere((b) => b.id == 'title').text,
      'New title',
    );
  });

  test('editBlock toggles a checkbox block\'s checked state', () async {
    final created = await container
        .read(objectsControllerProvider)
        .create('Buy milk', kind: NewObjectKind.checkbox);
    expect(created, isNotNull);

    final before =
        await container.read(objectBlocksProvider(created!.objectId).future);
    final checkboxId = before!.blocks
        .singleWhere((b) => b.style == Block_Content_Text_Style.Checkbox)
        .id;
    expect(before.blocks.singleWhere((b) => b.id == checkboxId).checked,
        isFalse);

    await container.read(objectsControllerProvider).editBlock(
          created.objectId,
          blockId: checkboxId,
          setChecked: true,
        );

    final after =
        await container.read(objectBlocksProvider(created.objectId).future);
    expect(
      after!.blocks.singleWhere((b) => b.id == checkboxId).checked,
      isTrue,
    );
  });

  test('insertBlock appends a new checkbox block after existing content',
      () async {
    final created = await container
        .read(objectsControllerProvider)
        .create('Original title');
    expect(created, isNotNull);

    final before =
        await container.read(objectBlocksProvider(created!.objectId).future);
    final beforeCount = before!.blocks.length;

    final inserted = await container.read(objectsControllerProvider).insertBlock(
          created.objectId,
          text: 'Buy milk',
          kind: NewBlockKind.checkbox,
        );
    expect(inserted, isNotNull);

    final after =
        await container.read(objectBlocksProvider(created.objectId).future);
    expect(after!.blocks.length, beforeCount + 1);
    final newBlock = after.blocks.singleWhere((b) => b.id == inserted!.blockId);
    expect(newBlock.style, Block_Content_Text_Style.Checkbox);
    expect(newBlock.text, 'Buy milk');
    expect(newBlock.checked, isFalse);
  });

  test('editRelation writes a string relation value visible in the detail report',
      () async {
    final created = await container
        .read(objectsControllerProvider)
        .create('Original title');
    expect(created, isNotNull);

    final result = await container.read(objectsControllerProvider).editRelation(
          created!.objectId,
          relationKey: 'description',
          stringValue: 'A relation value',
        );
    expect(result, isNotNull);
    expect(result!.relationKey, 'description');

    final detail =
        await container.read(objectDetailProvider(created.objectId).future);
    expect(
      detail!.lines.any((line) => line.contains('A relation value')),
      isTrue,
    );
  });

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
