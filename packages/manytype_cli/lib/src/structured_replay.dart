import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/models.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    show Value;

import 'config.dart';
import 'identity.dart';
import 'store/database.dart';

/// Detail keys emitted as relation values by [replayObjectRelations] rather
/// than as ordinary relation values, even though they technically live in
/// the same `details` map -- mirrors `read.dart`'s own
/// `renderedRelationKeys` exclusions for `targetObjectType`/`sourceObject`,
/// which are structural (type-picker/template provenance), not user-facing
/// relation values an editor should offer to overwrite.
const _structuralRelationKeys = <String>{'targetObjectType', 'sourceObject'};

/// Structural block IDs from `createMinimalPageSnapshotBase` that every page
/// object carries as scaffolding with no text content of its own. `title`
/// is deliberately NOT included here even though `read.dart`'s line-based
/// report skips it too: `title` holds the object's actual display name as
/// an editable text block, and a structured caller (unlike a human skimming
/// the CLI report) wants to bind an editor to it.
const structuralBlockIds = <String>{'header', 'featuredRelations'};

/// One user-visible content block, replayed to its current state.
///
/// Stable across re-reads: [id] is the same CRDT block ID `edit --block-id`
/// targets, so a UI can bind an editable control to a block once and keep
/// using that binding across rebuilds/replays.
class ReplayedBlockView {
  const ReplayedBlockView({
    required this.id,
    required this.style,
    required this.text,
    this.checked,
  });

  final String id;
  final Block_Content_Text_Style style;
  final String text;

  /// Only meaningful when [style] is [Block_Content_Text_Style.Checkbox].
  final bool? checked;
}

/// Structured replay of one object: the object's kind plus its ordered,
/// user-visible text/checkbox/quote/toggle/etc. blocks.
///
/// This is the same replay `readCommand`'s text report is derived from,
/// exposed as data instead of pre-rendered lines so a UI can bind editable
/// controls per block (text field, checkbox, toggle expand/collapse) rather
/// than parsing rendered text back apart.
class ReplayedObjectBlocks {
  const ReplayedObjectBlocks({
    required this.objectId,
    required this.smartBlockType,
    required this.blocks,
  });

  final String objectId;
  final int smartBlockType;
  final List<ReplayedBlockView> blocks;
}

/// Replay [objectId]'s current block state from local changes.
///
/// Returns `null` when the object has no local changes (not found) or its
/// root smart block type can't be parsed. Throws only on unexpected/decrypt
/// errors, matching `readCommand`'s own error surface for this object.
Future<ReplayedObjectBlocks?> replayObjectBlocks(
  ManytypeDatabase db,
  CliConfig config,
  String objectId,
) async {
  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    return null;
  }

  final identity = await Identity.fromMnemonic(config.mnemonic);
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  final treeKey = await deriveTreeKey(spaceKey, objectId);

  final rawTreeChanges =
      changes.map((change) => Uint8List.fromList(change.rawBytes)).toList();
  final replayed = await replayObjectState(
    rawTreeChanges: rawTreeChanges,
    treeKey: treeKey,
  );

  final blocks = <ReplayedBlockView>[
    for (final block in replayed.snapshot.blocks)
      if (!structuralBlockIds.contains(block.id) && block.hasText())
        ReplayedBlockView(
          id: block.id,
          style: block.text.style,
          text: block.text.text,
          checked: block.text.style == Block_Content_Text_Style.Checkbox
              ? block.text.checked
              : null,
        ),
  ];

  return ReplayedObjectBlocks(
    objectId: objectId,
    smartBlockType: replayed.smartBlockType,
    blocks: blocks,
  );
}

/// One user-facing relation value, replayed to its current state and
/// resolved to the typed shape [editRelationOffline] can write back --
/// exactly one of the typed fields is non-null, keyed off [format].
///
/// Status/tag values are resolved from raw STRelationOption IDs to their
/// display name (+ color for status) via the local option index, mirroring
/// `read.dart`'s `_formatOptionRelationValue`; an ID with no local match
/// still surfaces (as `optionId` with a null `name`) rather than being
/// dropped, so a caller can render an "unsynced option" placeholder instead
/// of silently losing the relation.
class ReplayedRelationView {
  const ReplayedRelationView({
    required this.key,
    required this.format,
    this.stringValue,
    this.stringListValue,
    this.boolValue,
    this.dateValue,
    this.objectIdValue,
    this.statusOptionId,
    this.statusName,
    this.statusColor,
    this.tagOptions = const [],
  });

  final String key;
  final RelationFormat format;

  /// Populated for [RelationFormat.longtext]/[RelationFormat.shorttext]/
  /// [RelationFormat.url]/[RelationFormat.email]/[RelationFormat.phone]/
  /// [RelationFormat.emoji] and any other single-string format without its
  /// own dedicated field below.
  final String? stringValue;

