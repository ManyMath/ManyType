import 'package:args/args.dart';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/models.dart';

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
    ..addFlag('sync', negatable: false, help: 'Sync after creating the object')
    ..addFlag('checkbox', negatable: false, help: 'Add a checkbox block')
    ..addFlag('numbered-list', negatable: false, help: 'Add a numbered list block')
    ..addFlag('toggle', negatable: false, help: 'Add a toggle block')
    ..addFlag('quote', negatable: false, help: 'Add a quote block')
    ..addFlag('callout', negatable: false, help: 'Add a callout block')
    ..addFlag('as-type', negatable: false, help: 'Create a custom object type (STType)')
    ..addFlag('as-relation', negatable: false, help: 'Create a custom relation (STRelation)')
    ..addFlag('as-set', negatable: false, help: 'Create a set object with Dataview')
    ..addFlag('as-relation-option',
        negatable: false,
        help: 'Create an STRelationOption SmartBlock bound to a parent relation')
    ..addOption('for-relation',
        help: 'Parent relation key (e.g. "status", "tag") — required with --as-relation-option')
    ..addOption('color',
        help: 'Option color — one of: default, grey, yellow, orange, red, pink, purple, blue, ice, teal, lime')
    ..addOption('name', help: 'Name for type/relation/set objects')
    ..addOption('format', help: 'Relation format: text, number, date, checkbox, url, email, phone, object')
    ..addOption('source-type', help: 'Source type key for set (e.g. ot-page)');
  final readParser = ArgParser()
    ..addFlag('sync', negatable: false, help: 'Sync before reading the object');
  final editParser = ArgParser()
    ..addOption('id',
        help: 'Object ID to edit (from manytype read output)', mandatory: true)
    ..addOption('text',
        help: 'New text content for the object')
    ..addFlag('checkbox', negatable: false, help: 'Add a checkbox block')
    ..addOption('relation', help: 'Relation key to set')
    ..addOption('bool', help: 'Bool relation value: true or false')
    ..addOption('date', help: 'Unix timestamp for date relation')
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
    ..addOption('status',
        help: 'Set a status-relation value to this STRelationOption ID (use with --relation)')
    ..addOption('tag',
        help: 'Set a tag-relation value to this comma-separated list of STRelationOption IDs (full replace; use with --relation)')
    ..addMultiOption('tag-add',
        help: 'Append an STRelationOption ID to a tag-relation (idempotent; use with --relation, may repeat)')
    ..addMultiOption('tag-remove',
        help: 'Remove an STRelationOption ID from a tag-relation (idempotent; use with --relation, may repeat)');
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
      final asType = command['as-type'] == true;
      final asRelation = command['as-relation'] == true;
      final asSet = command['as-set'] == true;
      final asRelationOption = command['as-relation-option'] == true;
      final name = command['name'] as String?;
      final format = command['format'] as String?;
      final sourceType = command['source-type'] as String?;
      final forRelation = command['for-relation'] as String?;
      final colorArg = command['color'] as String?;

      if ([asType, asRelation, asSet, asRelationOption].where((f) => f).length >
          1) {
        throw StateError(
          '--as-type, --as-relation, --as-set, and --as-relation-option are '
          'mutually exclusive',
        );
      }
      if ((asType || asRelation || asSet || asRelationOption) && name == null) {
        throw StateError(
          '--as-type, --as-relation, --as-set, and --as-relation-option '
          'require --name',
        );
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

      await createCommand(text, db, config,
        checkbox: command['checkbox'] == true,
        numberedList: command['numbered-list'] == true,
        toggle: command['toggle'] == true,
        quote: command['quote'] == true,
        callout: command['callout'] == true,
        asType: asType,
        asRelation: asRelation,
        asSet: asSet,
        asRelationOption: asRelationOption,
        name: name,
        format: format,
        sourceType: sourceType,
        forRelation: forRelation,
        color: colorArg,
      );
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
      final objectId = command['id'] as String;
      final hasCheckbox = command['checkbox'] == true;
      final newText = command['text'] as String?;
      final relationKey = command['relation'] as String?;
      final boolValue = command['bool'] as String?;
      final dateValue = command['date'] as String?;
      final objectIdValue = command['object-id'] as String?;

      // Phase 38: status/tag relation-value flags.
      final statusArg = command['status'] as String?;
      final tagArg = command['tag'] as String?;
      final tagAddList =
          (command['tag-add'] as List?)?.cast<String>() ?? const <String>[];
      final tagRemoveList =
          (command['tag-remove'] as List?)?.cast<String>() ?? const <String>[];

      final hasStatus = statusArg != null;
      final hasTag = tagArg != null;
      final hasTagDelta = tagAddList.isNotEmpty || tagRemoveList.isNotEmpty;

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
            (boolValue != null ||
                dateValue != null ||
                objectIdValue != null)) {
          throw StateError(
            '--status is mutex with --bool, --date, and --object-id',
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
            (boolValue != null ||
                dateValue != null ||
                objectIdValue != null)) {
          throw StateError(
            '--tag / --tag-add / --tag-remove are mutex with --bool, '
            '--date, and --object-id',
          );
        }

        final typedCount = [
          boolValue,
          dateValue,
          objectIdValue,
          hasStatus ? statusArg : null,
          hasTag ? tagArg : null,
          hasTagDelta ? 'delta' : null,
        ].where((v) => v != null).length;
        if (typedCount != 1) {
          throw StateError(
            '--relation requires exactly one of --bool, --date, --object-id, '
            '--status, --tag, or --tag-add/--tag-remove',
          );
        }
      } else if (boolValue != null ||
          dateValue != null ||
          objectIdValue != null) {
        throw StateError(
          '--bool, --date, and --object-id require --relation <key>',
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

      Block_Content_Text_Style? setStyle;
      if (setStyleName != null) {
        setStyle = parseStyleName(setStyleName);
        if (setStyle == null) {
          throw StateError(
            '--set-style must be one of: ${acceptedStyleNames.join(", ")}',
          );
        }
      }

      if (newText == null &&
          !hasCheckbox &&
          relationKey == null &&
          blockId == null) {
        throw StateError(
          'edit requires --text, --checkbox, --relation, or --block-id',
        );
      }

      if (networkConfigPath == null) {
        throw StateError(
          'edit requires --network-config <path>',
        );
      }
      final config = await CliConfig.load(serverOverride: serverOverride);
      final db = ManytypeDatabase(CliConfig.dbPath);
      await editCommand(objectId, newText, db, config,
          networkConfigPath: networkConfigPath,
          checkbox: hasCheckbox,
          checkboxText: hasCheckbox
              ? (command.rest.isNotEmpty ? command.rest.join(' ') : 'Todo')
              : null,
          relationKey: relationKey,
          boolValue: boolValue,
          dateValue: dateValue,
          objectIdValue: objectIdValue,
          blockId: blockId,
          setText: setTextArg,
          setChecked: setChecked,
          setStyle: setStyle,
          status: statusArg,
          tagIds: tagIds,
          tagAdds: tagAddList,
          tagRemoves: tagRemoveList);
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
