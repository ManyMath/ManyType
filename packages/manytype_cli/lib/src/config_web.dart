import 'package:path/path.dart' as p;

class CliConfig {
  final String mnemonic;
  final String serverAddress;

  CliConfig({required this.mnemonic, required this.serverAddress});

  static String get configDir =>
      throw UnsupportedError('config I/O is vm-only; construct CliConfig directly on web');

  static String get configPath =>
      throw UnsupportedError('config I/O is vm-only; construct CliConfig directly on web');

  static String get dbPath =>
      throw UnsupportedError('config I/O is vm-only; construct CliConfig directly on web');

  static String get downloadsDir =>
      throw UnsupportedError('config I/O is vm-only; construct CliConfig directly on web');

  static String downloadPath(String fileId, String cid) {
    final safeFileId = fileId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    final safeCid = cid.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    return p.join('downloads', '${safeFileId}_$safeCid.bin');
  }

  static Future<CliConfig> load({String? serverOverride}) async {
    throw UnsupportedError('config I/O is vm-only; construct CliConfig directly on web');
  }

  static Future<CliConfig> loadFrom(String path, {String? serverOverride}) async {
    throw UnsupportedError('config I/O is vm-only; construct CliConfig directly on web');
  }

  static Future<CliConfig> initialize() async {
    throw UnsupportedError('config I/O is vm-only; construct CliConfig directly on web');
  }
}
