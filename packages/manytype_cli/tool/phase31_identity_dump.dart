import 'dart:convert';
import 'dart:io';

import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/peer_id.dart';

String _toHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Future<void> main(List<String> argv) async {
  final publicOnly = argv.contains('--public-only');
  final config = await CliConfig.load();
  final identity = await Identity.fromMnemonic(config.mnemonic);

  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert({
      'space_id': identity.spaceId,
      'peer_id': encodeLibp2pPeerId(identity.keyPair.publicKey),
      'account_identity_hex': _toHex(identity.accountKeyPair.publicKey),
      if (!publicOnly) 'account_seed_hex': _toHex(identity.accountSeed),
      if (!publicOnly) 'identity_seed_hex': _toHex(identity.seed),
    }),
  );
}
