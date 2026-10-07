@TestOn('vm')
library;

import 'dart:io';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/structured_replay.dart';
import 'package:manytype_protocol/models.dart';
import 'package:test/test.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

void main() {
  late Directory tempDir;
  late ManytypeDatabase db;
  late CliConfig config;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manytype_replay_number_');
    AccountRegistry.testBaseDirOverride = tempDir.path;
    CliConfig.testConfigDirOverride = tempDir.path;
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
    config = CliConfig(mnemonic: _mnemonic, serverAddress: '127.0.0.1:1');
  });

  tearDown(() async {
    await db.close();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempDir.delete(recursive: true);
  });

  for (final (stored, rendered) in [('5', '5'), ('-12', '-12')]) {
    test('renders number relation value $stored as "$rendered"', () async {
      await createCommand(
        'Estimate',
        db,
        config,
        asRelation: true,
        format: 'number',
      );
      final target = await createCommand('Task', db, config);
      await editRelationOffline(
        target.objectId,
        db,
        config,
        relationKey: 'estimate',
        dateValue: stored,
      );

      final result = await replayObjectRelations(db, config, target.objectId);
      final view = result!.relations.singleWhere((r) => r.key == 'estimate');
      expect(view.format, RelationFormat.number);
      expect(view.stringValue, rendered);
    });
  }
}
