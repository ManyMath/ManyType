import 'dart:convert';
import 'dart:io';

import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';

String _toHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Future<void> main(List<String> argv) async {
  final config = await CliConfig.load();
  final identity = await Identity.fromMnemonic(config.mnemonic);

  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert({
      'space_id': identity.spaceId,
      'account_seed_hex': _toHex(identity.accountSeed),
    }),
  );
}

