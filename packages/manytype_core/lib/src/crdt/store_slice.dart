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
