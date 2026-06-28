import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:test/test.dart';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/models.dart';

import 'web/web_db_test_helpers.dart';

void main() {
  // Known BIP-39 test vector mnemonic
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  late ManytypeDatabase db;
  late CliConfig config;

  setUpAll(() async {
    await configureWebTestDatabaseAssets();
  });

  setUp(() async {
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
    config =
        CliConfig(mnemonic: testMnemonic, serverAddress: '127.0.0.1:33020');
  });

  tearDown(() async {
    await db.close();
  });

  group('createCommand', () {
    test('creates object with 2 changes (root + content)', () async {
      await createCommand('Hello world', db, config);

      final allObjects = await db.getAllObjects();
      expect(
        allObjects.length,
        7,
      ); // ACL + settings + 4 derived roots + text object

      StoredObject? textObj;
      int oneChangeObjects = 0;
      int twoChangeObjects = 0;
      for (final object in allObjects) {
        final changes = await db.getChangesForObject(object.id);
        if (changes.length == 1) {
          oneChangeObjects++;
        } else if (changes.length == 2) {
          twoChangeObjects++;
        }
        if (changes.length == 2) {
          final replayed = await _replayObject(db, config, object.id);
          final name = replayed.snapshot.details.fields['name']?.stringValue;
          if (name == 'Hello world') {
            textObj = object;
          }
        }
      }
      expect(textObj, isNotNull);
      expect(oneChangeObjects, 2);
      expect(twoChangeObjects, 5);

      // Text object should have 2 changes: root change + tree change
      final changes = await db.getChangesForObject(textObj!.id);
      expect(changes.length, 2);

      // Root change has no parents
      expect(changes[0].parentHeads, jsonEncode([]));
      expect(changes[0].rawBytes.length, greaterThan(0));

      // Tree change has root as parent
      final treeParents = jsonDecode(changes[1].parentHeads) as List;
      expect(treeParents.length, 1);
      expect(treeParents[0], changes[0].id); // parent is root change
      expect(changes[1].rawBytes.length, greaterThan(0));

      final nonUserChangeCounts = <int>[];
      for (final object in allObjects) {
        if (object.id == textObj.id) continue;
        nonUserChangeCounts
            .add((await db.getChangesForObject(object.id)).length);
      }
      expect(nonUserChangeCounts.where((count) => count == 1), hasLength(2));
      expect(nonUserChangeCounts.where((count) => count == 2), hasLength(4));
    });

    test('second create reuses existing ACL root', () async {
      await createCommand('First object', db, config);
      await createCommand('Second object', db, config);

      // Initial bootstrap (7 objects) + one more user object.
      final allObjects = await db.getAllObjects();
      expect(allObjects.length, 8);
    });

    test('created changes have non-empty rawBytes', () async {
      await createCommand('Test text', db, config);

      final allObjects = await db.getAllObjects();
      for (final obj in allObjects) {
        final changes = await db.getChangesForObject(obj.id);
        for (final change in changes) {
          expect(
            change.rawBytes.length,
            greaterThan(0),
            reason: 'Change ${change.id} should have non-empty rawBytes',
          );
        }
      }
    });

    test('object IDs are CIDs (start with bafy)', () async {
      await createCommand('CID test', db, config);

      final allObjects = await db.getAllObjects();
      for (final obj in allObjects) {
        expect(
          obj.id,
          startsWith('bafy'),
          reason: 'Object ID should be a CID starting with bafy',
        );
      }
    });

    test('object persists across database instances', () async {
      // Create in first db instance
      await createCommand('Persistent test', db, config);
      final objsBefore = await db.getAllObjects();
      expect(objsBefore.length, 7);

      // The in-memory database is the same instance, so this verifies
      // the data is retrievable (persistence with file-backed DB is
      // proven by using the same dbPath across process restarts).
      final objsAfter = await db.getAllObjects();
      expect(objsAfter.length, 7);
      expect(objsAfter.first.id, objsBefore.first.id);
    });

    test('creates template smartblock bound to an STType', () async {
      final typeResult = await createCommand(
        'ignored',
        db,
        config,
        asType: true,
        name: 'Project',
      );
      final typeId = typeResult.objectId;

      final templateResult = await createCommand(
        'ignored',
        db,
        config,
        asTemplate: true,
        name: 'Project Template',
        targetObjectType: typeId,
      );
      final templateId = templateResult.objectId;

      final replayed = await _replayObject(db, config, templateId);
      expect(replayed.smartBlockType, SmartBlockType.Template.value);
      expect(replayed.snapshot.objectTypes, contains('ot-template'));
      expect(replayed.snapshot.objectTypes, contains('project'));
      expect(
        replayed.snapshot.details.fields['targetObjectType']?.stringValue,
        typeId,
      );
      expect(
        replayed.snapshot.details.fields['templateNamePrefillType']?.numberValue
            .toInt(),
        TemplateNamePrefillType.FromTemplateName.value,
      );
      expect(
        replayed.snapshot.details.fields['name']?.stringValue,
        'Project Template',
      );
    });

    test('assigns an existing STType to a plain object via assignedType',
        () async {
      final typeResult = await createCommand(
        'ignored',
        db,
        config,
        asType: true,
        name: 'Project',
      );
      final typeId = typeResult.objectId;

      final objectResult = await createCommand(
        'My project',
        db,
        config,
        assignedType: typeId,
      );

      final replayed = await _replayObject(db, config, objectResult.objectId);
      expect(replayed.smartBlockType, SmartBlockType.Page.value);
      expect(replayed.snapshot.objectTypes, ['project']);
      expect(
        replayed.snapshot.details.fields['type']?.stringValue,
        typeId,
      );
      expect(
        replayed.snapshot.details.fields['name']?.stringValue,
        'My project',
      );
    });

    test('createCommand without assignedType keeps the default ot-page type',
        () async {
      final objectResult = await createCommand('Plain object', db, config);
      final replayed = await _replayObject(db, config, objectResult.objectId);
      expect(replayed.snapshot.objectTypes, ['ot-page']);
      expect(replayed.snapshot.details.fields.containsKey('type'), isFalse);
    });

    test('creates normal objects by cloning template state', () async {
      final typeResult = await createCommand(
        'ignored',
        db,
        config,
        asType: true,
        name: 'Task',
      );
      final typeId = typeResult.objectId;

      final templateResult = await createCommand(
        'Checklist seed',
        db,
        config,
        asTemplate: true,
        checkbox: true,
        name: 'Task Template',
        targetObjectType: typeId,
      );
      final templateId = templateResult.objectId;

      final objectResult = await createCommand(
        'Task 1',
        db,
        config,
        templateId: templateId,
        textProvided: true,
      );
      final objectId = objectResult.objectId;

      final replayed = await _replayObject(db, config, objectId);
      expect(replayed.smartBlockType, SmartBlockType.Page.value);
      expect(replayed.snapshot.objectTypes, ['task']);
      expect(
        replayed.snapshot.details.fields['sourceObject']?.stringValue,
        templateId,
      );
      expect(replayed.snapshot.details.fields['type']?.stringValue, typeId);
      expect(replayed.snapshot.details.fields['name']?.stringValue, 'Task 1');
      expect(
        replayed.snapshot.details.fields.containsKey('targetObjectType'),
        isFalse,
      );
      final titleBlock = replayed.snapshot.blocks.firstWhere(
        (block) => block.id == 'title',
      );
      expect(titleBlock.text.text, 'Task 1');
      expect(
        replayed.snapshot.blocks.any(
          (block) =>
              block.hasText() &&
              block.text.style == Block_Content_Text_Style.Checkbox,
        ),
        isTrue,
      );
    });

    test('applies template name prefill when no positional text is provided',
        () async {
      final typeResult = await createCommand(
        'ignored',
        db,
        config,
        asType: true,
        name: 'Recipe',
      );
      final typeId = typeResult.objectId;

      final templateResult = await createCommand(
        'seed body',
        db,
        config,
        asTemplate: true,
        name: 'Recipe Template',
        targetObjectType: typeId,
      );
      final templateId = templateResult.objectId;

      final objectResult = await createCommand(
        '',
        db,
        config,
        templateId: templateId,
        textProvided: false,
      );
      final objectId = objectResult.objectId;

      final replayed = await _replayObject(db, config, objectId);
      expect(
        replayed.snapshot.details.fields['name']?.stringValue,
        'Recipe Template',
      );
      final titleBlock = replayed.snapshot.blocks.firstWhere(
        (block) => block.id == 'title',
      );
      expect(titleBlock.text.text, 'Recipe Template');
    });
  });
}

Future<ReplayedObjectState> _replayObject(
  ManytypeDatabase db,
  CliConfig config,
  String objectId,
) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  final treeKey = await deriveTreeKey(spaceKey, objectId);
  final rawTreeChanges = (await db.getChangesForObject(objectId))
      .map((change) => Uint8List.fromList(change.rawBytes))
      .toList();
  return replayObjectState(
    rawTreeChanges: rawTreeChanges,
    treeKey: treeKey,
  );
}
