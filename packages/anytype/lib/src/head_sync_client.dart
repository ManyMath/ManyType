import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_protocol/spacesync.dart';

typedef HeadSyncUnaryInvoker = Uint8List Function(
  int handleId,
  String method,
  Uint8List payload,
);

class HeadSyncClient {
  HeadSyncClient({
    required HeadSyncUnaryInvoker invoker,
    DiffType diffType = DiffType.V3,
    int divideFactor = 32,
    int compareThreshold = 256,
    int maxRounds = 64,
    int maxPendingRanges = 1 << 16,
  })  : _invoker = invoker,
        _diffType = diffType,
        _divideFactor = divideFactor,
        _compareThreshold = compareThreshold,
        _maxRounds = maxRounds,
        _maxPendingRanges = maxPendingRanges;

  final HeadSyncUnaryInvoker _invoker;
  final DiffType _diffType;
  final int _divideFactor;
  final int _compareThreshold;

  // A server reporting counts it never resolves would otherwise make
  // narrowing grow the pending ranges by [_divideFactor] every round.
  final int _maxRounds;
  final int _maxPendingRanges;

  Map<String, Set<String>> fetchServerHeads(int handleId, String spaceId) {
    final serverHeads = <String, Set<String>>{};
    var pending = <HeadSyncRange>[_fullRange(elements: false)];
    var rounds = 0;

    while (pending.isNotEmpty) {
      if (++rounds > _maxRounds) {
        throw StateError(
          'HeadSync did not converge after $_maxRounds rounds',
        );
      }
      print('HeadSync: pending ranges=${pending.length}');
      final request = HeadSyncRequest(
        spaceId: spaceId,
        diffType: _diffType,
        ranges: pending,
      );
      final requestBytes = Uint8List.fromList(request.writeToBuffer());
      final responseBytes =
          _invoker(handleId, '/spacesync.SpaceSync/HeadSync', requestBytes);
      final response = HeadSyncResponse.fromBuffer(responseBytes);
      if (response.results.length != pending.length) {
        throw StateError(
          'HeadSync result count mismatch: '
          'requested=${pending.length}, got=${response.results.length}',
        );
      }

      final nextRanges = <HeadSyncRange>[];
      for (var index = 0; index < pending.length; index++) {
        final range = pending[index];
        final result = response.results[index];

        if (result.elements.isNotEmpty) {
          for (final element in result.elements) {
            serverHeads
                .putIfAbsent(element.id, () => <String>{})
                .add(element.head);
          }
          if (result.count > result.elements.length) {
            // Some servers cap the number of elements returned per range even
            // when `limit=0`. If we didn't receive all elements, subdivide and
            // keep narrowing until we can fetch the complete set.
            _addSubdivided(nextRanges, range);
          }
          continue;
        }

        if (result.count == 0) {
          continue;
        }

        if (range.elements) {
          throw StateError(
            'HeadSync returned no elements for expanded range '
            '${range.from}..${range.to} with count=${result.count}',
          );
        }

        if (result.count <= _compareThreshold) {
          nextRanges.add(
            HeadSyncRange(
              from: range.from,
              to: range.to,
              elements: true,
              limit: 0,
            ),
          );
          continue;
        }

        // A hash-only response means the client must narrow the range again.
        _addSubdivided(nextRanges, range);
      }

      pending = nextRanges;
    }

    return serverHeads;
  }

  HeadSyncRange _fullRange({required bool elements}) => HeadSyncRange(
        from: Int64.ZERO,
        to: _uint64ToProto(_u64Mask),
        elements: elements,
        limit: 0,
      );

  void _addSubdivided(List<HeadSyncRange> ranges, HeadSyncRange range) {
    ranges.addAll(_subdivide(range));
    if (ranges.length > _maxPendingRanges) {
      throw StateError(
        'HeadSync narrowing exceeded $_maxPendingRanges pending ranges',
      );
    }
  }

  List<HeadSyncRange> _subdivide(HeadSyncRange range) {
    final from = _protoToUint64(range.from);
    final to = _protoToUint64(range.to);
    if (to - from < BigInt.from(_divideFactor)) {
      // Too narrow for [_divideFactor] parts: the equal split below would
      // produce zero-width parts that wrap around (from 0, to the full
      // range). Split into single hash values instead.
      if (to <= from) {
        throw StateError('HeadSync cannot narrow range $from..$to further');
      }
      return [
        for (var value = from; value <= to; value += BigInt.one)
          HeadSyncRange(
            from: _uint64ToProto(value),
            to: _uint64ToProto(value),
            elements: false,
            limit: 0,
          ),
      ];
    }
    var perRange = (to - from) ~/ BigInt.from(_divideFactor);
    final align = ((to - from) % BigInt.from(_divideFactor) + BigInt.one) %
        BigInt.from(_divideFactor);
    if (align == BigInt.zero) {
      perRange += BigInt.one;
    }

    var current = from;
    final ranges = <HeadSyncRange>[];
    for (var index = 0; index < _divideFactor; index++) {
      var width = perRange;
      if (index == _divideFactor - 1) {
        width += align;
      }
      final end = (current + width - BigInt.one) & _u64Mask;
      ranges.add(
        HeadSyncRange(
          from: _uint64ToProto(current),
          to: _uint64ToProto(end),
          elements: false,
          limit: 0,
        ),
      );
      current = (current + width) & _u64Mask;
    }
    return ranges;
  }
}

final BigInt _u64Mask = (BigInt.one << 64) - BigInt.one;
final BigInt _u64SignBit = BigInt.one << 63;
final BigInt _u64Modulus = BigInt.one << 64;

BigInt _protoToUint64(Int64 value) {
  final signed = BigInt.from(value.toInt());
  return signed < BigInt.zero ? signed + _u64Modulus : signed;
}

Int64 _uint64ToProto(BigInt value) {
  final normalized = value & _u64Mask;
  final signed =
      normalized >= _u64SignBit ? normalized - _u64Modulus : normalized;
  return Int64.parseInt(signed.toString());
}
