import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pinenacl/tweetnacl.dart';
import 'package:pinenacl/x25519.dart' as nacl;

final _sha512 = Sha512();

/// Convert a 32-byte Ed25519 seed into a 32-byte Curve25519 (X25519) private key.
///
/// Mirrors any-sync `Ed25519PrivateKeyToCurve25519`:
/// sha512(seed) -> clamp -> first 32 bytes.
Future<Uint8List> ed25519SeedToCurve25519PrivateKey(Uint8List seed) async {
  if (seed.length != 32) {
    throw ArgumentError.value(seed.length, 'seed.length', 'must be 32 bytes');
  }
  final digest = await _sha512.hash(seed);
  final out = Uint8List.fromList(digest.bytes);

  // libsodium clamping
  out[0] &= 248;
  out[31] &= 127;
  out[31] |= 64;

  return Uint8List.fromList(out.sublist(0, 32));
}

/// Convert a 32-byte Ed25519 public key into a 32-byte Curve25519 (X25519) public key.
///
/// Mirrors any-sync `Ed25519PublicKeyToCurve25519` via TweetNaCl's conversion helper.
Uint8List ed25519PublicKeyToCurve25519PublicKey(Uint8List ed25519PublicKey) {
  if (ed25519PublicKey.length != 32) {
    throw ArgumentError.value(
      ed25519PublicKey.length,
      'ed25519PublicKey.length',
      'must be 32 bytes',
    );
  }

  final out = Uint8List(32);
  final rc =
      TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(out, ed25519PublicKey);
  if (rc != 0) {
    throw StateError('Invalid Ed25519 public key (failed Curve25519 conversion)');
  }
  return out;
}

/// Derive Curve25519 (X25519) public key from a Curve25519 private key.
Uint8List curve25519PublicKeyFromPrivateKey(Uint8List curvePrivKey) {
  if (curvePrivKey.length != 32) {
    throw ArgumentError.value(
      curvePrivKey.length,
      'curvePrivKey.length',
      'must be 32 bytes',
    );
  }
  return Uint8List.fromList(nacl.PrivateKey(curvePrivKey).publicKey);
}

/// any-sync compatible `EncryptX25519`.
///
/// Output format: `ephemeralPublicKey(32) || nacl_box(ciphertext)`
///
/// Note: any-sync currently derives the nonce as `nonce = epk[0:24]`
/// (see `util/crypto/x25519.go`). We intentionally match that behavior.
Uint8List encryptX25519({
  required Uint8List recipientCurvePublicKey,
  required Uint8List message,
}) {
  if (recipientCurvePublicKey.length != 32) {
    throw ArgumentError.value(
      recipientCurvePublicKey.length,
      'recipientCurvePublicKey.length',
      'must be 32 bytes',
    );
  }

  final ephemPriv = nacl.PrivateKey.generate();
  final ephemPub = Uint8List.fromList(ephemPriv.publicKey);
  final nonce = Uint8List.fromList(ephemPub.sublist(0, 24));

  final box = nacl.Box(
    myPrivateKey: ephemPriv,
    theirPublicKey: nacl.PublicKey(recipientCurvePublicKey),
  );
  final encrypted = box.encrypt(message, nonce: nonce);

  return Uint8List.fromList(ephemPub + encrypted.cipherText.asTypedList);
}

/// Encrypt message to an Ed25519 public key using any-sync's X25519 seal.
Uint8List encryptToEd25519PublicKey({
  required Uint8List recipientEd25519PublicKey,
  required Uint8List message,
}) {
  final curvePub = ed25519PublicKeyToCurve25519PublicKey(recipientEd25519PublicKey);
  return encryptX25519(recipientCurvePublicKey: curvePub, message: message);
}

/// any-sync compatible `DecryptX25519`.
Future<Uint8List> decryptX25519({
  required Uint8List recipientCurvePrivateKey,
  required Uint8List encrypted,
}) async {
  if (recipientCurvePrivateKey.length != 32) {
    throw ArgumentError.value(
      recipientCurvePrivateKey.length,
      'recipientCurvePrivateKey.length',
      'must be 32 bytes',
    );
  }
  if (encrypted.length < 32) {
    throw ArgumentError.value(
      encrypted.length,
      'encrypted.length',
      'must be >= 32 bytes',
    );
  }

  final epk = Uint8List.fromList(encrypted.sublist(0, 32));
  final nonce = Uint8List.fromList(epk.sublist(0, 24));
  final cipherText = Uint8List.fromList(encrypted.sublist(32));

  final box = nacl.Box(
    myPrivateKey: nacl.PrivateKey(recipientCurvePrivateKey),
    theirPublicKey: nacl.PublicKey(epk),
  );
  return box.decrypt(nacl.ByteList(cipherText), nonce: nonce);
}
