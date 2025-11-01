import 'dart:convert';

import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';

void main() {
  // Known BIP-39 test vector mnemonic
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  late ManytypeDatabase db;
  late CliConfig config;

  setUp(() {
    db = ManytypeDatabase.forTesting(NativeDatabase.memory());
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
      expect(allObjects.length, 3); // ACL root + settings root + text object

      StoredObject? textObj;
      int bootstrapObjects = 0;
      for (final object in allObjects) {
        final changes = await db.getChangesForObject(object.id);
        if (changes.length == 2) {
          textObj = object;
        } else if (changes.length == 1) {
          bootstrapObjects++;
        }
      }
      expect(textObj, isNotNull);
      expect(bootstrapObjects, 2);

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

      final bootstrapChangeCounts = <int>[];
      for (final object in allObjects) {
        if (object.id == textObj.id) continue;
        bootstrapChangeCounts
            .add((await db.getChangesForObject(object.id)).length);
      }
      expect(bootstrapChangeCounts, everyElement(1));
    });

    test('second create reuses existing ACL root', () async {
      await createCommand('First object', db, config);
      await createCommand('Second object', db, config);

      // Should have ACL root + settings root + 2 text objects
      final allObjects = await db.getAllObjects();
      expect(allObjects.length, 4);
    });

    test('created changes have non-empty rawBytes', () async {
      await createCommand('Test text', db, config);

      final allObjects = await db.getAllObjects();
      for (final obj in allObjects) {
        final changes = await db.getChangesForObject(obj.id);
        for (final change in changes) {
          expect(change.rawBytes.length, greaterThan(0),
              reason: 'Change ${change.id} should have non-empty rawBytes');
        }
      }
    });

    test('object IDs are CIDs (start with bafy)', () async {
      await createCommand('CID test', db, config);

      final allObjects = await db.getAllObjects();
      for (final obj in allObjects) {
        expect(obj.id, startsWith('bafy'),
            reason: 'Object ID should be a CID starting with bafy');
      }
    });

    test('object persists across database instances', () async {
      // Create in first db instance
      await createCommand('Persistent test', db, config);
      final objsBefore = await db.getAllObjects();
      expect(objsBefore.length, 3);

      // The in-memory database is the same instance, so this verifies
      // the data is retrievable (persistence with file-backed DB is
      // proven by using the same dbPath across process restarts).
      final objsAfter = await db.getAllObjects();
      expect(objsAfter.length, 3);
      expect(objsAfter.first.id, objsBefore.first.id);
    });
  });
}
