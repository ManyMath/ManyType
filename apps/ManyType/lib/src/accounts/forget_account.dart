import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';

import '../state/accounts_providers.dart';

/// Confirms and forgets the account [id] ([displayName] for the prompt).
///
/// Forgetting removes the profile from this device only; the recovery
/// phrase is the sole way to restore access afterwards.
Future<void> confirmForgetAccount(
  BuildContext context,
  WidgetRef ref, {
  required String id,
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
          Text('Forget "$displayName"?', style: theme.typography.title),
          const SizedBox(height: 8),
          Text(
            'This removes the account and its local data from this device. '
            'You can only get back in with its recovery phrase.',
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
                child: const Text('Forget account'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  if (confirmed == true) {
    await ref.read(accountsControllerProvider).forget(id);
  }
}
