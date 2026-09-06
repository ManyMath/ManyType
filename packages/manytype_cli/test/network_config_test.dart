@TestOn(
    'vm') // reads/writes real client.yml files via dart:io Directory/File: no browser filesystem equivalent used here
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_cli/src/peer_id.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:test/test.dart';

void main() {
  group('network config', () {
    late Directory tempDir;

    setUp(() async {
      tempDir =
          await Directory.systemTemp.createTemp('manytype_network_config_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('loads coordinator node from client.yml', () async {
      final file = File('${tempDir.path}/client.yml');
      await file.writeAsString('''
id: test
networkId: test-net
nodes:
  - peerId: peer-tree
    addresses:
      - quic://127.0.0.1:1011
    types:
      - tree
  - peerId: peer-coordinator
    addresses:
      - quic://127.0.0.1:1014
      - 127.0.0.1:1004
    types:
      - coordinator
''');

      final config = await loadNetworkConfig(file.path);
      final coordinator = requireCoordinatorNode(config);

      expect(config.networkId, 'test-net');
      expect(coordinator.peerId, 'peer-coordinator');
      expect(chooseBestAddress(coordinator.addresses), '127.0.0.1:1014');
    });

    test('loads file node from client.yml', () async {
      final file = File('${tempDir.path}/client.yml');
      await file.writeAsString('''
id: test
networkId: test-net
nodes:
  - peerId: peer-file
    addresses:
      - quic://127.0.0.1:1015
    types:
      - file
''');

      final config = await loadNetworkConfig(file.path);
      final fileNode = requireFileNode(config);

      expect(fileNode.peerId, 'peer-file');
      expect(chooseBestAddress(fileNode.addresses), '127.0.0.1:1015');
    });

    test('prefers localhost tree address from coordinator response', () {
      final address = chooseTreeAddressFromResponse([
        Node(
          addresses: ['quic://node.internal:1011', 'quic://127.0.0.1:1011'],
          types: [NodeType.TreeAPI],
        ),
      ]);

      expect(address, '127.0.0.1:1011');
    });

    test('parseNetworkConfig reads content directly, no filesystem', () {
      final config = parseNetworkConfig('''
id: test
networkId: content-net
nodes:
  - peerId: peer-coordinator
    addresses:
      - 127.0.0.1:1004
    types:
      - coordinator
''');

      expect(config.networkId, 'content-net');
      expect(requireCoordinatorNode(config).peerId, 'peer-coordinator');
    });

    test('resolveNetworkConfig prefers content over path', () async {
      final config = await resolveNetworkConfig(
        networkConfigContent: '''
id: test
networkId: content-net
nodes:
  - peerId: peer-coordinator
    addresses:
      - 127.0.0.1:1004
    types:
      - coordinator
''',
      );

      expect(config.networkId, 'content-net');
    });

    test('resolveNetworkConfig falls back to path', () async {
      final file = File('${tempDir.path}/client.yml');
      await file.writeAsString('''
id: test
networkId: path-net
nodes:
  - peerId: peer-coordinator
    addresses:
      - 127.0.0.1:1004
    types:
      - coordinator
''');

      final config = await resolveNetworkConfig(networkConfigPath: file.path);

      expect(config.networkId, 'path-net');
    });

    test('resolveNetworkConfig rejects both path and content', () {
      expect(
        () => resolveNetworkConfig(
          networkConfigPath: 'x.yml',
          networkConfigContent: 'id: test',
        ),
        throwsArgumentError,
      );
    });

    test('resolveNetworkConfig rejects neither path nor content', () {
      expect(
        () => resolveNetworkConfig(),
        throwsArgumentError,
      );
    });

    test('prefers localhost file address from coordinator response', () {
      final address = chooseFileAddressFromResponse([
        Node(
          addresses: ['quic://node.internal:1015', 'quic://127.0.0.1:1015'],
          types: [NodeType.FileAPI],
        ),
      ]);

      expect(address, '127.0.0.1:1015');
    });

    test('expects the peer ID of the node advertising an address', () {
      final coordinatorPeerId =
          encodeLibp2pPeerId(Uint8List(32)..fillRange(0, 32, 1));
      final treePeerId = encodeLibp2pPeerId(Uint8List(32)..fillRange(0, 32, 2));
      final config = parseNetworkConfig('''
id: test
networkId: test-net
nodes:
  - peerId: $coordinatorPeerId
    addresses:
      - quic://127.0.0.1:1004
    types:
      - coordinator
  - peerId: local
    addresses:
      - 127.0.0.1:1005
    types:
      - file
''');
      final nodes = [
        Node(
          peerId: treePeerId,
          addresses: ['quic://127.0.0.1:1011'],
          types: [NodeType.TreeAPI],
        ),
      ];

      String? expected(String address) =>
          expectedPeerIdForAddress(address, config: config, nodes: nodes);

      expect(expected('127.0.0.1:1004'), coordinatorPeerId);
      expect(expected('127.0.0.1:1011'), treePeerId);
      expect(expected('127.0.0.1:1005'), isNull);
      expect(expected('127.0.0.1:9999'), isNull);
    });
  });
}
