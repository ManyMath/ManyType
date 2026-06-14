@TestOn(
    'vm') // shells out via Process.run to the manytype.dart CLI + live docker oracle stack
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

import 'support/repo_root.dart';

/// Cross-home follow-up to `oracle_file_transfer_test.dart` (M035): a home
/// that only ever ran `sync` (never `create`) used to be unable to
/// `file-open`/`file-upload` at all, because `seedLiveSpaceForSync`'s
/// bootstrap lookup only scanned the local db for an ACL/settings root in
/// their originally-created encoding, and the plain per-object HeadSync/
/// ObjectSyncRequestStream pull loop that `sync` uses for everything else
/// can't fetch those two roots (the server answers "tree not found"/
/// "unexpected request type" for them). `SyncService` now falls back to a
/// `SpacePull` RPC to recover both roots in their original encoding and
/// persists them locally, so a freshly joined home can bootstrap on its own.
void main() {
  late Directory homeA;
  late Directory homeB;

  setUp(() {
    homeA = Directory.systemTemp.createTempSync('manytype_oracle_file_a_');
    homeB = Directory.systemTemp.createTempSync('manytype_oracle_file_b_');
  });

  tearDown(() {
    homeA.deleteSync(recursive: true);
    homeB.deleteSync(recursive: true);
  });

  test(
    'a freshly joined home can file-open a blob uploaded by the creating home',
    () async {
      final repoRoot = findRepoRoot();
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
      await File(p.join(manytypeDirA.path, 'config.toml'))
          .writeAsString(configToml);
      await File(p.join(manytypeDirB.path, 'config.toml'))
          .writeAsString(configToml);

      final dbA = ManytypeDatabase(p.join(manytypeDirA.path, 'store.db'));
      await createCommand('M036: cross-home file transfer', dbA, config);
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

      final sourceFile = File(p.join(homeA.path, 'upload-source.bin'));
      // Content-addressed: the filenode dedups by CID across test runs, so
      // vary the payload per run or a repeat run "Skip"s the upload RPC
      // entirely and never exercises the upload path.
      final uploadedContent = 'M036 cross-home file transfer payload $mnemonic';
      await sourceFile.writeAsString(uploadedContent);

      final uploadResult = await Process.run(
        'dart',
        [
          'run',
          'packages/manytype_cli/bin/manytype.dart',
          '--network-config',
          'docker/any-sync/etc/client.yml',
          'file-upload',
          '--file-id',
          'm036-file',
          sourceFile.path,
        ],
        environment: envA,
        workingDirectory: repoRoot,
      );
      expect(uploadResult.exitCode, equals(0),
          reason: 'home A file-upload failed: ${uploadResult.stderr}');
      final uploadOutput = uploadResult.stdout.toString();
      expect(uploadOutput, contains('Uploaded m036-file'),
          reason: 'expected a fresh upload, not a dedup skip: $uploadOutput');

      final cidMatch = RegExp(r'cid=([^)]+)\)').firstMatch(uploadOutput);
      expect(cidMatch, isNotNull,
          reason: 'Could not find cid in upload output: $uploadOutput');
      final cid = cidMatch!.group(1)!;

      // Home B only ever joins via `sync` -- it never runs `create`, so it
      // has no local ACL/settings root in the originally-created encoding
      // unless SyncService's SpacePull fallback recovers them.
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
      expect(syncB.exitCode, equals(0),
          reason: 'home B sync failed: ${syncB.stderr}');

      final outputPath = p.join(homeB.path, 'downloaded.bin');
      final openResult = await Process.run(
        'dart',
        [
          'run',
          'packages/manytype_cli/bin/manytype.dart',
          '--network-config',
          'docker/any-sync/etc/client.yml',
          'file-open',
          '--file-id',
          'm036-file',
          '--cid',
          cid,
          '--output',
          outputPath,
        ],
        environment: envB,
        workingDirectory: repoRoot,
      );
      expect(openResult.exitCode, equals(0),
          reason: 'home B file-open failed: ${openResult.stderr}');
      expect(openResult.stdout.toString(), contains('(network)'),
          reason: 'expected a genuine filenode fetch, not a cache hit: '
              '${openResult.stdout}');

      final downloadedContent = await File(outputPath).readAsString();
      expect(downloadedContent, equals(uploadedContent));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
