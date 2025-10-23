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

@DriftDatabase(tables: [Objects, Changes])
class ManytypeDatabase extends _$ManytypeDatabase {
  ManytypeDatabase(String dbPath) : super(_openConnection(dbPath));

  ManytypeDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

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
