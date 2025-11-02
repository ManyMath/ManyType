import 'dart:typed_data';

import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/spacesync.dart';

typedef SpacePullUnaryInvoker = Uint8List Function(
  int handleId,
  String method,
  Uint8List payload,
);

class SpacePullBootstrapResult {
  const SpacePullBootstrapResult({
    required this.payload,
    required this.aclRecords,
  });

  final SpacePayload payload;
  final List<RawRecordWithId> aclRecords;
}

class SpacePullBootstrap {
  SpacePullBootstrap({required SpacePullUnaryInvoker invoker})
      : _invoker = invoker;

  final SpacePullUnaryInvoker _invoker;

  SpacePullBootstrapResult fetch({
    required int handleId,
    required String spaceId,
  }) {
    final request = SpacePullRequest(id: spaceId).writeToBuffer();
    final responseBytes = _invoker(
      handleId,
      '/spacesync.SpaceSync/SpacePull',
      Uint8List.fromList(request),
    );
    final response = SpacePullResponse.fromBuffer(responseBytes);
    if (!response.hasPayload()) {
      throw StateError('SpacePull returned no payload for $spaceId');
    }

    return SpacePullBootstrapResult(
      payload: response.payload,
      aclRecords:
          response.aclRecords.map(_normalizeAclRecord).toList(growable: false),
    );
  }

  RawRecordWithId _normalizeAclRecord(AclRecord record) {
    try {
      final decoded = RawRecordWithId.fromBuffer(record.aclPayload);
      if (decoded.id.isNotEmpty) {
        return decoded;
      }
    } catch (_) {
      // Fall back to the explicit ID field if the payload is only a raw record.
    }
    return RawRecordWithId(
      id: record.id,
      payload: record.aclPayload,
    );
  }
}
