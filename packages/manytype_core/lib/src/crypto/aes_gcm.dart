import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// AES-256-GCM nonce length in bytes.
const nonceBytes = 12;

/// AES-256-GCM key length in bytes.
const keyBytes = 32;

final _aesGcm = AesGcm.with256bits();

/// Encrypt plaintext with AES-256-GCM.
///
/// Returns: [12-byte nonce][ciphertext + 16-byte GCM tag]
/// Matches Go implementation in any-sync/util/crypto/aes.go.
Future<Uint8List> aesGcmEncrypt(Uint8List key, Uint8List plaintext) async {
  final secretBox = await _aesGcm.encrypt(
    plaintext,
    secretKey: SecretKey(key),
  );

  // Format: nonce || ciphertext || mac
  final nonce = secretBox.nonce;
  final ciphertext = secretBox.cipherText;
  final mac = secretBox.mac.bytes;

  final result = Uint8List(nonce.length + ciphertext.length + mac.length);
  result.setRange(0, nonce.length, nonce);
  result.setRange(nonce.length, nonce.length + ciphertext.length, ciphertext);
  result.setRange(
      nonce.length + ciphertext.length, result.length, mac);

  return result;
}

/// Decrypt AES-256-GCM ciphertext.
///
/// Input format: [12-byte nonce][ciphertext + 16-byte GCM tag]
Future<Uint8List> aesGcmDecrypt(Uint8List key, Uint8List data) async {
  if (data.length < nonceBytes + 16) {
    throw ArgumentError(
        'Data too short: need at least ${nonceBytes + 16} bytes');
  }

  final nonce = data.sublist(0, nonceBytes);
  final ciphertextAndTag = data.sublist(nonceBytes);
  final ciphertext =
      ciphertextAndTag.sublist(0, ciphertextAndTag.length - 16);
  final mac = Mac(ciphertextAndTag.sublist(ciphertextAndTag.length - 16));

  final secretBox = SecretBox(
    ciphertext,
    nonce: nonce,
    mac: mac,
  );

  final plaintext = await _aesGcm.decrypt(
    secretBox,
    secretKey: SecretKey(key),
  );

  return Uint8List.fromList(plaintext);
}
