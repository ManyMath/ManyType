// Archive gate helper: entry point of the fresh Flutter consumer that
// scripts/check_sdk_archives.sh builds on the hosted anytype_flutter. It
// loads the bundled bridge and creates an account in a temporary storage
// root, so the bundled SQLite is exercised too.
import 'dart:io';

import 'package:anytype_flutter/anytype_flutter.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  stdout.writeln(
    'anytype_flutter bridge ABI ${AnytypeFlutter.ensureInitialized()}',
  );
  final root = await Directory.systemTemp.createTemp('anytype_consumer_');
  try {
    ManytypeStorage.directory = root.path;
    final account = await createAccountCommand(name: 'Consumer');
    final session = await ManytypeSession.open();
    await session.objects.create('Stored by the consumer');
    final stored = (await session.objects.list()).length;
    await session.close();
    stdout
        .writeln('anytype_flutter storage ok (${account.id}, $stored object)');
  } catch (error) {
    stdout.writeln('anytype_flutter storage failed: $error');
  } finally {
    await root.delete(recursive: true);
  }
  runApp(const SizedBox());
}
