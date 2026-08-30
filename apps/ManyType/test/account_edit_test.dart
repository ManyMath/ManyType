@TestOn('vm')
library;

// Runtime proof for AccountsController.rename/updateServerAddress: drives
// account creation, rename, and server-address edit through the app's
// riverpod providers against the real registry/config in a temp dir, no UI
// involved. Mirrors data_layer_test.dart's isolation pattern.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart' show CliConfig;
import 'package:manytype_cli/src/account_registry.dart';

import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/session_provider.dart';
import 'package:manytype/src/state/sync_controller.dart';

const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

const _networkConfig = '''
id: local
networkId: local-net
nodes:
  - peerId: coordinator
    addresses:
      - quic://127.0.0.1:1014
    types:
      - coordinator
''';

void main() {
  late Directory tempBase;
  late ProviderContainer container;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp(
      'manytype_account_edit_test',
    );
    AccountRegistry.testBaseDirOverride = tempBase.path;
    CliConfig.testConfigDirOverride = tempBase.path;
    container = ProviderContainer(
      overrides: <Override>[
        syncRunnerProvider.overrideWithValue((_, __) async {}),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  test(
    'rename updates the display name surfaced by currentAccountProvider',
    () async {
      final profile = await container
          .read(accountsControllerProvider)
          .createAndSelect(mnemonic: _testMnemonic, displayName: 'Work');

      await container
          .read(accountsControllerProvider)
          .rename(profile.id, 'Personal');

      final current = await container.read(currentAccountProvider.future);
      expect(current, isNotNull);
      expect(current!.displayName, 'Personal');
    },
  );

  test(
    'updateServerAddress changes the address the session reopens with',
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
    },
  );

  test(
    'forget and reimport resets sync state for the reused account id',
    () async {
      final accounts = container.read(accountsControllerProvider);
      final profile = await accounts.createAndSelect(
        mnemonic: _testMnemonic,
        displayName: 'Work',
      );
      final session = await container.read(sessionProvider.future);

      final sync = container.read(syncControllerProvider(profile.id).notifier);
      sync.updateNetworkConfig(_networkConfig);
      await sync.sync(spaceId: session!.identity.spaceId);
      expect(
        container.read(syncControllerProvider(profile.id)).status,
        SyncUiStatus.syncSucceeded,
      );

      await accounts.forget(profile.id);
      expect(await container.read(currentAccountIdProvider.future), isNull);

      final restored = await accounts.createAndSelect(
        mnemonic: _testMnemonic,
        displayName: 'Restored',
      );
      expect(restored.id, profile.id);
      final restoredSync = container.read(syncControllerProvider(restored.id));
      expect(restoredSync.status, SyncUiStatus.unconfigured);
      expect(restoredSync.networkConfigContent, isEmpty);
      expect(restoredSync.message, isNull);
    },
  );
}
