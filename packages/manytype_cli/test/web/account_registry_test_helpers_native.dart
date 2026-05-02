import 'dart:io';

import 'package:manytype_cli/src/account_registry.dart';

/// Isolates [AccountRegistry] state for a single test by pointing its
/// file-backed base dir at a fresh temp directory (the native backend keys
/// off `baseDir`, not a string prefix: see
/// account_registry_test_helpers_web.dart for the web-side equivalent).
Future<void> resetAccountRegistryForTest(String uniqueSuffix) async {
  final tempDir = await Directory.systemTemp
      .createTemp('manytype_account_registry_test_$uniqueSuffix');
  AccountRegistry.testBaseDirOverride = tempDir.path;
}
