import 'dart:io';

// AccountRegistry/active-account resolution remain host integration APIs
// rather than part of manytype_cli's command-oriented public barrel.
// ignore: implementation_imports
import 'package:manytype_client/manytype_client.dart';

// ignore: implementation_imports
// ignore: implementation_imports

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
