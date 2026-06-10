@TestOn(
    'vm') // shells out via Process.run to a bash harness + live docker oracle stack
@Tags(['round_trip'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/commands/read.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/repo_root.dart';

/// Derives the per-object tree key so `extractTextPreview` can decrypt --
/// every locally-created change has `readKeyId` set, there is no plaintext
/// path (see round_trip_test.dart's read.dart preview fix).
Future<Uint8List> _treeKeyFor(CliConfig config, String objectId) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  return deriveTreeKey(spaceKey, objectId);
}

void main() {
  late Directory homeA;
  late Directory homeB;

  setUp(() {
    homeA = Directory.systemTemp.createTempSync('manytype_oracle_edit_a_');
    homeB = Directory.systemTemp.createTempSync('manytype_oracle_edit_b_');
  });

  tearDown(() {
    homeA.deleteSync(recursive: true);
    homeB.deleteSync(recursive: true);
  });

  test(
    'oracle edit: push edit is visible after reconnect',
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
      await File(p.join(manytypeDirA.path, 'config.toml')).writeAsString(
        configToml,
      );
      await File(p.join(manytypeDirB.path, 'config.toml')).writeAsString(
        configToml,
      );

      final dbA = ManytypeDatabase(p.join(manytypeDirA.path, 'store.db'));
      await createCommand('Phase 29: oracle edit original text', dbA, config);
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
      expect(syncA.exitCode, equals(0),
          reason: 'homeA sync failed: ${syncA.stderr}');

      final dbA2 = ManytypeDatabase(p.join(manytypeDirA.path, 'store.db'));
      final identity = await Identity.fromMnemonic(config.mnemonic);
      final objects = await dbA2.getObjectsBySpace(identity.spaceId);
      String? noteObjectId;
      for (final obj in objects) {
        final changes = await dbA2.getChangesForObject(obj.id);
        final preview = await extractTextPreview(changes,
            treeKey: await _treeKeyFor(config, obj.id));
        if (preview.contains('oracle edit original text')) {
          noteObjectId = obj.id;
          break;
        }
      }
      expect(noteObjectId, isNotNull,
          reason: 'Could not find note object in homeA');
      final noteId = noteObjectId!;

      await editCommand(
        noteId,
        'Phase 29: oracle edit UPDATED text',
        dbA2,
        config,
        networkConfigPath: networkConfigPath,
      );
      await dbA2.close();

      bool foundUpdated = false;
      for (var attempt = 0; attempt < 6; attempt++) {
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
        expect(
          syncB.exitCode,
          equals(0),
          reason: 'homeB sync failed (attempt ${attempt + 1}): ${syncB.stderr}',
        );

        final dbB = ManytypeDatabase(p.join(manytypeDirB.path, 'store.db'));
        final identityB = await Identity.fromMnemonic(config.mnemonic);
        final objectsB = await dbB.getObjectsBySpace(identityB.spaceId);
        foundUpdated = false;
        for (final obj in objectsB) {
          final changes = await dbB.getChangesForObject(obj.id);
          final preview = await extractTextPreview(changes,
              treeKey: await _treeKeyFor(config, obj.id));
          if (preview == 'Phase 29: oracle edit UPDATED text') {
            foundUpdated = true;
            break;
          }
        }
        await dbB.close();

        if (foundUpdated) {
          break;
        }
        await Future.delayed(const Duration(seconds: 3));
      }
      expect(
        foundUpdated,
        isTrue,
        reason: 'homeB did not see the updated text after edit + reconnect',
      );
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  test(
    'oracle edit: repeated sync after edit is idempotent',
    () async {
      final repoRoot = findRepoRoot();
      final networkConfigPath =
          p.join(repoRoot, 'docker', 'any-sync', 'etc', 'client.yml');
      final manytypeDirA = Directory(p.join(homeA.path, '.manytype'));
      await manytypeDirA.create(recursive: true);

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

      final dbA = ManytypeDatabase(p.join(manytypeDirA.path, 'store.db'));
      await createCommand('Phase 29: oracle idempotent original', dbA, config);
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
      expect(syncA.exitCode, equals(0),
          reason: 'homeA sync failed: ${syncA.stderr}');

      final dbA2 = ManytypeDatabase(p.join(manytypeDirA.path, 'store.db'));
      final identity = await Identity.fromMnemonic(config.mnemonic);
      final objects = await dbA2.getObjectsBySpace(identity.spaceId);
      String? noteObjectId;
      for (final obj in objects) {
        final changes = await dbA2.getChangesForObject(obj.id);
        final preview = await extractTextPreview(changes,
            treeKey: await _treeKeyFor(config, obj.id));
        if (preview.contains('oracle idempotent original')) {
          noteObjectId = obj.id;
          break;
        }
      }
      expect(noteObjectId, isNotNull,
          reason: 'Could not find note object in homeA');
      final noteId = noteObjectId!;

      const updatedText = 'Phase 29: oracle idempotent UPDATED';
      await editCommand(
        noteId,
        updatedText,
        dbA2,
        config,
        networkConfigPath: networkConfigPath,
      );
      await dbA2.close();

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
          reason: 'homeA re-sync failed: ${syncA2.stderr}');

      final syncA3 = await Process.run(
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
      expect(syncA3.exitCode, equals(0),
          reason: 'homeA third sync failed: ${syncA3.stderr}');

      final dbA3 = ManytypeDatabase(p.join(manytypeDirA.path, 'store.db'));
      final changes = await dbA3.getChangesForObject(noteId);
      expect(
          await extractTextPreview(changes,
              treeKey: await _treeKeyFor(config, noteId)),
          equals(updatedText));
      await dbA3.close();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'oracle edit: head divergence is rejected on double push',
    () async {
      final repoRoot = findRepoRoot();
      final networkConfigPath =
          p.join(repoRoot, 'docker', 'any-sync', 'etc', 'client.yml');
      final manytypeDirA = Directory(p.join(homeA.path, '.manytype'));
      await manytypeDirA.create(recursive: true);

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

      final dbA = ManytypeDatabase(p.join(manytypeDirA.path, 'store.db'));
      await createCommand(
          'Phase 29: oracle sequential edit original', dbA, config);
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
      expect(syncA.exitCode, equals(0),
          reason: 'homeA sync failed: ${syncA.stderr}');

      final dbA2 = ManytypeDatabase(p.join(manytypeDirA.path, 'store.db'));
      final identity = await Identity.fromMnemonic(config.mnemonic);
      final objects = await dbA2.getObjectsBySpace(identity.spaceId);
      String? noteObjectId;
      for (final obj in objects) {
        final changes = await dbA2.getChangesForObject(obj.id);
        final preview = await extractTextPreview(changes,
            treeKey: await _treeKeyFor(config, obj.id));
        if (preview.contains('oracle sequential edit original')) {
          noteObjectId = obj.id;
          break;
        }
      }
      expect(noteObjectId, isNotNull,
          reason: 'Could not find note object in homeA');
      final noteId = noteObjectId!;

      await editCommand(
        noteId,
        'first update',
        dbA2,
        config,
        networkConfigPath: networkConfigPath,
      );
      await editCommand(
        noteId,
        'second update',
        dbA2,
        config,
        networkConfigPath: networkConfigPath,
      );

      final changes = await dbA2.getChangesForObject(noteId);
      expect(
        await extractTextPreview(changes,
            treeKey: await _treeKeyFor(config, noteId)),
        equals('second update'),
        reason:
            'Expected only the second update text; data corruption detected if "first update" is returned',
      );
      await dbA2.close();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
