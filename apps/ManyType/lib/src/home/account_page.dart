import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';

import '../accounts/edit_account_field.dart';
import '../accounts/forget_account.dart';
import '../state/accounts_providers.dart';
import '../state/session_provider.dart';

class AccountView extends ConsumerWidget {
  const AccountView({
    super.key,
    required this.spaceId,
    required this.onBack,
    this.isLegacySharedDemo = false,
  });

  final String spaceId;
  final VoidCallback onBack;
  final bool isLegacySharedDemo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final account = ref.watch(currentAccountProvider).valueOrNull;
    final config = ref.watch(sessionProvider).valueOrNull?.config;
    final server = config?.serverAddress;
    final recoveryPhrase = config?.mnemonic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.colors.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                MIconButton(
                  icon: MIconData.chevronLeft,
                  label: 'Back to library',
                  size: MButtonSize.sm,
                  onPressed: onBack,
                ),
                const SizedBox(width: 8),
                Text('Account', style: theme.typography.headlineSmall),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      account?.displayName ?? 'Account',
                      style: theme.typography.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Local identity and workspace settings',
                      style: theme.typography.bodySmall.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    if (isLegacySharedDemo) ...<Widget>[
                      const SizedBox(height: 20),
                      const MAlert(
                        variant: MAlertVariant.destructive,
                        message:
                            'This account is the public identity from an older '
                            'ManyType demo. Do not use it for private data.',
                      ),
                    ],
                    const SizedBox(height: 28),
                    Text('Profile', style: theme.typography.label),
                    const SizedBox(height: 12),
                    MInsetPanel(
                      padding: const EdgeInsets.all(16),
                      child: _EditableFact(
                        label: 'Display name',
                        value: account?.displayName,
                        style: theme.typography.body,
                        onEdit: account == null || isLegacySharedDemo
                            ? null
                            : () async {
                                final name = await promptEditAccountField(
                                  context,
                                  title: 'Rename account',
                                  label: 'Display name',
                                  initialValue: account.displayName,
                                );
                                if (name != null &&
                                    name != account.displayName) {
                                  await ref
                                      .read(accountsControllerProvider)
                                      .rename(account.id, name);
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Workspace', style: theme.typography.label),
                    const SizedBox(height: 12),
                    MInsetPanel(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _CopyableFact(
                            label: 'Account ID',
                            value: account?.id,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: MDivider(),
                          ),
                          _CopyableFact(
                            label: 'Personal space ID',
                            value: spaceId,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: MDivider(),
                          ),
                          _EditableFact(
                            label: 'Server address',
                            value: server,
                            style: theme.typography.code.copyWith(fontSize: 12),
                            onEdit: account == null || isLegacySharedDemo
                                ? null
                                : () async {
                                    final address =
                                        await promptEditAccountField(
                                          context,
                                          title: 'Edit server address',
                                          label: 'Server address',
                                          initialValue: server,
                                        );
                                    if (address != null && address != server) {
                                      await ref
                                          .read(accountsControllerProvider)
                                          .updateServerAddress(
                                            account.id,
                                            address,
                                          );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Recovery', style: theme.typography.label),
                    const SizedBox(height: 12),
                    MInsetPanel(
                      padding: const EdgeInsets.all(16),
                      child: MPropertyRow(
                        label: 'Recovery phrase',
                        value: Text(
                          isLegacySharedDemo
                              ? 'Retired public demo phrase'
                              : recoveryPhrase == null
                              ? 'Unavailable'
                              : '${recoveryPhrase.trim().split(RegExp(r'\s+')).length} words - keep private',
                          style: theme.typography.body,
                        ),
                        trailing: MButton(
                          variant: MButtonVariant.outline,
                          size: MButtonSize.sm,
                          semanticLabel: 'View recovery phrase',
                          onPressed:
                              recoveryPhrase == null || isLegacySharedDemo
                              ? null
                              : () => _showRecoveryPhraseDialog(
                                  context,
                                  recoveryPhrase,
                                ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              MIcon(MIconData.eye, size: 16),
                              SizedBox(width: 6),
                              Text('View'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        MButton(
                          variant: MButtonVariant.outline,
                          onPressed: () =>
                              ref.read(accountsControllerProvider).deselect(),
                          child: const Text('Switch account'),
                        ),
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
                          child: const Text('Forget account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showRecoveryPhraseDialog(
  BuildContext context,
  String recoveryPhrase,
) => showMDialog<void>(
  context,
  semanticLabel: 'Recovery phrase',
  builder: (context) => _RecoveryPhraseDialog(recoveryPhrase: recoveryPhrase),
);

class _RecoveryPhraseDialog extends HookWidget {
  const _RecoveryPhraseDialog({required this.recoveryPhrase});

  final String recoveryPhrase;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final copied = useState(false);

    Future<void> copyPhrase() async {
      await Clipboard.setData(ClipboardData(text: recoveryPhrase));
      copied.value = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (context.mounted) copied.value = false;
    }

    return MDialogContent(
      title: 'Recovery phrase',
      description: 'Use these words to restore this account on another device.',
      maxWidth: 520,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const MAlert(
            variant: MAlertVariant.destructive,
            message:
                'Anyone with this phrase can control the account. Keep it '
                'private and store it somewhere safe.',
          ),
          const SizedBox(height: 16),
          MInsetPanel(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              label: 'Recovery phrase words',
              child: Text(
                recoveryPhrase,
                style: theme.typography.code.copyWith(height: 1.6),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        MButton(
          variant: MButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        MButton(
          onPressed: copyPhrase,
          child: Text(copied.value ? 'Copied' : 'Copy phrase'),
        ),
      ],
    );
  }
}

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
    return MPropertyRow(
      label: label,
      value: Text(value ?? 'Not set', style: style, softWrap: true),
      trailing: MIconButton(
        icon: MIconData.edit,
        label: 'Edit $label',
        size: MButtonSize.sm,
        variant: MButtonVariant.outline,
        onPressed: onEdit == null ? null : () => onEdit!(),
      ),
    );
  }
}

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
      if (text == null) return;
      await Clipboard.setData(ClipboardData(text: text));
      copied.value = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (context.mounted) copied.value = false;
    }

    return MPropertyRow(
      label: label,
      value: Text(
        text ?? 'Not set',
        style: theme.typography.code.copyWith(fontSize: 12),
        softWrap: true,
      ),
      trailing: MIconButton(
        icon: copied.value ? MIconData.check : MIconData.copy,
        label: copied.value ? '$label copied' : 'Copy $label',
        size: MButtonSize.sm,
        variant: MButtonVariant.outline,
        onPressed: text == null ? null : copy,
      ),
    );
  }
}
