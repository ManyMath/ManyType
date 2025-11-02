import 'dart:typed_data';

import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/coordinator.dart';

typedef AclSyncUnaryInvoker = Uint8List Function(
  int handleId,
  String method,
  Uint8List payload,
);

class AclSyncService {
  AclSyncService({required AclSyncUnaryInvoker invoker}) : _invoker = invoker;

  final AclSyncUnaryInvoker _invoker;

  void spaceMakeShareable({
    required int handleId,
    required String spaceId,
  }) {
    final request = SpaceMakeShareableRequest(spaceId: spaceId).writeToBuffer();
    _invoker(
      handleId,
      '/coordinator.Coordinator/SpaceMakeShareable',
      Uint8List.fromList(request),
    );
  }

  RawRecordWithId addRecord({
    required int handleId,
    required String spaceId,
    required RawRecord record,
  }) {
    final request = AclAddRecordRequest(
      spaceId: spaceId,
      payload: record.writeToBuffer(),
    ).writeToBuffer();
    final responseBytes = _invoker(
      handleId,
      '/coordinator.Coordinator/AclAddRecord',
      Uint8List.fromList(request),
    );
    final response = AclAddRecordResponse.fromBuffer(responseBytes);
    if (response.recordId.isEmpty) {
      throw StateError('AclAddRecord returned an empty recordId');
    }
    return RawRecordWithId(
      id: response.recordId,
      payload: response.payload,
    );
  }

  List<RawRecordWithId> getRecords({
    required int handleId,
    required String spaceId,
    String aclHead = '',
  }) {
    final request = AclGetRecordsRequest(
      spaceId: spaceId,
      aclHead: aclHead,
    ).writeToBuffer();
    final responseBytes = _invoker(
      handleId,
      '/coordinator.Coordinator/AclGetRecords',
      Uint8List.fromList(request),
    );
    final response = AclGetRecordsResponse.fromBuffer(responseBytes);
    return response.records
        .map((recordBytes) => RawRecordWithId.fromBuffer(recordBytes))
        .toList(growable: false);
  }
}
