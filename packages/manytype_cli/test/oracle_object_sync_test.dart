@TestOn(
    'vm') // shells out via Process.start to a bash harness + live docker oracle stack
@Tags(['round_trip'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/repo_root.dart';

void main() {
  late Directory tempHome;

  setUp(() {
    tempHome =
        Directory.systemTemp.createTempSync('manytype_oracle_object_sync_');
  });

  tearDown(() {
    tempHome.deleteSync(recursive: true);
  });

  test('official object sync capture: push new object to oracle', () async {
    final repoRoot = findRepoRoot();
    final manytypeDir = Directory(p.join(tempHome.path, '.manytype'));
    await manytypeDir.create(recursive: true);
    final configPath = p.join(manytypeDir.path, 'config.toml');
    final dbPath = p.join(manytypeDir.path, 'store.db');
    final capturePath = Platform.environment['PHASE27_OBJECT_TRUTH_PATH'] ??
        p.join(repoRoot, 'test_vectors', 'phase27-object-truth.json');
    final networkConfigPath =
        p.join(repoRoot, 'docker', 'any-sync', 'etc', 'client.yml');

    final config = CliConfig(
      mnemonic: generateMnemonic(),
      serverAddress: '127.0.0.1:33020',
    );
    await File(configPath).writeAsString(
      'mnemonic = "${config.mnemonic}"\nserver_address = "${config.serverAddress}"\n',
    );

    final db = ManytypeDatabase(dbPath);
    // 1. Create space + object
    await createCommand('Phase 27: Page Object Truth', db, config);
    // 2. Seed space to oracle
    await seedLiveSpaceForSync(
      db,
      config,
      networkConfigPath: networkConfigPath,
    );
    await db.close();

    print('Waiting for space creation to propagate to coordinator...');
    await Future.delayed(const Duration(seconds: 10));

    final env = {
      ...Platform.environment,
      'HOME': tempHome.path,
      'LD_LIBRARY_PATH':
          '${Platform.environment['LD_LIBRARY_PATH'] ?? ''}:$repoRoot/rust/target/release',
      'MANYTYPE_SYNC_CAPTURE_PATH': capturePath,
    };

    // 2. Sync to oracle
    final process = await Process.start(
      'dart',
      [
        'run',
        'packages/manytype_cli/bin/manytype.dart',
        '--network-config',
        'docker/any-sync/etc/client.yml',
        'sync',
      ],
      environment: env,
      workingDirectory: repoRoot,
    );

    final stdoutFuture =
        process.stdout.transform(utf8.decoder).listen(print).asFuture();
    final stderrFuture =
        process.stderr.transform(utf8.decoder).listen(print).asFuture();

    final exitCode = await process.exitCode;
    await stdoutFuture;
    await stderrFuture;

    expect(exitCode, equals(0), reason: 'sync failed');
    final captureFile = File(capturePath);
    expect(captureFile.existsSync(), isTrue, reason: 'capture not written');

    final capture =
        jsonDecode(await captureFile.readAsString()) as Map<String, dynamic>;
    final events = (capture['events'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .toList();

    // Verify ObjectSync or ObjectSyncStream was called
    final objectSyncMethods = events
        .where((e) => e['type'] == 'unary_rpc' || e['type'] == 'stream_rpc')
        .map((e) => e['method'] as String)
        .where((m) => m.contains('ObjectSync'))
        .toList();

    expect(objectSyncMethods, isNotEmpty,
        reason: 'No ObjectSync RPCs found in capture');
    print('Found ObjectSync RPCs: $objectSyncMethods');

    final objectSyncStreamMessages = events
        .where((event) =>
            event['type'] == 'stream_rpc' &&
            event['method'] == '/spacesync.SpaceSync/ObjectSyncStream')
        .expand(
          (event) => (event['request_messages'] as List<dynamic>)
              .cast<Map<String, dynamic>>(),
        )
        .map<TreeSyncMessage>(
          (message) => TreeSyncMessage.fromBuffer(
              base64Decode(message['base64'] as String)),
        )
        .where(
          (TreeSyncMessage message) =>
              message.hasContent() && message.content.hasHeadUpdate(),
        )
        .toList(growable: false);

    expect(
      objectSyncStreamMessages,
      isNotEmpty,
      reason: 'No ObjectSyncStream head updates found in capture',
    );

    final snapshotBackedHeadUpdates =
        objectSyncStreamMessages.where((TreeSyncMessage message) {
      if (!message.hasRootChange()) {
        return false;
      }
      final headUpdate = message.content.headUpdate;
      return headUpdate.snapshotPath.length >= 2;
    }).toList(growable: false);

    expect(
      snapshotBackedHeadUpdates,
      isNotEmpty,
      reason:
          'Expected at least one snapshot-backed ObjectSyncStream head update',
    );

    for (final message in snapshotBackedHeadUpdates) {
      final headUpdate = message.content.headUpdate;
      final changeIds =
          headUpdate.changes.map((change) => change.id).toList(growable: false);

      expect(
        changeIds,
        contains(message.rootChange.id),
        reason: 'Root change must be replayable from headUpdate.changes',
      );
      expect(
        headUpdate.snapshotPath.last,
        equals(message.rootChange.id),
        reason: 'Snapshot path must terminate at the tree root',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
