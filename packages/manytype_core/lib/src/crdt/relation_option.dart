import 'dart:typed_data';

import 'package:manytype_protocol/manytype_protocol.dart' show RawTreeChange, RootChange;
import 'package:manytype_protocol/models.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

import 'snapshot_details.dart';

/// Official Anytype relation-option color palette.
///
/// Source: `anyproto/anytype-kotlin` `core-models/.../ThemeColor.kt` enum
/// (verified 2026-04-12 via Phase 38 research Q1). 11 values total,
/// including the `default` sentinel for "no explicit color".
///
/// Note: the Anytype web custom-CSS docs include `green` as a hue variable,
/// but `green` is NOT present in the Kotlin `ThemeColor` enum: treat as
/// out-of-palette for Phase 38 MVP. Phase 42 bidirectional verification
/// against the official client will confirm this constraint.
const Set<String> optionColorPalette = <String>{
  'default',
  'grey',
  'yellow',
  'orange',
  'red',
  'pink',
  'purple',
  'blue',
  'ice',
  'teal',
  'lime',
};

/// Build the google.protobuf.Struct that forms the `details` payload of an
/// STRelationOption SmartBlock snapshot (SmartBlockType 529 / 0x211).
///
/// Throws [ArgumentError] if [color] is not in [optionColorPalette].
///
/// Detail-key rationale (Phase 38 RESEARCH Q2):
///  - `name` + `text`: both point at the display string; `list.dart` already
///    reads `name` for its per-object index so option names surface without
///    extra wiring, AND upstream reads `text` (Relation.Option proto field 2).
///  - `relationOptionColor` + `color`: defensive dual-write per Pitfall 4.
///    Upstream details use `relationOptionColor`, but Relation.Option proto
///    field 3 is `color`, so both are written to maximize compatibility.
///  - `relationKey`: binds the option to its parent STRelation
///    (Relation.Option proto field 5).
///  - `layout = 13.0`: `ObjectType_Layout.relationOption`; required for
///    official-client rendering (Pitfall 5).
Struct buildRelationOptionDetails({
  required String name,
  required String color,
  required String relationKey,
}) {
  if (!optionColorPalette.contains(color)) {
    throw ArgumentError.value(
      color,
      'color',
      'Not in palette. Accepted: ${optionColorPalette.join(', ')}',
    );
  }
  return Struct()
    ..fields['name'] = Value(stringValue: name)
    ..fields['text'] = Value(stringValue: name)
    ..fields['relationOptionColor'] = Value(stringValue: color)
    ..fields['color'] = Value(stringValue: color)
    ..fields['relationKey'] = Value(stringValue: relationKey)
    ..fields['layout'] = Value(numberValue: 13.0);
}

/// Append a [Relation_Option] entry to a parent STRelation's `selectDict`
/// details [Value]. Accepts a `null` or unset-listValue [current] and
/// returns a fresh `Value(listValue:)` in that case. Preserves existing
/// entry order (new option appended at the end).
///
/// Each `selectDict` entry is stored as `Value(structValue: Struct)`
/// carrying `id` / `text` / `color` / `relationKey`: these map to
/// `Relation.Option` proto fields 1, 2, 3, and 5 respectively.
Value appendOptionToSelectDict(Value? current, Relation_Option newOption) {
  final values = <Value>[];
  if (current != null && current.hasListValue()) {
    values.addAll(current.listValue.values);
  }
  final optStruct = Struct()
    ..fields['id'] = Value(stringValue: newOption.id)
    ..fields['text'] = Value(stringValue: newOption.text)
    ..fields['color'] = Value(stringValue: newOption.color)
    ..fields['relationKey'] = Value(stringValue: newOption.relationKey);
  values.add(Value(structValue: optStruct));
  return Value(listValue: ListValue(values: values));
}

/// Result of resolving an STRelationOption ID against the local store.
///
/// Used by `read.dart` / `list.dart` to render option IDs as
/// `name (color)` or `<unknown:opt-xxxx>` when the option has not yet
/// synced (D-13).
class ResolvedOption {
  final String id;
  final String? name;
  final String? color;
  final String? relationKey;

  const ResolvedOption({
    required this.id,
    required this.name,
    required this.color,
    required this.relationKey,
  });

  /// True when no display name is available locally: caller should render
  /// the orphaned placeholder `<unknown:...>` per Phase 38 D-13.
  bool get isOrphaned => name == null;
}

/// Numeric `SmartBlockType.STRelationOption` value (0x211 / 529).
///
/// Lifted from `models.pbenum.dart` so manytype_core callers can filter for
/// option objects without importing the full proto enum just for one
/// constant. Verified against `SmartBlockType.STRelationOption`: Phase 38
/// research Q2.
const int smartBlockTypeRelationOption = 529;

