@TestOn('vm')
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype/src/app.dart';
import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/objects_providers.dart';
import 'package:manytype/src/state/session_provider.dart';
import 'package:manytype_cli/manytype_cli.dart' show ManytypeSession;
import 'package:manytype_cli/src/account_profile.dart' show AccountSummary;

void main() {
  testWidgets('pending starter template gates Home and its session list', (
    tester,
  ) async {
    final recovery = Completer<String?>();
    var sessionReads = 0;
    final summary = AccountSummary(
      id: 'demo-account',
      displayName: 'Demo workspace',
      createdAt: DateTime.utc(2026, 7, 11),
      pendingStarterTemplate: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentAccountIdProvider.overrideWith((ref) async => summary.id),
          accountsProvider.overrideWith(
            (ref) async => <AccountSummary>[summary],
          ),
          starterTemplateRecoveryProvider.overrideWith(
            (ref, accountId) => recovery.future,
          ),
          sessionProvider.overrideWith((ref) {
            sessionReads += 1;
            return Future<ManytypeSession?>.value(null);
          }),
        ],
        child: const ManyTypeApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Finishing sample workspace...'), findsOneWidget);
    expect(find.text('Loading workspace'), findsNothing);
    expect(sessionReads, 0);

    recovery.complete('template-object');
    await tester.pump();
    await tester.pump();

    expect(sessionReads, 1);
  });
}
