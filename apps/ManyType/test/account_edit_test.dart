@TestOn('vm')
library;

// Runtime proof for AccountsController.rename/updateServerAddress: drives
// account creation, rename, and server-address edit through the app's
// riverpod providers against the real registry/config in a temp dir, no UI
// involved. Mirrors data_layer_test.dart's isolation pattern.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/src/account_registry.dart';

import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/session_provider.dart';

const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  late Directory tempBase;
  late ProviderContainer container;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp('manytype_account_edit_test');
    AccountRegistry.testBaseDirOverride = tempBase.path;
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    AccountRegistry.testBaseDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  test('rename updates the display name surfaced by currentAccountProvider',
      () async {
    final profile = await container
        .read(accountsControllerProvider)
        .createAndSelect(mnemonic: _testMnemonic, displayName: 'Work');

    await container.read(accountsControllerProvider).rename(profile.id, 'Personal');

    final current = await container.read(currentAccountProvider.future);
    expect(current, isNotNull);
    expect(current!.displayName, 'Personal');
  });

  test('updateServerAddress changes the address the session reopens with',
      () async {
    final profile = await container
        .read(accountsControllerProvider)
        .createAndSelect(mnemonic: _testMnemonic, displayName: 'Work');

    final before = await container.read(sessionProvider.future);
    expect(before!.config.serverAddress, '127.0.0.1:33020');

    await container
        .read(accountsControllerProvider)
        .updateServerAddress(profile.id, '10.0.0.5:33020');

    final after = await container.read(sessionProvider.future);
    expect(after!.config.serverAddress, '10.0.0.5:33020');
  });
}
