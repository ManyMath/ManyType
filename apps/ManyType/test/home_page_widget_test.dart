@TestOn('vm')
library;

// Widget-level coverage for HomePage: pumps the real widget tree (session,
// providers, MWidgetsApp) against the real local store, using
// sessionTestDbOverrideProvider to swap in a synchronous in-memory database
// (ManytypeDatabase.forTesting + openDatabaseForTesting, the same seam
// manytype_cli's own package tests use) instead of the real per-account
// on-disk file. That real file is opened via
// NativeDatabase.createInBackground, a background isolate whose SendPort
// replies never arrive inside testWidgets() in this environment.
//
// Scope note: only the initial empty-state render is asserted here.
// Interaction-driven mutations (tapping Create/Delete, entering search text)
// were attempted and are NOT covered -- isolated this session to an
// environment-wide defect, not a app or test-file bug: ANY async Future
// triggered from inside a testWidgets() callback body (a Provider read, a
// tap handler, even a bare `await Directory.systemTemp.createTemp()` with
// zero app code involved) hangs indefinitely in this machine's Flutter SDK
// (3.44.4-0.0.pre-5, stable channel) -- confirmed reproducible in a
// completely fresh `flutter create` scaffold, so it is not fixable from
// this repo. The identical call from setUp()/tearDown() (outside
// testWidgets' zone) works fine, which is what makes the pre-warming below
// possible at all. See ROADMAP.md's ManyType section for the full
// isolation writeup and the follow-up once this is unblocked (SDK
// update/reinstall, on a different machine, or a future Flutter fix).

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/store/database_native.dart'
    show openDatabaseForTesting;
import 'package:manyui/manyui.dart';

import 'package:manytype/src/home/home_page.dart';
import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/objects_providers.dart';
import 'package:manytype/src/state/session_provider.dart';

const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  late Directory tempBase;
  late ProviderContainer container;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp(
      'manytype_home_widget_test',
    );
    AccountRegistry.testBaseDirOverride = tempBase.path;
    container = ProviderContainer(
      overrides: [
        sessionTestDbOverrideProvider.overrideWithValue(
          ManytypeDatabase.forTesting(await openDatabaseForTesting()),
        ),
      ],
    );
    await container
        .read(accountsControllerProvider)
        .createAndSelect(mnemonic: _testMnemonic, displayName: 'Test');
    // Pre-warm sessionProvider and objectsProvider here, outside
    // testWidgets' zone -- see the file-level comment above for why any
    // async Future awaited inside the test body itself never resolves in
    // this environment. Riverpod caches the resolved futures, so the
    // widget tree's own watch in the test below picks them up instantly.
    final session = await container.read(sessionProvider.future);
    await container.read(objectsProvider(session!.identity.spaceId).future);
  });

  tearDown(() async {
    container.dispose();
    AccountRegistry.testBaseDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  testWidgets('renders the empty state for a freshly created account', (
    tester,
  ) async {
    // HomePage's list + create card + search field is taller than the
    // default 800x600 test surface, which silently puts lower content
    // off-screen for tester.tap() hit-testing (see ROADMAP.md's Fleet-wide
    // gotcha) -- kept here even though this test doesn't tap anything yet,
    // so it stays correct if interaction coverage is added later.
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(theme: MThemeData.light(), home: const HomePage()),
      ),
    );
    // Not pumpAndSettle(): would hang on MProgress.indeterminate()'s
    // repeating AnimationController if the providers above weren't already
    // pre-warmed. A couple of plain pumps is enough now that they are.
    await tester.pump();
    await tester.pump();

    expect(find.text('No objects yet'), findsOneWidget);
    expect(find.text('Create your first object above.'), findsOneWidget);
  });
}
