import 'package:manytype_protocol/coordinator.dart';
import 'package:yaml/yaml.dart';

import 'peer_id.dart';

class NetworkConfigNode {
  final String peerId;
  final List<String> addresses;
  final List<String> types;

  NetworkConfigNode({
    required this.peerId,
    required this.addresses,
    required this.types,
  });
}

class NetworkConfigFile {
  final String id;
  final String networkId;
  final List<NetworkConfigNode> nodes;

  NetworkConfigFile({
    required this.id,
    required this.networkId,
    required this.nodes,
  });
}

/// Parses a `client.yml`-shaped any-sync network config from its raw YAML
/// text. Pure Dart (the `yaml` package has no dart:io dependency) so this
/// works on web too: unlike `loadNetworkConfig(path)`, which is vm-only
/// because it reads the path itself. Web callers that fetch/read config
/// content some other way (no filesystem) can call this directly (see
/// M016, docs/m016-web-api-surface.md scope item 3).
NetworkConfigFile parseNetworkConfig(String yamlContent, {String? source}) {
  final label = source ?? '<content>';
  final raw = loadYaml(yamlContent);
  if (raw is! YamlMap) {
    throw StateError('Invalid network config YAML at $label');
  }

  final nodesRaw = raw['nodes'];
  if (nodesRaw is! YamlList) {
    throw StateError('Network config at $label is missing nodes');
  }

  return NetworkConfigFile(
    id: (raw['id'] ?? '').toString(),
    networkId: (raw['networkId'] ?? '').toString(),
    nodes: nodesRaw.map((node) {
      if (node is! YamlMap) {
        throw StateError('Invalid node entry in $label');
      }
      final addresses = (node['addresses'] as YamlList? ?? const [])
          .map((value) => value.toString())
          .toList();
      final types = (node['types'] as YamlList? ?? const [])
          .map((value) => value.toString())
          .toList();
      return NetworkConfigNode(
        peerId: (node['peerId'] ?? '').toString(),
        addresses: addresses,
        types: types,
      );
    }).toList(),
  );
}

String normalizeQuicAddress(String address) {
  final trimmed = address.trim();
  if (trimmed.startsWith('quic://')) {
    return trimmed.substring('quic://'.length);
  }
  return trimmed;
}

String chooseBestAddress(Iterable<String> addresses) {
  final candidates = addresses
      .map((raw) {
        final trimmed = raw.trim();
        return (
          raw: trimmed,
          normalized: normalizeQuicAddress(trimmed),
          isQuic: trimmed.startsWith('quic://'),
        );
      })
      .where((candidate) => candidate.normalized.isNotEmpty)
      .toList();

  if (candidates.isEmpty) {
    throw StateError('No usable addresses available');
  }

  int score(
    ({String raw, String normalized, bool isQuic}) candidate,
  ) {
    final host = candidate.normalized.split(':').first;
    final isLocal = host == '127.0.0.1' || host == 'localhost';
    if (candidate.isQuic && isLocal) return 0;
    if (candidate.isQuic) return 1;
    if (isLocal) return 2;
    return 3;
  }

  candidates.sort((a, b) {
    final scoreCompare = score(a).compareTo(score(b));
    if (scoreCompare != 0) {
      return scoreCompare;
    }
    return 0;
  });

  for (final candidate in candidates) {
    if (candidate.normalized.isNotEmpty) {
      return candidate.normalized;
    }
  }

  throw StateError('No usable addresses available');
}

NetworkConfigNode requireCoordinatorNode(NetworkConfigFile config) {
  return requireNodeByType(config, 'coordinator');
}

NetworkConfigNode requireFileNode(NetworkConfigFile config) {
  return requireNodeByType(config, 'file');
}

NetworkConfigNode requireNodeByType(
  NetworkConfigFile config,
  String nodeType,
) {
  final normalized = nodeType.toLowerCase();
  return config.nodes.firstWhere(
    (node) =>
        node.types.map((value) => value.toLowerCase()).contains(normalized),
    orElse: () => throw StateError('No $nodeType node found in network config'),
  );
}

/// Returns the peer ID to verify when connecting to [address], taken from the
/// first node in [config] or [nodes] that advertises it.
///
/// Placeholder IDs that are not libp2p peer IDs (such as `local` in test
/// configs) are skipped, so those connections stay unverified.
String? expectedPeerIdForAddress(
  String address, {
  NetworkConfigFile? config,
  Iterable<Node> nodes = const [],
}) {
  final target = normalizeQuicAddress(address);
  final candidates = [
    for (final node in config?.nodes ?? const <NetworkConfigNode>[])
      (peerId: node.peerId, addresses: node.addresses),
    for (final node in nodes) (peerId: node.peerId, addresses: node.addresses),
  ];
  for (final candidate in candidates) {
    if (candidate.addresses.map(normalizeQuicAddress).contains(target) &&
        isLibp2pPeerId(candidate.peerId)) {
      return candidate.peerId;
    }
  }
  return null;
}

String? chooseTreeAddressFromResponse(Iterable<Node> nodes) {
  return chooseAddressForTypeFromResponse(nodes, NodeType.TreeAPI);
}

List<String> chooseTreeAddressesFromResponse(Iterable<Node> nodes) {
  return chooseAddressesForTypeFromResponse(nodes, NodeType.TreeAPI);
}

String? chooseFileAddressFromResponse(Iterable<Node> nodes) {
  return chooseAddressForTypeFromResponse(nodes, NodeType.FileAPI);
}

List<String> chooseFileAddressesFromResponse(Iterable<Node> nodes) {
  return chooseAddressesForTypeFromResponse(nodes, NodeType.FileAPI);
}

String? chooseAddressForTypeFromResponse(
  Iterable<Node> nodes,
  NodeType nodeType,
) {
  for (final node in nodes) {
    if (node.types.contains(nodeType) && node.addresses.isNotEmpty) {
      return chooseBestAddress(node.addresses);
    }
  }
  return null;
}

List<String> chooseAddressesForTypeFromResponse(
  Iterable<Node> nodes,
  NodeType nodeType,
) {
  final results = <String>[];
  for (final node in nodes) {
    if (!node.types.contains(nodeType) || node.addresses.isEmpty) {
      continue;
    }
    try {
      results.add(chooseBestAddress(node.addresses));
    } catch (_) {
      // Skip nodes with no usable addresses.
    }
  }
  results.sort();
  return results;
}
