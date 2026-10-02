import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:manytype_core/manytype_core.dart' show generateMnemonic;

import 'private_files.dart';

/// Parse a simple TOML file with key = "value" pairs.
/// Supports only flat string values (sufficient for config.toml).
Map<String, String> parseSimpleToml(String content) {
  final result = <String, String>{};
  for (final line in content.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final eqIndex = trimmed.indexOf('=');
    if (eqIndex < 0) continue;
    final key = trimmed.substring(0, eqIndex).trim();
    var value = trimmed.substring(eqIndex + 1).trim();
    // Strip surrounding quotes
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }
    result[key] = value;
  }
  return result;
}

Future<Map<String, String>> readSimpleTomlFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw StateError('Config not found at $path. Run: manytype init');
  }
  return parseSimpleToml(await file.readAsString());
}

String encodeCliConfig({
  required String serverAddress,
  String? mnemonic,
  bool usesPlatformRecoveryPhrase = false,
}) {
  return <String>[
    if (mnemonic != null) 'mnemonic = ${jsonEncode(mnemonic)}',
    if (usesPlatformRecoveryPhrase) 'recovery_phrase_store = "platform"',
    'server_address = ${jsonEncode(serverAddress)}',
    '',
  ].join('\n');
}

/// CLI configuration loaded from ~/.manytype/config.toml.
class CliConfig {
  final String mnemonic;
  final String serverAddress;

  CliConfig({required this.mnemonic, required this.serverAddress});

  /// Test-only override for the legacy single-account config directory.
  static String? testConfigDirOverride;

  static String get configDir {
    if (testConfigDirOverride != null) return testConfigDirOverride!;
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return p.join(home, '.manytype');
  }

  static String get configPath => p.join(configDir, 'config.toml');
  static String get dbPath => p.join(configDir, 'store.db');
  static String get downloadsDir => p.join(configDir, 'downloads');

  static String downloadPath(String fileId, String cid) {
    final safeFileId = fileId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    final safeCid = cid.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    return p.join(downloadsDir, '${safeFileId}_$safeCid.bin');
  }

  /// Load config from ~/.manytype/config.toml.
  /// Per D-10: serverAddress can be overridden by --server flag.
  static Future<CliConfig> load({String? serverOverride}) async {
    return loadFrom(configPath, serverOverride: serverOverride);
  }

  /// Load config from a specific file path (for testing).
  static Future<CliConfig> loadFrom(String path,
      {String? serverOverride}) async {
    final map = await readSimpleTomlFile(path);

    final mnemonic = map['mnemonic'] ?? '';
    final serverAddress =
        serverOverride ?? (map['server_address'] ?? '127.0.0.1:33020');

    if (mnemonic.isEmpty) {
      if (map['recovery_phrase_store'] == 'platform') {
        throw StateError(
          'Recovery phrase for $path is held in platform secure storage. '
          'Open this account through a host that configures a '
          'RecoveryPhraseStore.',
        );
      }
      throw StateError('mnemonic not set in $path');
    }

    return CliConfig(mnemonic: mnemonic, serverAddress: serverAddress);
  }

  /// Initialize the config directory with a newly generated mnemonic.
  ///
  /// Throws [StateError] if config.toml already exists, since replacing it
  /// discards the existing mnemonic; pass [force] to overwrite it anyway.
  static Future<CliConfig> initialize({bool force = false}) async {
    final file = File(configPath);
    if (!force && await file.exists()) {
      throw StateError(
        'Config already exists at $configPath. Re-running init would replace '
        'its mnemonic; pass --force to overwrite it.',
      );
    }
    final mnemonic = generateMnemonic();
    final config =
        CliConfig(mnemonic: mnemonic, serverAddress: '127.0.0.1:33020');

    await writePrivateFileAtomically(
      configPath,
      encodeCliConfig(
        mnemonic: config.mnemonic,
        serverAddress: config.serverAddress,
      ),
    );
    return config;
  }
}
