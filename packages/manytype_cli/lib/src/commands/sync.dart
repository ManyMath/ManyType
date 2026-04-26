import '../config.dart';
import '../session.dart';
import '../store/database.dart';
import '../sync_service.dart';

Future<void> syncCommand(
  ManytypeDatabase db,
  CliConfig config, {
  String? networkConfigPath,
  String? networkConfigContent,
}) async {
  final syncService = SyncService();
  await syncService.sync(
    db,
    config,
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
  );
}

Future<void> seedLiveSpaceForSync(
  ManytypeDatabase db,
  CliConfig config, {
  String? networkConfigPath,
  String? networkConfigContent,
}) async {
  final syncService = SyncService();
  await syncService.seedLiveSpaceForSync(
    db,
    config,
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
  );
}

/// Library-facing facade over head sync against the network, for consumers
/// that hold a [ManytypeSession] instead of driving the CLI directly.
/// Exposed as `session.sync`.
class SyncFacade {
  const SyncFacade(this._session);

  final ManytypeSession _session;

  Future<void> run({
    String? networkConfigPath,
    String? networkConfigContent,
  }) {
    return syncCommand(
      _session.db,
      _session.config,
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
    );
  }
}
