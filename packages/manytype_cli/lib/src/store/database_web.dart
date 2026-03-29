import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

Future<QueryExecutor> openDatabaseForApp(String dbPath) async {
  final result = await WasmDatabase.open(
    databaseName: dbPath,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return result.resolvedExecutor;
}

/// When set, [openDatabaseForTesting] loads sqlite3.wasm from this URI and
/// constructs an in-memory-backed [WasmDatabase] directly instead of calling
/// [WasmDatabase.open], which requires a same-origin drift worker script that
/// `dart test -p chrome` cannot serve (see D019/D019-adjacent pattern). Tests
/// that need real persistence use `IndexedDbFileSystem` directly instead
/// (see test/web/persistence_test.dart); tests that only need a functioning
/// in-session database set this to run against an in-memory VFS.
Uri? webTestSqlite3Uri;

WasmSqlite3? _testSqlite3;

Future<QueryExecutor> openDatabaseForTesting({String? name}) async {
  final overrideUri = webTestSqlite3Uri;
  if (overrideUri != null) {
    final sqlite = _testSqlite3 ??=
        await WasmSqlite3.loadFromUrl(overrideUri);
    sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
    return WasmDatabase.inMemory(sqlite);
  }
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
