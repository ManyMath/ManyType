import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

/// Test-only override for [openDatabaseForApp]'s asset URIs. A real deployed
/// web app serves `sqlite3.wasm`/`drift_worker.dart.js` at its own origin
/// root, so the relative-path defaults below resolve correctly; `dart test
/// -p chrome` has no such root to serve them from, so tests point this at
/// wherever they've actually served the assets (e.g.
/// test/web/asset_server.dart) instead. See [webTestSqlite3Uri] for the
/// analogous override on [openDatabaseForTesting].
({Uri sqlite3, Uri driftWorker})? webAppAssetUriOverride;

Future<QueryExecutor> openDatabaseForApp(String dbPath) async {
  final result = await openWasmDatabaseForApp(dbPath);
  return result.resolvedExecutor;
}

/// Diagnostic variant of [openDatabaseForApp] that exposes the full
/// [WasmDatabaseResult]: chiefly [WasmDatabaseResult.chosenImplementation]
/// and [WasmDatabaseResult.missingFeatures]: instead of just the resolved
/// executor. `dart test -p chrome` cannot load a cross-origin drift worker
/// script, so tests that override [webAppAssetUriOverride] with an
/// asset-server URI on a different port see `chosenImplementation ==
/// WasmStorageImplementation.inMemory` (see persistence_test.dart's R037
/// note); a real deployment serves the worker same-origin and gets a
/// durable implementation (OPFS-backed when available, IndexedDB
/// otherwise).
Future<WasmDatabaseResult> openWasmDatabaseForApp(String dbPath) {
  final override = webAppAssetUriOverride;
  return WasmDatabase.open(
    databaseName: dbPath,
    sqlite3Uri: override?.sqlite3 ?? Uri.parse('sqlite3.wasm'),
    driftWorkerUri: override?.driftWorker ?? Uri.parse('drift_worker.dart.js'),
  );
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
