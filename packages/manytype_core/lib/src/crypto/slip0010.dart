import 'dart:typed_data';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';

/// Result of SLIP-0010 key derivation.
class DerivedKey {
  /// 32-byte Ed25519 private key seed.
  final Uint8List privateKey;

  /// 32-byte chain code.
  final Uint8List chainCode;

  DerivedKey(this.privateKey, this.chainCode);
}

/// Anytype derivation path prefix for SLIP-0010 Ed25519 keys.
/// See: https://github.com/satoshilabs/slips/blob/master/slip-0044.md
/// Coin type 2046 is registered for Anytype.
const _anytypePrefix = "m/44'/2046'";

/// Derive Ed25519 identity keypair from BIP-39 seed.
/// Path: m/44'/2046'/[index]'/0'
/// Returns 32-byte Ed25519 private key seed and chain code.
Future<DerivedKey> deriveIdentityKey(List<int> seed, {int index = 0}) async {
  final path = "$_anytypePrefix/$index'/0'";
  return deriveFromPath(path, seed);
}

/// Derive Ed25519 account master key from BIP-39 seed.
/// Path: m/44'/2046'/[index]'
/// Returns 32-byte Ed25519 private key seed and chain code.
Future<DerivedKey> deriveAccountKey(List<int> seed, {int index = 0}) async {
  final path = "$_anytypePrefix/$index'";
  return deriveFromPath(path, seed);
}

/// Derive an Ed25519 key at an arbitrary SLIP-0010 hardened path.
Future<DerivedKey> deriveFromPath(String path, List<int> seed) async {
  final keyData = await ED25519_HD_KEY.derivePath(path, seed);
  return DerivedKey(
    Uint8List.fromList(keyData.key),
    Uint8List.fromList(keyData.chainCode),
  );
}
