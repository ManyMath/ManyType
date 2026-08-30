@TestOn('vm')
library;

// Runtime proof for the app's data layer: drives account creation, session
// open, and the create/list/read round trip through the app's riverpod
// providers against the real core (native Drift/sqlite store in a temp
// dir), no UI involved. Mirrors manytype_cli's temp-dir isolation via
// AccountRegistry.testBaseDirOverride.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart' show CliConfig;
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
    CliConfig.testConfigDirOverride = tempBase.path;
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    // sessionProvider's onDispose closes the db asynchronously; give it a
    // beat before tearing the directory down (unlink-while-open is fine on
    // unix, this just avoids noisy late writes).
    await Future<void>.delayed(const Duration(milliseconds: 100));
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  test('account + object round trip through the providers', () async {
    expect(await container.read(accountsProvider.future), isEmpty);
    expect(await container.read(currentAccountIdProvider.future), isNull);

    final profile = await container
        .read(accountsControllerProvider)
        .createAndSelect(mnemonic: _testMnemonic, displayName: 'Test');

    expect(await container.read(currentAccountIdProvider.future), profile.id);
    final summaries = await container.read(accountsProvider.future);
    expect(summaries.map((a) => a.id), contains(profile.id));

    final session = await container.read(sessionProvider.future);
    expect(session, isNotNull);
    final spaceId = session!.identity.spaceId;
    expect(await container.read(personalSpaceIdProvider.future), spaceId);

    // Objects list starts empty.
    expect(await container.read(objectsProvider(spaceId).future), isEmpty);

    // Create offline through the controller (real createCommand).
    final created = await container
        .read(objectsControllerProvider)
        .create('Hello from ManyType');
    expect(created, isNotNull);
    expect(created!.spaceId, spaceId);

    // The controller invalidated the family; re-read lists the object.
    final metas = await container.read(objectsProvider(spaceId).future);
    expect(metas, hasLength(1));
    expect(metas.single.id, created.objectId);

    // Detail replay contains the text.
    final detail = await container.read(
      objectDetailProvider(created.objectId).future,
    );
    expect(detail, isNotNull);
    expect(detail!.notFound, isFalse);
    expect(detail.lines.join('\n'), contains('Hello from ManyType'));

    // Delete offline through the controller (real deleteOffline, no
    // network): the object drops out of the list.
    final deleteResult = await container
        .read(objectsControllerProvider)
        .delete(created.objectId, spaceId);
    expect(deleteResult, isNotNull);
    expect(deleteResult!.objectId, created.objectId);

    final metasAfterDelete = await container.read(
      objectsProvider(spaceId).future,
    );
    expect(
      metasAfterDelete.map((m) => m.id),
      isNot(contains(created.objectId)),
    );
  });

  test('reload resumes and completes a pending starter template', () async {
    final profile = await container
        .read(accountsControllerProvider)
        .createAndSelectIfNew(
          mnemonic: _testMnemonic,
          displayName: 'Demo workspace',
          pendingStarterTemplate: true,
        );
    expect(profile, isNotNull);
    expect(
      (await AccountRegistry.listAccounts()).single.pendingStarterTemplate,
      isTrue,
    );

    // A new provider container models a browser reload: in-memory demo UI
    // state is gone, while the registry marker and current account remain.
    container.dispose();
    container = ProviderContainer();

    final objectId = await container.read(
      starterTemplateRecoveryProvider(profile!.id).future,
    );

    expect(objectId, isNotNull);
    expect(
      (await AccountRegistry.listAccounts()).single.pendingStarterTemplate,
      isFalse,
    );
    final session = await container.read(sessionProvider.future);
    final objects = await container.read(
      objectsProvider(session!.identity.spaceId).future,
    );
    expect(objects.map((object) => object.id), contains(objectId));
  });
}
