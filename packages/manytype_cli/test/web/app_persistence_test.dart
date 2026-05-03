@TestOn('browser')
library;

// R041: proves ManytypeDatabase's *production* default constructor
// (`ManytypeDatabase(dbPath)`, routed through openConnectionForApp ->
// openDatabaseForApp -> WasmDatabase.open) is actually usable on web.
// persistence_test.dart (M014/S02) proved persistence is possible in
// principle by hand-building an IndexedDbFileSystem executor and feeding it
// to ManytypeDatabase.forTesting; that path is never reached by real
// callers. Prior to this test, any web host calling the public
// ManytypeDatabase(dbPath) constructor got an UnsupportedError immediately
// (database_connection.dart had no web branch): this is the first test to
// go through the actual constructor a real embedding app would use.
import 'package:drift/wasm.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/store/database_web.dart' as database_web;
import 'package:test/test.dart';

import 'web_db_test_helpers.dart';

void main() {
  setUpAll(configureWebAppDatabaseAssets);

  group('R041 ManytypeDatabase(dbPath) production web connection', () {
    test(
        'succeeds (no UnsupportedError) and persists across close/reopen '
        'when a durable implementation is available', () async {
      final dbName =
          'manytype-r041-app-persist-${DateTime.now().microsecondsSinceEpoch}';

      // dart test -p chrome cannot load a cross-origin drift worker script
      // (see persistence_test.dart's R037 note), so this environment lands
      // on WasmStorageImplementation.inMemory rather than a durable one. A
      // real deployment serves the worker same-origin and gets IndexedDB or
      // OPFS. Check which one this run got before asserting persistence, so
      // the test is honest about what it can observe here.
      final diagnostic =
          await database_web.openWasmDatabaseForApp('$dbName-diagnostic');
      final implementation = diagnostic.chosenImplementation;
      printOnFailure('chosenImplementation=$implementation '
          'missingFeatures=${diagnostic.missingFeatures}');
      await diagnostic.resolvedExecutor.close();

      final db1 = ManytypeDatabase(dbName);
      await db1.insertObject('obj-app-persist-1', 'space-app-persist');
      await db1.close();

      final db2 = ManytypeDatabase(dbName);
      final objects = await db2.getAllObjects();
      await db2.close();

      if (implementation == WasmStorageImplementation.inMemory) {
        printOnFailure(
            'chosenImplementation was inMemory in this environment: '
            'cross-instance persistence cannot be observed here, but the '
            'production constructor completed without the UnsupportedError '
            'it used to throw unconditionally.');
        return;
      }
      expect(objects.map((o) => o.id), contains('obj-app-persist-1'));
    });
  }, timeout: const Timeout(Duration(seconds: 90)));
}
