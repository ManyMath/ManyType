import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_protocol/models.dart' show Block_Content_Text_Style;

import 'session_provider.dart';

/// Objects in [spaceId] via the real `listCommand`, offline (no network
/// config passed, so no sync attempt). Phase 1 only ever passes the
/// personal space id: `listCommand` always lists the identity's own space,
/// but the family key keeps invalidation scoped per space for later
/// multi-space support.
final objectsProvider = FutureProvider.family<List<ObjectMeta>, String>((
  ref,
  spaceId,
) async {
  final session = await ref.watch(sessionProvider.future);
  if (session == null) {
    return const <ObjectMeta>[];
  }
  final metas = await listCommand(session.db, session.config);
  // Space initialization derives system roots (Home / Archive / Widgets /
  // Workspace dashboards) that surface from listCommand with no object
  // type and no name; hide them from the user-facing list.
  return metas
      .where((m) => m.types.isNotEmpty || m.name != null || m.isCollection)
      .toList();
});

/// Replayed detail view for one object: `readCommand`'s rendered report
/// lines (title, kind, decrypted block contents).
final objectDetailProvider = FutureProvider.family<ReadDetailResult?, String>((
  ref,
  objectId,
) async {
  final session = await ref.watch(sessionProvider.future);
  if (session == null) {
    return null;
  }
  final result = await readCommand(
    session.db,
    session.config,
    objectId: objectId,
  );
  return result.detail;
});

/// Structured, editable block replay for one object -- the data-shaped
/// counterpart to [objectDetailProvider]'s pre-rendered text report. Backs
/// `ObjectDetailView`'s per-block TextField/Checkbox/Toggle editor.
final objectBlocksProvider =
    FutureProvider.family<ReplayedObjectBlocks?, String>((
  ref,
  objectId,
) async {
  final session = await ref.watch(sessionProvider.future);
  if (session == null) {
    return null;
  }
  return replayObjectBlocks(session.db, session.config, objectId);
});

/// Existing STType objects in [spaceId], for a type-picker dropdown.
/// Filters `objectsProvider`'s already-fetched metas for the
/// `ot-objectType` marker `createCommand`'s `asType` branch adds -- no new
/// core call needed, `listCommand` already surfaces this via `types`.
final spaceTypesProvider = FutureProvider.family<List<ObjectMeta>, String>((
  ref,
  spaceId,
) async {
  final metas = await ref.watch(objectsProvider(spaceId).future);
  return metas.where((m) => m.types.contains('ot-objectType')).toList();
});

/// Existing STRelation objects in [spaceId], for a relation-key picker.
/// Same shape as [spaceTypesProvider]: filters `objectsProvider`'s
/// already-fetched metas for the `ot-relation` marker `createCommand`'s
/// `asRelation` branch adds -- confirmed via a real create+list round trip
/// that `listCommand` already surfaces both the marker and the relation's
/// own `relationFormat`/`uniqueKey` details with no new core call needed
/// (relation objects get a random object id, not an `ot-`/`rel-` prefix, so
/// they aren't caught by `_extractObjectMeta`'s bundled-object filter).
final spaceRelationsProvider = FutureProvider.family<List<ObjectMeta>, String>(
  (ref, spaceId) async {
    final metas = await ref.watch(objectsProvider(spaceId).future);
    return metas.where((m) => m.types.contains('ot-relation')).toList();
  },
);

/// Text-block styles `createCommand` can produce offline, plus `type`: an
/// STType object (`createCommand`'s `asType` flag) so a type-picker on
/// create has something to populate itself with -- without this, the
/// "assign an existing type" dropdown would only ever be reachable in
/// theory, with no in-app way to create the type it assigns. Same
/// reasoning for `relation`: an STRelation object (`asRelation`), so the
/// relation editor's relation-key picker has something to populate itself
/// with.
enum NewObjectKind {
  text,
  checkbox,
  numbered,
  toggle,
  quote,
  callout,
  type,
  relation,
}

extension NewObjectKindLabel on NewObjectKind {
  String get label => switch (this) {
    NewObjectKind.text => 'Text',
    NewObjectKind.checkbox => 'Checkbox',
    NewObjectKind.numbered => 'Numbered list',
    NewObjectKind.toggle => 'Toggle',
    NewObjectKind.quote => 'Quote',
    NewObjectKind.callout => 'Callout',
    NewObjectKind.type => 'Type',
    NewObjectKind.relation => 'Relation',
  };
}

/// Relation value formats `createCommand`'s `format` param understands for
/// `asRelation: true` (mirrors `create.dart`'s `_parseRelationFormat`, which
/// only accepts these lowercase names -- anything else silently falls back
/// to `longtext`).
enum NewRelationFormat { text, status, tag, date, checkbox }

extension NewRelationFormatLabel on NewRelationFormat {
  String get label => switch (this) {
    NewRelationFormat.text => 'Text',
    NewRelationFormat.status => 'Status',
    NewRelationFormat.tag => 'Tag',
    NewRelationFormat.date => 'Date',
    NewRelationFormat.checkbox => 'Checkbox',
  };

  String get wireName => switch (this) {
    NewRelationFormat.text => 'text',
    NewRelationFormat.status => 'status',
    NewRelationFormat.tag => 'tag',
    NewRelationFormat.date => 'date',
    NewRelationFormat.checkbox => 'checkbox',
  };
}

extension NewBlockKindLabel on NewBlockKind {
  String get label => switch (this) {
    NewBlockKind.text => 'Text',
    NewBlockKind.checkbox => 'Checkbox',
    NewBlockKind.numbered => 'Numbered list',
    NewBlockKind.toggle => 'Toggle',
    NewBlockKind.quote => 'Quote',
    NewBlockKind.callout => 'Callout',
  };
}

