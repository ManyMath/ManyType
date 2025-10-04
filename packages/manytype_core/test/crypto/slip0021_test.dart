import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:manytype_core/src/crypto/slip0021.dart';

void main() {
  group('SLIP-0021', () {
    // Test vectors from SLIP-0021 spec and go-slip21 test suite
    // Seed from: https://github.com/satoshilabs/slips/blob/master/slip-0021.md#example
    final seed = Uint8List.fromList(hex.decode(
      'c76c4ac4f4e4a00d6b274d5c39c700bb4a7ddc04fbc6f78e85ca75007b5b495f'
      '74a9043eeb77bdd53aa6fc3a0e31462270316fa04b8c19114c8798706cd02ac8',
    ));

    test('master node key matches SLIP-0021 spec vector', () async {
      // Key(m) from the spec
      final key = await slip21Derive(seed, 'm');
      expect(
        hex.encode(key),
        equals('dbf12b44133eaab506a740f6565cc117228cbf1dd70635cfa8ddfdc9af734756'),
      );
    });

    test('Key(m/SLIP-0021) matches spec vector', () async {
      final key = await slip21Derive(seed, 'm/SLIP-0021');
      expect(
        hex.encode(key),
        equals('1d065e3ac1bbe5c7fad32cf2305f7d709dc070d672044a19e610c77cdf33de0d'),
      );
    });

    test('Key(m/SLIP-0021/Master encryption key) matches spec vector', () async {
      final key = await slip21Derive(seed, 'm/SLIP-0021/Master encryption key');
      expect(
        hex.encode(key),
        equals('ea163130e35bbafdf5ddee97a17b39cef2be4b4f390180d65b54cf05c6a82fde'),
      );
    });

    test('Key(m/SLIP-0021/Authentication key) matches spec vector', () async {
      final key = await slip21Derive(seed, 'm/SLIP-0021/Authentication key');
      expect(
        hex.encode(key),
        equals('47194e938ab24cc82bfa25f6486ed54bebe79c40ae2a5a32ea6db294d81861a6'),
      );
    });

    test('deriveSpaceKey returns 32 bytes', () async {
      final key = await deriveSpaceKey(seed);
      expect(key.length, equals(32));
    });

    test('deriveSpaceKey is deterministic', () async {
      final k1 = await deriveSpaceKey(seed);
      final k2 = await deriveSpaceKey(seed);
      expect(hex.encode(k1), equals(hex.encode(k2)));
    });

    test('deriveSpaceKey with different seeds produces different keys', () async {
      final seed2 = Uint8List(64);
      seed2.fillRange(0, 64, 0x42);
      final k1 = await deriveSpaceKey(seed);
      final k2 = await deriveSpaceKey(seed2);
      expect(hex.encode(k1), isNot(equals(hex.encode(k2))));
    });

    test('slip21Derive rejects invalid path', () async {
      expect(
        () => slip21Derive(seed, 'invalid'),
        throwsArgumentError,
      );
    });
  });
}
