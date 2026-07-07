import 'dart:io';

import 'account_registry.dart';
import 'account_resolver.dart';
import 'config.dart';

/// Resolves the config + db path for the currently-active account.
///
/// If a named account profile is selected (via [accountOverride],
/// [envAccountId], or the persisted current pointer), its own config/db is
/// used: normally `accounts/<id>/{config.toml,store.db}`, or the aliased
/// legacy paths if this profile came from [AccountRegistry.migrateLegacyAccount].
///
/// If no account profiles exist at all yet and a legacy top-level
/// `~/.manytype/config.toml` is found, it is migrated in place (registered
/// as a real profile aliasing the legacy paths: no files are moved or
/// copied) so it becomes visible to `account list`/`account use` from then
/// on. If neither a profile nor a legacy config exists, falls back to
/// `CliConfig.load()`'s own "run `manytype init`" error. An explicit
/// [accountOverride]/[envAccountId] with no matching profile is a real
/// error, not something to silently fall back past.
Future<({CliConfig config, String dbPath})> resolveActiveAccount({
  String? accountOverride,
  String? envAccountId,
  String? serverOverride,
}) async {
  try {
    final accountId = await AccountResolver.resolveAccountId(
      explicitAccountId: accountOverride,
      envAccountId: envAccountId,
    );
    final accounts = await AccountRegistry.listAccounts();
    final summary = accounts.firstWhere((a) => a.id == accountId);
    final dbPath =
        summary.dbPathOverride ?? AccountRegistry.accountDbPath(accountId);
    final config = await AccountRegistry.loadConfig(
      accountId,
      serverOverride: serverOverride,
    );
    return (config: config, dbPath: dbPath);
  } on NoAccountError {
    if (accountOverride != null || envAccountId != null) {
      rethrow;
    }
    if (await File(CliConfig.configPath).exists()) {
      final legacyConfig = await CliConfig.load(serverOverride: serverOverride);
      await AccountRegistry.migrateLegacyAccount(
        legacyConfigPath: CliConfig.configPath,
        legacyDbPath: CliConfig.dbPath,
        legacyMnemonic: legacyConfig.mnemonic,
      );
      return (config: legacyConfig, dbPath: CliConfig.dbPath);
    }
    final config = await CliConfig.load(serverOverride: serverOverride);
    return (config: config, dbPath: CliConfig.dbPath);
  }
}
