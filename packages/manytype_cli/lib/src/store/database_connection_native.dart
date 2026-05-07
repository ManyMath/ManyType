import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'web_storage_diagnostics.dart';

/// [onWebStorageDiagnostics] is web-only diagnostics; ignored here since
/// native storage is always a real, durable, single-process file.
QueryExecutor openConnectionForApp(String dbPath,
    {WebStorageDiagnosticsCallback? onWebStorageDiagnostics}) {
  return LazyDatabase(() async {
    final dir = Directory(dbPath).parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return NativeDatabase.createInBackground(File(dbPath));
  });
}
