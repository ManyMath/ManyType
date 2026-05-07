import 'package:drift/drift.dart';

import 'web_storage_diagnostics.dart';

QueryExecutor openConnectionForApp(String dbPath,
    {WebStorageDiagnosticsCallback? onWebStorageDiagnostics}) {
  throw UnsupportedError(
    'openConnectionForApp is not supported on this platform (neither dart:io nor dart:js_interop)',
  );
}
