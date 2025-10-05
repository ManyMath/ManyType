// This is a generated file - do not edit.
//
// Generated from any_sync/file.proto.

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

import 'file.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'file.pbenum.dart';

class Ok extends $pb.GeneratedMessage {
  factory Ok() => create();

  Ok._();

  factory Ok.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Ok.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ok',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ok clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ok copyWith(void Function(Ok) updates) =>
      super.copyWith((message) => updates(message as Ok)) as Ok;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Ok create() => Ok._();
  @$core.override
  Ok createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Ok getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Ok>(create);
  static Ok? _defaultInstance;
}

class BlockGetRequest extends $pb.GeneratedMessage {
  factory BlockGetRequest({
    $core.String? spaceId,
    $core.List<$core.int>? cid,
    $core.bool? wait,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (cid != null) result.cid = cid;
    if (wait != null) result.wait = wait;
    return result;
  }

  BlockGetRequest._();

  factory BlockGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'cid', $pb.PbFieldType.OY)
    ..aOB(3, _omitFieldNames ? '' : 'wait')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockGetRequest copyWith(void Function(BlockGetRequest) updates) =>
      super.copyWith((message) => updates(message as BlockGetRequest))
          as BlockGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockGetRequest create() => BlockGetRequest._();
  @$core.override
  BlockGetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockGetRequest>(create);
  static BlockGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get cid => $_getN(1);
  @$pb.TagNumber(2)
  set cid($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCid() => $_has(1);
  @$pb.TagNumber(2)
  void clearCid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get wait => $_getBF(2);
  @$pb.TagNumber(3)
  set wait($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWait() => $_has(2);
  @$pb.TagNumber(3)
  void clearWait() => $_clearField(3);
}

class BlockGetResponse extends $pb.GeneratedMessage {
  factory BlockGetResponse({
    $core.List<$core.int>? cid,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (cid != null) result.cid = cid;
    if (data != null) result.data = data;
    return result;
  }

  BlockGetResponse._();

  factory BlockGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'cid', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockGetResponse copyWith(void Function(BlockGetResponse) updates) =>
      super.copyWith((message) => updates(message as BlockGetResponse))
          as BlockGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockGetResponse create() => BlockGetResponse._();
  @$core.override
  BlockGetResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockGetResponse>(create);
  static BlockGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get cid => $_getN(0);
  @$pb.TagNumber(1)
  set cid($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCid() => $_has(0);
  @$pb.TagNumber(1)
  void clearCid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);
}

class BlockPushRequest extends $pb.GeneratedMessage {
  factory BlockPushRequest({
    $core.String? spaceId,
    $core.String? fileId,
    $core.List<$core.int>? cid,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (fileId != null) result.fileId = fileId;
    if (cid != null) result.cid = cid;
    if (data != null) result.data = data;
    return result;
  }

  BlockPushRequest._();

  factory BlockPushRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockPushRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockPushRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'fileId', protoName: 'fileId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'cid', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockPushRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockPushRequest copyWith(void Function(BlockPushRequest) updates) =>
      super.copyWith((message) => updates(message as BlockPushRequest))
          as BlockPushRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockPushRequest create() => BlockPushRequest._();
  @$core.override
  BlockPushRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockPushRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockPushRequest>(create);
  static BlockPushRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get cid => $_getN(2);
  @$pb.TagNumber(3)
  set cid($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCid() => $_has(2);
  @$pb.TagNumber(3)
  void clearCid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get data => $_getN(3);
  @$pb.TagNumber(4)
  set data($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasData() => $_has(3);
  @$pb.TagNumber(4)
  void clearData() => $_clearField(4);
}

class BlocksCheckRequest extends $pb.GeneratedMessage {
  factory BlocksCheckRequest({
    $core.String? spaceId,
    $core.Iterable<$core.List<$core.int>>? cids,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (cids != null) result.cids.addAll(cids);
    return result;
  }

  BlocksCheckRequest._();

  factory BlocksCheckRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlocksCheckRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlocksCheckRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..p<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'cids', $pb.PbFieldType.PY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlocksCheckRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlocksCheckRequest copyWith(void Function(BlocksCheckRequest) updates) =>
      super.copyWith((message) => updates(message as BlocksCheckRequest))
          as BlocksCheckRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlocksCheckRequest create() => BlocksCheckRequest._();
  @$core.override
  BlocksCheckRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlocksCheckRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlocksCheckRequest>(create);
  static BlocksCheckRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.List<$core.int>> get cids => $_getList(1);
}

class BlocksCheckResponse extends $pb.GeneratedMessage {
  factory BlocksCheckResponse({
    $core.Iterable<BlockAvailability>? blocksAvailability,
  }) {
    final result = create();
    if (blocksAvailability != null)
      result.blocksAvailability.addAll(blocksAvailability);
    return result;
  }

  BlocksCheckResponse._();

  factory BlocksCheckResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlocksCheckResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlocksCheckResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..pPM<BlockAvailability>(1, _omitFieldNames ? '' : 'blocksAvailability',
        protoName: 'blocksAvailability', subBuilder: BlockAvailability.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlocksCheckResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlocksCheckResponse copyWith(void Function(BlocksCheckResponse) updates) =>
      super.copyWith((message) => updates(message as BlocksCheckResponse))
          as BlocksCheckResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlocksCheckResponse create() => BlocksCheckResponse._();
  @$core.override
  BlocksCheckResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlocksCheckResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlocksCheckResponse>(create);
  static BlocksCheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BlockAvailability> get blocksAvailability => $_getList(0);
}

class BlockAvailability extends $pb.GeneratedMessage {
  factory BlockAvailability({
    $core.List<$core.int>? cid,
    AvailabilityStatus? status,
  }) {
    final result = create();
    if (cid != null) result.cid = cid;
    if (status != null) result.status = status;
    return result;
  }

  BlockAvailability._();

  factory BlockAvailability.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockAvailability.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockAvailability',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'cid', $pb.PbFieldType.OY)
    ..aE<AvailabilityStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: AvailabilityStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockAvailability clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockAvailability copyWith(void Function(BlockAvailability) updates) =>
      super.copyWith((message) => updates(message as BlockAvailability))
          as BlockAvailability;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockAvailability create() => BlockAvailability._();
  @$core.override
  BlockAvailability createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockAvailability getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockAvailability>(create);
  static BlockAvailability? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get cid => $_getN(0);
  @$pb.TagNumber(1)
  set cid($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCid() => $_has(0);
  @$pb.TagNumber(1)
  void clearCid() => $_clearField(1);

  @$pb.TagNumber(2)
  AvailabilityStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(AvailabilityStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
}

class BlocksBindRequest extends $pb.GeneratedMessage {
  factory BlocksBindRequest({
    $core.String? spaceId,
    $core.String? fileId,
    $core.Iterable<$core.List<$core.int>>? cids,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (fileId != null) result.fileId = fileId;
    if (cids != null) result.cids.addAll(cids);
    return result;
  }

  BlocksBindRequest._();

  factory BlocksBindRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlocksBindRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlocksBindRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'fileId', protoName: 'fileId')
    ..p<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'cids', $pb.PbFieldType.PY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlocksBindRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlocksBindRequest copyWith(void Function(BlocksBindRequest) updates) =>
      super.copyWith((message) => updates(message as BlocksBindRequest))
          as BlocksBindRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlocksBindRequest create() => BlocksBindRequest._();
  @$core.override
  BlocksBindRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlocksBindRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlocksBindRequest>(create);
  static BlocksBindRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fileId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.List<$core.int>> get cids => $_getList(2);
}

class FilesDeleteRequest extends $pb.GeneratedMessage {
  factory FilesDeleteRequest({
    $core.String? spaceId,
    $core.Iterable<$core.String>? fileIds,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (fileIds != null) result.fileIds.addAll(fileIds);
    return result;
  }

  FilesDeleteRequest._();

  factory FilesDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FilesDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilesDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..pPS(2, _omitFieldNames ? '' : 'fileIds', protoName: 'fileIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesDeleteRequest copyWith(void Function(FilesDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as FilesDeleteRequest))
          as FilesDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FilesDeleteRequest create() => FilesDeleteRequest._();
  @$core.override
  FilesDeleteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FilesDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FilesDeleteRequest>(create);
  static FilesDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get fileIds => $_getList(1);
}

class FilesDeleteResponse extends $pb.GeneratedMessage {
  factory FilesDeleteResponse() => create();

  FilesDeleteResponse._();

  factory FilesDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FilesDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilesDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesDeleteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesDeleteResponse copyWith(void Function(FilesDeleteResponse) updates) =>
      super.copyWith((message) => updates(message as FilesDeleteResponse))
          as FilesDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FilesDeleteResponse create() => FilesDeleteResponse._();
  @$core.override
  FilesDeleteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FilesDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FilesDeleteResponse>(create);
  static FilesDeleteResponse? _defaultInstance;
}

class FilesInfoRequest extends $pb.GeneratedMessage {
  factory FilesInfoRequest({
    $core.String? spaceId,
    $core.Iterable<$core.String>? fileIds,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (fileIds != null) result.fileIds.addAll(fileIds);
    return result;
  }

  FilesInfoRequest._();

  factory FilesInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FilesInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilesInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..pPS(2, _omitFieldNames ? '' : 'fileIds', protoName: 'fileIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesInfoRequest copyWith(void Function(FilesInfoRequest) updates) =>
      super.copyWith((message) => updates(message as FilesInfoRequest))
          as FilesInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FilesInfoRequest create() => FilesInfoRequest._();
  @$core.override
  FilesInfoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FilesInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FilesInfoRequest>(create);
  static FilesInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get fileIds => $_getList(1);
}

class FilesInfoResponse extends $pb.GeneratedMessage {
  factory FilesInfoResponse({
    $core.Iterable<FileInfo>? filesInfo,
  }) {
    final result = create();
    if (filesInfo != null) result.filesInfo.addAll(filesInfo);
    return result;
  }

  FilesInfoResponse._();

  factory FilesInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FilesInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilesInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..pPM<FileInfo>(1, _omitFieldNames ? '' : 'filesInfo',
        protoName: 'filesInfo', subBuilder: FileInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesInfoResponse copyWith(void Function(FilesInfoResponse) updates) =>
      super.copyWith((message) => updates(message as FilesInfoResponse))
          as FilesInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FilesInfoResponse create() => FilesInfoResponse._();
  @$core.override
  FilesInfoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FilesInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FilesInfoResponse>(create);
  static FilesInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FileInfo> get filesInfo => $_getList(0);
}

class FileInfo extends $pb.GeneratedMessage {
  factory FileInfo({
    $core.String? fileId,
    $fixnum.Int64? usageBytes,
    $core.int? cidsCount,
  }) {
    final result = create();
    if (fileId != null) result.fileId = fileId;
    if (usageBytes != null) result.usageBytes = usageBytes;
    if (cidsCount != null) result.cidsCount = cidsCount;
    return result;
  }

  FileInfo._();

  factory FileInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fileId', protoName: 'fileId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'usageBytes', $pb.PbFieldType.OU6,
        protoName: 'usageBytes', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'cidsCount',
        protoName: 'cidsCount', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileInfo copyWith(void Function(FileInfo) updates) =>
      super.copyWith((message) => updates(message as FileInfo)) as FileInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileInfo create() => FileInfo._();
  @$core.override
  FileInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileInfo>(create);
  static FileInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFileId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get usageBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set usageBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsageBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsageBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get cidsCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set cidsCount($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCidsCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCidsCount() => $_clearField(3);
}

class FilesGetRequest extends $pb.GeneratedMessage {
  factory FilesGetRequest({
    $core.String? spaceId,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    return result;
  }

  FilesGetRequest._();

  factory FilesGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FilesGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilesGetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesGetRequest copyWith(void Function(FilesGetRequest) updates) =>
      super.copyWith((message) => updates(message as FilesGetRequest))
          as FilesGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FilesGetRequest create() => FilesGetRequest._();
  @$core.override
  FilesGetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FilesGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FilesGetRequest>(create);
  static FilesGetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);
}

class FilesGetResponse extends $pb.GeneratedMessage {
  factory FilesGetResponse({
    $core.String? fileId,
  }) {
    final result = create();
    if (fileId != null) result.fileId = fileId;
    return result;
  }

  FilesGetResponse._();

  factory FilesGetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FilesGetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FilesGetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fileId', protoName: 'fileId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesGetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FilesGetResponse copyWith(void Function(FilesGetResponse) updates) =>
      super.copyWith((message) => updates(message as FilesGetResponse))
          as FilesGetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FilesGetResponse create() => FilesGetResponse._();
  @$core.override
  FilesGetResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FilesGetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FilesGetResponse>(create);
  static FilesGetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFileId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileId() => $_clearField(1);
}

class CheckRequest extends $pb.GeneratedMessage {
  factory CheckRequest() => create();

  CheckRequest._();

  factory CheckRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckRequest copyWith(void Function(CheckRequest) updates) =>
      super.copyWith((message) => updates(message as CheckRequest))
          as CheckRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckRequest create() => CheckRequest._();
  @$core.override
  CheckRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckRequest>(create);
  static CheckRequest? _defaultInstance;
}

class CheckResponse extends $pb.GeneratedMessage {
  factory CheckResponse({
    $core.Iterable<$core.String>? spaceIds,
    $core.bool? allowWrite,
  }) {
    final result = create();
    if (spaceIds != null) result.spaceIds.addAll(spaceIds);
    if (allowWrite != null) result.allowWrite = allowWrite;
    return result;
  }

  CheckResponse._();

  factory CheckResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'spaceIds', protoName: 'spaceIds')
    ..aOB(2, _omitFieldNames ? '' : 'allowWrite', protoName: 'allowWrite')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckResponse copyWith(void Function(CheckResponse) updates) =>
      super.copyWith((message) => updates(message as CheckResponse))
          as CheckResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckResponse create() => CheckResponse._();
  @$core.override
  CheckResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckResponse>(create);
  static CheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get spaceIds => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get allowWrite => $_getBF(1);
  @$pb.TagNumber(2)
  set allowWrite($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAllowWrite() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowWrite() => $_clearField(2);
}

class SpaceInfoRequest extends $pb.GeneratedMessage {
  factory SpaceInfoRequest({
    $core.String? spaceId,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    return result;
  }

  SpaceInfoRequest._();

  factory SpaceInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceInfoRequest copyWith(void Function(SpaceInfoRequest) updates) =>
      super.copyWith((message) => updates(message as SpaceInfoRequest))
          as SpaceInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceInfoRequest create() => SpaceInfoRequest._();
  @$core.override
  SpaceInfoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceInfoRequest>(create);
  static SpaceInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);
}

class SpaceInfoResponse extends $pb.GeneratedMessage {
  factory SpaceInfoResponse({
    $fixnum.Int64? limitBytes,
    $fixnum.Int64? totalUsageBytes,
    $fixnum.Int64? cidsCount,
    $fixnum.Int64? filesCount,
    $fixnum.Int64? spaceUsageBytes,
    $core.String? spaceId,
  }) {
    final result = create();
    if (limitBytes != null) result.limitBytes = limitBytes;
    if (totalUsageBytes != null) result.totalUsageBytes = totalUsageBytes;
    if (cidsCount != null) result.cidsCount = cidsCount;
    if (filesCount != null) result.filesCount = filesCount;
    if (spaceUsageBytes != null) result.spaceUsageBytes = spaceUsageBytes;
    if (spaceId != null) result.spaceId = spaceId;
    return result;
  }

  SpaceInfoResponse._();

  factory SpaceInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'limitBytes', $pb.PbFieldType.OU6,
        protoName: 'limitBytes', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'totalUsageBytes', $pb.PbFieldType.OU6,
        protoName: 'totalUsageBytes', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'cidsCount', $pb.PbFieldType.OU6,
        protoName: 'cidsCount', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'filesCount', $pb.PbFieldType.OU6,
        protoName: 'filesCount', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'spaceUsageBytes', $pb.PbFieldType.OU6,
        protoName: 'spaceUsageBytes', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(6, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceInfoResponse copyWith(void Function(SpaceInfoResponse) updates) =>
      super.copyWith((message) => updates(message as SpaceInfoResponse))
          as SpaceInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceInfoResponse create() => SpaceInfoResponse._();
  @$core.override
  SpaceInfoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceInfoResponse>(create);
  static SpaceInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get limitBytes => $_getI64(0);
  @$pb.TagNumber(1)
  set limitBytes($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLimitBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimitBytes() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalUsageBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set totalUsageBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalUsageBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalUsageBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get cidsCount => $_getI64(2);
  @$pb.TagNumber(3)
  set cidsCount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCidsCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCidsCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get filesCount => $_getI64(3);
  @$pb.TagNumber(4)
  set filesCount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFilesCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilesCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get spaceUsageBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set spaceUsageBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceUsageBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpaceUsageBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get spaceId => $_getSZ(5);
  @$pb.TagNumber(6)
  set spaceId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSpaceId() => $_has(5);
  @$pb.TagNumber(6)
  void clearSpaceId() => $_clearField(6);
}

class AccountInfoRequest extends $pb.GeneratedMessage {
  factory AccountInfoRequest() => create();

  AccountInfoRequest._();

  factory AccountInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountInfoRequest copyWith(void Function(AccountInfoRequest) updates) =>
      super.copyWith((message) => updates(message as AccountInfoRequest))
          as AccountInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountInfoRequest create() => AccountInfoRequest._();
  @$core.override
  AccountInfoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountInfoRequest>(create);
  static AccountInfoRequest? _defaultInstance;
}

class AccountInfoResponse extends $pb.GeneratedMessage {
  factory AccountInfoResponse({
    $fixnum.Int64? limitBytes,
    $fixnum.Int64? totalUsageBytes,
    $fixnum.Int64? totalCidsCount,
    $core.Iterable<SpaceInfoResponse>? spaces,
    $fixnum.Int64? accountLimitBytes,
  }) {
    final result = create();
    if (limitBytes != null) result.limitBytes = limitBytes;
    if (totalUsageBytes != null) result.totalUsageBytes = totalUsageBytes;
    if (totalCidsCount != null) result.totalCidsCount = totalCidsCount;
    if (spaces != null) result.spaces.addAll(spaces);
    if (accountLimitBytes != null) result.accountLimitBytes = accountLimitBytes;
    return result;
  }

  AccountInfoResponse._();

  factory AccountInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'limitBytes', $pb.PbFieldType.OU6,
        protoName: 'limitBytes', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'totalUsageBytes', $pb.PbFieldType.OU6,
        protoName: 'totalUsageBytes', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'totalCidsCount', $pb.PbFieldType.OU6,
        protoName: 'totalCidsCount', defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<SpaceInfoResponse>(4, _omitFieldNames ? '' : 'spaces',
        subBuilder: SpaceInfoResponse.create)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'accountLimitBytes', $pb.PbFieldType.OU6,
        protoName: 'accountLimitBytes', defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountInfoResponse copyWith(void Function(AccountInfoResponse) updates) =>
      super.copyWith((message) => updates(message as AccountInfoResponse))
          as AccountInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountInfoResponse create() => AccountInfoResponse._();
  @$core.override
  AccountInfoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountInfoResponse>(create);
  static AccountInfoResponse? _defaultInstance;

  /// the shared limit excluding isolated spaces
  @$pb.TagNumber(1)
  $fixnum.Int64 get limitBytes => $_getI64(0);
  @$pb.TagNumber(1)
  set limitBytes($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLimitBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimitBytes() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalUsageBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set totalUsageBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalUsageBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalUsageBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalCidsCount => $_getI64(2);
  @$pb.TagNumber(3)
  set totalCidsCount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCidsCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCidsCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<SpaceInfoResponse> get spaces => $_getList(3);

  /// the total limit including isolated spaces
  @$pb.TagNumber(5)
  $fixnum.Int64 get accountLimitBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set accountLimitBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAccountLimitBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearAccountLimitBytes() => $_clearField(5);
}

class AccountLimitSetRequest extends $pb.GeneratedMessage {
  factory AccountLimitSetRequest({
    $core.String? identity,
    $fixnum.Int64? limit,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (limit != null) result.limit = limit;
    return result;
  }

  AccountLimitSetRequest._();

  factory AccountLimitSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountLimitSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountLimitSetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'identity')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountLimitSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountLimitSetRequest copyWith(
          void Function(AccountLimitSetRequest) updates) =>
      super.copyWith((message) => updates(message as AccountLimitSetRequest))
          as AccountLimitSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountLimitSetRequest create() => AccountLimitSetRequest._();
  @$core.override
  AccountLimitSetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountLimitSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountLimitSetRequest>(create);
  static AccountLimitSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get identity => $_getSZ(0);
  @$pb.TagNumber(1)
  set identity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get limit => $_getI64(1);
  @$pb.TagNumber(2)
  set limit($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

class SpaceLimitSetRequest extends $pb.GeneratedMessage {
  factory SpaceLimitSetRequest({
    $core.String? spaceId,
    $fixnum.Int64? limit,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (limit != null) result.limit = limit;
    return result;
  }

  SpaceLimitSetRequest._();

  factory SpaceLimitSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceLimitSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceLimitSetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'filesync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceLimitSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceLimitSetRequest copyWith(void Function(SpaceLimitSetRequest) updates) =>
      super.copyWith((message) => updates(message as SpaceLimitSetRequest))
          as SpaceLimitSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceLimitSetRequest create() => SpaceLimitSetRequest._();
  @$core.override
  SpaceLimitSetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceLimitSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceLimitSetRequest>(create);
  static SpaceLimitSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get limit => $_getI64(1);
  @$pb.TagNumber(2)
  set limit($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

class FileApi {
  final $pb.RpcClient _client;

  FileApi(this._client);

  /// BlockGet gets one block from a server
  $async.Future<BlockGetResponse> blockGet(
          $pb.ClientContext? ctx, BlockGetRequest request) =>
      _client.invoke<BlockGetResponse>(
          ctx, 'File', 'BlockGet', request, BlockGetResponse());

  /// BlockPush pushes one block to a server
  $async.Future<Ok> blockPush(
          $pb.ClientContext? ctx, BlockPushRequest request) =>
      _client.invoke<Ok>(ctx, 'File', 'BlockPush', request, Ok());

  /// BlocksCheck checks is CIDs exists
  $async.Future<BlocksCheckResponse> blocksCheck(
          $pb.ClientContext? ctx, BlocksCheckRequest request) =>
      _client.invoke<BlocksCheckResponse>(
          ctx, 'File', 'BlocksCheck', request, BlocksCheckResponse());

  /// BlocksBind binds CIDs to space
  $async.Future<Ok> blocksBind(
          $pb.ClientContext? ctx, BlocksBindRequest request) =>
      _client.invoke<Ok>(ctx, 'File', 'BlocksBind', request, Ok());

  /// FilesDelete deletes files by id
  $async.Future<FilesDeleteResponse> filesDelete(
          $pb.ClientContext? ctx, FilesDeleteRequest request) =>
      _client.invoke<FilesDeleteResponse>(
          ctx, 'File', 'FilesDelete', request, FilesDeleteResponse());

  /// FilesInfo return info by given files id
  $async.Future<FilesInfoResponse> filesInfo(
          $pb.ClientContext? ctx, FilesInfoRequest request) =>
      _client.invoke<FilesInfoResponse>(
          ctx, 'File', 'FilesInfo', request, FilesInfoResponse());

  /// FilesGet returns a stream that streams all file ids in the space
  $async.Future<FilesGetResponse> filesGet(
          $pb.ClientContext? ctx, FilesGetRequest request) =>
      _client.invoke<FilesGetResponse>(
          ctx, 'File', 'FilesGet', request, FilesGetResponse());

  /// Check checks the connection and credentials
  $async.Future<CheckResponse> check_(
          $pb.ClientContext? ctx, CheckRequest request) =>
      _client.invoke<CheckResponse>(
          ctx, 'File', 'Check', request, CheckResponse());

  /// SpaceInfo returns usage, limit, etc about space
  $async.Future<SpaceInfoResponse> spaceInfo(
          $pb.ClientContext? ctx, SpaceInfoRequest request) =>
      _client.invoke<SpaceInfoResponse>(
          ctx, 'File', 'SpaceInfo', request, SpaceInfoResponse());

  /// AccountInfo returns usage, limit, etc by all spaces
  $async.Future<AccountInfoResponse> accountInfo(
          $pb.ClientContext? ctx, AccountInfoRequest request) =>
      _client.invoke<AccountInfoResponse>(
          ctx, 'File', 'AccountInfo', request, AccountInfoResponse());

  /// AccountLimitSet sets the account file storage limit (available only for nodeconf members)
  $async.Future<Ok> accountLimitSet(
          $pb.ClientContext? ctx, AccountLimitSetRequest request) =>
      _client.invoke<Ok>(ctx, 'File', 'AccountLimitSet', request, Ok());

  /// SpaceLimitSet sets the space limit. Limit 0 means space will use account limits.
  $async.Future<Ok> spaceLimitSet(
          $pb.ClientContext? ctx, SpaceLimitSetRequest request) =>
      _client.invoke<Ok>(ctx, 'File', 'SpaceLimitSet', request, Ok());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
