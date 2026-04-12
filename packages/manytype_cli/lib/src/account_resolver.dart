import 'account_registry.dart';

/// Raised when account selection is ambiguous (multiple candidates match,
/// or multiple accounts exist with no way to disambiguate).
class AmbiguousAccountError extends StateError {
  AmbiguousAccountError(super.message);
}

/// Raised when no account can be resolved at all.
class NoAccountError extends StateError {
  NoAccountError(super.message);
}

/// Resolves which account is "active" for a CLI invocation.
///
/// Precedence (highest first):
/// 1. An explicit `--account <id|name>` value
/// 2. The `MANYTYPE_ACCOUNT` environment variable (caller-supplied, since
///    reading `Platform.environment` is a native/vm-only concern)
/// 3. The persisted "current" pointer (`manytype account use <id|name>`)
/// 4. Auto-select if exactly one account profile exists
/// 5. Otherwise: error: ambiguous (2+ profiles) or none (0 profiles)
class AccountResolver {
  static Future<String> resolveAccountId({
    String? explicitAccountId,
    String? envAccountId,
  }) async {
    if (explicitAccountId != null && explicitAccountId.isNotEmpty) {
      return _resolveIdOrName(explicitAccountId);
    }
    if (envAccountId != null && envAccountId.isNotEmpty) {
      return _resolveIdOrName(envAccountId);
    }

    final current = await AccountRegistry.getCurrentAccountId();
    if (current != null && current.isNotEmpty) {
      return current;
    }

    final accounts = await AccountRegistry.listAccounts();
    if (accounts.isEmpty) {
      throw NoAccountError(
        'No accounts exist. Run: manytype account create --name <name>',
      );
    }
    if (accounts.length == 1) {
      return accounts.single.id;
    }
    throw AmbiguousAccountError(
      'Multiple accounts exist and none is selected. Use --account <id|name>, '
      'set MANYTYPE_ACCOUNT, or run: manytype account use <id|name>',
    );
  }

  static Future<String> _resolveIdOrName(String idOrName) async {
    final accounts = await AccountRegistry.listAccounts();

    final byId = accounts.where((a) => a.id == idOrName);
    if (byId.isNotEmpty) {
      return byId.first.id;
    }

    final byName = accounts.where((a) => a.displayName == idOrName);
    if (byName.length == 1) {
      return byName.first.id;
    }
    if (byName.length > 1) {
      throw AmbiguousAccountError(
        'Multiple accounts are named "$idOrName"; use an explicit account id instead.',
      );
    }

    throw NoAccountError('No account found matching "$idOrName".');
  }
}
