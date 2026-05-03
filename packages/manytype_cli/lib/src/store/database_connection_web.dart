import 'package:drift/drift.dart';

import 'database_opener.dart';

/// Real (non-test) web connection for [ManytypeDatabase]'s default
/// constructor: delegates to [openDatabaseForApp], which resolves through
/// `WasmDatabase.open`: OPFS-backed when the browser supports it and the
/// page is cross-origin isolated, falling back through shared/unsafe
/// IndexedDB otherwise. Wrapped in [LazyDatabase] since [openDatabaseForApp]
/// is async but [ManytypeDatabase]'s constructor needs a synchronous
/// [QueryExecutor].
QueryExecutor openConnectionForApp(String dbPath) {
  return LazyDatabase(() => openDatabaseForApp(dbPath));
}
