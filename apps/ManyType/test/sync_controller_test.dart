@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/store/database_native.dart'
    show openDatabaseForTesting;

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
  late ManytypeSession session;

  setUp(() async {
    session = ManytypeSession(
      db: ManytypeDatabase.forTesting(await openDatabaseForTesting()),
      config: CliConfig(mnemonic: _testMnemonic, serverAddress: '127.0.0.1:0'),
      identity: await Identity.fromMnemonic(_testMnemonic),
    );
  });

  tearDown(() => session.close());

  ProviderContainer buildContainer({
    ManyTypeProbeRunner? probeRunner,
    ManyTypeSyncRunner? syncRunner,
  }) {
    return ProviderContainer(
      overrides: <Override>[
        sessionProvider.overrideWith((ref) async => session),
        if (probeRunner != null)
          syncProbeRunnerProvider.overrideWithValue(probeRunner),
        if (syncRunner != null)
          syncRunnerProvider.overrideWithValue(syncRunner),
      ],
    );
  }

  test('valid network config becomes ready with parsed summary', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    container
        .read(syncControllerProvider.notifier)
        .updateNetworkConfig(_networkConfig);

    final state = container.read(syncControllerProvider);
    expect(state.status, SyncUiStatus.ready);
    expect(state.validationError, isNull);
    expect(state.canRun, isTrue);
    expect(state.configSummary?.networkId, 'local-net');
    expect(state.configSummary?.coordinatorAddress, '127.0.0.1:1014');
  });

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
        .read(syncControllerProvider.notifier)
        .useSelfHostedConfig(
          coordinatorAddress: '127.0.0.1:33020',
          peerId: 'peer-local',
          networkId: 'home-net',
        );

    final state = container.read(syncControllerProvider);
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
        .read(syncControllerProvider.notifier)
        .updateNetworkConfig('id: missing-nodes');

    final state = container.read(syncControllerProvider);
    expect(state.status, SyncUiStatus.failed);
    expect(state.canRun, isFalse);
    expect(state.validationError, contains('missing nodes'));
  });

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

      final controller = container.read(syncControllerProvider.notifier);
      controller.updateNetworkConfig(_networkConfig);
      await controller.probe();

      final state = container.read(syncControllerProvider);
      expect(receivedConfig, _networkConfig.trim());
      expect(state.status, SyncUiStatus.probeSucceeded);
      expect(state.configSummary?.networkId, 'live-net');
      expect(state.message, contains('3 nodes'));
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

    final controller = container.read(syncControllerProvider.notifier);
    controller.updateNetworkConfig(_networkConfig);
    await controller.sync(spaceId: 'space-id');

    final state = container.read(syncControllerProvider);
    expect(receivedConfig, _networkConfig.trim());
    expect(state.status, SyncUiStatus.syncSucceeded);
    expect(state.message, contains('Sync completed'));
  });
}
