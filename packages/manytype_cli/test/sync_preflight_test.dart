import 'dart:typed_data';

import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:test/test.dart';

void main() {
  group('discoverSyncTargetsForSync', () {
    test('runs NetworkConfiguration before SpaceStatusCheck', () {
      final methods = <String>[];
      final discovery = discoverSyncTargetsForSync(
        invoke: (handleId, method, payload) {
          methods.add(method);
          switch (method) {
            case '/coordinator.Coordinator/NetworkConfiguration':
              return NetworkConfigurationResponse(
                networkId: 'test-network',
                nodes: [
                  Node(
                    peerId: 'tree-peer',
                    addresses: ['quic://127.0.0.1:31001'],
                    types: [NodeType.TreeAPI],
                  ),
                ],
              ).writeToBuffer();
            case '/coordinator.Coordinator/SpaceStatusCheck':
              return SpaceStatusCheckResponse(
                payload: SpaceStatusPayload(
                  status: SpaceStatus.SpaceStatusCreated,
                ),
              ).writeToBuffer();
            default:
              throw StateError('unexpected method: $method');
          }
        },
        coordinatorHandleId: 1,
        spaceId: 'space-1',
        officialInteropMode: true,
        localServerAddress: '127.0.0.1:33020',
      );

      expect(
        methods,
        equals([
          '/coordinator.Coordinator/NetworkConfiguration',
          '/coordinator.Coordinator/SpaceStatusCheck',
        ]),
      );
      expect(discovery.syncAddress, '127.0.0.1:31001');
      expect(discovery.spaceStatus.status, SpaceStatus.SpaceStatusCreated);
    });

    test('throws a status-specific error for non-live spaces', () {
      expect(
        () => discoverSyncTargetsForSync(
          invoke: (handleId, method, payload) {
            switch (method) {
              case '/coordinator.Coordinator/NetworkConfiguration':
                return NetworkConfigurationResponse(
                  networkId: 'test-network',
                  nodes: [
                    Node(
                      peerId: 'tree-peer',
                      addresses: ['quic://127.0.0.1:31001'],
                      types: [NodeType.TreeAPI],
                    ),
                  ],
                ).writeToBuffer();
              case '/coordinator.Coordinator/SpaceStatusCheck':
                return SpaceStatusCheckResponse(
                  payload: SpaceStatusPayload(
                    status: SpaceStatus.SpaceStatusNotExists,
                  ),
                ).writeToBuffer();
              default:
                throw StateError('unexpected method: $method');
            }
          },
          coordinatorHandleId: 1,
          spaceId: 'space-404',
          officialInteropMode: true,
          localServerAddress: '127.0.0.1:33020',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('SpaceStatusNotExists'),
          ),
        ),
      );
    });
  });
}
