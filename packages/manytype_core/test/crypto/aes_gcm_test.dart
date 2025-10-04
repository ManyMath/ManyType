import 'dart:math';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:manytype_core/src/crypto/aes_gcm.dart';

void main() {
  group('AES-256-GCM', () {
    late Uint8List key;

    setUp(() {
      // Random 32-byte key
      final rng = Random.secure();
      key = Uint8List(32);
      for (var i = 0; i < 32; i++) {
        key[i] = rng.nextInt(256);
      }
    });

    test('encrypt produces output with correct format: nonce + ciphertext + tag', () async {
      final plaintext = Uint8List.fromList([1, 2, 3, 4, 5]);
      final encrypted = await aesGcmEncrypt(key, plaintext);
      // Format: 12-byte nonce + plaintext_len + 16-byte GCM tag
      expect(encrypted.length, equals(12 + 5 + 16));
    });

    test('decrypt(encrypt(x)) == x round-trip', () async {
      final plaintext = Uint8List.fromList(
        List.generate(100, (i) => i % 256),
      );
      final encrypted = await aesGcmEncrypt(key, plaintext);
      final decrypted = await aesGcmDecrypt(key, encrypted);
      expect(decrypted, equals(plaintext));
    });

    test('round-trip with empty plaintext', () async {
      final plaintext = Uint8List(0);
      final encrypted = await aesGcmEncrypt(key, plaintext);
      // 12-byte nonce + 0 plaintext + 16-byte tag
      expect(encrypted.length, equals(12 + 0 + 16));
      final decrypted = await aesGcmDecrypt(key, encrypted);
      expect(decrypted, equals(plaintext));
    });

    test('each encryption produces a unique nonce', () async {
      final plaintext = Uint8List.fromList([1, 2, 3]);
      final e1 = await aesGcmEncrypt(key, plaintext);
      final e2 = await aesGcmEncrypt(key, plaintext);
      // First 12 bytes (nonce) should differ
      final nonce1 = e1.sublist(0, 12);
      final nonce2 = e2.sublist(0, 12);
      expect(nonce1, isNot(equals(nonce2)));
    });

    test('decrypt with wrong key fails', () async {
      final plaintext = Uint8List.fromList([1, 2, 3, 4, 5]);
      final encrypted = await aesGcmEncrypt(key, plaintext);

      final wrongKey = Uint8List(32);
      wrongKey.fillRange(0, 32, 0xFF);
      expect(
        () => aesGcmDecrypt(wrongKey, encrypted),
        throwsA(anything),
      );
    });

    test('decrypt with tampered ciphertext fails', () async {
      final plaintext = Uint8List.fromList([1, 2, 3, 4, 5]);
      final encrypted = await aesGcmEncrypt(key, plaintext);
      // Tamper with a ciphertext byte (after nonce)
      encrypted[15] ^= 0xFF;
      expect(
        () => aesGcmDecrypt(key, encrypted),
        throwsA(anything),
      );
    });

    test('large plaintext round-trip', () async {
      final rng = Random.secure();
      final plaintext = Uint8List(4096);
      for (var i = 0; i < plaintext.length; i++) {
        plaintext[i] = rng.nextInt(256);
      }
      final encrypted = await aesGcmEncrypt(key, plaintext);
      final decrypted = await aesGcmDecrypt(key, encrypted);
      expect(decrypted, equals(plaintext));
    });
  });
}
