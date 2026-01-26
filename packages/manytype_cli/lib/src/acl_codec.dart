import 'dart:typed_data';

import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

AclRoot? tryDecodeAclRootFromRawRecordBytes(Uint8List rawRecordBytes) {
  try {
    final rawRecord = RawRecord.fromBuffer(rawRecordBytes);

    try {
      final record = Record.fromBuffer(rawRecord.payload);
      final decoded = AclRoot.fromBuffer(record.data);
      if (decoded.spaceId.isNotEmpty) {
        return decoded;
      }
    } catch (_) {
      // fall through
    }

    final decoded = AclRoot.fromBuffer(rawRecord.payload);
    if (decoded.spaceId.isNotEmpty) {
      return decoded;
    }
    return null;
  } catch (_) {
    return null;
  }
}
