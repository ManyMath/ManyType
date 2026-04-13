import 'config.dart';

/// Active-account resolution reads `~/.manytype` config files, which is a
/// vm-only concept (see [CliConfig]'s web stub). On web, construct a
/// [CliConfig] directly and open a session against it instead of resolving
/// an active account by name.
Future<({CliConfig config, String dbPath})> resolveActiveAccount({
  String? accountOverride,
  String? envAccountId,
  String? serverOverride,
}) async {
  throw UnsupportedError(
    'account resolution is vm-only; construct CliConfig directly on web',
  );
}
