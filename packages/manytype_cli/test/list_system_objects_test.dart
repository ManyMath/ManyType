@TestOn('vm')
library;

import 'dart:io';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/list.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:test/test.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

void main() {
  late Directory tempDir;
  late ManytypeDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manytype_list_system_');
    AccountRegistry.testBaseDirOverride = tempDir.path;
    CliConfig.testConfigDirOverride = tempDir.path;
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
  });

  tearDown(() async {
    await db.close();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempDir.delete(recursive: true);
  });

  test('hides the ACL root and derived space roots', () async {
    final config = CliConfig(mnemonic: _mnemonic, serverAddress: '127.0.0.1:1');
    final created = await createCommand('hello', db, config);

    final metas = await listCommand(db, config);

    expect(
      (await db.getObjectsBySpace(created.spaceId)).length,
      greaterThan(1),
    );
    expect(metas.map((meta) => meta.id), [created.objectId]);
  });
}
