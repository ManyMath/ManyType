import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:manytype_protocol/manytype_protocol.dart'
    show RawTreeChange, RootChange, TreeChange;

import 'database_connection.dart';

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
  ManytypeDatabase(String dbPath) : super(openConnectionForApp(dbPath));

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
      // Sync frequently re-sees existing object rows. Do not replace them, or
      // we clear soft-delete state that was already applied locally.
      mode: InsertMode.insertOrIgnore,
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

  /// Get all changes for an object in replay-safe order.
  Future<List<Change>> getChangesForObject(String objectId) async {
    final rows = await (select(changes)
          ..where((c) => c.objectId.equals(objectId)))
        .get();
    return _orderChangesForReplay(rows);
  }

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
    await (update(objects)..where((o) => o.id.equals(objectId)))
        .write(const ObjectsCompanion(isDeleted: Value(true)));
  }

  /// Get all non-deleted objects for a space.
  Future<List<StoredObject>> getNonDeletedObjectsBySpace(String spaceId) =>
      (select(objects)
            ..where(
                (o) => o.spaceId.equals(spaceId) & o.isDeleted.equals(false)))
          .get();

  /// Check if an object is marked as deleted.
  Future<bool> isObjectDeleted(String objectId) async {
    final obj = await (select(objects)..where((o) => o.id.equals(objectId)))
        .getSingleOrNull();
    return obj?.isDeleted ?? false;
  }
}

List<Change> _orderChangesForReplay(List<Change> rows) {
  if (rows.length < 2) {
    return rows;
  }

  final byId = <String, Change>{
    for (final row in rows) row.id: row,
  };
  final childrenByParent = <String, List<String>>{};
  final indegree = <String, int>{};
  final orderKeys = <String, _ChangeOrderKey>{};

  for (final row in rows) {
    final parents = _decodeParentHeads(row.parentHeads)
        .where(byId.containsKey)
        .toList(growable: false);
    indegree[row.id] = parents.length;
    orderKeys[row.id] = _ChangeOrderKey(
      isRoot: parents.isEmpty,
      timestamp: _extractStoredChangeTimestamp(
        row,
        isRoot: parents.isEmpty,
      ),
      id: row.id,
    );
    for (final parent in parents) {
      childrenByParent.putIfAbsent(parent, () => <String>[]).add(row.id);
    }
  }

  final ready = indegree.entries
      .where((entry) => entry.value == 0)
      .map((entry) => entry.key)
      .toList();
  ready.sort((left, right) => orderKeys[left]!.compareTo(orderKeys[right]!));

  final ordered = <Change>[];
  while (ready.isNotEmpty) {
    final nextId = ready.removeAt(0);
    ordered.add(byId[nextId]!);

    for (final childId in childrenByParent[nextId] ?? const <String>[]) {
      final remaining = indegree[childId]! - 1;
      indegree[childId] = remaining;
      if (remaining == 0) {
        ready.add(childId);
      }
    }
    ready.sort((left, right) => orderKeys[left]!.compareTo(orderKeys[right]!));
  }

  if (ordered.length == rows.length) {
    return ordered;
  }

  final fallback = List<Change>.from(rows);
  fallback.sort((left, right) {
    final leftKey = orderKeys[left.id] ??
        _ChangeOrderKey(
          isRoot: false,
          timestamp: _extractStoredChangeTimestamp(left),
          id: left.id,
        );
    final rightKey = orderKeys[right.id] ??
        _ChangeOrderKey(
          isRoot: false,
          timestamp: _extractStoredChangeTimestamp(right),
          id: right.id,
        );
    return leftKey.compareTo(rightKey);
  });
  return fallback;
}

List<String> _decodeParentHeads(String parentHeadsJson) {
  try {
    return (jsonDecode(parentHeadsJson) as List).cast<String>();
  } catch (_) {
    return const <String>[];
  }
}

int _extractStoredChangeTimestamp(
  Change row, {
  bool isRoot = false,
}) {
  try {
    final rawTreeChange = RawTreeChange.fromBuffer(row.rawBytes);
    if (rawTreeChange.payload.isEmpty) {
      return 0;
    }
    if (isRoot) {
      final rootChange = RootChange.fromBuffer(rawTreeChange.payload);
      return rootChange.hasTimestamp() ? rootChange.timestamp.toInt() : 0;
    }
    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
    return treeChange.hasTimestamp() ? treeChange.timestamp.toInt() : 0;
  } catch (_) {
    return 0;
  }
}

class _ChangeOrderKey implements Comparable<_ChangeOrderKey> {
  const _ChangeOrderKey({
    required this.isRoot,
    required this.timestamp,
    required this.id,
  });

  final bool isRoot;
  final int timestamp;
  final String id;

  @override
  int compareTo(_ChangeOrderKey other) {
    if (isRoot != other.isRoot) {
      return isRoot ? -1 : 1;
    }
    final timestampCompare = timestamp.compareTo(other.timestamp);
    if (timestampCompare != 0) {
      return timestampCompare;
    }
    return id.compareTo(other.id);
  }
}
