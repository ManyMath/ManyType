import 'package:fixnum/fixnum.dart';
import 'package:manytype_cli/src/head_sync_client.dart';
import 'package:manytype_protocol/spacesync.dart';
import 'package:test/test.dart';

void main() {
  group('HeadSyncClient', () {
    test('starts with a full-range hash-only V3 request', () {
      final seenRequests = <HeadSyncRequest>[];
      final client = HeadSyncClient(
        invoker: (handleId, method, payload) {
          seenRequests.add(HeadSyncRequest.fromBuffer(payload));
          return HeadSyncResponse(
            results: [
              HeadSyncResult(hash: [1], count: 0)
            ],
          ).writeToBuffer();
        },
      );

      client.fetchServerHeads(7, 'space-1');

      expect(seenRequests, hasLength(1));
      expect(seenRequests.single.diffType, DiffType.V3);
      expect(seenRequests.single.ranges, hasLength(1));
      expect(seenRequests.single.ranges.single.elements, isFalse);
      expect(seenRequests.single.ranges.single.from, Int64.ZERO);
      expect(
        seenRequests.single.ranges.single.to,
        Int64.parseHex('ffffffffffffffff'),
      );
    });

    test('subdivides a large hash-only mismatch into 32 child ranges', () {
      final seenRequests = <HeadSyncRequest>[];
      final responses = <HeadSyncResponse>[
        HeadSyncResponse(
          results: [
            HeadSyncResult(hash: [1], count: 300)
          ],
        ),
        HeadSyncResponse(
          results: List.generate(
            32,
            (_) => HeadSyncResult(hash: const [], count: 0),
          ),
        ),
      ];
      final client = HeadSyncClient(
        invoker: (handleId, method, payload) {
          seenRequests.add(HeadSyncRequest.fromBuffer(payload));
          return responses.removeAt(0).writeToBuffer();
        },
      );

      client.fetchServerHeads(7, 'space-1');

      expect(seenRequests, hasLength(2));
      expect(seenRequests[1].ranges, hasLength(32));
      expect(seenRequests[1].ranges.every((range) => !range.elements), isTrue);
    });

    test('re-requests a small hash-only mismatch with elements enabled', () {
      final seenRequests = <HeadSyncRequest>[];
      final responses = <HeadSyncResponse>[
        HeadSyncResponse(
          results: [
            HeadSyncResult(hash: [1], count: 2)
          ],
        ),
        HeadSyncResponse(
          results: [
            HeadSyncResult(
              elements: [
                HeadSyncResultElement(id: 'obj-1', head: 'head-1'),
                HeadSyncResultElement(id: 'obj-2', head: 'head-2'),
              ],
              count: 2,
            ),
          ],
        ),
      ];
      final client = HeadSyncClient(
        invoker: (handleId, method, payload) {
          seenRequests.add(HeadSyncRequest.fromBuffer(payload));
          return responses.removeAt(0).writeToBuffer();
        },
      );

      final heads = client.fetchServerHeads(7, 'space-1');

      expect(seenRequests, hasLength(2));
      expect(seenRequests[1].ranges.single.elements, isTrue);
      expect(heads['obj-1'], equals({'head-1'}));
      expect(heads['obj-2'], equals({'head-2'}));
    });

    test('drops empty ranges and merges collected element heads by object id',
        () {
      final seenRequests = <HeadSyncRequest>[];
      final responses = <HeadSyncResponse>[
        HeadSyncResponse(
          results: [
            HeadSyncResult(hash: [1], count: 400)
          ],
        ),
        HeadSyncResponse(
          results: [
            HeadSyncResult(
              elements: [
                HeadSyncResultElement(id: 'obj-1', head: 'head-a'),
                HeadSyncResultElement(id: 'obj-1', head: 'head-b'),
              ],
              count: 2,
            ),
            ...List.generate(
              31,
              (_) => HeadSyncResult(hash: const [], count: 0),
            ),
          ],
        ),
      ];
      final client = HeadSyncClient(
        invoker: (handleId, method, payload) {
          seenRequests.add(HeadSyncRequest.fromBuffer(payload));
          return responses.removeAt(0).writeToBuffer();
        },
      );

      final heads = client.fetchServerHeads(7, 'space-1');

      expect(seenRequests, hasLength(2));
      expect(heads['obj-1'], equals({'head-a', 'head-b'}));
      expect(heads.keys, hasLength(1));
    });
  });
}
