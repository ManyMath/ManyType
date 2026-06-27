import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';

import '../accounts/edit_account_field.dart';
import '../accounts/forget_account.dart';
import '../state/accounts_providers.dart';
import '../state/session_provider.dart';

/// Account view: the current account's identity facts plus a way back to
/// the picker. Swaps into the same slot as the object detail (side pane
/// when wide, drill-in when narrow), so it takes an [onBack] like
/// `ObjectDetailView`.
class AccountView extends ConsumerWidget {
  const AccountView({super.key, required this.spaceId, required this.onBack});

  final String spaceId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final account = ref.watch(currentAccountProvider).valueOrNull;
    final server =
        ref.watch(sessionProvider).valueOrNull?.config.serverAddress;

    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Account', style: theme.typography.headlineSmall),
                ),
                MButton(
                  variant: MButtonVariant.ghost,
                  onPressed: onBack,
                  child: const Text('Back'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _EditableFact(
              label: 'Display name',
              value: account?.displayName,
              style: theme.typography.body,
              onEdit: account == null
                  ? null
                  : () async {
                      final name = await promptEditAccountField(
                        context,
                        title: 'Rename account',
                        label: 'Display name',
                        initialValue: account.displayName,
                      );
                      if (name != null && name != account.displayName) {
                        await ref
                            .read(accountsControllerProvider)
                            .rename(account.id, name);
                      }
                    },
            ),
            const SizedBox(height: 16),
            _CopyableFact(label: 'Account id', value: account?.id),
            const SizedBox(height: 16),
            _CopyableFact(label: 'Personal space id', value: spaceId),
            const SizedBox(height: 16),
            _EditableFact(
              label: 'Server address',
              value: server,
              style: theme.typography.code.copyWith(fontSize: 12),
              onEdit: account == null
                  ? null
                  : () async {
                      final address = await promptEditAccountField(
                        context,
                        title: 'Edit server address',
                        label: 'Server address',
                        initialValue: server,
                      );
                      if (address != null && address != server) {
                        await ref
                            .read(accountsControllerProvider)
                            .updateServerAddress(account.id, address);
                      }
                    },
            ),
            const SizedBox(height: 24),
            MButton(
              variant: MButtonVariant.outline,
              onPressed: () => ref.read(accountsControllerProvider).deselect(),
              child: const Text('Switch account'),
            ),
            const SizedBox(height: 8),
            MButton(
              variant: MButtonVariant.destructive,
              onPressed: account == null
                  ? null
                  : () => confirmForgetAccount(
                        context,
                        ref,
                        id: account.id,
                        displayName: account.displayName,
                      ),
              child: const Text('Forget this account…'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label over a value with a small "Edit" button that prompts for a new
/// value via [promptEditAccountField] and hands it to [onEdit].
class _EditableFact extends StatelessWidget {
  const _EditableFact({
    required this.label,
    required this.value,
    required this.style,
    required this.onEdit,
  });

  final String label;
  final String? value;
  final TextStyle style;
  final Future<void> Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.typography.label),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Expanded(child: Text(value ?? '—', style: style)),
            const SizedBox(width: 8),
            MButton(
              variant: MButtonVariant.outline,
              size: MButtonSize.xs,
              onPressed: onEdit == null ? null : () => onEdit!(),
              child: const Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Label over a code-styled value with a small copy button that briefly
/// flips to "Copied" as feedback.
class _CopyableFact extends HookWidget {
  const _CopyableFact({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final copied = useState(false);
    final text = value;

    Future<void> copy() async {
      await Clipboard.setData(ClipboardData(text: text!));
      copied.value = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        copied.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.typography.label),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                text ?? '—',
                style: theme.typography.code.copyWith(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            MButton(
              variant: MButtonVariant.outline,
              size: MButtonSize.xs,
              onPressed: text == null ? null : copy,
              child: Text(copied.value ? 'Copied' : 'Copy'),
            ),
          ],
        ),
      ],
    );
  }
}
