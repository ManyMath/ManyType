// This is a generated file - do not edit.
//
// Generated from any_sync/treechange.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'treechange.pbenum.dart';

/// RootChange is a root of a tree
class RootChange extends $pb.GeneratedMessage {
  factory RootChange({
    $core.String? aclHeadId,
    $core.String? spaceId,
    $core.String? changeType,
    $fixnum.Int64? timestamp,
    $core.List<$core.int>? seed,
    $core.List<$core.int>? identity,
    $core.List<$core.int>? changePayload,
    $core.bool? isDerived,
  }) {
    final result = create();
    if (aclHeadId != null) result.aclHeadId = aclHeadId;
    if (spaceId != null) result.spaceId = spaceId;
    if (changeType != null) result.changeType = changeType;
    if (timestamp != null) result.timestamp = timestamp;
    if (seed != null) result.seed = seed;
    if (identity != null) result.identity = identity;
    if (changePayload != null) result.changePayload = changePayload;
    if (isDerived != null) result.isDerived = isDerived;
    return result;
  }

  RootChange._();

  factory RootChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RootChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RootChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'aclHeadId', protoName: 'aclHeadId')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'changeType', protoName: 'changeType')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'seed', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'changePayload', $pb.PbFieldType.OY,
        protoName: 'changePayload')
    ..aOB(8, _omitFieldNames ? '' : 'isDerived', protoName: 'isDerived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RootChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RootChange copyWith(void Function(RootChange) updates) =>
      super.copyWith((message) => updates(message as RootChange)) as RootChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RootChange create() => RootChange._();
  @$core.override
  RootChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RootChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RootChange>(create);
  static RootChange? _defaultInstance;

  /// AclHeadId is a cid of latest acl record at the time of tree creation
  @$pb.TagNumber(1)
  $core.String get aclHeadId => $_getSZ(0);
  @$pb.TagNumber(1)
  set aclHeadId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAclHeadId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAclHeadId() => $_clearField(1);

  /// SpaceId is an id of space where the document is placed
  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  /// ChangeType is a type of tree which this RootChange is a root of
  @$pb.TagNumber(3)
  $core.String get changeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set changeType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChangeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearChangeType() => $_clearField(3);

  /// Timestamp is this change creation timestamp
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);

  /// Seed is a random bytes to make root change unique
  @$pb.TagNumber(5)
  $core.List<$core.int> get seed => $_getN(4);
  @$pb.TagNumber(5)
  set seed($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSeed() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeed() => $_clearField(5);

  /// Identity is a public key of the tree's creator
  @$pb.TagNumber(6)
  $core.List<$core.int> get identity => $_getN(5);
  @$pb.TagNumber(6)
  set identity($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIdentity() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdentity() => $_clearField(6);

  /// ChangePayload is a payload related to ChangeType
  @$pb.TagNumber(7)
  $core.List<$core.int> get changePayload => $_getN(6);
  @$pb.TagNumber(7)
  set changePayload($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasChangePayload() => $_has(6);
  @$pb.TagNumber(7)
  void clearChangePayload() => $_clearField(7);

  /// IsDerived tells if the tree is derived
  @$pb.TagNumber(8)
  $core.bool get isDerived => $_getBF(7);
  @$pb.TagNumber(8)
  set isDerived($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsDerived() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsDerived() => $_clearField(8);
}

/// TreeChange is a change of a tree
class TreeChange extends $pb.GeneratedMessage {
  factory TreeChange({
    $core.Iterable<$core.String>? treeHeadIds,
    $core.String? aclHeadId,
    $core.String? snapshotBaseId,
    $core.List<$core.int>? changesData,
    $core.String? readKeyId,
    $fixnum.Int64? timestamp,
    $core.List<$core.int>? identity,
    $core.bool? isSnapshot,
    $core.String? dataType,
  }) {
    final result = create();
    if (treeHeadIds != null) result.treeHeadIds.addAll(treeHeadIds);
    if (aclHeadId != null) result.aclHeadId = aclHeadId;
    if (snapshotBaseId != null) result.snapshotBaseId = snapshotBaseId;
    if (changesData != null) result.changesData = changesData;
    if (readKeyId != null) result.readKeyId = readKeyId;
    if (timestamp != null) result.timestamp = timestamp;
    if (identity != null) result.identity = identity;
    if (isSnapshot != null) result.isSnapshot = isSnapshot;
    if (dataType != null) result.dataType = dataType;
    return result;
  }

  TreeChange._();

  factory TreeChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreeChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'treeHeadIds', protoName: 'treeHeadIds')
    ..aOS(2, _omitFieldNames ? '' : 'aclHeadId', protoName: 'aclHeadId')
    ..aOS(3, _omitFieldNames ? '' : 'snapshotBaseId',
        protoName: 'snapshotBaseId')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'changesData', $pb.PbFieldType.OY,
        protoName: 'changesData')
    ..aOS(5, _omitFieldNames ? '' : 'readKeyId', protoName: 'readKeyId')
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..aOB(8, _omitFieldNames ? '' : 'isSnapshot', protoName: 'isSnapshot')
    ..aOS(9, _omitFieldNames ? '' : 'dataType', protoName: 'dataType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeChange copyWith(void Function(TreeChange) updates) =>
      super.copyWith((message) => updates(message as TreeChange)) as TreeChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreeChange create() => TreeChange._();
  @$core.override
  TreeChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreeChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreeChange>(create);
  static TreeChange? _defaultInstance;

  /// TreeHeadIds are previous ids for this TreeChange
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get treeHeadIds => $_getList(0);

  /// AclHeadId is a cid of latest acl record at the time of this change
  @$pb.TagNumber(2)
  $core.String get aclHeadId => $_getSZ(1);
  @$pb.TagNumber(2)
  set aclHeadId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAclHeadId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAclHeadId() => $_clearField(2);

  /// SnapshotBaseId is a snapshot (root) of the tree where this change is added
  @$pb.TagNumber(3)
  $core.String get snapshotBaseId => $_getSZ(2);
  @$pb.TagNumber(3)
  set snapshotBaseId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSnapshotBaseId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSnapshotBaseId() => $_clearField(3);

  /// ChangesData is an arbitrary payload to be read by the client
  @$pb.TagNumber(4)
  $core.List<$core.int> get changesData => $_getN(3);
  @$pb.TagNumber(4)
  set changesData($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChangesData() => $_has(3);
  @$pb.TagNumber(4)
  void clearChangesData() => $_clearField(4);

  /// ReadKeyId is the id of the read key
  @$pb.TagNumber(5)
  $core.String get readKeyId => $_getSZ(4);
  @$pb.TagNumber(5)
  set readKeyId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReadKeyId() => $_has(4);
  @$pb.TagNumber(5)
  void clearReadKeyId() => $_clearField(5);

  /// Timestamp is this change creation timestamp
  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);

  /// Identity is a public key with which the raw payload of this change is signed
  @$pb.TagNumber(7)
  $core.List<$core.int> get identity => $_getN(6);
  @$pb.TagNumber(7)
  set identity($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIdentity() => $_has(6);
  @$pb.TagNumber(7)
  void clearIdentity() => $_clearField(7);

  /// IsSnapshot indicates whether this change contains a snapshot of state
  @$pb.TagNumber(8)
  $core.bool get isSnapshot => $_getBF(7);
  @$pb.TagNumber(8)
  set isSnapshot($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsSnapshot() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsSnapshot() => $_clearField(8);

  /// DataType indicates some special parameters of data for the client
  @$pb.TagNumber(9)
  $core.String get dataType => $_getSZ(8);
  @$pb.TagNumber(9)
  set dataType($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDataType() => $_has(8);
  @$pb.TagNumber(9)
  void clearDataType() => $_clearField(9);
}

/// TreeChange is a change of a tree
class NoDataTreeChange extends $pb.GeneratedMessage {
  factory NoDataTreeChange({
    $core.Iterable<$core.String>? treeHeadIds,
    $core.String? aclHeadId,
    $core.String? snapshotBaseId,
    $core.String? readKeyId,
    $fixnum.Int64? timestamp,
    $core.List<$core.int>? identity,
    $core.bool? isSnapshot,
    $core.String? dataType,
  }) {
    final result = create();
    if (treeHeadIds != null) result.treeHeadIds.addAll(treeHeadIds);
    if (aclHeadId != null) result.aclHeadId = aclHeadId;
    if (snapshotBaseId != null) result.snapshotBaseId = snapshotBaseId;
    if (readKeyId != null) result.readKeyId = readKeyId;
    if (timestamp != null) result.timestamp = timestamp;
    if (identity != null) result.identity = identity;
    if (isSnapshot != null) result.isSnapshot = isSnapshot;
    if (dataType != null) result.dataType = dataType;
    return result;
  }

  NoDataTreeChange._();

  factory NoDataTreeChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NoDataTreeChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NoDataTreeChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'treeHeadIds', protoName: 'treeHeadIds')
    ..aOS(2, _omitFieldNames ? '' : 'aclHeadId', protoName: 'aclHeadId')
    ..aOS(3, _omitFieldNames ? '' : 'snapshotBaseId',
        protoName: 'snapshotBaseId')
    ..aOS(5, _omitFieldNames ? '' : 'readKeyId', protoName: 'readKeyId')
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..aOB(8, _omitFieldNames ? '' : 'isSnapshot', protoName: 'isSnapshot')
    ..aOS(9, _omitFieldNames ? '' : 'dataType', protoName: 'dataType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NoDataTreeChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NoDataTreeChange copyWith(void Function(NoDataTreeChange) updates) =>
      super.copyWith((message) => updates(message as NoDataTreeChange))
          as NoDataTreeChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NoDataTreeChange create() => NoDataTreeChange._();
  @$core.override
  NoDataTreeChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NoDataTreeChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NoDataTreeChange>(create);
  static NoDataTreeChange? _defaultInstance;

  /// TreeHeadIds are previous ids for this TreeChange
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get treeHeadIds => $_getList(0);

  /// AclHeadId is a cid of latest acl record at the time of this change
  @$pb.TagNumber(2)
  $core.String get aclHeadId => $_getSZ(1);
  @$pb.TagNumber(2)
  set aclHeadId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAclHeadId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAclHeadId() => $_clearField(2);

  /// SnapshotBaseId is a snapshot (root) of the tree where this change is added
  @$pb.TagNumber(3)
  $core.String get snapshotBaseId => $_getSZ(2);
  @$pb.TagNumber(3)
  set snapshotBaseId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSnapshotBaseId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSnapshotBaseId() => $_clearField(3);

  /// ReadKeyId is the id of the read key
  @$pb.TagNumber(5)
  $core.String get readKeyId => $_getSZ(3);
  @$pb.TagNumber(5)
  set readKeyId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(5)
  $core.bool hasReadKeyId() => $_has(3);
  @$pb.TagNumber(5)
  void clearReadKeyId() => $_clearField(5);

  /// Timestamp is this change creation timestamp
  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);

  /// Identity is a public key with which the raw payload of this change is signed
  @$pb.TagNumber(7)
  $core.List<$core.int> get identity => $_getN(5);
  @$pb.TagNumber(7)
  set identity($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(7)
  $core.bool hasIdentity() => $_has(5);
  @$pb.TagNumber(7)
  void clearIdentity() => $_clearField(7);

  /// IsSnapshot indicates whether this change contains a snapshot of state
  @$pb.TagNumber(8)
  $core.bool get isSnapshot => $_getBF(6);
  @$pb.TagNumber(8)
  set isSnapshot($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(8)
  $core.bool hasIsSnapshot() => $_has(6);
  @$pb.TagNumber(8)
  void clearIsSnapshot() => $_clearField(8);

  /// DataType indicates some special parameters of data for the client
  @$pb.TagNumber(9)
  $core.String get dataType => $_getSZ(7);
  @$pb.TagNumber(9)
  set dataType($core.String value) => $_setString(7, value);
  @$pb.TagNumber(9)
  $core.bool hasDataType() => $_has(7);
  @$pb.TagNumber(9)
  void clearDataType() => $_clearField(9);
}

class ReducedTreeChange extends $pb.GeneratedMessage {
  factory ReducedTreeChange({
    $core.Iterable<$core.String>? treeHeadIds,
  }) {
    final result = create();
    if (treeHeadIds != null) result.treeHeadIds.addAll(treeHeadIds);
    return result;
  }

  ReducedTreeChange._();

  factory ReducedTreeChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReducedTreeChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReducedTreeChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'treeHeadIds', protoName: 'treeHeadIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReducedTreeChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReducedTreeChange copyWith(void Function(ReducedTreeChange) updates) =>
      super.copyWith((message) => updates(message as ReducedTreeChange))
          as ReducedTreeChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReducedTreeChange create() => ReducedTreeChange._();
  @$core.override
  ReducedTreeChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReducedTreeChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReducedTreeChange>(create);
  static ReducedTreeChange? _defaultInstance;

  /// TreeHeadIds are previous ids for this TreeChange
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get treeHeadIds => $_getList(0);
}

/// RawTreeChange is a marshalled TreeChange (or RootChange) payload and a signature of this payload
class RawTreeChange extends $pb.GeneratedMessage {
  factory RawTreeChange({
    $core.List<$core.int>? payload,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    if (signature != null) result.signature = signature;
    return result;
  }

  RawTreeChange._();

  factory RawTreeChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RawTreeChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RawTreeChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawTreeChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawTreeChange copyWith(void Function(RawTreeChange) updates) =>
      super.copyWith((message) => updates(message as RawTreeChange))
          as RawTreeChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RawTreeChange create() => RawTreeChange._();
  @$core.override
  RawTreeChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RawTreeChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RawTreeChange>(create);
  static RawTreeChange? _defaultInstance;

  /// Payload is a byte payload containing TreeChange
  @$pb.TagNumber(1)
  $core.List<$core.int> get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);

  /// Signature is a signature made by identity indicated in the TreeChange payload
  @$pb.TagNumber(2)
  $core.List<$core.int> get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);
}

/// RawTreeChangeWithId is a marshalled RawTreeChange with CID
class RawTreeChangeWithId extends $pb.GeneratedMessage {
  factory RawTreeChangeWithId({
    $core.List<$core.int>? rawChange,
    $core.String? id,
  }) {
    final result = create();
    if (rawChange != null) result.rawChange = rawChange;
    if (id != null) result.id = id;
    return result;
  }

  RawTreeChangeWithId._();

  factory RawTreeChangeWithId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RawTreeChangeWithId.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RawTreeChangeWithId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'rawChange', $pb.PbFieldType.OY,
        protoName: 'rawChange')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawTreeChangeWithId clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawTreeChangeWithId copyWith(void Function(RawTreeChangeWithId) updates) =>
      super.copyWith((message) => updates(message as RawTreeChangeWithId))
          as RawTreeChangeWithId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RawTreeChangeWithId create() => RawTreeChangeWithId._();
  @$core.override
  RawTreeChangeWithId createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RawTreeChangeWithId getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RawTreeChangeWithId>(create);
  static RawTreeChangeWithId? _defaultInstance;

  /// RawChange is a byte payload of RawTreeChange
  @$pb.TagNumber(1)
  $core.List<$core.int> get rawChange => $_getN(0);
  @$pb.TagNumber(1)
  set rawChange($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRawChange() => $_has(0);
  @$pb.TagNumber(1)
  void clearRawChange() => $_clearField(1);

  /// Id is a cid made from rawChange payload
  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

class TreeSyncMessage extends $pb.GeneratedMessage {
  factory TreeSyncMessage({
    TreeSyncContentValue? content,
    RawTreeChangeWithId? rootChange,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (rootChange != null) result.rootChange = rootChange;
    return result;
  }

  TreeSyncMessage._();

  factory TreeSyncMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreeSyncMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeSyncMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..aOM<TreeSyncContentValue>(1, _omitFieldNames ? '' : 'content',
        subBuilder: TreeSyncContentValue.create)
    ..aOM<RawTreeChangeWithId>(2, _omitFieldNames ? '' : 'rootChange',
        protoName: 'rootChange', subBuilder: RawTreeChangeWithId.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeSyncMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeSyncMessage copyWith(void Function(TreeSyncMessage) updates) =>
      super.copyWith((message) => updates(message as TreeSyncMessage))
          as TreeSyncMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreeSyncMessage create() => TreeSyncMessage._();
  @$core.override
  TreeSyncMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreeSyncMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreeSyncMessage>(create);
  static TreeSyncMessage? _defaultInstance;

  @$pb.TagNumber(1)
  TreeSyncContentValue get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(TreeSyncContentValue value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  TreeSyncContentValue ensureContent() => $_ensure(0);

  @$pb.TagNumber(2)
  RawTreeChangeWithId get rootChange => $_getN(1);
  @$pb.TagNumber(2)
  set rootChange(RawTreeChangeWithId value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRootChange() => $_has(1);
  @$pb.TagNumber(2)
  void clearRootChange() => $_clearField(2);
  @$pb.TagNumber(2)
  RawTreeChangeWithId ensureRootChange() => $_ensure(1);
}

enum TreeSyncContentValue_Value {
  headUpdate,
  fullSyncRequest,
  fullSyncResponse,
  errorResponse,
  notSet
}

/// TreeSyncContentValue provides different types for tree sync
class TreeSyncContentValue extends $pb.GeneratedMessage {
  factory TreeSyncContentValue({
    TreeHeadUpdate? headUpdate,
    TreeFullSyncRequest? fullSyncRequest,
    TreeFullSyncResponse? fullSyncResponse,
    TreeErrorResponse? errorResponse,
  }) {
    final result = create();
    if (headUpdate != null) result.headUpdate = headUpdate;
    if (fullSyncRequest != null) result.fullSyncRequest = fullSyncRequest;
    if (fullSyncResponse != null) result.fullSyncResponse = fullSyncResponse;
    if (errorResponse != null) result.errorResponse = errorResponse;
    return result;
  }

  TreeSyncContentValue._();

  factory TreeSyncContentValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreeSyncContentValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, TreeSyncContentValue_Value>
      _TreeSyncContentValue_ValueByTag = {
    1: TreeSyncContentValue_Value.headUpdate,
    2: TreeSyncContentValue_Value.fullSyncRequest,
    3: TreeSyncContentValue_Value.fullSyncResponse,
    4: TreeSyncContentValue_Value.errorResponse,
    0: TreeSyncContentValue_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeSyncContentValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4])
    ..aOM<TreeHeadUpdate>(1, _omitFieldNames ? '' : 'headUpdate',
        protoName: 'headUpdate', subBuilder: TreeHeadUpdate.create)
    ..aOM<TreeFullSyncRequest>(2, _omitFieldNames ? '' : 'fullSyncRequest',
        protoName: 'fullSyncRequest', subBuilder: TreeFullSyncRequest.create)
    ..aOM<TreeFullSyncResponse>(3, _omitFieldNames ? '' : 'fullSyncResponse',
        protoName: 'fullSyncResponse', subBuilder: TreeFullSyncResponse.create)
    ..aOM<TreeErrorResponse>(4, _omitFieldNames ? '' : 'errorResponse',
        protoName: 'errorResponse', subBuilder: TreeErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeSyncContentValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeSyncContentValue copyWith(void Function(TreeSyncContentValue) updates) =>
      super.copyWith((message) => updates(message as TreeSyncContentValue))
          as TreeSyncContentValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreeSyncContentValue create() => TreeSyncContentValue._();
  @$core.override
  TreeSyncContentValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreeSyncContentValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreeSyncContentValue>(create);
  static TreeSyncContentValue? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  TreeSyncContentValue_Value whichValue() =>
      _TreeSyncContentValue_ValueByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  void clearValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  TreeHeadUpdate get headUpdate => $_getN(0);
  @$pb.TagNumber(1)
  set headUpdate(TreeHeadUpdate value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHeadUpdate() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeadUpdate() => $_clearField(1);
  @$pb.TagNumber(1)
  TreeHeadUpdate ensureHeadUpdate() => $_ensure(0);

  @$pb.TagNumber(2)
  TreeFullSyncRequest get fullSyncRequest => $_getN(1);
  @$pb.TagNumber(2)
  set fullSyncRequest(TreeFullSyncRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFullSyncRequest() => $_has(1);
  @$pb.TagNumber(2)
  void clearFullSyncRequest() => $_clearField(2);
  @$pb.TagNumber(2)
  TreeFullSyncRequest ensureFullSyncRequest() => $_ensure(1);

  @$pb.TagNumber(3)
  TreeFullSyncResponse get fullSyncResponse => $_getN(2);
  @$pb.TagNumber(3)
  set fullSyncResponse(TreeFullSyncResponse value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFullSyncResponse() => $_has(2);
  @$pb.TagNumber(3)
  void clearFullSyncResponse() => $_clearField(3);
  @$pb.TagNumber(3)
  TreeFullSyncResponse ensureFullSyncResponse() => $_ensure(2);

  @$pb.TagNumber(4)
  TreeErrorResponse get errorResponse => $_getN(3);
  @$pb.TagNumber(4)
  set errorResponse(TreeErrorResponse value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasErrorResponse() => $_has(3);
  @$pb.TagNumber(4)
  void clearErrorResponse() => $_clearField(4);
  @$pb.TagNumber(4)
  TreeErrorResponse ensureErrorResponse() => $_ensure(3);
}

/// TreeHeadUpdate is a message sent on document head update
class TreeHeadUpdate extends $pb.GeneratedMessage {
  factory TreeHeadUpdate({
    $core.Iterable<$core.String>? heads,
    $core.Iterable<RawTreeChangeWithId>? changes,
    $core.Iterable<$core.String>? snapshotPath,
  }) {
    final result = create();
    if (heads != null) result.heads.addAll(heads);
    if (changes != null) result.changes.addAll(changes);
    if (snapshotPath != null) result.snapshotPath.addAll(snapshotPath);
    return result;
  }

  TreeHeadUpdate._();

  factory TreeHeadUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreeHeadUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeHeadUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'heads')
    ..pPM<RawTreeChangeWithId>(2, _omitFieldNames ? '' : 'changes',
        subBuilder: RawTreeChangeWithId.create)
    ..pPS(3, _omitFieldNames ? '' : 'snapshotPath', protoName: 'snapshotPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeHeadUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeHeadUpdate copyWith(void Function(TreeHeadUpdate) updates) =>
      super.copyWith((message) => updates(message as TreeHeadUpdate))
          as TreeHeadUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreeHeadUpdate create() => TreeHeadUpdate._();
  @$core.override
  TreeHeadUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreeHeadUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreeHeadUpdate>(create);
  static TreeHeadUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get heads => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<RawTreeChangeWithId> get changes => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get snapshotPath => $_getList(2);
}

/// TreeHeadUpdate is a message sent when document needs full sync
class TreeFullSyncRequest extends $pb.GeneratedMessage {
  factory TreeFullSyncRequest({
    $core.Iterable<$core.String>? heads,
    $core.Iterable<RawTreeChangeWithId>? changes,
    $core.Iterable<$core.String>? snapshotPath,
  }) {
    final result = create();
    if (heads != null) result.heads.addAll(heads);
    if (changes != null) result.changes.addAll(changes);
    if (snapshotPath != null) result.snapshotPath.addAll(snapshotPath);
    return result;
  }

  TreeFullSyncRequest._();

  factory TreeFullSyncRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreeFullSyncRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeFullSyncRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'heads')
    ..pPM<RawTreeChangeWithId>(2, _omitFieldNames ? '' : 'changes',
        subBuilder: RawTreeChangeWithId.create)
    ..pPS(3, _omitFieldNames ? '' : 'snapshotPath', protoName: 'snapshotPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeFullSyncRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeFullSyncRequest copyWith(void Function(TreeFullSyncRequest) updates) =>
      super.copyWith((message) => updates(message as TreeFullSyncRequest))
          as TreeFullSyncRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreeFullSyncRequest create() => TreeFullSyncRequest._();
  @$core.override
  TreeFullSyncRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreeFullSyncRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreeFullSyncRequest>(create);
  static TreeFullSyncRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get heads => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<RawTreeChangeWithId> get changes => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get snapshotPath => $_getList(2);
}

/// TreeFullSyncResponse is a message sent as a response for a specific full sync
class TreeFullSyncResponse extends $pb.GeneratedMessage {
  factory TreeFullSyncResponse({
    $core.Iterable<$core.String>? heads,
    $core.Iterable<RawTreeChangeWithId>? changes,
    $core.Iterable<$core.String>? snapshotPath,
  }) {
    final result = create();
    if (heads != null) result.heads.addAll(heads);
    if (changes != null) result.changes.addAll(changes);
    if (snapshotPath != null) result.snapshotPath.addAll(snapshotPath);
    return result;
  }

  TreeFullSyncResponse._();

  factory TreeFullSyncResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreeFullSyncResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeFullSyncResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'heads')
    ..pPM<RawTreeChangeWithId>(2, _omitFieldNames ? '' : 'changes',
        subBuilder: RawTreeChangeWithId.create)
    ..pPS(3, _omitFieldNames ? '' : 'snapshotPath', protoName: 'snapshotPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeFullSyncResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeFullSyncResponse copyWith(void Function(TreeFullSyncResponse) updates) =>
      super.copyWith((message) => updates(message as TreeFullSyncResponse))
          as TreeFullSyncResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreeFullSyncResponse create() => TreeFullSyncResponse._();
  @$core.override
  TreeFullSyncResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreeFullSyncResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreeFullSyncResponse>(create);
  static TreeFullSyncResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get heads => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<RawTreeChangeWithId> get changes => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get snapshotPath => $_getList(2);
}

/// TreeErrorResponse is an error sent as a response for a full sync request
class TreeErrorResponse extends $pb.GeneratedMessage {
  factory TreeErrorResponse({
    $core.String? error,
    $fixnum.Int64? errCode,
  }) {
    final result = create();
    if (error != null) result.error = error;
    if (errCode != null) result.errCode = errCode;
    return result;
  }

  TreeErrorResponse._();

  factory TreeErrorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreeErrorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeErrorResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'error')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'errCode', $pb.PbFieldType.OU6,
        protoName: 'errCode', defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeErrorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeErrorResponse copyWith(void Function(TreeErrorResponse) updates) =>
      super.copyWith((message) => updates(message as TreeErrorResponse))
          as TreeErrorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreeErrorResponse create() => TreeErrorResponse._();
  @$core.override
  TreeErrorResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreeErrorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreeErrorResponse>(create);
  static TreeErrorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get error => $_getSZ(0);
  @$pb.TagNumber(1)
  set error($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get errCode => $_getI64(1);
  @$pb.TagNumber(2)
  set errCode($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrCode() => $_clearField(2);
}

/// TreeChangeInfo is used internally in Tree implementation for ease of marshalling
class TreeChangeInfo extends $pb.GeneratedMessage {
  factory TreeChangeInfo({
    $core.String? changeType,
    $core.List<$core.int>? changePayload,
  }) {
    final result = create();
    if (changeType != null) result.changeType = changeType;
    if (changePayload != null) result.changePayload = changePayload;
    return result;
  }

  TreeChangeInfo._();

  factory TreeChangeInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreeChangeInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeChangeInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'treechange'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'changeType', protoName: 'changeType')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'changePayload', $pb.PbFieldType.OY,
        protoName: 'changePayload')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeChangeInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeChangeInfo copyWith(void Function(TreeChangeInfo) updates) =>
      super.copyWith((message) => updates(message as TreeChangeInfo))
          as TreeChangeInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreeChangeInfo create() => TreeChangeInfo._();
  @$core.override
  TreeChangeInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreeChangeInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreeChangeInfo>(create);
  static TreeChangeInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get changeType => $_getSZ(0);
  @$pb.TagNumber(1)
  set changeType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChangeType() => $_has(0);
  @$pb.TagNumber(1)
  void clearChangeType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get changePayload => $_getN(1);
  @$pb.TagNumber(2)
  set changePayload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChangePayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearChangePayload() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
