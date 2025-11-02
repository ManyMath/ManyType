import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Compute CIDv1 string from raw bytes.
///
/// Matches Anytype's `cidutil.NewCidFromBytes` exactly:
///   CIDv1 + dag-cbor (0x71) + SHA2-256 + base32lower with 'b' prefix
///
/// The resulting string always starts with "bafy" which is the signature
/// of CIDv1 + dag-cbor + SHA-256 in base32lower encoding.
Future<String> computeCid(Uint8List data) async {
  // 1. SHA-256 hash
  final algorithm = Sha256();
  final hash = await algorithm.hash(data);
  final digest = Uint8List.fromList(hash.bytes);

  // 2. Multihash: 0x12 (sha2-256) + 0x20 (32 bytes length) + 32-byte digest
  final multihash = Uint8List(34);
  multihash[0] = 0x12; // sha2-256 function code
  multihash[1] = 0x20; // digest length (32)
  multihash.setRange(2, 34, digest);

  // 3. CID bytes: 0x01 (CIDv1) + 0x71 (dag-cbor codec) + multihash
  final cidBytes = Uint8List(2 + 34);
  cidBytes[0] = 0x01; // CIDv1 version
  cidBytes[1] = 0x71; // dag-cbor codec
  cidBytes.setRange(2, 36, multihash);

  // 4. base32lower encode (RFC 4648, no padding) with 'b' multibase prefix
  return 'b${_base32LowerEncode(cidBytes)}';
}

/// Decode a base32lower CID string into the raw bytes expected by file-node
/// RPCs.
Uint8List cidToBytes(String cid) {
  final trimmed = cid.trim();
  if (trimmed.isEmpty) {
    throw FormatException('CID cannot be empty');
  }
  if (!trimmed.startsWith('b')) {
    throw FormatException('Only base32lower multibase CIDs are supported');
  }
  return _base32LowerDecode(trimmed.substring(1));
}

/// RFC 4648 base32 lowercase encoding without padding.
///
/// Alphabet: abcdefghijklmnopqrstuvwxyz234567
String _base32LowerEncode(Uint8List data) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz234567';
  final buffer = StringBuffer();
  var bits = 0;
  var value = 0;

  for (final byte in data) {
    value = (value << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      buffer.write(alphabet[(value >> bits) & 0x1f]);
    }
  }

  // Flush remaining bits (if any)
  if (bits > 0) {
    buffer.write(alphabet[(value << (5 - bits)) & 0x1f]);
  }

  return buffer.toString();
}

Uint8List _base32LowerDecode(String data) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz234567';
  final cleaned = data.trim().toLowerCase();
  final bytes = BytesBuilder();
  var bits = 0;
  var value = 0;

  for (final codeUnit in cleaned.codeUnits) {
    final char = String.fromCharCode(codeUnit);
    final index = alphabet.indexOf(char);
    if (index < 0) {
      throw FormatException('Invalid base32 character: $char');
    }
    value = (value << 5) | index;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      bytes.addByte((value >> bits) & 0xff);
    }
  }

  return bytes.toBytes();
}
