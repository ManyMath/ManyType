import 'package:drift/drift.dart';

import 'web_storage_diagnostics.dart';

Future<QueryExecutor> openDatabaseForApp(String dbPath,
    {WebStorageDiagnosticsCallback? onWebStorageDiagnostics}) {
  throw UnsupportedError(
    'openDatabaseForApp is not supported on this platform',
  );
}

Future<QueryExecutor> openDatabaseForTesting({String? name}) {
  throw UnsupportedError(
    'openDatabaseForTesting is not supported on this platform',
  );
}

Future<Never> openWasmDatabaseForTesting({String? name}) {
  throw UnsupportedError(
    'openWasmDatabaseForTesting is only supported on web',
  );
}
