import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_riverpod/manyui_riverpod.dart';

import 'home/home_page.dart';
import 'onboarding/onboarding_page.dart';
import 'state/accounts_providers.dart';
import 'state/objects_providers.dart';
import 'theme.dart';

class ManyTypeApp extends ConsumerWidget {
  const ManyTypeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watchMThemeMode(themeModeProvider);
    return MWidgetsApp(
      title: 'ManyType',
      theme: manyTypeLightTheme(),
      darkTheme: manyTypeDarkTheme(),
      themeMode: mode,
      debugShowCheckedModeBanner: false,
      home: const _RootGate(),
    );
  }
}

/// Routes between onboarding and the workspace based on whether an account
/// is selected. Core has no change streams, so account mutations
/// invalidate [currentAccountIdProvider] and this gate re-evaluates.
class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentId = ref.watch(currentAccountIdProvider);
    final demoState = ref.watch(guestDemoStateProvider);
    return currentId.when(
      loading: () => const MScaffold(
        body: Center(child: MLoadingState(message: 'Loading account registry')),
      ),
      error: (e, _) => MScaffold(
        body: Center(
          child: MAlert(
            variant: MAlertVariant.destructive,
            message: 'Failed to load account registry: $e',
            maxWidth: 420,
          ),
        ),
      ),
      data: (id) {
        if (id == null) {
          return const OnboardingPage();
        }
        if (demoState.status == GuestDemoStatus.preparing) {
          return _DemoPreparationGate(
            message: demoState.message ?? 'Preparing sample workspace...',
          );
        }

        return ref
            .watch(currentAccountProvider)
            .when(
              skipLoadingOnReload: true,
              loading: () =>
                  const _DemoPreparationGate(message: 'Checking workspace...'),
              error: (e, _) => _DemoRecoveryFailure(
                message: 'Failed to load account registry: $e',
                onRetry: () => ref.invalidate(accountsProvider),
              ),
              data: (account) {
                if (account == null) {
                  return const _DemoRecoveryFailure(
                    message: 'The selected account is no longer registered.',
                  );
                }
                if (!account.pendingStarterTemplate) {
                  return const HomePage();
                }
                if (demoState.status == GuestDemoStatus.failed) {
                  return _DemoRecoveryFailure(
                    message:
                        demoState.message ??
                        'The sample workspace could not be prepared.',
                    onRetry: () {
                      ref.read(guestDemoStateProvider.notifier).state =
                          const GuestDemoUiState();
                      ref.invalidate(starterTemplateRecoveryProvider(id));
                    },
                  );
                }

                final recovery = ref.watch(starterTemplateRecoveryProvider(id));
                return recovery.when(
                  loading: () => const _DemoPreparationGate(
                    message: 'Finishing sample workspace...',
                  ),
                  error: (e, _) => _DemoRecoveryFailure(
                    message: 'Could not finish the sample workspace: $e',
                    onRetry: () =>
                        ref.invalidate(starterTemplateRecoveryProvider(id)),
                  ),
                  data: (_) => const HomePage(),
                );
              },
            );
      },
    );
  }
}

class _DemoPreparationGate extends StatelessWidget {
  const _DemoPreparationGate({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MScaffold(
      header: const MAppHeader(title: 'ManyType'),
      body: Center(child: MLoadingState(message: message)),
    );
  }
}

class _DemoRecoveryFailure extends StatelessWidget {
  const _DemoRecoveryFailure({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return MScaffold(
      header: const MAppHeader(title: 'ManyType'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MAlert(variant: MAlertVariant.destructive, message: message),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: 12),
                MButton(onPressed: onRetry, child: const Text('Try again')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
