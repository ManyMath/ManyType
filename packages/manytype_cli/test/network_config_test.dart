import 'dart:io';

import 'package:manytype_cli/src/network_config.dart';
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

    test('prefers localhost tree address from coordinator response', () {
      final address = chooseTreeAddressFromResponse([
        Node(
          addresses: ['quic://node.internal:1011', 'quic://127.0.0.1:1011'],
          types: [NodeType.TreeAPI],
        ),
      ]);

      expect(address, '127.0.0.1:1011');
    });
  });
}
