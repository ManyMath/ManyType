import 'package:hooks_riverpod/hooks_riverpod.dart';
// AccountRegistry/AccountProfile are not re-exported by the manytype_cli
// barrel; import them from src the same way the package's own tests do.
// ignore: implementation_imports
import 'package:manytype_cli/src/account_profile.dart';
// ignore: implementation_imports
import 'package:manytype_cli/src/account_registry.dart';

import 'legacy_account_bootstrap.dart';
import 'session_provider.dart';
import 'sync_controller.dart';

/// All account profiles known to this install (registry summaries only:
/// mnemonics never leave each account's own config).
final accountsProvider = FutureProvider<List<AccountSummary>>((ref) {
  return AccountRegistry.listAccounts();
});

/// The persisted "current account" pointer, or null before onboarding.
///
/// Native installs created before the account registry existed only have a
/// top-level config and database. Resolve that legacy identity here so the
/// root gate migrates it before deciding whether to show onboarding.
final currentAccountIdProvider = FutureProvider<String?>((ref) async {
  final currentId = await AccountRegistry.getCurrentAccountId();
  if (currentId != null) {
    return currentId;
  }
  if ((await AccountRegistry.listAccounts()).isNotEmpty) {
    return null;
  }
  return bootstrapLegacyAccountIfPresent();
});

/// Summary of the current account (display name for the header), if any.
final currentAccountProvider = FutureProvider<AccountSummary?>((ref) async {
  final id = await ref.watch(currentAccountIdProvider.future);
  if (id == null) {
    return null;
  }
  final accounts = await ref.watch(accountsProvider.future);
  for (final account in accounts) {
    if (account.id == id) {
      return account;
    }
  }
  return null;
});

/// Mutations on the account registry. Core exposes plain Futures, no
/// streams, so each mutation invalidates the read providers afterwards and
/// the GUI re-queries.
class AccountsController {
  AccountsController(this._ref);

  final Ref _ref;

  /// Registers a new account for [mnemonic] and makes it current.
  ///
  /// CPU-heavy: deriving the account id runs `Identity.fromMnemonic`
  /// (PBKDF2 + SLIP-0010). Callers show progress while awaiting.
  Future<AccountProfile> createAndSelect({
    required String mnemonic,
    required String displayName,
  }) async {
    final profile = await AccountRegistry.createAccount(
      mnemonic: mnemonic,
      displayName: displayName,
    );
    await AccountRegistry.setCurrentAccountId(profile.id);
    _invalidate();
    return profile;
  }

  /// Creates and selects an account only when [mnemonic] is a new identity.
  /// A collision returns null without reopening or overwriting the account.
  Future<AccountProfile?> createAndSelectIfNew({
    required String mnemonic,
    required String displayName,
    Set<String> excludedAccountIds = const <String>{},
    bool pendingStarterTemplate = false,
  }) async {
    final profile = await AccountRegistry.createAccountIfNew(
      mnemonic: mnemonic,
      displayName: displayName,
      excludedAccountIds: excludedAccountIds,
      pendingStarterTemplate: pendingStarterTemplate,
    );
    if (profile == null) return null;
    await AccountRegistry.setCurrentAccountId(profile.id);
    _invalidate();
    return profile;
  }

  /// Clears the durable recovery marker after a starter template seed has
  /// completed. Only the account list changes; the open session remains valid.
  Future<void> completeStarterTemplate(String id) async {
    await AccountRegistry.setStarterTemplatePending(id, false);
    _ref.invalidate(accountsProvider);
  }

  Future<void> select(String id) async {
    await AccountRegistry.setCurrentAccountId(id);
    _invalidate();
  }

  /// Clears the current-account pointer so the root gate returns to the
  /// account picker. Both registry backends read an empty pointer as
  /// "no current account"; the account itself stays registered.
  Future<void> deselect() async {
    await AccountRegistry.setCurrentAccountId('');
    _invalidate();
  }

  /// Renames [id]'s display name. Only the account list changes; the
  /// current account and its open session remain valid.
  Future<void> rename(String id, String displayName) async {
    await AccountRegistry.renameAccount(id, displayName);
    _ref.invalidate(accountsProvider);
  }

  /// Updates [id]'s server address. Reopens the session (if it's the
  /// current account) so subsequent calls use the new address.
  Future<void> updateServerAddress(String id, String serverAddress) async {
    await AccountRegistry.updateServerAddress(id, serverAddress);
    _ref.invalidate(sessionProvider);
  }

  /// Forgets [id]: removes the profile from the registry on this device.
  /// The recovery phrase remains the only way to bring the account back.
  Future<void> forget(String id) async {
    final current = await AccountRegistry.getCurrentAccountId();
    if (current == id) {
      // A workspace that failed to open still needs to be forgettable. In
      // that case there is no usable session to close before storage removal.
      final session = await _ref
          .read(sessionProvider.future)
          .catchError((_) => null);
      await session?.close();
    }

    try {
      await AccountRegistry.removeAccount(id);
    } catch (_) {
      // Storage deletion is attempted before registry removal.
      // If it fails, reopen the closed current session and leave the account
      // fully registered so the user can retry.
      if (current == id) {
        _ref.invalidate(sessionProvider);
      }
      rethrow;
    }

    _ref.invalidate(syncControllerProvider(id));
    _invalidate();
  }

  void _invalidate() {
    _ref.invalidate(accountsProvider);
    _ref.invalidate(currentAccountIdProvider);
  }
}

final accountsControllerProvider = Provider<AccountsController>(
  AccountsController.new,
);
