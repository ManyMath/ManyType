@TestOn('browser')
library;

// Proves ManytypeDatabase's onWebStorageDiagnostics callback actually fires
// with a value derived from the resolved WasmDatabaseResult, closing the gap
// M017 left open: nothing surfaced chosenImplementation to callers of the
// public constructor before this (only the test-only openWasmDatabaseForApp
// diagnostic exposed it). Tolerant of dart test -p chrome's inability to
// load a same-origin drift worker (see app_persistence_test.dart's R041
// note): the callback should still fire exactly once regardless of which
// implementation gets chosen in this environment.
import 'package:manytype_cli/manytype_cli.dart';
import 'package:test/test.dart';

import 'web_db_test_helpers.dart';

void main() {
  setUpAll(configureWebAppDatabaseAssets);

  test(
      'ManytypeDatabase(dbPath) invokes onWebStorageDiagnostics exactly once '
      'with the resolved implementation', () async {
    final dbName =
        'manytype-web-storage-diag-${DateTime.now().microsecondsSinceEpoch}';

    WebStorageDiagnostics? seen;
    var callCount = 0;
    final db = ManytypeDatabase(dbName, onWebStorageDiagnostics: (d) {
      callCount++;
      seen = d;
    });

    // The callback fires from within the LazyDatabase's async opener, so
    // force it to run by issuing a query before asserting.
    await db.getAllObjects();
    await db.close();

    expect(callCount, 1);
    expect(seen, isNotNull);
    printOnFailure('diagnostics=$seen');
    expect(seen!.implementationName, isNotEmpty);
    if (seen!.implementationName == 'inMemory') {
      // The only implementation dart test -p chrome can actually reach (see
      // R041): confirm the mapping marks it correctly as non-durable and
      // not multi-tab safe.
      expect(seen!.isDurable, isFalse);
      expect(seen!.isMultiTabSafe, isFalse);
    } else {
      expect(seen!.isDurable, isTrue);
    }
  }, timeout: const Timeout(Duration(seconds: 90)));
}
