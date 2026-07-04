@TestOn('vm')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/src/account_profile.dart' show AccountSummary;
import 'package:manyui/manyui.dart';

import 'package:manytype/src/onboarding/onboarding_page.dart';
import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/theme.dart';

void main() {
  testWidgets('welcome flow describes a fresh unsynced demo account', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          accountsProvider.overrideWith(
            (ref) async => const <AccountSummary>[],
          ),
        ],
        child: MWidgetsApp(
          theme: manyTypeLightTheme(),
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Explore demo workspace'), findsOneWidget);
    expect(find.textContaining('fresh local account'), findsOneWidget);
    expect(find.textContaining('Sync remains off'), findsOneWidget);
    expect(find.textContaining('shared recovery phrase'), findsNothing);
    expect(find.bySemanticsLabel('Toggle theme'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
