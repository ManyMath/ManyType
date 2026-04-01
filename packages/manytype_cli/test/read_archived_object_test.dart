@TestOn('vm') // shells out via Process.run to spawn a real manytype_server subprocess
library;

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/commands/list.dart';
import 'package:manytype_cli/src/commands/read.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:test/test.dart';

void main() {
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  late ManytypeDatabase db;
  late CliConfig config;

  setUp(() async {
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
    config =
        CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:33020');
  });

  tearDown(() async {
    await db.close();
  });

  test('read/list surfaces exclude archived objects', () async {
    await createCommand('Archived object', db, config);

    final objectId = await _findObjectIdByName(db, config, 'Archived object');
    expect(objectId, isNotNull);

    await editCommand(
      objectId!,
      null,
      db,
      config,
      networkConfigPath: 'unused-network.yml',
      syncService: _NoopSyncService(),
      relationKey: 'isArchived',
      boolValue: 'true',
    );

    final readOutput = await _capturePrints(() async {
      await readCommand(db, config);
    });
    expect(readOutput, isNot(contains(objectId)));
    expect(readOutput, isNot(contains('Archived object')));

    final listOutput = await _capturePrints(() async {
      await listCommand(
        db,
        config,
        networkConfigPath: 'unused-network.yml',
        syncService: _NoopSyncService(),
      );
    });
    expect(listOutput, contains('ID'));
    expect(listOutput, isNot(contains(objectId)));
    expect(listOutput, isNot(contains('Archived object')));
  });

  test('list can read local store without network config', () async {
    await createCommand('Local list object', db, config);

    final listOutput = await _capturePrints(() async {
      await listCommand(
        db,
        config,
        syncService: _FailingSyncService(),
      );
    });

    expect(listOutput, contains('ID'));
    expect(listOutput, contains('Local list object'));
  });

  test('cli read refuses archived object ids', () async {
    final tempDir = await Directory.systemTemp.createTemp('manytype-phase47-');
    addTearDown(() async {
      await tempDir.delete(recursive: true);
    });

    final previousWarningValue =
        driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases =
          previousWarningValue;
    });

    final configDir = Directory('${tempDir.path}/.manytype');
    await configDir.create(recursive: true);
    await File('${configDir.path}/config.toml').writeAsString(
      'mnemonic = "$testMnemonic"\nserver_address = "127.0.0.1:33020"\n',
    );

    final fileDb = ManytypeDatabase('${configDir.path}/store.db');
    addTearDown(() async {
      await fileDb.close();
    });

    final fileConfig =
        CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:33020');

    await createCommand('Archived subprocess object', fileDb, fileConfig);
    final objectId = await _findObjectIdByName(
      fileDb,
      fileConfig,
      'Archived subprocess object',
    );
    expect(objectId, isNotNull);

    await editCommand(
      objectId!,
      null,
      fileDb,
      fileConfig,
      networkConfigPath: 'unused-network.yml',
      syncService: _NoopSyncService(),
      relationKey: 'isArchived',
      boolValue: 'true',
    );

    final result = await Process.run(
      'dart',
      ['run', 'packages/manytype_cli/bin/manytype.dart', 'read', objectId],
      workingDirectory: _findRepoRoot(),
      environment: {
        ...Platform.environment,
        'HOME': tempDir.path,
      },
    );

    expect(result.exitCode, equals(1));
    expect(
      result.stdout.toString(),
      contains('Object $objectId has been deleted or archived'),
    );
  });
}

class _NoopSyncService extends SyncService {
  @override
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
  }) async {}
}

Future<String?> _findObjectIdByName(
  ManytypeDatabase db,
  CliConfig config,
  String expectedName,
) async {
  for (final object in await db.getAllObjects()) {
    try {
      final replayed = await _replayObject(db, config, object.id);
      if (replayed.snapshot.details.fields['name']?.stringValue ==
          expectedName) {
        return object.id;
      }
    } on StateError {
      continue;
    }
  }
  return null;
}

class _FailingSyncService extends SyncService {
  @override
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
  }) {
    fail('sync should not be called');
  }
}

Future<ReplayedObjectState> _replayObject(
  ManytypeDatabase db,
  CliConfig config,
  String objectId,
) async {
  final treeKey = await _treeKeyForObject(config, objectId);
  final rawTreeChanges = (await db.getChangesForObject(objectId))
      .map((change) => Uint8List.fromList(change.rawBytes))
      .toList(growable: false);
  return replayObjectState(
    rawTreeChanges: rawTreeChanges,
    treeKey: treeKey,
  );
}

Future<Uint8List> _treeKeyForObject(CliConfig config, String objectId) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  return deriveTreeKey(spaceKey, objectId);
}

Future<String> _capturePrints(Future<void> Function() fn) async {
  final prints = <String>[];
  await runZoned(
    () async => await fn(),
    zoneSpecification: ZoneSpecification(
      print: (_, __, ___, String msg) {
        prints.add(msg);
      },
    ),
  );
  return prints.join('\n');
}

String _findRepoRoot() {
  Directory dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    if (File('${dir.path}/packages/manytype_cli/bin/manytype.dart')
            .existsSync() &&
        Directory('${dir.path}/packages').existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError('Could not locate repo root from ${Directory.current.path}');
}
