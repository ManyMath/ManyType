import 'package:test/test.dart';
import 'package:manytype_cli/src/identity.dart';

void main() {
  // Known BIP-39 test vector mnemonic
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  group('Identity', () {
    test('derives 32-byte seed from mnemonic', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.seed.length, 32);
    });

    test('derives 32-byte peerId from mnemonic', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.peerId.length, 32);
    });

    test('derivation is deterministic', () async {
      final identity1 = await Identity.fromMnemonic(testMnemonic);
      final identity2 = await Identity.fromMnemonic(testMnemonic);
      expect(identity1.peerId, identity2.peerId);
      expect(identity1.seed, identity2.seed);
    });

    test('spaceId is hex-encoded public key', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      // 32 bytes -> 64 hex chars
      expect(identity.spaceId.length, 64);
      // Should only contain hex characters
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(identity.spaceId), isTrue);
    });

    test('keyPair has matching private and public keys', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.keyPair.privateKey.length, 32);
      expect(identity.keyPair.publicKey.length, 32);
      // privateKey should be the seed
      expect(identity.keyPair.privateKey, identity.seed);
    });
  });
}
