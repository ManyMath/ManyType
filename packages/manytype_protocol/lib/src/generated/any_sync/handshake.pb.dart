// This is a generated file - do not edit.
//
// Generated from any_sync/handshake.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'handshake.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'handshake.pbenum.dart';

class Credentials extends $pb.GeneratedMessage {
  factory Credentials({
    CredentialsType? type,
    $core.List<$core.int>? payload,
    $core.int? version,
    $core.String? clientVersion,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (payload != null) result.payload = payload;
    if (version != null) result.version = version;
    if (clientVersion != null) result.clientVersion = clientVersion;
    return result;
  }

  Credentials._();

  factory Credentials.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Credentials.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Credentials',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anyHandshake'),
      createEmptyInstance: create)
    ..aE<CredentialsType>(1, _omitFieldNames ? '' : 'type',
        enumValues: CredentialsType.values)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aI(3, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'clientVersion', protoName: 'clientVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Credentials clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Credentials copyWith(void Function(Credentials) updates) =>
      super.copyWith((message) => updates(message as Credentials))
          as Credentials;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Credentials create() => Credentials._();
  @$core.override
  Credentials createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Credentials getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Credentials>(create);
  static Credentials? _defaultInstance;

  @$pb.TagNumber(1)
  CredentialsType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(CredentialsType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get version => $_getIZ(2);
  @$pb.TagNumber(3)
  set version($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientVersion() => $_clearField(4);
}

class PayloadSignedPeerIds extends $pb.GeneratedMessage {
  factory PayloadSignedPeerIds({
    $core.List<$core.int>? identity,
    $core.List<$core.int>? sign,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (sign != null) result.sign = sign;
    return result;
  }

  PayloadSignedPeerIds._();

  factory PayloadSignedPeerIds.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PayloadSignedPeerIds.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PayloadSignedPeerIds',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anyHandshake'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'sign', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PayloadSignedPeerIds clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PayloadSignedPeerIds copyWith(void Function(PayloadSignedPeerIds) updates) =>
      super.copyWith((message) => updates(message as PayloadSignedPeerIds))
          as PayloadSignedPeerIds;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PayloadSignedPeerIds create() => PayloadSignedPeerIds._();
  @$core.override
  PayloadSignedPeerIds createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PayloadSignedPeerIds getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PayloadSignedPeerIds>(create);
  static PayloadSignedPeerIds? _defaultInstance;

  /// account identity
  @$pb.TagNumber(1)
  $core.List<$core.int> get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  /// sign of (localPeerId + remotePeerId)
  @$pb.TagNumber(2)
  $core.List<$core.int> get sign => $_getN(1);
  @$pb.TagNumber(2)
  set sign($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSign() => $_has(1);
  @$pb.TagNumber(2)
  void clearSign() => $_clearField(2);
}

class Ack extends $pb.GeneratedMessage {
  factory Ack({
    Error? error,
  }) {
    final result = create();
    if (error != null) result.error = error;
    return result;
  }

  Ack._();

  factory Ack.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Ack.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ack',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anyHandshake'),
      createEmptyInstance: create)
    ..aE<Error>(1, _omitFieldNames ? '' : 'error', enumValues: Error.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ack clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ack copyWith(void Function(Ack) updates) =>
      super.copyWith((message) => updates(message as Ack)) as Ack;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Ack create() => Ack._();
  @$core.override
  Ack createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Ack getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Ack>(create);
  static Ack? _defaultInstance;

  @$pb.TagNumber(1)
  Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error(Error value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
}

class Proto extends $pb.GeneratedMessage {
  factory Proto({
    ProtoType? proto,
    $core.Iterable<Encoding>? encodings,
  }) {
    final result = create();
    if (proto != null) result.proto = proto;
    if (encodings != null) result.encodings.addAll(encodings);
    return result;
  }

  Proto._();

  factory Proto.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Proto.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Proto',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anyHandshake'),
      createEmptyInstance: create)
    ..aE<ProtoType>(1, _omitFieldNames ? '' : 'proto',
        enumValues: ProtoType.values)
    ..pc<Encoding>(2, _omitFieldNames ? '' : 'encodings', $pb.PbFieldType.KE,
        valueOf: Encoding.valueOf,
        enumValues: Encoding.values,
        defaultEnumValue: Encoding.None)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Proto clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Proto copyWith(void Function(Proto) updates) =>
      super.copyWith((message) => updates(message as Proto)) as Proto;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Proto create() => Proto._();
  @$core.override
  Proto createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Proto getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Proto>(create);
  static Proto? _defaultInstance;

  @$pb.TagNumber(1)
  ProtoType get proto => $_getN(0);
  @$pb.TagNumber(1)
  set proto(ProtoType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProto() => $_has(0);
  @$pb.TagNumber(1)
  void clearProto() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Encoding> get encodings => $_getList(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
