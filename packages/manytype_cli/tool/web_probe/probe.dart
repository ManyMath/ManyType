// Standalone web entrypoint for `tool/verify_opfs_same_origin.dart`.
//
// `dart test -p chrome` cannot prove which WasmStorageImplementation a real
// web deployment picks: it can't serve `drift_worker.dart.js` same-origin
// (see database_web.dart's openWasmDatabaseForApp doc comment), so
// `chosenImplementation` always lands on `inMemory` under that harness. This
// probe is compiled and served the way a real app is: as a same-origin
// static bundle: so it can observe the outcome `dart test -p chrome`
// structurally cannot.
//
// It calls the exact public constructor a real embedding host uses
// (`ManytypeDatabase(dbPath, onWebStorageDiagnostics: ...)`), does a
// write/close/reopen/read cycle, and writes the outcome into `#result` as
// JSON so `verify_opfs_same_origin.dart` can read it back out of a headless
// browser's dumped DOM.
import 'dart:convert';

import 'package:manytype_cli/manytype_cli.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  final result = <String, Object?>{};
  try {
    WebStorageDiagnostics? diagnostics;
    final dbName =
        'manytype-opfs-probe-${web.window.performance.now().toInt()}';

    final db1 = ManytypeDatabase(dbName,
        onWebStorageDiagnostics: (d) => diagnostics = d);
    await db1.insertObject('probe-object-1', 'probe-space');
    await db1.close();

    final db2 = ManytypeDatabase(dbName);
    final objects = await db2.getAllObjects();
    await db2.close();

    result['ok'] = true;
    result['implementationName'] = diagnostics?.implementationName;
    result['isDurable'] = diagnostics?.isDurable;
    result['isMultiTabSafe'] = diagnostics?.isMultiTabSafe;
    result['missingFeatures'] = diagnostics?.missingFeatures;
    result['rowSurvivedReopen'] =
        objects.map((o) => o.id).contains('probe-object-1');
  } catch (e, st) {
    result['ok'] = false;
    result['error'] = e.toString();
    result['stackTrace'] = st.toString();
  }

  final el = web.document.createElement('div') as web.HTMLDivElement;
  el.id = 'result';
  el.textContent = jsonEncode(result);
  web.document.body?.appendChild(el);
}