  /// Populated only when [format] has no more specific handling above and
  /// the raw value is a list of strings (a defensive fallback, not
  /// currently reachable by any format `editRelationOffline` writes).
  final List<String>? stringListValue;

  final bool? boolValue;

  /// Unix seconds, matching [format] == [RelationFormat.date] and the
  /// `dateValue` param `editRelationOffline` accepts.
  final int? dateValue;

  final String? objectIdValue;

  /// Populated for [format] == [RelationFormat.status]. [statusName]/
  /// [statusColor] are null when [statusOptionId] hasn't synced locally yet.
  final String? statusOptionId;
  final String? statusName;
  final String? statusColor;

  /// Populated for [format] == [RelationFormat.tag]: one entry per selected
  /// option, in stored order. An entry's `name`/`color` are null when that
  /// option hasn't synced locally yet.
  final List<ReplayedTagOption> tagOptions;
}

/// One resolved (or unresolved) tag-relation option value.
class ReplayedTagOption {
  const ReplayedTagOption({
    required this.optionId,
    this.name,
    this.color,
  });

  final String optionId;
  final String? name;
  final String? color;
}

/// Structured replay of one object's relation values.
class ReplayedObjectRelations {
  const ReplayedObjectRelations({
    required this.objectId,
    required this.relations,
  });

  final String objectId;
  final List<ReplayedRelationView> relations;
}

/// Replay [objectId]'s current relation values from local changes, resolving
/// relation value formats via local STRelation definitions and status/tag
/// option IDs to display names via the local STRelationOption index.
///
/// Returns `null` when the object has no local changes (not found).
/// Scoped to the same relation-value kinds [editRelationOffline] can write:
/// string, string-list, bool, date (unix seconds), object-ref, and status/
/// tag (via the option index). `targetObjectType`/`sourceObject` are
/// excluded (structural, see [_structuralRelationKeys]), matching
/// `read.dart`'s own dedicated handling of those two keys.
Future<ReplayedObjectRelations?> replayObjectRelations(
  ManytypeDatabase db,
  CliConfig config,
  String objectId,
) async {
  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    return null;
  }

  final identity = await Identity.fromMnemonic(config.mnemonic);
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  final treeKey = await deriveTreeKey(spaceKey, objectId);

  final rawTreeChanges =
      changes.map((change) => Uint8List.fromList(change.rawBytes)).toList();
  final replayed = await replayObjectState(
    rawTreeChanges: rawTreeChanges,
    treeKey: treeKey,
  );

  var optIndex = const <String, ResolvedOption>{};
  var relationFormatIndex = const <String, RelationFormat>{};
  try {
    final spaceObjects = await db.getNonDeletedObjectsBySpace(identity.spaceId);
    final optionInputs = <OptionIndexInput>[];
    final relationFormats = <String, RelationFormat>{};
    for (final obj in spaceObjects) {
      final rawRows = await db.getChangesForObject(obj.id);
      final rawTreeChanges =
          rawRows.map((r) => Uint8List.fromList(r.rawBytes)).toList();
      final objTreeKey = await deriveTreeKey(spaceKey, obj.id);
      optionInputs.add(OptionIndexInput(
        objectId: obj.id,
        rawTreeChanges: rawTreeChanges,
        treeKey: objTreeKey,
      ));
      if (extractRootSmartBlockType(rawTreeChanges) !=
          SmartBlockType.STRelation.value) {
        continue;
      }
      try {
        final details = await replayObjectDetails(
          rawTreeChanges: rawTreeChanges,
          treeKey: objTreeKey,
        );
        final format = _relationFormatFromValue(details['relationFormat']);
        if (format == null) {
          continue;
        }
        _indexRelationFormat(
          relationFormats,
          details['uniqueKey']?.stringValue,
          format,
        );
        _indexRelationFormat(
          relationFormats,
          details['relationKey']?.stringValue,
          format,
        );
      } catch (_) {
        // Ignore malformed/incomplete relation objects; value-shape guessing
        // below still gives callers a best-effort editable value.
      }
    }
    optIndex = await loadLocalOptionIndex(optionInputs);
    relationFormatIndex = Map.unmodifiable(relationFormats);
  } catch (_) {
    // Non-fatal: status/tag values fall back to unresolved option IDs, and
    // relation formats fall back to snapshot relationLinks/value guessing.
    optIndex = const <String, ResolvedOption>{};
    relationFormatIndex = const <String, RelationFormat>{};
  }

  final formatByKey = <String, RelationFormat>{
    ...relationFormatIndex,
    for (final link in replayed.snapshot.relationLinks) link.key: link.format,
  };
  final details = replayed.snapshot.details.fields;

  final relations = <ReplayedRelationView>[
    for (final entry in details.entries)
      if (!_structuralRelationKeys.contains(entry.key))
        _buildRelationView(
          entry.key,
          entry.value,
          formatByKey[entry.key],
          optIndex,
        ),
  ];

  return ReplayedObjectRelations(objectId: objectId, relations: relations);
}

