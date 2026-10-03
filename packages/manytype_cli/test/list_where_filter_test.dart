@TestOn('vm')
library;

import 'dart:io';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/commands/list.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:test/test.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manytype_list_where_');
    AccountRegistry.testBaseDirOverride = tempDir.path;
    CliConfig.testConfigDirOverride = tempDir.path;
  });

  tearDown(() async {
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempDir.delete(recursive: true);
  });

  for (final where in ['done', '=true']) {
    test('rejects --where "$where" instead of matching everything', () async {
      expect(
        () =>
            matchesObjectMetaFilters(ObjectMeta(id: 'obj'), whereFilter: where),
        throwsArgumentError,
      );

      final db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
      addTearDown(db.close);
      await expectLater(
        listCommand(
          db,
          CliConfig(mnemonic: _mnemonic, serverAddress: '127.0.0.1:1'),
          networkConfigPath: 'unused.yml',
          whereFilter: where,
          syncService: _UnexpectedSyncService(),
        ),
        throwsArgumentError,
      );
    });
  }
}

class _UnexpectedSyncService extends SyncService {
  @override
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
    String? networkConfigContent,
  }) async {
    fail('listCommand synced before validating --where');
  }
}
