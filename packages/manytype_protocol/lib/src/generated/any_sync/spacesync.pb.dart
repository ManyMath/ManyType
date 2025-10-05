// This is a generated file - do not edit.
//
// Generated from any_sync/spacesync.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'spacesync.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'spacesync.pbenum.dart';

/// HeadSyncRange presenting a request for one range
class HeadSyncRange extends $pb.GeneratedMessage {
  factory HeadSyncRange({
    $fixnum.Int64? from,
    $fixnum.Int64? to,
    $core.int? limit,
    $core.bool? elements,
  }) {
    final result = create();
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (limit != null) result.limit = limit;
    if (elements != null) result.elements = elements;
    return result;
  }

  HeadSyncRange._();

  factory HeadSyncRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HeadSyncRange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeadSyncRange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'from', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'to', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'elements')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncRange copyWith(void Function(HeadSyncRange) updates) =>
      super.copyWith((message) => updates(message as HeadSyncRange))
          as HeadSyncRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeadSyncRange create() => HeadSyncRange._();
  @$core.override
  HeadSyncRange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HeadSyncRange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HeadSyncRange>(create);
  static HeadSyncRange? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get from => $_getI64(0);
  @$pb.TagNumber(1)
  set from($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFrom() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrom() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get to => $_getI64(1);
  @$pb.TagNumber(2)
  set to($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTo() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get elements => $_getBF(3);
  @$pb.TagNumber(4)
  set elements($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasElements() => $_has(3);
  @$pb.TagNumber(4)
  void clearElements() => $_clearField(4);
}

/// HeadSyncResult presenting a response for one range
class HeadSyncResult extends $pb.GeneratedMessage {
  factory HeadSyncResult({
    $core.List<$core.int>? hash,
    $core.Iterable<HeadSyncResultElement>? elements,
    $core.int? count,
  }) {
    final result = create();
    if (hash != null) result.hash = hash;
    if (elements != null) result.elements.addAll(elements);
    if (count != null) result.count = count;
    return result;
  }

  HeadSyncResult._();

  factory HeadSyncResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HeadSyncResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeadSyncResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'hash', $pb.PbFieldType.OY)
    ..pPM<HeadSyncResultElement>(2, _omitFieldNames ? '' : 'elements',
        subBuilder: HeadSyncResultElement.create)
    ..aI(3, _omitFieldNames ? '' : 'count', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncResult copyWith(void Function(HeadSyncResult) updates) =>
      super.copyWith((message) => updates(message as HeadSyncResult))
          as HeadSyncResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeadSyncResult create() => HeadSyncResult._();
  @$core.override
  HeadSyncResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HeadSyncResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HeadSyncResult>(create);
  static HeadSyncResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get hash => $_getN(0);
  @$pb.TagNumber(1)
  set hash($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<HeadSyncResultElement> get elements => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => $_clearField(3);
}

/// HeadSyncResultElement presenting state of one object
class HeadSyncResultElement extends $pb.GeneratedMessage {
  factory HeadSyncResultElement({
    $core.String? id,
    $core.String? head,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (head != null) result.head = head;
    return result;
  }

  HeadSyncResultElement._();

  factory HeadSyncResultElement.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HeadSyncResultElement.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeadSyncResultElement',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'head')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncResultElement clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncResultElement copyWith(
          void Function(HeadSyncResultElement) updates) =>
      super.copyWith((message) => updates(message as HeadSyncResultElement))
          as HeadSyncResultElement;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeadSyncResultElement create() => HeadSyncResultElement._();
  @$core.override
  HeadSyncResultElement createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HeadSyncResultElement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HeadSyncResultElement>(create);
  static HeadSyncResultElement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get head => $_getSZ(1);
  @$pb.TagNumber(2)
  set head($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHead() => $_has(1);
  @$pb.TagNumber(2)
  void clearHead() => $_clearField(2);
}

/// HeadSyncRequest is a request for HeadSync
class HeadSyncRequest extends $pb.GeneratedMessage {
  factory HeadSyncRequest({
    $core.String? spaceId,
    $core.Iterable<HeadSyncRange>? ranges,
    DiffType? diffType,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (ranges != null) result.ranges.addAll(ranges);
    if (diffType != null) result.diffType = diffType;
    return result;
  }

  HeadSyncRequest._();

  factory HeadSyncRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HeadSyncRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeadSyncRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..pPM<HeadSyncRange>(2, _omitFieldNames ? '' : 'ranges',
        subBuilder: HeadSyncRange.create)
    ..aE<DiffType>(3, _omitFieldNames ? '' : 'diffType',
        protoName: 'diffType', enumValues: DiffType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncRequest copyWith(void Function(HeadSyncRequest) updates) =>
      super.copyWith((message) => updates(message as HeadSyncRequest))
          as HeadSyncRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeadSyncRequest create() => HeadSyncRequest._();
  @$core.override
  HeadSyncRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HeadSyncRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HeadSyncRequest>(create);
  static HeadSyncRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<HeadSyncRange> get ranges => $_getList(1);

  @$pb.TagNumber(3)
  DiffType get diffType => $_getN(2);
  @$pb.TagNumber(3)
  set diffType(DiffType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDiffType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDiffType() => $_clearField(3);
}

/// HeadSyncResponse is a response for HeadSync
class HeadSyncResponse extends $pb.GeneratedMessage {
  factory HeadSyncResponse({
    $core.Iterable<HeadSyncResult>? results,
    DiffType? diffType,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    if (diffType != null) result.diffType = diffType;
    return result;
  }

  HeadSyncResponse._();

  factory HeadSyncResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HeadSyncResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeadSyncResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..pPM<HeadSyncResult>(1, _omitFieldNames ? '' : 'results',
        subBuilder: HeadSyncResult.create)
    ..aE<DiffType>(2, _omitFieldNames ? '' : 'diffType',
        protoName: 'diffType', enumValues: DiffType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeadSyncResponse copyWith(void Function(HeadSyncResponse) updates) =>
      super.copyWith((message) => updates(message as HeadSyncResponse))
          as HeadSyncResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeadSyncResponse create() => HeadSyncResponse._();
  @$core.override
  HeadSyncResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HeadSyncResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HeadSyncResponse>(create);
  static HeadSyncResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<HeadSyncResult> get results => $_getList(0);

  @$pb.TagNumber(2)
  DiffType get diffType => $_getN(1);
  @$pb.TagNumber(2)
  set diffType(DiffType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDiffType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiffType() => $_clearField(2);
}

/// ObjectSyncMessage is a message sent on object sync
class ObjectSyncMessage extends $pb.GeneratedMessage {
  factory ObjectSyncMessage({
    $core.String? spaceId,
    $core.String? requestId,
    $core.String? replyId,
    $core.List<$core.int>? payload,
    $core.String? objectId,
    ObjectType? objectType,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (requestId != null) result.requestId = requestId;
    if (replyId != null) result.replyId = replyId;
    if (payload != null) result.payload = payload;
    if (objectId != null) result.objectId = objectId;
    if (objectType != null) result.objectType = objectType;
    return result;
  }

  ObjectSyncMessage._();

  factory ObjectSyncMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ObjectSyncMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ObjectSyncMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'requestId', protoName: 'requestId')
    ..aOS(3, _omitFieldNames ? '' : 'replyId', protoName: 'replyId')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aOS(5, _omitFieldNames ? '' : 'objectId', protoName: 'objectId')
    ..aE<ObjectType>(6, _omitFieldNames ? '' : 'objectType',
        protoName: 'objectType', enumValues: ObjectType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectSyncMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectSyncMessage copyWith(void Function(ObjectSyncMessage) updates) =>
      super.copyWith((message) => updates(message as ObjectSyncMessage))
          as ObjectSyncMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ObjectSyncMessage create() => ObjectSyncMessage._();
  @$core.override
  ObjectSyncMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ObjectSyncMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ObjectSyncMessage>(create);
  static ObjectSyncMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get requestId => $_getSZ(1);
  @$pb.TagNumber(2)
  set requestId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get replyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set replyId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReplyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReplyId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get payload => $_getN(3);
  @$pb.TagNumber(4)
  set payload($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayload() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get objectId => $_getSZ(4);
  @$pb.TagNumber(5)
  set objectId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasObjectId() => $_has(4);
  @$pb.TagNumber(5)
  void clearObjectId() => $_clearField(5);

  @$pb.TagNumber(6)
  ObjectType get objectType => $_getN(5);
  @$pb.TagNumber(6)
  set objectType(ObjectType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasObjectType() => $_has(5);
  @$pb.TagNumber(6)
  void clearObjectType() => $_clearField(6);
}

/// SpacePushRequest is a request to add space on a node containing only one acl record
class SpacePushRequest extends $pb.GeneratedMessage {
  factory SpacePushRequest({
    SpacePayload? payload,
    $core.List<$core.int>? credential,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    if (credential != null) result.credential = credential;
    return result;
  }

  SpacePushRequest._();

  factory SpacePushRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpacePushRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpacePushRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOM<SpacePayload>(1, _omitFieldNames ? '' : 'payload',
        subBuilder: SpacePayload.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'Credential', $pb.PbFieldType.OY,
        protoName: 'Credential')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePushRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePushRequest copyWith(void Function(SpacePushRequest) updates) =>
      super.copyWith((message) => updates(message as SpacePushRequest))
          as SpacePushRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpacePushRequest create() => SpacePushRequest._();
  @$core.override
  SpacePushRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpacePushRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpacePushRequest>(create);
  static SpacePushRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SpacePayload get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload(SpacePayload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);
  @$pb.TagNumber(1)
  SpacePayload ensurePayload() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get credential => $_getN(1);
  @$pb.TagNumber(2)
  set credential($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCredential() => $_has(1);
  @$pb.TagNumber(2)
  void clearCredential() => $_clearField(2);
}

/// SpacePushResponse is an empty response
class SpacePushResponse extends $pb.GeneratedMessage {
  factory SpacePushResponse() => create();

  SpacePushResponse._();

  factory SpacePushResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpacePushResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpacePushResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePushResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePushResponse copyWith(void Function(SpacePushResponse) updates) =>
      super.copyWith((message) => updates(message as SpacePushResponse))
          as SpacePushResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpacePushResponse create() => SpacePushResponse._();
  @$core.override
  SpacePushResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpacePushResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpacePushResponse>(create);
  static SpacePushResponse? _defaultInstance;
}

/// SpacePullRequest is a request to request a space on a node that doesn't have it
class SpacePullRequest extends $pb.GeneratedMessage {
  factory SpacePullRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  SpacePullRequest._();

  factory SpacePullRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpacePullRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpacePullRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePullRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePullRequest copyWith(void Function(SpacePullRequest) updates) =>
      super.copyWith((message) => updates(message as SpacePullRequest))
          as SpacePullRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpacePullRequest create() => SpacePullRequest._();
  @$core.override
  SpacePullRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpacePullRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpacePullRequest>(create);
  static SpacePullRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// SpacePullResponse is a response with header and acl root
class SpacePullResponse extends $pb.GeneratedMessage {
  factory SpacePullResponse({
    SpacePayload? payload,
    $core.Iterable<AclRecord>? aclRecords,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    if (aclRecords != null) result.aclRecords.addAll(aclRecords);
    return result;
  }

  SpacePullResponse._();

  factory SpacePullResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpacePullResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpacePullResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOM<SpacePayload>(1, _omitFieldNames ? '' : 'payload',
        subBuilder: SpacePayload.create)
    ..pPM<AclRecord>(2, _omitFieldNames ? '' : 'aclRecords',
        protoName: 'aclRecords', subBuilder: AclRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePullResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePullResponse copyWith(void Function(SpacePullResponse) updates) =>
      super.copyWith((message) => updates(message as SpacePullResponse))
          as SpacePullResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpacePullResponse create() => SpacePullResponse._();
  @$core.override
  SpacePullResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpacePullResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpacePullResponse>(create);
  static SpacePullResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SpacePayload get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload(SpacePayload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);
  @$pb.TagNumber(1)
  SpacePayload ensurePayload() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<AclRecord> get aclRecords => $_getList(1);
}

class AclRecord extends $pb.GeneratedMessage {
  factory AclRecord({
    $core.List<$core.int>? aclPayload,
    $core.String? id,
  }) {
    final result = create();
    if (aclPayload != null) result.aclPayload = aclPayload;
    if (id != null) result.id = id;
    return result;
  }

  AclRecord._();

  factory AclRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclRecord',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'aclPayload', $pb.PbFieldType.OY,
        protoName: 'aclPayload')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclRecord copyWith(void Function(AclRecord) updates) =>
      super.copyWith((message) => updates(message as AclRecord)) as AclRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclRecord create() => AclRecord._();
  @$core.override
  AclRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclRecord getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AclRecord>(create);
  static AclRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get aclPayload => $_getN(0);
  @$pb.TagNumber(1)
  set aclPayload($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAclPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearAclPayload() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

/// SpacePayload is a payload for pushing a space
class SpacePayload extends $pb.GeneratedMessage {
  factory SpacePayload({
    RawSpaceHeaderWithId? spaceHeader,
    $core.List<$core.int>? aclPayload,
    $core.String? aclPayloadId,
    $core.List<$core.int>? spaceSettingsPayload,
    $core.String? spaceSettingsPayloadId,
  }) {
    final result = create();
    if (spaceHeader != null) result.spaceHeader = spaceHeader;
    if (aclPayload != null) result.aclPayload = aclPayload;
    if (aclPayloadId != null) result.aclPayloadId = aclPayloadId;
    if (spaceSettingsPayload != null)
      result.spaceSettingsPayload = spaceSettingsPayload;
    if (spaceSettingsPayloadId != null)
      result.spaceSettingsPayloadId = spaceSettingsPayloadId;
    return result;
  }

  SpacePayload._();

  factory SpacePayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpacePayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpacePayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOM<RawSpaceHeaderWithId>(1, _omitFieldNames ? '' : 'spaceHeader',
        protoName: 'spaceHeader', subBuilder: RawSpaceHeaderWithId.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'aclPayload', $pb.PbFieldType.OY,
        protoName: 'aclPayload')
    ..aOS(3, _omitFieldNames ? '' : 'aclPayloadId', protoName: 'aclPayloadId')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'spaceSettingsPayload', $pb.PbFieldType.OY,
        protoName: 'spaceSettingsPayload')
    ..aOS(5, _omitFieldNames ? '' : 'spaceSettingsPayloadId',
        protoName: 'spaceSettingsPayloadId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpacePayload copyWith(void Function(SpacePayload) updates) =>
      super.copyWith((message) => updates(message as SpacePayload))
          as SpacePayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpacePayload create() => SpacePayload._();
  @$core.override
  SpacePayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpacePayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpacePayload>(create);
  static SpacePayload? _defaultInstance;

  @$pb.TagNumber(1)
  RawSpaceHeaderWithId get spaceHeader => $_getN(0);
  @$pb.TagNumber(1)
  set spaceHeader(RawSpaceHeaderWithId value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceHeader() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceHeader() => $_clearField(1);
  @$pb.TagNumber(1)
  RawSpaceHeaderWithId ensureSpaceHeader() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get aclPayload => $_getN(1);
  @$pb.TagNumber(2)
  set aclPayload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAclPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearAclPayload() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get aclPayloadId => $_getSZ(2);
  @$pb.TagNumber(3)
  set aclPayloadId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAclPayloadId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAclPayloadId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get spaceSettingsPayload => $_getN(3);
  @$pb.TagNumber(4)
  set spaceSettingsPayload($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSpaceSettingsPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpaceSettingsPayload() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get spaceSettingsPayloadId => $_getSZ(4);
  @$pb.TagNumber(5)
  set spaceSettingsPayloadId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceSettingsPayloadId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpaceSettingsPayloadId() => $_clearField(5);
}

/// SpaceHeader is a header for a space
class SpaceHeader extends $pb.GeneratedMessage {
  factory SpaceHeader({
    $core.List<$core.int>? identity,
    $fixnum.Int64? timestamp,
    $core.String? spaceType,
    $fixnum.Int64? replicationKey,
    $core.List<$core.int>? seed,
    $core.List<$core.int>? spaceHeaderPayload,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (timestamp != null) result.timestamp = timestamp;
    if (spaceType != null) result.spaceType = spaceType;
    if (replicationKey != null) result.replicationKey = replicationKey;
    if (seed != null) result.seed = seed;
    if (spaceHeaderPayload != null)
      result.spaceHeaderPayload = spaceHeaderPayload;
    return result;
  }

  SpaceHeader._();

  factory SpaceHeader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceHeader',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..aOS(3, _omitFieldNames ? '' : 'spaceType', protoName: 'spaceType')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'replicationKey', $pb.PbFieldType.OU6,
        protoName: 'replicationKey', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'seed', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'spaceHeaderPayload', $pb.PbFieldType.OY,
        protoName: 'spaceHeaderPayload')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceHeader copyWith(void Function(SpaceHeader) updates) =>
      super.copyWith((message) => updates(message as SpaceHeader))
          as SpaceHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceHeader create() => SpaceHeader._();
  @$core.override
  SpaceHeader createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceHeader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceHeader>(create);
  static SpaceHeader? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get spaceType => $_getSZ(2);
  @$pb.TagNumber(3)
  set spaceType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpaceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpaceType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get replicationKey => $_getI64(3);
  @$pb.TagNumber(4)
  set replicationKey($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReplicationKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearReplicationKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get seed => $_getN(4);
  @$pb.TagNumber(5)
  set seed($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSeed() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeed() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get spaceHeaderPayload => $_getN(5);
  @$pb.TagNumber(6)
  set spaceHeaderPayload($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSpaceHeaderPayload() => $_has(5);
  @$pb.TagNumber(6)
  void clearSpaceHeaderPayload() => $_clearField(6);
}

/// RawSpaceHeader is raw header for SpaceHeader
class RawSpaceHeader extends $pb.GeneratedMessage {
  factory RawSpaceHeader({
    $core.List<$core.int>? spaceHeader,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (spaceHeader != null) result.spaceHeader = spaceHeader;
    if (signature != null) result.signature = signature;
    return result;
  }

  RawSpaceHeader._();

  factory RawSpaceHeader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RawSpaceHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RawSpaceHeader',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'spaceHeader', $pb.PbFieldType.OY,
        protoName: 'spaceHeader')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawSpaceHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawSpaceHeader copyWith(void Function(RawSpaceHeader) updates) =>
      super.copyWith((message) => updates(message as RawSpaceHeader))
          as RawSpaceHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RawSpaceHeader create() => RawSpaceHeader._();
  @$core.override
  RawSpaceHeader createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RawSpaceHeader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RawSpaceHeader>(create);
  static RawSpaceHeader? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get spaceHeader => $_getN(0);
  @$pb.TagNumber(1)
  set spaceHeader($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceHeader() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceHeader() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);
}

/// RawSpaceHeaderWithId is a marshalled RawSpaceHeader with its content id
class RawSpaceHeaderWithId extends $pb.GeneratedMessage {
  factory RawSpaceHeaderWithId({
    $core.List<$core.int>? rawHeader,
    $core.String? id,
  }) {
    final result = create();
    if (rawHeader != null) result.rawHeader = rawHeader;
    if (id != null) result.id = id;
    return result;
  }

  RawSpaceHeaderWithId._();

  factory RawSpaceHeaderWithId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RawSpaceHeaderWithId.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RawSpaceHeaderWithId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'rawHeader', $pb.PbFieldType.OY,
        protoName: 'rawHeader')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawSpaceHeaderWithId clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawSpaceHeaderWithId copyWith(void Function(RawSpaceHeaderWithId) updates) =>
      super.copyWith((message) => updates(message as RawSpaceHeaderWithId))
          as RawSpaceHeaderWithId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RawSpaceHeaderWithId create() => RawSpaceHeaderWithId._();
  @$core.override
  RawSpaceHeaderWithId createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RawSpaceHeaderWithId getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RawSpaceHeaderWithId>(create);
  static RawSpaceHeaderWithId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get rawHeader => $_getN(0);
  @$pb.TagNumber(1)
  set rawHeader($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRawHeader() => $_has(0);
  @$pb.TagNumber(1)
  void clearRawHeader() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

enum SpaceSettingsContent_Value { objectDelete, spaceDelete, notSet }

/// SpaceSettingsContent is a payload for a space settings object
class SpaceSettingsContent extends $pb.GeneratedMessage {
  factory SpaceSettingsContent({
    ObjectDelete? objectDelete,
    SpaceDelete? spaceDelete,
  }) {
    final result = create();
    if (objectDelete != null) result.objectDelete = objectDelete;
    if (spaceDelete != null) result.spaceDelete = spaceDelete;
    return result;
  }

  SpaceSettingsContent._();

  factory SpaceSettingsContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceSettingsContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SpaceSettingsContent_Value>
      _SpaceSettingsContent_ValueByTag = {
    1: SpaceSettingsContent_Value.objectDelete,
    2: SpaceSettingsContent_Value.spaceDelete,
    0: SpaceSettingsContent_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceSettingsContent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ObjectDelete>(1, _omitFieldNames ? '' : 'objectDelete',
        protoName: 'objectDelete', subBuilder: ObjectDelete.create)
    ..aOM<SpaceDelete>(2, _omitFieldNames ? '' : 'spaceDelete',
        protoName: 'spaceDelete', subBuilder: SpaceDelete.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSettingsContent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSettingsContent copyWith(void Function(SpaceSettingsContent) updates) =>
      super.copyWith((message) => updates(message as SpaceSettingsContent))
          as SpaceSettingsContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceSettingsContent create() => SpaceSettingsContent._();
  @$core.override
  SpaceSettingsContent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceSettingsContent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceSettingsContent>(create);
  static SpaceSettingsContent? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SpaceSettingsContent_Value whichValue() =>
      _SpaceSettingsContent_ValueByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ObjectDelete get objectDelete => $_getN(0);
  @$pb.TagNumber(1)
  set objectDelete(ObjectDelete value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasObjectDelete() => $_has(0);
  @$pb.TagNumber(1)
  void clearObjectDelete() => $_clearField(1);
  @$pb.TagNumber(1)
  ObjectDelete ensureObjectDelete() => $_ensure(0);

  @$pb.TagNumber(2)
  SpaceDelete get spaceDelete => $_getN(1);
  @$pb.TagNumber(2)
  set spaceDelete(SpaceDelete value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceDelete() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceDelete() => $_clearField(2);
  @$pb.TagNumber(2)
  SpaceDelete ensureSpaceDelete() => $_ensure(1);
}

/// ObjectDelete is a message containing an object id which should be deleted
class ObjectDelete extends $pb.GeneratedMessage {
  factory ObjectDelete({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  ObjectDelete._();

  factory ObjectDelete.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ObjectDelete.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ObjectDelete',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectDelete clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectDelete copyWith(void Function(ObjectDelete) updates) =>
      super.copyWith((message) => updates(message as ObjectDelete))
          as ObjectDelete;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ObjectDelete create() => ObjectDelete._();
  @$core.override
  ObjectDelete createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ObjectDelete getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ObjectDelete>(create);
  static ObjectDelete? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// StoreHeader is a header for a store
class StoreHeader extends $pb.GeneratedMessage {
  factory StoreHeader({
    $core.String? spaceId,
    $core.String? storageName,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (storageName != null) result.storageName = storageName;
    return result;
  }

  StoreHeader._();

  factory StoreHeader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StoreHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StoreHeader',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'storageName', protoName: 'storageName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreHeader copyWith(void Function(StoreHeader) updates) =>
      super.copyWith((message) => updates(message as StoreHeader))
          as StoreHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreHeader create() => StoreHeader._();
  @$core.override
  StoreHeader createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StoreHeader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreHeader>(create);
  static StoreHeader? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get storageName => $_getSZ(1);
  @$pb.TagNumber(2)
  set storageName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStorageName() => $_has(1);
  @$pb.TagNumber(2)
  void clearStorageName() => $_clearField(2);
}

/// SpaceDelete is a message containing deleter peer id
class SpaceDelete extends $pb.GeneratedMessage {
  factory SpaceDelete({
    $core.String? deleterPeerId,
  }) {
    final result = create();
    if (deleterPeerId != null) result.deleterPeerId = deleterPeerId;
    return result;
  }

  SpaceDelete._();

  factory SpaceDelete.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceDelete.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceDelete',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deleterPeerId', protoName: 'deleterPeerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceDelete clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceDelete copyWith(void Function(SpaceDelete) updates) =>
      super.copyWith((message) => updates(message as SpaceDelete))
          as SpaceDelete;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceDelete create() => SpaceDelete._();
  @$core.override
  SpaceDelete createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceDelete getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceDelete>(create);
  static SpaceDelete? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deleterPeerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deleterPeerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeleterPeerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeleterPeerId() => $_clearField(1);
}

/// SpaceSettingsSnapshot contains all the deleted ids in a snapshot
class SpaceSettingsSnapshot extends $pb.GeneratedMessage {
  factory SpaceSettingsSnapshot({
    $core.Iterable<$core.String>? deletedIds,
    $core.String? deleterPeerId,
  }) {
    final result = create();
    if (deletedIds != null) result.deletedIds.addAll(deletedIds);
    if (deleterPeerId != null) result.deleterPeerId = deleterPeerId;
    return result;
  }

  SpaceSettingsSnapshot._();

  factory SpaceSettingsSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceSettingsSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceSettingsSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'deletedIds', protoName: 'deletedIds')
    ..aOS(2, _omitFieldNames ? '' : 'deleterPeerId', protoName: 'deleterPeerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSettingsSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSettingsSnapshot copyWith(
          void Function(SpaceSettingsSnapshot) updates) =>
      super.copyWith((message) => updates(message as SpaceSettingsSnapshot))
          as SpaceSettingsSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceSettingsSnapshot create() => SpaceSettingsSnapshot._();
  @$core.override
  SpaceSettingsSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceSettingsSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceSettingsSnapshot>(create);
  static SpaceSettingsSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get deletedIds => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get deleterPeerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deleterPeerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeleterPeerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeleterPeerId() => $_clearField(2);
}

/// SettingsData contains ObjectTree change payload
class SettingsData extends $pb.GeneratedMessage {
  factory SettingsData({
    $core.Iterable<SpaceSettingsContent>? content,
    SpaceSettingsSnapshot? snapshot,
  }) {
    final result = create();
    if (content != null) result.content.addAll(content);
    if (snapshot != null) result.snapshot = snapshot;
    return result;
  }

  SettingsData._();

  factory SettingsData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SettingsData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SettingsData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..pPM<SpaceSettingsContent>(1, _omitFieldNames ? '' : 'content',
        subBuilder: SpaceSettingsContent.create)
    ..aOM<SpaceSettingsSnapshot>(2, _omitFieldNames ? '' : 'snapshot',
        subBuilder: SpaceSettingsSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SettingsData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SettingsData copyWith(void Function(SettingsData) updates) =>
      super.copyWith((message) => updates(message as SettingsData))
          as SettingsData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SettingsData create() => SettingsData._();
  @$core.override
  SettingsData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SettingsData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SettingsData>(create);
  static SettingsData? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SpaceSettingsContent> get content => $_getList(0);

  @$pb.TagNumber(2)
  SpaceSettingsSnapshot get snapshot => $_getN(1);
  @$pb.TagNumber(2)
  set snapshot(SpaceSettingsSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSnapshot() => $_has(1);
  @$pb.TagNumber(2)
  void clearSnapshot() => $_clearField(2);
  @$pb.TagNumber(2)
  SpaceSettingsSnapshot ensureSnapshot() => $_ensure(1);
}

class SpaceSubscription extends $pb.GeneratedMessage {
  factory SpaceSubscription({
    $core.Iterable<$core.String>? spaceIds,
    SpaceSubscriptionAction? action,
  }) {
    final result = create();
    if (spaceIds != null) result.spaceIds.addAll(spaceIds);
    if (action != null) result.action = action;
    return result;
  }

  SpaceSubscription._();

  factory SpaceSubscription.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceSubscription.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceSubscription',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'spaceIds', protoName: 'spaceIds')
    ..aE<SpaceSubscriptionAction>(2, _omitFieldNames ? '' : 'action',
        enumValues: SpaceSubscriptionAction.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSubscription clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSubscription copyWith(void Function(SpaceSubscription) updates) =>
      super.copyWith((message) => updates(message as SpaceSubscription))
          as SpaceSubscription;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceSubscription create() => SpaceSubscription._();
  @$core.override
  SpaceSubscription createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceSubscription getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceSubscription>(create);
  static SpaceSubscription? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get spaceIds => $_getList(0);

  @$pb.TagNumber(2)
  SpaceSubscriptionAction get action => $_getN(1);
  @$pb.TagNumber(2)
  set action(SpaceSubscriptionAction value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);
}

/// AclAddRecordRequest contains marshaled consensusproto.RawRecord
class AclAddRecordRequest extends $pb.GeneratedMessage {
  factory AclAddRecordRequest({
    $core.String? spaceId,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (payload != null) result.payload = payload;
    return result;
  }

  AclAddRecordRequest._();

  factory AclAddRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAddRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAddRecordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAddRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAddRecordRequest copyWith(void Function(AclAddRecordRequest) updates) =>
      super.copyWith((message) => updates(message as AclAddRecordRequest))
          as AclAddRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAddRecordRequest create() => AclAddRecordRequest._();
  @$core.override
  AclAddRecordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAddRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAddRecordRequest>(create);
  static AclAddRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);
}

/// AclAddRecordResponse contains created record id and marshaled consensusproto.RawRecord
class AclAddRecordResponse extends $pb.GeneratedMessage {
  factory AclAddRecordResponse({
    $core.String? recordId,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (payload != null) result.payload = payload;
    return result;
  }

  AclAddRecordResponse._();

  factory AclAddRecordResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAddRecordResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAddRecordResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId', protoName: 'recordId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAddRecordResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAddRecordResponse copyWith(void Function(AclAddRecordResponse) updates) =>
      super.copyWith((message) => updates(message as AclAddRecordResponse))
          as AclAddRecordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAddRecordResponse create() => AclAddRecordResponse._();
  @$core.override
  AclAddRecordResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAddRecordResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAddRecordResponse>(create);
  static AclAddRecordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);
}

/// AclGetRecordsRequest can optionally contain the last known aclHead, the server will return only new records or an empty list if there are no new records.
/// If aclHead is not provided the whole list will be returned.
class AclGetRecordsRequest extends $pb.GeneratedMessage {
  factory AclGetRecordsRequest({
    $core.String? spaceId,
    $core.String? aclHead,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (aclHead != null) result.aclHead = aclHead;
    return result;
  }

  AclGetRecordsRequest._();

  factory AclGetRecordsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclGetRecordsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclGetRecordsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'aclHead', protoName: 'aclHead')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclGetRecordsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclGetRecordsRequest copyWith(void Function(AclGetRecordsRequest) updates) =>
      super.copyWith((message) => updates(message as AclGetRecordsRequest))
          as AclGetRecordsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclGetRecordsRequest create() => AclGetRecordsRequest._();
  @$core.override
  AclGetRecordsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclGetRecordsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclGetRecordsRequest>(create);
  static AclGetRecordsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get aclHead => $_getSZ(1);
  @$pb.TagNumber(2)
  set aclHead($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAclHead() => $_has(1);
  @$pb.TagNumber(2)
  void clearAclHead() => $_clearField(2);
}

/// AclGetRecordsResponse contains list of marshaled consensusproto.RawRecordWithId
class AclGetRecordsResponse extends $pb.GeneratedMessage {
  factory AclGetRecordsResponse({
    $core.Iterable<$core.List<$core.int>>? records,
  }) {
    final result = create();
    if (records != null) result.records.addAll(records);
    return result;
  }

  AclGetRecordsResponse._();

  factory AclGetRecordsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclGetRecordsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclGetRecordsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..p<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'records', $pb.PbFieldType.PY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclGetRecordsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclGetRecordsResponse copyWith(
          void Function(AclGetRecordsResponse) updates) =>
      super.copyWith((message) => updates(message as AclGetRecordsResponse))
          as AclGetRecordsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclGetRecordsResponse create() => AclGetRecordsResponse._();
  @$core.override
  AclGetRecordsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclGetRecordsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclGetRecordsResponse>(create);
  static AclGetRecordsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.List<$core.int>> get records => $_getList(0);
}

class StoreDiffRequest extends $pb.GeneratedMessage {
  factory StoreDiffRequest({
    $core.String? spaceId,
    $core.Iterable<HeadSyncRange>? ranges,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (ranges != null) result.ranges.addAll(ranges);
    return result;
  }

  StoreDiffRequest._();

  factory StoreDiffRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StoreDiffRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StoreDiffRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..pPM<HeadSyncRange>(2, _omitFieldNames ? '' : 'ranges',
        subBuilder: HeadSyncRange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreDiffRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreDiffRequest copyWith(void Function(StoreDiffRequest) updates) =>
      super.copyWith((message) => updates(message as StoreDiffRequest))
          as StoreDiffRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreDiffRequest create() => StoreDiffRequest._();
  @$core.override
  StoreDiffRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StoreDiffRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreDiffRequest>(create);
  static StoreDiffRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<HeadSyncRange> get ranges => $_getList(1);
}

class StoreDiffResponse extends $pb.GeneratedMessage {
  factory StoreDiffResponse({
    $core.Iterable<HeadSyncResult>? results,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    return result;
  }

  StoreDiffResponse._();

  factory StoreDiffResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StoreDiffResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StoreDiffResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..pPM<HeadSyncResult>(1, _omitFieldNames ? '' : 'results',
        subBuilder: HeadSyncResult.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreDiffResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreDiffResponse copyWith(void Function(StoreDiffResponse) updates) =>
      super.copyWith((message) => updates(message as StoreDiffResponse))
          as StoreDiffResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreDiffResponse create() => StoreDiffResponse._();
  @$core.override
  StoreDiffResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StoreDiffResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreDiffResponse>(create);
  static StoreDiffResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<HeadSyncResult> get results => $_getList(0);
}

class StoreKeyValue extends $pb.GeneratedMessage {
  factory StoreKeyValue({
    $core.String? keyPeerId,
    $core.List<$core.int>? value,
    $core.List<$core.int>? identitySignature,
    $core.List<$core.int>? peerSignature,
    $core.String? spaceId,
  }) {
    final result = create();
    if (keyPeerId != null) result.keyPeerId = keyPeerId;
    if (value != null) result.value = value;
    if (identitySignature != null) result.identitySignature = identitySignature;
    if (peerSignature != null) result.peerSignature = peerSignature;
    if (spaceId != null) result.spaceId = spaceId;
    return result;
  }

  StoreKeyValue._();

  factory StoreKeyValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StoreKeyValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StoreKeyValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'keyPeerId', protoName: 'keyPeerId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'identitySignature', $pb.PbFieldType.OY,
        protoName: 'identitySignature')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'peerSignature', $pb.PbFieldType.OY,
        protoName: 'peerSignature')
    ..aOS(5, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreKeyValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreKeyValue copyWith(void Function(StoreKeyValue) updates) =>
      super.copyWith((message) => updates(message as StoreKeyValue))
          as StoreKeyValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreKeyValue create() => StoreKeyValue._();
  @$core.override
  StoreKeyValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StoreKeyValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreKeyValue>(create);
  static StoreKeyValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get keyPeerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set keyPeerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeyPeerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeyPeerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get identitySignature => $_getN(2);
  @$pb.TagNumber(3)
  set identitySignature($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentitySignature() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentitySignature() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get peerSignature => $_getN(3);
  @$pb.TagNumber(4)
  set peerSignature($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPeerSignature() => $_has(3);
  @$pb.TagNumber(4)
  void clearPeerSignature() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get spaceId => $_getSZ(4);
  @$pb.TagNumber(5)
  set spaceId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpaceId() => $_clearField(5);
}

class StoreKeyValues extends $pb.GeneratedMessage {
  factory StoreKeyValues({
    $core.Iterable<StoreKeyValue>? keyValues,
  }) {
    final result = create();
    if (keyValues != null) result.keyValues.addAll(keyValues);
    return result;
  }

  StoreKeyValues._();

  factory StoreKeyValues.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StoreKeyValues.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StoreKeyValues',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..pPM<StoreKeyValue>(1, _omitFieldNames ? '' : 'keyValues',
        protoName: 'keyValues', subBuilder: StoreKeyValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreKeyValues clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreKeyValues copyWith(void Function(StoreKeyValues) updates) =>
      super.copyWith((message) => updates(message as StoreKeyValues))
          as StoreKeyValues;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreKeyValues create() => StoreKeyValues._();
  @$core.override
  StoreKeyValues createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StoreKeyValues getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreKeyValues>(create);
  static StoreKeyValues? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<StoreKeyValue> get keyValues => $_getList(0);
}

class StoreKeyInner extends $pb.GeneratedMessage {
  factory StoreKeyInner({
    $core.List<$core.int>? peer,
    $core.List<$core.int>? identity,
    $core.List<$core.int>? value,
    $fixnum.Int64? timestampMicro,
    $core.String? aclHeadId,
    $core.String? key,
  }) {
    final result = create();
    if (peer != null) result.peer = peer;
    if (identity != null) result.identity = identity;
    if (value != null) result.value = value;
    if (timestampMicro != null) result.timestampMicro = timestampMicro;
    if (aclHeadId != null) result.aclHeadId = aclHeadId;
    if (key != null) result.key = key;
    return result;
  }

  StoreKeyInner._();

  factory StoreKeyInner.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StoreKeyInner.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StoreKeyInner',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'peer', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OY)
    ..aInt64(4, _omitFieldNames ? '' : 'timestampMicro',
        protoName: 'timestampMicro')
    ..aOS(5, _omitFieldNames ? '' : 'aclHeadId', protoName: 'aclHeadId')
    ..aOS(6, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreKeyInner clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreKeyInner copyWith(void Function(StoreKeyInner) updates) =>
      super.copyWith((message) => updates(message as StoreKeyInner))
          as StoreKeyInner;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreKeyInner create() => StoreKeyInner._();
  @$core.override
  StoreKeyInner createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StoreKeyInner getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreKeyInner>(create);
  static StoreKeyInner? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get peer => $_getN(0);
  @$pb.TagNumber(1)
  set peer($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPeer() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeer() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get identity => $_getN(1);
  @$pb.TagNumber(2)
  set identity($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentity() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get value => $_getN(2);
  @$pb.TagNumber(3)
  set value($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestampMicro => $_getI64(3);
  @$pb.TagNumber(4)
  set timestampMicro($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestampMicro() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestampMicro() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get aclHeadId => $_getSZ(4);
  @$pb.TagNumber(5)
  set aclHeadId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAclHeadId() => $_has(4);
  @$pb.TagNumber(5)
  void clearAclHeadId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get key => $_getSZ(5);
  @$pb.TagNumber(6)
  set key($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearKey() => $_clearField(6);
}

class StorageHeader extends $pb.GeneratedMessage {
  factory StorageHeader({
    $core.String? spaceId,
    $core.String? storageName,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (storageName != null) result.storageName = storageName;
    return result;
  }

  StorageHeader._();

  factory StorageHeader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StorageHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StorageHeader',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'spacesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'storageName', protoName: 'storageName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StorageHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StorageHeader copyWith(void Function(StorageHeader) updates) =>
      super.copyWith((message) => updates(message as StorageHeader))
          as StorageHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StorageHeader create() => StorageHeader._();
  @$core.override
  StorageHeader createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StorageHeader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StorageHeader>(create);
  static StorageHeader? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get storageName => $_getSZ(1);
  @$pb.TagNumber(2)
  set storageName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStorageName() => $_has(1);
  @$pb.TagNumber(2)
  void clearStorageName() => $_clearField(2);
}

class SpaceSyncApi {
  final $pb.RpcClient _client;

  SpaceSyncApi(this._client);

  /// HeadSync compares all objects and their hashes in a space
  $async.Future<HeadSyncResponse> headSync(
          $pb.ClientContext? ctx, HeadSyncRequest request) =>
      _client.invoke<HeadSyncResponse>(
          ctx, 'SpaceSync', 'HeadSync', request, HeadSyncResponse());

  /// StoreDiff compares all objects and their hashes in a space
  $async.Future<StoreDiffResponse> storeDiff(
          $pb.ClientContext? ctx, StoreDiffRequest request) =>
      _client.invoke<StoreDiffResponse>(
          ctx, 'SpaceSync', 'StoreDiff', request, StoreDiffResponse());

  /// StoreElements exchanges elements between peers
  $async.Future<StoreKeyValue> storeElements(
          $pb.ClientContext? ctx, StoreKeyValue request) =>
      _client.invoke<StoreKeyValue>(
          ctx, 'SpaceSync', 'StoreElements', request, StoreKeyValue());

  /// SpacePush sends new space to the node
  $async.Future<SpacePushResponse> spacePush(
          $pb.ClientContext? ctx, SpacePushRequest request) =>
      _client.invoke<SpacePushResponse>(
          ctx, 'SpaceSync', 'SpacePush', request, SpacePushResponse());

  /// SpacePull gets space from the remote peer
  $async.Future<SpacePullResponse> spacePull(
          $pb.ClientContext? ctx, SpacePullRequest request) =>
      _client.invoke<SpacePullResponse>(
          ctx, 'SpaceSync', 'SpacePull', request, SpacePullResponse());

  /// ObjectSyncStream opens object sync stream with node or client
  $async.Future<ObjectSyncMessage> objectSyncStream(
          $pb.ClientContext? ctx, ObjectSyncMessage request) =>
      _client.invoke<ObjectSyncMessage>(
          ctx, 'SpaceSync', 'ObjectSyncStream', request, ObjectSyncMessage());

  /// ObjectSync sends object sync message and synchronously gets response message
  $async.Future<ObjectSyncMessage> objectSync(
          $pb.ClientContext? ctx, ObjectSyncMessage request) =>
      _client.invoke<ObjectSyncMessage>(
          ctx, 'SpaceSync', 'ObjectSync', request, ObjectSyncMessage());

  /// ObjectSyncRequestStream opens sends a request and gets streamed response
  $async.Future<ObjectSyncMessage> objectSyncRequestStream(
          $pb.ClientContext? ctx, ObjectSyncMessage request) =>
      _client.invoke<ObjectSyncMessage>(ctx, 'SpaceSync',
          'ObjectSyncRequestStream', request, ObjectSyncMessage());

  /// AclAddRecord adds a new record to acl log. Works only with any-sync-node
  /// deprecated: use coordinator api
  $async.Future<AclAddRecordResponse> aclAddRecord(
          $pb.ClientContext? ctx, AclAddRecordRequest request) =>
      _client.invoke<AclAddRecordResponse>(
          ctx, 'SpaceSync', 'AclAddRecord', request, AclAddRecordResponse());

  /// AclGetRecords gets acl records
  /// deprecated: use coordinator api
  $async.Future<AclGetRecordsResponse> aclGetRecords(
          $pb.ClientContext? ctx, AclGetRecordsRequest request) =>
      _client.invoke<AclGetRecordsResponse>(
          ctx, 'SpaceSync', 'AclGetRecords', request, AclGetRecordsResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
