// This is a generated file - do not edit.
//
// Generated from any_sync/aclrecord.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'aclrecord.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'aclrecord.pbenum.dart';

/// AclRoot is a root of access control list
class AclRoot extends $pb.GeneratedMessage {
  factory AclRoot({
    $core.List<$core.int>? identity,
    $core.List<$core.int>? masterKey,
    $core.String? spaceId,
    $core.List<$core.int>? encryptedReadKey,
    $fixnum.Int64? timestamp,
    $core.List<$core.int>? identitySignature,
    $core.List<$core.int>? metadataPubKey,
    $core.List<$core.int>? encryptedMetadataPrivKey,
    $core.List<$core.int>? encryptedOwnerMetadata,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (masterKey != null) result.masterKey = masterKey;
    if (spaceId != null) result.spaceId = spaceId;
    if (encryptedReadKey != null) result.encryptedReadKey = encryptedReadKey;
    if (timestamp != null) result.timestamp = timestamp;
    if (identitySignature != null) result.identitySignature = identitySignature;
    if (metadataPubKey != null) result.metadataPubKey = metadataPubKey;
    if (encryptedMetadataPrivKey != null)
      result.encryptedMetadataPrivKey = encryptedMetadataPrivKey;
    if (encryptedOwnerMetadata != null)
      result.encryptedOwnerMetadata = encryptedOwnerMetadata;
    return result;
  }

  AclRoot._();

  factory AclRoot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclRoot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclRoot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'masterKey', $pb.PbFieldType.OY,
        protoName: 'masterKey')
    ..aOS(3, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'encryptedReadKey', $pb.PbFieldType.OY,
        protoName: 'encryptedReadKey')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'identitySignature', $pb.PbFieldType.OY,
        protoName: 'identitySignature')
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'metadataPubKey', $pb.PbFieldType.OY,
        protoName: 'metadataPubKey')
    ..a<$core.List<$core.int>>(8,
        _omitFieldNames ? '' : 'encryptedMetadataPrivKey', $pb.PbFieldType.OY,
        protoName: 'encryptedMetadataPrivKey')
    ..a<$core.List<$core.int>>(
        9, _omitFieldNames ? '' : 'encryptedOwnerMetadata', $pb.PbFieldType.OY,
        protoName: 'encryptedOwnerMetadata')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclRoot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclRoot copyWith(void Function(AclRoot) updates) =>
      super.copyWith((message) => updates(message as AclRoot)) as AclRoot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclRoot create() => AclRoot._();
  @$core.override
  AclRoot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclRoot getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AclRoot>(create);
  static AclRoot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get masterKey => $_getN(1);
  @$pb.TagNumber(2)
  set masterKey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMasterKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearMasterKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get spaceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set spaceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpaceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpaceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get encryptedReadKey => $_getN(3);
  @$pb.TagNumber(4)
  set encryptedReadKey($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptedReadKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedReadKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get identitySignature => $_getN(5);
  @$pb.TagNumber(6)
  set identitySignature($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIdentitySignature() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdentitySignature() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get metadataPubKey => $_getN(6);
  @$pb.TagNumber(7)
  set metadataPubKey($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMetadataPubKey() => $_has(6);
  @$pb.TagNumber(7)
  void clearMetadataPubKey() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get encryptedMetadataPrivKey => $_getN(7);
  @$pb.TagNumber(8)
  set encryptedMetadataPrivKey($core.List<$core.int> value) =>
      $_setBytes(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEncryptedMetadataPrivKey() => $_has(7);
  @$pb.TagNumber(8)
  void clearEncryptedMetadataPrivKey() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.int> get encryptedOwnerMetadata => $_getN(8);
  @$pb.TagNumber(9)
  set encryptedOwnerMetadata($core.List<$core.int> value) =>
      $_setBytes(8, value);
  @$pb.TagNumber(9)
  $core.bool hasEncryptedOwnerMetadata() => $_has(8);
  @$pb.TagNumber(9)
  void clearEncryptedOwnerMetadata() => $_clearField(9);
}

/// AclAccountInvite contains the public invite key, the private part of which is sent to the user directly
class AclAccountInvite extends $pb.GeneratedMessage {
  factory AclAccountInvite({
    $core.List<$core.int>? inviteKey,
    AclInviteType? inviteType,
    AclUserPermissions? permissions,
    $core.List<$core.int>? encryptedReadKey,
  }) {
    final result = create();
    if (inviteKey != null) result.inviteKey = inviteKey;
    if (inviteType != null) result.inviteType = inviteType;
    if (permissions != null) result.permissions = permissions;
    if (encryptedReadKey != null) result.encryptedReadKey = encryptedReadKey;
    return result;
  }

  AclAccountInvite._();

  factory AclAccountInvite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountInvite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountInvite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'inviteKey', $pb.PbFieldType.OY,
        protoName: 'inviteKey')
    ..aE<AclInviteType>(2, _omitFieldNames ? '' : 'inviteType',
        protoName: 'inviteType', enumValues: AclInviteType.values)
    ..aE<AclUserPermissions>(3, _omitFieldNames ? '' : 'permissions',
        enumValues: AclUserPermissions.values)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'encryptedReadKey', $pb.PbFieldType.OY,
        protoName: 'encryptedReadKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountInvite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountInvite copyWith(void Function(AclAccountInvite) updates) =>
      super.copyWith((message) => updates(message as AclAccountInvite))
          as AclAccountInvite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountInvite create() => AclAccountInvite._();
  @$core.override
  AclAccountInvite createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountInvite getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountInvite>(create);
  static AclAccountInvite? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get inviteKey => $_getN(0);
  @$pb.TagNumber(1)
  set inviteKey($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInviteKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearInviteKey() => $_clearField(1);

  @$pb.TagNumber(2)
  AclInviteType get inviteType => $_getN(1);
  @$pb.TagNumber(2)
  set inviteType(AclInviteType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasInviteType() => $_has(1);
  @$pb.TagNumber(2)
  void clearInviteType() => $_clearField(2);

  @$pb.TagNumber(3)
  AclUserPermissions get permissions => $_getN(2);
  @$pb.TagNumber(3)
  set permissions(AclUserPermissions value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPermissions() => $_has(2);
  @$pb.TagNumber(3)
  void clearPermissions() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get encryptedReadKey => $_getN(3);
  @$pb.TagNumber(4)
  set encryptedReadKey($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptedReadKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedReadKey() => $_clearField(4);
}

class AclAccountInviteChange extends $pb.GeneratedMessage {
  factory AclAccountInviteChange({
    $core.String? inviteRecordId,
    AclUserPermissions? permissions,
  }) {
    final result = create();
    if (inviteRecordId != null) result.inviteRecordId = inviteRecordId;
    if (permissions != null) result.permissions = permissions;
    return result;
  }

  AclAccountInviteChange._();

  factory AclAccountInviteChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountInviteChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountInviteChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'inviteRecordId',
        protoName: 'inviteRecordId')
    ..aE<AclUserPermissions>(2, _omitFieldNames ? '' : 'permissions',
        enumValues: AclUserPermissions.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountInviteChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountInviteChange copyWith(
          void Function(AclAccountInviteChange) updates) =>
      super.copyWith((message) => updates(message as AclAccountInviteChange))
          as AclAccountInviteChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountInviteChange create() => AclAccountInviteChange._();
  @$core.override
  AclAccountInviteChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountInviteChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountInviteChange>(create);
  static AclAccountInviteChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get inviteRecordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set inviteRecordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInviteRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearInviteRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  AclUserPermissions get permissions => $_getN(1);
  @$pb.TagNumber(2)
  set permissions(AclUserPermissions value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPermissions() => $_has(1);
  @$pb.TagNumber(2)
  void clearPermissions() => $_clearField(2);
}

/// AclAccountRequestJoin contains the reference to the invite record and the data of the person who wants to join, confirmed by the private invite key
class AclAccountRequestJoin extends $pb.GeneratedMessage {
  factory AclAccountRequestJoin({
    $core.List<$core.int>? inviteIdentity,
    $core.String? inviteRecordId,
    $core.List<$core.int>? inviteIdentitySignature,
    $core.List<$core.int>? metadata,
  }) {
    final result = create();
    if (inviteIdentity != null) result.inviteIdentity = inviteIdentity;
    if (inviteRecordId != null) result.inviteRecordId = inviteRecordId;
    if (inviteIdentitySignature != null)
      result.inviteIdentitySignature = inviteIdentitySignature;
    if (metadata != null) result.metadata = metadata;
    return result;
  }

  AclAccountRequestJoin._();

  factory AclAccountRequestJoin.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountRequestJoin.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountRequestJoin',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'inviteIdentity', $pb.PbFieldType.OY,
        protoName: 'inviteIdentity')
    ..aOS(2, _omitFieldNames ? '' : 'inviteRecordId',
        protoName: 'inviteRecordId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'inviteIdentitySignature', $pb.PbFieldType.OY,
        protoName: 'inviteIdentitySignature')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'metadata', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestJoin clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestJoin copyWith(
          void Function(AclAccountRequestJoin) updates) =>
      super.copyWith((message) => updates(message as AclAccountRequestJoin))
          as AclAccountRequestJoin;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountRequestJoin create() => AclAccountRequestJoin._();
  @$core.override
  AclAccountRequestJoin createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountRequestJoin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountRequestJoin>(create);
  static AclAccountRequestJoin? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get inviteIdentity => $_getN(0);
  @$pb.TagNumber(1)
  set inviteIdentity($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInviteIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearInviteIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get inviteRecordId => $_getSZ(1);
  @$pb.TagNumber(2)
  set inviteRecordId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInviteRecordId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInviteRecordId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get inviteIdentitySignature => $_getN(2);
  @$pb.TagNumber(3)
  set inviteIdentitySignature($core.List<$core.int> value) =>
      $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInviteIdentitySignature() => $_has(2);
  @$pb.TagNumber(3)
  void clearInviteIdentitySignature() => $_clearField(3);

  /// Metadata is encrypted with metadata key of the space
  @$pb.TagNumber(4)
  $core.List<$core.int> get metadata => $_getN(3);
  @$pb.TagNumber(4)
  set metadata($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMetadata() => $_has(3);
  @$pb.TagNumber(4)
  void clearMetadata() => $_clearField(4);
}

/// AclInviteJoin contains the reference to the invite record and the data of the person who wants to join, confirmed by the private invite key
/// The person must encrypt the key with its own public key
class AclAccountInviteJoin extends $pb.GeneratedMessage {
  factory AclAccountInviteJoin({
    $core.List<$core.int>? identity,
    $core.String? inviteRecordId,
    $core.List<$core.int>? inviteIdentitySignature,
    $core.List<$core.int>? metadata,
    $core.List<$core.int>? encryptedReadKey,
    AclUserPermissions? permissions,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (inviteRecordId != null) result.inviteRecordId = inviteRecordId;
    if (inviteIdentitySignature != null)
      result.inviteIdentitySignature = inviteIdentitySignature;
    if (metadata != null) result.metadata = metadata;
    if (encryptedReadKey != null) result.encryptedReadKey = encryptedReadKey;
    if (permissions != null) result.permissions = permissions;
    return result;
  }

  AclAccountInviteJoin._();

  factory AclAccountInviteJoin.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountInviteJoin.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountInviteJoin',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'inviteRecordId',
        protoName: 'inviteRecordId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'inviteIdentitySignature', $pb.PbFieldType.OY,
        protoName: 'inviteIdentitySignature')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'metadata', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'encryptedReadKey', $pb.PbFieldType.OY,
        protoName: 'encryptedReadKey')
    ..aE<AclUserPermissions>(6, _omitFieldNames ? '' : 'permissions',
        enumValues: AclUserPermissions.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountInviteJoin clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountInviteJoin copyWith(void Function(AclAccountInviteJoin) updates) =>
      super.copyWith((message) => updates(message as AclAccountInviteJoin))
          as AclAccountInviteJoin;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountInviteJoin create() => AclAccountInviteJoin._();
  @$core.override
  AclAccountInviteJoin createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountInviteJoin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountInviteJoin>(create);
  static AclAccountInviteJoin? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get inviteRecordId => $_getSZ(1);
  @$pb.TagNumber(2)
  set inviteRecordId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInviteRecordId() => $_has(1);
  @$pb.TagNumber(2)
  void clearInviteRecordId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get inviteIdentitySignature => $_getN(2);
  @$pb.TagNumber(3)
  set inviteIdentitySignature($core.List<$core.int> value) =>
      $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInviteIdentitySignature() => $_has(2);
  @$pb.TagNumber(3)
  void clearInviteIdentitySignature() => $_clearField(3);

  /// Metadata is encrypted with metadata key of the space
  @$pb.TagNumber(4)
  $core.List<$core.int> get metadata => $_getN(3);
  @$pb.TagNumber(4)
  set metadata($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMetadata() => $_has(3);
  @$pb.TagNumber(4)
  void clearMetadata() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get encryptedReadKey => $_getN(4);
  @$pb.TagNumber(5)
  set encryptedReadKey($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEncryptedReadKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncryptedReadKey() => $_clearField(5);

  @$pb.TagNumber(6)
  AclUserPermissions get permissions => $_getN(5);
  @$pb.TagNumber(6)
  set permissions(AclUserPermissions value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasPermissions() => $_has(5);
  @$pb.TagNumber(6)
  void clearPermissions() => $_clearField(6);
}

/// AclAccountRequestAccept contains the reference to join record and all read keys, encrypted with the identity of the requestor
class AclAccountRequestAccept extends $pb.GeneratedMessage {
  factory AclAccountRequestAccept({
    $core.List<$core.int>? identity,
    $core.String? requestRecordId,
    $core.List<$core.int>? encryptedReadKey,
    AclUserPermissions? permissions,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (requestRecordId != null) result.requestRecordId = requestRecordId;
    if (encryptedReadKey != null) result.encryptedReadKey = encryptedReadKey;
    if (permissions != null) result.permissions = permissions;
    return result;
  }

  AclAccountRequestAccept._();

  factory AclAccountRequestAccept.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountRequestAccept.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountRequestAccept',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'requestRecordId',
        protoName: 'requestRecordId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'encryptedReadKey', $pb.PbFieldType.OY,
        protoName: 'encryptedReadKey')
    ..aE<AclUserPermissions>(4, _omitFieldNames ? '' : 'permissions',
        enumValues: AclUserPermissions.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestAccept clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestAccept copyWith(
          void Function(AclAccountRequestAccept) updates) =>
      super.copyWith((message) => updates(message as AclAccountRequestAccept))
          as AclAccountRequestAccept;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountRequestAccept create() => AclAccountRequestAccept._();
  @$core.override
  AclAccountRequestAccept createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountRequestAccept getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountRequestAccept>(create);
  static AclAccountRequestAccept? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get requestRecordId => $_getSZ(1);
  @$pb.TagNumber(2)
  set requestRecordId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestRecordId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestRecordId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedReadKey => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedReadKey($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncryptedReadKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedReadKey() => $_clearField(3);

  @$pb.TagNumber(4)
  AclUserPermissions get permissions => $_getN(3);
  @$pb.TagNumber(4)
  set permissions(AclUserPermissions value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPermissions() => $_has(3);
  @$pb.TagNumber(4)
  void clearPermissions() => $_clearField(4);
}

/// AclAccountRequestDecline contains the reference to join record
class AclAccountRequestDecline extends $pb.GeneratedMessage {
  factory AclAccountRequestDecline({
    $core.String? requestRecordId,
  }) {
    final result = create();
    if (requestRecordId != null) result.requestRecordId = requestRecordId;
    return result;
  }

  AclAccountRequestDecline._();

  factory AclAccountRequestDecline.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountRequestDecline.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountRequestDecline',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestRecordId',
        protoName: 'requestRecordId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestDecline clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestDecline copyWith(
          void Function(AclAccountRequestDecline) updates) =>
      super.copyWith((message) => updates(message as AclAccountRequestDecline))
          as AclAccountRequestDecline;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountRequestDecline create() => AclAccountRequestDecline._();
  @$core.override
  AclAccountRequestDecline createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountRequestDecline getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountRequestDecline>(create);
  static AclAccountRequestDecline? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestRecordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestRecordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestRecordId() => $_clearField(1);
}

/// AclAccountInviteRevoke revokes the invite record
class AclAccountInviteRevoke extends $pb.GeneratedMessage {
  factory AclAccountInviteRevoke({
    $core.String? inviteRecordId,
  }) {
    final result = create();
    if (inviteRecordId != null) result.inviteRecordId = inviteRecordId;
    return result;
  }

  AclAccountInviteRevoke._();

  factory AclAccountInviteRevoke.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountInviteRevoke.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountInviteRevoke',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'inviteRecordId',
        protoName: 'inviteRecordId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountInviteRevoke clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountInviteRevoke copyWith(
          void Function(AclAccountInviteRevoke) updates) =>
      super.copyWith((message) => updates(message as AclAccountInviteRevoke))
          as AclAccountInviteRevoke;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountInviteRevoke create() => AclAccountInviteRevoke._();
  @$core.override
  AclAccountInviteRevoke createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountInviteRevoke getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountInviteRevoke>(create);
  static AclAccountInviteRevoke? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get inviteRecordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set inviteRecordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInviteRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearInviteRecordId() => $_clearField(1);
}

/// AclEncryptedReadKeys are new key for specific identity
class AclEncryptedReadKey extends $pb.GeneratedMessage {
  factory AclEncryptedReadKey({
    $core.List<$core.int>? identity,
    $core.List<$core.int>? encryptedReadKey,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (encryptedReadKey != null) result.encryptedReadKey = encryptedReadKey;
    return result;
  }

  AclEncryptedReadKey._();

  factory AclEncryptedReadKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclEncryptedReadKey.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclEncryptedReadKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'encryptedReadKey', $pb.PbFieldType.OY,
        protoName: 'encryptedReadKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclEncryptedReadKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclEncryptedReadKey copyWith(void Function(AclEncryptedReadKey) updates) =>
      super.copyWith((message) => updates(message as AclEncryptedReadKey))
          as AclEncryptedReadKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclEncryptedReadKey create() => AclEncryptedReadKey._();
  @$core.override
  AclEncryptedReadKey createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclEncryptedReadKey getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclEncryptedReadKey>(create);
  static AclEncryptedReadKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedReadKey => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedReadKey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptedReadKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedReadKey() => $_clearField(2);
}

/// AclAccountPermissionChanges contains permission changes for certain identities
class AclAccountPermissionChanges extends $pb.GeneratedMessage {
  factory AclAccountPermissionChanges({
    $core.Iterable<AclAccountPermissionChange>? changes,
  }) {
    final result = create();
    if (changes != null) result.changes.addAll(changes);
    return result;
  }

  AclAccountPermissionChanges._();

  factory AclAccountPermissionChanges.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountPermissionChanges.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountPermissionChanges',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..pPM<AclAccountPermissionChange>(1, _omitFieldNames ? '' : 'changes',
        subBuilder: AclAccountPermissionChange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountPermissionChanges clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountPermissionChanges copyWith(
          void Function(AclAccountPermissionChanges) updates) =>
      super.copyWith(
              (message) => updates(message as AclAccountPermissionChanges))
          as AclAccountPermissionChanges;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountPermissionChanges create() =>
      AclAccountPermissionChanges._();
  @$core.override
  AclAccountPermissionChanges createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountPermissionChanges getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountPermissionChanges>(create);
  static AclAccountPermissionChanges? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AclAccountPermissionChange> get changes => $_getList(0);
}

/// AclAccountsAdd contains new accounts to be added
class AclAccountsAdd extends $pb.GeneratedMessage {
  factory AclAccountsAdd({
    $core.Iterable<AclAccountAdd>? additions,
  }) {
    final result = create();
    if (additions != null) result.additions.addAll(additions);
    return result;
  }

  AclAccountsAdd._();

  factory AclAccountsAdd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountsAdd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountsAdd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..pPM<AclAccountAdd>(1, _omitFieldNames ? '' : 'additions',
        subBuilder: AclAccountAdd.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountsAdd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountsAdd copyWith(void Function(AclAccountsAdd) updates) =>
      super.copyWith((message) => updates(message as AclAccountsAdd))
          as AclAccountsAdd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountsAdd create() => AclAccountsAdd._();
  @$core.override
  AclAccountsAdd createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountsAdd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountsAdd>(create);
  static AclAccountsAdd? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AclAccountAdd> get additions => $_getList(0);
}

/// AclAccountAdd contains new account to be added
class AclAccountAdd extends $pb.GeneratedMessage {
  factory AclAccountAdd({
    $core.List<$core.int>? identity,
    AclUserPermissions? permissions,
    $core.List<$core.int>? metadata,
    $core.List<$core.int>? encryptedReadKey,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (permissions != null) result.permissions = permissions;
    if (metadata != null) result.metadata = metadata;
    if (encryptedReadKey != null) result.encryptedReadKey = encryptedReadKey;
    return result;
  }

  AclAccountAdd._();

  factory AclAccountAdd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountAdd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountAdd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..aE<AclUserPermissions>(2, _omitFieldNames ? '' : 'permissions',
        enumValues: AclUserPermissions.values)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'metadata', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'encryptedReadKey', $pb.PbFieldType.OY,
        protoName: 'encryptedReadKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountAdd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountAdd copyWith(void Function(AclAccountAdd) updates) =>
      super.copyWith((message) => updates(message as AclAccountAdd))
          as AclAccountAdd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountAdd create() => AclAccountAdd._();
  @$core.override
  AclAccountAdd createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountAdd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountAdd>(create);
  static AclAccountAdd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  AclUserPermissions get permissions => $_getN(1);
  @$pb.TagNumber(2)
  set permissions(AclUserPermissions value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPermissions() => $_has(1);
  @$pb.TagNumber(2)
  void clearPermissions() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get metadata => $_getN(2);
  @$pb.TagNumber(3)
  set metadata($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMetadata() => $_has(2);
  @$pb.TagNumber(3)
  void clearMetadata() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get encryptedReadKey => $_getN(3);
  @$pb.TagNumber(4)
  set encryptedReadKey($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptedReadKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedReadKey() => $_clearField(4);
}

/// AclRequestCancel contains reference to the request that is canceled by the account
class AclAccountRequestCancel extends $pb.GeneratedMessage {
  factory AclAccountRequestCancel({
    $core.String? recordId,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    return result;
  }

  AclAccountRequestCancel._();

  factory AclAccountRequestCancel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountRequestCancel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountRequestCancel',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId', protoName: 'recordId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestCancel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestCancel copyWith(
          void Function(AclAccountRequestCancel) updates) =>
      super.copyWith((message) => updates(message as AclAccountRequestCancel))
          as AclAccountRequestCancel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountRequestCancel create() => AclAccountRequestCancel._();
  @$core.override
  AclAccountRequestCancel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountRequestCancel getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountRequestCancel>(create);
  static AclAccountRequestCancel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);
}

/// AclAccountPermissionChange changes permissions of specific account
class AclAccountPermissionChange extends $pb.GeneratedMessage {
  factory AclAccountPermissionChange({
    $core.List<$core.int>? identity,
    AclUserPermissions? permissions,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (permissions != null) result.permissions = permissions;
    return result;
  }

  AclAccountPermissionChange._();

  factory AclAccountPermissionChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountPermissionChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountPermissionChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identity', $pb.PbFieldType.OY)
    ..aE<AclUserPermissions>(2, _omitFieldNames ? '' : 'permissions',
        enumValues: AclUserPermissions.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountPermissionChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountPermissionChange copyWith(
          void Function(AclAccountPermissionChange) updates) =>
      super.copyWith(
              (message) => updates(message as AclAccountPermissionChange))
          as AclAccountPermissionChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountPermissionChange create() => AclAccountPermissionChange._();
  @$core.override
  AclAccountPermissionChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountPermissionChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountPermissionChange>(create);
  static AclAccountPermissionChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  AclUserPermissions get permissions => $_getN(1);
  @$pb.TagNumber(2)
  set permissions(AclUserPermissions value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPermissions() => $_has(1);
  @$pb.TagNumber(2)
  void clearPermissions() => $_clearField(2);
}

/// AclReadKeyChange changes the key for a space
class AclReadKeyChange extends $pb.GeneratedMessage {
  factory AclReadKeyChange({
    $core.Iterable<AclEncryptedReadKey>? accountKeys,
    $core.List<$core.int>? metadataPubKey,
    $core.List<$core.int>? encryptedMetadataPrivKey,
    $core.List<$core.int>? encryptedOldReadKey,
    $core.Iterable<AclEncryptedReadKey>? inviteKeys,
  }) {
    final result = create();
    if (accountKeys != null) result.accountKeys.addAll(accountKeys);
    if (metadataPubKey != null) result.metadataPubKey = metadataPubKey;
    if (encryptedMetadataPrivKey != null)
      result.encryptedMetadataPrivKey = encryptedMetadataPrivKey;
    if (encryptedOldReadKey != null)
      result.encryptedOldReadKey = encryptedOldReadKey;
    if (inviteKeys != null) result.inviteKeys.addAll(inviteKeys);
    return result;
  }

  AclReadKeyChange._();

  factory AclReadKeyChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclReadKeyChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclReadKeyChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..pPM<AclEncryptedReadKey>(1, _omitFieldNames ? '' : 'accountKeys',
        protoName: 'accountKeys', subBuilder: AclEncryptedReadKey.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'metadataPubKey', $pb.PbFieldType.OY,
        protoName: 'metadataPubKey')
    ..a<$core.List<$core.int>>(3,
        _omitFieldNames ? '' : 'encryptedMetadataPrivKey', $pb.PbFieldType.OY,
        protoName: 'encryptedMetadataPrivKey')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'encryptedOldReadKey', $pb.PbFieldType.OY,
        protoName: 'encryptedOldReadKey')
    ..pPM<AclEncryptedReadKey>(5, _omitFieldNames ? '' : 'inviteKeys',
        protoName: 'inviteKeys', subBuilder: AclEncryptedReadKey.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclReadKeyChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclReadKeyChange copyWith(void Function(AclReadKeyChange) updates) =>
      super.copyWith((message) => updates(message as AclReadKeyChange))
          as AclReadKeyChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclReadKeyChange create() => AclReadKeyChange._();
  @$core.override
  AclReadKeyChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclReadKeyChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclReadKeyChange>(create);
  static AclReadKeyChange? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AclEncryptedReadKey> get accountKeys => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get metadataPubKey => $_getN(1);
  @$pb.TagNumber(2)
  set metadataPubKey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMetadataPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearMetadataPubKey() => $_clearField(2);

  /// EncryptedMetadataPrivKey is encrypted with new read key
  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedMetadataPrivKey => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedMetadataPrivKey($core.List<$core.int> value) =>
      $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncryptedMetadataPrivKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedMetadataPrivKey() => $_clearField(3);

  /// EncryptedOldReadKey is encrypted with new read key
  @$pb.TagNumber(4)
  $core.List<$core.int> get encryptedOldReadKey => $_getN(3);
  @$pb.TagNumber(4)
  set encryptedOldReadKey($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptedOldReadKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedOldReadKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<AclEncryptedReadKey> get inviteKeys => $_getList(4);
}

/// AclAccountRemove removes an account and changes read key for space
class AclAccountRemove extends $pb.GeneratedMessage {
  factory AclAccountRemove({
    $core.Iterable<$core.List<$core.int>>? identities,
    AclReadKeyChange? readKeyChange,
  }) {
    final result = create();
    if (identities != null) result.identities.addAll(identities);
    if (readKeyChange != null) result.readKeyChange = readKeyChange;
    return result;
  }

  AclAccountRemove._();

  factory AclAccountRemove.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountRemove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountRemove',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..p<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identities', $pb.PbFieldType.PY)
    ..aOM<AclReadKeyChange>(2, _omitFieldNames ? '' : 'readKeyChange',
        protoName: 'readKeyChange', subBuilder: AclReadKeyChange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRemove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRemove copyWith(void Function(AclAccountRemove) updates) =>
      super.copyWith((message) => updates(message as AclAccountRemove))
          as AclAccountRemove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountRemove create() => AclAccountRemove._();
  @$core.override
  AclAccountRemove createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountRemove getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountRemove>(create);
  static AclAccountRemove? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.List<$core.int>> get identities => $_getList(0);

  @$pb.TagNumber(2)
  AclReadKeyChange get readKeyChange => $_getN(1);
  @$pb.TagNumber(2)
  set readKeyChange(AclReadKeyChange value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasReadKeyChange() => $_has(1);
  @$pb.TagNumber(2)
  void clearReadKeyChange() => $_clearField(2);
  @$pb.TagNumber(2)
  AclReadKeyChange ensureReadKeyChange() => $_ensure(1);
}

/// AclAccountRequestRemove adds a request to remove an account
class AclAccountRequestRemove extends $pb.GeneratedMessage {
  factory AclAccountRequestRemove() => create();

  AclAccountRequestRemove._();

  factory AclAccountRequestRemove.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclAccountRequestRemove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclAccountRequestRemove',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestRemove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclAccountRequestRemove copyWith(
          void Function(AclAccountRequestRemove) updates) =>
      super.copyWith((message) => updates(message as AclAccountRequestRemove))
          as AclAccountRequestRemove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclAccountRequestRemove create() => AclAccountRequestRemove._();
  @$core.override
  AclAccountRequestRemove createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclAccountRequestRemove getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclAccountRequestRemove>(create);
  static AclAccountRequestRemove? _defaultInstance;
}

enum AclContentValue_Value {
  invite,
  inviteRevoke,
  requestJoin,
  requestAccept,
  permissionChange,
  accountRemove,
  readKeyChange,
  requestDecline,
  accountRequestRemove,
  permissionChanges,
  accountsAdd,
  requestCancel,
  inviteJoin,
  inviteChange,
  notSet
}

/// AclContentValue contains possible values for Acl
class AclContentValue extends $pb.GeneratedMessage {
  factory AclContentValue({
    AclAccountInvite? invite,
    AclAccountInviteRevoke? inviteRevoke,
    AclAccountRequestJoin? requestJoin,
    AclAccountRequestAccept? requestAccept,
    AclAccountPermissionChange? permissionChange,
    AclAccountRemove? accountRemove,
    AclReadKeyChange? readKeyChange,
    AclAccountRequestDecline? requestDecline,
    AclAccountRequestRemove? accountRequestRemove,
    AclAccountPermissionChanges? permissionChanges,
    AclAccountsAdd? accountsAdd,
    AclAccountRequestCancel? requestCancel,
    AclAccountInviteJoin? inviteJoin,
    AclAccountInviteChange? inviteChange,
  }) {
    final result = create();
    if (invite != null) result.invite = invite;
    if (inviteRevoke != null) result.inviteRevoke = inviteRevoke;
    if (requestJoin != null) result.requestJoin = requestJoin;
    if (requestAccept != null) result.requestAccept = requestAccept;
    if (permissionChange != null) result.permissionChange = permissionChange;
    if (accountRemove != null) result.accountRemove = accountRemove;
    if (readKeyChange != null) result.readKeyChange = readKeyChange;
    if (requestDecline != null) result.requestDecline = requestDecline;
    if (accountRequestRemove != null)
      result.accountRequestRemove = accountRequestRemove;
    if (permissionChanges != null) result.permissionChanges = permissionChanges;
    if (accountsAdd != null) result.accountsAdd = accountsAdd;
    if (requestCancel != null) result.requestCancel = requestCancel;
    if (inviteJoin != null) result.inviteJoin = inviteJoin;
    if (inviteChange != null) result.inviteChange = inviteChange;
    return result;
  }

  AclContentValue._();

  factory AclContentValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclContentValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, AclContentValue_Value>
      _AclContentValue_ValueByTag = {
    1: AclContentValue_Value.invite,
    2: AclContentValue_Value.inviteRevoke,
    3: AclContentValue_Value.requestJoin,
    4: AclContentValue_Value.requestAccept,
    5: AclContentValue_Value.permissionChange,
    6: AclContentValue_Value.accountRemove,
    7: AclContentValue_Value.readKeyChange,
    8: AclContentValue_Value.requestDecline,
    9: AclContentValue_Value.accountRequestRemove,
    10: AclContentValue_Value.permissionChanges,
    11: AclContentValue_Value.accountsAdd,
    12: AclContentValue_Value.requestCancel,
    13: AclContentValue_Value.inviteJoin,
    14: AclContentValue_Value.inviteChange,
    0: AclContentValue_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclContentValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14])
    ..aOM<AclAccountInvite>(1, _omitFieldNames ? '' : 'invite',
        subBuilder: AclAccountInvite.create)
    ..aOM<AclAccountInviteRevoke>(2, _omitFieldNames ? '' : 'inviteRevoke',
        protoName: 'inviteRevoke', subBuilder: AclAccountInviteRevoke.create)
    ..aOM<AclAccountRequestJoin>(3, _omitFieldNames ? '' : 'requestJoin',
        protoName: 'requestJoin', subBuilder: AclAccountRequestJoin.create)
    ..aOM<AclAccountRequestAccept>(4, _omitFieldNames ? '' : 'requestAccept',
        protoName: 'requestAccept', subBuilder: AclAccountRequestAccept.create)
    ..aOM<AclAccountPermissionChange>(
        5, _omitFieldNames ? '' : 'permissionChange',
        protoName: 'permissionChange',
        subBuilder: AclAccountPermissionChange.create)
    ..aOM<AclAccountRemove>(6, _omitFieldNames ? '' : 'accountRemove',
        protoName: 'accountRemove', subBuilder: AclAccountRemove.create)
    ..aOM<AclReadKeyChange>(7, _omitFieldNames ? '' : 'readKeyChange',
        protoName: 'readKeyChange', subBuilder: AclReadKeyChange.create)
    ..aOM<AclAccountRequestDecline>(8, _omitFieldNames ? '' : 'requestDecline',
        protoName: 'requestDecline',
        subBuilder: AclAccountRequestDecline.create)
    ..aOM<AclAccountRequestRemove>(
        9, _omitFieldNames ? '' : 'accountRequestRemove',
        protoName: 'accountRequestRemove',
        subBuilder: AclAccountRequestRemove.create)
    ..aOM<AclAccountPermissionChanges>(
        10, _omitFieldNames ? '' : 'permissionChanges',
        protoName: 'permissionChanges',
        subBuilder: AclAccountPermissionChanges.create)
    ..aOM<AclAccountsAdd>(11, _omitFieldNames ? '' : 'accountsAdd',
        protoName: 'accountsAdd', subBuilder: AclAccountsAdd.create)
    ..aOM<AclAccountRequestCancel>(12, _omitFieldNames ? '' : 'requestCancel',
        protoName: 'requestCancel', subBuilder: AclAccountRequestCancel.create)
    ..aOM<AclAccountInviteJoin>(13, _omitFieldNames ? '' : 'inviteJoin',
        protoName: 'inviteJoin', subBuilder: AclAccountInviteJoin.create)
    ..aOM<AclAccountInviteChange>(14, _omitFieldNames ? '' : 'inviteChange',
        protoName: 'inviteChange', subBuilder: AclAccountInviteChange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclContentValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclContentValue copyWith(void Function(AclContentValue) updates) =>
      super.copyWith((message) => updates(message as AclContentValue))
          as AclContentValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclContentValue create() => AclContentValue._();
  @$core.override
  AclContentValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclContentValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AclContentValue>(create);
  static AclContentValue? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  AclContentValue_Value whichValue() =>
      _AclContentValue_ValueByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  void clearValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  AclAccountInvite get invite => $_getN(0);
  @$pb.TagNumber(1)
  set invite(AclAccountInvite value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasInvite() => $_has(0);
  @$pb.TagNumber(1)
  void clearInvite() => $_clearField(1);
  @$pb.TagNumber(1)
  AclAccountInvite ensureInvite() => $_ensure(0);

  @$pb.TagNumber(2)
  AclAccountInviteRevoke get inviteRevoke => $_getN(1);
  @$pb.TagNumber(2)
  set inviteRevoke(AclAccountInviteRevoke value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasInviteRevoke() => $_has(1);
  @$pb.TagNumber(2)
  void clearInviteRevoke() => $_clearField(2);
  @$pb.TagNumber(2)
  AclAccountInviteRevoke ensureInviteRevoke() => $_ensure(1);

  @$pb.TagNumber(3)
  AclAccountRequestJoin get requestJoin => $_getN(2);
  @$pb.TagNumber(3)
  set requestJoin(AclAccountRequestJoin value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestJoin() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestJoin() => $_clearField(3);
  @$pb.TagNumber(3)
  AclAccountRequestJoin ensureRequestJoin() => $_ensure(2);

  @$pb.TagNumber(4)
  AclAccountRequestAccept get requestAccept => $_getN(3);
  @$pb.TagNumber(4)
  set requestAccept(AclAccountRequestAccept value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasRequestAccept() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequestAccept() => $_clearField(4);
  @$pb.TagNumber(4)
  AclAccountRequestAccept ensureRequestAccept() => $_ensure(3);

  /// AclAccountPermissionChange deprecated
  @$pb.TagNumber(5)
  AclAccountPermissionChange get permissionChange => $_getN(4);
  @$pb.TagNumber(5)
  set permissionChange(AclAccountPermissionChange value) =>
      $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPermissionChange() => $_has(4);
  @$pb.TagNumber(5)
  void clearPermissionChange() => $_clearField(5);
  @$pb.TagNumber(5)
  AclAccountPermissionChange ensurePermissionChange() => $_ensure(4);

  @$pb.TagNumber(6)
  AclAccountRemove get accountRemove => $_getN(5);
  @$pb.TagNumber(6)
  set accountRemove(AclAccountRemove value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAccountRemove() => $_has(5);
  @$pb.TagNumber(6)
  void clearAccountRemove() => $_clearField(6);
  @$pb.TagNumber(6)
  AclAccountRemove ensureAccountRemove() => $_ensure(5);

  @$pb.TagNumber(7)
  AclReadKeyChange get readKeyChange => $_getN(6);
  @$pb.TagNumber(7)
  set readKeyChange(AclReadKeyChange value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasReadKeyChange() => $_has(6);
  @$pb.TagNumber(7)
  void clearReadKeyChange() => $_clearField(7);
  @$pb.TagNumber(7)
  AclReadKeyChange ensureReadKeyChange() => $_ensure(6);

  @$pb.TagNumber(8)
  AclAccountRequestDecline get requestDecline => $_getN(7);
  @$pb.TagNumber(8)
  set requestDecline(AclAccountRequestDecline value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasRequestDecline() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequestDecline() => $_clearField(8);
  @$pb.TagNumber(8)
  AclAccountRequestDecline ensureRequestDecline() => $_ensure(7);

  @$pb.TagNumber(9)
  AclAccountRequestRemove get accountRequestRemove => $_getN(8);
  @$pb.TagNumber(9)
  set accountRequestRemove(AclAccountRequestRemove value) =>
      $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasAccountRequestRemove() => $_has(8);
  @$pb.TagNumber(9)
  void clearAccountRequestRemove() => $_clearField(9);
  @$pb.TagNumber(9)
  AclAccountRequestRemove ensureAccountRequestRemove() => $_ensure(8);

  @$pb.TagNumber(10)
  AclAccountPermissionChanges get permissionChanges => $_getN(9);
  @$pb.TagNumber(10)
  set permissionChanges(AclAccountPermissionChanges value) =>
      $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasPermissionChanges() => $_has(9);
  @$pb.TagNumber(10)
  void clearPermissionChanges() => $_clearField(10);
  @$pb.TagNumber(10)
  AclAccountPermissionChanges ensurePermissionChanges() => $_ensure(9);

  @$pb.TagNumber(11)
  AclAccountsAdd get accountsAdd => $_getN(10);
  @$pb.TagNumber(11)
  set accountsAdd(AclAccountsAdd value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasAccountsAdd() => $_has(10);
  @$pb.TagNumber(11)
  void clearAccountsAdd() => $_clearField(11);
  @$pb.TagNumber(11)
  AclAccountsAdd ensureAccountsAdd() => $_ensure(10);

  @$pb.TagNumber(12)
  AclAccountRequestCancel get requestCancel => $_getN(11);
  @$pb.TagNumber(12)
  set requestCancel(AclAccountRequestCancel value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasRequestCancel() => $_has(11);
  @$pb.TagNumber(12)
  void clearRequestCancel() => $_clearField(12);
  @$pb.TagNumber(12)
  AclAccountRequestCancel ensureRequestCancel() => $_ensure(11);

  @$pb.TagNumber(13)
  AclAccountInviteJoin get inviteJoin => $_getN(12);
  @$pb.TagNumber(13)
  set inviteJoin(AclAccountInviteJoin value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasInviteJoin() => $_has(12);
  @$pb.TagNumber(13)
  void clearInviteJoin() => $_clearField(13);
  @$pb.TagNumber(13)
  AclAccountInviteJoin ensureInviteJoin() => $_ensure(12);

  @$pb.TagNumber(14)
  AclAccountInviteChange get inviteChange => $_getN(13);
  @$pb.TagNumber(14)
  set inviteChange(AclAccountInviteChange value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasInviteChange() => $_has(13);
  @$pb.TagNumber(14)
  void clearInviteChange() => $_clearField(14);
  @$pb.TagNumber(14)
  AclAccountInviteChange ensureInviteChange() => $_ensure(13);
}

/// AclData contains different acl content
class AclData extends $pb.GeneratedMessage {
  factory AclData({
    $core.Iterable<AclContentValue>? aclContent,
  }) {
    final result = create();
    if (aclContent != null) result.aclContent.addAll(aclContent);
    return result;
  }

  AclData._();

  factory AclData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AclData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AclData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'aclrecord'),
      createEmptyInstance: create)
    ..pPM<AclContentValue>(1, _omitFieldNames ? '' : 'aclContent',
        protoName: 'aclContent', subBuilder: AclContentValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AclData copyWith(void Function(AclData) updates) =>
      super.copyWith((message) => updates(message as AclData)) as AclData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AclData create() => AclData._();
  @$core.override
  AclData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AclData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AclData>(create);
  static AclData? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AclContentValue> get aclContent => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
