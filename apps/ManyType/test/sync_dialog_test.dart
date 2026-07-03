@TestOn('vm')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';

import 'package:manytype/src/home/sync_dialog.dart';

void main() {
  testWidgets('sync dialog exposes self-hosted server bootstrap command', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MWidgetsApp(
          theme: MThemeData.light(),
          home: Builder(
            builder: (context) {
              return MButton(
                onPressed: () {
                  showSyncDialog(context, spaceId: 'space-id');
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

    expect(find.text('Server bootstrap'), findsOneWidget);
    expect(find.text('External listen hosts'), findsOneWidget);
    expect(find.text('Copy command'), findsOneWidget);
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
}
