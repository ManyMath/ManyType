import 'dart:convert';
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
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

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

@DataClassName('StoredAttachmentRef')
class AttachmentRefs extends Table {
  TextColumn get spaceId => text()();
  TextColumn get objectId => text().references(Objects, #id)();
  TextColumn get fileId => text()();
  TextColumn get cid => text().withDefault(const Constant(''))();
  DateTimeColumn get discoveredAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {spaceId, objectId, fileId, cid};
}

@DataClassName('StoredCachedBlob')
class CachedBlobs extends Table {
  TextColumn get spaceId => text()();
  TextColumn get fileId => text()();
  TextColumn get cid => text()();
  BlobColumn get bytes => blob()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {spaceId, fileId, cid};
}

@DriftDatabase(
    tables: [Objects, Changes, StoreEntries, AttachmentRefs, CachedBlobs])
class ManytypeDatabase extends _$ManytypeDatabase {
  ManytypeDatabase(String dbPath) : super(_openConnection(dbPath));

  ManytypeDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 4) {
          await m.addColumn(objects, objects.isDeleted);
        }
      },
    );
  }

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
  Future<List<String>> getObjectHeads(String objectId) async {
    final allChanges = await getChangesForObject(objectId);
    if (allChanges.isEmpty) return [];
    final parentIds = <String>{};
    for (final change in allChanges) {
      try {
        final parents = (jsonDecode(change.parentHeads) as List).cast<String>();
        parentIds.addAll(parents);
      } catch (_) {
        // Ignore malformed parentHeads rows.
      }
    }

    final heads = allChanges
        .map((change) => change.id)
        .where((id) => !parentIds.contains(id))
        .toList(growable: false);
    final sorted = heads.toList()..sort();
    return sorted;
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

  Future<void> upsertAttachmentRef({
    required String spaceId,
    required String objectId,
    required String fileId,
    String cid = '',
  }) async {
    await into(attachmentRefs).insert(
      AttachmentRefsCompanion.insert(
        spaceId: spaceId,
        objectId: objectId,
        fileId: fileId,
        cid: Value(cid),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<StoredAttachmentRef>> getAttachmentRefsByObject(
          String objectId) =>
      (select(attachmentRefs)
            ..where((entry) => entry.objectId.equals(objectId))
            ..orderBy([
              (entry) => OrderingTerm.asc(entry.fileId),
              (entry) => OrderingTerm.asc(entry.cid),
            ]))
          .get();

  Future<List<StoredAttachmentRef>> getAttachmentRefsByFileId(
    String spaceId,
    String fileId,
  ) =>
      (select(attachmentRefs)
            ..where(
              (entry) =>
                  entry.spaceId.equals(spaceId) & entry.fileId.equals(fileId),
            )
            ..orderBy([
              (entry) => OrderingTerm.asc(entry.objectId),
              (entry) => OrderingTerm.asc(entry.cid),
            ]))
          .get();

  Future<void> cacheBlob({
    required String spaceId,
    required String fileId,
    required String cid,
    required List<int> bytes,
  }) async {
    await into(cachedBlobs).insert(
      CachedBlobsCompanion.insert(
        spaceId: spaceId,
        fileId: fileId,
        cid: cid,
        bytes: Uint8List.fromList(bytes),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<StoredCachedBlob?> getCachedBlob({
    required String spaceId,
    required String fileId,
    required String cid,
  }) =>
      (select(cachedBlobs)
            ..where(
              (entry) =>
                  entry.spaceId.equals(spaceId) &
                  entry.fileId.equals(fileId) &
                  entry.cid.equals(cid),
            ))
          .getSingleOrNull();
  /// Mark an object as deleted (soft-delete via isDeleted flag).
  Future<void> markObjectDeleted(String objectId) async {
    (update(objects)..where((o) => o.id.equals(objectId)))
        .write(const ObjectsCompanion(isDeleted: Value(true)));
  }

  /// Get all non-deleted objects for a space.
  Future<List<StoredObject>> getNonDeletedObjectsBySpace(String spaceId) =>
      (select(objects)
            ..where((o) => o.spaceId.equals(spaceId) & o.isDeleted.equals(false)))
          .get();

  /// Check if an object is marked as deleted.
  Future<bool> isObjectDeleted(String objectId) async {
    final obj = await (select(objects)..where((o) => o.id.equals(objectId))).getSingleOrNull();
    return obj?.isDeleted ?? false;
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
