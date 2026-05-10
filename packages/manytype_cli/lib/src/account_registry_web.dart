import 'dart:convert';

import 'package:web/web.dart' as web;

import 'account_profile.dart';
import 'config.dart';

/// Web account registry backed by `window.localStorage`:
/// - `<prefix>:accounts`: JSON index of known account summaries
/// - `<prefix>:current`: the currently-selected account id
/// - `<prefix>:account:<id>:mnemonic` / `:server`: that account's secret
///   material (there is no config.toml on web; localStorage plays the same
///   role a flat file plays on native)
///
/// Each account maps to its own OPFS/IndexedDB-backed Drift database via
/// [accountDbPath], reusing the existing `WasmDatabase.open(databaseName:)`
/// seam: a distinct name is a distinct database, with no schema change
/// needed relative to the single-account web opener from M014.
class AccountRegistry {
  /// Test-only override for the localStorage key prefix, so `dart test -p
  /// chrome` runs don't share state across tests in the same browser
  /// session. Defaults to `'manytype'` for real use.
  static String keyPrefix = 'manytype';

  /// Unused on web (there is no native filesystem base dir); declared to
  /// keep the conditional-export API surface identical to
  /// account_registry_native.dart's [testBaseDirOverride].
  static String? testBaseDirOverride;

  static String get _accountsKey => '$keyPrefix:accounts';
  static String get _currentKey => '$keyPrefix:current';
  static String _mnemonicKey(String id) => '$keyPrefix:account:$id:mnemonic';
  static String _serverKey(String id) => '$keyPrefix:account:$id:server';

  static web.Storage get _storage => web.window.localStorage;

  static String accountDir(String id) => 'accounts/$id';
  static String accountConfigPath(String id) => 'accounts/$id/config';

  /// Per-account OPFS/IndexedDB database name (passed straight to
  /// `WasmDatabase.open(databaseName: ...)`).
  static String accountDbPath(String id) => '$keyPrefix-account-$id';

  static Future<List<AccountSummary>> listAccounts() async {
    final raw = _storage.getItem(_accountsKey);
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final accounts = (decoded['accounts'] as List<dynamic>? ?? [])
        .map((e) => AccountSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    return accounts;
  }

  static void _writeAccounts(List<AccountSummary> accounts) {
    final encoded = jsonEncode({
      'accounts': accounts.map((a) => a.toJson()).toList(),
    });
    _storage.setItem(_accountsKey, encoded);
  }

  static Future<void> registerAccount(AccountSummary summary) async {
    final accounts = await listAccounts();
    final withoutExisting = accounts.where((a) => a.id != summary.id).toList();
    _writeAccounts([...withoutExisting, summary]);
  }

  /// Remove an account's registry entry and secret material. This is local
  /// profile removal only: never the protocol-level AccountDelete
  /// operation. Does not delete the account's OPFS/IndexedDB database
  /// contents (callers that need that should drop the database by name via
  /// [accountDbPath] themselves).
  static Future<void> removeAccount(String id) async {
    final accounts = await listAccounts();
    _writeAccounts(accounts.where((a) => a.id != id).toList());
    _storage.removeItem(_mnemonicKey(id));
    _storage.removeItem(_serverKey(id));

    final currentId = await getCurrentAccountId();
    if (currentId == id) {
      _storage.removeItem(_currentKey);
    }
  }

  /// Load an account's config (mnemonic + server address) from localStorage
  ///: the web counterpart to native's `CliConfig.loadFrom(config.toml)`,
  /// since there is no config.toml on web. Throws [StateError] if no
  /// account is registered under [id].
  static Future<CliConfig> loadConfig(String id,
      {String? serverOverride}) async {
    final mnemonic = _storage.getItem(_mnemonicKey(id));
    if (mnemonic == null) {
      throw StateError('no account registered with id $id');
    }
    final storedServer = _storage.getItem(_serverKey(id));
    return CliConfig(
      mnemonic: mnemonic,
      serverAddress: serverOverride ?? storedServer ?? '127.0.0.1:33020',
    );
  }

  static Future<String?> getCurrentAccountId() async {
    final value = _storage.getItem(_currentKey);
    return (value == null || value.isEmpty) ? null : value;
  }

  static Future<void> setCurrentAccountId(String id) async {
    _storage.setItem(_currentKey, id);
  }

  static Future<AccountProfile> createAccount({
    required String mnemonic,
    required String displayName,
    String serverAddress = '127.0.0.1:33020',
  }) async {
    final id = await AccountProfile.deriveAccountId(mnemonic);
    _storage.setItem(_mnemonicKey(id), mnemonic);
    _storage.setItem(_serverKey(id), serverAddress);

    final createdAt = DateTime.now().toUtc();
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

  /// There is no pre-existing native single-account layout to migrate from
  /// on web: this method exists only to keep the conditional-export API
  /// surface identical to account_registry_native.dart's
  /// [migrateLegacyAccount].
  static Future<AccountProfile?> migrateLegacyAccount({
    required String legacyConfigPath,
    required String legacyDbPath,
    required String legacyMnemonic,
    String displayName = 'default',
  }) async {
    throw UnsupportedError(
      'legacy account migration is a native-only concept; web has no '
      'pre-existing single-account layout to migrate from',
    );
  }
}
