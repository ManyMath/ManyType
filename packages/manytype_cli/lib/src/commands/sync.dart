import '../config.dart';
import '../session.dart';
import '../store/database.dart';
import '../sync_service.dart';

Future<void> syncCommand(
  ManytypeDatabase db,
  CliConfig config, {
  String? networkConfigPath,
}) async {
  final syncService = SyncService();
  await syncService.sync(db, config, networkConfigPath: networkConfigPath);
}

Future<void> seedLiveSpaceForSync(
  ManytypeDatabase db,
  CliConfig config, {
  required String networkConfigPath,
}) async {
  final syncService = SyncService();
  await syncService.seedLiveSpaceForSync(db, config,
      networkConfigPath: networkConfigPath);
}

/// Library-facing facade over head sync against the network, for consumers
/// that hold a [ManytypeSession] instead of driving the CLI directly.
/// Exposed as `session.sync`.
class SyncFacade {
  const SyncFacade(this._session);

  final ManytypeSession _session;

  Future<void> run({String? networkConfigPath}) {
    return syncCommand(
      _session.db,
      _session.config,
      networkConfigPath: networkConfigPath,
    );
  }
}
