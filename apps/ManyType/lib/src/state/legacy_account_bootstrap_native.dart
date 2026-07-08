import 'dart:io';

// AccountRegistry/active-account resolution remain host integration APIs
// rather than part of manytype_cli's command-oriented public barrel.
// ignore: implementation_imports
import 'package:manytype_cli/src/account_registry.dart';
// ignore: implementation_imports
import 'package:manytype_cli/src/active_account.dart';
// ignore: implementation_imports
import 'package:manytype_cli/src/config.dart';

/// Registers and secures a pre-registry account, if this install has one.
Future<String?> bootstrapLegacyAccountIfPresent() async {
  if (!await File(CliConfig.configPath).exists()) {
    return null;
  }

  await resolveActiveAccount();
  final currentId = await AccountRegistry.getCurrentAccountId();
  if (currentId == null) {
    throw StateError('Legacy account bootstrap did not select an account.');
  }
  return currentId;
}
