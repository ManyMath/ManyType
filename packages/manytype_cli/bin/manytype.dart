import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/models.dart';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/account_resolver.dart';
import 'package:manytype_cli/src/active_account.dart';
import 'package:manytype_cli/src/commands/account.dart';
import 'package:manytype_cli/src/commands/account_delete.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/delete.dart';
import 'package:manytype_cli/src/commands/edit.dart';
import 'package:manytype_cli/src/commands/acl_lifecycle.dart';
import 'package:manytype_cli/src/commands/consensus_flow.dart';
import 'package:manytype_cli/src/commands/list.dart';
import 'package:manytype_cli/src/commands/file_transfer.dart';
import 'package:manytype_cli/src/commands/probe_file_node.dart';
import 'package:manytype_cli/src/commands/probe_network.dart';
import 'package:manytype_cli/src/commands/read.dart';
import 'package:manytype_cli/src/commands/space_delete.dart';
import 'package:manytype_cli/src/commands/space_pull_flow.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';

/// Handles the `manytype account <subcommand>` command group: parses the
/// subcommand's args, calls the typed `commands/account.dart` functions,
/// and prints/sets `exitCode` for the CLI.
Future<void> _runAccountCommand(
  ArgResults command, {
  String? envAccountId,
}) async {
  final sub = command.command;
  if (sub == null) {
    stderr.writeln(
      'Usage: manytype account <create|list|use|current|remove> [options]',
    );
    exitCode = 1;
    return;
  }

  try {
    // Register a legacy single-account install first, so account commands
    // neither hide it nor orphan it by creating the first profile.
    await migrateLegacyAccountIfPresent();
    switch (sub.name) {
      case 'create':
        final result = await createAccountCommand(name: sub['name'] as String?);
        print('Created account "${result.displayName}" (${result.id})');
        print('Mnemonic saved to ${result.configPath}');
        if (result.isCurrent) {
          print('Selected as the current account.');
        }
        break;

      case 'list':
        final accounts = await listAccountsCommand();
        if (accounts.isEmpty) {
          print('No accounts. Run: manytype account create --name <name>');
          break;
        }
        final currentId = await AccountRegistry.getCurrentAccountId();
        for (final account in accounts) {
          final marker = account.id == currentId ? '* ' : '  ';
          print('$marker${account.displayName}\t${account.id}');
        }
        break;

      case 'use':
        if (sub.rest.isEmpty) {
          stderr.writeln('Usage: manytype account use <id|name>');
          exitCode = 1;
          break;
        }
        final result = await useAccountCommand(sub.rest.first);
        print('Current account set to ${result.id}');
        break;

      case 'current':
        final summary = await currentAccountCommand(envAccountId: envAccountId);
        print('${summary.displayName}\t${summary.id}');
        break;

      case 'remove':
        if (sub.rest.isEmpty) {
          stderr.writeln('Usage: manytype account remove <id>');
          exitCode = 1;
          break;
        }
        final result = await removeAccountCommand(sub.rest.first);
        print(
          'Removed local account profile ${result.id} (local profile only '
          ':  this does not run the protocol-level AccountDelete coordinator '
          'operation).',
        );
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
  } on StateError catch (e) {
    stderr.writeln('Error: ${e.message}');
    exitCode = 1;
  }
}

/// Print an [EditResult] in the CLI's human-readable format.
void _printEditResult(EditResult result) {
  print('Edited object: ${result.objectId}');
  if (result.textChangeId != null) print('Text change: ${result.textChangeId}');
  if (result.blockChangeId != null) {
    print('Block change: ${result.blockChangeId}');
  }
  if (result.relationChangeId != null) {
    final fileRelationResult = result.fileRelationResult;
    if (fileRelationResult != null) {
      final mimeSuffix = _hasSpecificMime(fileRelationResult.mime)
          ? ' (${fileRelationResult.mime})'
          : '';
      print(
        'Relation change: ${result.relationChangeId} '
        '(${result.relationKey} = ${fileRelationResult.fileObjectId})',
      );
      print(
        'FileObject: ${fileRelationResult.fileObjectId} '
        '[${fileRelationResult.fileName}$mimeSuffix, '
        'cid=${fileRelationResult.cid}, '
        '${fileRelationResult.uploaded ? "uploaded" : "existing-blob"}]',
      );
    } else if (result.relationStringValue != null) {
      print(
          'Set detail: ${result.relationKey} = ${result.relationStringValue}');
    } else if (result.relationStringListValue != null) {
      print(
        'Set detail list: ${result.relationKey} = '
        '[${result.relationStringListValue!.join(", ")}]',
      );
    } else if (result.relationStatus != null) {
      print('Set status: ${result.relationKey} = ${result.relationStatus}');
    } else if (result.relationTagIds != null) {
      final tagIds = result.relationTagIds!;
      print(
        'Set tag: ${result.relationKey} = [${tagIds.join(", ")}] '
        '(full replace, ${tagIds.length} values)',
      );
    } else if (result.relationTagAdds.isNotEmpty ||
        result.relationTagRemoves.isNotEmpty) {
      print(
        'Updated tag: ${result.relationKey} '
        '(added: ${result.relationTagAdds.join(", ")}; '
        'removed: ${result.relationTagRemoves.join(", ")})',
      );
    } else {
      final displayValue = result.relationBoolValue ??
          result.relationDateValue ??
          result.relationObjectIdValue ??
          '';
      print(
        'Relation change: ${result.relationChangeId} '
        '(${result.relationKey} = $displayValue)',
      );
    }
  }
  if (result.blockUpdateChangeId != null) {
    print(
      'Block update: ${result.blockUpdateChangeId} '
      '(block-id=${result.blockId}, ${result.blockUpdateDescription})',
    );
  }
  if (result.collectionChangeDescription != null) {
    if (result.collectionChangeId != null) {
      print(
        'Collection change: ${result.collectionChangeId} '
        '(${result.collectionChangeDescription})',
      );
    } else {
      print('Collection change: no-op (${result.collectionChangeDescription})');
    }
  }
}

bool _hasSpecificMime(String mime) =>
    mime.isNotEmpty && mime != 'application/octet-stream';

/// Print a [SpaceDeleteReport] in the CLI's human-readable format.
void _printSpaceDeleteReport(SpaceDeleteReport report) {
  final initialPre =
      _spaceStatusLabel(report.initial['pre_status'] as Map<String, Object?>);
  final initialPost = _spaceStatusLabel(
    report.initial['post_status'] as Map<String, Object?>,
  );
  final reconnectStatus = _spaceStatusLabel(
    report.afterReconnect['status'] as Map<String, Object?>,
  );

  print('Command: space-delete');
  print('Space: ${report.spaceId}');
  print('Reference environment: $kAcceptedSpaceDeleteTruthSurface');
  print('Proof mode: $kAcceptedSpaceDeleteProofMode');
  print(
      'Observed status path: $initialPre -> $initialPost -> $reconnectStatus');
  print('Outcome: ${report.assessment.outcome}');
  print('Reason: ${report.assessment.reason}');
}

/// Print an [AccountDeleteReport] in the CLI's human-readable format.
void _printAccountDeleteReport(AccountDeleteReport report) {
  print('Command: account-delete');
  print('Outcome: ${report.assessment.outcome}');
  print('Reason: ${report.assessment.reason}');
}

String _spaceStatusLabel(Map<String, Object?> statusResult) {
  if (statusResult['ok'] != true) {
    return 'error';
  }
  final value = statusResult['value'];
  if (value == null) {
    return 'unknown';
  }
  final valueMap = value as Map;
  return valueMap['status']?.toString() ?? 'unknown';
}

/// Print an aligned three-column table of object metadata.
void _printObjectTable(List<ObjectMeta> metas) {
  if (metas.isEmpty) {
    print('No objects found.');
    return;
  }

  var idWidth = 'ID'.length;
  var typeWidth = 'TYPE'.length;
  for (final meta in metas) {
    if (meta.id.length > idWidth) idWidth = meta.id.length;
    if (meta.displayType.length > typeWidth) {
      typeWidth = meta.displayType.length;
    }
  }

  print('${"ID".padRight(idWidth)}  ${"TYPE".padRight(typeWidth)}  NAME');
  for (final meta in metas) {
    print(
      '${meta.id.padRight(idWidth)}  '
      '${meta.displayType.padRight(typeWidth)}  '
      '${meta.displayName}',
    );
  }
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('server',
        help: 'Server address (overrides config)', defaultsTo: null)
    ..addOption('network-config',
        help: 'Path to an any-sync client.yml network config', defaultsTo: null)
    ..addOption('account',
        help:
            'Account id or name to operate against (overrides current selection)',
        defaultsTo: null);

  final createParser = ArgParser()
    ..addFlag('sync', negatable: false, help: 'Sync after creating the object')
    ..addFlag('checkbox', negatable: false, help: 'Add a checkbox block')
    ..addFlag('numbered-list',
        negatable: false, help: 'Add a numbered list block')
    ..addFlag('toggle', negatable: false, help: 'Add a toggle block')
    ..addFlag('quote', negatable: false, help: 'Add a quote block')
    ..addFlag('callout', negatable: false, help: 'Add a callout block')
    ..addFlag('as-type',
        negatable: false, help: 'Create a custom object type (STType)')
    ..addFlag('as-relation',
        negatable: false, help: 'Create a custom relation (STRelation)')
    ..addFlag('as-set',
        negatable: false, help: 'Create a set object with Dataview')
    ..addFlag('as-collection',
        negatable: false, help: 'Create a collection object with Dataview')
    ..addFlag('as-template',
        negatable: false, help: 'Create a template object bound to an STType')
    ..addFlag('as-relation-option',
        negatable: false,
        help:
            'Create an STRelationOption SmartBlock bound to a parent relation')
    ..addOption('template',
        help:
            'Apply an existing template when creating a new object (template object ID)')
    ..addOption('for-relation',
        help:
            'Parent relation key (e.g. "status", "tag"): required with --as-relation-option')
    ..addOption('target-object-type',
        help: 'Target STType object ID: required with --as-template')
    ..addOption('color',
        help:
            'Option color: one of: default, grey, yellow, orange, red, pink, purple, blue, ice, teal, lime')
    ..addOption('name', help: 'Name for type/relation/set objects')
    ..addOption('format',
        help:
            'Relation format: text, number, date, file, checkbox, url, email, phone, object, status, tag')
    ..addOption('source-type', help: 'Source type key for set (e.g. ot-page)');
  final readParser = ArgParser()
    ..addFlag('sync', negatable: false, help: 'Sync before reading the object');
  final editParser = ArgParser()
    ..addOption('id',
        help: 'Object ID to edit (from manytype read output)', mandatory: true)
    ..addOption('text', help: 'New text content for the object')
    ..addFlag('checkbox', negatable: false, help: 'Add a checkbox block')
    ..addOption('relation', help: 'Relation key to set')
    ..addOption('string', help: 'String detail value')
    ..addOption('string-list', help: 'Comma-separated string-list detail value')
    ..addOption('bool', help: 'Bool relation value: true or false')
    ..addOption('date', help: 'Unix timestamp for date relation')
    ..addOption('file-relation',
        help: 'Source file path for a file-format relation value')
    ..addOption('object-id', help: 'Object ID for object-ref relation')
    ..addOption('block-id',
        help: 'Target block ID for in-place mutation (BlockUpdate)')
    ..addOption('set-text', help: "Rewrite the target block's text content")
    ..addOption('set-checked',
        help: 'Set the target checkbox block state: true or false')
    ..addOption('set-style',
        help: "Change the target block's style (one of: paragraph, "
            'header1, header2, header3, checkbox, numbered, toggle, '
            'quote, callout)')
    ..addOption('collection-add',
        help: 'Add this object ID to the target collection')
    ..addOption('collection-remove',
        help: 'Remove this object ID from the target collection')
    ..addOption('collection-move',
        help: 'Move this object ID within the target collection')
    ..addOption('after',
        help:
            'Insert moved collection member after this object ID; use empty string to move to front')
    ..addOption('status',
        help:
            'Set a status-relation value to this STRelationOption ID (use with --relation)')
    ..addOption('tag',
        help:
            'Set a tag-relation value to this comma-separated list of STRelationOption IDs (full replace; use with --relation)')
    ..addMultiOption('tag-add',
        help:
            'Append an STRelationOption ID to a tag-relation (idempotent; use with --relation, may repeat)')
    ..addMultiOption('tag-remove',
        help:
            'Remove an STRelationOption ID from a tag-relation (idempotent; use with --relation, may repeat)');
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
        help: 'Object ID to delete (from manytype read output)',
        mandatory: true);
  final spaceDeleteParser = ArgParser()
    ..addOption('space-id',
        help:
            'Space ID to delete; must match the current owner space, which is the default')
    ..addOption('wait-seconds',
        defaultsTo: '6',
        help:
            'Seconds to wait before reconnecting and checking status (default: 6)')
    ..addOption('deletion-duration-minutes',
        defaultsTo: '0',
        help: 'Deletion duration sent to the coordinator request (default: 0)')
    ..addFlag('json',
        negatable: false,
        help: 'Emit the structured space-delete report as JSON');
  final accountDeleteParser = ArgParser()
    ..addFlag('json',
        negatable: false,
        help: 'Emit the structured account-delete report as JSON');
  final listParser = ArgParser()
    ..addOption('type', help: 'Filter by object type key (e.g. ot-page)')
    ..addOption('where', help: 'Filter by relation key=value (e.g. done=true)');
  final aclLifecycleParser = ArgParser()
    ..addFlag('json', negatable: false, help: 'Emit JSON output');
  final consensusBootstrapParser = ArgParser()
    ..addOption('state-out',
        help: 'Optional path to write continuation state JSON')
    ..addFlag('json', negatable: false, help: 'Emit JSON output');
  final consensusContinueParser = ArgParser()
    ..addOption('state-in',
        help: 'Path to the continuation state JSON', mandatory: true)
    ..addFlag('json', negatable: false, help: 'Emit JSON output');
  final spacePullBootstrapParser = ArgParser()
    ..addOption('state-out',
        help: 'Optional path to write continuation state JSON')
    ..addFlag('json', negatable: false, help: 'Emit JSON output');
  final spacePullRefetchParser = ArgParser()
    ..addOption('state-in',
        help: 'Path to the continuation state JSON', mandatory: true)
    ..addFlag('json', negatable: false, help: 'Emit JSON output');
  parser.addCommand('create', createParser);
  parser.addCommand('sync');
  parser.addCommand('read', readParser);
  parser.addCommand('edit', editParser);
  parser.addCommand('delete', deleteParser);
  parser.addCommand('space-delete', spaceDeleteParser);
  parser.addCommand('account-delete', accountDeleteParser);
  parser.addCommand('acl-lifecycle', aclLifecycleParser);
  parser.addCommand('consensus-bootstrap', consensusBootstrapParser);
  parser.addCommand('consensus-continue', consensusContinueParser);
  parser.addCommand('space-pull-bootstrap', spacePullBootstrapParser);
  parser.addCommand('space-pull-refetch', spacePullRefetchParser);
  parser.addCommand('list', listParser);
  parser.addCommand(
    'init',
    ArgParser()
      ..addFlag('force',
          negatable: false,
          help: 'Overwrite an existing config.toml, replacing its mnemonic'),
  );
  parser.addCommand('file-upload', fileUploadParser);
  parser.addCommand('file-open', fileOpenParser);
  parser.addCommand('probe-network');
  parser.addCommand('probe-file-node', probeFileNodeParser);
  parser.addCommand('account', buildAccountParser());

  final results = parser.parse(arguments);

  if (results['help'] == true || results.command == null) {
    print('Usage: manytype <command> [options]');
    print(
      'Commands: init, account, create, sync, read, edit, delete, list, '
      'file-upload, file-open, probe-network, probe-file-node, space-delete, '
      'account-delete, acl-lifecycle, consensus-bootstrap, consensus-continue, '
      'space-pull-bootstrap, space-pull-refetch',
    );
    print(parser.usage);
    return;
  }

  final command = results.command!;
  final serverOverride = results['server'] as String?;
  final networkConfigPath = results['network-config'] as String?;
  final accountOverride = results['account'] as String?;
  final envAccountId = Platform.environment['MANYTYPE_ACCOUNT'];

  switch (command.name) {
    case 'account':
      await _runAccountCommand(command, envAccountId: envAccountId);
      break;

    case 'init':
      await CliConfig.initialize(force: command['force'] == true);
      print('Initialized ~/.manytype/');
      print('Mnemonic saved to ${CliConfig.configPath}');
      break;

    case 'create':
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      final db = ManytypeDatabase(active.dbPath);
      final text =
          command.rest.isNotEmpty ? command.rest.join(' ') : 'Untitled';
      final asType = command['as-type'] == true;
      final asRelation = command['as-relation'] == true;
      final asSet = command['as-set'] == true;
      final asCollection = command['as-collection'] == true;
      final asTemplate = command['as-template'] == true;
      final asRelationOption = command['as-relation-option'] == true;
      final templateId = command['template'] as String?;
      final name = command['name'] as String?;
      final format = command['format'] as String?;
      final sourceType = command['source-type'] as String?;
      final forRelation = command['for-relation'] as String?;
      final targetObjectType = command['target-object-type'] as String?;
      final colorArg = command['color'] as String?;

      if ([
            asType,
            asRelation,
            asSet,
            asCollection,
            asTemplate,
            asRelationOption
          ].where((f) => f).length >
          1) {
        throw StateError(
          '--as-type, --as-relation, --as-set, --as-collection, '
          '--as-template, and '
          '--as-relation-option are '
          'mutually exclusive',
        );
      }
      if ((asType ||
              asRelation ||
              asSet ||
              asCollection ||
              asTemplate ||
              asRelationOption) &&
          name == null) {
        throw StateError(
          '--as-type, --as-relation, --as-set, --as-collection, '
          '--as-template, and '
          '--as-relation-option require --name',
        );
      }
      if (templateId != null &&
          [
            asType,
            asRelation,
            asSet,
            asCollection,
            asTemplate,
            asRelationOption
          ].any((f) => f)) {
        throw StateError(
          '--template cannot be combined with any --as-* creation mode',
        );
      }
      if (templateId != null &&
          (command['checkbox'] == true ||
              command['numbered-list'] == true ||
              command['toggle'] == true ||
              command['quote'] == true ||
              command['callout'] == true)) {
        throw StateError(
          '--template cannot be combined with block scaffold flags',
        );
      }
      if (templateId != null && name != null) {
        throw StateError(
          '--name cannot be combined with --template; use positional text instead',
        );
      }
      if (asTemplate) {
        if (targetObjectType == null || targetObjectType.isEmpty) {
          throw StateError(
            '--as-template requires --target-object-type <stTypeObjectId>',
          );
        }
      } else if (targetObjectType != null) {
        throw StateError('--target-object-type requires --as-template');
      }

      // Phase 38: create --as-relation-option validation
      if (asRelationOption) {
        if (forRelation == null || forRelation.isEmpty) {
          throw StateError(
            '--as-relation-option requires --for-relation <relationKey>',
          );
        }
        if (colorArg == null || colorArg.isEmpty) {
          throw StateError(
            '--as-relation-option requires --color <name> (one of: '
            '${optionColorPalette.join(", ")})',
          );
        }
        if (!optionColorPalette.contains(colorArg)) {
          throw StateError(
            '--color "$colorArg" is not in the Anytype palette. Accepted: '
            '${optionColorPalette.join(", ")}',
          );
        }
      } else {
        if (forRelation != null) {
          throw StateError('--for-relation requires --as-relation-option');
        }
        if (colorArg != null) {
          throw StateError('--color requires --as-relation-option');
        }
      }

      final createResult = await createCommand(
        text,
        db,
        config,
        checkbox: command['checkbox'] == true,
        numberedList: command['numbered-list'] == true,
        toggle: command['toggle'] == true,
        quote: command['quote'] == true,
        callout: command['callout'] == true,
        asType: asType,
        asRelation: asRelation,
        asSet: asSet,
        asCollection: asCollection,
        asTemplate: asTemplate,
        asRelationOption: asRelationOption,
        name: name,
        format: format,
        sourceType: sourceType,
        forRelation: forRelation,
        targetObjectType: targetObjectType,
        templateId: templateId,
        color: colorArg,
        textProvided: command.rest.isNotEmpty,
      );
      if (createResult.spaceInitialized) {
        print('Initialized space: ${createResult.spaceId}');
      }
      if (createResult.appendedOption != null) {
        final appended = createResult.appendedOption!;
        print(
          'Appended option ${createResult.objectId} to STRelation '
          '${appended.parentStRelationId} (selectDict now has '
          '${appended.selectDictSize} entries)',
        );
      }
      print('Created ${createResult.objectKind}: ${createResult.objectId}');
      print('Text: ${createResult.displayName}');
      print('Changes: ${createResult.changeCount} (root + snapshot)');
      await db.close();

      if (command['sync'] == true) {
        if (networkConfigPath == null) {
          throw StateError(
            'create --sync requires --network-config <path>',
          );
        }
        final db = ManytypeDatabase(active.dbPath);
        await syncCommand(db, config, networkConfigPath: networkConfigPath);
        await db.close();
      }
      break;

    case 'sync':
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      final db = ManytypeDatabase(active.dbPath);
      await syncCommand(db, config, networkConfigPath: networkConfigPath);
      await db.close();
      break;

    case 'read':
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;

      if (command['sync'] == true) {
        if (networkConfigPath == null) {
          throw StateError(
            'read --sync requires --network-config <path>',
          );
        }
        final syncDb = ManytypeDatabase(active.dbPath);
        await syncCommand(syncDb, config, networkConfigPath: networkConfigPath);
        await syncDb.close();
      }

      final db = ManytypeDatabase(active.dbPath);
      final objId = command.rest.isNotEmpty ? command.rest.first : null;
      try {
        final readResult = await readCommand(db, config, objectId: objId);
        final readLines = readResult.listing?.lines ?? readResult.detail!.lines;
        readLines.forEach(print);
      } on ObjectUnavailableError catch (e) {
        print(e.message);
        exitCode = 1;
      }
      await db.close();
      break;

    case 'edit':
      final objectId = command['id'] as String;
      final hasCheckbox = command['checkbox'] == true;
      final newText = command['text'] as String?;
      final relationKey = command['relation'] as String?;
      final stringValue = command['string'] as String?;
      final stringListArg = command['string-list'] as String?;
      final boolValue = (command['bool'] as String?)?.toLowerCase();
      final dateValue = command['date'] as String?;
      final fileRelationPath = command['file-relation'] as String?;
      final objectIdValue = command['object-id'] as String?;

      // Phase 38: status/tag relation-value flags.
      final statusArg = command['status'] as String?;
      final tagArg = command['tag'] as String?;
      final collectionAddId = command['collection-add'] as String?;
      final collectionRemoveId = command['collection-remove'] as String?;
      final collectionMoveId = command['collection-move'] as String?;
      final afterArg = command['after'] as String?;
      final tagAddList =
          (command['tag-add'] as List?)?.cast<String>() ?? const <String>[];
      final tagRemoveList =
          (command['tag-remove'] as List?)?.cast<String>() ?? const <String>[];

      final hasStatus = statusArg != null;
      final hasTag = tagArg != null;
      final hasTagDelta = tagAddList.isNotEmpty || tagRemoveList.isNotEmpty;
      final List<String>? stringListValue;
      if (stringListArg != null) {
        stringListValue = stringListArg
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        stringListValue = null;
      }

      // Parse tag full-replace list.
      final List<String>? tagIds;
      if (hasTag) {
        tagIds = tagArg
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        tagIds = null;
      }

      // Validate relation flags.
      if (relationKey != null) {
        // Run mutex checks BEFORE the "exactly one" count so the more
        // specific error messages surface when multiple value types collide.
        // --status is mutex with --bool / --date / --object-id.
        if (hasStatus &&
            (stringValue != null ||
                stringListValue != null ||
                boolValue != null ||
                dateValue != null ||
                fileRelationPath != null ||
                objectIdValue != null)) {
          throw StateError(
            '--status is mutex with --string, --string-list, --bool, --date, '
            '--file-relation, and --object-id',
          );
        }
        // --tag is mutex with --tag-add / --tag-remove.
        if (hasTag && hasTagDelta) {
          throw StateError(
            '--tag is mutex with --tag-add and --tag-remove (use one or the other)',
          );
        }
        // --status and --tag/--tag* are mutex with each other.
        if (hasStatus && (hasTag || hasTagDelta)) {
          throw StateError(
            '--status is mutex with --tag / --tag-add / --tag-remove',
          );
        }
        // --tag/--tag* is mutex with --bool / --date / --object-id.
        if ((hasTag || hasTagDelta) &&
            (stringValue != null ||
                stringListValue != null ||
                boolValue != null ||
                dateValue != null ||
                fileRelationPath != null ||
                objectIdValue != null)) {
          throw StateError(
            '--tag / --tag-add / --tag-remove are mutex with --string, '
            '--string-list, --bool, --date, --file-relation, and --object-id',
          );
        }

        final typedCount = [
          stringValue,
          stringListValue != null ? '__string_list__' : null,
          boolValue,
          dateValue,
          fileRelationPath,
          objectIdValue,
          hasStatus ? statusArg : null,
          hasTag ? tagArg : null,
          hasTagDelta ? 'delta' : null,
        ].where((v) => v != null).length;
        if (typedCount != 1) {
          throw StateError(
            '--relation requires exactly one of --string, --string-list, '
            '--bool, --date, --file-relation, --object-id, --status, --tag, or '
            '--tag-add/--tag-remove',
          );
        }
      } else if (stringValue != null ||
          stringListValue != null ||
          boolValue != null ||
          dateValue != null ||
          fileRelationPath != null ||
          objectIdValue != null) {
        throw StateError(
          '--string, --string-list, --bool, --date, --file-relation, and '
          '--object-id require --relation <key>',
        );
      } else if (hasStatus || hasTag || hasTagDelta) {
        throw StateError(
          '--status / --tag / --tag-add / --tag-remove require --relation <key>',
        );
      }

      // Validate BlockUpdate flags (exactly one of set-text/set-checked/set-style
      // when --block-id is present, and each set-* requires --block-id).
      final blockId = command['block-id'] as String?;
      final setTextArg = command['set-text'] as String?;
      final setCheckedRaw = command['set-checked'] as String?;
      final setStyleName = command['set-style'] as String?;

      final setCount = [setTextArg, setCheckedRaw, setStyleName]
          .where((v) => v != null)
          .length;

      if (blockId != null) {
        if (setCount != 1) {
          throw StateError(
            '--block-id requires exactly one of --set-text, --set-checked, or --set-style',
          );
        }
      } else if (setCount > 0) {
        throw StateError(
          '--set-text, --set-checked, and --set-style require --block-id <id>',
        );
      }

      bool? setChecked;
      if (setCheckedRaw != null) {
        if (setCheckedRaw != 'true' && setCheckedRaw != 'false') {
          throw StateError('--set-checked must be "true" or "false"');
        }
        setChecked = setCheckedRaw == 'true';
      }
      if (boolValue != null && boolValue != 'true' && boolValue != 'false') {
        throw StateError('--bool must be "true" or "false"');
      }
      if (dateValue != null && int.tryParse(dateValue) == null) {
        throw StateError('--date must be a Unix timestamp in seconds');
      }

      Block_Content_Text_Style? setStyle;
      if (setStyleName != null) {
        setStyle = parseStyleName(setStyleName);
        if (setStyle == null) {
          throw StateError(
            '--set-style must be one of: ${acceptedStyleNames.join(", ")}',
          );
        }
      }

      final collectionCount = [
        collectionAddId,
        collectionRemoveId,
        collectionMoveId,
      ].where((v) => v != null).length;
      if (collectionCount > 1) {
        throw StateError(
          '--collection-add, --collection-remove, and --collection-move are mutually exclusive',
        );
      }
      if (collectionMoveId != null && afterArg == null) {
        throw StateError(
          '--collection-move requires --after <objectId> (use --after "" to move to front)',
        );
      }
      if (collectionMoveId == null && afterArg != null) {
        throw StateError('--after requires --collection-move');
      }
      if (collectionCount > 0 &&
          (newText != null ||
              hasCheckbox ||
              relationKey != null ||
              blockId != null)) {
        throw StateError(
          '--collection-add / --collection-remove / --collection-move are mutex with --text, --checkbox, --relation, and --block-id',
        );
      }

      if (newText == null &&
          !hasCheckbox &&
          relationKey == null &&
          blockId == null &&
          collectionCount == 0) {
        throw StateError(
          'edit requires --text, --checkbox, --relation, --block-id, or a collection operation',
        );
      }

      if (networkConfigPath == null) {
        throw StateError(
          'edit requires --network-config <path>',
        );
      }
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      final db = ManytypeDatabase(active.dbPath);
      final editResult = await editCommand(objectId, newText, db, config,
          networkConfigPath: networkConfigPath,
          checkbox: hasCheckbox,
          checkboxText: hasCheckbox
              ? (command.rest.isNotEmpty ? command.rest.join(' ') : 'Todo')
              : null,
          relationKey: relationKey,
          stringValue: stringValue,
          stringListValue: stringListValue,
          boolValue: boolValue,
          dateValue: dateValue,
          fileRelationPath: fileRelationPath,
          objectIdValue: objectIdValue,
          blockId: blockId,
          setText: setTextArg,
          setChecked: setChecked,
          setStyle: setStyle,
          status: statusArg,
          tagIds: tagIds,
          tagAdds: tagAddList,
          tagRemoves: tagRemoveList,
          collectionAddId: collectionAddId,
          collectionRemoveId: collectionRemoveId,
          collectionMoveId: collectionMoveId,
          afterId: afterArg ?? '');
      _printEditResult(editResult);
      await db.close();
      break;

    case 'delete':
      if (networkConfigPath == null) {
        throw StateError(
          'delete requires --network-config <path>',
        );
      }
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      final db = ManytypeDatabase(active.dbPath);
      final deleteResult = await deleteCommand(
        command['id'] as String,
        db,
        config,
        networkConfigPath: networkConfigPath,
      );
      print('Deleted ${deleteResult.objectId}');
      await db.close();
      break;

    case 'list':
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      final db = ManytypeDatabase(active.dbPath);
      final results = await listCommand(
        db,
        config,
        networkConfigPath: networkConfigPath,
        typeFilter: command['type'] as String?,
        whereFilter: command['where'] as String?,
      );
      _printObjectTable(results);
      await db.close();
      break;

    case 'space-delete':
      if (networkConfigPath == null) {
        throw StateError(
          'space-delete requires --network-config <path>',
        );
      }
      final waitSecondsRaw = command['wait-seconds'] as String;
      final deletionDurationRaw =
          command['deletion-duration-minutes'] as String;
      final waitSeconds = int.tryParse(waitSecondsRaw);
      final deletionDurationMinutes = int.tryParse(deletionDurationRaw);
      if (waitSeconds == null) {
        throw StateError('--wait-seconds must be an integer');
      }
      if (deletionDurationMinutes == null) {
        throw StateError('--deletion-duration-minutes must be an integer');
      }
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      final spaceDeleteReport = await spaceDeleteCommand(
        config: config,
        networkConfigPath: networkConfigPath,
        requestedSpaceId: command['space-id'] as String?,
        waitSeconds: waitSeconds,
        deletionDurationMinutes: deletionDurationMinutes,
      );
      if (command['json'] == true) {
        print(
          const JsonEncoder.withIndent('  ')
              .convert(spaceDeleteReport.toJson()),
        );
      } else {
        _printSpaceDeleteReport(spaceDeleteReport);
      }
      if (!spaceDeleteReport.assessment.supported) {
        exit(2);
      }
      break;

    case 'account-delete':
      if (networkConfigPath == null) {
        throw StateError(
          'account-delete requires --network-config <path>',
        );
      }
      final activeForAccountDelete = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final accountDeleteReport = await accountDeleteCommand(
        config: activeForAccountDelete.config,
        networkConfigPath: networkConfigPath,
      );
      if (command['json'] == true) {
        print(
          const JsonEncoder.withIndent('  ')
              .convert(accountDeleteReport.toJson()),
        );
      } else {
        _printAccountDeleteReport(accountDeleteReport);
      }
      if (!accountDeleteReport.assessment.supported) {
        exit(2);
      }
      break;

    case 'acl-lifecycle':
      if (networkConfigPath == null) {
        throw StateError(
          'acl-lifecycle requires --network-config <path>',
        );
      }
      final aclLifecycleReport = await aclLifecycleCommand(
        networkConfigPath: networkConfigPath,
      );
      if (command['json'] == true) {
        stdout.writeln(
          const JsonEncoder.withIndent('  ')
              .convert(aclLifecycleReport.toJson()),
        );
      } else {
        stdout.writeln('Command: acl-lifecycle');
        stdout.writeln('Backend: $kAclLifecycleBackendLabel');
        stdout.writeln('Space: ${aclLifecycleReport.spaceId}');
        stdout.writeln('ACL root: ${aclLifecycleReport.aclRootId}');
        stdout.writeln('Invite record: ${aclLifecycleReport.inviteRecordId}');
        stdout.writeln('Join record: ${aclLifecycleReport.joinRecordId}');
        stdout.writeln('Accept record: ${aclLifecycleReport.acceptRecordId}');
        stdout.writeln(
          'Joiner permission: ${aclLifecycleReport.joinerPermission}',
        );
        stdout.writeln('Joiner status: ${aclLifecycleReport.joinerStatus}');
      }
      break;

    case 'consensus-bootstrap':
      final consensusBootstrapReport = await consensusBootstrapCommand(
        serverAddress: serverOverride ?? '127.0.0.1:33020',
        stateOut: command['state-out'] as String?,
      );
      if (command['json'] == true) {
        stdout.writeln(
          const JsonEncoder.withIndent('  ')
              .convert(consensusBootstrapReport.toJson()),
        );
      } else {
        stdout.writeln('Command: consensus-bootstrap');
        stdout.writeln('Backend: $kConsensusBackendLabel');
        stdout.writeln('Log: ${consensusBootstrapReport.logId}');
        stdout.writeln('Root: ${consensusBootstrapReport.rootId}');
        stdout.writeln(
          'First record: ${consensusBootstrapReport.firstRecordId}',
        );
        if (consensusBootstrapReport.statePath != null &&
            consensusBootstrapReport.statePath!.isNotEmpty) {
          stdout.writeln('State: ${consensusBootstrapReport.statePath}');
        }
      }
      break;

    case 'consensus-continue':
      final consensusContinueReport = await consensusContinueCommand(
        serverOverride: serverOverride,
        stateIn: command['state-in'] as String,
      );
      if (command['json'] == true) {
        stdout.writeln(
          const JsonEncoder.withIndent('  ')
              .convert(consensusContinueReport.toJson()),
        );
      } else {
        stdout.writeln('Command: consensus-continue');
        stdout.writeln('Backend: $kConsensusBackendLabel');
        stdout.writeln('Log: ${consensusContinueReport.logId}');
        stdout.writeln(
          'Second record: ${consensusContinueReport.secondRecordId}',
        );
      }
      break;

    case 'space-pull-bootstrap':
      if (networkConfigPath == null) {
        throw StateError(
          'space-pull-bootstrap requires --network-config <path>',
        );
      }
      final spacePullBootstrapReport = await spacePullBootstrapCommand(
        networkConfigPath: networkConfigPath,
        serverAddress: serverOverride ?? '127.0.0.1:33020',
        stateOut: command['state-out'] as String?,
      );
      if (command['json'] == true) {
        stdout.writeln(
          const JsonEncoder.withIndent('  ')
              .convert(spacePullBootstrapReport.toJson()),
        );
      } else {
        stdout.writeln('Command: space-pull-bootstrap');
        stdout.writeln('Backend: $kSpacePullBackendLabel');
        stdout.writeln('Space: ${spacePullBootstrapReport.spaceId}');
        stdout.writeln('ACL root: ${spacePullBootstrapReport.aclRootId}');
        stdout.writeln(
          'Invite record: ${spacePullBootstrapReport.inviteRecordId}',
        );
        if (spacePullBootstrapReport.statePath != null &&
            spacePullBootstrapReport.statePath!.isNotEmpty) {
          stdout.writeln('State: ${spacePullBootstrapReport.statePath}');
        }
      }
      break;

    case 'space-pull-refetch':
      final spacePullRefetchReport = await spacePullRefetchCommand(
        serverOverride: serverOverride,
        stateIn: command['state-in'] as String,
      );
      if (command['json'] == true) {
        stdout.writeln(
          const JsonEncoder.withIndent('  ')
              .convert(spacePullRefetchReport.toJson()),
        );
      } else {
        stdout.writeln('Command: space-pull-refetch');
        stdout.writeln('Backend: $kSpacePullBackendLabel');
        stdout.writeln('Space: ${spacePullRefetchReport.spaceId}');
        stdout.writeln(
          'Invite record: ${spacePullRefetchReport.inviteRecordId}',
        );
      }
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
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      final db = ManytypeDatabase(active.dbPath);
      final uploadResult = await fileUploadCommand(
        db,
        config,
        networkConfigPath: networkConfigPath,
        fileId: fileId,
        sourcePath: command.rest.first,
      );
      print(
        uploadResult.uploaded
            ? 'Uploaded $fileId (cid=${uploadResult.cid})'
            : 'Skipped upload for $fileId (cid=${uploadResult.cid}) - blob already present',
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
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      final db = ManytypeDatabase(active.dbPath);
      final openResult = await fileOpenCommand(
        db,
        config,
        networkConfigPath: networkConfigPath,
        fileId: fileId,
        cid: command['cid'] as String?,
        outputPath: command['output'] as String?,
      );
      print(
        'Opened $fileId (${openResult.fromCache ? "cache" : "network"}) -> '
        '${openResult.outputPath}',
      );
      await db.close();
      break;

    case 'probe-network':
      if (networkConfigPath == null) {
        throw StateError(
          'probe-network requires --network-config <path>',
        );
      }
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      print('Connecting to coordinator...');
      final networkProbeResult = await probeNetworkCommand(
        config,
        networkConfigPath: networkConfigPath,
      );
      print('NetworkConfiguration exchange succeeded.');
      print('Network: ${networkProbeResult.networkId}');
      print('Configuration ID: ${networkProbeResult.configurationId}');
      print('Nodes returned: ${networkProbeResult.nodeCount}');
      break;

    case 'probe-file-node':
      if (networkConfigPath == null) {
        throw StateError(
          'probe-file-node requires --network-config <path>',
        );
      }
      final active = await resolveActiveAccount(
        accountOverride: accountOverride,
        envAccountId: envAccountId,
        serverOverride: serverOverride,
      );
      final config = active.config;
      print('Connecting to coordinator...');
      final probeResult = await probeFileNodeCommand(
        config,
        networkConfigPath: networkConfigPath,
        readOnly: command['read-only'] == true,
      );
      print('Resolved FileAPI node: ${probeResult.fileAddress}');
      print('File-node probe completed.');
      break;
  }
}
