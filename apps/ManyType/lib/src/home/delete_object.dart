import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';

import '../state/objects_providers.dart';

/// Confirms and deletes object [objectId] ([displayName] for the prompt) in
/// [spaceId].
///
/// Deletion here is local-only until the next sync: the object is archived
/// and flagged deleted in the local store immediately and there is no undo
/// from this UI once confirmed, but the corresponding `ObjectDelete`
/// settings-tree change only reaches other devices/space members on the
/// next successful `manytype sync` -- this is not the same as a mutable
/// app's "undo my mistake" delete, it is a durable local tombstone.
/// Returns true if the object was deleted, false otherwise (cancelled or no
/// session).
Future<bool> confirmDeleteObject(
  BuildContext context,
  WidgetRef ref, {
  required String objectId,
  required String spaceId,
  required String displayName,
}) async {
  final confirmed = await showMConfirmDialog(
    context,
    title: 'Delete "$displayName"?',
    message:
        'This marks the object deleted on this device right away and cannot '
        'be undone from here. The delete only reaches your other devices once '
        'you sync.',
    confirmLabel: 'Delete',
    confirmVariant: MButtonVariant.destructive,
  );
  if (!confirmed) {
    return false;
  }
  final result = await ref
      .read(objectsControllerProvider)
      .delete(objectId, spaceId);
  return result != null;
}
