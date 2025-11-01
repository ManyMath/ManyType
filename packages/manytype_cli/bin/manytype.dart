import 'package:args/args.dart';

import 'package:manytype_cli/src/commands/create.dart';
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

  final createParser = ArgParser();
  parser.addCommand('create', createParser);
  parser.addCommand('sync');
  parser.addCommand('read');
  parser.addCommand('init');
  parser.addCommand('probe-network');

  final results = parser.parse(arguments);

  if (results['help'] == true || results.command == null) {
    print('Usage: manytype <command> [options]');
    print('Commands: init, create, sync, read, probe-network');
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
      break;

    case 'sync':
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      await syncCommand(db, config, networkConfigPath: networkConfigPath);
      await db.close();
      break;

    case 'read':
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      final objId = command.rest.isNotEmpty ? command.rest.first : null;
      await readCommand(db, config, objectId: objId);
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
  }
}
