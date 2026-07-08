import 'package:path/path.dart' as p;

import 'dart:convert';

Map<String, String> parseSimpleToml(String content) {
  throw UnsupportedError('config I/O is vm-only');
}

Future<Map<String, String>> readSimpleTomlFile(String path) async {
  throw UnsupportedError('config I/O is vm-only');
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

class CliConfig {
  final String mnemonic;
  final String serverAddress;

  CliConfig({required this.mnemonic, required this.serverAddress});

  static String? testConfigDirOverride;

  static String get configDir => throw UnsupportedError(
      'config I/O is vm-only; construct CliConfig directly on web');

  static String get configPath => throw UnsupportedError(
      'config I/O is vm-only; construct CliConfig directly on web');

  static String get dbPath => throw UnsupportedError(
      'config I/O is vm-only; construct CliConfig directly on web');

  static String get downloadsDir => throw UnsupportedError(
      'config I/O is vm-only; construct CliConfig directly on web');

  static String downloadPath(String fileId, String cid) {
    final safeFileId = fileId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    final safeCid = cid.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    return p.join('downloads', '${safeFileId}_$safeCid.bin');
  }

  static Future<CliConfig> load({String? serverOverride}) async {
    throw UnsupportedError(
        'config I/O is vm-only; construct CliConfig directly on web');
  }

  static Future<CliConfig> loadFrom(String path,
      {String? serverOverride}) async {
    throw UnsupportedError(
        'config I/O is vm-only; construct CliConfig directly on web');
  }

  static Future<CliConfig> initialize() async {
    throw UnsupportedError(
        'config I/O is vm-only; construct CliConfig directly on web');
  }
}
