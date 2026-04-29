import 'dart:typed_data';

import 'package:libcompress/src/snappy/snappy_codec.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, RootChange, TreeChange;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    show ListValue, Value;

import '../config.dart';
import '../collection_keys.dart';
import '../identity.dart';
import '../session.dart';
import '../store/database.dart';
import '../sync_service.dart';
import 'create.dart';
import 'delete.dart';
import 'edit.dart';
import 'read.dart';

final _snappy = SnappyCodec();

/// Lightweight metadata extracted from an object's change tree.
class ObjectMeta {
  final String id;
  final List<String> types;
  final String? name;
  final Map<String, String> details;
  final bool isArchived;
  final bool isCollection;
  final int collectionMemberCount;

  ObjectMeta({
    required this.id,
    this.types = const [],
    this.name,
    this.details = const {},
    this.isArchived = false,
    this.isCollection = false,
    this.collectionMemberCount = 0,
  });

  String? get type => types.isEmpty ? null : types.first;
  String get displayType => isCollection
      ? '[Collection] $collectionMemberCount members'
      : (type ?? '<unknown>');
  String get displayName => name ?? '<unnamed>';
}

/// List objects from local store with optional type and field filters.
///
/// Syncs first, then queries the local Drift database for non-deleted
/// objects, decodes metadata from each object's change tree, and applies
/// filters.
Future<List<ObjectMeta>> listCommand(
  ManytypeDatabase db,
  CliConfig config, {
  String? networkConfigPath,
  String? networkConfigContent,
  String? typeFilter,
  String? whereFilter,
  SyncService? syncService,
}) async {
  // Derive identity and space key once.
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final accountKeyPair = await ed25519KeyPairFromSeed(identity.accountSeed);
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);

  // Sync before listing when network access is explicitly requested.
  if (networkConfigPath != null || networkConfigContent != null) {
    final syncServiceRef = syncService ?? SyncService();
    await syncServiceRef.sync(
      db,
      config,
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
    );
  }

  // Query all non-deleted objects.
  final objects = await db.getNonDeletedObjectsBySpace(identity.spaceId);

  // Phase 38: Build the STRelationOption index ONCE per list invocation.
  // We need every non-deleted object's raw changes both for this index and
  // for per-object metadata extraction below, so fetch once and share the
  // in-memory map to avoid double-fetching from Drift.
  final rawChangesByObject = <String, List<Change>>{};
  final optionInputs = <OptionIndexInput>[];
  for (final obj in objects) {
    final rawRows = await db.getChangesForObject(obj.id);
    rawChangesByObject[obj.id] = rawRows;
    final objTreeKey = await deriveTreeKey(spaceKey, obj.id);
    optionInputs.add(OptionIndexInput(
      objectId: obj.id,
      rawTreeChanges:
          rawRows.map((r) => Uint8List.fromList(r.rawBytes)).toList(),
      treeKey: objTreeKey,
    ));
  }
  final Map<String, ResolvedOption> optIndex =
      await loadLocalOptionIndex(optionInputs);

  // Extract metadata for each object, filtering out nulls (system/undecryptable).
  final metas = <ObjectMeta>[];
  for (final obj in objects) {
    final meta = await _extractObjectMeta(
      db,
      obj,
      spaceKey,
      optIndex: optIndex,
      cachedChanges: rawChangesByObject[obj.id],
    );
    if (meta != null && !meta.isArchived) {
      metas.add(meta);
    }
  }

  // Apply --type filter.
  return metas
      .where(
        (m) => matchesObjectMetaFilters(
          m,
          typeFilter: typeFilter,
          whereFilter: whereFilter,
        ),
      )
      .toList();
}

/// Library-facing facade over object listing/creation/deletion/editing/
/// reading, for consumers that hold a [ManytypeSession] instead of driving
/// the CLI directly. Exposed as `session.objects`.
class ListFacade {
  const ListFacade(this._session);

  final ManytypeSession _session;

  Future<List<ObjectMeta>> list({
    String? networkConfigPath,
    String? networkConfigContent,
    String? typeFilter,
    String? whereFilter,
    SyncService? syncService,
  }) {
    return listCommand(
      _session.db,
      _session.config,
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
      typeFilter: typeFilter,
      whereFilter: whereFilter,
      syncService: syncService,
    );
  }

