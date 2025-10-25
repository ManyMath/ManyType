import 'package:args/args.dart';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/read.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('server',
        help: 'Server address (overrides config)', defaultsTo: null);

  final createParser = ArgParser();
  parser.addCommand('create', createParser);
  parser.addCommand('sync');
  parser.addCommand('read');
  parser.addCommand('init');

  final results = parser.parse(arguments);

  if (results['help'] == true || results.command == null) {
    print('Usage: manytype <command> [options]');
    print('Commands: init, create, sync, read');
    print(parser.usage);
    return;
  }

  final command = results.command!;
  final serverOverride = results['server'] as String?;

  switch (command.name) {
    case 'init':
      await CliConfig.initialize();
      print('Initialized ~/.manytype/');
      print('Mnemonic saved to ${CliConfig.configPath}');
      break;

    case 'create':
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      final text = command.rest.isNotEmpty ? command.rest.join(' ') : 'Untitled';
      await createCommand(text, db, config);
      await db.close();
      break;

    case 'sync':
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      await syncCommand(db, config);
      await db.close();
      break;

    case 'read':
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      final objId = command.rest.isNotEmpty ? command.rest.first : null;
      await readCommand(db, config, objectId: objId);
      await db.close();
      break;
  }
}
