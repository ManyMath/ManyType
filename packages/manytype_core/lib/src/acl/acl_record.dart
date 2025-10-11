import 'dart:typed_data';

import 'package:manytype_protocol/manytype_protocol.dart';

/// Verified ACL record with decoded fields.
class VerifiedAclRecord {
  /// CID of this record.
  final String id;

  /// CID of the previous record (empty for root).
  final String prevId;

  /// Signer's Ed25519 public key (32 bytes).
  final Uint8List identity;

  /// Decoded ACL content (null for root record).
  final AclData? aclData;

  /// Decoded AclRoot (null for non-root records).
  final AclRoot? aclRoot;

  /// Timestamp from the inner Record.
  final int timestamp;

  VerifiedAclRecord({
    required this.id,
    required this.prevId,
    required this.identity,
    this.aclData,
    this.aclRoot,
    required this.timestamp,
  });

  /// True if this is the root record in the ACL chain.
  bool get isRoot => prevId.isEmpty;
}
