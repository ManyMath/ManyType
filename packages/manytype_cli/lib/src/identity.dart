import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/manytype_protocol.dart' show Key, KeyType;
import 'package:manytype_protocol/spacesync.dart';

/// User identity derived from BIP-39 mnemonic via SLIP-0010.
class Identity {
  /// 32-byte Ed25519 account seed (m/44'/2046'/0').
  final Uint8List accountSeed;

  /// Ed25519 account key pair used for space headers and ACL master key.
  final Ed25519KeyPair accountKeyPair;

  /// 32-byte Ed25519 identity seed (m/44'/2046'/0'/0').
  final Uint8List seed;

  /// Ed25519 identity key pair used for peer ID and change signing.
  final Ed25519KeyPair keyPair;

  /// Raw 32-byte identity public key bytes (peer ID).
  final Uint8List peerId;

  /// Deterministic space header signed by the account key.
  final RawSpaceHeaderWithId spaceHeader;

  Identity._({
    required this.accountSeed,
    required this.accountKeyPair,
    required this.seed,
    required this.keyPair,
    required this.peerId,
    required this.spaceHeader,
  });

  /// Derive identity from BIP-39 mnemonic.
  ///
  /// Uses:
  /// - account key: m/44'/2046'/0'
  /// - identity key: m/44'/2046'/0'/0'
  static Future<Identity> fromMnemonic(String mnemonic) async {
    final bip39Seed = mnemonicToSeed(mnemonic);
    final accountDerived = await deriveAccountKey(bip39Seed);
    final identityDerived = await deriveIdentityKey(bip39Seed);
    final accountKeyPair =
        await ed25519KeyPairFromSeed(accountDerived.privateKey);
    final keyPair = await ed25519KeyPairFromSeed(identityDerived.privateKey);
    final peerId = keyPair.publicKey;
    final spaceHeader = await _buildDerivedSpaceHeader(
      accountSeed: accountDerived.privateKey,
      accountPublicKey: accountKeyPair.publicKey,
    );

    return Identity._(
      accountSeed: accountDerived.privateKey,
      accountKeyPair: accountKeyPair,
      seed: identityDerived.privateKey,
      keyPair: keyPair,
      peerId: peerId,
      spaceHeader: spaceHeader,
    );
  }

  /// Space ID derived from the account-signed raw space header CID and
  /// the base36 replication key.
  String get spaceId => spaceHeader.id;
}

const _regularSpaceType = 'anytype.space';
final _fnv64OffsetBasis = BigInt.parse('cbf29ce484222325', radix: 16);
final _fnv64Prime = BigInt.parse('100000001b3', radix: 16);
final _u64Mask = (BigInt.one << 64) - BigInt.one;
final _u64SignBit = BigInt.one << 63;
final _u64Modulus = BigInt.one << 64;

Future<RawSpaceHeaderWithId> _buildDerivedSpaceHeader({
  required Uint8List accountSeed,
  required Uint8List accountPublicKey,
}) async {
  final replicationKey = _fnv64(accountPublicKey);
  final header = SpaceHeader(
    identity: _marshalEd25519PublicKey(accountPublicKey),
    spaceType: _regularSpaceType,
    replicationKey: _toProtoUint64(replicationKey),
  );
  final headerBytes = Uint8List.fromList(header.writeToBuffer());
  final signature = await ed25519Sign(accountSeed, headerBytes);
  final rawHeader = RawSpaceHeader(
    spaceHeader: headerBytes,
    signature: signature,
  );
  final rawHeaderBytes = Uint8List.fromList(rawHeader.writeToBuffer());
  final headerId = await computeCid(rawHeaderBytes);

  return RawSpaceHeaderWithId(
    id: '$headerId.${_formatUint64Radix36(replicationKey)}',
    rawHeader: rawHeaderBytes,
  );
}

Uint8List _marshalEd25519PublicKey(Uint8List publicKey) => Uint8List.fromList(
      Key(
        type: KeyType.Ed25519Public,
        data: publicKey,
      ).writeToBuffer(),
    );

BigInt _fnv64(List<int> bytes) {
  var hash = _fnv64OffsetBasis;
  for (final byte in bytes) {
    hash = (hash * _fnv64Prime) & _u64Mask;
    hash ^= BigInt.from(byte);
  }
  return hash;
}

Int64 _toProtoUint64(BigInt value) {
  final normalized = value & _u64Mask;
  final signed =
      normalized >= _u64SignBit ? normalized - _u64Modulus : normalized;
  return Int64.parseInt(signed.toString());
}

String _formatUint64Radix36(BigInt value) =>
    (value & _u64Mask).toRadixString(36);
