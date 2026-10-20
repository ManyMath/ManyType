import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

import 'web_storage_diagnostics.dart';

/// Storage implementations drift documents as safe when the same database is
/// opened in multiple tabs at once (see `WasmStorageImplementation`'s
/// doc-comments). `unsafeIndexedDb` and `inMemory` are excluded.
const _multiTabSafeImplementations = {
  WasmStorageImplementation.opfsShared,
  WasmStorageImplementation.opfsLocks,
  WasmStorageImplementation.sharedIndexedDb,
};

/// Maps drift's [WasmDatabaseResult] onto the platform-agnostic
/// [WebStorageDiagnostics] surfaced through [openDatabaseForApp].
WebStorageDiagnostics webStorageDiagnosticsFromWasmResult(
    WasmDatabaseResult result) {
  return WebStorageDiagnostics(
    implementationName: result.chosenImplementation.name,
    isDurable:
        result.chosenImplementation != WasmStorageImplementation.inMemory,
    isMultiTabSafe:
        _multiTabSafeImplementations.contains(result.chosenImplementation),
    missingFeatures: result.missingFeatures.map((f) => f.name).toList(),
  );
}

/// Test-only override for [openDatabaseForApp]'s asset URIs. A real deployed
/// web app serves `sqlite3.wasm`/`drift_worker.dart.js` at its own origin
/// root, so the relative-path defaults below resolve correctly; `dart test
/// -p chrome` has no such root to serve them from, so tests point this at
/// wherever they've served the assets (e.g.
/// test/web/asset_server.dart) instead. See [webTestSqlite3Uri] for the
/// analogous override on [openDatabaseForTesting].
({Uri sqlite3, Uri driftWorker})? webAppAssetUriOverride;

/// Test hook for browser storage deletion. Production always uses drift's
/// storage probe so both OPFS and IndexedDB databases are covered.
Future<void> Function(String databaseName)? webDatabaseDeleteOverride;

Future<QueryExecutor> openDatabaseForApp(String dbPath,
    {WebStorageDiagnosticsCallback? onWebStorageDiagnostics}) async {
  final result = await openWasmDatabaseForApp(dbPath);
  onWebStorageDiagnostics?.call(webStorageDiagnosticsFromWasmResult(result));
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

/// Deletes every durable web database named [databaseName].
///
/// The caller must close all local connections first. Drift's probe reports
/// whether the named database lives in OPFS or IndexedDB and provides the
/// matching deletion operation for either backend. A blocked deletion times
/// out with an actionable error instead of removing account metadata while
/// leaving the workspace recoverable under the same identity.
Future<void> deleteWebDatabaseForApp(String databaseName) async {
  final override = webDatabaseDeleteOverride;
  if (override != null) {
    return override(databaseName);
  }

  const timeout = Duration(seconds: 15);
  try {
    await _deleteWebDatabaseForApp(databaseName).timeout(timeout);
  } on TimeoutException {
    throw StateError(
      'Local workspace deletion was blocked. Close other ManyType tabs and '
      'try again.',
    );
  } catch (error) {
    throw StateError(
      'Could not delete the local workspace. Close other ManyType tabs and '
      'try again. ($error)',
    );
  }
}

Future<void> _deleteWebDatabaseForApp(String databaseName) async {
  final override = webAppAssetUriOverride;
  final probe = await WasmDatabase.probe(
    sqlite3Uri: override?.sqlite3 ?? Uri.parse('sqlite3.wasm'),
    driftWorkerUri: override?.driftWorker ?? Uri.parse('drift_worker.dart.js'),
    databaseName: databaseName,
  );
  final matches = probe.existingDatabases
      .where((database) => database.$2 == databaseName)
      .toList(growable: false);

  final couldInspectDurableStorage = probe.availableStorages.any(
    (storage) => storage.storageApi != null,
  );
  if (matches.isEmpty &&
      !couldInspectDurableStorage &&
      probe.missingFeatures.contains(MissingBrowserFeature.workerError)) {
    throw StateError(
      'The browser storage worker could not inspect local workspace data.',
    );
  }

  for (final database in matches) {
    await probe.deleteDatabase(database);
  }
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
    final sqlite = _testSqlite3 ??= await WasmSqlite3.loadFromUrl(overrideUri);
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
