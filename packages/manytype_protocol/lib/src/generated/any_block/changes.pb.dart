// This is a generated file - do not edit.
//
// Generated from any_block/changes.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $1;

import 'changes.pbenum.dart';
import 'models.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'changes.pbenum.dart';

class Change_Snapshot extends $pb.GeneratedMessage {
  factory Change_Snapshot({
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? logHeads,
    $0.SmartBlockSnapshotBase? data,
    $core.Iterable<Change_FileKeys>? fileKeys,
  }) {
    final result = create();
    if (logHeads != null) result.logHeads.addEntries(logHeads);
    if (data != null) result.data = data;
    if (fileKeys != null) result.fileKeys.addAll(fileKeys);
    return result;
  }

  Change_Snapshot._();

  factory Change_Snapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_Snapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.Snapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, _omitFieldNames ? '' : 'logHeads',
        protoName: 'logHeads',
        entryClassName: 'Change.Snapshot.LogHeadsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('anytype.model'))
    ..aOM<$0.SmartBlockSnapshotBase>(2, _omitFieldNames ? '' : 'data',
        subBuilder: $0.SmartBlockSnapshotBase.create)
    ..pPM<Change_FileKeys>(3, _omitFieldNames ? '' : 'fileKeys',
        protoName: 'fileKeys', subBuilder: Change_FileKeys.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_Snapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_Snapshot copyWith(void Function(Change_Snapshot) updates) =>
      super.copyWith((message) => updates(message as Change_Snapshot))
          as Change_Snapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_Snapshot create() => Change_Snapshot._();
  @$core.override
  Change_Snapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_Snapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_Snapshot>(create);
  static Change_Snapshot? _defaultInstance;

  /// logId -> lastChangeId
  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.String> get logHeads => $_getMap(0);

  /// snapshot data
  @$pb.TagNumber(2)
  $0.SmartBlockSnapshotBase get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($0.SmartBlockSnapshotBase value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.SmartBlockSnapshotBase ensureData() => $_ensure(1);

  /// all file keys related to doc
  @$pb.TagNumber(3)
  $pb.PbList<Change_FileKeys> get fileKeys => $_getList(2);
}

class Change_FileKeys extends $pb.GeneratedMessage {
  factory Change_FileKeys({
    $core.String? hash,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? keys,
  }) {
    final result = create();
    if (hash != null) result.hash = hash;
    if (keys != null) result.keys.addEntries(keys);
    return result;
  }

  Change_FileKeys._();

  factory Change_FileKeys.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_FileKeys.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.FileKeys',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'keys',
        entryClassName: 'Change.FileKeys.KeysEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('anytype.model'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_FileKeys clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_FileKeys copyWith(void Function(Change_FileKeys) updates) =>
      super.copyWith((message) => updates(message as Change_FileKeys))
          as Change_FileKeys;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_FileKeys create() => Change_FileKeys._();
  @$core.override
  Change_FileKeys createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_FileKeys getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_FileKeys>(create);
  static Change_FileKeys? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.String> get keys => $_getMap(1);
}

enum Change_Content_Value {
  blockCreate,
  blockUpdate,
  blockRemove,
  blockMove,
  blockDuplicate,
  relationAdd,
  relationRemove,
  detailsSet,
  detailsUnset,
  objectTypeAdd,
  objectTypeRemove,
  storeKeySet,
  storeKeyUnset,
  storeSliceUpdate,
  originalCreatedTimestampSet,
  setFileInfo,
  notificationCreate,
  notificationUpdate,
  deviceAdd,
  deviceUpdate,
  notSet
}

class Change_Content extends $pb.GeneratedMessage {
  factory Change_Content({
    Change_BlockCreate? blockCreate,
    Change_BlockUpdate? blockUpdate,
    Change_BlockRemove? blockRemove,
    Change_BlockMove? blockMove,
    Change_BlockDuplicate? blockDuplicate,
    Change_RelationAdd? relationAdd,
    Change_RelationRemove? relationRemove,
    Change_DetailsSet? detailsSet,
    Change_DetailsUnset? detailsUnset,
    Change_ObjectTypeAdd? objectTypeAdd,
    Change_ObjectTypeRemove? objectTypeRemove,
    Change_StoreKeySet? storeKeySet,
    Change_StoreKeyUnset? storeKeyUnset,
    Change_StoreSliceUpdate? storeSliceUpdate,
    Change_OriginalCreatedTimestampSet? originalCreatedTimestampSet,
    Change_SetFileInfo? setFileInfo,
    Change_NotificationCreate? notificationCreate,
    Change_NotificationUpdate? notificationUpdate,
    Change_DeviceAdd? deviceAdd,
    Change_DeviceUpdate? deviceUpdate,
  }) {
    final result = create();
    if (blockCreate != null) result.blockCreate = blockCreate;
    if (blockUpdate != null) result.blockUpdate = blockUpdate;
    if (blockRemove != null) result.blockRemove = blockRemove;
    if (blockMove != null) result.blockMove = blockMove;
    if (blockDuplicate != null) result.blockDuplicate = blockDuplicate;
    if (relationAdd != null) result.relationAdd = relationAdd;
    if (relationRemove != null) result.relationRemove = relationRemove;
    if (detailsSet != null) result.detailsSet = detailsSet;
    if (detailsUnset != null) result.detailsUnset = detailsUnset;
    if (objectTypeAdd != null) result.objectTypeAdd = objectTypeAdd;
    if (objectTypeRemove != null) result.objectTypeRemove = objectTypeRemove;
    if (storeKeySet != null) result.storeKeySet = storeKeySet;
    if (storeKeyUnset != null) result.storeKeyUnset = storeKeyUnset;
    if (storeSliceUpdate != null) result.storeSliceUpdate = storeSliceUpdate;
    if (originalCreatedTimestampSet != null)
      result.originalCreatedTimestampSet = originalCreatedTimestampSet;
    if (setFileInfo != null) result.setFileInfo = setFileInfo;
    if (notificationCreate != null)
      result.notificationCreate = notificationCreate;
    if (notificationUpdate != null)
      result.notificationUpdate = notificationUpdate;
    if (deviceAdd != null) result.deviceAdd = deviceAdd;
    if (deviceUpdate != null) result.deviceUpdate = deviceUpdate;
    return result;
  }

  Change_Content._();

  factory Change_Content.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_Content.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Change_Content_Value>
      _Change_Content_ValueByTag = {
    1: Change_Content_Value.blockCreate,
    2: Change_Content_Value.blockUpdate,
    3: Change_Content_Value.blockRemove,
    4: Change_Content_Value.blockMove,
    5: Change_Content_Value.blockDuplicate,
    50: Change_Content_Value.relationAdd,
    51: Change_Content_Value.relationRemove,
    100: Change_Content_Value.detailsSet,
    101: Change_Content_Value.detailsUnset,
    105: Change_Content_Value.objectTypeAdd,
    106: Change_Content_Value.objectTypeRemove,
    107: Change_Content_Value.storeKeySet,
    108: Change_Content_Value.storeKeyUnset,
    109: Change_Content_Value.storeSliceUpdate,
    110: Change_Content_Value.originalCreatedTimestampSet,
    111: Change_Content_Value.setFileInfo,
    112: Change_Content_Value.notificationCreate,
    113: Change_Content_Value.notificationUpdate,
    114: Change_Content_Value.deviceAdd,
    115: Change_Content_Value.deviceUpdate,
    0: Change_Content_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.Content',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..oo(0, [
      1,
      2,
      3,
      4,
      5,
      50,
      51,
      100,
      101,
      105,
      106,
      107,
      108,
      109,
      110,
      111,
      112,
      113,
      114,
      115
    ])
    ..aOM<Change_BlockCreate>(1, _omitFieldNames ? '' : 'blockCreate',
        protoName: 'blockCreate', subBuilder: Change_BlockCreate.create)
    ..aOM<Change_BlockUpdate>(2, _omitFieldNames ? '' : 'blockUpdate',
        protoName: 'blockUpdate', subBuilder: Change_BlockUpdate.create)
    ..aOM<Change_BlockRemove>(3, _omitFieldNames ? '' : 'blockRemove',
        protoName: 'blockRemove', subBuilder: Change_BlockRemove.create)
    ..aOM<Change_BlockMove>(4, _omitFieldNames ? '' : 'blockMove',
        protoName: 'blockMove', subBuilder: Change_BlockMove.create)
    ..aOM<Change_BlockDuplicate>(5, _omitFieldNames ? '' : 'blockDuplicate',
        protoName: 'blockDuplicate', subBuilder: Change_BlockDuplicate.create)
    ..aOM<Change_RelationAdd>(50, _omitFieldNames ? '' : 'relationAdd',
        protoName: 'relationAdd', subBuilder: Change_RelationAdd.create)
    ..aOM<Change_RelationRemove>(51, _omitFieldNames ? '' : 'relationRemove',
        protoName: 'relationRemove', subBuilder: Change_RelationRemove.create)
    ..aOM<Change_DetailsSet>(100, _omitFieldNames ? '' : 'detailsSet',
        protoName: 'detailsSet', subBuilder: Change_DetailsSet.create)
    ..aOM<Change_DetailsUnset>(101, _omitFieldNames ? '' : 'detailsUnset',
        protoName: 'detailsUnset', subBuilder: Change_DetailsUnset.create)
    ..aOM<Change_ObjectTypeAdd>(105, _omitFieldNames ? '' : 'objectTypeAdd',
        protoName: 'objectTypeAdd', subBuilder: Change_ObjectTypeAdd.create)
    ..aOM<Change_ObjectTypeRemove>(
        106, _omitFieldNames ? '' : 'objectTypeRemove',
        protoName: 'objectTypeRemove',
        subBuilder: Change_ObjectTypeRemove.create)
    ..aOM<Change_StoreKeySet>(107, _omitFieldNames ? '' : 'storeKeySet',
        protoName: 'storeKeySet', subBuilder: Change_StoreKeySet.create)
    ..aOM<Change_StoreKeyUnset>(108, _omitFieldNames ? '' : 'storeKeyUnset',
        protoName: 'storeKeyUnset', subBuilder: Change_StoreKeyUnset.create)
    ..aOM<Change_StoreSliceUpdate>(
        109, _omitFieldNames ? '' : 'storeSliceUpdate',
        protoName: 'storeSliceUpdate',
        subBuilder: Change_StoreSliceUpdate.create)
    ..aOM<Change_OriginalCreatedTimestampSet>(
        110, _omitFieldNames ? '' : 'originalCreatedTimestampSet',
        protoName: 'originalCreatedTimestampSet',
        subBuilder: Change_OriginalCreatedTimestampSet.create)
    ..aOM<Change_SetFileInfo>(111, _omitFieldNames ? '' : 'setFileInfo',
        protoName: 'setFileInfo', subBuilder: Change_SetFileInfo.create)
    ..aOM<Change_NotificationCreate>(
        112, _omitFieldNames ? '' : 'notificationCreate',
        protoName: 'notificationCreate',
        subBuilder: Change_NotificationCreate.create)
    ..aOM<Change_NotificationUpdate>(
        113, _omitFieldNames ? '' : 'notificationUpdate',
        protoName: 'notificationUpdate',
        subBuilder: Change_NotificationUpdate.create)
    ..aOM<Change_DeviceAdd>(114, _omitFieldNames ? '' : 'deviceAdd',
        protoName: 'deviceAdd', subBuilder: Change_DeviceAdd.create)
    ..aOM<Change_DeviceUpdate>(115, _omitFieldNames ? '' : 'deviceUpdate',
        protoName: 'deviceUpdate', subBuilder: Change_DeviceUpdate.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_Content clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_Content copyWith(void Function(Change_Content) updates) =>
      super.copyWith((message) => updates(message as Change_Content))
          as Change_Content;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_Content create() => Change_Content._();
  @$core.override
  Change_Content createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_Content getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_Content>(create);
  static Change_Content? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(50)
  @$pb.TagNumber(51)
  @$pb.TagNumber(100)
  @$pb.TagNumber(101)
  @$pb.TagNumber(105)
  @$pb.TagNumber(106)
  @$pb.TagNumber(107)
  @$pb.TagNumber(108)
  @$pb.TagNumber(109)
  @$pb.TagNumber(110)
  @$pb.TagNumber(111)
  @$pb.TagNumber(112)
  @$pb.TagNumber(113)
  @$pb.TagNumber(114)
  @$pb.TagNumber(115)
  Change_Content_Value whichValue() =>
      _Change_Content_ValueByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(50)
  @$pb.TagNumber(51)
  @$pb.TagNumber(100)
  @$pb.TagNumber(101)
  @$pb.TagNumber(105)
  @$pb.TagNumber(106)
  @$pb.TagNumber(107)
  @$pb.TagNumber(108)
  @$pb.TagNumber(109)
  @$pb.TagNumber(110)
  @$pb.TagNumber(111)
  @$pb.TagNumber(112)
  @$pb.TagNumber(113)
  @$pb.TagNumber(114)
  @$pb.TagNumber(115)
  void clearValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Change_BlockCreate get blockCreate => $_getN(0);
  @$pb.TagNumber(1)
  set blockCreate(Change_BlockCreate value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockCreate() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockCreate() => $_clearField(1);
  @$pb.TagNumber(1)
  Change_BlockCreate ensureBlockCreate() => $_ensure(0);

  @$pb.TagNumber(2)
  Change_BlockUpdate get blockUpdate => $_getN(1);
  @$pb.TagNumber(2)
  set blockUpdate(Change_BlockUpdate value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockUpdate() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockUpdate() => $_clearField(2);
  @$pb.TagNumber(2)
  Change_BlockUpdate ensureBlockUpdate() => $_ensure(1);

  @$pb.TagNumber(3)
  Change_BlockRemove get blockRemove => $_getN(2);
  @$pb.TagNumber(3)
  set blockRemove(Change_BlockRemove value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockRemove() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockRemove() => $_clearField(3);
  @$pb.TagNumber(3)
  Change_BlockRemove ensureBlockRemove() => $_ensure(2);

  @$pb.TagNumber(4)
  Change_BlockMove get blockMove => $_getN(3);
  @$pb.TagNumber(4)
  set blockMove(Change_BlockMove value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBlockMove() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockMove() => $_clearField(4);
  @$pb.TagNumber(4)
  Change_BlockMove ensureBlockMove() => $_ensure(3);

  @$pb.TagNumber(5)
  Change_BlockDuplicate get blockDuplicate => $_getN(4);
  @$pb.TagNumber(5)
  set blockDuplicate(Change_BlockDuplicate value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasBlockDuplicate() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockDuplicate() => $_clearField(5);
  @$pb.TagNumber(5)
  Change_BlockDuplicate ensureBlockDuplicate() => $_ensure(4);

  @$pb.TagNumber(50)
  Change_RelationAdd get relationAdd => $_getN(5);
  @$pb.TagNumber(50)
  set relationAdd(Change_RelationAdd value) => $_setField(50, value);
  @$pb.TagNumber(50)
  $core.bool hasRelationAdd() => $_has(5);
  @$pb.TagNumber(50)
  void clearRelationAdd() => $_clearField(50);
  @$pb.TagNumber(50)
  Change_RelationAdd ensureRelationAdd() => $_ensure(5);

  @$pb.TagNumber(51)
  Change_RelationRemove get relationRemove => $_getN(6);
  @$pb.TagNumber(51)
  set relationRemove(Change_RelationRemove value) => $_setField(51, value);
  @$pb.TagNumber(51)
  $core.bool hasRelationRemove() => $_has(6);
  @$pb.TagNumber(51)
  void clearRelationRemove() => $_clearField(51);
  @$pb.TagNumber(51)
  Change_RelationRemove ensureRelationRemove() => $_ensure(6);

  @$pb.TagNumber(100)
  Change_DetailsSet get detailsSet => $_getN(7);
  @$pb.TagNumber(100)
  set detailsSet(Change_DetailsSet value) => $_setField(100, value);
  @$pb.TagNumber(100)
  $core.bool hasDetailsSet() => $_has(7);
  @$pb.TagNumber(100)
  void clearDetailsSet() => $_clearField(100);
  @$pb.TagNumber(100)
  Change_DetailsSet ensureDetailsSet() => $_ensure(7);

  @$pb.TagNumber(101)
  Change_DetailsUnset get detailsUnset => $_getN(8);
  @$pb.TagNumber(101)
  set detailsUnset(Change_DetailsUnset value) => $_setField(101, value);
  @$pb.TagNumber(101)
  $core.bool hasDetailsUnset() => $_has(8);
  @$pb.TagNumber(101)
  void clearDetailsUnset() => $_clearField(101);
  @$pb.TagNumber(101)
  Change_DetailsUnset ensureDetailsUnset() => $_ensure(8);

  @$pb.TagNumber(105)
  Change_ObjectTypeAdd get objectTypeAdd => $_getN(9);
  @$pb.TagNumber(105)
  set objectTypeAdd(Change_ObjectTypeAdd value) => $_setField(105, value);
  @$pb.TagNumber(105)
  $core.bool hasObjectTypeAdd() => $_has(9);
  @$pb.TagNumber(105)
  void clearObjectTypeAdd() => $_clearField(105);
  @$pb.TagNumber(105)
  Change_ObjectTypeAdd ensureObjectTypeAdd() => $_ensure(9);

  @$pb.TagNumber(106)
  Change_ObjectTypeRemove get objectTypeRemove => $_getN(10);
  @$pb.TagNumber(106)
  set objectTypeRemove(Change_ObjectTypeRemove value) => $_setField(106, value);
  @$pb.TagNumber(106)
  $core.bool hasObjectTypeRemove() => $_has(10);
  @$pb.TagNumber(106)
  void clearObjectTypeRemove() => $_clearField(106);
  @$pb.TagNumber(106)
  Change_ObjectTypeRemove ensureObjectTypeRemove() => $_ensure(10);

  @$pb.TagNumber(107)
  Change_StoreKeySet get storeKeySet => $_getN(11);
  @$pb.TagNumber(107)
  set storeKeySet(Change_StoreKeySet value) => $_setField(107, value);
  @$pb.TagNumber(107)
  $core.bool hasStoreKeySet() => $_has(11);
  @$pb.TagNumber(107)
  void clearStoreKeySet() => $_clearField(107);
  @$pb.TagNumber(107)
  Change_StoreKeySet ensureStoreKeySet() => $_ensure(11);

  @$pb.TagNumber(108)
  Change_StoreKeyUnset get storeKeyUnset => $_getN(12);
  @$pb.TagNumber(108)
  set storeKeyUnset(Change_StoreKeyUnset value) => $_setField(108, value);
  @$pb.TagNumber(108)
  $core.bool hasStoreKeyUnset() => $_has(12);
  @$pb.TagNumber(108)
  void clearStoreKeyUnset() => $_clearField(108);
  @$pb.TagNumber(108)
  Change_StoreKeyUnset ensureStoreKeyUnset() => $_ensure(12);

  @$pb.TagNumber(109)
  Change_StoreSliceUpdate get storeSliceUpdate => $_getN(13);
  @$pb.TagNumber(109)
  set storeSliceUpdate(Change_StoreSliceUpdate value) => $_setField(109, value);
  @$pb.TagNumber(109)
  $core.bool hasStoreSliceUpdate() => $_has(13);
  @$pb.TagNumber(109)
  void clearStoreSliceUpdate() => $_clearField(109);
  @$pb.TagNumber(109)
  Change_StoreSliceUpdate ensureStoreSliceUpdate() => $_ensure(13);

  @$pb.TagNumber(110)
  Change_OriginalCreatedTimestampSet get originalCreatedTimestampSet =>
      $_getN(14);
  @$pb.TagNumber(110)
  set originalCreatedTimestampSet(Change_OriginalCreatedTimestampSet value) =>
      $_setField(110, value);
  @$pb.TagNumber(110)
  $core.bool hasOriginalCreatedTimestampSet() => $_has(14);
  @$pb.TagNumber(110)
  void clearOriginalCreatedTimestampSet() => $_clearField(110);
  @$pb.TagNumber(110)
  Change_OriginalCreatedTimestampSet ensureOriginalCreatedTimestampSet() =>
      $_ensure(14);

  @$pb.TagNumber(111)
  Change_SetFileInfo get setFileInfo => $_getN(15);
  @$pb.TagNumber(111)
  set setFileInfo(Change_SetFileInfo value) => $_setField(111, value);
  @$pb.TagNumber(111)
  $core.bool hasSetFileInfo() => $_has(15);
  @$pb.TagNumber(111)
  void clearSetFileInfo() => $_clearField(111);
  @$pb.TagNumber(111)
  Change_SetFileInfo ensureSetFileInfo() => $_ensure(15);

  @$pb.TagNumber(112)
  Change_NotificationCreate get notificationCreate => $_getN(16);
  @$pb.TagNumber(112)
  set notificationCreate(Change_NotificationCreate value) =>
      $_setField(112, value);
  @$pb.TagNumber(112)
  $core.bool hasNotificationCreate() => $_has(16);
  @$pb.TagNumber(112)
  void clearNotificationCreate() => $_clearField(112);
  @$pb.TagNumber(112)
  Change_NotificationCreate ensureNotificationCreate() => $_ensure(16);

  @$pb.TagNumber(113)
  Change_NotificationUpdate get notificationUpdate => $_getN(17);
  @$pb.TagNumber(113)
  set notificationUpdate(Change_NotificationUpdate value) =>
      $_setField(113, value);
  @$pb.TagNumber(113)
  $core.bool hasNotificationUpdate() => $_has(17);
  @$pb.TagNumber(113)
  void clearNotificationUpdate() => $_clearField(113);
  @$pb.TagNumber(113)
  Change_NotificationUpdate ensureNotificationUpdate() => $_ensure(17);

  @$pb.TagNumber(114)
  Change_DeviceAdd get deviceAdd => $_getN(18);
  @$pb.TagNumber(114)
  set deviceAdd(Change_DeviceAdd value) => $_setField(114, value);
  @$pb.TagNumber(114)
  $core.bool hasDeviceAdd() => $_has(18);
  @$pb.TagNumber(114)
  void clearDeviceAdd() => $_clearField(114);
  @$pb.TagNumber(114)
  Change_DeviceAdd ensureDeviceAdd() => $_ensure(18);

  @$pb.TagNumber(115)
  Change_DeviceUpdate get deviceUpdate => $_getN(19);
  @$pb.TagNumber(115)
  set deviceUpdate(Change_DeviceUpdate value) => $_setField(115, value);
  @$pb.TagNumber(115)
  $core.bool hasDeviceUpdate() => $_has(19);
  @$pb.TagNumber(115)
  void clearDeviceUpdate() => $_clearField(115);
  @$pb.TagNumber(115)
  Change_DeviceUpdate ensureDeviceUpdate() => $_ensure(19);
}

class Change_BlockCreate extends $pb.GeneratedMessage {
  factory Change_BlockCreate({
    $core.String? targetId,
    $0.Block_Position? position,
    $core.Iterable<$0.Block>? blocks,
  }) {
    final result = create();
    if (targetId != null) result.targetId = targetId;
    if (position != null) result.position = position;
    if (blocks != null) result.blocks.addAll(blocks);
    return result;
  }

  Change_BlockCreate._();

  factory Change_BlockCreate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_BlockCreate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.BlockCreate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'targetId', protoName: 'targetId')
    ..aE<$0.Block_Position>(2, _omitFieldNames ? '' : 'position',
        enumValues: $0.Block_Position.values)
    ..pPM<$0.Block>(3, _omitFieldNames ? '' : 'blocks',
        subBuilder: $0.Block.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockCreate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockCreate copyWith(void Function(Change_BlockCreate) updates) =>
      super.copyWith((message) => updates(message as Change_BlockCreate))
          as Change_BlockCreate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_BlockCreate create() => Change_BlockCreate._();
  @$core.override
  Change_BlockCreate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_BlockCreate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_BlockCreate>(create);
  static Change_BlockCreate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get targetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Block_Position get position => $_getN(1);
  @$pb.TagNumber(2)
  set position($0.Block_Position value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearPosition() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$0.Block> get blocks => $_getList(2);
}

class Change_BlockUpdate extends $pb.GeneratedMessage {
  factory Change_BlockUpdate({
    $core.Iterable<$core.List<$core.int>>? events,
  }) {
    final result = create();
    if (events != null) result.events.addAll(events);
    return result;
  }

  Change_BlockUpdate._();

  factory Change_BlockUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_BlockUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.BlockUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..p<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'events', $pb.PbFieldType.PY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockUpdate copyWith(void Function(Change_BlockUpdate) updates) =>
      super.copyWith((message) => updates(message as Change_BlockUpdate))
          as Change_BlockUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_BlockUpdate create() => Change_BlockUpdate._();
  @$core.override
  Change_BlockUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_BlockUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_BlockUpdate>(create);
  static Change_BlockUpdate? _defaultInstance;

  /// Original: repeated Event.Message events = 2;
  /// Event.Message is from events.proto (1125 lines) -- not needed for v1.
  /// Raw event bytes preserved for forward compatibility.
  @$pb.TagNumber(2)
  $pb.PbList<$core.List<$core.int>> get events => $_getList(0);
}

class Change_BlockRemove extends $pb.GeneratedMessage {
  factory Change_BlockRemove({
    $core.Iterable<$core.String>? ids,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  Change_BlockRemove._();

  factory Change_BlockRemove.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_BlockRemove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.BlockRemove',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'ids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockRemove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockRemove copyWith(void Function(Change_BlockRemove) updates) =>
      super.copyWith((message) => updates(message as Change_BlockRemove))
          as Change_BlockRemove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_BlockRemove create() => Change_BlockRemove._();
  @$core.override
  Change_BlockRemove createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_BlockRemove getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_BlockRemove>(create);
  static Change_BlockRemove? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get ids => $_getList(0);
}

class Change_BlockMove extends $pb.GeneratedMessage {
  factory Change_BlockMove({
    $core.String? targetId,
    $0.Block_Position? position,
    $core.Iterable<$core.String>? ids,
  }) {
    final result = create();
    if (targetId != null) result.targetId = targetId;
    if (position != null) result.position = position;
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  Change_BlockMove._();

  factory Change_BlockMove.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_BlockMove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.BlockMove',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'targetId', protoName: 'targetId')
    ..aE<$0.Block_Position>(2, _omitFieldNames ? '' : 'position',
        enumValues: $0.Block_Position.values)
    ..pPS(3, _omitFieldNames ? '' : 'ids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockMove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockMove copyWith(void Function(Change_BlockMove) updates) =>
      super.copyWith((message) => updates(message as Change_BlockMove))
          as Change_BlockMove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_BlockMove create() => Change_BlockMove._();
  @$core.override
  Change_BlockMove createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_BlockMove getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_BlockMove>(create);
  static Change_BlockMove? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get targetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Block_Position get position => $_getN(1);
  @$pb.TagNumber(2)
  set position($0.Block_Position value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearPosition() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get ids => $_getList(2);
}

class Change_BlockDuplicate extends $pb.GeneratedMessage {
  factory Change_BlockDuplicate({
    $core.String? targetId,
    $0.Block_Position? position,
    $core.Iterable<$core.String>? ids,
  }) {
    final result = create();
    if (targetId != null) result.targetId = targetId;
    if (position != null) result.position = position;
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  Change_BlockDuplicate._();

  factory Change_BlockDuplicate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_BlockDuplicate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.BlockDuplicate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'targetId', protoName: 'targetId')
    ..aE<$0.Block_Position>(2, _omitFieldNames ? '' : 'position',
        enumValues: $0.Block_Position.values)
    ..pPS(3, _omitFieldNames ? '' : 'ids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockDuplicate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_BlockDuplicate copyWith(
          void Function(Change_BlockDuplicate) updates) =>
      super.copyWith((message) => updates(message as Change_BlockDuplicate))
          as Change_BlockDuplicate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_BlockDuplicate create() => Change_BlockDuplicate._();
  @$core.override
  Change_BlockDuplicate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_BlockDuplicate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_BlockDuplicate>(create);
  static Change_BlockDuplicate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get targetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Block_Position get position => $_getN(1);
  @$pb.TagNumber(2)
  set position($0.Block_Position value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearPosition() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get ids => $_getList(2);
}

class Change_DetailsSet extends $pb.GeneratedMessage {
  factory Change_DetailsSet({
    $core.String? key,
    $1.Value? value,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (value != null) result.value = value;
    return result;
  }

  Change_DetailsSet._();

  factory Change_DetailsSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_DetailsSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.DetailsSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOM<$1.Value>(2, _omitFieldNames ? '' : 'value',
        subBuilder: $1.Value.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_DetailsSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_DetailsSet copyWith(void Function(Change_DetailsSet) updates) =>
      super.copyWith((message) => updates(message as Change_DetailsSet))
          as Change_DetailsSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_DetailsSet create() => Change_DetailsSet._();
  @$core.override
  Change_DetailsSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_DetailsSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_DetailsSet>(create);
  static Change_DetailsSet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Value get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($1.Value value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Value ensureValue() => $_ensure(1);
}

class Change_DetailsUnset extends $pb.GeneratedMessage {
  factory Change_DetailsUnset({
    $core.String? key,
  }) {
    final result = create();
    if (key != null) result.key = key;
    return result;
  }

  Change_DetailsUnset._();

  factory Change_DetailsUnset.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_DetailsUnset.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.DetailsUnset',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_DetailsUnset clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_DetailsUnset copyWith(void Function(Change_DetailsUnset) updates) =>
      super.copyWith((message) => updates(message as Change_DetailsUnset))
          as Change_DetailsUnset;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_DetailsUnset create() => Change_DetailsUnset._();
  @$core.override
  Change_DetailsUnset createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_DetailsUnset getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_DetailsUnset>(create);
  static Change_DetailsUnset? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);
}

class Change_RelationAdd extends $pb.GeneratedMessage {
  factory Change_RelationAdd({
    $core.Iterable<$0.RelationLink>? relationLinks,
  }) {
    final result = create();
    if (relationLinks != null) result.relationLinks.addAll(relationLinks);
    return result;
  }

  Change_RelationAdd._();

  factory Change_RelationAdd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_RelationAdd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.RelationAdd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<$0.RelationLink>(1, _omitFieldNames ? '' : 'relationLinks',
        protoName: 'relationLinks', subBuilder: $0.RelationLink.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_RelationAdd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_RelationAdd copyWith(void Function(Change_RelationAdd) updates) =>
      super.copyWith((message) => updates(message as Change_RelationAdd))
          as Change_RelationAdd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_RelationAdd create() => Change_RelationAdd._();
  @$core.override
  Change_RelationAdd createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_RelationAdd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_RelationAdd>(create);
  static Change_RelationAdd? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.RelationLink> get relationLinks => $_getList(0);
}

class Change_RelationRemove extends $pb.GeneratedMessage {
  factory Change_RelationRemove({
    $core.Iterable<$core.String>? relationKey,
  }) {
    final result = create();
    if (relationKey != null) result.relationKey.addAll(relationKey);
    return result;
  }

  Change_RelationRemove._();

  factory Change_RelationRemove.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_RelationRemove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.RelationRemove',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'relationKey', protoName: 'relationKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_RelationRemove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_RelationRemove copyWith(
          void Function(Change_RelationRemove) updates) =>
      super.copyWith((message) => updates(message as Change_RelationRemove))
          as Change_RelationRemove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_RelationRemove create() => Change_RelationRemove._();
  @$core.override
  Change_RelationRemove createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_RelationRemove getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_RelationRemove>(create);
  static Change_RelationRemove? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get relationKey => $_getList(0);
}

class Change_ObjectTypeAdd extends $pb.GeneratedMessage {
  factory Change_ObjectTypeAdd({
    $core.String? url,
    $core.String? key,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (key != null) result.key = key;
    return result;
  }

  Change_ObjectTypeAdd._();

  factory Change_ObjectTypeAdd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_ObjectTypeAdd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.ObjectTypeAdd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_ObjectTypeAdd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_ObjectTypeAdd copyWith(void Function(Change_ObjectTypeAdd) updates) =>
      super.copyWith((message) => updates(message as Change_ObjectTypeAdd))
          as Change_ObjectTypeAdd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_ObjectTypeAdd create() => Change_ObjectTypeAdd._();
  @$core.override
  Change_ObjectTypeAdd createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_ObjectTypeAdd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_ObjectTypeAdd>(create);
  static Change_ObjectTypeAdd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);
}

class Change_ObjectTypeRemove extends $pb.GeneratedMessage {
  factory Change_ObjectTypeRemove({
    $core.String? url,
    $core.String? key,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (key != null) result.key = key;
    return result;
  }

  Change_ObjectTypeRemove._();

  factory Change_ObjectTypeRemove.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_ObjectTypeRemove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.ObjectTypeRemove',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_ObjectTypeRemove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_ObjectTypeRemove copyWith(
          void Function(Change_ObjectTypeRemove) updates) =>
      super.copyWith((message) => updates(message as Change_ObjectTypeRemove))
          as Change_ObjectTypeRemove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_ObjectTypeRemove create() => Change_ObjectTypeRemove._();
  @$core.override
  Change_ObjectTypeRemove createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_ObjectTypeRemove getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_ObjectTypeRemove>(create);
  static Change_ObjectTypeRemove? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);
}

class Change_StoreKeySet extends $pb.GeneratedMessage {
  factory Change_StoreKeySet({
    $core.Iterable<$core.String>? path,
    $1.Value? value,
  }) {
    final result = create();
    if (path != null) result.path.addAll(path);
    if (value != null) result.value = value;
    return result;
  }

  Change_StoreKeySet._();

  factory Change_StoreKeySet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_StoreKeySet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.StoreKeySet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'path')
    ..aOM<$1.Value>(2, _omitFieldNames ? '' : 'value',
        subBuilder: $1.Value.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreKeySet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreKeySet copyWith(void Function(Change_StoreKeySet) updates) =>
      super.copyWith((message) => updates(message as Change_StoreKeySet))
          as Change_StoreKeySet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_StoreKeySet create() => Change_StoreKeySet._();
  @$core.override
  Change_StoreKeySet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_StoreKeySet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_StoreKeySet>(create);
  static Change_StoreKeySet? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get path => $_getList(0);

  @$pb.TagNumber(2)
  $1.Value get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($1.Value value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Value ensureValue() => $_ensure(1);
}

class Change_StoreKeyUnset extends $pb.GeneratedMessage {
  factory Change_StoreKeyUnset({
    $core.Iterable<$core.String>? path,
  }) {
    final result = create();
    if (path != null) result.path.addAll(path);
    return result;
  }

  Change_StoreKeyUnset._();

  factory Change_StoreKeyUnset.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_StoreKeyUnset.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.StoreKeyUnset',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'path')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreKeyUnset clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreKeyUnset copyWith(void Function(Change_StoreKeyUnset) updates) =>
      super.copyWith((message) => updates(message as Change_StoreKeyUnset))
          as Change_StoreKeyUnset;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_StoreKeyUnset create() => Change_StoreKeyUnset._();
  @$core.override
  Change_StoreKeyUnset createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_StoreKeyUnset getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_StoreKeyUnset>(create);
  static Change_StoreKeyUnset? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get path => $_getList(0);
}

class Change_StoreSliceUpdate_Add extends $pb.GeneratedMessage {
  factory Change_StoreSliceUpdate_Add({
    $core.String? afterId,
    $core.Iterable<$core.String>? ids,
  }) {
    final result = create();
    if (afterId != null) result.afterId = afterId;
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  Change_StoreSliceUpdate_Add._();

  factory Change_StoreSliceUpdate_Add.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_StoreSliceUpdate_Add.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.StoreSliceUpdate.Add',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'afterId', protoName: 'afterId')
    ..pPS(2, _omitFieldNames ? '' : 'ids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreSliceUpdate_Add clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreSliceUpdate_Add copyWith(
          void Function(Change_StoreSliceUpdate_Add) updates) =>
      super.copyWith(
              (message) => updates(message as Change_StoreSliceUpdate_Add))
          as Change_StoreSliceUpdate_Add;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_StoreSliceUpdate_Add create() =>
      Change_StoreSliceUpdate_Add._();
  @$core.override
  Change_StoreSliceUpdate_Add createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_StoreSliceUpdate_Add getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_StoreSliceUpdate_Add>(create);
  static Change_StoreSliceUpdate_Add? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get afterId => $_getSZ(0);
  @$pb.TagNumber(1)
  set afterId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAfterId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAfterId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get ids => $_getList(1);
}

class Change_StoreSliceUpdate_Remove extends $pb.GeneratedMessage {
  factory Change_StoreSliceUpdate_Remove({
    $core.Iterable<$core.String>? ids,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  Change_StoreSliceUpdate_Remove._();

  factory Change_StoreSliceUpdate_Remove.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_StoreSliceUpdate_Remove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.StoreSliceUpdate.Remove',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'ids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreSliceUpdate_Remove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreSliceUpdate_Remove copyWith(
          void Function(Change_StoreSliceUpdate_Remove) updates) =>
      super.copyWith(
              (message) => updates(message as Change_StoreSliceUpdate_Remove))
          as Change_StoreSliceUpdate_Remove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_StoreSliceUpdate_Remove create() =>
      Change_StoreSliceUpdate_Remove._();
  @$core.override
  Change_StoreSliceUpdate_Remove createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_StoreSliceUpdate_Remove getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_StoreSliceUpdate_Remove>(create);
  static Change_StoreSliceUpdate_Remove? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get ids => $_getList(0);
}

class Change_StoreSliceUpdate_Move extends $pb.GeneratedMessage {
  factory Change_StoreSliceUpdate_Move({
    $core.String? afterId,
    $core.Iterable<$core.String>? ids,
  }) {
    final result = create();
    if (afterId != null) result.afterId = afterId;
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  Change_StoreSliceUpdate_Move._();

  factory Change_StoreSliceUpdate_Move.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_StoreSliceUpdate_Move.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.StoreSliceUpdate.Move',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'afterId', protoName: 'afterId')
    ..pPS(2, _omitFieldNames ? '' : 'ids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreSliceUpdate_Move clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreSliceUpdate_Move copyWith(
          void Function(Change_StoreSliceUpdate_Move) updates) =>
      super.copyWith(
              (message) => updates(message as Change_StoreSliceUpdate_Move))
          as Change_StoreSliceUpdate_Move;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_StoreSliceUpdate_Move create() =>
      Change_StoreSliceUpdate_Move._();
  @$core.override
  Change_StoreSliceUpdate_Move createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_StoreSliceUpdate_Move getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_StoreSliceUpdate_Move>(create);
  static Change_StoreSliceUpdate_Move? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get afterId => $_getSZ(0);
  @$pb.TagNumber(1)
  set afterId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAfterId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAfterId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get ids => $_getList(1);
}

enum Change_StoreSliceUpdate_Operation { add, remove, move, notSet }

class Change_StoreSliceUpdate extends $pb.GeneratedMessage {
  factory Change_StoreSliceUpdate({
    $core.String? key,
    Change_StoreSliceUpdate_Add? add,
    Change_StoreSliceUpdate_Remove? remove,
    Change_StoreSliceUpdate_Move? move,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (add != null) result.add = add;
    if (remove != null) result.remove = remove;
    if (move != null) result.move = move;
    return result;
  }

  Change_StoreSliceUpdate._();

  factory Change_StoreSliceUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_StoreSliceUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Change_StoreSliceUpdate_Operation>
      _Change_StoreSliceUpdate_OperationByTag = {
    2: Change_StoreSliceUpdate_Operation.add,
    3: Change_StoreSliceUpdate_Operation.remove,
    4: Change_StoreSliceUpdate_Operation.move,
    0: Change_StoreSliceUpdate_Operation.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.StoreSliceUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..oo(0, [2, 3, 4])
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOM<Change_StoreSliceUpdate_Add>(2, _omitFieldNames ? '' : 'add',
        subBuilder: Change_StoreSliceUpdate_Add.create)
    ..aOM<Change_StoreSliceUpdate_Remove>(3, _omitFieldNames ? '' : 'remove',
        subBuilder: Change_StoreSliceUpdate_Remove.create)
    ..aOM<Change_StoreSliceUpdate_Move>(4, _omitFieldNames ? '' : 'move',
        subBuilder: Change_StoreSliceUpdate_Move.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreSliceUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_StoreSliceUpdate copyWith(
          void Function(Change_StoreSliceUpdate) updates) =>
      super.copyWith((message) => updates(message as Change_StoreSliceUpdate))
          as Change_StoreSliceUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_StoreSliceUpdate create() => Change_StoreSliceUpdate._();
  @$core.override
  Change_StoreSliceUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_StoreSliceUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_StoreSliceUpdate>(create);
  static Change_StoreSliceUpdate? _defaultInstance;

  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  Change_StoreSliceUpdate_Operation whichOperation() =>
      _Change_StoreSliceUpdate_OperationByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  void clearOperation() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  Change_StoreSliceUpdate_Add get add => $_getN(1);
  @$pb.TagNumber(2)
  set add(Change_StoreSliceUpdate_Add value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAdd() => $_has(1);
  @$pb.TagNumber(2)
  void clearAdd() => $_clearField(2);
  @$pb.TagNumber(2)
  Change_StoreSliceUpdate_Add ensureAdd() => $_ensure(1);

  @$pb.TagNumber(3)
  Change_StoreSliceUpdate_Remove get remove => $_getN(2);
  @$pb.TagNumber(3)
  set remove(Change_StoreSliceUpdate_Remove value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRemove() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemove() => $_clearField(3);
  @$pb.TagNumber(3)
  Change_StoreSliceUpdate_Remove ensureRemove() => $_ensure(2);

  @$pb.TagNumber(4)
  Change_StoreSliceUpdate_Move get move => $_getN(3);
  @$pb.TagNumber(4)
  set move(Change_StoreSliceUpdate_Move value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMove() => $_has(3);
  @$pb.TagNumber(4)
  void clearMove() => $_clearField(4);
  @$pb.TagNumber(4)
  Change_StoreSliceUpdate_Move ensureMove() => $_ensure(3);
}

class Change_OriginalCreatedTimestampSet extends $pb.GeneratedMessage {
  factory Change_OriginalCreatedTimestampSet({
    $fixnum.Int64? ts,
  }) {
    final result = create();
    if (ts != null) result.ts = ts;
    return result;
  }

  Change_OriginalCreatedTimestampSet._();

  factory Change_OriginalCreatedTimestampSet.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_OriginalCreatedTimestampSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.OriginalCreatedTimestampSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'ts')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_OriginalCreatedTimestampSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_OriginalCreatedTimestampSet copyWith(
          void Function(Change_OriginalCreatedTimestampSet) updates) =>
      super.copyWith((message) =>
              updates(message as Change_OriginalCreatedTimestampSet))
          as Change_OriginalCreatedTimestampSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_OriginalCreatedTimestampSet create() =>
      Change_OriginalCreatedTimestampSet._();
  @$core.override
  Change_OriginalCreatedTimestampSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_OriginalCreatedTimestampSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_OriginalCreatedTimestampSet>(
          create);
  static Change_OriginalCreatedTimestampSet? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get ts => $_getI64(0);
  @$pb.TagNumber(1)
  set ts($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTs() => $_has(0);
  @$pb.TagNumber(1)
  void clearTs() => $_clearField(1);
}

class Change_SetFileInfo extends $pb.GeneratedMessage {
  factory Change_SetFileInfo({
    $0.FileInfo? fileInfo,
  }) {
    final result = create();
    if (fileInfo != null) result.fileInfo = fileInfo;
    return result;
  }

  Change_SetFileInfo._();

  factory Change_SetFileInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_SetFileInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.SetFileInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOM<$0.FileInfo>(1, _omitFieldNames ? '' : 'fileInfo',
        protoName: 'fileInfo', subBuilder: $0.FileInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_SetFileInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_SetFileInfo copyWith(void Function(Change_SetFileInfo) updates) =>
      super.copyWith((message) => updates(message as Change_SetFileInfo))
          as Change_SetFileInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_SetFileInfo create() => Change_SetFileInfo._();
  @$core.override
  Change_SetFileInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_SetFileInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_SetFileInfo>(create);
  static Change_SetFileInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $0.FileInfo get fileInfo => $_getN(0);
  @$pb.TagNumber(1)
  set fileInfo($0.FileInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFileInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.FileInfo ensureFileInfo() => $_ensure(0);
}

class Change_NotificationCreate extends $pb.GeneratedMessage {
  factory Change_NotificationCreate({
    $0.Notification? notification,
  }) {
    final result = create();
    if (notification != null) result.notification = notification;
    return result;
  }

  Change_NotificationCreate._();

  factory Change_NotificationCreate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_NotificationCreate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.NotificationCreate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOM<$0.Notification>(1, _omitFieldNames ? '' : 'notification',
        subBuilder: $0.Notification.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_NotificationCreate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_NotificationCreate copyWith(
          void Function(Change_NotificationCreate) updates) =>
      super.copyWith((message) => updates(message as Change_NotificationCreate))
          as Change_NotificationCreate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_NotificationCreate create() => Change_NotificationCreate._();
  @$core.override
  Change_NotificationCreate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_NotificationCreate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_NotificationCreate>(create);
  static Change_NotificationCreate? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Notification get notification => $_getN(0);
  @$pb.TagNumber(1)
  set notification($0.Notification value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNotification() => $_has(0);
  @$pb.TagNumber(1)
  void clearNotification() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Notification ensureNotification() => $_ensure(0);
}

class Change_NotificationUpdate extends $pb.GeneratedMessage {
  factory Change_NotificationUpdate({
    $core.String? id,
    $0.Notification_Status? status,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (status != null) result.status = status;
    return result;
  }

  Change_NotificationUpdate._();

  factory Change_NotificationUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_NotificationUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.NotificationUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<$0.Notification_Status>(2, _omitFieldNames ? '' : 'status',
        enumValues: $0.Notification_Status.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_NotificationUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_NotificationUpdate copyWith(
          void Function(Change_NotificationUpdate) updates) =>
      super.copyWith((message) => updates(message as Change_NotificationUpdate))
          as Change_NotificationUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_NotificationUpdate create() => Change_NotificationUpdate._();
  @$core.override
  Change_NotificationUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_NotificationUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_NotificationUpdate>(create);
  static Change_NotificationUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Notification_Status get status => $_getN(1);
  @$pb.TagNumber(2)
  set status($0.Notification_Status value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
}

class Change_DeviceAdd extends $pb.GeneratedMessage {
  factory Change_DeviceAdd({
    $0.DeviceInfo? device,
  }) {
    final result = create();
    if (device != null) result.device = device;
    return result;
  }

  Change_DeviceAdd._();

  factory Change_DeviceAdd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_DeviceAdd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.DeviceAdd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOM<$0.DeviceInfo>(1, _omitFieldNames ? '' : 'device',
        subBuilder: $0.DeviceInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_DeviceAdd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_DeviceAdd copyWith(void Function(Change_DeviceAdd) updates) =>
      super.copyWith((message) => updates(message as Change_DeviceAdd))
          as Change_DeviceAdd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_DeviceAdd create() => Change_DeviceAdd._();
  @$core.override
  Change_DeviceAdd createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_DeviceAdd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_DeviceAdd>(create);
  static Change_DeviceAdd? _defaultInstance;

  @$pb.TagNumber(1)
  $0.DeviceInfo get device => $_getN(0);
  @$pb.TagNumber(1)
  set device($0.DeviceInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.DeviceInfo ensureDevice() => $_ensure(0);
}

class Change_DeviceUpdate extends $pb.GeneratedMessage {
  factory Change_DeviceUpdate({
    $core.String? id,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  Change_DeviceUpdate._();

  factory Change_DeviceUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change_DeviceUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change.DeviceUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_DeviceUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change_DeviceUpdate copyWith(void Function(Change_DeviceUpdate) updates) =>
      super.copyWith((message) => updates(message as Change_DeviceUpdate))
          as Change_DeviceUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change_DeviceUpdate create() => Change_DeviceUpdate._();
  @$core.override
  Change_DeviceUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change_DeviceUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Change_DeviceUpdate>(create);
  static Change_DeviceUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

/// the element of change tree used to store and internal apply smartBlock history
class Change extends $pb.GeneratedMessage {
  factory Change({
    $core.Iterable<Change_Content>? content,
    Change_Snapshot? snapshot,
    $core.Iterable<Change_FileKeys>? fileKeys,
    $fixnum.Int64? timestamp,
    $core.int? version,
    $core.int? changeType,
  }) {
    final result = create();
    if (content != null) result.content.addAll(content);
    if (snapshot != null) result.snapshot = snapshot;
    if (fileKeys != null) result.fileKeys.addAll(fileKeys);
    if (timestamp != null) result.timestamp = timestamp;
    if (version != null) result.version = version;
    if (changeType != null) result.changeType = changeType;
    return result;
  }

  Change._();

  factory Change.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Change.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Change',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<Change_Content>(3, _omitFieldNames ? '' : 'content',
        subBuilder: Change_Content.create)
    ..aOM<Change_Snapshot>(4, _omitFieldNames ? '' : 'snapshot',
        subBuilder: Change_Snapshot.create)
    ..pPM<Change_FileKeys>(6, _omitFieldNames ? '' : 'fileKeys',
        protoName: 'fileKeys', subBuilder: Change_FileKeys.create)
    ..aInt64(7, _omitFieldNames ? '' : 'timestamp')
    ..aI(8, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'changeType',
        protoName: 'changeType', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change copyWith(void Function(Change) updates) =>
      super.copyWith((message) => updates(message as Change)) as Change;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Change create() => Change._();
  @$core.override
  Change createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Change getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Change>(create);
  static Change? _defaultInstance;

  /// set of actions to apply
  @$pb.TagNumber(3)
  $pb.PbList<Change_Content> get content => $_getList(0);

  /// snapshot - when not null, the Content will be ignored
  @$pb.TagNumber(4)
  Change_Snapshot get snapshot => $_getN(1);
  @$pb.TagNumber(4)
  set snapshot(Change_Snapshot value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSnapshot() => $_has(1);
  @$pb.TagNumber(4)
  void clearSnapshot() => $_clearField(4);
  @$pb.TagNumber(4)
  Change_Snapshot ensureSnapshot() => $_ensure(1);

  /// file keys related to changes content
  @$pb.TagNumber(6)
  $pb.PbList<Change_FileKeys> get fileKeys => $_getList(2);

  /// creation timestamp
  @$pb.TagNumber(7)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(7)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(7)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(7)
  void clearTimestamp() => $_clearField(7);

  /// version of business logic
  @$pb.TagNumber(8)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(8)
  set version($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);

  /// business-level type of change applied to object
  @$pb.TagNumber(9)
  $core.int get changeType => $_getIZ(5);
  @$pb.TagNumber(9)
  set changeType($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(9)
  $core.bool hasChangeType() => $_has(5);
  @$pb.TagNumber(9)
  void clearChangeType() => $_clearField(9);
}

class ChangeNoSnapshot extends $pb.GeneratedMessage {
  factory ChangeNoSnapshot({
    $core.Iterable<Change_Content>? content,
    $core.Iterable<Change_FileKeys>? fileKeys,
    $fixnum.Int64? timestamp,
    $core.int? version,
    $core.int? changeType,
  }) {
    final result = create();
    if (content != null) result.content.addAll(content);
    if (fileKeys != null) result.fileKeys.addAll(fileKeys);
    if (timestamp != null) result.timestamp = timestamp;
    if (version != null) result.version = version;
    if (changeType != null) result.changeType = changeType;
    return result;
  }

  ChangeNoSnapshot._();

  factory ChangeNoSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangeNoSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangeNoSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<Change_Content>(3, _omitFieldNames ? '' : 'content',
        subBuilder: Change_Content.create)
    ..pPM<Change_FileKeys>(6, _omitFieldNames ? '' : 'fileKeys',
        protoName: 'fileKeys', subBuilder: Change_FileKeys.create)
    ..aInt64(7, _omitFieldNames ? '' : 'timestamp')
    ..aI(8, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'changeType',
        protoName: 'changeType', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeNoSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeNoSnapshot copyWith(void Function(ChangeNoSnapshot) updates) =>
      super.copyWith((message) => updates(message as ChangeNoSnapshot))
          as ChangeNoSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeNoSnapshot create() => ChangeNoSnapshot._();
  @$core.override
  ChangeNoSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChangeNoSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangeNoSnapshot>(create);
  static ChangeNoSnapshot? _defaultInstance;

  /// set of actions to apply
  @$pb.TagNumber(3)
  $pb.PbList<Change_Content> get content => $_getList(0);

  /// file keys related to changes content
  @$pb.TagNumber(6)
  $pb.PbList<Change_FileKeys> get fileKeys => $_getList(1);

  /// creation timestamp
  @$pb.TagNumber(7)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(7)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(7)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(7)
  void clearTimestamp() => $_clearField(7);

  /// version of business logic
  @$pb.TagNumber(8)
  $core.int get version => $_getIZ(3);
  @$pb.TagNumber(8)
  set version($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);

  /// business-level type of change applied to object
  @$pb.TagNumber(9)
  $core.int get changeType => $_getIZ(4);
  @$pb.TagNumber(9)
  set changeType($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(9)
  $core.bool hasChangeType() => $_has(4);
  @$pb.TagNumber(9)
  void clearChangeType() => $_clearField(9);
}

class StoreChange extends $pb.GeneratedMessage {
  factory StoreChange({
    $core.Iterable<StoreChangeContent>? changeSet,
  }) {
    final result = create();
    if (changeSet != null) result.changeSet.addAll(changeSet);
    return result;
  }

  StoreChange._();

  factory StoreChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StoreChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StoreChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<StoreChangeContent>(1, _omitFieldNames ? '' : 'changeSet',
        protoName: 'changeSet', subBuilder: StoreChangeContent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreChange copyWith(void Function(StoreChange) updates) =>
      super.copyWith((message) => updates(message as StoreChange))
          as StoreChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreChange create() => StoreChange._();
  @$core.override
  StoreChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StoreChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreChange>(create);
  static StoreChange? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<StoreChangeContent> get changeSet => $_getList(0);
}

enum StoreChangeContent_Change { create_1, modify, delete, notSet }

class StoreChangeContent extends $pb.GeneratedMessage {
  factory StoreChangeContent({
    DocumentCreate? create_1,
    DocumentModify? modify,
    DocumentDelete? delete,
  }) {
    final result = create();
    if (create_1 != null) result.create_1 = create_1;
    if (modify != null) result.modify = modify;
    if (delete != null) result.delete = delete;
    return result;
  }

  StoreChangeContent._();

  factory StoreChangeContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StoreChangeContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, StoreChangeContent_Change>
      _StoreChangeContent_ChangeByTag = {
    1: StoreChangeContent_Change.create_1,
    2: StoreChangeContent_Change.modify,
    3: StoreChangeContent_Change.delete,
    0: StoreChangeContent_Change.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StoreChangeContent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<DocumentCreate>(1, _omitFieldNames ? '' : 'create',
        subBuilder: DocumentCreate.create)
    ..aOM<DocumentModify>(2, _omitFieldNames ? '' : 'modify',
        subBuilder: DocumentModify.create)
    ..aOM<DocumentDelete>(3, _omitFieldNames ? '' : 'delete',
        subBuilder: DocumentDelete.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreChangeContent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreChangeContent copyWith(void Function(StoreChangeContent) updates) =>
      super.copyWith((message) => updates(message as StoreChangeContent))
          as StoreChangeContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreChangeContent create() => StoreChangeContent._();
  @$core.override
  StoreChangeContent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StoreChangeContent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreChangeContent>(create);
  static StoreChangeContent? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  StoreChangeContent_Change whichChange() =>
      _StoreChangeContent_ChangeByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearChange() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  DocumentCreate get create_1 => $_getN(0);
  @$pb.TagNumber(1)
  set create_1(DocumentCreate value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCreate_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearCreate_1() => $_clearField(1);
  @$pb.TagNumber(1)
  DocumentCreate ensureCreate_1() => $_ensure(0);

  @$pb.TagNumber(2)
  DocumentModify get modify => $_getN(1);
  @$pb.TagNumber(2)
  set modify(DocumentModify value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasModify() => $_has(1);
  @$pb.TagNumber(2)
  void clearModify() => $_clearField(2);
  @$pb.TagNumber(2)
  DocumentModify ensureModify() => $_ensure(1);

  @$pb.TagNumber(3)
  DocumentDelete get delete => $_getN(2);
  @$pb.TagNumber(3)
  set delete(DocumentDelete value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDelete() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelete() => $_clearField(3);
  @$pb.TagNumber(3)
  DocumentDelete ensureDelete() => $_ensure(2);
}

class DocumentCreate extends $pb.GeneratedMessage {
  factory DocumentCreate({
    $core.String? collection,
    $core.String? documentId,
    $core.String? value,
  }) {
    final result = create();
    if (collection != null) result.collection = collection;
    if (documentId != null) result.documentId = documentId;
    if (value != null) result.value = value;
    return result;
  }

  DocumentCreate._();

  factory DocumentCreate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentCreate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentCreate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'collection')
    ..aOS(2, _omitFieldNames ? '' : 'documentId', protoName: 'documentId')
    ..aOS(3, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentCreate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentCreate copyWith(void Function(DocumentCreate) updates) =>
      super.copyWith((message) => updates(message as DocumentCreate))
          as DocumentCreate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentCreate create() => DocumentCreate._();
  @$core.override
  DocumentCreate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentCreate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentCreate>(create);
  static DocumentCreate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get collection => $_getSZ(0);
  @$pb.TagNumber(1)
  set collection($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCollection() => $_has(0);
  @$pb.TagNumber(1)
  void clearCollection() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get documentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set documentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocumentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocumentId() => $_clearField(2);

  /// json
  @$pb.TagNumber(3)
  $core.String get value => $_getSZ(2);
  @$pb.TagNumber(3)
  set value($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);
}

class DocumentModify extends $pb.GeneratedMessage {
  factory DocumentModify({
    $core.String? collection,
    $core.String? documentId,
    $core.Iterable<KeyModify>? keys,
  }) {
    final result = create();
    if (collection != null) result.collection = collection;
    if (documentId != null) result.documentId = documentId;
    if (keys != null) result.keys.addAll(keys);
    return result;
  }

  DocumentModify._();

  factory DocumentModify.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentModify.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentModify',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'collection')
    ..aOS(2, _omitFieldNames ? '' : 'documentId', protoName: 'documentId')
    ..pPM<KeyModify>(4, _omitFieldNames ? '' : 'keys',
        subBuilder: KeyModify.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentModify clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentModify copyWith(void Function(DocumentModify) updates) =>
      super.copyWith((message) => updates(message as DocumentModify))
          as DocumentModify;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentModify create() => DocumentModify._();
  @$core.override
  DocumentModify createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentModify getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentModify>(create);
  static DocumentModify? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get collection => $_getSZ(0);
  @$pb.TagNumber(1)
  set collection($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCollection() => $_has(0);
  @$pb.TagNumber(1)
  void clearCollection() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get documentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set documentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocumentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocumentId() => $_clearField(2);

  @$pb.TagNumber(4)
  $pb.PbList<KeyModify> get keys => $_getList(2);
}

class KeyModify extends $pb.GeneratedMessage {
  factory KeyModify({
    $core.Iterable<$core.String>? keyPath,
    ModifyOp? modifyOp,
    $core.String? modifyValue,
  }) {
    final result = create();
    if (keyPath != null) result.keyPath.addAll(keyPath);
    if (modifyOp != null) result.modifyOp = modifyOp;
    if (modifyValue != null) result.modifyValue = modifyValue;
    return result;
  }

  KeyModify._();

  factory KeyModify.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory KeyModify.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'KeyModify',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'keyPath', protoName: 'keyPath')
    ..aE<ModifyOp>(3, _omitFieldNames ? '' : 'modifyOp',
        protoName: 'modifyOp', enumValues: ModifyOp.values)
    ..aOS(4, _omitFieldNames ? '' : 'modifyValue', protoName: 'modifyValue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyModify clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  KeyModify copyWith(void Function(KeyModify) updates) =>
      super.copyWith((message) => updates(message as KeyModify)) as KeyModify;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyModify create() => KeyModify._();
  @$core.override
  KeyModify createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static KeyModify getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyModify>(create);
  static KeyModify? _defaultInstance;

  /// key path; example: [user, email]
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get keyPath => $_getList(0);

  /// modify op: set, unset, inc, etc.
  @$pb.TagNumber(3)
  ModifyOp get modifyOp => $_getN(1);
  @$pb.TagNumber(3)
  set modifyOp(ModifyOp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasModifyOp() => $_has(1);
  @$pb.TagNumber(3)
  void clearModifyOp() => $_clearField(3);

  /// json value; example: '"new@email.com"'
  @$pb.TagNumber(4)
  $core.String get modifyValue => $_getSZ(2);
  @$pb.TagNumber(4)
  set modifyValue($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasModifyValue() => $_has(2);
  @$pb.TagNumber(4)
  void clearModifyValue() => $_clearField(4);
}

class DocumentDelete extends $pb.GeneratedMessage {
  factory DocumentDelete({
    $core.String? collection,
    $core.String? documentId,
  }) {
    final result = create();
    if (collection != null) result.collection = collection;
    if (documentId != null) result.documentId = documentId;
    return result;
  }

  DocumentDelete._();

  factory DocumentDelete.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DocumentDelete.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DocumentDelete',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'collection')
    ..aOS(2, _omitFieldNames ? '' : 'documentId', protoName: 'documentId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentDelete clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DocumentDelete copyWith(void Function(DocumentDelete) updates) =>
      super.copyWith((message) => updates(message as DocumentDelete))
          as DocumentDelete;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocumentDelete create() => DocumentDelete._();
  @$core.override
  DocumentDelete createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DocumentDelete getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DocumentDelete>(create);
  static DocumentDelete? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get collection => $_getSZ(0);
  @$pb.TagNumber(1)
  set collection($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCollection() => $_has(0);
  @$pb.TagNumber(1)
  void clearCollection() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get documentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set documentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDocumentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocumentId() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
