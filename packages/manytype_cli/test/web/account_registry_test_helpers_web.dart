import 'package:manytype_cli/src/account_registry.dart';

/// Isolates [AccountRegistry] state for a single test by giving it a fresh
/// localStorage key prefix (the web backend keys off a string prefix, not a
/// filesystem base dir: see account_registry_test_helpers_native.dart for
/// the native-side equivalent).
Future<void> resetAccountRegistryForTest(String uniqueSuffix) async {
  AccountRegistry.keyPrefix = 'manytype-account-registry-test-$uniqueSuffix';
}
