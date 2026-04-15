import 'package:args/args.dart';
import 'package:manytype_core/manytype_core.dart' show generateMnemonic;

import '../account_profile.dart';
import '../account_registry.dart';
import '../account_resolver.dart';
import '../session.dart';

/// Result of [createAccountCommand].
class AccountCreateResult {
  const AccountCreateResult({
    required this.id,
    required this.displayName,
    required this.configPath,
    required this.isCurrent,
  });

  final String id;
  final String displayName;
  final String configPath;
  final bool isCurrent;
}

/// Result of [useAccountCommand].
class AccountUseResult {
  const AccountUseResult({required this.id});

  final String id;
}

/// Result of [removeAccountCommand].
class AccountRemoveResult {
  const AccountRemoveResult({required this.id});

  final String id;
}

/// Create a new local account profile, selecting it as current if it's the
/// only one registered.
Future<AccountCreateResult> createAccountCommand({String? name}) async {
  final displayName = name ?? 'default';
  final mnemonic = generateMnemonic();
  final profile = await AccountRegistry.createAccount(
    mnemonic: mnemonic,
    displayName: displayName,
  );

  final accounts = await AccountRegistry.listAccounts();
  final isCurrent = accounts.length == 1;
  if (isCurrent) {
    await AccountRegistry.setCurrentAccountId(profile.id);
  }

  return AccountCreateResult(
    id: profile.id,
    displayName: displayName,
    configPath: AccountRegistry.accountConfigPath(profile.id),
    isCurrent: isCurrent,
  );
}

/// List all known account summaries, in registration order.
Future<List<AccountSummary>> listAccountsCommand() =>
    AccountRegistry.listAccounts();

/// Select [idOrName] as the current account.
///
/// Throws [AmbiguousAccountError] or [NoAccountError] if it can't be
/// resolved to exactly one account.
Future<AccountUseResult> useAccountCommand(String idOrName) async {
  final resolvedId = await AccountResolver.resolveAccountId(
    explicitAccountId: idOrName,
  );
  await AccountRegistry.setCurrentAccountId(resolvedId);
  return AccountUseResult(id: resolvedId);
}

/// Resolve and return the current account's summary.
///
/// Throws [AmbiguousAccountError] or [NoAccountError] if it can't be
/// resolved to exactly one account.
Future<AccountSummary> currentAccountCommand({String? envAccountId}) async {
  final resolvedId = await AccountResolver.resolveAccountId(
    envAccountId: envAccountId,
  );
  final accounts = await AccountRegistry.listAccounts();
  return accounts.firstWhere((a) => a.id == resolvedId);
}

/// Remove a local account profile (and its on-disk directory).
///
/// Local profile removal only: never the protocol-level `AccountDelete`
/// coordinator teardown operation.
///
/// Throws [StateError] if no account matches [id].
Future<AccountRemoveResult> removeAccountCommand(String id) async {
  final accounts = await AccountRegistry.listAccounts();
  if (accounts.every((a) => a.id != id)) {
    throw StateError('No account found matching "$id".');
  }
  await AccountRegistry.removeAccount(id);
  return AccountRemoveResult(id: id);
}

/// Library-facing facade over account-profile management, for consumers
/// that hold a [ManytypeSession] instead of driving the CLI directly.
/// Exposed as `session.accounts`. Unlike the other domain facades this one
/// doesn't touch [ManytypeSession.db]/[ManytypeSession.config]: account
/// profiles are managed in the shared registry, ahead of any particular
/// session being opened: but it's grouped under the session for a
/// consistent `session.<domain>.<verb>(...)` call shape.
class AccountsFacade {
  const AccountsFacade(this._session);

  // ignore: unused_field
  final ManytypeSession _session;

  Future<AccountCreateResult> create({String? name}) =>
      createAccountCommand(name: name);

  Future<List<AccountSummary>> list() => listAccountsCommand();

  Future<AccountUseResult> use(String idOrName) =>
      useAccountCommand(idOrName);

  Future<AccountSummary> current({String? envAccountId}) =>
      currentAccountCommand(envAccountId: envAccountId);

  Future<AccountRemoveResult> remove(String id) => removeAccountCommand(id);
}

/// Builds the `account` command's ArgParser, including its subcommands.
ArgParser buildAccountParser() {
  final createParser = ArgParser()
    ..addOption('name', help: 'Display name for the new account');
  final parser = ArgParser()
    ..addCommand('create', createParser)
    ..addCommand('list')
    ..addCommand('use')
    ..addCommand('current')
    ..addCommand('remove');
  return parser;
}
