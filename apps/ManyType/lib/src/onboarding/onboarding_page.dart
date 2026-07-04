import 'dart:async';

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// Not re-exported by the manytype_cli barrel (see accounts_providers.dart).
// ignore: implementation_imports
import 'package:manytype_cli/src/account_profile.dart' show AccountSummary;
import 'package:manytype_core/manytype_core.dart' show generateMnemonic;
import 'package:manyui/manyui.dart';
import 'package:manyui_riverpod/manyui_riverpod.dart';

import '../accounts/forget_account.dart';
import '../state/accounts_providers.dart';
import '../state/guest_demo.dart';
import '../state/objects_providers.dart';
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
    final accounts = ref.watch(accountsProvider);
    final mode = useState<_Mode>(_Mode.pick);
    final busy = useState(false);
    final error = useState<String?>(null);
    final demoState = ref.watch(guestDemoStateProvider);
    final demoBusy = demoState.status == GuestDemoStatus.preparing;

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

    void openGuestDemo() {
      if (busy.value || demoBusy) return;
      final accountsController = ref.read(accountsControllerProvider);
      final objectsController = ref.read(objectsControllerProvider);
      final demoNotifier = ref.read(guestDemoStateProvider.notifier);
      final pendingSelection = ref.read(
        pendingObjectSelectionProvider.notifier,
      );
      demoNotifier.state = const GuestDemoUiState(
        status: GuestDemoStatus.preparing,
        message: guestDemoCreatingAccountMessage,
      );

      unawaited(() async {
        // Give the preparing state a frame before key derivation starts.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        try {
          String? createdDemoAccountId;
          final launch = await createGuestDemoWorkspace(
            createAndSelectIfNew:
                ({required mnemonic, required displayName}) async {
                  final account = await accountsController.createAndSelectIfNew(
                    mnemonic: mnemonic,
                    displayName: displayName,
                    pendingStarterTemplate: true,
                    excludedAccountIds: const <String>{
                      legacySharedDemoAccountId,
                    },
                  );
                  createdDemoAccountId = account?.id;
                  return account?.id;
                },
            seedTemplate: () async {
              final templateObjectId = await objectsController
                  .seedDemoTemplate();
              if (templateObjectId == null) {
                throw StateError('Demo account has no open session.');
              }
              final accountId = createdDemoAccountId;
              if (accountId == null) {
                throw StateError('Demo account is no longer selected.');
              }
              await accountsController.completeStarterTemplate(accountId);
              return templateObjectId;
            },
            onProgress: (message) {
              demoNotifier.state = GuestDemoUiState(
                status: GuestDemoStatus.preparing,
                message: message,
              );
            },
          );
          if (launch.templateObjectId != null) {
            pendingSelection.state = launch.templateObjectId;
          }
          demoNotifier.state = const GuestDemoUiState(
            status: GuestDemoStatus.ready,
          );
        } catch (exception) {
          demoNotifier.state = GuestDemoUiState(
            status: GuestDemoStatus.failed,
            message: 'Could not prepare the demo: $exception',
          );
        }
      }());
    }

    final body = accounts.when(
      loading: () => const MLoadingState(
        message: 'Loading accounts',
        alignment: MLoadingStateAlignment.start,
      ),
      error: (e, _) => MAlert(
        variant: MAlertVariant.destructive,
        message: 'Could not load accounts: $e',
      ),
      data: (list) => switch (mode.value) {
        _Mode.create => _CreateAccountCard(
          busy: busy.value || demoBusy,
          onCancel: () => mode.value = _Mode.pick,
          onCreate: (name, mnemonic) => runGuarded(() async {
            await ref
                .read(accountsControllerProvider)
                .createAndSelect(mnemonic: mnemonic, displayName: name);
          }),
        ),
        _Mode.import => _ImportAccountCard(
          busy: busy.value || demoBusy,
          onCancel: () => mode.value = _Mode.pick,
          onImport: (name, mnemonic) => runGuarded(() async {
            await ref
                .read(accountsControllerProvider)
                .createAndSelect(mnemonic: mnemonic, displayName: name);
          }),
        ),
        _Mode.pick when list.isNotEmpty => _AccountPickerCard(
          accounts: list,
          busy: busy.value || demoBusy,
          onUse: (id) => runGuarded(() async {
            await ref.read(accountsControllerProvider).select(id);
          }),
          onCreate: () => mode.value = _Mode.create,
          onImport: () => mode.value = _Mode.import,
          onDemo: openGuestDemo,
          onForget: (account) => confirmForgetAccount(
            context,
            ref,
            id: account.id,
            displayName: account.displayName,
          ),
        ),
        _Mode.pick => _WelcomeCard(
          busy: busy.value || demoBusy,
          onDemo: openGuestDemo,
          onCreate: () => mode.value = _Mode.create,
          onImport: () => mode.value = _Mode.import,
        ),
      },
    );

    return MScaffold(
      header: const MAppHeader(
        title: 'ManyType',
        actions: <Widget>[_ThemeToggle()],
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
                  MAlert(
                    variant: MAlertVariant.destructive,
                    message: error.value!,
                  ),
                ],
                if (demoState.status == GuestDemoStatus.failed &&
                    demoState.message != null) ...<Widget>[
                  const SizedBox(height: 12),
                  MAlert(
                    variant: MAlertVariant.destructive,
                    message: demoState.message!,
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
    return MIconButton(
      icon: ref.watchMThemeMode(themeModeProvider) == MThemeMode.dark
          ? MIconData.sun
          : MIconData.moon,
      label: 'Toggle theme',
      size: MButtonSize.sm,
      onPressed: () => ref.toggleMThemeMode(themeModeProvider),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.busy,
    required this.onDemo,
    required this.onCreate,
    required this.onImport,
  });

  final bool busy;
  final VoidCallback onDemo;
  final VoidCallback onCreate;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const MSectionHeader(
              title: 'Welcome to ManyType',
              description:
                  'An offline-first Any-Sync client. Encrypted document '
                  'changes stay local and belong to your recovery identity.',
              descriptionMaxLines: 5,
            ),
            const SizedBox(height: 24),
            MButton(
              onPressed: busy ? null : onDemo,
              child: const Text('Explore demo workspace'),
            ),
            const SizedBox(height: 12),
            const MAlert(
              variant: MAlertVariant.neutral,
              message:
                  'Each demo creates a fresh local account and recovery '
                  'phrase, then copies in sample content. Sync remains off '
                  'until you configure it.',
            ),
            const SizedBox(height: 8),
            MButton(
              variant: MButtonVariant.outline,
              onPressed: busy ? null : onCreate,
              child: const Text('Create account'),
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

class _AccountPickerCard extends StatelessWidget {
  const _AccountPickerCard({
    required this.accounts,
    required this.busy,
    required this.onUse,
    required this.onCreate,
    required this.onImport,
    required this.onDemo,
    required this.onForget,
  });

  final List<AccountSummary> accounts;
  final bool busy;
  final ValueChanged<String> onUse;
  final VoidCallback onCreate;
  final VoidCallback onImport;
  final VoidCallback onDemo;
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
            const MSectionHeader(title: 'Choose an account'),
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
                  MIconButton(
                    icon: MIconData.trash,
                    label: 'Forget ${account.displayName}',
                    size: MButtonSize.sm,
                    onPressed: busy ? null : () => onForget(account),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const MDivider(),
            const SizedBox(height: 12),
            MButton(
              onPressed: busy ? null : onDemo,
              child: const Text('Open demo workspace'),
            ),
            const SizedBox(height: 8),
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
    final nameFocus = useFocusNode();

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
            const MSectionHeader(title: 'Create account'),
            const SizedBox(height: 16),
            MField(
              label: 'Display name',
              focusNode: nameFocus,
              enabled: !busy,
              child: MTextField(
                focusNode: nameFocus,
                placeholder: 'e.g. Personal',
                semanticLabel: 'Display name',
                enabled: !busy,
                onChanged: (value) => name.value = value,
              ),
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
              MField(
                label: 'Recovery phrase',
                child: MInsetPanel(
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
    final name = useState('');
    final phrase = useState('');
    final validationError = useState<String?>(null);
    final nameFocus = useFocusNode();
    final phraseFocus = useFocusNode();

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
            const MSectionHeader(title: 'Import phrase'),
            const SizedBox(height: 16),
            MField(
              label: 'Display name',
              focusNode: nameFocus,
              enabled: !busy,
              child: MTextField(
                focusNode: nameFocus,
                placeholder: 'e.g. Personal',
                semanticLabel: 'Display name',
                enabled: !busy,
                onChanged: (value) => name.value = value,
              ),
            ),
            const SizedBox(height: 16),
            MField(
              label: 'Recovery phrase (12 or 24 words)',
              focusNode: phraseFocus,
              enabled: !busy,
              errorText: validationError.value,
              child: MTextField(
                focusNode: phraseFocus,
                placeholder: 'word word word ...',
                semanticLabel: 'Recovery phrase',
                enabled: !busy,
                error: validationError.value != null,
                onChanged: (value) => phrase.value = value,
                onSubmitted: (_) => submit(),
              ),
            ),
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
