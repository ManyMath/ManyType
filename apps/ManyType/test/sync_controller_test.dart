@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/store/database_native.dart'
    show openDatabaseForTesting;

import 'package:manytype/src/state/session_provider.dart';
import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/objects_providers.dart';
import 'package:manytype/src/state/sync_controller.dart';

const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

const _accountId = 'account-a';

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
  late ManytypeSession session;
  late _MemorySyncMetadataStore metadataStore;
  late DateTime now;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp('manytype_sync_test');
    AccountRegistry.testBaseDirOverride = tempBase.path;
    CliConfig.testConfigDirOverride = tempBase.path;
    metadataStore = _MemorySyncMetadataStore();
    now = DateTime.utc(2026, 7, 13, 18, 30);
    session = ManytypeSession(
      db: ManytypeDatabase.forTesting(await openDatabaseForTesting()),
      config: CliConfig(mnemonic: _testMnemonic, serverAddress: '127.0.0.1:0'),
      identity: await Identity.fromMnemonic(_testMnemonic),
    );
  });

  tearDown(() async {
    await session.close();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  ProviderContainer buildContainer({
    ManyTypeProbeRunner? probeRunner,
    ManyTypeSyncRunner? syncRunner,
  }) {
    return ProviderContainer(
      overrides: <Override>[
        sessionProvider.overrideWith((ref) async => session),
        currentAccountIdProvider.overrideWith((ref) async => _accountId),
        syncMetadataStoreProvider.overrideWithValue(metadataStore),
        syncClockProvider.overrideWithValue(() => now),
        if (probeRunner != null)
          syncProbeRunnerProvider.overrideWithValue(probeRunner),
        if (syncRunner != null)
          syncRunnerProvider.overrideWithValue(syncRunner),
      ],
    );
  }

  test('new account sync state is unconfigured and account-scoped', () async {
    final container = buildContainer(syncRunner: (_, __) async {});
    addTearDown(container.dispose);
    final firstProvider = syncControllerProvider('first-account');
    final secondProvider = syncControllerProvider('second-account');

    expect(container.read(firstProvider).status, SyncUiStatus.unconfigured);
    expect(container.read(firstProvider).networkConfigContent, isEmpty);
    expect(container.read(firstProvider).canRun, isFalse);

    final firstController = container.read(firstProvider.notifier);
    firstController.updateNetworkConfig(_networkConfig);
    await firstController.sync(spaceId: session.identity.spaceId);
    expect(container.read(firstProvider).status, SyncUiStatus.syncSucceeded);

    final secondState = container.read(secondProvider);
    expect(secondState.status, SyncUiStatus.unconfigured);
    expect(secondState.networkConfigContent, isEmpty);
    expect(secondState.configSummary, isNull);
    expect(secondState.canRun, isFalse);
  });

  test(
    'valid network config becomes configured without claiming reachability',
    () async {
      final container = buildContainer();
      addTearDown(container.dispose);

      container
          .read(syncControllerProvider(_accountId).notifier)
          .updateNetworkConfig(_networkConfig);

      final state = container.read(syncControllerProvider(_accountId));
      expect(state.status, SyncUiStatus.ready);
      expect(state.validationError, isNull);
      expect(state.canRun, isTrue);
      expect(state.configSummary?.networkId, 'local-net');
      expect(state.configSummary?.coordinatorAddress, '127.0.0.1:1014');
      expect(state.message, contains('Probe the coordinator'));
      expect(state.message, isNot(contains('is ready')));
      expect(state.configuredAt, now);
      expect(state.lastProbeAt, isNull);
      expect(state.lastSuccessfulSyncAt, isNull);
      await container
          .read(syncControllerProvider(_accountId).notifier)
          .flushPersistence();
      expect(metadataStore.values[_accountId]?.configuredAt, now);
    },
  );

  test('buildSelfHostedNetworkConfig creates parseable single-node config', () {
    final content = buildSelfHostedNetworkConfig(
      coordinatorAddress: 'quic://127.0.0.1:33020',
      peerId: 'peer-local',
      networkId: 'home-net',
      configId: 'home',
    );

    final config = parseNetworkConfig(content);
    final coordinator = requireCoordinatorNode(config);

    expect(config.id, 'home');
    expect(config.networkId, 'home-net');
    expect(coordinator.peerId, 'peer-local');
    expect(chooseBestAddress(coordinator.addresses), '127.0.0.1:33020');
    expect(
      coordinator.types,
      containsAll(<String>['coordinator', 'tree', 'file', 'consensus']),
    );
  });

  test('buildSelfHostedDockerStartCommand creates make-start script', () {
    final command = buildSelfHostedDockerStartCommand(
      externalListenHosts: '192.168.1.10',
    );

    expect(command, contains('cd docker/any-sync'));
    expect(command, contains('EXTERNAL_LISTEN_HOSTS="192.168.1.10"'));
    expect(command, contains('make start'));
  });

  test('buildSelfHostedDockerStartCommand escapes env value', () {
    final command = buildSelfHostedDockerStartCommand(
      externalListenHosts: r'host"$name\path',
    );

    expect(command, contains(r'EXTERNAL_LISTEN_HOSTS="host\"\$name\\path"'));
  });

  test('buildSelfHostedDockerStartCommand rejects multiline host list', () {
    expect(
      () => buildSelfHostedDockerStartCommand(
        externalListenHosts: '127.0.0.1\n192.168.1.10',
      ),
      throwsStateError,
    );
  });

  test('useSelfHostedConfig fills state with generated config', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final generated = container
        .read(syncControllerProvider(_accountId).notifier)
        .useSelfHostedConfig(
          coordinatorAddress: '127.0.0.1:33020',
          peerId: 'peer-local',
          networkId: 'home-net',
        );

    final state = container.read(syncControllerProvider(_accountId));
    expect(state.networkConfigContent, generated);
    expect(state.status, SyncUiStatus.ready);
    expect(state.validationError, isNull);
    expect(state.configSummary?.networkId, 'home-net');
    expect(state.configSummary?.coordinatorAddress, '127.0.0.1:33020');
  });

  test('buildSelfHostedNetworkConfig rejects missing peer id', () {
    expect(
      () => buildSelfHostedNetworkConfig(
        coordinatorAddress: '127.0.0.1:33020',
        peerId: '',
      ),
      throwsStateError,
    );
  });

  test('invalid network config reports a validation error', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    container
        .read(syncControllerProvider(_accountId).notifier)
        .updateNetworkConfig('id: missing-nodes');

    final state = container.read(syncControllerProvider(_accountId));
    expect(state.status, SyncUiStatus.failed);
    expect(state.canRun, isFalse);
    expect(state.validationError, contains('missing nodes'));
  });

  test(
    'valid config and sync facts restore per account after restart',
    () async {
      final firstContainer = buildContainer(syncRunner: (_, __) async {});
      final firstProvider = syncControllerProvider('first-account');
      final first = firstContainer.read(firstProvider.notifier);
      first.updateNetworkConfig(_networkConfig);
      await first.sync(spaceId: 'space-id');
      await first.flushPersistence();
      firstContainer.dispose();

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);
      final restoredProvider = syncControllerProvider('first-account');
      final restoredController = restoredContainer.read(
        restoredProvider.notifier,
      );
      await restoredController.initialized;
      final restored = restoredContainer.read(restoredProvider);

      expect(restored.status, SyncUiStatus.syncSucceeded);
      expect(restored.networkConfigContent, _networkConfig);
      expect(restored.configuredAt, now);
      expect(restored.lastSuccessfulSyncAt, now);
      expect(restored.lastProbeAt, isNull);

      final unrelatedProvider = syncControllerProvider('second-account');
      await restoredContainer.read(unrelatedProvider.notifier).initialized;
      final unrelated = restoredContainer.read(unrelatedProvider);
      expect(unrelated.status, SyncUiStatus.unconfigured);
      expect(unrelated.networkConfigContent, isEmpty);
      expect(unrelated.lastSuccessfulSyncAt, isNull);
    },
  );

  test(
    'a local edit remains pending while sync is unconfigured after restart',
    () async {
      final firstContainer = buildContainer();
      final provider = syncControllerProvider(_accountId);
      final first = firstContainer.read(provider.notifier);
      await first.markLocalChangesPending();
      await first.flushPersistence();

      expect(firstContainer.read(provider).status, SyncUiStatus.unconfigured);
      expect(firstContainer.read(provider).pendingLocalChanges, isTrue);
      firstContainer.dispose();

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);
      final restoredProvider = syncControllerProvider(_accountId);
      await restoredContainer.read(restoredProvider.notifier).initialized;
      final restored = restoredContainer.read(restoredProvider);
      expect(restored.status, SyncUiStatus.unconfigured);
      expect(restored.networkConfigContent, isEmpty);
      expect(restored.pendingLocalChanges, isTrue);
      expect(restored.lastSuccessfulSyncAt, isNull);
    },
  );

  test(
    'edit completion waits for a durable pending marker before restart',
    () async {
      final firstContainer = buildContainer();
      final provider = syncControllerProvider(_accountId);
      final controller = firstContainer.read(provider.notifier);
      await controller.initialized;
      final created = await createCommand(
        'Before edit',
        session.db,
        session.config,
      );
      final saveGate = Completer<void>();
      metadataStore.blockNextSave = saveGate;

      var editCompleted = false;
      final editCompletion = firstContainer
          .read(objectsControllerProvider)
          .editBlock(created.objectId, blockId: 'title', setText: 'After edit')
          .then((_) {
            editCompleted = true;
          });
      await metadataStore.nextSaveStarted.future;

      expect(editCompleted, isFalse);
      expect(
        metadataStore.values[_accountId]?.pendingLocalChanges,
        isNot(isTrue),
      );
      expect(firstContainer.read(provider).pendingLocalChanges, isTrue);
      final blockedBlocks = await replayObjectBlocks(
        session.db,
        session.config,
        created.objectId,
      );
      expect(
        blockedBlocks!.blocks.singleWhere((block) => block.id == 'title').text,
        'Before edit',
      );

      saveGate.complete();
      await editCompletion;
      expect(editCompleted, isTrue);
      expect(metadataStore.values[_accountId]?.pendingLocalChanges, isTrue);
      final editedBlocks = await replayObjectBlocks(
        session.db,
        session.config,
        created.objectId,
      );
      expect(
        editedBlocks!.blocks.singleWhere((block) => block.id == 'title').text,
        'After edit',
      );
      firstContainer.dispose();

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);
      final restoredProvider = syncControllerProvider(_accountId);
      await restoredContainer.read(restoredProvider.notifier).initialized;
      expect(
        restoredContainer.read(restoredProvider).pendingLocalChanges,
        isTrue,
      );
    },
  );

  test(
    'invalid edits do not replace the last durable valid configuration',
    () async {
      final firstContainer = buildContainer();
      final provider = syncControllerProvider(_accountId);
      final first = firstContainer.read(provider.notifier);
      first.updateNetworkConfig(_networkConfig);
      await first.flushPersistence();
      first.updateNetworkConfig('id: missing-nodes');
      await first.flushPersistence();
      expect(firstContainer.read(provider).validationError, isNotNull);
      firstContainer.dispose();

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);
      final restoredProvider = syncControllerProvider(_accountId);
      await restoredContainer.read(restoredProvider.notifier).initialized;
      final restored = restoredContainer.read(restoredProvider);
      expect(restored.status, SyncUiStatus.ready);
      expect(restored.networkConfigContent, _networkConfig);
      expect(restored.validationError, isNull);
    },
  );

  test(
    'probe uses the configured runner and reports coordinator response',
    () async {
      String? receivedConfig;
      final container = buildContainer(
        probeRunner: (session, networkConfigContent) async {
          receivedConfig = networkConfigContent;
          return const NetworkProbeResult(
            coordinatorAddress: '127.0.0.1:1014',
            networkId: 'live-net',
            configurationId: 'cfg-1',
            nodeCount: 3,
          );
        },
      );
      addTearDown(container.dispose);

      final controller = container.read(
        syncControllerProvider(_accountId).notifier,
      );
      controller.updateNetworkConfig(_networkConfig);
      await controller.probe();

      final state = container.read(syncControllerProvider(_accountId));
      expect(receivedConfig, _networkConfig.trim());
      expect(state.status, SyncUiStatus.probeSucceeded);
      expect(state.configSummary?.networkId, 'live-net');
      expect(state.message, contains('3 nodes'));
      expect(state.lastProbeAt, now);
      expect(state.lastSuccessfulSyncAt, isNull);
      expect(metadataStore.values[_accountId]?.lastProbeAt, now);
      expect(metadataStore.values[_accountId]?.lastSuccessfulSyncAt, isNull);
    },
  );

  test('sync uses the configured runner and reports completion', () async {
    String? receivedConfig;
    final container = buildContainer(
      syncRunner: (session, networkConfigContent) async {
        receivedConfig = networkConfigContent;
      },
    );
    addTearDown(container.dispose);

    final controller = container.read(
      syncControllerProvider(_accountId).notifier,
    );
    controller.updateNetworkConfig(_networkConfig);
    await controller.sync(spaceId: 'space-id');

    final state = container.read(syncControllerProvider(_accountId));
    expect(receivedConfig, _networkConfig.trim());
    expect(state.status, SyncUiStatus.syncSucceeded);
    expect(state.message, contains('Sync completed'));
    expect(state.lastSuccessfulSyncAt, now);
    expect(state.pendingLocalChanges, isFalse);
  });

  test('re-applying the current config keeps its sync results', () async {
    final container = buildContainer(syncRunner: (_, __) async {});
    addTearDown(container.dispose);
    final provider = syncControllerProvider(_accountId);
    final controller = container.read(provider.notifier);
    controller.updateNetworkConfig(_networkConfig);
    await controller.sync(spaceId: 'space-id');
    final configuredAt = container.read(provider).configuredAt;
    final syncedAt = container.read(provider).lastSuccessfulSyncAt;
    expect(syncedAt, isNotNull);
    now = now.add(const Duration(minutes: 5));

    controller.updateNetworkConfig('$_networkConfig\n');
    await controller.flushPersistence();

    final state = container.read(provider);
    expect(state.status, SyncUiStatus.syncSucceeded);
    expect(state.message, contains('Sync completed'));
    expect(state.configuredAt, configuredAt);
    expect(state.lastSuccessfulSyncAt, syncedAt);
    expect(
      metadataStore.values[_accountId]?.networkConfigContent,
      '$_networkConfig\n',
    );
    expect(metadataStore.values[_accountId]?.lastSuccessfulSyncAt, syncedAt);
  });

  test(
    'failed sync preserves config, pending state, and prior success time',
    () async {
      var fail = false;
      final container = buildContainer(
        syncRunner: (_, __) async {
          if (fail) throw StateError('coordinator unavailable');
        },
      );
      addTearDown(container.dispose);
      final provider = syncControllerProvider(_accountId);
      final controller = container.read(provider.notifier);
      controller.updateNetworkConfig(_networkConfig);
      await controller.markLocalChangesPending();
      await controller.sync(spaceId: 'space-id');
      final successfulAt = container.read(provider).lastSuccessfulSyncAt;
      expect(successfulAt, now);

      await controller.markLocalChangesPending();
      fail = true;
      now = now.add(const Duration(minutes: 15));
      await controller.sync(spaceId: 'space-id');

      final failed = container.read(provider);
      expect(failed.status, SyncUiStatus.failed);
      expect(failed.networkConfigContent, _networkConfig);
      expect(failed.lastSuccessfulSyncAt, successfulAt);
      expect(failed.pendingLocalChanges, isTrue);
      expect(failed.lastError, contains('coordinator unavailable'));
      final durable = metadataStore.values[_accountId]!;
      expect(durable.networkConfigContent, _networkConfig);
      expect(durable.lastSuccessfulSyncAt, successfulAt);
      expect(durable.pendingLocalChanges, isTrue);
      expect(durable.lastError, contains('coordinator unavailable'));
    },
  );

  test(
    'failed probe records an attempt and error without claiming sync',
    () async {
      final container = buildContainer(
        probeRunner: (_, __) async => throw StateError('no route'),
      );
      addTearDown(container.dispose);
      final provider = syncControllerProvider(_accountId);
      final controller = container.read(provider.notifier);
      controller.updateNetworkConfig(_networkConfig);

      await controller.probe();

      final failed = container.read(provider);
      expect(failed.status, SyncUiStatus.failed);
      expect(failed.lastProbeAt, now);
      expect(failed.lastSuccessfulSyncAt, isNull);
      expect(failed.lastError, contains('no route'));
      expect(metadataStore.values[_accountId]?.lastSuccessfulSyncAt, isNull);
    },
  );

  test(
    'successful probe is not mislabeled when result persistence fails',
    () async {
      final container = buildContainer(
        probeRunner: (_, __) async => const NetworkProbeResult(
          coordinatorAddress: '127.0.0.1:1014',
          networkId: 'live-net',
          configurationId: 'cfg-1',
          nodeCount: 3,
        ),
      );
      addTearDown(container.dispose);
      final provider = syncControllerProvider(_accountId);
      final controller = container.read(provider.notifier);
      controller.updateNetworkConfig(_networkConfig);
      await controller.flushPersistence();
      metadataStore.failNextSave = StateError('disk full');

      await controller.probe();

      final state = container.read(provider);
      expect(state.status, SyncUiStatus.failed);
      expect(state.message, contains('network responded'));
      expect(state.message, isNot(contains('Network probe failed')));
      expect(state.configSummary?.networkId, 'live-net');
      expect(state.lastProbeAt, now);
      expect(state.lastSuccessfulSyncAt, isNull);
      expect(state.lastError, contains('disk full'));
    },
  );

  test(
    'successful sync is not mislabeled when result persistence fails',
    () async {
      final container = buildContainer(syncRunner: (_, __) async {});
      addTearDown(container.dispose);
      final provider = syncControllerProvider(_accountId);
      final controller = container.read(provider.notifier);
      controller.updateNetworkConfig(_networkConfig);
      await controller.flushPersistence();
      await controller.markLocalChangesPending();
      metadataStore.failNextSave = StateError('disk full');

      await controller.sync(spaceId: 'space-id');

      final state = container.read(provider);
      expect(state.status, SyncUiStatus.failed);
      expect(state.message, contains('Sync completed'));
      expect(state.message, isNot(contains('Sync failed')));
      expect(state.lastSuccessfulSyncAt, now);
      expect(state.pendingLocalChanges, isFalse);
      expect(state.lastError, contains('disk full'));
    },
  );

  test(
    'unsupported platform never invokes probe, sync, or session runners',
    () async {
      var probeCalls = 0;
      var syncCalls = 0;
      final container = ProviderContainer(
        overrides: <Override>[
          nativeSyncSupportedProvider.overrideWithValue(false),
          syncMetadataStoreProvider.overrideWithValue(metadataStore),
          syncProbeRunnerProvider.overrideWithValue((_, __) async {
            probeCalls++;
            throw StateError('must not run');
          }),
          syncRunnerProvider.overrideWithValue((_, __) async {
            syncCalls++;
            throw StateError('must not run');
          }),
        ],
      );
      addTearDown(container.dispose);
      final provider = syncControllerProvider(_accountId);
      final controller = container.read(provider.notifier);

      controller.updateNetworkConfig(_networkConfig);
      await controller.probe();
      await controller.sync(spaceId: 'space-id');

      final state = container.read(provider);
      expect(state.status, SyncUiStatus.unsupported);
      expect(state.canRun, isFalse);
      expect(state.message, contains('not available on this platform'));
      expect(probeCalls, 0);
      expect(syncCalls, 0);
      expect(metadataStore.values, isEmpty);
    },
  );

  test('a local write after sync is reported as pending', () async {
    final container = buildContainer(syncRunner: (_, __) async {});
    addTearDown(container.dispose);
    final provider = syncControllerProvider(_accountId);
    final controller = container.read(provider.notifier);

    controller.updateNetworkConfig(_networkConfig);
    await controller.sync(spaceId: 'space-id');
    expect(container.read(provider).status, SyncUiStatus.syncSucceeded);

    await controller.markLocalChangesPending();

    expect(container.read(provider).status, SyncUiStatus.localChangesPending);
    expect(container.read(provider).message, contains('next sync'));
    expect(container.read(provider).pendingLocalChanges, isTrue);
  });

  test('a write made during sync prevents a stale success label', () async {
    final syncStarted = Completer<void>();
    final finishSync = Completer<void>();
    final container = buildContainer(
      syncRunner: (_, __) async {
        syncStarted.complete();
        await finishSync.future;
      },
    );
    addTearDown(container.dispose);
    final provider = syncControllerProvider(_accountId);
    final controller = container.read(provider.notifier);
    controller.updateNetworkConfig(_networkConfig);

    final sync = controller.sync(spaceId: 'space-id');
    await syncStarted.future;
    await controller.markLocalChangesPending();
    finishSync.complete();
    await sync;

    expect(container.read(provider).status, SyncUiStatus.localChangesPending);
    expect(container.read(provider).message, contains('newer local changes'));
    expect(container.read(provider).lastSuccessfulSyncAt, now);
    expect(container.read(provider).pendingLocalChanges, isTrue);
    await controller.flushPersistence();
    expect(metadataStore.values[_accountId]?.lastSuccessfulSyncAt, now);
    expect(metadataStore.values[_accountId]?.pendingLocalChanges, isTrue);
  });

  test(
    'sync refreshes cached blocks, relations, and rendered detail',
    () async {
      final created = await createCommand(
        'Before sync',
        session.db,
        session.config,
      );
      await editRelationOffline(
        created.objectId,
        session.db,
        session.config,
        relationKey: 'description',
        stringValue: 'Before relation',
      );
      final container = buildContainer(
        syncRunner: (openSession, _) async {
          await editOffline(
            created.objectId,
            openSession.db,
            openSession.config,
            blockId: 'title',
            setText: 'After sync',
          );
          await editRelationOffline(
            created.objectId,
            openSession.db,
            openSession.config,
            relationKey: 'description',
            stringValue: 'After relation',
          );
        },
      );
      addTearDown(container.dispose);

      final beforeBlocks = await container.read(
        objectBlocksProvider(created.objectId).future,
      );
      final beforeRelations = await container.read(
        objectRelationsProvider(created.objectId).future,
      );
      final beforeDetail = await container.read(
        objectDetailProvider(created.objectId).future,
      );
      expect(
        beforeBlocks!.blocks.singleWhere((block) => block.id == 'title').text,
        'Before sync',
      );
      expect(beforeRelations!.relations.single.stringValue, 'Before relation');
      expect(beforeDetail!.lines.join('\n'), contains('Before sync'));

      final controller = container.read(
        syncControllerProvider(_accountId).notifier,
      );
      controller.updateNetworkConfig(_networkConfig);
      await controller.sync(spaceId: session.identity.spaceId);

      final afterBlocks = await container.read(
        objectBlocksProvider(created.objectId).future,
      );
      final afterRelations = await container.read(
        objectRelationsProvider(created.objectId).future,
      );
      final afterDetail = await container.read(
        objectDetailProvider(created.objectId).future,
      );
      expect(
        afterBlocks!.blocks.singleWhere((block) => block.id == 'title').text,
        'After sync',
      );
      expect(afterRelations!.relations.single.stringValue, 'After relation');
      expect(afterDetail!.lines.join('\n'), contains('After sync'));
    },
  );
}

class _MemorySyncMetadataStore implements SyncMetadataStore {
  final Map<String, AccountSyncMetadata> values =
      <String, AccountSyncMetadata>{};
  Completer<void>? blockNextSave;
  Completer<void> nextSaveStarted = Completer<void>();
  Object? failNextSave;

  @override
  Future<AccountSyncMetadata> load(String accountId) async {
    return values[accountId] ?? const AccountSyncMetadata();
  }

  @override
  Future<void> save(String accountId, AccountSyncMetadata metadata) async {
    final failure = failNextSave;
    if (failure != null) {
      failNextSave = null;
      throw failure;
    }
    final gate = blockNextSave;
    if (gate != null) {
      blockNextSave = null;
      if (!nextSaveStarted.isCompleted) nextSaveStarted.complete();
      await gate.future;
    }
    values[accountId] = metadata;
  }
}
