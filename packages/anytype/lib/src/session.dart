import 'account_registry.dart';
import 'active_account.dart';
import 'commands/account.dart';
import 'commands/account_delete.dart';
import 'commands/acl_lifecycle.dart';
import 'commands/consensus_flow.dart';
import 'commands/file_transfer.dart';
import 'commands/list.dart';
import 'commands/probe_file_node.dart';
import 'commands/probe_network.dart';
import 'commands/space_delete.dart';
import 'commands/space_pull_flow.dart';
import 'commands/sync.dart';
import 'config.dart';
import 'identity.dart';
import 'store/database.dart';

/// Composition root for the library-facing API (M016).
///
/// Resolves the active account, opens its database, and derives its
/// identity once, then exposes per-domain facades (`session.fileTransfer`,
/// `session.objects`, `session.sync`, and one per remaining
/// `commands/*.dart` module) over that shared state. CLI entry points and
/// non-CLI consumers both build one of these instead of re-deriving
/// config/db/identity per call.
class ManytypeSession {
  ManytypeSession({
    required this.db,
    required this.config,
    required this.identity,
  });

  final ManytypeDatabase db;
  final CliConfig config;
  final Identity identity;
  Future<void>? _closeOperation;

  /// Resolves the active account (see [resolveActiveAccount]) and opens a
  /// session against its config/db. Native/vm only: [resolveActiveAccount]
  /// reads `~/.manytype`, which has no web equivalent; web callers use
  /// [openWeb] instead.
  ///
  /// [dbOverride], if given, is used instead of opening
  /// [ManytypeDatabase]'s real on-disk file at [active.dbPath] --
  /// [ManytypeDatabase]'s default constructor opens the database on a real
  /// background isolate (`NativeDatabase.createInBackground`), which never
  /// completes under Flutter's `testWidgets()` zone (confirmed: identical
  /// code opens instantly in a plain `test()`, hangs indefinitely in
  /// `testWidgets()`, with no Riverpod/UI involved). Widget tests that need
  /// a real session should pass `ManytypeDatabase.forTesting(await
  /// openDatabaseForTesting())` here instead, mirroring the seam
  /// `manytype_cli`'s own package tests already use.
  static Future<ManytypeSession> open({
    String? accountOverride,
    String? envAccountId,
    String? serverOverride,
    ManytypeDatabase? dbOverride,
  }) async {
    final active = await resolveActiveAccount(
      accountOverride: accountOverride,
      envAccountId: envAccountId,
      serverOverride: serverOverride,
    );
    final identity = await Identity.fromMnemonic(active.config.mnemonic);
    return ManytypeSession(
      db: dbOverride ?? ManytypeDatabase(active.dbPath),
      config: active.config,
      identity: identity,
    );
  }

  /// Web counterpart to [open]: builds a session for an account already
  /// registered via [AccountRegistry.createAccount] (there is no
  /// `~/.manytype` filesystem to resolve an active account from on web, so
  /// callers pass [accountId] explicitly instead of relying on a persisted
  /// "current" pointer). Loads that account's config via
  /// [AccountRegistry.loadConfig] and opens its OPFS/IndexedDB-backed
  /// database via [AccountRegistry.accountDbPath]: the same
  /// [ManytypeDatabase] default constructor [open] uses, now reachable on
  /// web (M017).
  ///
  /// Works on native too (same [AccountRegistry] API on both platforms),
  /// but [open] is the natural choice there since it also handles legacy
  /// single-account migration; this exists for web hosts that manage
  /// account selection themselves rather than through a CLI-style "current
  /// account" pointer.
  ///
  /// [onWebStorageDiagnostics], if given, is forwarded to the
  /// [ManytypeDatabase] constructor: see its doc comment.
  static Future<ManytypeSession> openWeb({
    required String accountId,
    String? serverOverride,
    WebStorageDiagnosticsCallback? onWebStorageDiagnostics,
  }) async {
    final config = await AccountRegistry.loadConfig(
      accountId,
      serverOverride: serverOverride,
    );
    final identity = await Identity.fromMnemonic(config.mnemonic);
    return ManytypeSession(
      db: ManytypeDatabase(
        AccountRegistry.accountDbPath(accountId),
        onWebStorageDiagnostics: onWebStorageDiagnostics,
      ),
      config: config,
      identity: identity,
    );
  }

  FileTransferFacade get fileTransfer => FileTransferFacade(this);

  ListFacade get objects => ListFacade(this);

  ProbeFileNodeFacade get probeFileNode => ProbeFileNodeFacade(this);

  AccountsFacade get accounts => AccountsFacade(this);

  AccountDeleteFacade get accountDelete => AccountDeleteFacade(this);

  ProbeNetworkFacade get probeNetwork => ProbeNetworkFacade(this);

  SpaceDeleteFacade get spaceDelete => SpaceDeleteFacade(this);

  AclLifecycleFacade get aclLifecycle => AclLifecycleFacade(this);

  ConsensusFlowFacade get consensus => ConsensusFlowFacade(this);

  SpacePullFlowFacade get spacePull => SpacePullFlowFacade(this);

  SyncFacade get sync => SyncFacade(this);

  /// Closes the underlying database exactly once.
  ///
  /// Riverpod disposal can race an explicit close performed before local
  /// account deletion. Sharing the same future keeps that cleanup idempotent.
  Future<void> close() => _closeOperation ??= db.close();
}