  Future<CreateResult> create(
    String text, {
    bool checkbox = false,
    bool numberedList = false,
    bool toggle = false,
    bool quote = false,
    bool callout = false,
    bool asType = false,
    bool asRelation = false,
    bool asSet = false,
    bool asCollection = false,
    bool asTemplate = false,
    bool asRelationOption = false,
    String? name,
    String? format,
    String? sourceType,
    String? forRelation,
    String? targetObjectType,
    String? templateId,
    String? color,
    bool textProvided = true,
  }) {
    return createCommand(
      text,
      _session.db,
      _session.config,
      checkbox: checkbox,
      numberedList: numberedList,
      toggle: toggle,
      quote: quote,
      callout: callout,
      asType: asType,
      asRelation: asRelation,
      asSet: asSet,
      asCollection: asCollection,
      asTemplate: asTemplate,
      asRelationOption: asRelationOption,
      name: name,
      format: format,
      sourceType: sourceType,
      forRelation: forRelation,
      targetObjectType: targetObjectType,
      templateId: templateId,
      color: color,
      textProvided: textProvided,
    );
  }

  Future<DeleteResult> delete(
    String objectId, {
    String? networkConfigPath,
    String? networkConfigContent,
    SyncService? syncService,
  }) {
    return deleteCommand(
      objectId,
      _session.db,
      _session.config,
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
      syncService: syncService,
    );
  }

  Future<EditResult> edit(
    String objectId,
    String? newText, {
    String? networkConfigPath,
    String? networkConfigContent,
    SyncService? syncService,
    bool checkbox = false,
    String? checkboxText,
    String? relationKey,
    String? stringValue,
    List<String>? stringListValue,
    String? boolValue,
    String? dateValue,
    String? fileRelationPath,
    Uint8List? fileRelationBytes,
    String? fileRelationFileName,
    String? objectIdValue,
    String? blockId,
    String? setText,
    bool? setChecked,
    Block_Content_Text_Style? setStyle,
    String? status,
    List<String>? tagIds,
    List<String> tagAdds = const <String>[],
    List<String> tagRemoves = const <String>[],
    String? collectionAddId,
    String? collectionRemoveId,
    String? collectionMoveId,
    String afterId = '',
  }) {
    return editCommand(
      objectId,
      newText,
      _session.db,
      _session.config,
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
      syncService: syncService,
      checkbox: checkbox,
      checkboxText: checkboxText,
      relationKey: relationKey,
      stringValue: stringValue,
      stringListValue: stringListValue,
      boolValue: boolValue,
      dateValue: dateValue,
      fileRelationPath: fileRelationPath,
      fileRelationBytes: fileRelationBytes,
      fileRelationFileName: fileRelationFileName,
      objectIdValue: objectIdValue,
      blockId: blockId,
      setText: setText,
      setChecked: setChecked,
      setStyle: setStyle,
      status: status,
      tagIds: tagIds,
      tagAdds: tagAdds,
      tagRemoves: tagRemoves,
      collectionAddId: collectionAddId,
      collectionRemoveId: collectionRemoveId,
      collectionMoveId: collectionMoveId,
      afterId: afterId,
    );
  }

  Future<ReadResult> read({String? objectId}) {
    return readCommand(_session.db, _session.config, objectId: objectId);
  }
}

bool matchesObjectMetaFilters(
  ObjectMeta meta, {
  String? typeFilter,
  String? whereFilter,
}) {
  if (typeFilter != null && !meta.types.contains(typeFilter)) {
    return false;
  }

  // Phase 38: D-12 behavior shift: `meta.details[key]` is the output of
  // `_valueToString(..., optIndex: optIndex)`, which resolves option IDs
  // to names. Users write `--where status=Done`, NOT
  // `--where status=opt-abc123`.
  if (whereFilter != null) {
    final eqIndex = whereFilter.indexOf('=');
    if (eqIndex <= 0) {
      return true;
    }
    final key = whereFilter.substring(0, eqIndex);
    final value = whereFilter.substring(eqIndex + 1);
    if (meta.details[key] != value) {
      return false;
    }
  }

  return true;
}

