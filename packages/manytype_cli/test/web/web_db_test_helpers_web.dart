import 'package:manytype_cli/src/store/database_web.dart' as database_web;
import 'package:test/test.dart';

bool _configured = false;

/// Spawns the shared asset server (test/web/asset_server.dart) once and
/// points [database_web.webTestSqlite3Uri] at it, so `openDatabaseForTesting`
/// can load sqlite3.wasm under `dart test -p chrome` without relying on
/// WasmDatabase.open's same-origin drift worker requirement.
Future<void> configureWebTestDatabaseAssets() async {
  if (_configured) return;
  _configured = true;
  final channel = spawnHybridUri('/test/web/asset_server.dart');
  final port = (await channel.stream.first as num).toInt();
  database_web.webTestSqlite3Uri =
      Uri.parse('http://localhost:$port/sqlite3.wasm');
}
