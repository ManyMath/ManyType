import 'package:manytype_protocol/models.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart';

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

// TODO(Task 3): loadLocalOptionIndex — added after snapshot_details.dart
// exists. Scans space objects, filters by smart_block_type == 529, and
// returns a Map<String, ResolvedOption> keyed by option ID.
