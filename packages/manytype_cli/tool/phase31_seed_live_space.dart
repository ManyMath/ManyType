import 'dart:io';

import 'package:args/args.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('network-config', mandatory: true)
    ..addOption(
      'wait-seconds',
      defaultsTo: '10',
      help:
          'Seconds to wait after seeding to allow coordinator propagation (default: 10).',
    );
  final results = parser.parse(argv);
  final networkConfigPath = results['network-config'] as String;
  final waitSecondsRaw = results['wait-seconds'] as String;
  final waitSeconds = int.tryParse(waitSecondsRaw);
  if (waitSeconds == null || waitSeconds < 0) {
    throw StateError('--wait-seconds must be a non-negative integer');
  }

  final config = await CliConfig.load();
  final db = ManytypeDatabase(CliConfig.dbPath);
  try {
    await seedLiveSpaceForSync(db, config,
        networkConfigPath: networkConfigPath);
  } finally {
    await db.close();
  }

  if (waitSeconds > 0) {
    stderr.writeln('Waiting ${waitSeconds}s for space propagation...');
    await Future<void>.delayed(Duration(seconds: waitSeconds));
  }
}
