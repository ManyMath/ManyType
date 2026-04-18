import 'dart:typed_data';

import 'package:manytype_protocol/coordinator.dart';

import '../config.dart';
import '../ffi/native_bridge.dart';
import '../identity.dart';
import '../network_config.dart';
import '../session.dart';

/// Result of a successful NetworkConfiguration exchange with a coordinator.
class NetworkProbeResult {
  const NetworkProbeResult({
    required this.coordinatorAddress,
    required this.networkId,
    required this.configurationId,
    required this.nodeCount,
  });

  final String coordinatorAddress;
  final String networkId;
  final String configurationId;
  final int nodeCount;
}

/// Connect to a coordinator and perform only the NetworkConfiguration exchange.
///
/// This is intentionally narrower than `sync` so live production validation can
/// stop at the first coordinator RPC without attempting object or store sync.
Future<NetworkProbeResult> probeNetworkCommand(
  CliConfig config, {
  required String networkConfigPath,
}) async {
  final networkConfig = await loadNetworkConfig(networkConfigPath);
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final bridge = NativeBridge();

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

    return NetworkProbeResult(
      coordinatorAddress: coordinatorAddress,
      networkId: response.networkId,
      configurationId: response.configurationId,
      nodeCount: response.nodes.length,
    );
  } finally {
    bridge.freeHandle(handleId);
  }
}

/// Library-facing facade over the NetworkConfiguration probe, for consumers
/// that hold a [ManytypeSession] instead of driving the CLI directly.
/// Exposed as `session.probeNetwork`.
class ProbeNetworkFacade {
  const ProbeNetworkFacade(this._session);

  final ManytypeSession _session;

  Future<NetworkProbeResult> probe({required String networkConfigPath}) {
    return probeNetworkCommand(
      _session.config,
      networkConfigPath: networkConfigPath,
    );
  }
}
