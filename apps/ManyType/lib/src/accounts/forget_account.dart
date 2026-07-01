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
  final confirmed = await showMConfirmDialog(
    context,
    title: 'Forget "$displayName"?',
    message:
        'This removes the account and its local data from this device. '
        'You can only get back in with its recovery phrase.',
    confirmLabel: 'Forget account',
    confirmVariant: MButtonVariant.destructive,
  );
  if (confirmed) {
    await ref.read(accountsControllerProvider).forget(id);
  }
}