RelationFormat? _relationFormatFromValue(Value? value) {
  if (value == null) {
    return null;
  }
  final intValue = value.hasNumberValue()
      ? value.numberValue.round()
      : value.hasStringValue()
          ? double.tryParse(value.stringValue)?.round()
          : null;
  return intValue == null ? null : RelationFormat.valueOf(intValue);
}

void _indexRelationFormat(
  Map<String, RelationFormat> index,
  String? key,
  RelationFormat format,
) {
  final normalized = key?.trim() ?? '';
  if (normalized.isEmpty) {
    return;
  }
  index[normalized] = format;
  if (normalized.startsWith('rel-') && normalized.length > 4) {
    index.putIfAbsent(normalized.substring(4), () => format);
  } else {
    index.putIfAbsent('rel-$normalized', () => format);
  }
}

ReplayedRelationView _buildRelationView(
  String key,
  Value value,
  RelationFormat? knownFormat,
  Map<String, ResolvedOption> optIndex,
) {
  final format = knownFormat ?? _guessFormat(value, optIndex);

  switch (format) {
    case RelationFormat.checkbox:
      if (value.hasBoolValue()) {
        return ReplayedRelationView(
          key: key,
          format: format,
          boolValue: value.boolValue,
        );
      }
    case RelationFormat.date:
      if (value.hasNumberValue()) {
        return ReplayedRelationView(
          key: key,
          format: format,
          dateValue: value.numberValue.round(),
        );
      }
    case RelationFormat.status:
      if (value.hasStringValue()) {
        final id = value.stringValue;
        final opt = optIndex[id];
        return ReplayedRelationView(
          key: key,
          format: format,
          statusOptionId: id,
          statusName: (opt == null || opt.isOrphaned) ? null : opt.name,
          statusColor: (opt == null || opt.isOrphaned) ? null : opt.color,
        );
      }
    case RelationFormat.tag:
      if (value.hasListValue()) {
        return ReplayedRelationView(
          key: key,
          format: format,
          tagOptions: [
            for (final v in value.listValue.values)
              if (v.hasStringValue())
                ReplayedTagOption(
                  optionId: v.stringValue,
                  name: optIndex[v.stringValue]?.isOrphaned == false
                      ? optIndex[v.stringValue]!.name
                      : null,
                  color: optIndex[v.stringValue]?.isOrphaned == false
                      ? optIndex[v.stringValue]!.color
                      : null,
                ),
          ],
        );
      }
    case RelationFormat.object:
      if (value.hasStringValue()) {
        return ReplayedRelationView(
          key: key,
          format: format,
          objectIdValue: value.stringValue,
        );
      }
    default:
      break;
  }

  if (value.hasStringValue()) {
    return ReplayedRelationView(
      key: key,
      format: format,
      stringValue: value.stringValue,
    );
  }
  if (value.hasListValue()) {
    final strings = [
      for (final v in value.listValue.values)
        if (v.hasStringValue()) v.stringValue,
    ];
    if (strings.length == value.listValue.values.length) {
      return ReplayedRelationView(
        key: key,
        format: format,
        stringListValue: strings,
      );
    }
  }
  if (value.hasBoolValue()) {
    return ReplayedRelationView(
      key: key,
      format: format,
      boolValue: value.boolValue,
    );
  }
  return ReplayedRelationView(
    key: key,
    format: format,
    stringValue: value.toString(),
  );
}

/// Best-effort format guess for a detail with no matching `relationLinks` or
/// local STRelation definition entry. Mirrors `read.dart`'s own value-based
/// option-ref detection fallback for status/tag; adds number-value detection
/// for dates, which `read.dart`'s own fallback doesn't need since it renders
/// numbers generically either way.
RelationFormat _guessFormat(Value value, Map<String, ResolvedOption> optIndex) {
  if (optIndex.isNotEmpty) {
    if (value.hasStringValue() && optIndex.containsKey(value.stringValue)) {
      return RelationFormat.status;
    }
    if (value.hasListValue()) {
      for (final v in value.listValue.values) {
        if (v.hasStringValue() && optIndex.containsKey(v.stringValue)) {
          return RelationFormat.tag;
        }
      }
    }
  }
  if (value.hasBoolValue()) return RelationFormat.checkbox;
  if (value.hasNumberValue()) return RelationFormat.date;
  return RelationFormat.longtext;
}