/// Decode an object's change tree to extract name, type, and details metadata.
///
/// Returns null for system objects, bundled objects (ot-/rel- prefixes), and
/// objects that cannot be decrypted.
Future<ObjectMeta?> _extractObjectMeta(
  ManytypeDatabase db,
  StoredObject obj,
  Uint8List spaceKey, {
  Map<String, ResolvedOption>? optIndex,
  List<Change>? cachedChanges,
}) async {
  final changes = cachedChanges ?? await db.getChangesForObject(obj.id);
  if (changes.isEmpty) return null;

  // Check for system object via root change.
  try {
    final rawTreeChange = RawTreeChange.fromBuffer(changes.first.rawBytes);
    if (rawTreeChange.payload.isNotEmpty) {
      final rootChange = RootChange.fromBuffer(rawTreeChange.payload);
      if (rootChange.changeType == 'anytype.space' ||
          rootChange.changeType == 'any-sync.space') {
        return null;
      }
    }
  } catch (_) {
    // Not parseable as root change -- continue.
  }

  // Skip bundled objects.
  if (obj.id.startsWith('ot-') || obj.id.startsWith('rel-')) {
    return null;
  }

  // Derive per-object tree key.
  final treeKey = await deriveTreeKey(spaceKey, obj.id);

  // Walk changes to accumulate metadata.
  final objectTypes = <String>[];
  String? name;
  final details = <String, String>{};
  var isCollection = false;
  Block_Content_Dataview? collectionDataview;
  final collections = <String, Value>{};

  for (var i = 0; i < changes.length; i++) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(changes[i].rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;

      // Try as TreeChange (non-root changes).
      TreeChange treeChange;
      try {
        treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
      } catch (_) {
        // Root change or unparseable -- skip.
        continue;
      }
      if (treeChange.changesData.isEmpty) continue;

      // Decrypt and decompress.
      var data = Uint8List.fromList(treeChange.changesData);
      if (treeChange.readKeyId.isNotEmpty) {
        data = await aesGcmDecrypt(treeKey, data);
      }
      if (treeChange.dataType == '1/s') {
        data = _snappy.decompress(data);
      }

      final change = changes_proto.Change.fromBuffer(data);

      // Extract from snapshot.
      if (change.hasSnapshot()) {
        final snapData = change.snapshot.data;
        if (snapData.objectTypes.isNotEmpty) {
          objectTypes
            ..clear()
            ..addAll(snapData.objectTypes);
        }
        collectionDataview = _findCollectionDataview(snapData.blocks);
        isCollection = collectionDataview != null;
        collections
          ..clear()
          ..addEntries(snapData.collections.fields.entries.map(
            (entry) => MapEntry(entry.key, entry.value.deepCopy()),
          ));
        if (snapData.hasDetails()) {
          for (final entry in snapData.details.fields.entries) {
            details[entry.key] =
                _valueToString(entry.value, optIndex: optIndex);
          }
          if (snapData.details.fields.containsKey('name')) {
            name = snapData.details.fields['name']!.stringValue;
          }
        }
      }

      // Process incremental content changes.
      for (final content in change.content) {
        if (content.hasDetailsSet()) {
          final key = content.detailsSet.key;
          final val =
              _valueToString(content.detailsSet.value, optIndex: optIndex);
          details[key] = val;
          if (key == 'name') {
            name = content.detailsSet.value.hasStringValue()
                ? content.detailsSet.value.stringValue
                : val;
          }
        }
        if (content.hasObjectTypeAdd()) {
          final typeKey = content.objectTypeAdd.key.isNotEmpty
              ? content.objectTypeAdd.key
              : content.objectTypeAdd.url;
          if (typeKey.isNotEmpty && !objectTypes.contains(typeKey)) {
            objectTypes.add(typeKey);
          }
        }
        if (content.hasObjectTypeRemove()) {
          final typeKey = content.objectTypeRemove.key.isNotEmpty
              ? content.objectTypeRemove.key
              : content.objectTypeRemove.url;
          objectTypes.remove(typeKey);
        }
        if (content.hasBlockCreate()) {
          for (final block in content.blockCreate.blocks) {
            if (!block.hasDataview() || !block.dataview.isCollection) {
              continue;
            }
            isCollection = true;
            collectionDataview ??= block.dataview.deepCopy();
            if (collectionDataview.views.isEmpty &&
                block.dataview.views.isNotEmpty) {
              collectionDataview = block.dataview.deepCopy();
            }
          }
        }
        if (content.hasStoreKeySet()) {
          final key = _topLevelCollectionKey(content.storeKeySet.path);
          if (key != null) {
            collections[key] = content.storeKeySet.value.deepCopy();
          }
        }
        if (content.hasStoreKeyUnset()) {
          final key = _topLevelCollectionKey(content.storeKeyUnset.path);
          if (key != null) {
            collections.remove(key);
          }
        }
        if (content.hasStoreSliceUpdate()) {
          _applyCollectionStoreSliceUpdate(
              collections, content.storeSliceUpdate);
        }
      }
    } catch (_) {
      // Encrypted or corrupt change -- skip silently.
      continue;
    }
  }

  return ObjectMeta(
    id: obj.id,
    types: List<String>.from(objectTypes),
    name: name,
    details: details,
    isArchived: details['isArchived'] == 'true',
    isCollection: isCollection,
    collectionMemberCount:
        _collectionMemberCount(collections, collectionDataview),
  );
}

