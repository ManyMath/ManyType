import 'package:manytype_protocol/models.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    show Value;

const String officialCollectionStoreKey = 'objects';
const String officialCollectionViewId = 'default';

String legacyCollectionStoreKey(String viewId) => 'objectOrder/$viewId';

String resolveCollectionStoreKeyFromValues(
  Block_Content_Dataview dataview,
  Map<String, Value> collections,
) {
  final viewId = dataview.views.isNotEmpty ? dataview.views.first.id : '';
  final legacyKey = viewId.isEmpty ? '' : legacyCollectionStoreKey(viewId);

  if (collections.containsKey(officialCollectionStoreKey)) {
    return officialCollectionStoreKey;
  }
  if (legacyKey.isNotEmpty && collections.containsKey(legacyKey)) {
    return legacyKey;
  }
  if (viewId == officialCollectionViewId) {
    return officialCollectionStoreKey;
  }
  if (legacyKey.isNotEmpty) {
    return legacyKey;
  }
  return officialCollectionStoreKey;
}

String resolveCollectionStoreKeyFromLists(
  Block_Content_Dataview dataview,
  Map<String, List<String>> collections,
) {
  final viewId = dataview.views.isNotEmpty ? dataview.views.first.id : '';
  final legacyKey = viewId.isEmpty ? '' : legacyCollectionStoreKey(viewId);

  if (collections.containsKey(officialCollectionStoreKey)) {
    return officialCollectionStoreKey;
  }
  if (legacyKey.isNotEmpty && collections.containsKey(legacyKey)) {
    return legacyKey;
  }
  if (viewId == officialCollectionViewId) {
    return officialCollectionStoreKey;
  }
  if (legacyKey.isNotEmpty) {
    return legacyKey;
  }
  return officialCollectionStoreKey;
}
