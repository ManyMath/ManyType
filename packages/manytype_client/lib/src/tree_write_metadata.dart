import 'dart:typed_data';

import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, TreeChange;

import 'acl_codec.dart';
import 'store/database.dart';

/// The acl/snapshot/read-key IDs a new tree write needs, resolved from the
/// object's own most recent stored change rather than assumed fixed values
/// -- a change's acl head can advance independently of the space's original
/// bootstrap acl root once membership changes.
class TreeWriteMetadata {
  const TreeWriteMetadata({
    required this.aclHeadId,
    required this.snapshotBaseId,
    required this.readKeyId,
  });

  final String aclHeadId;
  final String snapshotBaseId;
  final String readKeyId;
}

/// Resolve [TreeWriteMetadata] for a write against [currentHeads], preferring
/// whatever the most recent stored change among those heads itself declares
/// and falling back to the supplied space-level defaults otherwise.
TreeWriteMetadata resolveTreeWriteMetadata(
  List<Change> changes,
  List<String> currentHeads, {
  required String fallbackAclHeadId,
  required String fallbackSnapshotBaseId,
}) {
  final currentHeadSet = currentHeads.toSet();

  for (final stored in changes.reversed) {
    if (!currentHeadSet.contains(stored.id)) {
      continue;
    }
    final decoded = _decodeStoredTreeChange(stored);
    if (decoded == null) {
      continue;
    }
    final aclHeadId =
        decoded.aclHeadId.isNotEmpty ? decoded.aclHeadId : fallbackAclHeadId;
    final snapshotBaseId = decoded.isSnapshot
        ? stored.id
        : decoded.snapshotBaseId.isNotEmpty
            ? decoded.snapshotBaseId
            : fallbackSnapshotBaseId;
    final readKeyId =
        decoded.readKeyId.isNotEmpty ? decoded.readKeyId : aclHeadId;
    return TreeWriteMetadata(
      aclHeadId: aclHeadId,
      snapshotBaseId: snapshotBaseId,
      readKeyId: readKeyId,
    );
  }

  return TreeWriteMetadata(
    aclHeadId: fallbackAclHeadId,
    snapshotBaseId: fallbackSnapshotBaseId,
    readKeyId: fallbackAclHeadId,
  );
}

TreeChange? _decodeStoredTreeChange(Change stored) {
  try {
    final rawTreeChange = RawTreeChange.fromBuffer(stored.rawBytes);
    if (rawTreeChange.payload.isEmpty) {
      return null;
    }
    return TreeChange.fromBuffer(rawTreeChange.payload);
  } catch (_) {
    return null;
  }
}

/// Find the object whose changes decode to an [AclRoot] for [spaceId] --
/// the space's ACL bootstrap object, needed as a fallback aclHeadId for any
/// new tree write.
Future<String> findAclRootId(
  ManytypeDatabase db,
  List<StoredObject> objects,
  String spaceId,
) async {
  for (final object in objects) {
    final changes = await db.getChangesForObject(object.id);
    if (changes.isEmpty) continue;
    for (final change in changes) {
      try {
        final aclRoot = tryDecodeAclRootFromRawRecordBytes(
          Uint8List.fromList(change.rawBytes),
        );
        if (aclRoot != null && aclRoot.spaceId == spaceId) {
          return object.id;
        }
      } catch (_) {
        continue;
      }
    }
  }
  throw StateError('Space bootstrap is missing an ACL root');
}
