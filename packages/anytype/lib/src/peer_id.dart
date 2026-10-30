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

/// Whether [value] is a base58btc libp2p peer ID: an identity or sha2-256
/// multihash.
bool isLibp2pPeerId(String value) {
  final bytes = _base58Decode(value);
  if (bytes == null || bytes.length < 2) {
    return false;
  }
  return switch (bytes[0]) {
    0x00 => bytes[1] == bytes.length - 2 && bytes[1] <= 42,
    0x12 => bytes[1] == 32 && bytes.length == 34,
    _ => false,
  };
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

Uint8List? _base58Decode(String input) {
  if (input.isEmpty) {
    return null;
  }

  var zeroCount = 0;
  while (zeroCount < input.length && input[zeroCount] == _base58Alphabet[0]) {
    zeroCount++;
  }

  final bytes = <int>[];
  for (var i = 0; i < input.length; i++) {
    var carry = _base58Alphabet.indexOf(input[i]);
    if (carry < 0) {
      return null;
    }
    for (var j = 0; j < bytes.length; j++) {
      final value = bytes[j] * 58 + carry;
      bytes[j] = value & 0xff;
      carry = value >> 8;
    }
    while (carry > 0) {
      bytes.add(carry & 0xff);
      carry >>= 8;
    }
  }

  return Uint8List.fromList([
    ...List.filled(zeroCount, 0),
    ...bytes.reversed,
  ]);
}
