import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> openDatabaseForApp(String dbPath) async {
  final result = await WasmDatabase.open(
    databaseName: dbPath,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return result.resolvedExecutor;
}

Future<QueryExecutor> openDatabaseForTesting({String? name}) async {
  final result = await openWasmDatabaseForTesting(name: name);
  return result.resolvedExecutor;
}

Future<WasmDatabaseResult> openWasmDatabaseForTesting({String? name}) {
  return WasmDatabase.open(
    databaseName: name ?? 'manytype-cli-test',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
}
