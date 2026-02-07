import 'dart:typed_data';

const _base58Alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// Encode an Ed25519 public key as the libp2p peer ID string used by Any-Sync.
///
/// libp2p represents Ed25519 peer IDs as a base58btc-encoded identity
/// multihash of the protobuf-encoded public key.
String encodeLibp2pPeerId(Uint8List ed25519PublicKey) {
  if (ed25519PublicKey.length != 32) {
    throw StateError(
      'Expected 32-byte Ed25519 public key, got ${ed25519PublicKey.length}',
    );
  }

  final keyProto = Uint8List(4 + ed25519PublicKey.length)
    ..[0] = 0x08
    ..[1] = 0x01
    ..[2] = 0x12
    ..[3] = ed25519PublicKey.length
    ..setRange(4, 4 + ed25519PublicKey.length, ed25519PublicKey);

  final multihash = Uint8List(2 + keyProto.length)
    ..[0] = 0x00
    ..[1] = keyProto.length
    ..setRange(2, 2 + keyProto.length, keyProto);

  return _base58Encode(multihash);
}

String _base58Encode(Uint8List input) {
  if (input.isEmpty) {
    return '';
  }

  var zeroCount = 0;
  while (zeroCount < input.length && input[zeroCount] == 0) {
    zeroCount++;
  }

  final digits = <int>[0];
  for (final byte in input) {
    var carry = byte;
    for (var i = 0; i < digits.length; i++) {
      final value = digits[i] * 256 + carry;
      digits[i] = value % 58;
      carry = value ~/ 58;
    }
    while (carry > 0) {
      digits.add(carry % 58);
      carry ~/= 58;
    }
  }

  final buffer = StringBuffer();
  for (var i = 0; i < zeroCount; i++) {
    buffer.write(_base58Alphabet[0]);
  }
  for (var i = digits.length - 1; i >= 0; i--) {
    buffer.write(_base58Alphabet[digits[i]]);
  }
  return buffer.toString();
}
