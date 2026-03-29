import 'dart:async';
import 'dart:typed_data';

import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/delete.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, RootChange, TreeChange;
import 'package:manytype_protocol/spacesync.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart'
    show Value;
import 'package:test/test.dart';

import 'web/web_db_test_helpers.dart';

void main() {
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  late ManytypeDatabase db;
  late CliConfig config;

  setUpAll(() async {
    await configureWebTestDatabaseAssets();
  });

  setUp(() async {
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
    config =
        CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:33020');
  });

  tearDown(() async {
    await db.close();
  });

  test('delete archives the object and writes ObjectDelete in settings',
      () async {
    await createCommand('Delete me', db, config);

    final objectId = await _findObjectIdByName(db, config, 'Delete me');
    expect(objectId, isNotNull);
    final id = objectId!;

    final output = await _capturePrints(() async {
      await deleteCommand(
        id,
        db,
        config,
        networkConfigPath: 'unused-network.yml',
        syncService: _NoopSyncService(),
      );
    });

    expect(output, contains('Deleted $id'));
    expect(await db.isObjectDeleted(id), isTrue);

    final objectDetails = await _replayDetails(db, config, id);
    expect(objectDetails['isArchived']?.boolValue, isTrue);

    final objectTreeKey = await _treeKeyForObject(config, id);
    final objectChanges = await db.getChangesForObject(id);
    final archiveRawTreeChange =
        RawTreeChange.fromBuffer(objectChanges.last.rawBytes);
    final archiveTreeChange =
        TreeChange.fromBuffer(archiveRawTreeChange.payload);
    final archiveDecoded = await aesGcmDecrypt(
      objectTreeKey,
      Uint8List.fromList(archiveTreeChange.changesData),
    );
    final archiveChange = changes_proto.Change.fromBuffer(archiveDecoded);
    expect(
      archiveChange.content.any(
        (content) =>
            content.hasDetailsSet() &&
            content.detailsSet.key == 'isArchived' &&
            content.detailsSet.value.hasBoolValue() &&
            content.detailsSet.value.boolValue,
      ),
      isTrue,
    );

    final settingsObjectId = await _findSettingsObjectId(db, config);
    expect(settingsObjectId, isNotNull);

    final settingsChanges = await db.getChangesForObject(settingsObjectId!);
    final settingsTreeKey = await _treeKeyForObject(config, settingsObjectId);
    final settingsRawTreeChange =
        RawTreeChange.fromBuffer(settingsChanges.last.rawBytes);
    final settingsTreeChange =
        TreeChange.fromBuffer(settingsRawTreeChange.payload);
    final settingsDecoded = await aesGcmDecrypt(
      settingsTreeKey,
      Uint8List.fromList(settingsTreeChange.changesData),
    );
    final settingsData = SettingsData.fromBuffer(settingsDecoded);
    expect(settingsData.content, isNotEmpty);
    expect(settingsData.content.last.hasObjectDelete(), isTrue);
    expect(settingsData.content.last.objectDelete.id, equals(id));
  });

  test('re-seeing an object row does not clear an existing delete flag',
      () async {
    await createCommand('Delete me twice', db, config);

    final objectId = await _findObjectIdByName(db, config, 'Delete me twice');
    expect(objectId, isNotNull);
    final id = objectId!;

    await deleteCommand(
      id,
      db,
      config,
      networkConfigPath: 'unused-network.yml',
      syncService: _NoopSyncService(),
    );
    expect(await db.isObjectDeleted(id), isTrue);

    final identity = await Identity.fromMnemonic(config.mnemonic);
    await db.insertObject(id, identity.spaceId);

    expect(await db.isObjectDeleted(id), isTrue);
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
      final details = await _replayDetails(db, config, object.id);
      if (details['name']?.stringValue == expectedName) {
        return object.id;
      }
    } on StateError {
      continue;
    }
  }
  return null;
}

Future<String?> _findSettingsObjectId(
  ManytypeDatabase db,
  CliConfig config,
) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  for (final object in await db.getAllObjects()) {
    final changes = await db.getChangesForObject(object.id);
    if (changes.isEmpty) continue;
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(changes.first.rawBytes);
      if (rawTreeChange.payload.isEmpty) continue;
      final rootChange = RootChange.fromBuffer(rawTreeChange.payload);
      if (rootChange.spaceId == identity.spaceId &&
          (rootChange.changeType == 'anytype.space' ||
              rootChange.changeType == 'any-sync.space')) {
        return object.id;
      }
    } catch (_) {
      continue;
    }
  }
  return null;
}

Future<Map<String, Value>> _replayDetails(
  ManytypeDatabase db,
  CliConfig config,
  String objectId,
) async {
  final treeKey = await _treeKeyForObject(config, objectId);
  final rawTreeChanges = (await db.getChangesForObject(objectId))
      .map((change) => Uint8List.fromList(change.rawBytes))
      .toList(growable: false);
  return replayObjectDetails(rawTreeChanges: rawTreeChanges, treeKey: treeKey);
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
