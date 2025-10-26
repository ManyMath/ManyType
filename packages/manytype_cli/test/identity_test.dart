import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_protocol/spacesync.dart';
import 'package:test/test.dart';

void main() {
  // Known BIP-39 test vector mnemonic
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  group('Identity', () {
    test('derives 32-byte account and identity seeds from mnemonic', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.accountSeed.length, 32);
      expect(identity.seed.length, 32);
    });

    test('derives 32-byte peerId from mnemonic', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.peerId.length, 32);
    });

    test('derivation is deterministic', () async {
      final identity1 = await Identity.fromMnemonic(testMnemonic);
      final identity2 = await Identity.fromMnemonic(testMnemonic);
      expect(identity1.accountSeed, identity2.accountSeed);
      expect(identity1.peerId, identity2.peerId);
      expect(identity1.seed, identity2.seed);
      expect(identity1.spaceId, identity2.spaceId);
    });

    test('account and identity keys are distinct', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.accountSeed, isNot(equals(identity.seed)));
      expect(identity.accountKeyPair.publicKey,
          isNot(equals(identity.keyPair.publicKey)));
    });

    test('spaceId is derived from raw space header CID and replication key',
        () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.spaceId, matches(RegExp(r'^bafy[a-z2-7]+\.[0-9a-z]+$')));
      expect(identity.spaceHeader.id, identity.spaceId);
      expect(identity.spaceHeader.rawHeader, isNotEmpty);
    });

    test('keyPair has matching private and public keys', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.keyPair.privateKey.length, 32);
      expect(identity.keyPair.publicKey.length, 32);
      // privateKey should be the seed
      expect(identity.keyPair.privateKey, identity.seed);
    });

    test('space header is signed by the account key', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      final rawHeader = RawSpaceHeader.fromBuffer(identity.spaceHeader.rawHeader);
      final header = SpaceHeader.fromBuffer(rawHeader.spaceHeader);

      expect(header.identity, identity.accountKeyPair.publicKey);
      final valid = await ed25519Verify(
        identity.accountKeyPair.publicKey,
        Uint8List.fromList(rawHeader.spaceHeader),
        Uint8List.fromList(rawHeader.signature),
      );
      expect(valid, isTrue);
    });
  });
}
