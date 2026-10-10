@TestOn('vm')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manyui/manyui.dart';

import 'package:manytype/src/home/sync_dialog.dart';
import 'package:manytype/src/state/sync_controller.dart';

void main() {
  testWidgets('sync dialog exposes self-hosted server bootstrap command', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          syncMetadataStoreProvider.overrideWithValue(
            _MemorySyncMetadataStore(),
          ),
        ],
        child: MWidgetsApp(
          theme: MThemeData.light(),
          home: Builder(
            builder: (context) {
              return MButton(
                onPressed: () {
                  showSyncDialog(
                    context,
                    accountId: 'account-id',
                    spaceId: 'space-id',
                  );
                },
                child: const Text('Open sync'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sync'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Advanced setup'), findsOneWidget);
    expect(find.text('Server bootstrap').hitTestable(), findsNothing);
    await tester.tap(find.text('Advanced setup'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Server bootstrap').hitTestable(), findsOneWidget);
    expect(find.text('External listen hosts'), findsOneWidget);
    expect(find.bySemanticsLabel('Copy command'), findsOneWidget);
    expect(find.textContaining('cd docker/any-sync'), findsOneWidget);
    expect(
      find.textContaining('EXTERNAL_LISTEN_HOSTS="127.0.0.1"'),
      findsOneWidget,
    );
    expect(find.textContaining('make start'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).last, '10.0.0.5');
    await tester.pump();

    expect(
      find.textContaining('EXTERNAL_LISTEN_HOSTS="10.0.0.5"'),
      findsOneWidget,
    );
  });

  testWidgets('default sync setup fits a phone viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          syncMetadataStoreProvider.overrideWithValue(
            _MemorySyncMetadataStore(),
          ),
        ],
        child: MWidgetsApp(
          theme: MThemeData.light(),
          home: Builder(
            builder: (context) => MButton(
              onPressed: () => showSyncDialog(
                context,
                accountId: 'account-id',
                spaceId: 'space-id',
              ),
              child: const Text('Open sync'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sync'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Self-hosted coordinator'), findsOneWidget);
    expect(find.text('Advanced setup'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sync dialog surfaces durable sync facts without conflation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final configuredAt = DateTime.utc(2026, 7, 13, 18, 30);
    final probedAt = configuredAt.add(const Duration(minutes: 2));
    final store = _MemorySyncMetadataStore(<String, AccountSyncMetadata>{
      'account-id': AccountSyncMetadata(
        networkConfigContent: _networkConfig,
        configuredAt: configuredAt,
        lastProbeAt: probedAt,
        pendingLocalChanges: true,
        lastError: 'Previous sync timed out',
      ),
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          syncMetadataStoreProvider.overrideWithValue(store),
        ],
        child: MWidgetsApp(
          theme: MThemeData.light(),
          home: Builder(
            builder: (context) => MButton(
              onPressed: () => showSyncDialog(
                context,
                accountId: 'account-id',
                spaceId: 'space-id',
              ),
              child: const Text('Open sync'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sync'));
    await tester.pumpAndSettle();

    expect(find.text('Configured'), findsOneWidget);
    expect(find.text('Last probe'), findsOneWidget);
    expect(find.text('Last successful sync'), findsOneWidget);
    expect(find.text('Never'), findsOneWidget);
    expect(find.text('Local changes'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Last error'), findsOneWidget);
    expect(find.text('Previous sync timed out'), findsOneWidget);
  });

  testWidgets('unsupported platforms explain that sync is unavailable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          nativeSyncSupportedProvider.overrideWithValue(false),
          syncMetadataStoreProvider.overrideWithValue(
            _MemorySyncMetadataStore(),
          ),
        ],
        child: MWidgetsApp(
          theme: MThemeData.light(),
          home: Builder(
            builder: (context) => MButton(
              onPressed: () => showSyncDialog(
                context,
                accountId: 'account-id',
                spaceId: 'space-id',
              ),
              child: const Text('Open sync'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sync'));
    await tester.pumpAndSettle();

    expect(
      find.text('Workspaces on this platform are offline-only.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('use ManyType on macOS or Linux'),
      findsOneWidget,
    );
    expect(
      tester.widget<MButton>(find.widgetWithText(MButton, 'Probe')).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<MButton>(find.widgetWithText(MButton, 'Sync now'))
          .onPressed,
      isNull,
    );
  });
}

const _networkConfig = '''
id: local
networkId: local-net
nodes:
  - peerId: coordinator
    addresses:
      - quic://127.0.0.1:1014
    types:
      - coordinator
''';

class _MemorySyncMetadataStore implements SyncMetadataStore {
  _MemorySyncMetadataStore([Map<String, AccountSyncMetadata>? initialValues])
    : values = initialValues ?? <String, AccountSyncMetadata>{};

  final Map<String, AccountSyncMetadata> values;

  @override
  Future<AccountSyncMetadata> load(String accountId) async {
    return values[accountId] ?? const AccountSyncMetadata();
  }

  @override
  Future<void> save(String accountId, AccountSyncMetadata metadata) async {
    values[accountId] = metadata;
  }
}
