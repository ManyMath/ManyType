import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// Not re-exported by the manytype_cli barrel (see accounts_providers.dart).
// ignore: implementation_imports
import 'package:manytype_cli/src/account_profile.dart' show AccountSummary;
import 'package:manytype_core/manytype_core.dart' show generateMnemonic;
import 'package:manyui/manyui.dart';

import '../accounts/forget_account.dart';
import '../state/accounts_providers.dart';
import '../theme.dart';
import 'mnemonic_form.dart';

enum _Mode { pick, create, import }

/// First-run flow: create an account (generate + confirm a recovery
/// phrase), import an existing phrase, or pick one of the accounts already
/// registered on this device.
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final accounts = ref.watch(accountsProvider);
    final mode = useState<_Mode>(_Mode.pick);
    final busy = useState(false);
    final error = useState<String?>(null);

    Future<void> runGuarded(Future<void> Function() action) async {
      busy.value = true;
      error.value = null;
      // Let the progress indicator paint before Identity.fromMnemonic
      // (synchronous PBKDF2) blocks this isolate.
      // TODO(manytype): move key derivation off the UI isolate (compute).
      await Future<void>.delayed(const Duration(milliseconds: 50));
      try {
        await action();
      } catch (e) {
        error.value = '$e';
      } finally {
        busy.value = false;
      }
    }

    final body = accounts.when(
      loading: () => const MProgress.indeterminate(),
      error: (e, _) => Text(
        'Could not load accounts: $e',
        style: theme.typography.bodySmall.copyWith(
          color: theme.colors.destructive,
        ),
      ),
      data: (list) => switch (mode.value) {
        _Mode.create => _CreateAccountCard(
          busy: busy.value,
          onCancel: () => mode.value = _Mode.pick,
          onCreate: (name, mnemonic) => runGuarded(() async {
            await ref
                .read(accountsControllerProvider)
                .createAndSelect(mnemonic: mnemonic, displayName: name);
          }),
        ),
        _Mode.import => _ImportAccountCard(
          busy: busy.value,
          onCancel: () => mode.value = _Mode.pick,
          onImport: (name, mnemonic) => runGuarded(() async {
            await ref
                .read(accountsControllerProvider)
                .createAndSelect(mnemonic: mnemonic, displayName: name);
          }),
        ),
        _Mode.pick when list.isNotEmpty => _AccountPickerCard(
          accounts: list,
          busy: busy.value,
          onUse: (id) => runGuarded(() async {
            await ref.read(accountsControllerProvider).select(id);
          }),
          onCreate: () => mode.value = _Mode.create,
          onImport: () => mode.value = _Mode.import,
          onForget: (account) => confirmForgetAccount(
            context,
            ref,
            id: account.id,
            displayName: account.displayName,
          ),
        ),
        _Mode.pick => _WelcomeCard(
          onCreate: () => mode.value = _Mode.create,
          onImport: () => mode.value = _Mode.import,
        ),
      },
    );

    return MScaffold(
      header: Row(
        children: <Widget>[
          Text('ManyType', style: theme.typography.title),
          const Spacer(),
          const _ThemeToggle(),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                body,
                if (error.value != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    error.value!,
                    style: theme.typography.bodySmall.copyWith(
                      color: theme.colors.destructive,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MButton(
      variant: MButtonVariant.ghost,
      onPressed: () {
        final mode = ref.read(themeModeProvider);
        ref.read(themeModeProvider.notifier).state = mode == MThemeMode.dark
            ? MThemeMode.light
            : MThemeMode.dark;
      },
      semanticLabel: 'Toggle theme',
            child: Text(ref.watch(themeModeProvider) == MThemeMode.dark
                ? '\u2600'
                : '\u263e'),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.onCreate, required this.onImport});

  final VoidCallback onCreate;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Welcome to ManyType', style: theme.typography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'An offline-first Any-Sync client. Your notes live in a local, '
              'encrypted store owned by a recovery phrase.',
              style: theme.typography.bodySmall.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            MButton(onPressed: onCreate, child: const Text('Create account')),
            const SizedBox(height: 8),
            MButton(
              variant: MButtonVariant.outline,
              onPressed: onImport,
              child: const Text('Import phrase'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountPickerCard extends StatelessWidget {
  const _AccountPickerCard({
    required this.accounts,
    required this.busy,
    required this.onUse,
    required this.onCreate,
    required this.onImport,
    required this.onForget,
  });

  final List<AccountSummary> accounts;
  final bool busy;
  final ValueChanged<String> onUse;
  final VoidCallback onCreate;
  final VoidCallback onImport;
  final ValueChanged<AccountSummary> onForget;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Choose an account', style: theme.typography.headlineSmall),
            const SizedBox(height: 16),
            for (final account in accounts) ...<Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(account.displayName, style: theme.typography.body),
                        Text(
                          account.id,
                          style: theme.typography.code.copyWith(
                            color: theme.colors.mutedForeground,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  MButton(
                    variant: MButtonVariant.secondary,
                    onPressed: busy ? null : () => onUse(account.id),
                    child: const Text('Use'),
                  ),
                  const SizedBox(width: 8),
                  MButton(
                    variant: MButtonVariant.ghost,
                    size: MButtonSize.sm,
                    semanticLabel: 'Forget ${account.displayName}',
                    onPressed: busy ? null : () => onForget(account),
                    child: const Text('Forget'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const MDivider(),
            const SizedBox(height: 12),
            MButton(
              variant: MButtonVariant.outline,
              onPressed: busy ? null : onCreate,
              child: const Text('Create another account'),
            ),
            const SizedBox(height: 8),
            MButton(
              variant: MButtonVariant.ghost,
              onPressed: busy ? null : onImport,
              child: const Text('Import phrase'),
            ),
            if (busy) ...<Widget>[
              const SizedBox(height: 16),
              const MProgress.indeterminate(),
            ],
          ],
        ),
      ),
    );
  }
}

class _CreateAccountCard extends HookWidget {
  const _CreateAccountCard({
    required this.busy,
    required this.onCreate,
    required this.onCancel,
  });

  final bool busy;
  final void Function(String displayName, String mnemonic) onCreate;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final name = useState('');
    final mnemonic = useState<String?>(null);
    final saved = useState(false);
    final copied = useState(false);

    final phrase = mnemonic.value;

    Future<void> copyPhrase() async {
      await Clipboard.setData(ClipboardData(text: phrase!));
      copied.value = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        copied.value = false;
      }
    }
    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Create account', style: theme.typography.headlineSmall),
            const SizedBox(height: 16),
            const MLabel('Display name'),
            const SizedBox(height: 8),
            MTextField(
              placeholder: 'e.g. Personal',
              semanticLabel: 'Display name',
              enabled: !busy,
              onChanged: (value) => name.value = value,
            ),
            const SizedBox(height: 16),
            if (phrase == null)
              MButton(
                onPressed: name.value.trim().isEmpty
                    ? null
                    : () {
                        mnemonic.value = generateMnemonic();
                        saved.value = false;
                      },
                child: const Text('Generate recovery phrase'),
              )
            else ...<Widget>[
              const MLabel('Recovery phrase'),
              const SizedBox(height: 8),
              MCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(phrase, style: theme.typography.code),
                ),
              ),
              const SizedBox(height: 8),
              MButton(
                variant: MButtonVariant.outline,
                onPressed: busy ? null : copyPhrase,
                child: Text(copied.value ? 'Copied' : 'Copy'),
              ),
              const SizedBox(height: 8),
              Text(
                'This phrase is the only way to recover your account. '
                'Write it down before continuing.',
                style: theme.typography.bodySmall.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 16),
              if (!saved.value)
                MButton(
                  variant: MButtonVariant.outline,
                  onPressed: busy ? null : () => saved.value = true,
                  child: const Text('I saved my recovery phrase'),
                )
              else
                MButton(
                  onPressed: busy
                      ? null
                      : () => onCreate(name.value.trim(), phrase),
                  child: const Text('Create account'),
                ),
            ],
            const SizedBox(height: 8),
            MButton(
              variant: MButtonVariant.ghost,
              onPressed: busy ? null : onCancel,
              child: const Text('Back'),
            ),
            if (busy) ...<Widget>[
              const SizedBox(height: 16),
              const MProgress.indeterminate(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImportAccountCard extends HookWidget {
  const _ImportAccountCard({
    required this.busy,
    required this.onImport,
    required this.onCancel,
  });

  final bool busy;
  final void Function(String displayName, String mnemonic) onImport;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final name = useState('');
    final phrase = useState('');
    final validationError = useState<String?>(null);

    void submit() {
      final problem = mnemonicInputError(phrase.value);
      validationError.value = problem;
      if (problem != null) {
        return;
      }
      final displayName = name.value.trim().isEmpty
          ? 'Imported'
          : name.value.trim();
      onImport(displayName, normalizeMnemonic(phrase.value));
    }

    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Import phrase', style: theme.typography.headlineSmall),
            const SizedBox(height: 16),
            const MLabel('Display name'),
            const SizedBox(height: 8),
            MTextField(
              placeholder: 'e.g. Personal',
              semanticLabel: 'Display name',
              enabled: !busy,
              onChanged: (value) => name.value = value,
            ),
            const SizedBox(height: 16),
            const MLabel('Recovery phrase (12 or 24 words)'),
            const SizedBox(height: 8),
            MTextField(
              placeholder: 'word word word ...',
              semanticLabel: 'Recovery phrase',
              enabled: !busy,
              onChanged: (value) => phrase.value = value,
              onSubmitted: (_) => submit(),
            ),
            if (validationError.value != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                validationError.value!,
                style: theme.typography.bodySmall.copyWith(
                  color: theme.colors.destructive,
                ),
              ),
            ],
            const SizedBox(height: 16),
            MButton(
              onPressed: busy ? null : submit,
              child: const Text('Import account'),
            ),
            const SizedBox(height: 8),
            MButton(
              variant: MButtonVariant.ghost,
              onPressed: busy ? null : onCancel,
              child: const Text('Back'),
            ),
            if (busy) ...<Widget>[
              const SizedBox(height: 16),
              const MProgress.indeterminate(),
            ],
          ],
        ),
      ),
    );
  }
}
