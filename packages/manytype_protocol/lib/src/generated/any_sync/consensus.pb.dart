// This is a generated file - do not edit.
//
// Generated from any_sync/consensus.proto.

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

import 'consensus.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'consensus.pbenum.dart';

class Log extends $pb.GeneratedMessage {
  factory Log({
    $core.String? id,
    $core.Iterable<RawRecordWithId>? records,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (records != null) result.records.addAll(records);
    return result;
  }

  Log._();

  factory Log.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Log.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Log',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..pPM<RawRecordWithId>(3, _omitFieldNames ? '' : 'records',
        subBuilder: RawRecordWithId.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Log clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Log copyWith(void Function(Log) updates) =>
      super.copyWith((message) => updates(message as Log)) as Log;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Log create() => Log._();
  @$core.override
  Log createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Log getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Log>(create);
  static Log? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(3)
  $pb.PbList<RawRecordWithId> get records => $_getList(1);
}

/// RawRecord is a proto message containing the payload in bytes, signature of the account who added it and signature of the acceptor
class RawRecord extends $pb.GeneratedMessage {
  factory RawRecord({
    $core.List<$core.int>? payload,
    $core.List<$core.int>? signature,
    $core.List<$core.int>? acceptorIdentity,
    $core.List<$core.int>? acceptorSignature,
    $fixnum.Int64? acceptorTimestamp,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    if (signature != null) result.signature = signature;
    if (acceptorIdentity != null) result.acceptorIdentity = acceptorIdentity;
    if (acceptorSignature != null) result.acceptorSignature = acceptorSignature;
    if (acceptorTimestamp != null) result.acceptorTimestamp = acceptorTimestamp;
    return result;
  }

  RawRecord._();

  factory RawRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RawRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RawRecord',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'acceptorIdentity', $pb.PbFieldType.OY,
        protoName: 'acceptorIdentity')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'acceptorSignature', $pb.PbFieldType.OY,
        protoName: 'acceptorSignature')
    ..aInt64(5, _omitFieldNames ? '' : 'acceptorTimestamp',
        protoName: 'acceptorTimestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawRecord copyWith(void Function(RawRecord) updates) =>
      super.copyWith((message) => updates(message as RawRecord)) as RawRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RawRecord create() => RawRecord._();
  @$core.override
  RawRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RawRecord getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RawRecord>(create);
  static RawRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get acceptorIdentity => $_getN(2);
  @$pb.TagNumber(3)
  set acceptorIdentity($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAcceptorIdentity() => $_has(2);
  @$pb.TagNumber(3)
  void clearAcceptorIdentity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get acceptorSignature => $_getN(3);
  @$pb.TagNumber(4)
  set acceptorSignature($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAcceptorSignature() => $_has(3);
  @$pb.TagNumber(4)
  void clearAcceptorSignature() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get acceptorTimestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set acceptorTimestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAcceptorTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearAcceptorTimestamp() => $_clearField(5);
}

/// RawRecordWithId is a raw record and the id for convenience
class RawRecordWithId extends $pb.GeneratedMessage {
  factory RawRecordWithId({
    $core.List<$core.int>? payload,
    $core.String? id,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    if (id != null) result.id = id;
    return result;
  }

  RawRecordWithId._();

  factory RawRecordWithId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RawRecordWithId.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RawRecordWithId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawRecordWithId clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawRecordWithId copyWith(void Function(RawRecordWithId) updates) =>
      super.copyWith((message) => updates(message as RawRecordWithId))
          as RawRecordWithId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RawRecordWithId create() => RawRecordWithId._();
  @$core.override
  RawRecordWithId createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RawRecordWithId getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RawRecordWithId>(create);
  static RawRecordWithId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);
}

/// Record is a record containing a data
class Record extends $pb.GeneratedMessage {
  factory Record({
    $core.String? prevId,
    $core.List<$core.int>? identity,
    $core.List<$core.int>? data,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (prevId != null) result.prevId = prevId;
    if (identity != null) result.identity = identity;
    if (data != null) result.data = data;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  Record._();

  factory Record.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Record.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Record',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'prevId', protoName: 'prevId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Record clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Record copyWith(void Function(Record) updates) =>
      super.copyWith((message) => updates(message as Record)) as Record;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Record create() => Record._();
  @$core.override
  Record createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Record getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Record>(create);
  static Record? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prevId => $_getSZ(0);
  @$pb.TagNumber(1)
  set prevId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrevId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrevId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get identity => $_getN(1);
  @$pb.TagNumber(2)
  set identity($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentity() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
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

class LogAddRequest extends $pb.GeneratedMessage {
  factory LogAddRequest({
    $core.String? logId,
    RawRecordWithId? record,
  }) {
    final result = create();
    if (logId != null) result.logId = logId;
    if (record != null) result.record = record;
    return result;
  }

  LogAddRequest._();

  factory LogAddRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogAddRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogAddRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'logId', protoName: 'logId')
    ..aOM<RawRecordWithId>(2, _omitFieldNames ? '' : 'record',
        subBuilder: RawRecordWithId.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogAddRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogAddRequest copyWith(void Function(LogAddRequest) updates) =>
      super.copyWith((message) => updates(message as LogAddRequest))
          as LogAddRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogAddRequest create() => LogAddRequest._();
  @$core.override
  LogAddRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogAddRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogAddRequest>(create);
  static LogAddRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get logId => $_getSZ(0);
  @$pb.TagNumber(1)
  set logId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLogId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLogId() => $_clearField(1);

  /// first record in the log, consensus node not sign it
  @$pb.TagNumber(2)
  RawRecordWithId get record => $_getN(1);
  @$pb.TagNumber(2)
  set record(RawRecordWithId value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRecord() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecord() => $_clearField(2);
  @$pb.TagNumber(2)
  RawRecordWithId ensureRecord() => $_ensure(1);
}

class RecordAddRequest extends $pb.GeneratedMessage {
  factory RecordAddRequest({
    $core.String? logId,
    RawRecord? record,
  }) {
    final result = create();
    if (logId != null) result.logId = logId;
    if (record != null) result.record = record;
    return result;
  }

  RecordAddRequest._();

  factory RecordAddRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecordAddRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordAddRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'logId', protoName: 'logId')
    ..aOM<RawRecord>(2, _omitFieldNames ? '' : 'record',
        subBuilder: RawRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordAddRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordAddRequest copyWith(void Function(RecordAddRequest) updates) =>
      super.copyWith((message) => updates(message as RecordAddRequest))
          as RecordAddRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordAddRequest create() => RecordAddRequest._();
  @$core.override
  RecordAddRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecordAddRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordAddRequest>(create);
  static RecordAddRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get logId => $_getSZ(0);
  @$pb.TagNumber(1)
  set logId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLogId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLogId() => $_clearField(1);

  @$pb.TagNumber(2)
  RawRecord get record => $_getN(1);
  @$pb.TagNumber(2)
  set record(RawRecord value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRecord() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecord() => $_clearField(2);
  @$pb.TagNumber(2)
  RawRecord ensureRecord() => $_ensure(1);
}

class LogWatchRequest extends $pb.GeneratedMessage {
  factory LogWatchRequest({
    $core.Iterable<$core.String>? watchIds,
    $core.Iterable<$core.String>? unwatchIds,
  }) {
    final result = create();
    if (watchIds != null) result.watchIds.addAll(watchIds);
    if (unwatchIds != null) result.unwatchIds.addAll(unwatchIds);
    return result;
  }

  LogWatchRequest._();

  factory LogWatchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogWatchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogWatchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'watchIds', protoName: 'watchIds')
    ..pPS(2, _omitFieldNames ? '' : 'unwatchIds', protoName: 'unwatchIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogWatchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogWatchRequest copyWith(void Function(LogWatchRequest) updates) =>
      super.copyWith((message) => updates(message as LogWatchRequest))
          as LogWatchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogWatchRequest create() => LogWatchRequest._();
  @$core.override
  LogWatchRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogWatchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogWatchRequest>(create);
  static LogWatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get watchIds => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get unwatchIds => $_getList(1);
}

class LogWatchEvent extends $pb.GeneratedMessage {
  factory LogWatchEvent({
    $core.String? logId,
    $core.Iterable<RawRecordWithId>? records,
    Err? error,
  }) {
    final result = create();
    if (logId != null) result.logId = logId;
    if (records != null) result.records.addAll(records);
    if (error != null) result.error = error;
    return result;
  }

  LogWatchEvent._();

  factory LogWatchEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogWatchEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogWatchEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'logId', protoName: 'logId')
    ..pPM<RawRecordWithId>(2, _omitFieldNames ? '' : 'records',
        subBuilder: RawRecordWithId.create)
    ..aOM<Err>(3, _omitFieldNames ? '' : 'error', subBuilder: Err.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogWatchEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogWatchEvent copyWith(void Function(LogWatchEvent) updates) =>
      super.copyWith((message) => updates(message as LogWatchEvent))
          as LogWatchEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogWatchEvent create() => LogWatchEvent._();
  @$core.override
  LogWatchEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogWatchEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogWatchEvent>(create);
  static LogWatchEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get logId => $_getSZ(0);
  @$pb.TagNumber(1)
  set logId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLogId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLogId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<RawRecordWithId> get records => $_getList(1);

  @$pb.TagNumber(3)
  Err get error => $_getN(2);
  @$pb.TagNumber(3)
  set error(Err value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
  @$pb.TagNumber(3)
  Err ensureError() => $_ensure(2);
}

class LogDeleteRequest extends $pb.GeneratedMessage {
  factory LogDeleteRequest({
    $core.String? logId,
  }) {
    final result = create();
    if (logId != null) result.logId = logId;
    return result;
  }

  LogDeleteRequest._();

  factory LogDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'logId', protoName: 'logId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogDeleteRequest copyWith(void Function(LogDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as LogDeleteRequest))
          as LogDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogDeleteRequest create() => LogDeleteRequest._();
  @$core.override
  LogDeleteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogDeleteRequest>(create);
  static LogDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get logId => $_getSZ(0);
  @$pb.TagNumber(1)
  set logId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLogId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLogId() => $_clearField(1);
}

class Err extends $pb.GeneratedMessage {
  factory Err({
    ErrCodes? error,
  }) {
    final result = create();
    if (error != null) result.error = error;
    return result;
  }

  Err._();

  factory Err.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Err.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Err',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aE<ErrCodes>(1, _omitFieldNames ? '' : 'error',
        enumValues: ErrCodes.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Err clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Err copyWith(void Function(Err) updates) =>
      super.copyWith((message) => updates(message as Err)) as Err;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Err create() => Err._();
  @$core.override
  Err createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Err getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Err>(create);
  static Err? _defaultInstance;

  @$pb.TagNumber(1)
  ErrCodes get error => $_getN(0);
  @$pb.TagNumber(1)
  set error(ErrCodes value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
}

enum LogSyncContentValue_Value {
  headUpdate,
  fullSyncRequest,
  fullSyncResponse,
  notSet
}

/// LogSyncContentValue provides different types for log sync
class LogSyncContentValue extends $pb.GeneratedMessage {
  factory LogSyncContentValue({
    LogHeadUpdate? headUpdate,
    LogFullSyncRequest? fullSyncRequest,
    LogFullSyncResponse? fullSyncResponse,
  }) {
    final result = create();
    if (headUpdate != null) result.headUpdate = headUpdate;
    if (fullSyncRequest != null) result.fullSyncRequest = fullSyncRequest;
    if (fullSyncResponse != null) result.fullSyncResponse = fullSyncResponse;
    return result;
  }

  LogSyncContentValue._();

  factory LogSyncContentValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogSyncContentValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, LogSyncContentValue_Value>
      _LogSyncContentValue_ValueByTag = {
    1: LogSyncContentValue_Value.headUpdate,
    2: LogSyncContentValue_Value.fullSyncRequest,
    3: LogSyncContentValue_Value.fullSyncResponse,
    0: LogSyncContentValue_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogSyncContentValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<LogHeadUpdate>(1, _omitFieldNames ? '' : 'headUpdate',
        protoName: 'headUpdate', subBuilder: LogHeadUpdate.create)
    ..aOM<LogFullSyncRequest>(2, _omitFieldNames ? '' : 'fullSyncRequest',
        protoName: 'fullSyncRequest', subBuilder: LogFullSyncRequest.create)
    ..aOM<LogFullSyncResponse>(3, _omitFieldNames ? '' : 'fullSyncResponse',
        protoName: 'fullSyncResponse', subBuilder: LogFullSyncResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogSyncContentValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogSyncContentValue copyWith(void Function(LogSyncContentValue) updates) =>
      super.copyWith((message) => updates(message as LogSyncContentValue))
          as LogSyncContentValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogSyncContentValue create() => LogSyncContentValue._();
  @$core.override
  LogSyncContentValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogSyncContentValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogSyncContentValue>(create);
  static LogSyncContentValue? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  LogSyncContentValue_Value whichValue() =>
      _LogSyncContentValue_ValueByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  LogHeadUpdate get headUpdate => $_getN(0);
  @$pb.TagNumber(1)
  set headUpdate(LogHeadUpdate value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHeadUpdate() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeadUpdate() => $_clearField(1);
  @$pb.TagNumber(1)
  LogHeadUpdate ensureHeadUpdate() => $_ensure(0);

  @$pb.TagNumber(2)
  LogFullSyncRequest get fullSyncRequest => $_getN(1);
  @$pb.TagNumber(2)
  set fullSyncRequest(LogFullSyncRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFullSyncRequest() => $_has(1);
  @$pb.TagNumber(2)
  void clearFullSyncRequest() => $_clearField(2);
  @$pb.TagNumber(2)
  LogFullSyncRequest ensureFullSyncRequest() => $_ensure(1);

  @$pb.TagNumber(3)
  LogFullSyncResponse get fullSyncResponse => $_getN(2);
  @$pb.TagNumber(3)
  set fullSyncResponse(LogFullSyncResponse value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFullSyncResponse() => $_has(2);
  @$pb.TagNumber(3)
  void clearFullSyncResponse() => $_clearField(3);
  @$pb.TagNumber(3)
  LogFullSyncResponse ensureFullSyncResponse() => $_ensure(2);
}

/// LogSyncMessage is a message sent when we are syncing logs
class LogSyncMessage extends $pb.GeneratedMessage {
  factory LogSyncMessage({
    $core.String? id,
    $core.List<$core.int>? payload,
    LogSyncContentValue? content,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (payload != null) result.payload = payload;
    if (content != null) result.content = content;
    return result;
  }

  LogSyncMessage._();

  factory LogSyncMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogSyncMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogSyncMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aOM<LogSyncContentValue>(3, _omitFieldNames ? '' : 'content',
        subBuilder: LogSyncContentValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogSyncMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogSyncMessage copyWith(void Function(LogSyncMessage) updates) =>
      super.copyWith((message) => updates(message as LogSyncMessage))
          as LogSyncMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogSyncMessage create() => LogSyncMessage._();
  @$core.override
  LogSyncMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogSyncMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogSyncMessage>(create);
  static LogSyncMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);

  @$pb.TagNumber(3)
  LogSyncContentValue get content => $_getN(2);
  @$pb.TagNumber(3)
  set content(LogSyncContentValue value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => $_clearField(3);
  @$pb.TagNumber(3)
  LogSyncContentValue ensureContent() => $_ensure(2);
}

/// LogHeadUpdate is a message sent on consensus log head update
class LogHeadUpdate extends $pb.GeneratedMessage {
  factory LogHeadUpdate({
    $core.String? head,
    $core.Iterable<RawRecordWithId>? records,
  }) {
    final result = create();
    if (head != null) result.head = head;
    if (records != null) result.records.addAll(records);
    return result;
  }

  LogHeadUpdate._();

  factory LogHeadUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogHeadUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogHeadUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'head')
    ..pPM<RawRecordWithId>(2, _omitFieldNames ? '' : 'records',
        subBuilder: RawRecordWithId.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogHeadUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogHeadUpdate copyWith(void Function(LogHeadUpdate) updates) =>
      super.copyWith((message) => updates(message as LogHeadUpdate))
          as LogHeadUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogHeadUpdate create() => LogHeadUpdate._();
  @$core.override
  LogHeadUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogHeadUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogHeadUpdate>(create);
  static LogHeadUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get head => $_getSZ(0);
  @$pb.TagNumber(1)
  set head($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHead() => $_has(0);
  @$pb.TagNumber(1)
  void clearHead() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<RawRecordWithId> get records => $_getList(1);
}

/// LogFullSyncRequest is a message sent when consensus log needs full sync
class LogFullSyncRequest extends $pb.GeneratedMessage {
  factory LogFullSyncRequest({
    $core.String? head,
    $core.Iterable<RawRecordWithId>? records,
  }) {
    final result = create();
    if (head != null) result.head = head;
    if (records != null) result.records.addAll(records);
    return result;
  }

  LogFullSyncRequest._();

  factory LogFullSyncRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogFullSyncRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogFullSyncRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'head')
    ..pPM<RawRecordWithId>(2, _omitFieldNames ? '' : 'records',
        subBuilder: RawRecordWithId.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogFullSyncRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogFullSyncRequest copyWith(void Function(LogFullSyncRequest) updates) =>
      super.copyWith((message) => updates(message as LogFullSyncRequest))
          as LogFullSyncRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogFullSyncRequest create() => LogFullSyncRequest._();
  @$core.override
  LogFullSyncRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogFullSyncRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogFullSyncRequest>(create);
  static LogFullSyncRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get head => $_getSZ(0);
  @$pb.TagNumber(1)
  set head($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHead() => $_has(0);
  @$pb.TagNumber(1)
  void clearHead() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<RawRecordWithId> get records => $_getList(1);
}

/// LogFullSyncResponse is a message sent as a response for a specific full sync
class LogFullSyncResponse extends $pb.GeneratedMessage {
  factory LogFullSyncResponse({
    $core.String? head,
    $core.Iterable<RawRecordWithId>? records,
  }) {
    final result = create();
    if (head != null) result.head = head;
    if (records != null) result.records.addAll(records);
    return result;
  }

  LogFullSyncResponse._();

  factory LogFullSyncResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogFullSyncResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogFullSyncResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'consensusProto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'head')
    ..pPM<RawRecordWithId>(2, _omitFieldNames ? '' : 'records',
        subBuilder: RawRecordWithId.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogFullSyncResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogFullSyncResponse copyWith(void Function(LogFullSyncResponse) updates) =>
      super.copyWith((message) => updates(message as LogFullSyncResponse))
          as LogFullSyncResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogFullSyncResponse create() => LogFullSyncResponse._();
  @$core.override
  LogFullSyncResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogFullSyncResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogFullSyncResponse>(create);
  static LogFullSyncResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get head => $_getSZ(0);
  @$pb.TagNumber(1)
  set head($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHead() => $_has(0);
  @$pb.TagNumber(1)
  void clearHead() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<RawRecordWithId> get records => $_getList(1);
}

class ConsensusApi {
  final $pb.RpcClient _client;

  ConsensusApi(this._client);

  /// LogAdd adds new log to consensus
  $async.Future<Ok> logAdd($pb.ClientContext? ctx, LogAddRequest request) =>
      _client.invoke<Ok>(ctx, 'Consensus', 'LogAdd', request, Ok());

  /// RecordAdd adds new record to log
  $async.Future<RawRecordWithId> recordAdd(
          $pb.ClientContext? ctx, RecordAddRequest request) =>
      _client.invoke<RawRecordWithId>(
          ctx, 'Consensus', 'RecordAdd', request, RawRecordWithId());

  /// LogWatch fetches log and subscribes for a changes
  $async.Future<LogWatchEvent> logWatch(
          $pb.ClientContext? ctx, LogWatchRequest request) =>
      _client.invoke<LogWatchEvent>(
          ctx, 'Consensus', 'LogWatch', request, LogWatchEvent());

  /// LogDelete deletes the log from the consensus
  $async.Future<Ok> logDelete(
          $pb.ClientContext? ctx, LogDeleteRequest request) =>
      _client.invoke<Ok>(ctx, 'Consensus', 'LogDelete', request, Ok());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
