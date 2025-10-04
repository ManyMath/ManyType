import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

final _ed25519 = Ed25519();

/// Ed25519 keypair for signing.
class Ed25519KeyPair {
  /// 32-byte Ed25519 private key seed.
  final Uint8List privateKey;

  /// 32-byte Ed25519 public key.
  final Uint8List publicKey;

  Ed25519KeyPair(this.privateKey, this.publicKey);
}

/// Create an Ed25519 keypair from a 32-byte private key seed.
Future<Ed25519KeyPair> ed25519KeyPairFromSeed(Uint8List seed) async {
  final keyPair = await _ed25519.newKeyPairFromSeed(seed);
  final publicKey = await keyPair.extractPublicKey();
  return Ed25519KeyPair(
    Uint8List.fromList(seed),
    Uint8List.fromList(publicKey.bytes),
  );
}

/// Sign a message with Ed25519.
/// Returns 64-byte signature.
Future<Uint8List> ed25519Sign(Uint8List privateKeySeed, Uint8List message) async {
  final keyPair = await _ed25519.newKeyPairFromSeed(privateKeySeed);
  final signature = await _ed25519.sign(message, keyPair: keyPair);
  return Uint8List.fromList(signature.bytes);
}

/// Verify an Ed25519 signature.
/// Returns true if valid, false otherwise.
Future<bool> ed25519Verify(
    Uint8List publicKey, Uint8List message, Uint8List signature) async {
  final sig = Signature(
    signature,
    publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
  );
  try {
    final valid = await _ed25519.verify(message, signature: sig);
    return valid;
  } catch (_) {
    return false;
  }
}
