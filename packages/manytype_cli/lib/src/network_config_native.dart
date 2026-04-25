export 'network_config_shared.dart';

import 'dart:io';

import 'network_config_shared.dart';

Future<NetworkConfigFile> loadNetworkConfig(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw StateError('Network config not found at $path');
  }

  return parseNetworkConfig(await file.readAsString(), source: path);
}
