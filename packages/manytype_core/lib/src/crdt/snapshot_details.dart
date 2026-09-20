import 'dart:typed_data';

import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

import 'change_replay.dart';

/// Replay an object's tree-change sequence and return the final details
/// `Map<String, Value>`.
///
/// This is the details projection of `replayObjectState`: both run the same
/// replay, so snapshot boundaries, `detailsSet` (a set without a value
/// deletes the key, as in heart) and `detailsUnset` behave identically. It
/// lives in `manytype_core` so the CLI write-path (selectDict
/// read-before-append in create.dart, tag read-modify-write in edit.dart)
/// and the local option-index scanner can share a single implementation.
///
/// Inputs:
///  - [rawTreeChanges]: topologically ordered list of `RawTreeChange` byte
///    blobs, i.e. the `rawBytes` column of `db.getChangesForObject` rows.
///    Callers in the CLI layer extract these from their Drift `Change` row
///    type; the helper itself stays free of any Drift dependency.
///  - [treeKey]: per-object tree key derived via `deriveTreeKey(spaceKey,
///    objectId)`. Ignored for any individual change whose `readKeyId` is
///    empty (e.g. root changes).
///
/// Unlike `replayObjectState`, a root change is not required and any change
/// that cannot be decrypted or decoded is skipped silently, so callers can
/// tolerate malformed individual changes. Callers should still wrap in a
/// `try/catch` on a per-object basis if they want to tolerate malformed
/// objects without halting a full space scan (e.g. `loadLocalOptionIndex`).
Future<Map<String, Value>> replayObjectDetails({
  required List<Uint8List> rawTreeChanges,
  required Uint8List treeKey,
}) async {
  final state = await replayRawTreeChanges(
    rawTreeChanges,
    treeKey,
    skipUnreadable: true,
  );
  return Map.of(state.details.fields);
}
