// This is a generated file - do not edit.
//
// Generated from any_sync/coordinator.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'coordinator.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'coordinator.pbenum.dart';

class SpaceSignRequest extends $pb.GeneratedMessage {
  factory SpaceSignRequest({
    $core.String? spaceId,
    $core.List<$core.int>? header,
    $core.List<$core.int>? oldIdentity,
    $core.List<$core.int>? newIdentitySignature,
    $core.bool? forceRequest,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (header != null) result.header = header;
    if (oldIdentity != null) result.oldIdentity = oldIdentity;
    if (newIdentitySignature != null)
      result.newIdentitySignature = newIdentitySignature;
    if (forceRequest != null) result.forceRequest = forceRequest;
    return result;
  }

  SpaceSignRequest._();

  factory SpaceSignRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceSignRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceSignRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'header', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'oldIdentity', $pb.PbFieldType.OY,
        protoName: 'oldIdentity')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'newIdentitySignature', $pb.PbFieldType.OY,
        protoName: 'newIdentitySignature')
    ..aOB(5, _omitFieldNames ? '' : 'forceRequest', protoName: 'forceRequest')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSignRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSignRequest copyWith(void Function(SpaceSignRequest) updates) =>
      super.copyWith((message) => updates(message as SpaceSignRequest))
          as SpaceSignRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceSignRequest create() => SpaceSignRequest._();
  @$core.override
  SpaceSignRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceSignRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceSignRequest>(create);
  static SpaceSignRequest? _defaultInstance;

  /// SpaceId is the id of the signed space
  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  /// Header is the header of the signed space
  @$pb.TagNumber(2)
  $core.List<$core.int> get header => $_getN(1);
  @$pb.TagNumber(2)
  set header($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeader() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeader() => $_clearField(2);

  /// OldIdentity is the old identity of the space owner
  @$pb.TagNumber(3)
  $core.List<$core.int> get oldIdentity => $_getN(2);
  @$pb.TagNumber(3)
  set oldIdentity($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOldIdentity() => $_has(2);
  @$pb.TagNumber(3)
  void clearOldIdentity() => $_clearField(3);

  /// NewIdentitySignature is the new identity signed by the old one
  @$pb.TagNumber(4)
  $core.List<$core.int> get newIdentitySignature => $_getN(3);
  @$pb.TagNumber(4)
  set newIdentitySignature($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNewIdentitySignature() => $_has(3);
  @$pb.TagNumber(4)
  void clearNewIdentitySignature() => $_clearField(4);

  /// ForceRequest if true, forces the creating space receipt even if the space is deleted before
  @$pb.TagNumber(5)
  $core.bool get forceRequest => $_getBF(4);
  @$pb.TagNumber(5)
  set forceRequest($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasForceRequest() => $_has(4);
  @$pb.TagNumber(5)
  void clearForceRequest() => $_clearField(5);
}

class SpaceLimits extends $pb.GeneratedMessage {
  factory SpaceLimits({
    $core.int? readMembers,
    $core.int? writeMembers,
  }) {
    final result = create();
    if (readMembers != null) result.readMembers = readMembers;
    if (writeMembers != null) result.writeMembers = writeMembers;
    return result;
  }

  SpaceLimits._();

  factory SpaceLimits.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceLimits.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceLimits',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'readMembers',
        protoName: 'readMembers', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'writeMembers',
        protoName: 'writeMembers', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceLimits clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceLimits copyWith(void Function(SpaceLimits) updates) =>
      super.copyWith((message) => updates(message as SpaceLimits))
          as SpaceLimits;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceLimits create() => SpaceLimits._();
  @$core.override
  SpaceLimits createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceLimits getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceLimits>(create);
  static SpaceLimits? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get readMembers => $_getIZ(0);
  @$pb.TagNumber(1)
  set readMembers($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReadMembers() => $_has(0);
  @$pb.TagNumber(1)
  void clearReadMembers() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get writeMembers => $_getIZ(1);
  @$pb.TagNumber(2)
  set writeMembers($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWriteMembers() => $_has(1);
  @$pb.TagNumber(2)
  void clearWriteMembers() => $_clearField(2);
}

class SpaceStatusPayload extends $pb.GeneratedMessage {
  factory SpaceStatusPayload({
    SpaceStatus? status,
    $fixnum.Int64? deletionTimestamp,
    SpacePermissions? permissions,
    SpaceLimits? limits,
    $core.bool? isShared,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (deletionTimestamp != null) result.deletionTimestamp = deletionTimestamp;
    if (permissions != null) result.permissions = permissions;
    if (limits != null) result.limits = limits;
    if (isShared != null) result.isShared = isShared;
    return result;
  }

  SpaceStatusPayload._();

  factory SpaceStatusPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceStatusPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceStatusPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aE<SpaceStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: SpaceStatus.values)
    ..aInt64(2, _omitFieldNames ? '' : 'deletionTimestamp',
        protoName: 'deletionTimestamp')
    ..aE<SpacePermissions>(3, _omitFieldNames ? '' : 'permissions',
        enumValues: SpacePermissions.values)
    ..aOM<SpaceLimits>(4, _omitFieldNames ? '' : 'limits',
        subBuilder: SpaceLimits.create)
    ..aOB(5, _omitFieldNames ? '' : 'isShared', protoName: 'isShared')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusPayload copyWith(void Function(SpaceStatusPayload) updates) =>
      super.copyWith((message) => updates(message as SpaceStatusPayload))
          as SpaceStatusPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceStatusPayload create() => SpaceStatusPayload._();
  @$core.override
  SpaceStatusPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceStatusPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceStatusPayload>(create);
  static SpaceStatusPayload? _defaultInstance;

  @$pb.TagNumber(1)
  SpaceStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(SpaceStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deletionTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set deletionTimestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeletionTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeletionTimestamp() => $_clearField(2);

  @$pb.TagNumber(3)
  SpacePermissions get permissions => $_getN(2);
  @$pb.TagNumber(3)
  set permissions(SpacePermissions value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPermissions() => $_has(2);
  @$pb.TagNumber(3)
  void clearPermissions() => $_clearField(3);

  @$pb.TagNumber(4)
  SpaceLimits get limits => $_getN(3);
  @$pb.TagNumber(4)
  set limits(SpaceLimits value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLimits() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimits() => $_clearField(4);
  @$pb.TagNumber(4)
  SpaceLimits ensureLimits() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.bool get isShared => $_getBF(4);
  @$pb.TagNumber(5)
  set isShared($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsShared() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsShared() => $_clearField(5);
}

class SpaceSignResponse extends $pb.GeneratedMessage {
  factory SpaceSignResponse({
    SpaceReceiptWithSignature? receipt,
  }) {
    final result = create();
    if (receipt != null) result.receipt = receipt;
    return result;
  }

  SpaceSignResponse._();

  factory SpaceSignResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceSignResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceSignResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOM<SpaceReceiptWithSignature>(1, _omitFieldNames ? '' : 'receipt',
        subBuilder: SpaceReceiptWithSignature.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSignResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceSignResponse copyWith(void Function(SpaceSignResponse) updates) =>
      super.copyWith((message) => updates(message as SpaceSignResponse))
          as SpaceSignResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceSignResponse create() => SpaceSignResponse._();
  @$core.override
  SpaceSignResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceSignResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceSignResponse>(create);
  static SpaceSignResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SpaceReceiptWithSignature get receipt => $_getN(0);
  @$pb.TagNumber(1)
  set receipt(SpaceReceiptWithSignature value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReceipt() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceipt() => $_clearField(1);
  @$pb.TagNumber(1)
  SpaceReceiptWithSignature ensureReceipt() => $_ensure(0);
}

/// SpaceReceiptWithSignature contains protobuf encoded receipt and its signature
class SpaceReceiptWithSignature extends $pb.GeneratedMessage {
  factory SpaceReceiptWithSignature({
    $core.List<$core.int>? spaceReceiptPayload,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (spaceReceiptPayload != null)
      result.spaceReceiptPayload = spaceReceiptPayload;
    if (signature != null) result.signature = signature;
    return result;
  }

  SpaceReceiptWithSignature._();

  factory SpaceReceiptWithSignature.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceReceiptWithSignature.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceReceiptWithSignature',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'spaceReceiptPayload', $pb.PbFieldType.OY,
        protoName: 'spaceReceiptPayload')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceReceiptWithSignature clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceReceiptWithSignature copyWith(
          void Function(SpaceReceiptWithSignature) updates) =>
      super.copyWith((message) => updates(message as SpaceReceiptWithSignature))
          as SpaceReceiptWithSignature;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceReceiptWithSignature create() => SpaceReceiptWithSignature._();
  @$core.override
  SpaceReceiptWithSignature createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceReceiptWithSignature getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceReceiptWithSignature>(create);
  static SpaceReceiptWithSignature? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get spaceReceiptPayload => $_getN(0);
  @$pb.TagNumber(1)
  set spaceReceiptPayload($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceReceiptPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceReceiptPayload() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);
}

/// SpaceReceipt contains permission to SpacePush operation
class SpaceReceipt extends $pb.GeneratedMessage {
  factory SpaceReceipt({
    $core.String? spaceId,
    $core.String? peerId,
    $core.List<$core.int>? accountIdentity,
    $core.String? networkId,
    $fixnum.Int64? validUntil,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (peerId != null) result.peerId = peerId;
    if (accountIdentity != null) result.accountIdentity = accountIdentity;
    if (networkId != null) result.networkId = networkId;
    if (validUntil != null) result.validUntil = validUntil;
    return result;
  }

  SpaceReceipt._();

  factory SpaceReceipt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceReceipt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceReceipt',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'peerId', protoName: 'peerId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'accountIdentity', $pb.PbFieldType.OY,
        protoName: 'accountIdentity')
    ..aOS(4, _omitFieldNames ? '' : 'networkId', protoName: 'networkId')
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'validUntil', $pb.PbFieldType.OU6,
        protoName: 'validUntil', defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceReceipt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceReceipt copyWith(void Function(SpaceReceipt) updates) =>
      super.copyWith((message) => updates(message as SpaceReceipt))
          as SpaceReceipt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceReceipt create() => SpaceReceipt._();
  @$core.override
  SpaceReceipt createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceReceipt getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceReceipt>(create);
  static SpaceReceipt? _defaultInstance;

  /// SpaceId is the identifier of space
  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  /// PeerId of receipt requester
  @$pb.TagNumber(2)
  $core.String get peerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set peerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeerId() => $_clearField(2);

  /// AccountIdentity is an identity of a space owner
  @$pb.TagNumber(3)
  $core.List<$core.int> get accountIdentity => $_getN(2);
  @$pb.TagNumber(3)
  set accountIdentity($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccountIdentity() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountIdentity() => $_clearField(3);

  /// NetworkId is the id of a network where the receipt is issued
  @$pb.TagNumber(4)
  $core.String get networkId => $_getSZ(3);
  @$pb.TagNumber(4)
  set networkId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNetworkId() => $_has(3);
  @$pb.TagNumber(4)
  void clearNetworkId() => $_clearField(4);

  /// ValidUntil is a unix-timestamp with a deadline time of receipt validity
  @$pb.TagNumber(5)
  $fixnum.Int64 get validUntil => $_getI64(4);
  @$pb.TagNumber(5)
  set validUntil($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValidUntil() => $_has(4);
  @$pb.TagNumber(5)
  void clearValidUntil() => $_clearField(5);
}

/// SpaceStatusCheckRequest contains the spaceId of requested space
class SpaceStatusCheckRequest extends $pb.GeneratedMessage {
  factory SpaceStatusCheckRequest({
    $core.String? spaceId,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    return result;
  }

  SpaceStatusCheckRequest._();

  factory SpaceStatusCheckRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceStatusCheckRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceStatusCheckRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusCheckRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusCheckRequest copyWith(
          void Function(SpaceStatusCheckRequest) updates) =>
      super.copyWith((message) => updates(message as SpaceStatusCheckRequest))
          as SpaceStatusCheckRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceStatusCheckRequest create() => SpaceStatusCheckRequest._();
  @$core.override
  SpaceStatusCheckRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceStatusCheckRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceStatusCheckRequest>(create);
  static SpaceStatusCheckRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);
}

/// SpaceStatusCheckResponse contains the current status of space
class SpaceStatusCheckResponse extends $pb.GeneratedMessage {
  factory SpaceStatusCheckResponse({
    SpaceStatusPayload? payload,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    return result;
  }

  SpaceStatusCheckResponse._();

  factory SpaceStatusCheckResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceStatusCheckResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceStatusCheckResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOM<SpaceStatusPayload>(1, _omitFieldNames ? '' : 'payload',
        subBuilder: SpaceStatusPayload.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusCheckResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusCheckResponse copyWith(
          void Function(SpaceStatusCheckResponse) updates) =>
      super.copyWith((message) => updates(message as SpaceStatusCheckResponse))
          as SpaceStatusCheckResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceStatusCheckResponse create() => SpaceStatusCheckResponse._();
  @$core.override
  SpaceStatusCheckResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceStatusCheckResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceStatusCheckResponse>(create);
  static SpaceStatusCheckResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SpaceStatusPayload get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload(SpaceStatusPayload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);
  @$pb.TagNumber(1)
  SpaceStatusPayload ensurePayload() => $_ensure(0);
}

/// SpaceStatusCheckManyRequest contains the spaceIds of requested spaces
class SpaceStatusCheckManyRequest extends $pb.GeneratedMessage {
  factory SpaceStatusCheckManyRequest({
    $core.Iterable<$core.String>? spaceIds,
  }) {
    final result = create();
    if (spaceIds != null) result.spaceIds.addAll(spaceIds);
    return result;
  }

  SpaceStatusCheckManyRequest._();

  factory SpaceStatusCheckManyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceStatusCheckManyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceStatusCheckManyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'spaceIds', protoName: 'spaceIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusCheckManyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusCheckManyRequest copyWith(
          void Function(SpaceStatusCheckManyRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SpaceStatusCheckManyRequest))
          as SpaceStatusCheckManyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceStatusCheckManyRequest create() =>
      SpaceStatusCheckManyRequest._();
  @$core.override
  SpaceStatusCheckManyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceStatusCheckManyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceStatusCheckManyRequest>(create);
  static SpaceStatusCheckManyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get spaceIds => $_getList(0);
}

/// SpaceStatusCheckManyResponse contains the current statuses of spaces
class SpaceStatusCheckManyResponse extends $pb.GeneratedMessage {
  factory SpaceStatusCheckManyResponse({
    $core.Iterable<SpaceStatusPayload>? payloads,
    AccountLimits? accountLimits,
  }) {
    final result = create();
    if (payloads != null) result.payloads.addAll(payloads);
    if (accountLimits != null) result.accountLimits = accountLimits;
    return result;
  }

  SpaceStatusCheckManyResponse._();

  factory SpaceStatusCheckManyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceStatusCheckManyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceStatusCheckManyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..pPM<SpaceStatusPayload>(1, _omitFieldNames ? '' : 'payloads',
        subBuilder: SpaceStatusPayload.create)
    ..aOM<AccountLimits>(2, _omitFieldNames ? '' : 'accountLimits',
        protoName: 'accountLimits', subBuilder: AccountLimits.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusCheckManyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusCheckManyResponse copyWith(
          void Function(SpaceStatusCheckManyResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SpaceStatusCheckManyResponse))
          as SpaceStatusCheckManyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceStatusCheckManyResponse create() =>
      SpaceStatusCheckManyResponse._();
  @$core.override
  SpaceStatusCheckManyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceStatusCheckManyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceStatusCheckManyResponse>(create);
  static SpaceStatusCheckManyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SpaceStatusPayload> get payloads => $_getList(0);

  @$pb.TagNumber(2)
  AccountLimits get accountLimits => $_getN(1);
  @$pb.TagNumber(2)
  set accountLimits(AccountLimits value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAccountLimits() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountLimits() => $_clearField(2);
  @$pb.TagNumber(2)
  AccountLimits ensureAccountLimits() => $_ensure(1);
}

/// AccountLimits describes account level limit
class AccountLimits extends $pb.GeneratedMessage {
  factory AccountLimits({
    $core.int? sharedSpacesLimit,
  }) {
    final result = create();
    if (sharedSpacesLimit != null) result.sharedSpacesLimit = sharedSpacesLimit;
    return result;
  }

  AccountLimits._();

  factory AccountLimits.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountLimits.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountLimits',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'sharedSpacesLimit',
        protoName: 'sharedSpacesLimit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountLimits clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountLimits copyWith(void Function(AccountLimits) updates) =>
      super.copyWith((message) => updates(message as AccountLimits))
          as AccountLimits;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountLimits create() => AccountLimits._();
  @$core.override
  AccountLimits createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountLimits getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountLimits>(create);
  static AccountLimits? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sharedSpacesLimit => $_getIZ(0);
  @$pb.TagNumber(1)
  set sharedSpacesLimit($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSharedSpacesLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearSharedSpacesLimit() => $_clearField(1);
}

/// SpaceStatusChangeRequest contains the deletionChange if we want to delete space, or it is empty otherwise
class SpaceStatusChangeRequest extends $pb.GeneratedMessage {
  factory SpaceStatusChangeRequest({
    $core.String? spaceId,
    $core.String? deletionPayloadId,
    $core.List<$core.int>? deletionPayload,
    DeletionPayloadType? deletionPayloadType,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (deletionPayloadId != null) result.deletionPayloadId = deletionPayloadId;
    if (deletionPayload != null) result.deletionPayload = deletionPayload;
    if (deletionPayloadType != null)
      result.deletionPayloadType = deletionPayloadType;
    return result;
  }

  SpaceStatusChangeRequest._();

  factory SpaceStatusChangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceStatusChangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceStatusChangeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'deletionPayloadId',
        protoName: 'deletionPayloadId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'deletionPayload', $pb.PbFieldType.OY,
        protoName: 'deletionPayload')
    ..aE<DeletionPayloadType>(4, _omitFieldNames ? '' : 'deletionPayloadType',
        protoName: 'deletionPayloadType',
        enumValues: DeletionPayloadType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusChangeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusChangeRequest copyWith(
          void Function(SpaceStatusChangeRequest) updates) =>
      super.copyWith((message) => updates(message as SpaceStatusChangeRequest))
          as SpaceStatusChangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceStatusChangeRequest create() => SpaceStatusChangeRequest._();
  @$core.override
  SpaceStatusChangeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceStatusChangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceStatusChangeRequest>(create);
  static SpaceStatusChangeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deletionPayloadId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deletionPayloadId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeletionPayloadId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeletionPayloadId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get deletionPayload => $_getN(2);
  @$pb.TagNumber(3)
  set deletionPayload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeletionPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeletionPayload() => $_clearField(3);

  @$pb.TagNumber(4)
  DeletionPayloadType get deletionPayloadType => $_getN(3);
  @$pb.TagNumber(4)
  set deletionPayloadType(DeletionPayloadType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDeletionPayloadType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeletionPayloadType() => $_clearField(4);
}

/// SpaceStatusChangeResponse contains changed status of space
class SpaceStatusChangeResponse extends $pb.GeneratedMessage {
  factory SpaceStatusChangeResponse({
    SpaceStatusPayload? payload,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    return result;
  }

  SpaceStatusChangeResponse._();

  factory SpaceStatusChangeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceStatusChangeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceStatusChangeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOM<SpaceStatusPayload>(1, _omitFieldNames ? '' : 'payload',
        subBuilder: SpaceStatusPayload.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusChangeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceStatusChangeResponse copyWith(
          void Function(SpaceStatusChangeResponse) updates) =>
      super.copyWith((message) => updates(message as SpaceStatusChangeResponse))
          as SpaceStatusChangeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceStatusChangeResponse create() => SpaceStatusChangeResponse._();
  @$core.override
  SpaceStatusChangeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceStatusChangeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceStatusChangeResponse>(create);
  static SpaceStatusChangeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SpaceStatusPayload get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload(SpaceStatusPayload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);
  @$pb.TagNumber(1)
  SpaceStatusPayload ensurePayload() => $_ensure(0);
}

class SpaceMakeShareableRequest extends $pb.GeneratedMessage {
  factory SpaceMakeShareableRequest({
    $core.String? spaceId,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    return result;
  }

  SpaceMakeShareableRequest._();

  factory SpaceMakeShareableRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceMakeShareableRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceMakeShareableRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceMakeShareableRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceMakeShareableRequest copyWith(
          void Function(SpaceMakeShareableRequest) updates) =>
      super.copyWith((message) => updates(message as SpaceMakeShareableRequest))
          as SpaceMakeShareableRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceMakeShareableRequest create() => SpaceMakeShareableRequest._();
  @$core.override
  SpaceMakeShareableRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceMakeShareableRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceMakeShareableRequest>(create);
  static SpaceMakeShareableRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);
}

class SpaceMakeShareableResponse extends $pb.GeneratedMessage {
  factory SpaceMakeShareableResponse() => create();

  SpaceMakeShareableResponse._();

  factory SpaceMakeShareableResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceMakeShareableResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceMakeShareableResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceMakeShareableResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceMakeShareableResponse copyWith(
          void Function(SpaceMakeShareableResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SpaceMakeShareableResponse))
          as SpaceMakeShareableResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceMakeShareableResponse create() => SpaceMakeShareableResponse._();
  @$core.override
  SpaceMakeShareableResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceMakeShareableResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceMakeShareableResponse>(create);
  static SpaceMakeShareableResponse? _defaultInstance;
}

class SpaceMakeUnshareableRequest extends $pb.GeneratedMessage {
  factory SpaceMakeUnshareableRequest({
    $core.String? spaceId,
    $core.String? aclHead,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (aclHead != null) result.aclHead = aclHead;
    return result;
  }

  SpaceMakeUnshareableRequest._();

  factory SpaceMakeUnshareableRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceMakeUnshareableRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceMakeUnshareableRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'aclHead', protoName: 'aclHead')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceMakeUnshareableRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceMakeUnshareableRequest copyWith(
          void Function(SpaceMakeUnshareableRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SpaceMakeUnshareableRequest))
          as SpaceMakeUnshareableRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceMakeUnshareableRequest create() =>
      SpaceMakeUnshareableRequest._();
  @$core.override
  SpaceMakeUnshareableRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceMakeUnshareableRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceMakeUnshareableRequest>(create);
  static SpaceMakeUnshareableRequest? _defaultInstance;

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

class SpaceMakeUnshareableResponse extends $pb.GeneratedMessage {
  factory SpaceMakeUnshareableResponse() => create();

  SpaceMakeUnshareableResponse._();

  factory SpaceMakeUnshareableResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceMakeUnshareableResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceMakeUnshareableResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceMakeUnshareableResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceMakeUnshareableResponse copyWith(
          void Function(SpaceMakeUnshareableResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SpaceMakeUnshareableResponse))
          as SpaceMakeUnshareableResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceMakeUnshareableResponse create() =>
      SpaceMakeUnshareableResponse._();
  @$core.override
  SpaceMakeUnshareableResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceMakeUnshareableResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceMakeUnshareableResponse>(create);
  static SpaceMakeUnshareableResponse? _defaultInstance;
}

/// NetworkConfigurationRequest contains currenId of the client configuration, it can be empty
class NetworkConfigurationRequest extends $pb.GeneratedMessage {
  factory NetworkConfigurationRequest({
    $core.String? currentId,
  }) {
    final result = create();
    if (currentId != null) result.currentId = currentId;
    return result;
  }

  NetworkConfigurationRequest._();

  factory NetworkConfigurationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NetworkConfigurationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkConfigurationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'currentId', protoName: 'currentId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkConfigurationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkConfigurationRequest copyWith(
          void Function(NetworkConfigurationRequest) updates) =>
      super.copyWith(
              (message) => updates(message as NetworkConfigurationRequest))
          as NetworkConfigurationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkConfigurationRequest create() =>
      NetworkConfigurationRequest._();
  @$core.override
  NetworkConfigurationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NetworkConfigurationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NetworkConfigurationRequest>(create);
  static NetworkConfigurationRequest? _defaultInstance;

  /// currenId of the client configuration
  /// if the currentId is equal to the latest configuration id then the response will not contain a nodes list
  @$pb.TagNumber(1)
  $core.String get currentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set currentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCurrentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentId() => $_clearField(1);
}

/// NetworkConfigurationResponse contains list of nodes
class NetworkConfigurationResponse extends $pb.GeneratedMessage {
  factory NetworkConfigurationResponse({
    $core.String? configurationId,
    $core.String? networkId,
    $core.Iterable<Node>? nodes,
    $fixnum.Int64? creationTimeUnix,
  }) {
    final result = create();
    if (configurationId != null) result.configurationId = configurationId;
    if (networkId != null) result.networkId = networkId;
    if (nodes != null) result.nodes.addAll(nodes);
    if (creationTimeUnix != null) result.creationTimeUnix = creationTimeUnix;
    return result;
  }

  NetworkConfigurationResponse._();

  factory NetworkConfigurationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NetworkConfigurationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkConfigurationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configurationId',
        protoName: 'configurationId')
    ..aOS(2, _omitFieldNames ? '' : 'networkId', protoName: 'networkId')
    ..pPM<Node>(3, _omitFieldNames ? '' : 'nodes', subBuilder: Node.create)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'creationTimeUnix', $pb.PbFieldType.OU6,
        protoName: 'creationTimeUnix', defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkConfigurationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkConfigurationResponse copyWith(
          void Function(NetworkConfigurationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as NetworkConfigurationResponse))
          as NetworkConfigurationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkConfigurationResponse create() =>
      NetworkConfigurationResponse._();
  @$core.override
  NetworkConfigurationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NetworkConfigurationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NetworkConfigurationResponse>(create);
  static NetworkConfigurationResponse? _defaultInstance;

  /// id of current configuration
  @$pb.TagNumber(1)
  $core.String get configurationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set configurationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigurationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigurationId() => $_clearField(1);

  /// network id
  @$pb.TagNumber(2)
  $core.String get networkId => $_getSZ(1);
  @$pb.TagNumber(2)
  set networkId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNetworkId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNetworkId() => $_clearField(2);

  /// nodes list - it will be empty if the client's currentId is equal configurationId
  @$pb.TagNumber(3)
  $pb.PbList<Node> get nodes => $_getList(2);

  /// unix timestamp of the creation time of configuration
  @$pb.TagNumber(4)
  $fixnum.Int64 get creationTimeUnix => $_getI64(3);
  @$pb.TagNumber(4)
  set creationTimeUnix($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreationTimeUnix() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreationTimeUnix() => $_clearField(4);
}

/// Node describes one node in the network
class Node extends $pb.GeneratedMessage {
  factory Node({
    $core.String? peerId,
    $core.Iterable<$core.String>? addresses,
    $core.Iterable<NodeType>? types,
  }) {
    final result = create();
    if (peerId != null) result.peerId = peerId;
    if (addresses != null) result.addresses.addAll(addresses);
    if (types != null) result.types.addAll(types);
    return result;
  }

  Node._();

  factory Node.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Node.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Node',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'peerId', protoName: 'peerId')
    ..pPS(2, _omitFieldNames ? '' : 'addresses')
    ..pc<NodeType>(3, _omitFieldNames ? '' : 'types', $pb.PbFieldType.KE,
        valueOf: NodeType.valueOf,
        enumValues: NodeType.values,
        defaultEnumValue: NodeType.TreeAPI)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Node clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Node copyWith(void Function(Node) updates) =>
      super.copyWith((message) => updates(message as Node)) as Node;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Node create() => Node._();
  @$core.override
  Node createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Node getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Node>(create);
  static Node? _defaultInstance;

  /// peerId - it's a peer identifier (libp2p format string) so it's an encoded publicKey
  @$pb.TagNumber(1)
  $core.String get peerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set peerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPeerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeerId() => $_clearField(1);

  /// list of node addresses
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get addresses => $_getList(1);

  /// list of supported APIs
  @$pb.TagNumber(3)
  $pb.PbList<NodeType> get types => $_getList(2);
}

/// DeletionConfirmPayloadWithSignature contains protobuf encoded deletion payload and its signature
class DeletionConfirmPayloadWithSignature extends $pb.GeneratedMessage {
  factory DeletionConfirmPayloadWithSignature({
    $core.List<$core.int>? deletionPayload,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (deletionPayload != null) result.deletionPayload = deletionPayload;
    if (signature != null) result.signature = signature;
    return result;
  }

  DeletionConfirmPayloadWithSignature._();

  factory DeletionConfirmPayloadWithSignature.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeletionConfirmPayloadWithSignature.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeletionConfirmPayloadWithSignature',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'deletionPayload', $pb.PbFieldType.OY,
        protoName: 'deletionPayload')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionConfirmPayloadWithSignature clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionConfirmPayloadWithSignature copyWith(
          void Function(DeletionConfirmPayloadWithSignature) updates) =>
      super.copyWith((message) =>
              updates(message as DeletionConfirmPayloadWithSignature))
          as DeletionConfirmPayloadWithSignature;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeletionConfirmPayloadWithSignature create() =>
      DeletionConfirmPayloadWithSignature._();
  @$core.override
  DeletionConfirmPayloadWithSignature createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeletionConfirmPayloadWithSignature getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          DeletionConfirmPayloadWithSignature>(create);
  static DeletionConfirmPayloadWithSignature? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get deletionPayload => $_getN(0);
  @$pb.TagNumber(1)
  set deletionPayload($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeletionPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeletionPayload() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);
}

/// DeletionConfirmPayload contains payload for deletion confirmation
class DeletionConfirmPayload extends $pb.GeneratedMessage {
  factory DeletionConfirmPayload({
    $core.String? spaceId,
    $core.String? peerId,
    $core.List<$core.int>? accountIdentity,
    $core.String? networkId,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (peerId != null) result.peerId = peerId;
    if (accountIdentity != null) result.accountIdentity = accountIdentity;
    if (networkId != null) result.networkId = networkId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  DeletionConfirmPayload._();

  factory DeletionConfirmPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeletionConfirmPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeletionConfirmPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'peerId', protoName: 'peerId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'accountIdentity', $pb.PbFieldType.OY,
        protoName: 'accountIdentity')
    ..aOS(4, _omitFieldNames ? '' : 'networkId', protoName: 'networkId')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionConfirmPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionConfirmPayload copyWith(
          void Function(DeletionConfirmPayload) updates) =>
      super.copyWith((message) => updates(message as DeletionConfirmPayload))
          as DeletionConfirmPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeletionConfirmPayload create() => DeletionConfirmPayload._();
  @$core.override
  DeletionConfirmPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeletionConfirmPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeletionConfirmPayload>(create);
  static DeletionConfirmPayload? _defaultInstance;

  /// SpaceId is the identifier of space
  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  /// PeerId of receipt requester
  @$pb.TagNumber(2)
  $core.String get peerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set peerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeerId() => $_clearField(2);

  /// AccountIdentity is an identity of a space owner
  @$pb.TagNumber(3)
  $core.List<$core.int> get accountIdentity => $_getN(2);
  @$pb.TagNumber(3)
  set accountIdentity($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccountIdentity() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountIdentity() => $_clearField(3);

  /// NetworkId is the id of a network where the deletion was requested
  @$pb.TagNumber(4)
  $core.String get networkId => $_getSZ(3);
  @$pb.TagNumber(4)
  set networkId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNetworkId() => $_has(3);
  @$pb.TagNumber(4)
  void clearNetworkId() => $_clearField(4);

  /// Timestamp is a timestamp when the deletion was requested
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

class DeletionLogRequest extends $pb.GeneratedMessage {
  factory DeletionLogRequest({
    $core.String? afterId,
    $core.int? limit,
  }) {
    final result = create();
    if (afterId != null) result.afterId = afterId;
    if (limit != null) result.limit = limit;
    return result;
  }

  DeletionLogRequest._();

  factory DeletionLogRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeletionLogRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeletionLogRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'afterId', protoName: 'afterId')
    ..aI(2, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionLogRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionLogRequest copyWith(void Function(DeletionLogRequest) updates) =>
      super.copyWith((message) => updates(message as DeletionLogRequest))
          as DeletionLogRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeletionLogRequest create() => DeletionLogRequest._();
  @$core.override
  DeletionLogRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeletionLogRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeletionLogRequest>(create);
  static DeletionLogRequest? _defaultInstance;

  /// AfterId is the last known logId to request records after this id. If it is empty will be returned a list from the beginning.
  @$pb.TagNumber(1)
  $core.String get afterId => $_getSZ(0);
  @$pb.TagNumber(1)
  set afterId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAfterId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAfterId() => $_clearField(1);

  /// Limit is a desired record count in response
  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

class DeletionLogResponse extends $pb.GeneratedMessage {
  factory DeletionLogResponse({
    $core.Iterable<DeletionLogRecord>? records,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (records != null) result.records.addAll(records);
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  DeletionLogResponse._();

  factory DeletionLogResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeletionLogResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeletionLogResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..pPM<DeletionLogRecord>(1, _omitFieldNames ? '' : 'records',
        subBuilder: DeletionLogRecord.create)
    ..aOB(2, _omitFieldNames ? '' : 'hasMore', protoName: 'hasMore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionLogResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionLogResponse copyWith(void Function(DeletionLogResponse) updates) =>
      super.copyWith((message) => updates(message as DeletionLogResponse))
          as DeletionLogResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeletionLogResponse create() => DeletionLogResponse._();
  @$core.override
  DeletionLogResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeletionLogResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeletionLogResponse>(create);
  static DeletionLogResponse? _defaultInstance;

  /// DeletionLogRecord list of records, if there are no new records will be empty
  @$pb.TagNumber(1)
  $pb.PbList<DeletionLogRecord> get records => $_getList(0);

  /// HasMore indicates if there are records left
  @$pb.TagNumber(2)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(2)
  set hasMore($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasMore() => $_clearField(2);
}

class DeletionLogRecord extends $pb.GeneratedMessage {
  factory DeletionLogRecord({
    $core.String? id,
    $core.String? spaceId,
    DeletionLogRecordStatus? status,
    $fixnum.Int64? timestamp,
    $core.String? fileGroup,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (spaceId != null) result.spaceId = spaceId;
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    if (fileGroup != null) result.fileGroup = fileGroup;
    return result;
  }

  DeletionLogRecord._();

  factory DeletionLogRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeletionLogRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeletionLogRecord',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aE<DeletionLogRecordStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: DeletionLogRecordStatus.values)
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..aOS(5, _omitFieldNames ? '' : 'fileGroup', protoName: 'fileGroup')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionLogRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletionLogRecord copyWith(void Function(DeletionLogRecord) updates) =>
      super.copyWith((message) => updates(message as DeletionLogRecord))
          as DeletionLogRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeletionLogRecord create() => DeletionLogRecord._();
  @$core.override
  DeletionLogRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeletionLogRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeletionLogRecord>(create);
  static DeletionLogRecord? _defaultInstance;

  /// Id is a record id
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// SpaceId is a space identifier
  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  /// DeletionLogRecordStatus is a space status
  @$pb.TagNumber(3)
  DeletionLogRecordStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(DeletionLogRecordStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  /// Timestamp is a unixtimestamp of record creation
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);

  /// FileGroup is a key of group for file nodes
  @$pb.TagNumber(5)
  $core.String get fileGroup => $_getSZ(4);
  @$pb.TagNumber(5)
  set fileGroup($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFileGroup() => $_has(4);
  @$pb.TagNumber(5)
  void clearFileGroup() => $_clearField(5);
}

/// SpaceDeleteRequest contains the deletion confirmation for the space to be deleted
class SpaceDeleteRequest extends $pb.GeneratedMessage {
  factory SpaceDeleteRequest({
    $core.String? spaceId,
    $core.String? deletionPayloadId,
    $core.List<$core.int>? deletionPayload,
    $fixnum.Int64? deletionDuration,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (deletionPayloadId != null) result.deletionPayloadId = deletionPayloadId;
    if (deletionPayload != null) result.deletionPayload = deletionPayload;
    if (deletionDuration != null) result.deletionDuration = deletionDuration;
    return result;
  }

  SpaceDeleteRequest._();

  factory SpaceDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'deletionPayloadId',
        protoName: 'deletionPayloadId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'deletionPayload', $pb.PbFieldType.OY,
        protoName: 'deletionPayload')
    ..aInt64(4, _omitFieldNames ? '' : 'deletionDuration',
        protoName: 'deletionDuration')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceDeleteRequest copyWith(void Function(SpaceDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as SpaceDeleteRequest))
          as SpaceDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceDeleteRequest create() => SpaceDeleteRequest._();
  @$core.override
  SpaceDeleteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceDeleteRequest>(create);
  static SpaceDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deletionPayloadId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deletionPayloadId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeletionPayloadId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeletionPayloadId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get deletionPayload => $_getN(2);
  @$pb.TagNumber(3)
  set deletionPayload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeletionPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeletionPayload() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get deletionDuration => $_getI64(3);
  @$pb.TagNumber(4)
  set deletionDuration($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeletionDuration() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeletionDuration() => $_clearField(4);
}

/// SpaceDeleteResponse contains timestamp when the space is finally deleted
class SpaceDeleteResponse extends $pb.GeneratedMessage {
  factory SpaceDeleteResponse({
    $fixnum.Int64? toBeDeletedTimestamp,
  }) {
    final result = create();
    if (toBeDeletedTimestamp != null)
      result.toBeDeletedTimestamp = toBeDeletedTimestamp;
    return result;
  }

  SpaceDeleteResponse._();

  factory SpaceDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'toBeDeletedTimestamp',
        protoName: 'toBeDeletedTimestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceDeleteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceDeleteResponse copyWith(void Function(SpaceDeleteResponse) updates) =>
      super.copyWith((message) => updates(message as SpaceDeleteResponse))
          as SpaceDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceDeleteResponse create() => SpaceDeleteResponse._();
  @$core.override
  SpaceDeleteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceDeleteResponse>(create);
  static SpaceDeleteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get toBeDeletedTimestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set toBeDeletedTimestamp($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToBeDeletedTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearToBeDeletedTimestamp() => $_clearField(1);
}

/// AccountDeleteRequest contains payload for account deletion
class AccountDeleteRequest extends $pb.GeneratedMessage {
  factory AccountDeleteRequest({
    $core.String? deletionPayloadId,
    $core.List<$core.int>? deletionPayload,
  }) {
    final result = create();
    if (deletionPayloadId != null) result.deletionPayloadId = deletionPayloadId;
    if (deletionPayload != null) result.deletionPayload = deletionPayload;
    return result;
  }

  AccountDeleteRequest._();

  factory AccountDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deletionPayloadId',
        protoName: 'deletionPayloadId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'deletionPayload', $pb.PbFieldType.OY,
        protoName: 'deletionPayload')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountDeleteRequest copyWith(void Function(AccountDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as AccountDeleteRequest))
          as AccountDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountDeleteRequest create() => AccountDeleteRequest._();
  @$core.override
  AccountDeleteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountDeleteRequest>(create);
  static AccountDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deletionPayloadId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deletionPayloadId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeletionPayloadId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeletionPayloadId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get deletionPayload => $_getN(1);
  @$pb.TagNumber(2)
  set deletionPayload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeletionPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeletionPayload() => $_clearField(2);
}

/// AccountDeletionConfirmPayload contains payload for deletion confirmation
class AccountDeletionConfirmPayload extends $pb.GeneratedMessage {
  factory AccountDeletionConfirmPayload({
    $core.String? peerId,
    $core.List<$core.int>? accountIdentity,
    $core.String? networkId,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (peerId != null) result.peerId = peerId;
    if (accountIdentity != null) result.accountIdentity = accountIdentity;
    if (networkId != null) result.networkId = networkId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  AccountDeletionConfirmPayload._();

  factory AccountDeletionConfirmPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountDeletionConfirmPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountDeletionConfirmPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'peerId', protoName: 'peerId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'accountIdentity', $pb.PbFieldType.OY,
        protoName: 'accountIdentity')
    ..aOS(3, _omitFieldNames ? '' : 'networkId', protoName: 'networkId')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountDeletionConfirmPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountDeletionConfirmPayload copyWith(
          void Function(AccountDeletionConfirmPayload) updates) =>
      super.copyWith(
              (message) => updates(message as AccountDeletionConfirmPayload))
          as AccountDeletionConfirmPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountDeletionConfirmPayload create() =>
      AccountDeletionConfirmPayload._();
  @$core.override
  AccountDeletionConfirmPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountDeletionConfirmPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountDeletionConfirmPayload>(create);
  static AccountDeletionConfirmPayload? _defaultInstance;

  /// PeerId of receipt requester
  @$pb.TagNumber(1)
  $core.String get peerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set peerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPeerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeerId() => $_clearField(1);

  /// AccountIdentity is an identity of a space owner
  @$pb.TagNumber(2)
  $core.List<$core.int> get accountIdentity => $_getN(1);
  @$pb.TagNumber(2)
  set accountIdentity($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccountIdentity() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountIdentity() => $_clearField(2);

  /// NetworkId is the id of a network where the deletion was requested
  @$pb.TagNumber(3)
  $core.String get networkId => $_getSZ(2);
  @$pb.TagNumber(3)
  set networkId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNetworkId() => $_has(2);
  @$pb.TagNumber(3)
  void clearNetworkId() => $_clearField(3);

  /// Timestamp is a timestamp when the deletion was requested
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// AccountDeleteResponse contains timestamp when the account is finally deleted
class AccountDeleteResponse extends $pb.GeneratedMessage {
  factory AccountDeleteResponse({
    $fixnum.Int64? toBeDeletedTimestamp,
  }) {
    final result = create();
    if (toBeDeletedTimestamp != null)
      result.toBeDeletedTimestamp = toBeDeletedTimestamp;
    return result;
  }

  AccountDeleteResponse._();

  factory AccountDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'toBeDeletedTimestamp',
        protoName: 'toBeDeletedTimestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountDeleteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountDeleteResponse copyWith(
          void Function(AccountDeleteResponse) updates) =>
      super.copyWith((message) => updates(message as AccountDeleteResponse))
          as AccountDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountDeleteResponse create() => AccountDeleteResponse._();
  @$core.override
  AccountDeleteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountDeleteResponse>(create);
  static AccountDeleteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get toBeDeletedTimestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set toBeDeletedTimestamp($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToBeDeletedTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearToBeDeletedTimestamp() => $_clearField(1);
}

/// AccountRevertDeletionRequest is a request to revert an account deletion
class AccountRevertDeletionRequest extends $pb.GeneratedMessage {
  factory AccountRevertDeletionRequest() => create();

  AccountRevertDeletionRequest._();

  factory AccountRevertDeletionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountRevertDeletionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountRevertDeletionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountRevertDeletionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountRevertDeletionRequest copyWith(
          void Function(AccountRevertDeletionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as AccountRevertDeletionRequest))
          as AccountRevertDeletionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountRevertDeletionRequest create() =>
      AccountRevertDeletionRequest._();
  @$core.override
  AccountRevertDeletionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountRevertDeletionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountRevertDeletionRequest>(create);
  static AccountRevertDeletionRequest? _defaultInstance;
}

/// AccountRevertDeletionResponse is an empty response confirming that the deletion is reverted
class AccountRevertDeletionResponse extends $pb.GeneratedMessage {
  factory AccountRevertDeletionResponse() => create();

  AccountRevertDeletionResponse._();

  factory AccountRevertDeletionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountRevertDeletionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountRevertDeletionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountRevertDeletionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountRevertDeletionResponse copyWith(
          void Function(AccountRevertDeletionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as AccountRevertDeletionResponse))
          as AccountRevertDeletionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountRevertDeletionResponse create() =>
      AccountRevertDeletionResponse._();
  @$core.override
  AccountRevertDeletionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountRevertDeletionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountRevertDeletionResponse>(create);
  static AccountRevertDeletionResponse? _defaultInstance;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
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

class AccountLimitsSetRequest extends $pb.GeneratedMessage {
  factory AccountLimitsSetRequest({
    $core.String? identity,
    $core.String? reason,
    $fixnum.Int64? fileStorageLimitBytes,
    $core.int? spaceMembersRead,
    $core.int? spaceMembersWrite,
    $core.int? sharedSpacesLimit,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (reason != null) result.reason = reason;
    if (fileStorageLimitBytes != null)
      result.fileStorageLimitBytes = fileStorageLimitBytes;
    if (spaceMembersRead != null) result.spaceMembersRead = spaceMembersRead;
    if (spaceMembersWrite != null) result.spaceMembersWrite = spaceMembersWrite;
    if (sharedSpacesLimit != null) result.sharedSpacesLimit = sharedSpacesLimit;
    return result;
  }

  AccountLimitsSetRequest._();

  factory AccountLimitsSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountLimitsSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountLimitsSetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'identity')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'fileStorageLimitBytes', $pb.PbFieldType.OU6,
        protoName: 'fileStorageLimitBytes', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(4, _omitFieldNames ? '' : 'spaceMembersRead',
        protoName: 'spaceMembersRead', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'spaceMembersWrite',
        protoName: 'spaceMembersWrite', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'sharedSpacesLimit',
        protoName: 'sharedSpacesLimit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountLimitsSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountLimitsSetRequest copyWith(
          void Function(AccountLimitsSetRequest) updates) =>
      super.copyWith((message) => updates(message as AccountLimitsSetRequest))
          as AccountLimitsSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountLimitsSetRequest create() => AccountLimitsSetRequest._();
  @$core.override
  AccountLimitsSetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountLimitsSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountLimitsSetRequest>(create);
  static AccountLimitsSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get identity => $_getSZ(0);
  @$pb.TagNumber(1)
  set identity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get fileStorageLimitBytes => $_getI64(2);
  @$pb.TagNumber(3)
  set fileStorageLimitBytes($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFileStorageLimitBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileStorageLimitBytes() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get spaceMembersRead => $_getIZ(3);
  @$pb.TagNumber(4)
  set spaceMembersRead($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSpaceMembersRead() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpaceMembersRead() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get spaceMembersWrite => $_getIZ(4);
  @$pb.TagNumber(5)
  set spaceMembersWrite($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceMembersWrite() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpaceMembersWrite() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get sharedSpacesLimit => $_getIZ(5);
  @$pb.TagNumber(6)
  set sharedSpacesLimit($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSharedSpacesLimit() => $_has(5);
  @$pb.TagNumber(6)
  void clearSharedSpacesLimit() => $_clearField(6);
}

class AccountLimitsSetResponse extends $pb.GeneratedMessage {
  factory AccountLimitsSetResponse() => create();

  AccountLimitsSetResponse._();

  factory AccountLimitsSetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AccountLimitsSetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AccountLimitsSetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountLimitsSetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AccountLimitsSetResponse copyWith(
          void Function(AccountLimitsSetResponse) updates) =>
      super.copyWith((message) => updates(message as AccountLimitsSetResponse))
          as AccountLimitsSetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AccountLimitsSetResponse create() => AccountLimitsSetResponse._();
  @$core.override
  AccountLimitsSetResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AccountLimitsSetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AccountLimitsSetResponse>(create);
  static AccountLimitsSetResponse? _defaultInstance;
}

class AclEventLogRequest extends $pb.GeneratedMessage {
  factory AclEventLogRequest({
    $core.String? accountIdentity,
    $core.String? afterId,
    $core.int? limit,
  }) {
    final result = create();
    if (accountIdentity != null) result.accountIdentity = accountIdentity;
    if (afterId != null) result.afterId = afterId;
    if (limit != null) result.limit = limit;
    return result;
  }

  AclEventLogRequest._();

  factory AclEventLogRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclEventLogRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclEventLogRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accountIdentity',
        protoName: 'accountIdentity')
    ..aOS(2, _omitFieldNames ? '' : 'afterId', protoName: 'afterId')
    ..aI(3, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclEventLogRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclEventLogRequest copyWith(void Function(AclEventLogRequest) updates) =>
      super.copyWith((message) => updates(message as AclEventLogRequest))
          as AclEventLogRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclEventLogRequest create() => AclEventLogRequest._();
  @$core.override
  AclEventLogRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclEventLogRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclEventLogRequest>(create);
  static AclEventLogRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accountIdentity => $_getSZ(0);
  @$pb.TagNumber(1)
  set accountIdentity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccountIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountIdentity() => $_clearField(1);

  /// AfterId is the last known logId to request records after this id. If it is empty will be returned a list from the beginning.
  @$pb.TagNumber(2)
  $core.String get afterId => $_getSZ(1);
  @$pb.TagNumber(2)
  set afterId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAfterId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAfterId() => $_clearField(2);

  /// Limit is a desired record count in response
  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class AclEventLogResponse extends $pb.GeneratedMessage {
  factory AclEventLogResponse({
    $core.Iterable<AclEventLogRecord>? records,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (records != null) result.records.addAll(records);
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  AclEventLogResponse._();

  factory AclEventLogResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclEventLogResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclEventLogResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..pPM<AclEventLogRecord>(1, _omitFieldNames ? '' : 'records',
        subBuilder: AclEventLogRecord.create)
    ..aOB(2, _omitFieldNames ? '' : 'hasMore', protoName: 'hasMore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclEventLogResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclEventLogResponse copyWith(void Function(AclEventLogResponse) updates) =>
      super.copyWith((message) => updates(message as AclEventLogResponse))
          as AclEventLogResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclEventLogResponse create() => AclEventLogResponse._();
  @$core.override
  AclEventLogResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclEventLogResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclEventLogResponse>(create);
  static AclEventLogResponse? _defaultInstance;

  /// AclEventLogRecord list of records, if there are no new records will be empty
  @$pb.TagNumber(1)
  $pb.PbList<AclEventLogRecord> get records => $_getList(0);

  /// HasMore indicates if there are records left
  @$pb.TagNumber(2)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(2)
  set hasMore($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasMore() => $_clearField(2);
}

class AclEventLogRecord extends $pb.GeneratedMessage {
  factory AclEventLogRecord({
    $core.String? id,
    $core.String? spaceId,
    $fixnum.Int64? timestamp,
    AclEventLogRecordType? type,
    $core.String? aclChangeId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (spaceId != null) result.spaceId = spaceId;
    if (timestamp != null) result.timestamp = timestamp;
    if (type != null) result.type = type;
    if (aclChangeId != null) result.aclChangeId = aclChangeId;
    return result;
  }

  AclEventLogRecord._();

  factory AclEventLogRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclEventLogRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclEventLogRecord',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..aE<AclEventLogRecordType>(4, _omitFieldNames ? '' : 'type',
        enumValues: AclEventLogRecordType.values)
    ..aOS(5, _omitFieldNames ? '' : 'aclChangeId', protoName: 'aclChangeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclEventLogRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclEventLogRecord copyWith(void Function(AclEventLogRecord) updates) =>
      super.copyWith((message) => updates(message as AclEventLogRecord))
          as AclEventLogRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclEventLogRecord create() => AclEventLogRecord._();
  @$core.override
  AclEventLogRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclEventLogRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclEventLogRecord>(create);
  static AclEventLogRecord? _defaultInstance;

  /// Id is a record id
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// SpaceId is a space identifier
  @$pb.TagNumber(2)
  $core.String get spaceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set spaceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceId() => $_clearField(2);

  /// Timestamp is a unixtimestamp of record creation
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  /// Type of current event
  @$pb.TagNumber(4)
  AclEventLogRecordType get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(AclEventLogRecordType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  /// only for RecordTypeSpaceAclAddRecord
  @$pb.TagNumber(5)
  $core.String get aclChangeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set aclChangeId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAclChangeId() => $_has(4);
  @$pb.TagNumber(5)
  void clearAclChangeId() => $_clearField(5);
}

class AclUploadInviteRequest extends $pb.GeneratedMessage {
  factory AclUploadInviteRequest({
    $core.List<$core.int>? cid,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (cid != null) result.cid = cid;
    if (data != null) result.data = data;
    return result;
  }

  AclUploadInviteRequest._();

  factory AclUploadInviteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclUploadInviteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclUploadInviteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'cid', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclUploadInviteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclUploadInviteRequest copyWith(
          void Function(AclUploadInviteRequest) updates) =>
      super.copyWith((message) => updates(message as AclUploadInviteRequest))
          as AclUploadInviteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclUploadInviteRequest create() => AclUploadInviteRequest._();
  @$core.override
  AclUploadInviteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclUploadInviteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclUploadInviteRequest>(create);
  static AclUploadInviteRequest? _defaultInstance;

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

class AclUploadInviteResponse extends $pb.GeneratedMessage {
  factory AclUploadInviteResponse() => create();

  AclUploadInviteResponse._();

  factory AclUploadInviteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclUploadInviteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclUploadInviteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'coordinator'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclUploadInviteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclUploadInviteResponse copyWith(
          void Function(AclUploadInviteResponse) updates) =>
      super.copyWith((message) => updates(message as AclUploadInviteResponse))
          as AclUploadInviteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclUploadInviteResponse create() => AclUploadInviteResponse._();
  @$core.override
  AclUploadInviteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclUploadInviteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclUploadInviteResponse>(create);
  static AclUploadInviteResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
