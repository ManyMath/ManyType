import 'dart:io';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'database.g.dart';

@DataClassName('StoredObject')
class Objects extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Changes extends Table {
  TextColumn get id => text()();
  TextColumn get objectId => text().references(Objects, #id)();
  BlobColumn get rawBytes => blob()();
  TextColumn get parentHeads => text()(); // JSON-encoded list of parent CIDs

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StoredStoreEntry')
class StoreEntries extends Table {
  TextColumn get keyPeerId => text()();
  TextColumn get spaceId => text()();
  BlobColumn get value => blob()();
  BlobColumn get identitySignature => blob()();
  BlobColumn get peerSignature => blob()();

  @override
  Set<Column> get primaryKey => {keyPeerId};
}

@DriftDatabase(tables: [Objects, Changes, StoreEntries])
class ManytypeDatabase extends _$ManytypeDatabase {
  ManytypeDatabase(String dbPath) : super(_openConnection(dbPath));

  ManytypeDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  /// Insert a new object. Returns the created object.
  Future<void> insertObject(String id, String spaceId) async {
    await into(objects).insert(
      ObjectsCompanion.insert(id: id, spaceId: spaceId),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Insert a change for an object.
  Future<void> insertChange(
    String id,
    String objectId,
    List<int> rawBytes,
    String parentHeadsJson,
  ) async {
    await into(changes).insert(
      ChangesCompanion.insert(
        id: id,
        objectId: objectId,
        rawBytes: Uint8List.fromList(rawBytes),
        parentHeads: parentHeadsJson,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Get all objects.
  Future<List<StoredObject>> getAllObjects() => select(objects).get();

  /// Get all objects for a space.
  Future<List<StoredObject>> getObjectsBySpace(String spaceId) =>
      (select(objects)..where((o) => o.spaceId.equals(spaceId))).get();

  /// Get all changes for an object, ordered by insertion.
  Future<List<Change>> getChangesForObject(String objectId) =>
      (select(changes)..where((c) => c.objectId.equals(objectId))).get();

  /// Get head CIDs for an object (changes with no children).
  /// For v1: return the last change's CID as the head.
  Future<List<String>> getObjectHeads(String objectId) async {
    final allChanges = await getChangesForObject(objectId);
    if (allChanges.isEmpty) return [];
    // Simple approach: last change is the head
    return [allChanges.last.id];
  }

  /// Get all object IDs with their head CIDs for a space.
  Future<Map<String, List<String>>> getSpaceHeads(String spaceId) async {
    final objs = await getObjectsBySpace(spaceId);
    final result = <String, List<String>>{};
    for (final obj in objs) {
      result[obj.id] = await getObjectHeads(obj.id);
    }
    return result;
  }

  Future<void> upsertStoreEntry({
    required String keyPeerId,
    required String spaceId,
    required List<int> valueBytes,
    required List<int> identitySignatureBytes,
    required List<int> peerSignatureBytes,
  }) async {
    await into(storeEntries).insert(
      StoreEntriesCompanion.insert(
        keyPeerId: keyPeerId,
        spaceId: spaceId,
        value: Uint8List.fromList(valueBytes),
        identitySignature: Uint8List.fromList(identitySignatureBytes),
        peerSignature: Uint8List.fromList(peerSignatureBytes),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<StoredStoreEntry>> getStoreEntriesBySpace(String spaceId) =>
      (select(storeEntries)
            ..where((entry) => entry.spaceId.equals(spaceId))
            ..orderBy([(entry) => OrderingTerm.asc(entry.keyPeerId)]))
          .get();
}

LazyDatabase _openConnection(String dbPath) {
  return LazyDatabase(() async {
    final dir = Directory(dbPath).parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return NativeDatabase.createInBackground(File(dbPath));
  });
}
