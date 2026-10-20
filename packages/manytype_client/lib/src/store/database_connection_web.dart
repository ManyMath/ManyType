import 'package:drift/drift.dart';

import 'database_opener.dart';
import 'web_storage_diagnostics.dart';

/// Real (non-test) web connection for [ManytypeDatabase]'s default
/// constructor: delegates to [openDatabaseForApp], which resolves through
/// `WasmDatabase.open`: OPFS-backed when the browser supports it and the
/// page is cross-origin isolated, falling back through shared/unsafe
/// IndexedDB otherwise. Wrapped in [LazyDatabase] since [openDatabaseForApp]
/// is async but [ManytypeDatabase]'s constructor needs a synchronous
/// [QueryExecutor]. [onWebStorageDiagnostics], if given, is invoked once the
/// backend resolves so a caller can warn when persistence degraded (see
/// [WebStorageDiagnostics]).
QueryExecutor openConnectionForApp(String dbPath,
    {WebStorageDiagnosticsCallback? onWebStorageDiagnostics}) {
  return LazyDatabase(() => openDatabaseForApp(dbPath,
      onWebStorageDiagnostics: onWebStorageDiagnostics));
}