/// Convert a protobuf Value to a string for display and --where matching.
///
/// When [optIndex] is provided, a stringValue that matches a known option
/// ID is resolved to the option name (status-relation case). A listValue
/// whose entries are option IDs is resolved to a comma-joined list of
/// names (tag-relation case, Phase 38: closes RESEARCH Pitfall 1 where
/// tag relations previously fell through to a raw protobuf debug string).
/// Orphaned / not-yet-synced option IDs render as `<unknown:xxxxxxxx>`
/// per Phase 38 D-13.
///
/// Non-option string values and non-option list entries are unaffected:
/// they fall through to their existing serialization so Phase 37 behavior
/// is preserved when no STRelationOption objects exist in the space.
String _valueToString(Value val, {Map<String, ResolvedOption>? optIndex}) {
  if (val.hasStringValue()) {
    final s = val.stringValue;
    // Status-relation resolution: if a status value's string happens to
    // be an option ID in the index, resolve to name. Harmless for
    // non-option strings (they aren't in the index and fall through).
    if (optIndex != null && optIndex.containsKey(s)) {
      final opt = optIndex[s]!;
      return opt.isOrphaned ? '<unknown:${_truncate8(s)}>' : opt.name!;
    }
    return s;
  }
  if (val.hasBoolValue()) return val.boolValue.toString();
  if (val.hasNumberValue()) return val.numberValue.toString();
  if (val.hasListValue()) {
    // Phase 38: RESEARCH Pitfall 1 fix: tag relations (list_value of
    // stringValues) used to fall through to `.toString()` and emit a raw
    // protobuf debug string. Now they join resolved names with ", ".
    return val.listValue.values.map((v) {
      if (!v.hasStringValue()) return v.toString();
      final id = v.stringValue;
      if (optIndex == null) return id;
      final opt = optIndex[id];
      if (opt == null || opt.isOrphaned) {
        return '<unknown:${_truncate8(id)}>';
      }
      return opt.name!;
    }).join(', ');
  }
  return val.toString();
}

String _truncate8(String s) => s.length <= 8 ? s : s.substring(0, 8);

Block_Content_Dataview? _findCollectionDataview(List<Block> blocks) {
  for (final block in blocks) {
    if (block.hasDataview() && block.dataview.isCollection) {
      return block.dataview;
    }
  }
  return null;
}

String? _topLevelCollectionKey(List<String> path) {
  if (path.length != 1) {
    return null;
  }
  return path.first;
}

int _collectionMemberCount(
  Map<String, Value> collections,
  Block_Content_Dataview? dataview,
) {
  if (dataview == null) {
    return 0;
  }
  final storeKey = resolveCollectionStoreKeyFromValues(dataview, collections);
  return _readCollectionStringList(collections[storeKey]).length;
}

void _applyCollectionStoreSliceUpdate(
  Map<String, Value> collections,
  changes_proto.Change_StoreSliceUpdate update,
) {
  final current = _readCollectionStringList(collections[update.key]);
  switch (update.whichOperation()) {
    case changes_proto.Change_StoreSliceUpdate_Operation.add:
      _insertCollectionIds(current, update.add.afterId, update.add.ids);
      break;
    case changes_proto.Change_StoreSliceUpdate_Operation.remove:
      current.removeWhere(update.remove.ids.contains);
      break;
    case changes_proto.Change_StoreSliceUpdate_Operation.move:
      current.removeWhere(update.move.ids.contains);
      _insertCollectionIds(current, update.move.afterId, update.move.ids);
      break;
    case changes_proto.Change_StoreSliceUpdate_Operation.notSet:
      break;
  }
  collections[update.key] = Value(
    listValue: ListValue(
      values: current.map((value) => Value(stringValue: value)).toList(),
    ),
  );
}

List<String> _readCollectionStringList(Value? value) {
  if (value == null || !value.hasListValue()) {
    return <String>[];
  }
  return value.listValue.values
      .where((item) => item.hasStringValue())
      .map((item) => item.stringValue)
      .toList();
}

void _insertCollectionIds(
  List<String> current,
  String afterId,
  Iterable<String> ids,
) {
  final values = ids.toList();
  if (values.isEmpty) {
    return;
  }

  if (afterId.isEmpty) {
    current.insertAll(0, values);
    return;
  }

  final index = current.indexOf(afterId);
  if (index < 0) {
    current.addAll(values);
    return;
  }

  current.insertAll(index + 1, values);
}

