import 'dart:typed_data';
import 'package:manytype_core/manytype_core.dart';

/// User identity derived from BIP-39 mnemonic via SLIP-0010.
class Identity {
  /// 32-byte Ed25519 private key seed.
  final Uint8List seed;

  /// Ed25519 key pair for signing.
  final Ed25519KeyPair keyPair;

  /// Raw 32-byte public key bytes (peer ID).
  final Uint8List peerId;

  Identity._({required this.seed, required this.keyPair, required this.peerId});

  /// Derive identity from BIP-39 mnemonic.
  /// Uses SLIP-0010 path m/44'/2046'/0'/0' for identity key
  /// (coin type 2046 is registered for Anytype).
  static Future<Identity> fromMnemonic(String mnemonic) async {
    final bip39Seed = mnemonicToSeed(mnemonic);
    final derived = await deriveIdentityKey(bip39Seed);
    // derived.privateKey is 32 bytes (Ed25519 seed)
    final keyPair = await ed25519KeyPairFromSeed(derived.privateKey);
    final peerId = keyPair.publicKey; // 32 raw bytes

    return Identity._(seed: derived.privateKey, keyPair: keyPair, peerId: peerId);
  }

  /// Space ID derivation (for single-user: based on identity public key).
  String get spaceId {
    // For v1 single-user: space is derived from identity public key hex
    return keyPair.publicKey
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
