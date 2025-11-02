import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:manytype_core/manytype_core.dart';

/// Shared test vector: b"hello anytype"
/// Expected CID computed via Rust cid crate (CIDv1 + dag-cbor + SHA-256 + base32lower)
const expectedCid =
    'bafyreie7ijnjsupdthz7mvg2y76gd6coqvyic5k36tli2p2bnn6mq24ohi';

void main() {
  final knownBytes = Uint8List.fromList('hello anytype'.codeUnits);
  final emptyBytes = Uint8List(0);

  group('computeCid', () {
    test('produces string starting with b (base32lower multibase prefix)',
        () async {
      final cid = await computeCid(knownBytes);
      expect(cid, startsWith('b'));
    });

    test('produces valid CID for empty bytes', () async {
      final cid = await computeCid(emptyBytes);
      expect(cid, isNotEmpty);
      expect(cid, startsWith('b'));
    });

    test('produces string starting with bafy (CIDv1 + dag-cbor + SHA-256)',
        () async {
      final cid = await computeCid(knownBytes);
      expect(cid, startsWith('bafy'));
    });

    test('two different inputs produce different CIDs', () async {
      final cid1 = await computeCid(knownBytes);
      final cid2 = await computeCid(Uint8List.fromList('other data'.codeUnits));
      expect(cid1, isNot(equals(cid2)));
    });

    test('matches pre-computed cross-language test vector', () async {
      final cid = await computeCid(knownBytes);
      expect(cid, equals(expectedCid));
    });

    test('decodes computed CID strings back into raw CID bytes', () async {
      final cid = await computeCid(knownBytes);
      final cidBytes = cidToBytes(cid);

      expect(cidBytes, hasLength(36));
      expect(cidBytes[0], 0x01);
      expect(cidBytes[1], 0x71);
      expect(cidBytes[2], 0x12);
      expect(cidBytes[3], 0x20);
    });

    test('rejects non-base32lower CID strings', () {
      expect(
        () => cidToBytes('zdj7WkFakeCid'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
