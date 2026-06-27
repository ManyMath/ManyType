import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';

import 'home/home_page.dart';
import 'onboarding/onboarding_page.dart';
import 'state/accounts_providers.dart';
import 'theme.dart';

class ManyTypeApp extends ConsumerWidget {
  const ManyTypeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MWidgetsApp(
      title: 'ManyType',
      theme: MThemeData.light(),
      darkTheme: MThemeData.dark(),
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
    return currentId.when(
      loading: () =>
          const MScaffold(body: Center(child: MProgress.indeterminate())),
      error: (e, _) => MScaffold(
        body: Center(child: Text('Failed to load account registry: $e')),
      ),
      data: (id) => id == null ? const OnboardingPage() : const HomePage(),
    );
  }
}
