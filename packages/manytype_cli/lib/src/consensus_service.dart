import 'dart:typed_data';

import 'package:manytype_protocol/consensus.dart';

typedef ConsensusUnaryInvoker = Uint8List Function(
  int handleId,
  String method,
  Uint8List payload,
);

class ConsensusService {
  ConsensusService({required ConsensusUnaryInvoker invoker})
      : _invoker = invoker;

  final ConsensusUnaryInvoker _invoker;

  Ok logAdd({
    required int handleId,
    required String logId,
    required RawRecordWithId record,
  }) {
    final request = LogAddRequest(logId: logId, record: record).writeToBuffer();
    final responseBytes = _invoker(
      handleId,
      '/consensusProto.Consensus/LogAdd',
      Uint8List.fromList(request),
    );
    return Ok.fromBuffer(responseBytes);
  }

  RawRecordWithId recordAdd({
    required int handleId,
    required String logId,
    required RawRecord record,
  }) {
    final request =
        RecordAddRequest(logId: logId, record: record).writeToBuffer();
    final responseBytes = _invoker(
      handleId,
      '/consensusProto.Consensus/RecordAdd',
      Uint8List.fromList(request),
    );
    final response = RawRecordWithId.fromBuffer(responseBytes);
    // The countersigned server response defines the authoritative next link.
    if (response.id.isEmpty) {
      throw StateError('RecordAdd returned an empty recordId');
    }
    return response;
  }
}
