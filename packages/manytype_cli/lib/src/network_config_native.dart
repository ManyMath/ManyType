export 'network_config_shared.dart';

import 'dart:io';

import 'package:yaml/yaml.dart';

import 'network_config_shared.dart';

Future<NetworkConfigFile> loadNetworkConfig(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw StateError('Network config not found at $path');
  }

  final raw = loadYaml(await file.readAsString());
  if (raw is! YamlMap) {
    throw StateError('Invalid network config YAML at $path');
  }

  final nodesRaw = raw['nodes'];
  if (nodesRaw is! YamlList) {
    throw StateError('Network config at $path is missing nodes');
  }

  return NetworkConfigFile(
    id: (raw['id'] ?? '').toString(),
    networkId: (raw['networkId'] ?? '').toString(),
    nodes: nodesRaw.map((node) {
      if (node is! YamlMap) {
        throw StateError('Invalid node entry in $path');
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
