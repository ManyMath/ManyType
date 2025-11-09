
import '../../manytype_cli.dart';
import '../config.dart';
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
