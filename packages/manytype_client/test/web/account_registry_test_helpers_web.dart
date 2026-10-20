import 'package:manytype_client/src/account_registry.dart';
import 'package:manytype_client/src/store/database_web.dart' as database_web;
import 'package:sqlite3/wasm.dart';
import 'package:test/test.dart';

/// Isolates [AccountRegistry] state for a single test by giving it a fresh
/// localStorage key prefix (the web backend keys off a string prefix, not a
/// filesystem base dir: see account_registry_test_helpers_native.dart for
/// the native-side equivalent).
Future<void> resetAccountRegistryForTest(String uniqueSuffix) async {
  AccountRegistry.keyPrefix = 'manytype-account-registry-test-$uniqueSuffix';
  // This registry-facade test opens only in-memory session databases. The
  // browser runner cannot serve a same-origin production storage worker.
  // Use real IndexedDB deletion here, as the persistent account test does,
  // without weakening the production probe's fail-closed behavior.
  database_web.webDatabaseDeleteOverride = IndexedDbFileSystem.deleteDatabase;
  addTearDown(() => database_web.webDatabaseDeleteOverride = null);
}
