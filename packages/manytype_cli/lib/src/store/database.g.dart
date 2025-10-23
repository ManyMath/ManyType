// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ObjectsTable extends Objects
    with TableInfo<$ObjectsTable, StoredObject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _spaceIdMeta =
      const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
      'space_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, spaceId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'objects';
  @override
  VerificationContext validateIntegrity(Insertable<StoredObject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta,
          spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredObject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredObject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      spaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ObjectsTable createAlias(String alias) {
    return $ObjectsTable(attachedDatabase, alias);
  }
}

class StoredObject extends DataClass implements Insertable<StoredObject> {
  final String id;
  final String spaceId;
  final DateTime createdAt;
  const StoredObject(
      {required this.id, required this.spaceId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ObjectsCompanion toCompanion(bool nullToAbsent) {
    return ObjectsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      createdAt: Value(createdAt),
    );
  }

  factory StoredObject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredObject(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StoredObject copyWith({String? id, String? spaceId, DateTime? createdAt}) =>
      StoredObject(
        id: id ?? this.id,
        spaceId: spaceId ?? this.spaceId,
        createdAt: createdAt ?? this.createdAt,
      );
  StoredObject copyWithCompanion(ObjectsCompanion data) {
    return StoredObject(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredObject(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, spaceId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredObject &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.createdAt == this.createdAt);
}

class ObjectsCompanion extends UpdateCompanion<StoredObject> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ObjectsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObjectsCompanion.insert({
    required String id,
    required String spaceId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        spaceId = Value(spaceId);
  static Insertable<StoredObject> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? spaceId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ObjectsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObjectsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangesTable extends Changes with TableInfo<$ChangesTable, Change> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _objectIdMeta =
      const VerificationMeta('objectId');
  @override
  late final GeneratedColumn<String> objectId = GeneratedColumn<String>(
      'object_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawBytesMeta =
      const VerificationMeta('rawBytes');
  @override
  late final GeneratedColumn<Uint8List> rawBytes = GeneratedColumn<Uint8List>(
      'raw_bytes', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _parentHeadsMeta =
      const VerificationMeta('parentHeads');
  @override
  late final GeneratedColumn<String> parentHeads = GeneratedColumn<String>(
      'parent_heads', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, objectId, rawBytes, parentHeads];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'changes';
  @override
  VerificationContext validateIntegrity(Insertable<Change> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('object_id')) {
      context.handle(_objectIdMeta,
          objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta));
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('raw_bytes')) {
      context.handle(_rawBytesMeta,
          rawBytes.isAcceptableOrUnknown(data['raw_bytes']!, _rawBytesMeta));
    } else if (isInserting) {
      context.missing(_rawBytesMeta);
    }
    if (data.containsKey('parent_heads')) {
      context.handle(
          _parentHeadsMeta,
          parentHeads.isAcceptableOrUnknown(
              data['parent_heads']!, _parentHeadsMeta));
    } else if (isInserting) {
      context.missing(_parentHeadsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Change map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Change(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      objectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}object_id'])!,
      rawBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}raw_bytes'])!,
      parentHeads: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_heads'])!,
    );
  }

  @override
  $ChangesTable createAlias(String alias) {
    return $ChangesTable(attachedDatabase, alias);
  }
}

class Change extends DataClass implements Insertable<Change> {
  final String id;
  final String objectId;
  final Uint8List rawBytes;
  final String parentHeads;
  const Change(
      {required this.id,
      required this.objectId,
      required this.rawBytes,
      required this.parentHeads});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['object_id'] = Variable<String>(objectId);
    map['raw_bytes'] = Variable<Uint8List>(rawBytes);
    map['parent_heads'] = Variable<String>(parentHeads);
    return map;
  }

  ChangesCompanion toCompanion(bool nullToAbsent) {
    return ChangesCompanion(
      id: Value(id),
      objectId: Value(objectId),
      rawBytes: Value(rawBytes),
      parentHeads: Value(parentHeads),
    );
  }

  factory Change.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Change(
      id: serializer.fromJson<String>(json['id']),
      objectId: serializer.fromJson<String>(json['objectId']),
      rawBytes: serializer.fromJson<Uint8List>(json['rawBytes']),
      parentHeads: serializer.fromJson<String>(json['parentHeads']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'objectId': serializer.toJson<String>(objectId),
      'rawBytes': serializer.toJson<Uint8List>(rawBytes),
      'parentHeads': serializer.toJson<String>(parentHeads),
    };
  }

  Change copyWith(
          {String? id,
          String? objectId,
          Uint8List? rawBytes,
          String? parentHeads}) =>
      Change(
        id: id ?? this.id,
        objectId: objectId ?? this.objectId,
        rawBytes: rawBytes ?? this.rawBytes,
        parentHeads: parentHeads ?? this.parentHeads,
      );
  Change copyWithCompanion(ChangesCompanion data) {
    return Change(
      id: data.id.present ? data.id.value : this.id,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      rawBytes: data.rawBytes.present ? data.rawBytes.value : this.rawBytes,
      parentHeads:
          data.parentHeads.present ? data.parentHeads.value : this.parentHeads,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Change(')
          ..write('id: $id, ')
          ..write('objectId: $objectId, ')
          ..write('rawBytes: $rawBytes, ')
          ..write('parentHeads: $parentHeads')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, objectId, $driftBlobEquality.hash(rawBytes), parentHeads);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Change &&
          other.id == this.id &&
          other.objectId == this.objectId &&
          $driftBlobEquality.equals(other.rawBytes, this.rawBytes) &&
          other.parentHeads == this.parentHeads);
}

class ChangesCompanion extends UpdateCompanion<Change> {
  final Value<String> id;
  final Value<String> objectId;
  final Value<Uint8List> rawBytes;
  final Value<String> parentHeads;
  final Value<int> rowid;
  const ChangesCompanion({
    this.id = const Value.absent(),
    this.objectId = const Value.absent(),
    this.rawBytes = const Value.absent(),
    this.parentHeads = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChangesCompanion.insert({
    required String id,
    required String objectId,
    required Uint8List rawBytes,
    required String parentHeads,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        objectId = Value(objectId),
        rawBytes = Value(rawBytes),
        parentHeads = Value(parentHeads);
  static Insertable<Change> custom({
    Expression<String>? id,
    Expression<String>? objectId,
    Expression<Uint8List>? rawBytes,
    Expression<String>? parentHeads,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (objectId != null) 'object_id': objectId,
      if (rawBytes != null) 'raw_bytes': rawBytes,
      if (parentHeads != null) 'parent_heads': parentHeads,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChangesCompanion copyWith(
      {Value<String>? id,
      Value<String>? objectId,
      Value<Uint8List>? rawBytes,
      Value<String>? parentHeads,
      Value<int>? rowid}) {
    return ChangesCompanion(
      id: id ?? this.id,
      objectId: objectId ?? this.objectId,
      rawBytes: rawBytes ?? this.rawBytes,
      parentHeads: parentHeads ?? this.parentHeads,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<String>(objectId.value);
    }
    if (rawBytes.present) {
      map['raw_bytes'] = Variable<Uint8List>(rawBytes.value);
    }
    if (parentHeads.present) {
      map['parent_heads'] = Variable<String>(parentHeads.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangesCompanion(')
          ..write('id: $id, ')
          ..write('objectId: $objectId, ')
          ..write('rawBytes: $rawBytes, ')
          ..write('parentHeads: $parentHeads, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ManytypeDatabase extends GeneratedDatabase {
  _$ManytypeDatabase(QueryExecutor e) : super(e);
  $ManytypeDatabaseManager get managers => $ManytypeDatabaseManager(this);
  late final $ObjectsTable objects = $ObjectsTable(this);
  late final $ChangesTable changes = $ChangesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [objects, changes];
}

typedef $$ObjectsTableCreateCompanionBuilder = ObjectsCompanion Function({
  required String id,
  required String spaceId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$ObjectsTableUpdateCompanionBuilder = ObjectsCompanion Function({
  Value<String> id,
  Value<String> spaceId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ObjectsTableFilterComposer
    extends Composer<_$ManytypeDatabase, $ObjectsTable> {
  $$ObjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spaceId => $composableBuilder(
      column: $table.spaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ObjectsTableOrderingComposer
    extends Composer<_$ManytypeDatabase, $ObjectsTable> {
  $$ObjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spaceId => $composableBuilder(
      column: $table.spaceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ObjectsTableAnnotationComposer
    extends Composer<_$ManytypeDatabase, $ObjectsTable> {
  $$ObjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ObjectsTableTableManager extends RootTableManager<
    _$ManytypeDatabase,
    $ObjectsTable,
    StoredObject,
    $$ObjectsTableFilterComposer,
    $$ObjectsTableOrderingComposer,
    $$ObjectsTableAnnotationComposer,
    $$ObjectsTableCreateCompanionBuilder,
    $$ObjectsTableUpdateCompanionBuilder,
    (
      StoredObject,
      BaseReferences<_$ManytypeDatabase, $ObjectsTable, StoredObject>
    ),
    StoredObject,
    PrefetchHooks Function()> {
  $$ObjectsTableTableManager(_$ManytypeDatabase db, $ObjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> spaceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ObjectsCompanion(
            id: id,
            spaceId: spaceId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String spaceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ObjectsCompanion.insert(
            id: id,
            spaceId: spaceId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ObjectsTableProcessedTableManager = ProcessedTableManager<
    _$ManytypeDatabase,
    $ObjectsTable,
    StoredObject,
    $$ObjectsTableFilterComposer,
    $$ObjectsTableOrderingComposer,
    $$ObjectsTableAnnotationComposer,
    $$ObjectsTableCreateCompanionBuilder,
    $$ObjectsTableUpdateCompanionBuilder,
    (
      StoredObject,
      BaseReferences<_$ManytypeDatabase, $ObjectsTable, StoredObject>
    ),
    StoredObject,
    PrefetchHooks Function()>;
typedef $$ChangesTableCreateCompanionBuilder = ChangesCompanion Function({
  required String id,
  required String objectId,
  required Uint8List rawBytes,
  required String parentHeads,
  Value<int> rowid,
});
typedef $$ChangesTableUpdateCompanionBuilder = ChangesCompanion Function({
  Value<String> id,
  Value<String> objectId,
  Value<Uint8List> rawBytes,
  Value<String> parentHeads,
  Value<int> rowid,
});

class $$ChangesTableFilterComposer
    extends Composer<_$ManytypeDatabase, $ChangesTable> {
  $$ChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objectId => $composableBuilder(
      column: $table.objectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get rawBytes => $composableBuilder(
      column: $table.rawBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentHeads => $composableBuilder(
      column: $table.parentHeads, builder: (column) => ColumnFilters(column));
}

class $$ChangesTableOrderingComposer
    extends Composer<_$ManytypeDatabase, $ChangesTable> {
  $$ChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objectId => $composableBuilder(
      column: $table.objectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get rawBytes => $composableBuilder(
      column: $table.rawBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentHeads => $composableBuilder(
      column: $table.parentHeads, builder: (column) => ColumnOrderings(column));
}

class $$ChangesTableAnnotationComposer
    extends Composer<_$ManytypeDatabase, $ChangesTable> {
  $$ChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumn<Uint8List> get rawBytes =>
      $composableBuilder(column: $table.rawBytes, builder: (column) => column);

  GeneratedColumn<String> get parentHeads => $composableBuilder(
      column: $table.parentHeads, builder: (column) => column);
}

class $$ChangesTableTableManager extends RootTableManager<
    _$ManytypeDatabase,
    $ChangesTable,
    Change,
    $$ChangesTableFilterComposer,
    $$ChangesTableOrderingComposer,
    $$ChangesTableAnnotationComposer,
    $$ChangesTableCreateCompanionBuilder,
    $$ChangesTableUpdateCompanionBuilder,
    (Change, BaseReferences<_$ManytypeDatabase, $ChangesTable, Change>),
    Change,
    PrefetchHooks Function()> {
  $$ChangesTableTableManager(_$ManytypeDatabase db, $ChangesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> objectId = const Value.absent(),
            Value<Uint8List> rawBytes = const Value.absent(),
            Value<String> parentHeads = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChangesCompanion(
            id: id,
            objectId: objectId,
            rawBytes: rawBytes,
            parentHeads: parentHeads,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String objectId,
            required Uint8List rawBytes,
            required String parentHeads,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChangesCompanion.insert(
            id: id,
            objectId: objectId,
            rawBytes: rawBytes,
            parentHeads: parentHeads,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChangesTableProcessedTableManager = ProcessedTableManager<
    _$ManytypeDatabase,
    $ChangesTable,
    Change,
    $$ChangesTableFilterComposer,
    $$ChangesTableOrderingComposer,
    $$ChangesTableAnnotationComposer,
    $$ChangesTableCreateCompanionBuilder,
    $$ChangesTableUpdateCompanionBuilder,
    (Change, BaseReferences<_$ManytypeDatabase, $ChangesTable, Change>),
    Change,
    PrefetchHooks Function()>;

class $ManytypeDatabaseManager {
  final _$ManytypeDatabase _db;
  $ManytypeDatabaseManager(this._db);
  $$ObjectsTableTableManager get objects =>
      $$ObjectsTableTableManager(_db, _db.objects);
  $$ChangesTableTableManager get changes =>
      $$ChangesTableTableManager(_db, _db.changes);
}
