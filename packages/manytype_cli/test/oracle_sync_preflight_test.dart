@TestOn('vm') // shells out via Process.run to a bash harness + live docker oracle stack
@Tags(['round_trip'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/repo_root.dart';

void main() {
  late Directory tempHome;

  setUp(() {
    tempHome =
        Directory.systemTemp.createTempSync('manytype_oracle_preflight_');
  });

  tearDown(() {
    tempHome.deleteSync(recursive: true);
  });

  test(
      'seeded oracle sync captures SpaceStatusCheck before SpaceSign and SpacePush',
      () async {
    final repoRoot = findRepoRoot();
    final manytypeDir = Directory(p.join(tempHome.path, '.manytype'));
    await manytypeDir.create(recursive: true);
    final configPath = p.join(manytypeDir.path, 'config.toml');
    final dbPath = p.join(manytypeDir.path, 'store.db');
    final capturePath = Platform.environment['ORACLE_ARTIFACT_PATH'] ??
        p.join(repoRoot, 'test_vectors', 'oracle-capture-artifact.json');
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
    await createCommand('oracle-preflight-probe', db, config);
    await seedLiveSpaceForSync(
      db,
      config,
      networkConfigPath: networkConfigPath,
    );
    await db.close();

    final env = {
      ...Platform.environment,
      'HOME': tempHome.path,
      'LD_LIBRARY_PATH':
          '${Platform.environment['LD_LIBRARY_PATH'] ?? ''}:$repoRoot/rust/target/release',
      'MANYTYPE_SYNC_CAPTURE_PATH': capturePath,
      'ORACLE_ARTIFACT_PATH': capturePath,
    };

    final result = await Process.run(
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

    expect(result.exitCode, equals(0), reason: 'sync failed: ${result.stderr}');
    final captureFile = File(capturePath);
    expect(captureFile.existsSync(), isTrue, reason: 'capture not written');

    final capture =
        jsonDecode(await captureFile.readAsString()) as Map<String, dynamic>;
    final events = (capture['events'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((event) => event['type'] == 'unary_rpc')
        .toList();
    final methods = events.map((event) => event['method'] as String).toList();

    final networkIndex =
        methods.indexOf('/coordinator.Coordinator/NetworkConfiguration');
    final statusIndex =
        methods.indexOf('/coordinator.Coordinator/SpaceStatusCheck');
    final signIndex = methods.indexOf('/coordinator.Coordinator/SpaceSign');
    final pushIndex = methods.indexOf('/spacesync.SpaceSync/SpacePush');

    expect(networkIndex, isNonNegative);
    expect(statusIndex, greaterThan(networkIndex));
    expect(signIndex, greaterThan(statusIndex));
    expect(pushIndex, greaterThan(signIndex));

    final statusEvent = events[statusIndex];
    final responseBytes =
        base64Decode(statusEvent['response_base64'] as String);
    final statusResponse = SpaceStatusCheckResponse.fromBuffer(responseBytes);
    expect(statusResponse.payload.status, SpaceStatus.SpaceStatusCreated);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
