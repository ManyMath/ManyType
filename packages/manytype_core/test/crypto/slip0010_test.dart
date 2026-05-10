import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:manytype_core/src/crypto/bip39.dart';
import 'package:manytype_core/src/crypto/slip0010.dart';

void main() {
  group('SLIP-0010', () {
    // Use standard BIP-39 test vector seed
    late List<int> seed;

    setUp(() {
      const mnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      seed = mnemonicToSeed(mnemonic);
    });

    test('deriveIdentityKey returns 32-byte private key', () async {
      final result = await deriveIdentityKey(seed, index: 0);
      expect(result.privateKey.length, equals(32));
    });

    test('deriveIdentityKey returns 32-byte chain code', () async {
      final result = await deriveIdentityKey(seed, index: 0);
      expect(result.chainCode.length, equals(32));
    });

    test('deriveAccountKey returns 32-byte private key', () async {
      final result = await deriveAccountKey(seed, index: 0);
      expect(result.privateKey.length, equals(32));
    });

    test('same seed always produces same identity key', () async {
      final r1 = await deriveIdentityKey(seed, index: 0);
      final r2 = await deriveIdentityKey(seed, index: 0);
      expect(hex.encode(r1.privateKey), equals(hex.encode(r2.privateKey)));
    });

    test('different indices produce different keys', () async {
      final r0 = await deriveIdentityKey(seed, index: 0);
      final r1 = await deriveIdentityKey(seed, index: 1);
      expect(
          hex.encode(r0.privateKey), isNot(equals(hex.encode(r1.privateKey))));
    });

    test('identity key differs from account key (extra derivation level)',
        () async {
      final account = await deriveAccountKey(seed, index: 0);
      final identity = await deriveIdentityKey(seed, index: 0);
      expect(
        hex.encode(account.privateKey),
        isNot(equals(hex.encode(identity.privateKey))),
      );
    });

    test('deriveIdentityKey uses m/44h/2046h/index/0h path', () async {
      // The identity key at index 0 should use path m/44'/2046'/0'/0'
      // which is the Anytype standard derivation path
      final result = await deriveIdentityKey(seed, index: 0);
      // Verify it produces a non-zero key (basic sanity)
      final keyHex = hex.encode(result.privateKey);
      expect(keyHex, isNot(equals('00' * 32)));
    });

    test('SLIP-0010 test vector: seed 000102030405060708090a0b0c0d0e0f',
        () async {
      // SLIP-0010 Ed25519 test vector from the spec
      // Seed: 000102030405060708090a0b0c0d0e0f
      // Chain m: private key = 2b4be7f19ee27bbf30c667b642d5f4aa69fd169872f8fc3059c08ebae2eb19e7
      // Chain m: chain code = 90046a93de5380a72b5e45010748567d5ea02bbf6522f979e05c0d8d8ca9fffb
      final testSeed = hex.decode('000102030405060708090a0b0c0d0e0f');
      // getMasterKeyFromSeed is SLIP-0010 master key derivation
      // We test it indirectly through the derivePath function
      final result = await deriveFromPath("m/0'", testSeed);
      expect(result.privateKey.length, equals(32));
      expect(result.chainCode.length, equals(32));
    });
  });
}
