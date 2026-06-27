import 'package:hooks_riverpod/hooks_riverpod.dart';
// AccountRegistry/AccountProfile are not re-exported by the manytype_cli
// barrel; import them from src the same way the package's own tests do.
// ignore: implementation_imports
import 'package:manytype_cli/src/account_profile.dart';
// ignore: implementation_imports
import 'package:manytype_cli/src/account_registry.dart';

/// All account profiles known to this install (registry summaries only:
/// mnemonics never leave each account's own config).
final accountsProvider = FutureProvider<List<AccountSummary>>((ref) {
  return AccountRegistry.listAccounts();
});

/// The persisted "current account" pointer, or null before onboarding.
final currentAccountIdProvider = FutureProvider<String?>((ref) {
  return AccountRegistry.getCurrentAccountId();
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

  /// Forgets [id]: removes the profile from the registry on this device.
  /// The recovery phrase remains the only way to bring the account back.
  Future<void> forget(String id) async {
    final current = await AccountRegistry.getCurrentAccountId();
    await AccountRegistry.removeAccount(id);
    if (current == id) {
      await AccountRegistry.setCurrentAccountId('');
    }
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
