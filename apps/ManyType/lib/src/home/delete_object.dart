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
  final theme = MTheme.of(context);
  final confirmed = await showMDialog<bool>(
    context,
    builder: (BuildContext ctx) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Delete "$displayName"?', style: theme.typography.title),
          const SizedBox(height: 8),
          Text(
            'This marks the object deleted on this device right away and '
            'cannot be undone from here. The delete only reaches your other '
            'devices once you sync.',
            style: theme.typography.bodySmall
                .copyWith(color: theme.colors.mutedForeground),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              MButton(
                variant: MButtonVariant.ghost,
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              MButton(
                variant: MButtonVariant.destructive,
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  if (confirmed != true) {
    return false;
  }
  final result = await ref
      .read(objectsControllerProvider)
      .delete(objectId, spaceId);
  return result != null;
}
