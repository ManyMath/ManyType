import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:manytype_core/src/crypto/bip39.dart';

void main() {
  group('BIP-39', () {
    test('generateMnemonic returns 12 words', () {
      final mnemonic = generateMnemonic();
      final words = mnemonic.split(' ');
      expect(words.length, equals(12));
    });

    test('generateMnemonic produces different results each time', () {
      final m1 = generateMnemonic();
      final m2 = generateMnemonic();
      expect(m1, isNot(equals(m2)));
    });

    test('mnemonicToSeed produces 64 bytes', () {
      const mnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      final seed = mnemonicToSeed(mnemonic);
      expect(seed.length, equals(64));
    });

    test('mnemonicToSeed matches BIP-39 test vector', () {
      // Standard BIP-39 test vector for "abandon...about" with empty passphrase
      const mnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      final seed = mnemonicToSeed(mnemonic);
      final seedHex = hex.encode(seed);
      expect(
        seedHex,
        equals(
          '5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc1'
          '9a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4',
        ),
      );
    });

    test('validateMnemonic accepts valid mnemonic', () {
      const mnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      expect(validateMnemonic(mnemonic), isTrue);
    });

    test('validateMnemonic rejects invalid mnemonic', () {
      const bad =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon';
      expect(validateMnemonic(bad), isFalse);
    });

    test('mnemonicToSeed is deterministic', () {
      const mnemonic =
          'tag volcano eight thank tide danger coast health above argue embrace heavy';
      final seed1 = mnemonicToSeed(mnemonic);
      final seed2 = mnemonicToSeed(mnemonic);
      expect(seed1, equals(seed2));
    });
  });
}
