import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'account_profile.dart';
import 'account_sync_metadata.dart';
import 'config.dart';
import 'recovery_phrase_store.dart';

/// Native (vm) account registry backed by files under `~/.manytype`:
/// - `accounts.json`: index of known account summaries (no secrets)
/// - `current`: plain-text file naming the currently-selected account id
/// - `accounts/<id>/config.toml`: server address and, for CLI-only hosts,
///   the account mnemonic
/// - `accounts/<id>/store.db`: that account's database
class AccountRegistry {
  /// Test-only override for [baseDir]. When null, baseDir resolves to
  /// `$HOME/.manytype` (or `$USERPROFILE` on Windows) as usual.
  static String? testBaseDirOverride;
  static RecoveryPhraseStore? _recoveryPhraseStore;

  /// Supplies the native host's OS-backed secret storage.
  ///
  /// The Flutter app configures this before accessing accounts. A pure Dart
  /// CLI host leaves it null to retain the established plaintext
  /// `config.toml` format and receives an explicit error if it encounters an
  /// app-owned config whose phrase is only available from platform storage.
  static void configureRecoveryPhraseStore(RecoveryPhraseStore? store) {
    _recoveryPhraseStore = store;
  }

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
  static String accountSyncMetadataPath(String id) =>
      p.join(accountDir(id), 'sync.json');

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
  /// (config.toml + store.db + downloads). Migrated accounts resolve and
  /// delete their legacy config/database overrides instead. This is local
  /// profile removal only: never the protocol-level AccountDelete operation.
  static Future<void> removeAccount(String id) async {
    final accounts = await listAccounts();
    AccountSummary? summary;
    for (final account in accounts) {
      if (account.id == id) {
        summary = account;
        break;
      }
    }

    final recoveryPhrase = await _recoveryPhraseStore?.read(id);
    var recoveryPhraseDeleted = false;
    if (recoveryPhrase != null) {
      await _recoveryPhraseStore!.delete(id);
      recoveryPhraseDeleted = true;
    }

    try {
      if (summary != null) {
        final dbPath = summary.dbPathOverride;
        if (dbPath != null) {
          // SQLite may leave these siblings behind even after the connection
          // closes. Delete them before the main database so a failure keeps the
          // registry entry available for another cleanup attempt.
          for (final suffix in const <String>['-wal', '-shm', '-journal']) {
            await _deleteFileIfPresent('$dbPath$suffix');
          }
          await _deleteFileIfPresent(dbPath);
        }

        final configPath = summary.configPathOverride;
        if (configPath != null) {
          await _deleteFileIfPresent(configPath);
        }
      }

      final dir = Directory(accountDir(id));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      // Remove the registry entry only after durable data deletion succeeds.
      // A filesystem failure therefore leaves the profile available for retry.
      await _writeAccounts(accounts.where((a) => a.id != id).toList());

      final currentId = await getCurrentAccountId();
      if (currentId == id) {
        final file = File(currentPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {
      if (recoveryPhraseDeleted) {
        await _recoveryPhraseStore!.write(id, recoveryPhrase!);
      }
      rethrow;
    }
  }

  static Future<void> _deleteFileIfPresent(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
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

  /// Persist whether [id] still needs its app-provided starter template.
  static Future<void> setStarterTemplatePending(
    String id,
    bool pending,
  ) async {
    final accounts = await listAccounts();
    final index = accounts.indexWhere((account) => account.id == id);
    if (index < 0) {
      throw StateError('no account registered with id $id');
    }
    final updated = List<AccountSummary>.of(accounts);
    updated[index] = accounts[index].copyWith(
      pendingStarterTemplate: pending,
    );
    await _writeAccounts(updated);
  }

  /// Update an account's server address in its own config.toml, preserving
  /// its mnemonic. Throws [StateError] if no account is registered under
  /// [id].
  static Future<void> updateServerAddress(
      String id, String serverAddress) async {
    final summary = await _requireSummary(id);
    final configPath = summary.configPathOverride ?? accountConfigPath(id);
    final config = await loadConfig(id);
    await _writeFileAtomically(
      configPath,
      encodeCliConfig(
        mnemonic: _recoveryPhraseStore == null ? config.mnemonic : null,
        serverAddress: serverAddress,
        usesPlatformRecoveryPhrase: _recoveryPhraseStore != null,
      ),
    );
  }

  /// Load an account's config (mnemonic + server address), the same way
  /// [resolveActiveAccount] does for the currently-active account :
  /// respecting [AccountSummary.configPathOverride] for migrated legacy
  /// accounts. Throws [StateError] if no account is registered under [id].
  static Future<CliConfig> loadConfig(String id,
      {String? serverOverride}) async {
    final summary = await _requireSummary(id);
    final configPath = summary.configPathOverride ?? accountConfigPath(id);
    final store = _recoveryPhraseStore;
    if (store == null) {
      return CliConfig.loadFrom(configPath, serverOverride: serverOverride);
    }

    final values = await readSimpleTomlFile(configPath);
    final serverAddress =
        serverOverride ?? (values['server_address'] ?? '127.0.0.1:33020');
    final plaintextPhrase = values['mnemonic']?.trim();
    var securePhrase = await store.read(id);

    if (plaintextPhrase != null && plaintextPhrase.isNotEmpty) {
      if (securePhrase != null && securePhrase != plaintextPhrase) {
        throw StateError(
          'Platform recovery phrase does not match the plaintext phrase for '
          'account $id; refusing to overwrite either copy.',
        );
      }

      final createdSecureCopy = securePhrase == null;
      if (createdSecureCopy) {
        await store.write(id, plaintextPhrase);
      }
      try {
        await _writeFileAtomically(
          configPath,
          encodeCliConfig(
            serverAddress: values['server_address'] ?? '127.0.0.1:33020',
            usesPlatformRecoveryPhrase: true,
          ),
        );
      } catch (_) {
        if (createdSecureCopy) {
          await store.delete(id);
        }
        rethrow;
      }
      securePhrase = plaintextPhrase;
    }

    if (securePhrase == null || securePhrase.trim().isEmpty) {
      throw StateError(
        'Recovery phrase is missing from platform secure storage for account '
        '$id.',
      );
    }
    return CliConfig(mnemonic: securePhrase, serverAddress: serverAddress);
  }

  static Future<AccountSummary> _requireSummary(String id) async {
    final accounts = await listAccounts();
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    throw StateError('no account registered with id $id');
  }

  static Future<AccountSyncMetadata> loadSyncMetadata(String id) async {
    await _requireSummary(id);
    final file = File(accountSyncMetadataPath(id));
    if (!await file.exists()) return const AccountSyncMetadata();
    final content = await file.readAsString();
    if (content.trim().isEmpty) return const AccountSyncMetadata();
    final decoded = jsonDecode(content) as Map<String, Object?>;
    return AccountSyncMetadata.fromJson(decoded);
  }

  static Future<void> saveSyncMetadata(
    String id,
    AccountSyncMetadata metadata,
  ) async {
    await _requireSummary(id);
    await Directory(accountDir(id)).create(recursive: true);
    await _writeFileAtomically(
      accountSyncMetadataPath(id),
      jsonEncode(metadata.toJson()),
    );
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
    bool pendingStarterTemplate = false,
  }) async {
    final id = await AccountProfile.deriveAccountId(mnemonic);
    return _createAccountWithId(
      id: id,
      mnemonic: mnemonic,
      displayName: displayName,
      serverAddress: serverAddress,
      pendingStarterTemplate: pendingStarterTemplate,
    );
  }

  /// Creates an account only when its mnemonic-derived ID is not registered.
  /// Returns null without touching the existing account when the ID collides.
  static Future<AccountProfile?> createAccountIfNew({
    required String mnemonic,
    required String displayName,
    String serverAddress = '127.0.0.1:33020',
    Set<String> excludedAccountIds = const <String>{},
    bool pendingStarterTemplate = false,
  }) async {
    final id = await AccountProfile.deriveAccountId(mnemonic);
    if (excludedAccountIds.contains(id)) return null;
    final accounts = await listAccounts();
    if (accounts.any((account) => account.id == id)) return null;
    return _createAccountWithId(
      id: id,
      mnemonic: mnemonic,
      displayName: displayName,
      serverAddress: serverAddress,
      pendingStarterTemplate: pendingStarterTemplate,
    );
  }

  static Future<AccountProfile> _createAccountWithId({
    required String id,
    required String mnemonic,
    required String displayName,
    required String serverAddress,
    required bool pendingStarterTemplate,
  }) async {
    final dir = Directory(accountDir(id));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final createdAt = DateTime.now().toUtc();
    final store = _recoveryPhraseStore;
    var securePhraseWritten = false;
    try {
      if (store != null) {
        await store.write(id, mnemonic);
        securePhraseWritten = true;
      }
      await _writeFileAtomically(
        accountConfigPath(id),
        encodeCliConfig(
          mnemonic: store == null ? mnemonic : null,
          serverAddress: serverAddress,
          usesPlatformRecoveryPhrase: store != null,
        ),
      );

      await registerAccount(AccountSummary(
        id: id,
        displayName: displayName,
        createdAt: createdAt,
        pendingStarterTemplate: pendingStarterTemplate,
      ));
    } catch (_) {
      if (securePhraseWritten) {
        await store!.delete(id);
      }
      await _deleteFileIfPresent(accountConfigPath(id));
      final children = await dir.list().toList();
      if (children.isEmpty) await dir.delete();
      rethrow;
    }

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

  static Future<void> _writeFileAtomically(String path, String content) async {
    final target = File(path);
    await target.parent.create(recursive: true);
    final temporary = File(
      '$path.tmp-${DateTime.now().microsecondsSinceEpoch}-${pid.toString()}',
    );
    try {
      await temporary.writeAsString(content, flush: true);
      await temporary.rename(path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
