import 'active_account.dart';
import 'commands/file_transfer.dart';
import 'config.dart';
import 'identity.dart';
import 'store/database.dart';

/// Composition root for the library-facing API surface (M016).
///
/// Resolves the active account, opens its database, and derives its
/// identity once, then exposes per-domain facades (`session.fileTransfer`,
/// and more as each `commands/*.dart` module is converted) over that shared
/// state. CLI entry points and non-CLI consumers both build one of these
/// instead of re-deriving config/db/identity per call.
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

  Future<void> close() => db.close();
}
