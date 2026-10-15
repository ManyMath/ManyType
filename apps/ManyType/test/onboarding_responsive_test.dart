@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart' show CliConfig;
import 'package:manytype_cli/src/account_profile.dart' show AccountSummary;
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manyui/manyui.dart';

import 'package:manytype/src/onboarding/onboarding_page.dart';
import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/theme.dart';

void main() {
  late Directory tempBase;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp(
      'manytype_onboarding_test',
    );
    AccountRegistry.testBaseDirOverride = tempBase.path;
    CliConfig.testConfigDirOverride = tempBase.path;
  });

  tearDown(() async {
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempBase.delete(recursive: true);
  });

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

  testWidgets('account picker names the account each Use button opens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          accountsProvider.overrideWith(
            (ref) async => <AccountSummary>[
              AccountSummary(
                id: 'work-id',
                displayName: 'Work',
                createdAt: DateTime.utc(2026, 7, 11),
              ),
              AccountSummary(
                id: 'personal-id',
                displayName: 'Personal',
                createdAt: DateTime.utc(2026, 7, 12),
              ),
            ],
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

    expect(find.bySemanticsLabel('Use Work'), findsOneWidget);
    expect(find.bySemanticsLabel('Use Personal'), findsOneWidget);
  });
}
