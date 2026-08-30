@TestOn('vm')
library;

import 'dart:async';
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
import 'package:manytype/src/home/object_detail.dart';
import 'package:manytype/src/state/accounts_providers.dart';
import 'package:manytype/src/state/objects_providers.dart';
import 'package:manytype/src/state/session_provider.dart';
import 'package:manytype/src/theme.dart';

const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  late Directory tempBase;
  late ProviderContainer container;
  late String objectId;
  late String typeObjectId;
  late String relationObjectId;
  late String spaceId;
  ObjectBlockTextSaver? saveOverride;

  setUp(() async {
    saveOverride = null;
    tempBase = await Directory.systemTemp.createTemp(
      'manytype_editor_widget_test',
    );
    AccountRegistry.testBaseDirOverride = tempBase.path;
    CliConfig.testConfigDirOverride = tempBase.path;
    container = ProviderContainer(
      overrides: <Override>[
        sessionTestDbOverrideProvider.overrideWithValue(
          ManytypeDatabase.forTesting(await openDatabaseForTesting()),
        ),
        objectBlockTextSaverProvider.overrideWith((ref) {
          return (objectId, blockId, value) async {
            final override = saveOverride;
            if (override != null) {
              await override(objectId, blockId, value);
              return;
            }
            await ref
                .read(objectsControllerProvider)
                .editBlock(objectId, blockId: blockId, setText: value);
          };
        }),
      ],
    );
    await container
        .read(accountsControllerProvider)
        .createAndSelect(mnemonic: _testMnemonic, displayName: 'Test account');
    final session = await container.read(sessionProvider.future);
    spaceId = session!.identity.spaceId;
    final created = await container
        .read(objectsControllerProvider)
        .create('Responsive page');
    objectId = created!.objectId;
    await container
        .read(objectsControllerProvider)
        .insertBlock(
          objectId,
          text: 'A paragraph that remains editable on a narrow screen.',
        );
    typeObjectId =
        (await container
                .read(objectsControllerProvider)
                .create('Project', kind: NewObjectKind.type))!
            .objectId;
    relationObjectId =
        (await container
                .read(objectsControllerProvider)
                .create('Owner', kind: NewObjectKind.relation))!
            .objectId;
    await container.read(objectsProvider(spaceId).future);
    await container.read(objectBlocksProvider(objectId).future);
    await container.read(objectBlocksProvider(typeObjectId).future);
    await container.read(objectBlocksProvider(relationObjectId).future);
    await container.read(objectRelationsProvider(objectId).future);
    await container.read(currentAccountProvider.future);
  });

  tearDown(() async {
    container.dispose();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  testWidgets('document editor fits a phone viewport without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(
          theme: manyTypeLightTheme(),
          home: ObjectDetailView(
            objectId: objectId,
            spaceId: spaceId,
            onBack: () {},
            onToggleMaximized: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.bySemanticsLabel('Page title'), findsOneWidget);
    expect(find.bySemanticsLabel('Back to library'), findsOneWidget);
    expect(find.bySemanticsLabel('Maximize page'), findsOneWidget);
    expect(find.text('Properties'), findsOneWidget);
    expect(find.textContaining('createdDate'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapid title submissions save in order', (tester) async {
    final firstSave = Completer<void>();
    final values = <String>[];
    saveOverride = (_, __, value) async {
      values.add(value);
      if (values.length == 1) await firstSave.future;
    };
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(
          theme: manyTypeLightTheme(),
          home: ObjectDetailView(objectId: objectId, spaceId: spaceId),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    final title = find.byType(EditableText).first;

    await tester.enterText(title, 'First title');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.enterText(title, 'Final title');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(values, <String>['First title']);
    expect(find.text('Saving'), findsOneWidget);

    firstSave.complete();
    await tester.pump();
    await tester.pump();

    expect(values, <String>['First title', 'Final title']);
    expect(find.text('Saved locally'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('schema object titles expose their actual purpose', (
    tester,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(
          theme: manyTypeLightTheme(),
          home: ObjectDetailView(objectId: typeObjectId, spaceId: spaceId),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      tester.widget<MTextField>(find.byType(MTextField).first).semanticLabel,
      'Type name',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(
          theme: manyTypeLightTheme(),
          home: ObjectDetailView(objectId: relationObjectId, spaceId: spaceId),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      tester.widget<MTextField>(find.byType(MTextField).first).semanticLabel,
      'Relation name',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('account settings scroll and fit a phone viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(
          theme: manyTypeLightTheme(),
          home: AccountView(spaceId: spaceId, onBack: () {}),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Test account'), findsWidgets);
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.bySemanticsLabel('Copy Account ID'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('maximized page restores the prior collapsed workspace', (
    tester,
  ) async {
    container.read(pendingObjectSelectionProvider.notifier).state = objectId;
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(theme: manyTypeLightTheme(), home: const HomePage()),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.bySemanticsLabel('Page title'), findsOneWidget);
    expect(find.bySemanticsLabel('Maximize page'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Collapse workspace navigation'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Collapse Pages browser'));
    await tester.pump();

    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('workspace-navigation')))
          .width,
      60,
    );
    expect(find.bySemanticsLabel('Expand Pages browser'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Maximize page'));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('maximized-page')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('workspace-navigation')),
      findsNothing,
    );
    expect(find.bySemanticsLabel('Restore workspace'), findsOneWidget);
    expect(find.text('ManyType'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Restore workspace'));
    await tester.pump();

    final navigation = find.byKey(
      const ValueKey<String>('workspace-navigation'),
    );
    expect(tester.getSize(navigation).width, 60);
    expect(
      find.bySemanticsLabel('Expand workspace navigation'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Expand Pages browser'), findsOneWidget);
    expect(find.bySemanticsLabel('Maximize page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
