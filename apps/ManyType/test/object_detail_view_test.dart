@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_protocol/models.dart' show Block_Content_Text_Style;
import 'package:manyui/manyui.dart';

import 'package:manytype/src/home/object_detail.dart';
import 'package:manytype/src/state/objects_providers.dart';
import 'package:manytype/src/theme.dart';

void main() {
  late Directory tempBase;
  late Map<String, List<ReplayedBlockView>> blocksById;
  late List<String> saves;
  late ProviderContainer container;

  setUp(() async {
    tempBase = await Directory.systemTemp.createTemp(
      'manytype_object_detail_test',
    );
    AccountRegistry.testBaseDirOverride = tempBase.path;
    CliConfig.testConfigDirOverride = tempBase.path;
    blocksById = <String, List<ReplayedBlockView>>{};
    saves = <String>[];
    container = ProviderContainer(
      overrides: <Override>[
        objectBlocksProvider.overrideWith(
          (ref, objectId) async => ReplayedObjectBlocks(
            objectId: objectId,
            smartBlockType: 0,
            blocks: blocksById[objectId] ?? const <ReplayedBlockView>[],
          ),
        ),
        objectsProvider.overrideWith((ref, spaceId) async => <ObjectMeta>[]),
        objectRelationsProvider.overrideWith((ref, objectId) async => null),
        objectBlockTextSaverProvider.overrideWithValue((
          objectId,
          blockId,
          value,
        ) async {
          saves.add('$objectId/$blockId=$value');
        }),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempBase.delete(recursive: true);
  });

  ReplayedBlockView title(String text) => ReplayedBlockView(
    id: 'title',
    style: Block_Content_Text_Style.Paragraph,
    text: text,
  );

  Future<void> pumpDetail(
    WidgetTester tester,
    ValueNotifier<String> selected,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MWidgetsApp(
          theme: manyTypeLightTheme(),
          home: ValueListenableBuilder<String>(
            valueListenable: selected,
            builder: (context, objectId, _) =>
                ObjectDetailView(objectId: objectId, spaceId: 'space'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('a reused detail view saves title edits to its current object', (
    tester,
  ) async {
    blocksById['a'] = <ReplayedBlockView>[title('Page A')];
    blocksById['b'] = <ReplayedBlockView>[title('Page B')];
    final selected = ValueNotifier<String>('a');
    addTearDown(selected.dispose);
    await pumpDetail(tester, selected);

    selected.value = 'b';
    await tester.pump();
    await tester.pump();
    selected.value = 'a';
    await tester.pump();

    final field = find.byType(EditableText).first;
    expect(tester.widget<EditableText>(field).controller.text, 'Page A');
    await tester.enterText(field, 'Renamed A');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pump();

    expect(saves, <String>['a/title=Renamed A']);
    expect(tester.takeException(), isNull);
  });
}
