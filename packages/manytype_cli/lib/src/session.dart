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

/// Composition root for the library-facing API surface (M016).
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

  /// Resolves the active account (see [resolveActiveAccount]) and opens a
  /// session against its config/db. Native/vm only — on web, construct a
  /// [CliConfig] and [ManytypeDatabase] directly and use the default
  /// constructor instead.
  static Future<ManytypeSession> open({
    String? accountOverride,
    String? envAccountId,
    String? serverOverride,
  }) async {
    final active = await resolveActiveAccount(
      accountOverride: accountOverride,
      envAccountId: envAccountId,
      serverOverride: serverOverride,
    );
    final identity = await Identity.fromMnemonic(active.config.mnemonic);
    return ManytypeSession(
      db: ManytypeDatabase(active.dbPath),
      config: active.config,
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

  Future<void> close() => db.close();
}
