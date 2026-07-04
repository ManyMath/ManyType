@TestOn('vm')
library;

// Runtime proof for the type-picker-on-create data layer: drives
// create(kind: NewObjectKind.type) -> spaceTypesProvider ->
// create(assignedType: ...) entirely through ObjectsController (the same
// surface the "New object" card's kind + type pickers call), no UI
// involved. Mirrors object_blocks_editor_test.dart's temp-dir isolation
// via AccountRegistry.testBaseDirOverride.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/src/account_registry.dart';

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

  test(
    'spaceTypesProvider only surfaces STType objects, not plain ones',
    () async {
      final session = await container.read(sessionProvider.future);
      final spaceId = session!.identity.spaceId;
      final controller = container.read(objectsControllerProvider);

      expect(await container.read(spaceTypesProvider(spaceId).future), isEmpty);

      final plainResult = await controller.create('A plain object');
      expect(plainResult, isNotNull);
      // A plain object should NOT show up as a type.
      expect(await container.read(spaceTypesProvider(spaceId).future), isEmpty);

      final typeResult = await controller.create(
        'Project',
        kind: NewObjectKind.type,
      );
      expect(typeResult, isNotNull);
      final types = await container.read(spaceTypesProvider(spaceId).future);
      expect(types.map((t) => t.id), [typeResult!.objectId]);
      expect(types.single.name, 'Project');
    },
  );

  test(
    'create with assignedType bakes an existing STType into objectTypes',
    () async {
      final session = await container.read(sessionProvider.future);
      final spaceId = session!.identity.spaceId;
      final controller = container.read(objectsControllerProvider);

      // Create the STType itself entirely through the app-facing
      // ObjectsController API (kind: NewObjectKind.type), the same path the
      // "New object" card's kind picker now exposes -- not a CLI-only
      // fixture reachable outside the GUI.
      final typeCreate = await controller.create(
        'Project',
        kind: NewObjectKind.type,
      );
      expect(typeCreate, isNotNull);
      final typeId = typeCreate!.objectId;

      final types = await container.read(spaceTypesProvider(spaceId).future);
      expect(types.map((t) => t.id), contains(typeId));

      final objectResult = await controller.create(
        'My project',
        assignedType: typeId,
      );
      expect(objectResult, isNotNull);

      final metas = await container.read(objectsProvider(spaceId).future);
      final created = metas.singleWhere((m) => m.id == objectResult!.objectId);
      expect(created.types, ['project']);
    },
  );
}
