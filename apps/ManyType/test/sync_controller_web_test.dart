@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:manytype/src/state/sync_controller.dart';

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
  test(
    'browser sync is disabled before native runners can be reached',
    () async {
      var probeCalls = 0;
      var syncCalls = 0;
      final container = ProviderContainer(
        overrides: <Override>[
          syncProbeRunnerProvider.overrideWithValue((_, __) async {
            probeCalls++;
            throw StateError('browser must not probe');
          }),
          syncRunnerProvider.overrideWithValue((_, __) async {
            syncCalls++;
            throw StateError('browser must not sync');
          }),
        ],
      );
      addTearDown(container.dispose);
      final provider = syncControllerProvider('browser-account');
      final controller = container.read(provider.notifier);

      controller.updateNetworkConfig(_networkConfig);
      await controller.probe();
      await controller.sync(spaceId: 'space-id');

      final state = container.read(provider);
      expect(state.status, SyncUiStatus.unsupported);
      expect(state.message, contains('disabled in the browser'));
      expect(state.networkConfigContent, isEmpty);
      expect(state.lastProbeAt, isNull);
      expect(state.lastSuccessfulSyncAt, isNull);
      expect(probeCalls, 0);
      expect(syncCalls, 0);
    },
  );
}
