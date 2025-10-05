/// Protocol State Machine: Coordinator Discovery
///
/// Documents the coordinator discovery flow as executable assertions.
/// Source: any-sync/coordinator/coordinatorproto/coordinator.proto
/// Source: any-sync/coordinator/coordinator.go
///
/// PROTO-01: Protocol state machine
/// PROTO-02: Protobuf message flows

import 'package:test/test.dart';
import 'package:manytype_protocol/coordinator.dart';

void main() {
  group('Coordinator Discovery Flow', () {
    test('Step 1: Client sends NetworkConfigurationRequest to coordinator', () {
      // Document: Client connects to coordinator node (known address from config).
      // Creates NetworkConfigurationRequest with optional currentId.
      // If currentId matches latest config, response will have empty nodes list.
      final request = NetworkConfigurationRequest();
      expect(request, isNotNull);
      expect(request.currentId, isEmpty); // No current config = full discovery

      // With a known configuration ID (for incremental updates):
      final incrementalRequest = NetworkConfigurationRequest(
        currentId: 'config-abc-123',
      );
      expect(incrementalRequest.currentId, equals('config-abc-123'));
    });

    test('Step 2: Coordinator responds with NetworkConfigurationResponse', () {
      // Document: Coordinator returns NetworkConfigurationResponse containing:
      // - configurationId: unique ID of this network configuration
      // - networkId: identifies the network
      // - nodes: list of Node entries with peerId, addresses, and types
      // - creationTimeUnix: when this configuration was created
      //
      // Each Node has a NodeType indicating its role:
      //   TreeAPI (0) = sync node, FileAPI (1) = file node,
      //   CoordinatorAPI (2) = coordinator, ConsensusAPI (3) = consensus
      final response = NetworkConfigurationResponse(
        configurationId: 'config-abc-123',
        networkId: 'N1234567890abcdef',
        nodes: [
          Node(
            peerId: '12D3KooWExampleSyncNode',
            addresses: ['192.168.1.10:33010'],
            types: [NodeType.TreeAPI],
          ),
          Node(
            peerId: '12D3KooWExampleFileNode',
            addresses: ['192.168.1.11:33010'],
            types: [NodeType.FileAPI],
          ),
          Node(
            peerId: '12D3KooWExampleCoordinator',
            addresses: ['192.168.1.1:33010'],
            types: [NodeType.CoordinatorAPI],
          ),
        ],
      );
      expect(response.configurationId, isNotEmpty);
      expect(response.networkId, isNotEmpty);
      expect(response.nodes, hasLength(3));

      // Client filters nodes by type to find sync nodes:
      final syncNodes = response.nodes
          .where((n) => n.types.contains(NodeType.TreeAPI))
          .toList();
      expect(syncNodes, hasLength(1));
      expect(syncNodes.first.peerId, equals('12D3KooWExampleSyncNode'));
    });

    test('Step 3: Client sends SpaceSignRequest to register space', () {
      // Document: After getting node addresses, client sends SpaceSignRequest
      // to coordinator to register its space.
      // SpaceSignRequest contains:
      //   - spaceId: the space being registered
      //   - header: serialized space header (RawSpaceHeader protobuf)
      //   - oldIdentity: (optional) for identity migration
      //   - newIdentitySignature: (optional) for identity migration
      //   - forceRequest: (optional) force re-registration
      final request = SpaceSignRequest(
        spaceId: 'bafyspace123.abc',
        header: [0x0a, 0x10, 0x20], // Serialized RawSpaceHeader
      );
      expect(request.spaceId, isNotEmpty);
      expect(request.header, isNotEmpty);
    });

    test('Step 4: Coordinator responds with SpaceSignResponse', () {
      // Document: Coordinator returns SpaceSignResponse containing a receipt.
      // The receipt is a SpaceReceiptWithSignature that proves the coordinator
      // acknowledged the space registration.
      final response = SpaceSignResponse(
        receipt: SpaceReceiptWithSignature(
          spaceReceiptPayload: [0x0a, 0x20, 0x30], // Serialized SpaceReceipt
          signature: [0x01, 0x02, 0x03], // Coordinator's signature
        ),
      );
      expect(response.receipt, isNotNull);
      expect(response.receipt.signature, isNotEmpty);
    });

    test('Full coordinator discovery sequence', () {
      // Complete discovery flow:
      //
      // 1. Client -> Coordinator: NetworkConfigurationRequest {}
      //    Purpose: Discover available nodes in the network
      //
      // 2. Coordinator -> Client: NetworkConfigurationResponse {
      //      configurationId, networkId, nodes: [
      //        { peerId, addresses, types: [TreeAPI] },   // sync node
      //        { peerId, addresses, types: [FileAPI] },   // file node
      //        { peerId, addresses, types: [CoordinatorAPI] },
      //      ]
      //    }
      //    Purpose: Client learns which nodes exist and their roles
      //
      // 3. Client picks sync node (TreeAPI) from response
      //
      // 4. Client -> Coordinator: SpaceSignRequest {
      //      spaceId, header (serialized RawSpaceHeader)
      //    }
      //    Purpose: Register client's space with the coordinator
      //
      // 5. Coordinator -> Client: SpaceSignResponse {
      //      receipt: { payload, signature }
      //    }
      //    Purpose: Coordinator acknowledges space registration
      //
      // 6. Client connects to sync node for HeadSync + ObjectSync

      // Verify the types compose correctly:
      final request = NetworkConfigurationRequest();
      expect(request, isA<NetworkConfigurationRequest>());

      final response = NetworkConfigurationResponse(
        configurationId: 'cfg-1',
        networkId: 'net-1',
        nodes: [
          Node(
            peerId: 'sync-node-1',
            addresses: ['10.0.0.1:33010'],
            types: [NodeType.TreeAPI],
          ),
        ],
      );
      expect(response.nodes.first.types, contains(NodeType.TreeAPI));

      final signRequest = SpaceSignRequest(spaceId: 'space-1');
      expect(signRequest.spaceId, equals('space-1'));

      final signResponse = SpaceSignResponse(
        receipt: SpaceReceiptWithSignature(),
      );
      expect(signResponse.receipt, isNotNull);
    });
  });
}
