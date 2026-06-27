import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';

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

/// Text-block styles `createCommand` can produce offline.
enum NewObjectKind { text, checkbox, numbered, toggle, quote, callout }

extension NewObjectKindLabel on NewObjectKind {
  String get label => switch (this) {
    NewObjectKind.text => 'Text',
    NewObjectKind.checkbox => 'Checkbox',
    NewObjectKind.numbered => 'Numbered list',
    NewObjectKind.toggle => 'Toggle',
    NewObjectKind.quote => 'Quote',
    NewObjectKind.callout => 'Callout',
  };
}

/// Object mutations. Create is fully offline (signed changes persisted to
/// the local Drift store); the list provider is invalidated afterwards so
/// the GUI re-queries.
class ObjectsController {
  ObjectsController(this._ref);

  final Ref _ref;

  /// Creates a text object in the personal space and refreshes the list.
  /// Returns null when no session is open (pre-onboarding).
  Future<CreateResult?> create(
    String text, {
    NewObjectKind kind = NewObjectKind.text,
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
    );
    _ref.invalidate(objectsProvider(result.spaceId));
    return result;
  }

  // TODO(manytype): phase 2 editing. `editCommand` requires a network
  // config today; offline edits need a tree_builder wrapper (or a core
  // change relaxing that requirement). Phase 1 is create + list + read.
}

final objectsControllerProvider = Provider<ObjectsController>(
  ObjectsController.new,
);
