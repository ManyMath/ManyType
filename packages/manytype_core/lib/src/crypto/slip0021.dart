import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// SLIP-0021 symmetric key derivation.
///
/// Algorithm:
/// 1. Master node: HMAC-SHA512(key="Symmetric key seed", data=seed)
///    - master[0..32] = derivation key (chain code)
///    - master[32..64] = symmetric key
/// 2. For each path segment after "m":
///    - child = HMAC-SHA512(key=parent_chain_code, data=0x00 || segment_bytes)
///    - child[0..32] = chain code, child[32..64] = symmetric key
/// 3. Return final node's symmetric key (bytes 32..64)

const _seedModifier = 'Symmetric key seed';
final _pathRegex = RegExp(r'^m(/.*)*$');

/// Derive a symmetric key using SLIP-0021 from a BIP-39 seed.
///
/// Returns the 32-byte symmetric key at the given path.
/// Path format: "m/label1/label2/..."
Future<Uint8List> slip21Derive(Uint8List seed, String path) async {
  if (!_pathRegex.hasMatch(path)) {
    throw ArgumentError('Invalid SLIP-0021 path: $path');
  }

  final hmacAlgo = Hmac.sha512();

  // Master node: HMAC-SHA512(key="Symmetric key seed", data=seed)
  final masterMac = await hmacAlgo.calculateMac(
    seed,
    secretKey: SecretKey(Uint8List.fromList(_seedModifier.codeUnits)),
  );
  var node = Uint8List.fromList(masterMac.bytes);

  // Split path and derive through each label after "m"
  final labels = path.split('/');
  for (var i = 1; i < labels.length; i++) {
    final label = labels[i];
    final chainCode = node.sublist(0, 32);

    // Child derivation: HMAC-SHA512(key=chain_code, data=0x00 || label_bytes)
    final data = Uint8List(1 + label.length);
    data[0] = 0x00;
    data.setRange(1, data.length, label.codeUnits);

    final childMac = await hmacAlgo.calculateMac(
      data,
      secretKey: SecretKey(chainCode),
    );
    node = Uint8List.fromList(childMac.bytes);
  }

  // Return the symmetric key (bytes 32..64)
  return Uint8List.fromList(node.sublist(32, 64));
}

/// Derive Anytype space read key.
/// Path: "m/SLIP-0021/anysync/space"
Future<Uint8List> deriveSpaceKey(Uint8List seed) {
  return slip21Derive(seed, 'm/SLIP-0021/anysync/space');
}

/// Derive Anytype tree key for a specific tree ID.
/// Path: "m/SLIP-0021/anysync/tree/{treeId}"
Future<Uint8List> deriveTreeKey(Uint8List seed, String treeId) {
  return slip21Derive(seed, 'm/SLIP-0021/anysync/tree/$treeId');
}
