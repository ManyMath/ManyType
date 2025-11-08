@Tags(['round_trip'])
library;

import 'dart:io';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory homeA;
  late Directory homeB;

  setUp(() {
    homeA = Directory.systemTemp.createTempSync('manytype_oracle_pull_a_');
    homeB = Directory.systemTemp.createTempSync('manytype_oracle_pull_b_');
  });

  tearDown(() {
    homeA.deleteSync(recursive: true);
    homeB.deleteSync(recursive: true);
  });

  test(
    'fresh store with same mnemonic can pull and reread object from oracle',
    () async {
      final repoRoot = Directory.current.path;
      final networkConfigPath =
          p.join(repoRoot, 'docker', 'any-sync', 'etc', 'client.yml');
      final manytypeDirA = Directory(p.join(homeA.path, '.manytype'));
      final manytypeDirB = Directory(p.join(homeB.path, '.manytype'));
      await manytypeDirA.create(recursive: true);
      await manytypeDirB.create(recursive: true);

      final mnemonic = generateMnemonic();
      final config = CliConfig(
        mnemonic: mnemonic,
        serverAddress: '127.0.0.1:33020',
      );
      final configToml = 'mnemonic = "${config.mnemonic}"\n'
          'server_address = "${config.serverAddress}"\n';
      await File(p.join(manytypeDirA.path, 'config.toml')).writeAsString(
        configToml,
      );
      await File(p.join(manytypeDirB.path, 'config.toml')).writeAsString(
        configToml,
      );

      final dbA = ManytypeDatabase(p.join(manytypeDirA.path, 'store.db'));
      await createCommand('Phase 28: oracle pull reread', dbA, config);
      await seedLiveSpaceForSync(
        dbA,
        config,
        networkConfigPath: networkConfigPath,
      );
      await dbA.close();

      await Future.delayed(const Duration(seconds: 10));

      final envA = {
        ...Platform.environment,
        'HOME': homeA.path,
        'LD_LIBRARY_PATH': '${Platform.environment['LD_LIBRARY_PATH'] ?? ''}:'
            '$repoRoot/rust/target/release',
      };
      final envB = {
        ...Platform.environment,
        'HOME': homeB.path,
        'LD_LIBRARY_PATH': '${Platform.environment['LD_LIBRARY_PATH'] ?? ''}:'
            '$repoRoot/rust/target/release',
      };

      final syncA = await Process.run(
        'dart',
        [
          'run',
          'packages/manytype_cli/bin/manytype.dart',
          '--network-config',
          'docker/any-sync/etc/client.yml',
          'sync',
        ],
        environment: envA,
        workingDirectory: repoRoot,
      );
      print('syncA stderr:\n${syncA.stderr}');
      expect(syncA.exitCode, equals(0),
          reason: 'home A sync failed: ${syncA.stderr}');
      final syncAOutput = syncA.stdout.toString();

      final syncA2 = await Process.run(
        'dart',
        [
          'run',
          'packages/manytype_cli/bin/manytype.dart',
          '--network-config',
          'docker/any-sync/etc/client.yml',
          'sync',
        ],
        environment: envA,
        workingDirectory: repoRoot,
      );
      expect(syncA2.exitCode, equals(0),
          reason: 'home A sync 2 failed: ${syncA2.stderr}');
      final syncA2Output = syncA2.stdout.toString();

      final syncB = await Process.run(
        'dart',
        [
          'run',
          'packages/manytype_cli/bin/manytype.dart',
          '--network-config',
          'docker/any-sync/etc/client.yml',
          'sync',
        ],
        environment: envB,
        workingDirectory: repoRoot,
      );
      print('syncB stderr:\n${syncB.stderr}');
      expect(syncB.exitCode, equals(0),
          reason: 'home B sync failed: ${syncB.stderr}');
      final syncBOutput = syncB.stdout.toString();

      final syncBAgain = await Process.run(
        'dart',
        [
          'run',
          'packages/manytype_cli/bin/manytype.dart',
          '--network-config',
          'docker/any-sync/etc/client.yml',
          'sync',
        ],
        environment: envB,
        workingDirectory: repoRoot,
      );
      expect(
        syncBAgain.exitCode,
        equals(0),
        reason: 'home B re-sync failed: ${syncBAgain.stderr}',
      );
      final syncBAgainOutput = syncBAgain.stdout.toString();
      expect(
        syncBOutput.contains('pulled 1 objects') ||
            syncBAgainOutput.contains('pulled 1 objects'),
        isTrue,
        reason: 'home B never pulled the oracle object.\n'
            'home A sync:\n$syncAOutput\n'
            'first sync:\n$syncBOutput\n'
            'second sync:\n$syncBAgainOutput',
      );

      final readB = await Process.run(
        'dart',
        ['run', 'packages/manytype_cli/bin/manytype.dart', 'read'],
        environment: envB,
        workingDirectory: repoRoot,
      );
      expect(readB.exitCode, equals(0),
          reason: 'home B read failed: ${readB.stderr}');
      expect(readB.stdout.toString(), contains('Phase 28: oracle pull reread'));
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