/// Object mutations. Create is fully offline (signed changes persisted to
/// the local Drift store); the list provider is invalidated afterwards so
/// the GUI re-queries.
class ObjectsController {
  ObjectsController(this._ref);

  final Ref _ref;

  /// Creates a text object (or, with `kind: NewObjectKind.type`/`.relation`,
  /// a new STType/STRelation named [text]) in the personal space and
  /// refreshes the list. Returns null when no session is open
  /// (pre-onboarding). [assignedType] optionally assigns an existing
  /// STType object's id to a non-type object, baked into the initial
  /// snapshot's `objectTypes` + `type` detail together (see
  /// `createCommand`'s `assignedType` param) -- there is no incremental
  /// retyping path for an object already created without one.
  /// [relationFormat] only applies when `kind == NewObjectKind.relation`;
  /// defaults to `NewRelationFormat.text` (matches `createCommand`'s own
  /// `format: null` default).
  Future<CreateResult?> create(
    String text, {
    NewObjectKind kind = NewObjectKind.text,
    String? assignedType,
    NewRelationFormat? relationFormat,
  }) async {
    final session = await _ref.read(sessionProvider.future);
    if (session == null) {
      return null;
    }
    final result = await createCommand(
      text,
      session.db,
      session.config,
      checkbox: kind == NewObjectKind.checkbox,
      numberedList: kind == NewObjectKind.numbered,
      toggle: kind == NewObjectKind.toggle,
      quote: kind == NewObjectKind.quote,
      callout: kind == NewObjectKind.callout,
      asType: kind == NewObjectKind.type,
      asRelation: kind == NewObjectKind.relation,
      name: kind == NewObjectKind.type || kind == NewObjectKind.relation
          ? text
          : null,
      format: kind == NewObjectKind.relation
          ? (relationFormat ?? NewRelationFormat.text).wireName
          : null,
      assignedType: assignedType,
    );
    _ref.invalidate(objectsProvider(result.spaceId));
    return result;
  }

  /// Mutates one block's text/checked/style in place via `editOffline` and
  /// refreshes both the structured and text-report detail views for
  /// [objectId]. Returns null when no session is open. Exactly one of
  /// [setText]/[setChecked]/[setStyle] should be passed per call, matching
  /// `editOffline`'s own contract.
  Future<EditOfflineResult?> editBlock(
    String objectId, {
    required String blockId,
    String? setText,
    bool? setChecked,
    Block_Content_Text_Style? setStyle,
  }) async {
    final session = await _ref.read(sessionProvider.future);
    if (session == null) {
      return null;
    }
    final result = await editOffline(
      objectId,
      session.db,
      session.config,
      blockId: blockId,
      setText: setText,
      setChecked: setChecked,
      setStyle: setStyle,
    );
    _ref.invalidate(objectBlocksProvider(objectId));
    _ref.invalidate(objectDetailProvider(objectId));
    return result;
  }

  /// Deletes [objectId] in [spaceId] and refreshes the list. Uses
  /// `deleteOffline` (not `deleteCommand`) -- `deleteCommand` brackets its
  /// local writes with two `SyncService.sync()` calls that require a live
  /// coordinator connection and throw when offline, the same network
  /// dependency already worked around for create/list/read. This only
  /// performs the local archive + delete-flag write; the corresponding
  /// `ObjectDelete` settings change reaches other devices/peers on the next
  /// successful `manytype sync`. Returns null when no session is open.
  Future<DeleteResult?> delete(String objectId, String spaceId) async {
    final session = await _ref.read(sessionProvider.future);
    if (session == null) {
      return null;
    }
    final result = await deleteOffline(objectId, session.db, session.config);
    _ref.invalidate(objectsProvider(spaceId));
    return result;
  }

  /// Appends a new typed block to [objectId] via `insertBlockOffline` and
  /// refreshes both the structured and text-report detail views. Returns
  /// null when no session is open.
  Future<InsertBlockResult?> insertBlock(
    String objectId, {
    required String text,
    NewBlockKind kind = NewBlockKind.text,
  }) async {
    final session = await _ref.read(sessionProvider.future);
    if (session == null) {
      return null;
    }
    final result = await insertBlockOffline(
      objectId,
      session.db,
      session.config,
      text: text,
      kind: kind,
    );
    _ref.invalidate(objectBlocksProvider(objectId));
    _ref.invalidate(objectDetailProvider(objectId));
    return result;
  }

  /// Writes one typed relation value on [objectId] via
  /// `editRelationOffline` and refreshes the text-report detail view
  /// (the only view relation details currently render in, until a
  /// structured relation replay/editor grows richer field-level widgets).
  /// Exactly one of the typed value parameters should be passed, matching
  /// `editRelationOffline`'s own contract. Returns null when no session is
  /// open.
  Future<EditRelationOfflineResult?> editRelation(
    String objectId, {
    required String relationKey,
    String? stringValue,
    List<String>? stringListValue,
    String? boolValue,
    String? dateValue,
    String? objectIdValue,
    String? status,
  }) async {
    final session = await _ref.read(sessionProvider.future);
    if (session == null) {
      return null;
    }
    final result = await editRelationOffline(
      objectId,
      session.db,
      session.config,
      relationKey: relationKey,
      stringValue: stringValue,
      stringListValue: stringListValue,
      boolValue: boolValue,
      dateValue: dateValue,
      objectIdValue: objectIdValue,
      status: status,
    );
    _ref.invalidate(objectDetailProvider(objectId));
    return result;
  }
}

final objectsControllerProvider = Provider<ObjectsController>(
  ObjectsController.new,
);
