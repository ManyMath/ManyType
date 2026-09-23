import 'package:manytype_protocol/changes.dart' as changes_proto;

/// Build a StoreSliceUpdate add operation for [key].
///
/// An empty [afterId] prepends the incoming [ids].
changes_proto.Change_Content buildStoreSliceUpdateAdd({
  required String key,
  required List<String> ids,
  String afterId = '',
}) {
  return changes_proto.Change_Content(
    storeSliceUpdate: changes_proto.Change_StoreSliceUpdate(
      key: key,
      add: changes_proto.Change_StoreSliceUpdate_Add(
        afterId: afterId,
        ids: ids,
      ),
    ),
  );
}

/// Build a StoreSliceUpdate remove operation for [key].
changes_proto.Change_Content buildStoreSliceUpdateRemove({
  required String key,
  required List<String> ids,
}) {
  return changes_proto.Change_Content(
    storeSliceUpdate: changes_proto.Change_StoreSliceUpdate(
      key: key,
      remove: changes_proto.Change_StoreSliceUpdate_Remove(ids: ids),
    ),
  );
}

/// Build a StoreSliceUpdate move operation for [key].
///
/// An empty [afterId] moves the incoming [ids] to the front.
changes_proto.Change_Content buildStoreSliceUpdateMove({
  required String key,
  required List<String> ids,
  String afterId = '',
}) {
  return changes_proto.Change_Content(
    storeSliceUpdate: changes_proto.Change_StoreSliceUpdate(
      key: key,
      move: changes_proto.Change_StoreSliceUpdate_Move(
        afterId: afterId,
        ids: ids,
      ),
    ),
  );
}

/// Apply a StoreSliceUpdate to the [current] slice and return the result.
///
/// Ports heart's `slice.ApplyChanges` exactly: duplicates in [current] are
/// dropped first (keeping the first occurrence); `add` inserts after
/// `afterId`, or at the front when `afterId` is empty or missing; `move`
/// re-inserts only ids that were already in [current]; `remove` filters the
/// ids out.
List<String> applyStoreSliceUpdate(
  Iterable<String> current,
  changes_proto.Change_StoreSliceUpdate update,
) {
  final known = <String>{};
  final result = [
    for (final id in current)
      if (known.add(id)) id,
  ];
  switch (update.whichOperation()) {
    case changes_proto.Change_StoreSliceUpdate_Operation.add:
      final afterIndex =
          update.add.afterId.isEmpty ? -1 : result.indexOf(update.add.afterId);
      result.insertAll(afterIndex + 1, update.add.ids);
      break;
    case changes_proto.Change_StoreSliceUpdate_Operation.remove:
      result.removeWhere(update.remove.ids.contains);
      break;
    case changes_proto.Change_StoreSliceUpdate_Operation.move:
      result.removeWhere(update.move.ids.contains);
      final afterIndex = update.move.afterId.isEmpty
          ? -1
          : result.indexOf(update.move.afterId);
      result.insertAll(afterIndex + 1, update.move.ids.where(known.contains));
      break;
    case changes_proto.Change_StoreSliceUpdate_Operation.notSet:
      break;
  }
  return result;
}
