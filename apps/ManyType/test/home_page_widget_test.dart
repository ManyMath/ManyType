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
// The tests share one read-only account/database fixture.
// AccountRegistry's native lifecycle serializer retains the Future from the
// zone that opened it; rebuilding the fixture in each testWidgets zone makes
// the next zone wait on its predecessor indefinitely on this Flutter runner.
// Pre-warming once in setUpAll avoids that cross-zone handoff. The tests do not
// mutate persisted account or object data, each testWidgets call still creates
// a fresh widget tree, and tearDownAll explicitly closes the shared session.

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/store/database_native.dart'
    show openDatabaseForTesting;
import 'package:manyui/manyui.dart';

import 'package:manytype/src/home/account_page.dart';
import 'package:manytype/src/home/home_page.dart';
import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/guest_demo.dart';
import 'package:manytype/src/state/objects_providers.dart';
import 'package:manytype/src/state/session_provider.dart';

const _testMnemonic =
    'legal winner thank year wave sausage worth useful legal winner thank '
    'yellow';

void main() {
  late Directory tempBase;
  late ProviderContainer container;
  late ManytypeSession session;
  late String spaceId;

  setUpAll(() async {
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
        .createAndSelect(mnemonic: _testMnemonic, displayName: 'Guest');
    await container.read(currentAccountProvider.future);
    // Pre-warm the providers once outside the testWidgets zones. Riverpod
    // caches the resolved futures for each fresh widget tree in this suite.
    session = (await container.read(sessionProvider.future))!;
    spaceId = session.identity.spaceId;
    await container.read(objectsProvider(spaceId).future);
  });

  tearDownAll(() async {
    container.dispose();
    await session.close();
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

    expect(find.text('No pages yet'), findsOneWidget);
    expect(find.text('Create a page to start writing.'), findsOneWidget);
    expect(find.text('Sync: configure'), findsOneWidget);
    expect(find.bySemanticsLabel('Configure sync'), findsOneWidget);

    final accountControl = find.byWidgetPredicate(
      (widget) =>
          widget is MIconButton &&
          widget.label == 'Open account settings for Guest',
    );
    expect(accountControl, findsOneWidget);
    expect(
      tester.widget<MIconButton>(accountControl).icon,
      same(MIconData.users),
    );
    expect(
      find.bySemanticsLabel('Open account settings for Guest'),
      findsOneWidget,
    );

    await tester.tap(accountControl);
    await tester.pump();
    expect(find.text('Local identity and workspace settings'), findsOneWidget);
    final editName = find.byWidgetPredicate(
      (widget) => widget is MIconButton && widget.label == 'Edit Display name',
    );
    expect(editName, findsOneWidget);
    expect(tester.widget<MIconButton>(editName).onPressed, isNotNull);
    expect(find.textContaining('public identity from an older'), findsNothing);

    expect(find.bySemanticsLabel('View recovery phrase'), findsOneWidget);
    expect(find.text(_testMnemonic), findsNothing);
    await tester.tap(find.bySemanticsLabel('View recovery phrase'));
    await tester.pump();
    expect(find.text(_testMnemonic), findsOneWidget);
    expect(find.text('Copy phrase'), findsOneWidget);
  });

  testWidgets('compact workspace has no overflow at a phone viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(theme: MThemeData.light(), home: const HomePage()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Pages'), findsWidgets);
    expect(find.text('No pages yet'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Open account settings for Guest'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Toggle theme'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'desktop navigation and browser collapse, and section selection reopens',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MWidgetsApp(theme: MThemeData.light(), home: const HomePage()),
        ),
      );
      await tester.pump();
      await tester.pump();

      final navigation = find.byKey(
        const ValueKey<String>('workspace-navigation'),
      );
      expect(tester.getSize(navigation).width, 232);
      expect(
        find.bySemanticsLabel('Collapse workspace navigation'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Collapse Pages browser'), findsOneWidget);
      expect(find.byType(MResizable), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Collapse workspace navigation'));
      await tester.pump();
      expect(tester.getSize(navigation).width, 60);
      expect(
        find.bySemanticsLabel('Expand workspace navigation'),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel('Collapse Pages browser'));
      await tester.pump();
      expect(find.byType(MResizable), findsNothing);
      expect(find.bySemanticsLabel('Expand Pages browser'), findsOneWidget);
      expect(find.bySemanticsLabel('Search pages'), findsNothing);

      final typesControl = find.byWidgetPredicate(
        (widget) => widget is MIconButton && widget.label.startsWith('Types,'),
      );
      await tester.tap(typesControl);
      await tester.pump();

      expect(container.read(librarySectionProvider), LibrarySection.types);
      expect(find.byType(MResizable), findsOneWidget);
      expect(find.bySemanticsLabel('Search types'), findsOneWidget);
      expect(find.bySemanticsLabel('Collapse Types browser'), findsOneWidget);
      expect(tester.getSize(navigation).width, 60);

      await tester.tap(find.bySemanticsLabel('Collapse Types browser'));
      await tester.pump();
      final relationsControl = find.byWidgetPredicate(
        (widget) =>
            widget is MIconButton && widget.label.startsWith('Relations,'),
      );
      await tester.tap(relationsControl);
      await tester.pump();
      expect(container.read(librarySectionProvider), LibrarySection.relations);
      expect(find.bySemanticsLabel('Search relations'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Collapse Relations browser'),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel('Collapse Relations browser'));
      await tester.pump();
      final pagesControl = find.byWidgetPredicate(
        (widget) => widget is MIconButton && widget.label.startsWith('Pages,'),
      );
      await tester.tap(pagesControl);
      await tester.pump();
      expect(container.read(librarySectionProvider), LibrarySection.pages);
      expect(find.bySemanticsLabel('Search pages'), findsOneWidget);
      expect(find.bySemanticsLabel('Collapse Pages browser'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('demo preparation reports its current non-secret phase', (
    tester,
  ) async {
    container
        .read(guestDemoStateProvider.notifier)
        .state = const GuestDemoUiState(
      status: GuestDemoStatus.preparing,
      message: guestDemoSeedingTemplateMessage,
    );
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(theme: MThemeData.light(), home: const HomePage()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(guestDemoSeedingTemplateMessage), findsOneWidget);
    expect(find.textContaining(_testMnemonic), findsNothing);
  });

  testWidgets('retired shared demo identity remains visibly restricted', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(
          theme: MThemeData.light(),
          home: AccountView(
            spaceId: spaceId,
            isLegacySharedDemo: true,
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('public identity from an older'),
      findsOneWidget,
    );
    final editName = find.byWidgetPredicate(
      (widget) => widget is MIconButton && widget.label == 'Edit Display name',
    );
    expect(editName, findsOneWidget);
    expect(tester.widget<MIconButton>(editName).onPressed, isNull);
    final recoveryControl = find.byWidgetPredicate(
      (widget) =>
          widget is MButton && widget.semanticLabel == 'View recovery phrase',
    );
    expect(recoveryControl, findsOneWidget);
    expect(tester.widget<MButton>(recoveryControl).onPressed, isNull);
  });
}
