import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'account_profile.dart';
import 'config.dart';

/// Native (vm) account registry backed by files under `~/.manytype`:
/// - `accounts.json`: index of known account summaries (no secrets)
/// - `current`: plain-text file naming the currently-selected account id
/// - `accounts/<id>/config.toml`: that account's mnemonic + server_address
/// - `accounts/<id>/store.db`: that account's database
class AccountRegistry {
  /// Test-only override for [baseDir]. When null, baseDir resolves to
  /// `$HOME/.manytype` (or `$USERPROFILE` on Windows) as usual.
  static String? testBaseDirOverride;

  static String get baseDir {
    if (testBaseDirOverride != null) {
      return testBaseDirOverride!;
    }
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return p.join(home, '.manytype');
  }

  static String get registryPath => p.join(baseDir, 'accounts.json');
  static String get currentPath => p.join(baseDir, 'current');
  static String get accountsDir => p.join(baseDir, 'accounts');

  static String accountDir(String id) => p.join(accountsDir, id);
  static String accountConfigPath(String id) =>
      p.join(accountDir(id), 'config.toml');
  static String accountDbPath(String id) => p.join(accountDir(id), 'store.db');
  static String accountDownloadsDir(String id) =>
      p.join(accountDir(id), 'downloads');

  /// List all known account summaries, in the order they were registered.
  static Future<List<AccountSummary>> listAccounts() async {
    final file = File(registryPath);
    if (!await file.exists()) {
      return [];
    }
    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(content) as Map<String, dynamic>;
    final accounts = (decoded['accounts'] as List<dynamic>? ?? [])
        .map((e) => AccountSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    return accounts;
  }

  static Future<void> _writeAccounts(List<AccountSummary> accounts) async {
    final dir = Directory(baseDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(registryPath);
    final encoded = jsonEncode({
      'accounts': accounts.map((a) => a.toJson()).toList(),
    });
    await file.writeAsString(encoded);
  }

  /// Register (or re-register, idempotently) an account summary in the
  /// shared index. Does not touch the account's own config/db.
  static Future<void> registerAccount(AccountSummary summary) async {
    final accounts = await listAccounts();
    final withoutExisting = accounts.where((a) => a.id != summary.id).toList();
    await _writeAccounts([...withoutExisting, summary]);
  }

  /// Remove an account's registry entry and delete its on-disk directory
  /// (config.toml + store.db + downloads). This is local profile removal
  /// only: never the protocol-level AccountDelete operation.
  static Future<void> removeAccount(String id) async {
    final accounts = await listAccounts();
    await _writeAccounts(accounts.where((a) => a.id != id).toList());

    final dir = Directory(accountDir(id));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }

    final currentId = await getCurrentAccountId();
    if (currentId == id) {
      final file = File(currentPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Rename an already-registered account's display name. Throws
  /// [StateError] if no account is registered under [id].
  static Future<void> renameAccount(String id, String displayName) async {
    final accounts = await listAccounts();
    final index = accounts.indexWhere((a) => a.id == id);
    if (index < 0) {
      throw StateError('no account registered with id $id');
    }
    final updated = List<AccountSummary>.of(accounts);
    updated[index] = accounts[index].copyWith(displayName: displayName);
    await _writeAccounts(updated);
  }

  /// Update an account's server address in its own config.toml, preserving
  /// its mnemonic. Throws [StateError] if no account is registered under
  /// [id].
  static Future<void> updateServerAddress(String id, String serverAddress) async {
    final accounts = await listAccounts();
    AccountSummary? summary;
    for (final account in accounts) {
      if (account.id == id) {
        summary = account;
        break;
      }
    }
    if (summary == null) {
      throw StateError('no account registered with id $id');
    }
    final configPath = summary.configPathOverride ?? accountConfigPath(id);
    final config = await CliConfig.loadFrom(configPath);
    final configFile = File(configPath);
    await configFile.writeAsString(
      'mnemonic = "${config.mnemonic}"\nserver_address = "$serverAddress"\n',
    );
  }

  /// Load an account's config (mnemonic + server address), the same way
  /// [resolveActiveAccount] does for the currently-active account : 
  /// respecting [AccountSummary.configPathOverride] for migrated legacy
  /// accounts. Throws [StateError] if no account is registered under [id].
  static Future<CliConfig> loadConfig(String id,
      {String? serverOverride}) async {
    final accounts = await listAccounts();
    AccountSummary? summary;
    for (final account in accounts) {
      if (account.id == id) {
        summary = account;
        break;
      }
    }
    if (summary == null) {
      throw StateError('no account registered with id $id');
    }
    final configPath = summary.configPathOverride ?? accountConfigPath(id);
    return CliConfig.loadFrom(configPath, serverOverride: serverOverride);
  }

  static Future<String?> getCurrentAccountId() async {
    final file = File(currentPath);
    if (!await file.exists()) {
      return null;
    }
    final content = (await file.readAsString()).trim();
    return content.isEmpty ? null : content;
  }

  static Future<void> setCurrentAccountId(String id) async {
    final dir = Directory(baseDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await File(currentPath).writeAsString(id);
  }

  /// Create the on-disk directory for a new account and write its
  /// config.toml (mnemonic + server_address). Registers the summary in the
  /// shared index. Does not change which account is "current".
  static Future<AccountProfile> createAccount({
    required String mnemonic,
    required String displayName,
    String serverAddress = '127.0.0.1:33020',
  }) async {
    final id = await AccountProfile.deriveAccountId(mnemonic);
    final dir = Directory(accountDir(id));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final createdAt = DateTime.now().toUtc();
    final configFile = File(accountConfigPath(id));
    await configFile.writeAsString(
      'mnemonic = "$mnemonic"\nserver_address = "$serverAddress"\n',
    );

    await registerAccount(AccountSummary(
      id: id,
      displayName: displayName,
      createdAt: createdAt,
    ));

    return AccountProfile(
      id: id,
      displayName: displayName,
      mnemonic: mnemonic,
      createdAt: createdAt,
    );
  }

  /// Register a pre-existing legacy single-account install (a top-level
  /// `~/.manytype/config.toml` + `store.db`, from before named account
  /// profiles existed) as a real, selectable account profile: without
  /// moving or copying any files. The registered [AccountSummary] carries
  /// `configPathOverride`/`dbPathOverride` pointing at the exact legacy
  /// paths, so the migrated account's storage location never changes and
  /// there is no risk of two divergent copies of the data.
  ///
  /// No-op (returns null) if any account is already registered: this makes
  /// the migration idempotent and safe to attempt on every invocation.
  static Future<AccountProfile?> migrateLegacyAccount({
    required String legacyConfigPath,
    required String legacyDbPath,
    required String legacyMnemonic,
    String displayName = 'default',
  }) async {
    final existing = await listAccounts();
    if (existing.isNotEmpty) {
      return null;
    }

    final id = await AccountProfile.deriveAccountId(legacyMnemonic);
    final createdAt = DateTime.now().toUtc();

    await registerAccount(AccountSummary(
      id: id,
      displayName: displayName,
      createdAt: createdAt,
      configPathOverride: legacyConfigPath,
      dbPathOverride: legacyDbPath,
    ));
    await setCurrentAccountId(id);

    return AccountProfile(
      id: id,
      displayName: displayName,
      mnemonic: legacyMnemonic,
      createdAt: createdAt,
    );
  }
}
