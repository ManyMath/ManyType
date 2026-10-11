@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype/src/app.dart';
import 'package:manytype/src/home/home_page.dart';
import 'package:manytype/src/onboarding/onboarding_page.dart';
import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/session_provider.dart';
import 'package:manytype/src/state/sync_controller.dart';
import 'package:manytype_cli/manytype_cli.dart'
    show AccountSyncMetadata, CliConfig, ManytypeSession;
import 'package:manytype_cli/src/account_profile.dart' show AccountSummary;
import 'package:manytype_cli/src/account_registry.dart';

void main() {
  late Directory tempBase;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp('manytype_root_gate_test');
    AccountRegistry.testBaseDirOverride = tempBase.path;
    CliConfig.testConfigDirOverride = tempBase.path;
  });

  tearDown(() async {
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  AccountSummary summary(String displayName) => AccountSummary(
    id: 'account',
    displayName: displayName,
    createdAt: DateTime.utc(2026, 7, 11),
  );

  testWidgets('reloading the account list keeps Home mounted', (tester) async {
    final reload = Completer<List<AccountSummary>>();
    var accountReads = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentAccountIdProvider.overrideWith((ref) async => 'account'),
          accountsProvider.overrideWith((ref) {
            accountReads += 1;
            return accountReads == 1
                ? Future<List<AccountSummary>>.value(<AccountSummary>[
                    summary('Work'),
                  ])
                : reload.future;
          }),
          sessionProvider.overrideWith(
            (ref) => Future<ManytypeSession?>.value(null),
          ),
          syncMetadataStoreProvider.overrideWithValue(
            _MemorySyncMetadataStore(),
          ),
        ],
        child: const ManyTypeApp(),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);

    ProviderScope.containerOf(
      tester.element(find.byType(HomePage)),
    ).invalidate(accountsProvider);
    await tester.pump();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Checking workspace...'), findsNothing);

    reload.complete(<AccountSummary>[summary('Personal')]);
    await tester.pump();
    await tester.pump();

    expect(find.text('Personal'), findsOneWidget);
  });

  testWidgets('a registry load failure can be retried', (tester) async {
    var idReads = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentAccountIdProvider.overrideWith((ref) async {
            idReads += 1;
            if (idReads == 1) throw StateError('registry unreadable');
            return null;
          }),
          accountsProvider.overrideWith(
            (ref) async => const <AccountSummary>[],
          ),
        ],
        child: const ManyTypeApp(),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('registry unreadable'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();

    expect(idReads, 2);
    expect(find.byType(OnboardingPage), findsOneWidget);
  });

  testWidgets('a missing selected account offers another account', (
    tester,
  ) async {
    var deselects = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentAccountIdProvider.overrideWith((ref) async => 'gone'),
          accountsProvider.overrideWith(
            (ref) async => <AccountSummary>[summary('Work')],
          ),
          accountsControllerProvider.overrideWith(
            (ref) => _RecordingAccountsController(ref, () => deselects += 1),
          ),
        ],
        child: const ManyTypeApp(),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(
      find.text('The selected account is no longer registered.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Choose another account'));
    await tester.pump();

    expect(deselects, 1);
  });
}

class _RecordingAccountsController extends AccountsController {
  _RecordingAccountsController(super.ref, this._onDeselect);

  final void Function() _onDeselect;

  @override
  Future<void> deselect() async => _onDeselect();
}

class _MemorySyncMetadataStore implements SyncMetadataStore {
  final Map<String, AccountSyncMetadata> values =
      <String, AccountSyncMetadata>{};

  @override
  Future<AccountSyncMetadata> load(String accountId) async {
    return values[accountId] ?? const AccountSyncMetadata();
  }

  @override
  Future<void> save(String accountId, AccountSyncMetadata metadata) async {
    values[accountId] = metadata;
  }
}
