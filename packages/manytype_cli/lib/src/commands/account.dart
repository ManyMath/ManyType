import 'dart:io';

import 'package:args/args.dart';
import 'package:manytype_core/manytype_core.dart' show generateMnemonic;

import '../account_registry.dart';
import '../account_resolver.dart';

/// Handles the `manytype account <subcommand>` command group.
///
/// Local account-profile management only — `account remove` deletes a
/// profile's local directory and registry entry, it never performs the
/// protocol-level `AccountDelete` coordinator teardown operation.
Future<void> accountCommand(ArgResults command, {String? envAccountId}) async {
  final sub = command.command;
  if (sub == null) {
    stderr.writeln(
      'Usage: manytype account <create|list|use|current|remove> [options]',
    );
    exitCode = 1;
    return;
  }

  try {
    switch (sub.name) {
      case 'create':
        await _create(sub);
        break;
      case 'list':
        await _list();
        break;
      case 'use':
        await _use(sub);
        break;
      case 'current':
        await _current(envAccountId: envAccountId);
        break;
      case 'remove':
        await _remove(sub);
        break;
      default:
        stderr.writeln('Unknown account subcommand: ${sub.name}');
        exitCode = 1;
    }
  } on AmbiguousAccountError catch (e) {
    stderr.writeln('Error: ${e.message}');
    exitCode = 1;
  } on NoAccountError catch (e) {
    stderr.writeln('Error: ${e.message}');
    exitCode = 1;
  }
}

Future<void> _create(ArgResults sub) async {
  final name = sub['name'] as String? ?? 'default';
  final mnemonic = generateMnemonic();
  final profile = await AccountRegistry.createAccount(
    mnemonic: mnemonic,
    displayName: name,
  );

  final accounts = await AccountRegistry.listAccounts();
  if (accounts.length == 1) {
    await AccountRegistry.setCurrentAccountId(profile.id);
  }

  print('Created account "$name" (${profile.id})');
  print('Mnemonic saved to ${AccountRegistry.accountConfigPath(profile.id)}');
  if (accounts.length == 1) {
    print('Selected as the current account.');
  }
}

Future<void> _list() async {
  final accounts = await AccountRegistry.listAccounts();
  if (accounts.isEmpty) {
    print('No accounts. Run: manytype account create --name <name>');
    return;
  }
  final currentId = await AccountRegistry.getCurrentAccountId();
  for (final account in accounts) {
    final marker = account.id == currentId ? '* ' : '  ';
    print('$marker${account.displayName}\t${account.id}');
  }
}

Future<void> _use(ArgResults sub) async {
  if (sub.rest.isEmpty) {
    stderr.writeln('Usage: manytype account use <id|name>');
    exitCode = 1;
    return;
  }
  final idOrName = sub.rest.first;
  final resolvedId = await AccountResolver.resolveAccountId(
    explicitAccountId: idOrName,
  );
  await AccountRegistry.setCurrentAccountId(resolvedId);
  print('Current account set to $resolvedId');
}

Future<void> _current({String? envAccountId}) async {
  final resolvedId = await AccountResolver.resolveAccountId(
    envAccountId: envAccountId,
  );
  final accounts = await AccountRegistry.listAccounts();
  final summary = accounts.firstWhere((a) => a.id == resolvedId);
  print('${summary.displayName}\t${summary.id}');
}

Future<void> _remove(ArgResults sub) async {
  if (sub.rest.isEmpty) {
    stderr.writeln('Usage: manytype account remove <id>');
    exitCode = 1;
    return;
  }
  final id = sub.rest.first;
  final accounts = await AccountRegistry.listAccounts();
  if (accounts.every((a) => a.id != id)) {
    stderr.writeln('Error: No account found matching "$id".');
    exitCode = 1;
    return;
  }
  await AccountRegistry.removeAccount(id);
  print(
    'Removed local account profile $id (local profile only — this does not '
    'run the protocol-level AccountDelete coordinator operation).',
  );
}

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
