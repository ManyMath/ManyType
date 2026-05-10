@TestOn('browser')
library;

// M014/S05 integrated acceptance: proves the real flow through the public
// library entrypoint (package:manytype_cli/manytype_cli.dart): open a
// database on IndexedDB, write an object, close, reopen, verify persistence.
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:sqlite3/wasm.dart';
import 'package:test/test.dart';

late int _assetServerPort;
WasmSqlite3? _sqlite3;

Future<WasmSqlite3> _loadSqlite3() async {
  if (_sqlite3 != null) return _sqlite3!;
  final sqlite = await WasmSqlite3.loadFromUrl(
    Uri.parse('http://localhost:$_assetServerPort/sqlite3.wasm'),
  );
  _sqlite3 = sqlite;
  return sqlite;
}

Future<(QueryExecutor, IndexedDbFileSystem)> _openPersistent(
    String dbName) async {
  final sqlite = await _loadSqlite3();
  final idb = await IndexedDbFileSystem.open(dbName: dbName);
  sqlite.registerVirtualFileSystem(idb);
  final executor = WasmDatabase(
    sqlite3: sqlite,
    path: '/$dbName',
    fileSystem: idb,
  );
  return (executor, idb);
}

void main() {
  setUpAll(() async {
    final channel = spawnHybridUri('/test/web/asset_server.dart');
    _assetServerPort = (await channel.stream.first as num).toInt();
  });

  group(
    'M014/S02 Drift web persistence',
    () {
      test('round-trips a row across close/reopen with same databaseName',
          () async {
        final dbName =
            'manytype-s02-persistence-${DateTime.now().microsecondsSinceEpoch}';

        final (exec1, idb1) = await _openPersistent(dbName);
        final db1 = ManytypeDatabase.forTesting(exec1);
        await db1.insertObject('obj-persist-1', 'space-persist');
        await db1.close();
        await idb1.close();

        final (exec2, idb2) = await _openPersistent(dbName);
        final db2 = ManytypeDatabase.forTesting(exec2);
        final deleted = await db2.isObjectDeleted('obj-persist-1');
        expect(deleted, isFalse, reason: 'row must survive close/reopen');
        await db2.close();
        await idb2.close();
      });

      test(
          'chosenImplementation is loggable (R037: worker cross-origin '
          'falls back to inMemory under dart test -p chrome)', () async {
        final dbName =
            'manytype-s02-impl-check-${DateTime.now().microsecondsSinceEpoch}';
        final result = await WasmDatabase.open(
          databaseName: dbName,
          sqlite3Uri:
              Uri.parse('http://localhost:$_assetServerPort/sqlite3.wasm'),
          driftWorkerUri: Uri.parse(
              'http://localhost:$_assetServerPort/drift_worker.dart.js'),
        );
        print('[M014/S02] chosenImplementation=${result.chosenImplementation}');
        print('[M014/S02] missingFeatures=${result.missingFeatures}');

        // When the worker fails to load (cross-origin: this test's asset
        // server runs on a different port than the test page), WasmDatabase.open
        // falls back through unsafeIndexedDb to inMemory. Empirically, under
        // dart test -p chrome, the worker load fails with
        // MissingBrowserFeature.workerError and this lands on inMemory (see
        // app_persistence_test.dart's R041 diagnostic, which observes the same
        // thing). A real deployment serves the worker same-origin and gets a
        // durable implementation instead: this test only documents what
        // WasmDatabase.open chooses in the test harness's environment.
        //
        // For the true persistence proof, we rely on the round-trip test above
        // which uses IndexedDbFileSystem directly.
        printOnFailure('chosenImplementation: ${result.chosenImplementation}');
        printOnFailure('missingFeatures: ${result.missingFeatures}');
        await result.resolvedExecutor.close();
      });

      test('missingFeatures is loggable (diagnostics)', () async {
        final dbName =
            'manytype-s02-features-${DateTime.now().microsecondsSinceEpoch}';
        final result = await WasmDatabase.open(
          databaseName: dbName,
          sqlite3Uri:
              Uri.parse('http://localhost:$_assetServerPort/sqlite3.wasm'),
          driftWorkerUri: Uri.parse(
              'http://localhost:$_assetServerPort/drift_worker.dart.js'),
        );
        print(
            '[M014/S02] missingFeatures=${result.missingFeatures} chosen=${result.chosenImplementation}');
        await result.resolvedExecutor.close();
      });
    },
    // IndexedDB open can be slow under headless chrome resource contention
    // when the full suite runs concurrently; the default 30s timeout flaked.
    // See M014/S05 test:web (dart test -p chrome -j 1) which also mitigates
    // this at the runner level.
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
