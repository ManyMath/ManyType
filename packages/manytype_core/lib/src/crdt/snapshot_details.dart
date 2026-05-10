import 'dart:typed_data';

import 'package:libcompress/src/snappy/snappy_codec.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, TreeChange;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

import '../crypto/aes_gcm.dart';

final _snappy = SnappyCodec();

/// Replay an object's tree-change sequence and return the final details
/// `Map<String, Value>`: i.e. the last-write-wins projection of
/// `Change_Snapshot.details` + every `Change_Content.detailsSet` entry.
///
/// This is a pure projection of `snapshot.dart`'s replay loop onto the
/// details map only. It mirrors the existing walk in
/// `packages/manytype_cli/lib/src/commands/list.dart` lines 128-203
/// verbatim, moved into `manytype_core` so both the CLI write-path
/// (selectDict read-before-append in create.dart, tag read-modify-write
/// in edit.dart) and Phase 38's local option-index scanner can share a
/// single implementation.
///
/// Inputs:
///  - [rawTreeChanges]: ordered list of `RawTreeChange` byte blobs, i.e.
///    the `rawBytes` column of `db.getChangesForObject` rows. Callers in
///    the CLI layer extract these from their Drift `Change` row type; the
///    helper itself stays free of any Drift dependency.
///  - [treeKey]: per-object tree key derived via `deriveTreeKey(spaceKey,
///    objectId)`. Ignored for any individual change whose `readKeyId` is
///    empty (e.g. root changes).
///
/// Behavior:
///  - Any `RawTreeChange` whose `payload` is empty is skipped.
///  - Any `TreeChange` that fails to parse (e.g. actual root change) is
///    skipped silently: root changes never carry `detailsSet` content
///    and their smart_block_type is read by [loadLocalOptionIndex]'s
///    varint helper instead.
///  - `TreeChange.changesData` is AES-GCM decrypted with [treeKey] IFF
///    `readKeyId.isNotEmpty`, and snappy-decompressed IFF
///    `dataType == '1/s'`. This matches `list.dart` lines 144-150.
///  - A `Change` with `snapshot.data.details` set RESETS the running
///    details map (matches `snapshot.dart`'s snapshot-boundary semantics).
///  - Each `Change_Content.detailsSet` overwrites the running map at its
///    key with `value.deepCopy()`: deep-copied so the caller can mutate
///    freely without affecting subsequent calls.
///
/// Callers should wrap in a `try/catch` on a per-object basis if they
/// want to tolerate malformed individual objects without halting a full
/// space scan (e.g. `loadLocalOptionIndex`).
Future<Map<String, Value>> replayObjectDetails({
  required List<Uint8List> rawTreeChanges,
  required Uint8List treeKey,
}) async {
  final details = <String, Value>{};

  for (final raw in rawTreeChanges) {
    try {
      final rawTc = RawTreeChange.fromBuffer(raw);
      if (rawTc.payload.isEmpty) continue;

      final TreeChange tc;
      try {
        tc = TreeChange.fromBuffer(rawTc.payload);
      } catch (_) {
        // Root change or unparseable non-TreeChange envelope: skip.
        continue;
      }
      if (tc.changesData.isEmpty) continue;

      var data = Uint8List.fromList(tc.changesData);
      if (tc.readKeyId.isNotEmpty) {
        data = await aesGcmDecrypt(treeKey, data);
      }
      if (tc.dataType == '1/s') {
        data = _snappy.decompress(data);
      }

      final change = changes_proto.Change.fromBuffer(data);

      if (change.hasSnapshot() && change.snapshot.data.hasDetails()) {
        details.clear();
        for (final entry in change.snapshot.data.details.fields.entries) {
          details[entry.key] = entry.value.deepCopy();
        }
      }

      for (final content in change.content) {
        if (content.hasDetailsSet()) {
          details[content.detailsSet.key] = content.detailsSet.value.deepCopy();
        }
      }
    } catch (_) {
      // Encrypted-without-key, corrupt, or otherwise unreadable change : 
      // skip silently and continue the replay (matches list.dart:199-201).
      continue;
    }
  }

  return details;
}
