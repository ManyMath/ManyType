import 'dart:typed_data';

import 'package:libcompress/libcompress.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, RootChange, TreeChange;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    show Value;

import '../config.dart';
import '../identity.dart';
import '../store/database.dart';
import '../sync_service.dart';

final _snappy = SnappyCodec();

/// Lightweight metadata extracted from an object's change tree.
class ObjectMeta {
  final String id;
  final String? type;
  final String? name;
  final Map<String, String> details;

  ObjectMeta({
    required this.id,
    this.type,
    this.name,
    this.details = const {},
  });

  String get displayType => type ?? '<unknown>';
  String get displayName => name ?? '<unnamed>';
}

/// List objects from local store with optional type and field filters.
///
/// Syncs first, then queries the local Drift database for non-deleted objects,
/// decodes metadata from each object's change tree, applies filters, and prints
/// an aligned three-column table.
Future<void> listCommand(
  ManytypeDatabase db,
  CliConfig config, {
  required String networkConfigPath,
  String? typeFilter,
  String? whereFilter,
}) async {
  // Derive identity and space key once.
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final accountKeyPair = await ed25519KeyPairFromSeed(identity.accountSeed);
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);

  // Sync before listing.
  final syncService = SyncService();
  await syncService.sync(db, config, networkConfigPath: networkConfigPath);

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
      rawTreeChanges: rawRows.map((r) => Uint8List.fromList(r.rawBytes)).toList(),
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
    if (meta != null) {
      metas.add(meta);
    }
  }

  // Apply --type filter.
  var results = metas;
  if (typeFilter != null) {
    results = results.where((m) => m.type == typeFilter).toList();
  }

  // Apply --where key=value filter.
  //
  // Phase 38 — D-12 behavior shift: `m.details[key]` is the output of
  // `_valueToString(..., optIndex: optIndex)`, which now resolves option
  // IDs to names. Users write `--where status="Done"`, NOT
  // `--where status="opt-abc123"`. The matcher code itself does not
  // change — the resolution happens upstream inside `_extractObjectMeta`.
  if (whereFilter != null) {
    final eqIndex = whereFilter.indexOf('=');
    if (eqIndex > 0) {
      final key = whereFilter.substring(0, eqIndex);
      final value = whereFilter.substring(eqIndex + 1);
      results = results.where((m) => m.details[key] == value).toList();
    }
  }

  _printObjectTable(results);
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
        if (snapData.hasDetails()) {
          for (final entry in snapData.details.fields.entries) {
            details[entry.key] = _valueToString(entry.value, optIndex: optIndex);
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
          final val = _valueToString(content.detailsSet.value, optIndex: optIndex);
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
      }
    } catch (_) {
      // Encrypted or corrupt change -- skip silently.
      continue;
    }
  }

  return ObjectMeta(
    id: obj.id,
    type: objectTypes.isNotEmpty ? objectTypes.first : null,
    name: name,
    details: details,
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

/// Print an aligned three-column table of object metadata.
void _printObjectTable(List<ObjectMeta> metas) {
  if (metas.isEmpty) {
    print('No objects found.');
    return;
  }

  // Compute column widths.
  var idWidth = 'ID'.length;
  var typeWidth = 'TYPE'.length;
  for (final meta in metas) {
    if (meta.id.length > idWidth) idWidth = meta.id.length;
    if (meta.displayType.length > typeWidth) {
      typeWidth = meta.displayType.length;
    }
  }

  // Print header.
  print('${"ID".padRight(idWidth)}  ${"TYPE".padRight(typeWidth)}  NAME');

  // Print rows.
  for (final meta in metas) {
    print(
      '${meta.id.padRight(idWidth)}  '
      '${meta.displayType.padRight(typeWidth)}  '
      '${meta.displayName}',
    );
  }
}
