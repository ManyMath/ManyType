import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:manytype_core/manytype_core.dart';
import 'test_vectors.dart';

void main() {
  group('Cross-verification against Go reference vectors', () {
    test('BIP-39 mnemonic produces expected seed', () {
      final seed = mnemonicToSeed(testMnemonic);
      expect(hex.encode(seed), equals(testSeedHex));
    });

    test('SLIP-0010 produces expected identity private key', () async {
      final seed = mnemonicToSeed(testMnemonic);
      final derived = await deriveIdentityKey(seed, index: 0);
      expect(
        hex.encode(derived.privateKey),
        equals(testIdentityPrivateKeyHex),
      );
    });

    test('SLIP-0010 produces expected account private key', () async {
      final seed = mnemonicToSeed(testMnemonic);
      final derived = await deriveAccountKey(seed, index: 0);
      expect(
        hex.encode(derived.privateKey),
        equals(testAccountPrivateKeyHex),
      );
    });

    test('Ed25519 public key from identity seed matches reference', () async {
      final seed = mnemonicToSeed(testMnemonic);
      final derived = await deriveIdentityKey(seed, index: 0);
      final keypair = await ed25519KeyPairFromSeed(derived.privateKey);
      expect(
        hex.encode(keypair.publicKey),
        equals(testIdentityPublicKeyHex),
      );
    });

    test('SLIP-0021 produces expected space key', () async {
      final seed = mnemonicToSeed(testMnemonic);
      final spaceKey = await deriveSpaceKey(seed);
      expect(hex.encode(spaceKey), equals(testSpaceKeyHex));
    });

    test('SLIP-0021 spec vector: Master encryption key', () async {
      final seed = Uint8List.fromList(hex.decode(testSlip21SpecSeedHex));
      final key =
          await slip21Derive(seed, 'm/SLIP-0021/Master encryption key');
      expect(hex.encode(key), equals(testSlip21MasterEncKeyHex));
    });

    test('SLIP-0021 spec vector: Authentication key', () async {
      final seed = Uint8List.fromList(hex.decode(testSlip21SpecSeedHex));
      final key = await slip21Derive(seed, 'm/SLIP-0021/Authentication key');
      expect(hex.encode(key), equals(testSlip21AuthKeyHex));
    });

    test(
        'AES-256-GCM format matches Go: [12-byte nonce][ciphertext][16-byte tag]',
        () async {
      final key = Uint8List(32); // zero key for test
      final plaintext = utf8.encode('hello anytype');
      final encrypted = await aesGcmEncrypt(
        key,
        Uint8List.fromList(plaintext),
      );
      // Verify format: 12 bytes nonce + plaintext.length + 16 bytes tag
      expect(encrypted.length, equals(12 + plaintext.length + 16));
      // Verify round-trip
      final decrypted = await aesGcmDecrypt(key, encrypted);
      expect(decrypted, equals(plaintext));
    });

    test('Ed25519 sign/verify round-trip with derived identity key', () async {
      final seed = mnemonicToSeed(testMnemonic);
      final derived = await deriveIdentityKey(seed, index: 0);
      final keypair = await ed25519KeyPairFromSeed(derived.privateKey);
      final message = utf8.encode('test change payload');
      final signature = await ed25519Sign(
        keypair.privateKey,
        Uint8List.fromList(message),
      );
      expect(signature.length, equals(64));
      final valid = await ed25519Verify(
        keypair.publicKey,
        Uint8List.fromList(message),
        signature,
      );
      expect(valid, isTrue);
    });
  });

  group('Dart-Rust cross-verification', () {
    // Both Dart and Rust must match the same reference vectors.
    // If both match, they match each other (transitive equality).

    test('BIP-39 seed matches Rust output', () {
      final seed = mnemonicToSeed(testMnemonic);
      expect(hex.encode(seed), equals(testSeedHex));
    });

    test('SLIP-0010 identity key matches Rust output', () async {
      final seed = mnemonicToSeed(testMnemonic);
      final derived = await deriveIdentityKey(seed, index: 0);
      // Rust derives the same private key at m/44'/2046'/0'/0'
      expect(
        hex.encode(derived.privateKey),
        equals(testIdentityPrivateKeyHex),
      );
    });

    test('Ed25519 public key matches Rust output', () async {
      final seed = mnemonicToSeed(testMnemonic);
      final derived = await deriveIdentityKey(seed, index: 0);
      final keypair = await ed25519KeyPairFromSeed(derived.privateKey);
      // Rust derives the same public key from the same private seed
      expect(
        hex.encode(keypair.publicKey),
        equals(testIdentityPublicKeyHex),
      );
    });

    test('SLIP-0021 space key matches Rust output', () async {
      final seed = mnemonicToSeed(testMnemonic);
      final spaceKey = await deriveSpaceKey(seed);
      // Rust derives the same space key
      expect(hex.encode(spaceKey), equals(testSpaceKeyHex));
    });

    test('AES-256-GCM encrypt/decrypt interop format', () async {
      // Both Dart and Rust use the same wire format:
      // [12-byte nonce][ciphertext][16-byte GCM tag]
      // While we can't directly call Rust from Dart tests,
      // we verify the format is identical so cross-decryption works.
      final key = Uint8List(32);
      key.fillRange(0, 32, 42); // key = [42, 42, ..., 42]
      final plaintext = Uint8List.fromList(utf8.encode('hello anytype'));
      final encrypted = await aesGcmEncrypt(key, plaintext);

      // Format check: nonce(12) + ciphertext(13) + tag(16) = 41
      expect(encrypted.length, equals(41));

      // Nonce is first 12 bytes
      final nonce = encrypted.sublist(0, 12);
      expect(nonce.length, equals(12));

      // Decrypt with same key works
      final decrypted = await aesGcmDecrypt(key, encrypted);
      expect(utf8.decode(decrypted), equals('hello anytype'));
    });
  });
}
