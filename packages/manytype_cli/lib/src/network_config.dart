export 'network_config_web.dart'
    if (dart.library.io) 'network_config_native.dart';

import 'network_config_web.dart'
    if (dart.library.io) 'network_config_native.dart';

/// Resolves a network config from either a filesystem path (vm-only, via
/// [loadNetworkConfig]) or inline YAML content (works everywhere, via
/// [parseNetworkConfig]): mutually exclusive, mirroring the
/// `fileRelationPath`/`fileRelationBytes` split on `editCommand`. Command
/// call sites that currently require `networkConfigPath` gain an
/// alternative `networkConfigContent` parameter that funnels here (see
/// M016, docs/m016-web-api-surface.md scope item 3).
Future<NetworkConfigFile> resolveNetworkConfig({
  String? networkConfigPath,
  String? networkConfigContent,
}) async {
  if (networkConfigContent != null && networkConfigPath != null) {
    throw ArgumentError(
      'Pass either networkConfigPath or networkConfigContent, not both',
    );
  }
  if (networkConfigContent != null) {
    return parseNetworkConfig(networkConfigContent);
  }
  if (networkConfigPath != null) {
    return loadNetworkConfig(networkConfigPath);
  }
  throw ArgumentError(
    'Either networkConfigPath or networkConfigContent is required',
  );
}