/// Minimal per-object input to [loadLocalOptionIndex]. The CLI layer
/// assembles this list by querying Drift for all non-deleted objects in
/// a space and lifting each object's raw tree-change rows into
/// [rawTreeChanges]. This keeps `manytype_core` free of any Drift /
/// `ManytypeDatabase` dependency.
class OptionIndexInput {
  final String objectId;
  final List<Uint8List> rawTreeChanges;
  final Uint8List treeKey;

  const OptionIndexInput({
    required this.objectId,
    required this.rawTreeChanges,
    required this.treeKey,
  });
}

/// Scan a list of space objects, filter those whose root change's
/// `smart_block_type` varint equals [smartBlockTypeRelationOption] (529),
/// replay their details, and return a map from option ID -> [ResolvedOption].
///
/// Does NOT bump the Drift schema (Phase 38 RESEARCH Q6). The cost of
/// the per-object root-change varint decode is O(objects-in-space), which
/// is already the dominant cost of `list.dart`'s existing per-object walk.
///
/// Call once per `read` / `list` invocation, cache the result in-scope,
/// then look up `map[optionId]` per option ID encountered in a relation
/// value. A lookup miss indicates an orphaned ID (not yet synced) and
/// callers should render `<unknown:${id.substring(0, 8)}>` per D-13.
///
/// A [ResolvedOption] is emitted for every object whose root change's
/// smart_block_type matches 529, even if its details turn out to be
/// malformed or missing `name`/`text`: in that case
/// [ResolvedOption.isOrphaned] will be `true`, giving callers an
/// explicit signal about partially-synced option objects.
Future<Map<String, ResolvedOption>> loadLocalOptionIndex(
  List<OptionIndexInput> inputs,
) async {
  final result = <String, ResolvedOption>{};
  for (final input in inputs) {
    final sbType = extractRootSmartBlockType(input.rawTreeChanges);
    if (sbType != smartBlockTypeRelationOption) continue;

    Map<String, Value> details;
    try {
      details = await replayObjectDetails(
        rawTreeChanges: input.rawTreeChanges,
        treeKey: input.treeKey,
      );
    } catch (_) {
      details = const <String, Value>{};
    }

    final name =
        details['name']?.stringValue ?? details['text']?.stringValue;
    final color = details['relationOptionColor']?.stringValue ??
        details['color']?.stringValue;
    final relationKey = details['relationKey']?.stringValue;

    result[input.objectId] = ResolvedOption(
      id: input.objectId,
      name: (name != null && name.isNotEmpty) ? name : null,
      color: (color != null && color.isNotEmpty) ? color : null,
      relationKey:
          (relationKey != null && relationKey.isNotEmpty) ? relationKey : null,
    );
  }
  return result;
}

/// Extract the `SmartBlockType` varint from the FIRST raw tree change in
/// the sequence, which must be a [RootChange] envelope. Returns `-1` if
/// the input is empty, the payload cannot be parsed, or the
/// `changePayload` field does not begin with tag 0x08 (field 1, wire
/// type 0 = varint).
///
/// Mirrors `packages/manytype_cli/lib/src/commands/read.dart:541-557`
/// (`_extractSmartBlockType` + `_decodeVarint`) verbatim: moved into
/// `manytype_core` so Phase 38's [loadLocalOptionIndex] can scan root
/// changes without depending on the CLI.
///
/// The `changePayload` is a protobuf message whose field 1 (tag 0x08) is
/// the `SmartBlockType` enum value encoded as a varint. STRelationOption
/// is 529 / 0x211 which is a MULTI-byte varint (`0x91 0x04`), so the
/// decode loop must handle more than one continuation byte.
int extractRootSmartBlockType(List<Uint8List> rawTreeChanges) {
  if (rawTreeChanges.isEmpty) return -1;
  try {
    final rawTc = RawTreeChange.fromBuffer(rawTreeChanges.first);
    if (rawTc.payload.isEmpty) return -1;
    final rootChange = RootChange.fromBuffer(rawTc.payload);
    if (rootChange.changePayload.isEmpty) return -1;
    final bytes = rootChange.changePayload;
    if (bytes[0] != 0x08) return -1;
    return _decodeVarint(bytes.sublist(1));
  } catch (_) {
    return -1;
  }
}

/// Decode an unsigned protobuf varint from the head of [bytes]. Handles
/// multi-byte values (e.g. `SmartBlockType.STType = 528`, `STRelation =
/// 521`, `STRelationOption = 529`) which all exceed the single-byte
/// range.
int _decodeVarint(List<int> bytes) {
  int result = 0;
  int shift = 0;
  for (final b in bytes) {
    result |= (b & 0x7F) << shift;
    shift += 7;
    if (b < 0x80) break;
  }
  return result;
}
