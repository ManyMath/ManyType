import 'package:args/args.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand('create')
    ..addCommand('sync')
    ..addCommand('read');

  final results = parser.parse(arguments);
  if (results.command == null) {
    print('Usage: manytype <command>');
    print('Commands: create, sync, read');
  }
}
