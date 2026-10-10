@TestOn('vm')
library;

import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/head_sync_client.dart';
import 'package:manytype_protocol/spacesync.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manytype_head_sync_');
    AccountRegistry.testBaseDirOverride = tempDir.path;
    CliConfig.testConfigDirOverride = tempDir.path;
  });

  tearDown(() async {
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempDir.delete(recursive: true);
  });

  test('narrows ranges below the divide factor into single hash values', () {
    final target = BigInt.from(5);
    final requests = <HeadSyncRequest>[];
    final client = HeadSyncClient(
      invoker: (handleId, method, payload) {
        final request = HeadSyncRequest.fromBuffer(payload);
        requests.add(request);
        return HeadSyncResponse(
          results: [
            for (final range in request.ranges)
              if (_unsigned(range.from) > target ||
                  _unsigned(range.to) < target)
                HeadSyncResult(count: 0)
              else if (range.elements)
                HeadSyncResult(
                  count: 1,
                  elements: [HeadSyncResultElement(id: 'obj', head: 'h')],
                )
              else
                // Claim too many elements until the range is one hash value.
                HeadSyncResult(count: range.from == range.to ? 1 : 300),
          ],
        ).writeToBuffer();
      },
    );

    final heads = client.fetchServerHeads(1, 'space-1');

    expect(heads, {
      'obj': {'h'},
    });
    for (final request in requests.skip(1)) {
      for (final range in request.ranges) {
        expect(_unsigned(range.to) >= _unsigned(range.from), isTrue);
        expect(
          range.from == Int64.ZERO &&
              range.to == Int64.parseHex('ffffffffffffffff'),
          isFalse,
          reason: 'narrowing regenerated the full range',
        );
      }
    }
  });

  test('gives up when counts never resolve instead of growing unbounded', () {
    var requests = 0;
    final client = HeadSyncClient(
      invoker: (handleId, method, payload) {
        requests++;
        final request = HeadSyncRequest.fromBuffer(payload);
        return HeadSyncResponse(
          results: [
            for (final _ in request.ranges) HeadSyncResult(count: 300),
          ],
        ).writeToBuffer();
      },
      maxPendingRanges: 4096,
    );

    expect(
      () => client.fetchServerHeads(1, 'space-1'),
      throwsA(isA<StateError>()),
    );
    expect(requests, lessThanOrEqualTo(4));
  });
}

BigInt _unsigned(Int64 value) => BigInt.parse(value.toStringUnsigned());
