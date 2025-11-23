import 'package:args/args.dart';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/delete.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/commands/list.dart';
import 'package:manytype_cli/src/commands/file_transfer.dart';
import 'package:manytype_cli/src/commands/probe_file_node.dart';
import 'package:manytype_cli/src/commands/probe_network.dart';
import 'package:manytype_cli/src/commands/read.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('server',
        help: 'Server address (overrides config)', defaultsTo: null)
    ..addOption('network-config',
        help: 'Path to an any-sync client.yml network config',
        defaultsTo: null);

  final createParser = ArgParser()
    ..addFlag('sync', negatable: false, help: 'Sync after creating the object');
  final readParser = ArgParser()
    ..addFlag('sync', negatable: false, help: 'Sync before reading the object');
  final editParser = ArgParser()
    ..addOption('id',
        help: 'Object ID to edit (from manytype read output)', mandatory: true)
    ..addOption('text',
        help: 'New text content for the object', mandatory: true);
  final fileUploadParser = ArgParser()
    ..addOption('file-id', help: 'Stable file ID for upload', defaultsTo: null);
  final fileOpenParser = ArgParser()
    ..addOption('file-id', help: 'File ID to open', defaultsTo: null)
    ..addOption('cid', help: 'Explicit CID to download/open', defaultsTo: null)
    ..addOption('output',
        help: 'Output path for opened bytes', defaultsTo: null);
  final probeFileNodeParser = ArgParser()
    ..addFlag(
      'read-only',
      negatable: false,
      help: 'Skip mutating file RPCs such as BlockPush',
    );
  final deleteParser = ArgParser()
    ..addOption('id',
        help: 'Object ID to delete (from manytype read output)', mandatory: true);
  final listParser = ArgParser()
    ..addOption('type', help: 'Filter by object type key (e.g. ot-page)')
    ..addOption('where', help: 'Filter by relation key=value (e.g. done=true)');
  parser.addCommand('create', createParser);
  parser.addCommand('sync');
  parser.addCommand('read', readParser);
  parser.addCommand('edit', editParser);
  parser.addCommand('delete', deleteParser);
  parser.addCommand('list', listParser);
  parser.addCommand('init');
  parser.addCommand('file-upload', fileUploadParser);
  parser.addCommand('file-open', fileOpenParser);
  parser.addCommand('probe-network');
  parser.addCommand('probe-file-node', probeFileNodeParser);

  final results = parser.parse(arguments);

  if (results['help'] == true || results.command == null) {
    print('Usage: manytype <command> [options]');
    print(
      'Commands: init, create, sync, read, edit, delete, list, file-upload, '
      'file-open, probe-network, probe-file-node',
    );
    print(parser.usage);
    return;
  }

  final command = results.command!;
  final serverOverride = results['server'] as String?;
  final networkConfigPath = results['network-config'] as String?;

  switch (command.name) {
    case 'init':
      await CliConfig.initialize();
      print('Initialized ~/.manytype/');
      print('Mnemonic saved to ${CliConfig.configPath}');
      break;

    case 'create':
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      final text =
          command.rest.isNotEmpty ? command.rest.join(' ') : 'Untitled';
      await createCommand(text, db, config);
      await db.close();

      if (command['sync'] == true) {
        if (networkConfigPath == null) {
          throw StateError(
            'create --sync requires --network-config <path>',
          );
        }
        final db = ManytypeDatabase(CliConfig.dbPath);
        await syncCommand(db, config, networkConfigPath: networkConfigPath);
        await db.close();
      }
      break;

    case 'sync':
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      await syncCommand(db, config, networkConfigPath: networkConfigPath);
      await db.close();
      break;

    case 'read':
      final config = await CliConfig.load(serverOverride: serverOverride);

      if (command['sync'] == true) {
        if (networkConfigPath == null) {
          throw StateError(
            'read --sync requires --network-config <path>',
          );
        }
        final syncDb = ManytypeDatabase(CliConfig.dbPath);
        await syncCommand(syncDb, config, networkConfigPath: networkConfigPath);
        await syncDb.close();
      }

      final db = ManytypeDatabase(CliConfig.dbPath);
      final objId = command.rest.isNotEmpty ? command.rest.first : null;
      await readCommand(db, config, objectId: objId);
      await db.close();
      break;

    case 'edit':
      if (networkConfigPath == null) {
        throw StateError(
          'edit requires --network-config <path>',
        );
      }
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      final objectId = command['id'] as String;
      final newText = command['text'] as String;
      await editCommand(objectId, newText, db, config,
          networkConfigPath: networkConfigPath);
      await db.close();
      break;

    case 'delete':
      if (networkConfigPath == null) {
        throw StateError(
          'delete requires --network-config <path>',
        );
      }
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      await deleteCommand(
        command['id'] as String,
        db,
        config,
        networkConfigPath: networkConfigPath,
      );
      await db.close();
      break;

    case 'list':
      if (networkConfigPath == null) {
        throw StateError(
          'list requires --network-config <path>',
        );
      }
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      await listCommand(
        db,
        config,
        networkConfigPath: networkConfigPath,
        typeFilter: command['type'] as String?,
        whereFilter: command['where'] as String?,
      );
      await db.close();
      break;

    case 'file-upload':
      if (networkConfigPath == null) {
        throw StateError(
          'file-upload requires --network-config <path>',
        );
      }
      final fileId = command['file-id'] as String?;
      if (fileId == null || fileId.isEmpty) {
        throw StateError('file-upload requires --file-id <id>');
      }
      if (command.rest.isEmpty) {
        throw StateError('file-upload requires a source file path');
      }
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      await fileUploadCommand(
        db,
        config,
        networkConfigPath: networkConfigPath,
        fileId: fileId,
        sourcePath: command.rest.first,
      );
      await db.close();
      break;

    case 'file-open':
      if (networkConfigPath == null) {
        throw StateError(
          'file-open requires --network-config <path>',
        );
      }
      final fileId = command['file-id'] as String?;
      if (fileId == null || fileId.isEmpty) {
        throw StateError('file-open requires --file-id <id>');
      }
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      await fileOpenCommand(
        db,
        config,
        networkConfigPath: networkConfigPath,
        fileId: fileId,
        cid: command['cid'] as String?,
        outputPath: command['output'] as String?,
      );
      await db.close();
      break;

    case 'probe-network':
      if (networkConfigPath == null) {
        throw StateError(
          'probe-network requires --network-config <path>',
        );
      }
      final config = await CliConfig.load(serverOverride: serverOverride);
      await probeNetworkCommand(config, networkConfigPath: networkConfigPath);
      break;

    case 'probe-file-node':
      if (networkConfigPath == null) {
        throw StateError(
          'probe-file-node requires --network-config <path>',
        );
      }
      final config = await CliConfig.load(serverOverride: serverOverride);
      await probeFileNodeCommand(
        config,
        networkConfigPath: networkConfigPath,
        readOnly: command['read-only'] == true,
      );
      break;
  }
}
