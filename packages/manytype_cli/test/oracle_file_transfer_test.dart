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

/// Live acceptance coverage for the `file-upload`/`file-open` CLI commands
/// against the docker any-sync filenode (OPSX-01: promoting a dev-facing
/// command to the same live-infra acceptance bar as `acl-lifecycle`,
/// `consensus-bootstrap`/`-continue`, and `space-pull-bootstrap`/`-refetch`
/// already have via oracle_acl_lifecycle_test.dart, consensus_service_test.dart,
/// and space_pull_bootstrap_test.dart).
///
/// Single home/db by design: `file-open`'s SpacePush prerequisite
/// (`seedLiveSpaceForSync`) requires the ACL root/settings root payload
/// bytes to already exist in the caller's *local* db in their originally
/// created form, which a fresh joined home does not have (`sync` pulling
/// them back down does not round-trip through the same decode path --
/// a separate gap from this test's scope). `uploadBlobToFileNode` does not
/// cache the blob locally on upload, so the later `file-open` is still a
/// genuine cache-miss fetch from the filenode, not a local-cache short
/// circuit.
void main() {
  late Directory home;

  setUp(() {
    home = Directory.systemTemp.createTempSync('manytype_oracle_file_');
  });

  tearDown(() {
    home.deleteSync(recursive: true);
  });

  test(
    'file-upload then file-open round-trips bytes through the live filenode',
    () async {
      final repoRoot = findRepoRoot();
      final networkConfigPath =
          p.join(repoRoot, 'docker', 'any-sync', 'etc', 'client.yml');
      final manytypeDir = Directory(p.join(home.path, '.manytype'));
      await manytypeDir.create(recursive: true);

      final mnemonic = generateMnemonic();
      final config = CliConfig(
        mnemonic: mnemonic,
        serverAddress: '127.0.0.1:33020',
      );
      final configToml = 'mnemonic = "${config.mnemonic}"\n'
          'server_address = "${config.serverAddress}"\n';
      await File(p.join(manytypeDir.path, 'config.toml')).writeAsString(
        configToml,
      );

      // A space must exist server-side (SpacePush) before the filenode will
      // accept blocks scoped to it -- same bootstrap seedLiveSpaceForSync
      // used by the oracle sync/edit/pull tests.
      final db = ManytypeDatabase(p.join(manytypeDir.path, 'store.db'));
      await createCommand('Phase 30: oracle file transfer', db, config);
      await seedLiveSpaceForSync(
        db,
        config,
        networkConfigPath: networkConfigPath,
      );
      await db.close();

      await Future.delayed(const Duration(seconds: 10));

      final env = {
        ...Platform.environment,
        'HOME': home.path,
        'LD_LIBRARY_PATH': '${Platform.environment['LD_LIBRARY_PATH'] ?? ''}:'
            '$repoRoot/rust/target/release',
      };

      final sourceFile = File(p.join(home.path, 'upload-source.bin'));
      // Content-addressed: the filenode dedups by CID across test runs, so
      // vary the payload per run or a repeat run "Skip"s the upload RPC
      // entirely and never exercises the upload path.
      final uploadedContent = 'Phase 30 file transfer payload $mnemonic';
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
          'phase30-file',
          sourceFile.path,
        ],
        environment: env,
        workingDirectory: repoRoot,
      );
      expect(uploadResult.exitCode, equals(0),
          reason: 'file-upload failed: ${uploadResult.stderr}');
      final uploadOutput = uploadResult.stdout.toString();
      expect(uploadOutput, contains('Uploaded phase30-file'),
          reason: 'expected a fresh upload, not a dedup skip: $uploadOutput');

      final cidMatch = RegExp(r'cid=([^)]+)\)').firstMatch(uploadOutput);
      expect(cidMatch, isNotNull,
          reason: 'Could not find cid in upload output: $uploadOutput');
      final cid = cidMatch!.group(1)!;

      final outputPath = p.join(home.path, 'downloaded.bin');
      final openResult = await Process.run(
        'dart',
        [
          'run',
          'packages/manytype_cli/bin/manytype.dart',
          '--network-config',
          'docker/any-sync/etc/client.yml',
          'file-open',
          '--file-id',
          'phase30-file',
          '--cid',
          cid,
          '--output',
          outputPath,
        ],
        environment: env,
        workingDirectory: repoRoot,
      );
      expect(openResult.exitCode, equals(0),
          reason: 'file-open failed: ${openResult.stderr}');
      expect(openResult.stdout.toString(), contains('(network)'),
          reason: 'expected a genuine filenode fetch, not a cache hit: '
              '${openResult.stdout}');

      final downloadedContent = await File(outputPath).readAsString();
      expect(downloadedContent, equals(uploadedContent));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
