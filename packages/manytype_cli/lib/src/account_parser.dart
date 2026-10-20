import 'package:args/args.dart';

/// Builds the `account` command's ArgParser, including its subcommands.
ArgParser buildAccountParser() {
  final createParser = ArgParser()
    ..addOption('name', help: 'Display name for the new account');
  final parser = ArgParser()
    ..addCommand('create', createParser)
    ..addCommand('list')
    ..addCommand('use')
    ..addCommand('current')
    ..addCommand('remove');
  return parser;
}
