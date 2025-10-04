import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:manytype_core/src/crypto/ed25519.dart';

void main() {
  group('Ed25519', () {
    test('keypair from seed produces 32-byte public key', () async {
      final seed = Uint8List(32);
      seed.fillRange(0, 32, 0x42);
      final kp = await ed25519KeyPairFromSeed(seed);
      expect(kp.publicKey.length, equals(32));
    });

    test('keypair from seed is deterministic', () async {
      final seed = Uint8List(32);
      seed.fillRange(0, 32, 0x01);
      final kp1 = await ed25519KeyPairFromSeed(seed);
      final kp2 = await ed25519KeyPairFromSeed(seed);
      expect(hex.encode(kp1.publicKey), equals(hex.encode(kp2.publicKey)));
    });

    test('sign returns 64-byte signature', () async {
      final seed = Uint8List(32);
      seed.fillRange(0, 32, 0x03);
      final kp = await ed25519KeyPairFromSeed(seed);
      final message = Uint8List.fromList([1, 2, 3, 4, 5]);
      final sig = await ed25519Sign(kp.privateKey, message);
      expect(sig.length, equals(64));
    });

    test('verify accepts valid signature', () async {
      final seed = Uint8List(32);
      seed.fillRange(0, 32, 0x04);
      final kp = await ed25519KeyPairFromSeed(seed);
      final message = Uint8List.fromList([10, 20, 30, 40, 50]);
      final sig = await ed25519Sign(kp.privateKey, message);
      final valid = await ed25519Verify(kp.publicKey, message, sig);
      expect(valid, isTrue);
    });

    test('verify rejects tampered message', () async {
      final seed = Uint8List(32);
      seed.fillRange(0, 32, 0x05);
      final kp = await ed25519KeyPairFromSeed(seed);
      final message = Uint8List.fromList([1, 2, 3, 4, 5]);
      final sig = await ed25519Sign(kp.privateKey, message);
      final tampered = Uint8List.fromList([1, 2, 3, 4, 6]);
      final valid = await ed25519Verify(kp.publicKey, tampered, sig);
      expect(valid, isFalse);
    });

    test('verify rejects wrong public key', () async {
      final seed1 = Uint8List(32)..fillRange(0, 32, 0x06);
      final seed2 = Uint8List(32)..fillRange(0, 32, 0x07);
      final kp1 = await ed25519KeyPairFromSeed(seed1);
      final kp2 = await ed25519KeyPairFromSeed(seed2);
      final message = Uint8List.fromList([1, 2, 3]);
      final sig = await ed25519Sign(kp1.privateKey, message);
      final valid = await ed25519Verify(kp2.publicKey, message, sig);
      expect(valid, isFalse);
    });

    test('sign and verify with empty message', () async {
      final seed = Uint8List(32)..fillRange(0, 32, 0x08);
      final kp = await ed25519KeyPairFromSeed(seed);
      final message = Uint8List(0);
      final sig = await ed25519Sign(kp.privateKey, message);
      final valid = await ed25519Verify(kp.publicKey, message, sig);
      expect(valid, isTrue);
    });

    test('sign and verify with large message', () async {
      final rng = Random.secure();
      final seed = Uint8List(32);
      for (var i = 0; i < 32; i++) seed[i] = rng.nextInt(256);
      final kp = await ed25519KeyPairFromSeed(seed);
      final message = Uint8List(8192);
      for (var i = 0; i < message.length; i++) message[i] = rng.nextInt(256);
      final sig = await ed25519Sign(kp.privateKey, message);
      final valid = await ed25519Verify(kp.publicKey, message, sig);
      expect(valid, isTrue);
    });
  });
}
