import 'dart:typed_data';

import 'package:manytype_protocol/coordinator.dart';

import '../config.dart';
import '../ffi/native_bridge.dart';
import '../identity.dart';
import '../network_config.dart';

/// Connect to a coordinator and perform only the NetworkConfiguration exchange.
///
/// This is intentionally narrower than `sync` so live production validation can
/// stop at the first coordinator RPC without attempting object or store sync.
Future<void> probeNetworkCommand(
  CliConfig config, {
  required String networkConfigPath,
}) async {
  final networkConfig = await loadNetworkConfig(networkConfigPath);
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final bridge = NativeBridge();

  print('Connecting to coordinator at $coordinatorAddress...');
  final handleId =
      bridge.connect(coordinatorAddress, identity.seed, identity.accountSeed);

  try {
    final requestBytes =
        Uint8List.fromList(NetworkConfigurationRequest().writeToBuffer());
    final responseBytes = bridge.invoke(
      handleId,
      '/coordinator.Coordinator/NetworkConfiguration',
      requestBytes,
    );
    final response = NetworkConfigurationResponse.fromBuffer(responseBytes);

    print('NetworkConfiguration exchange succeeded.');
    print('Network: ${response.networkId}');
    print('Configuration ID: ${response.configurationId}');
    print('Nodes returned: ${response.nodes.length}');
  } finally {
    bridge.freeHandle(handleId);
  }
}
