import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/models.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, RootChange;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    show Value;

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
  Identity? identityOverride,
}) async {
  // Derive identity and space key once.
  final identity =
      identityOverride ?? await Identity.fromMnemonic(config.mnemonic);
  final accountKeyPair = identity.accountKeyPair;
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

  // Replay the change tree into the object's current state.
  final snapshot = await replayObjectSnapshot(
    rawTreeChanges:
        changes.map((change) => Uint8List.fromList(change.rawBytes)).toList(),
    treeKey: treeKey,
  );
  final details = <String, String>{
    for (final entry in snapshot.details.fields.entries)
      entry.key: _valueToString(entry.value, optIndex: optIndex),
  };
  final nameValue = snapshot.details.fields['name'];
  final collectionDataview = _findCollectionDataview(snapshot.blocks);

  return ObjectMeta(
    id: obj.id,
    types: List<String>.from(snapshot.objectTypes),
    name: nameValue == null || !nameValue.hasStringValue()
        ? details['name']
        : nameValue.stringValue,
    details: details,
    isArchived: details['isArchived'] == 'true',
    isCollection: collectionDataview != null,
    collectionMemberCount:
        _collectionMemberCount(snapshot.collections.fields, collectionDataview),
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

List<String> _readCollectionStringList(Value? value) {
  if (value == null || !value.hasListValue()) {
    return <String>[];
  }
  return value.listValue.values
      .where((item) => item.hasStringValue())
      .map((item) => item.stringValue)
      .toList();
}
