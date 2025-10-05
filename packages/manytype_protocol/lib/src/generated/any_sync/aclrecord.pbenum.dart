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

import 'package:protobuf/protobuf.dart' as $pb;

class AclInviteType extends $pb.ProtobufEnum {
  static const AclInviteType RequestToJoin =
      AclInviteType._(0, _omitEnumNames ? '' : 'RequestToJoin');
  static const AclInviteType AnyoneCanJoin =
      AclInviteType._(1, _omitEnumNames ? '' : 'AnyoneCanJoin');

  static const $core.List<AclInviteType> values = <AclInviteType>[
    RequestToJoin,
    AnyoneCanJoin,
  ];

  static final $core.List<AclInviteType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static AclInviteType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AclInviteType._(super.value, super.name);
}

/// AclUserPermissions contains different possible user roles
class AclUserPermissions extends $pb.ProtobufEnum {
  static const AclUserPermissions None =
      AclUserPermissions._(0, _omitEnumNames ? '' : 'None');
  static const AclUserPermissions Owner =
      AclUserPermissions._(1, _omitEnumNames ? '' : 'Owner');
  static const AclUserPermissions Admin =
      AclUserPermissions._(2, _omitEnumNames ? '' : 'Admin');
  static const AclUserPermissions Writer =
      AclUserPermissions._(3, _omitEnumNames ? '' : 'Writer');
  static const AclUserPermissions Reader =
      AclUserPermissions._(4, _omitEnumNames ? '' : 'Reader');
  static const AclUserPermissions Guest =
      AclUserPermissions._(5, _omitEnumNames ? '' : 'Guest');

  static const $core.List<AclUserPermissions> values = <AclUserPermissions>[
    None,
    Owner,
    Admin,
    Writer,
    Reader,
    Guest,
  ];

  static final $core.List<AclUserPermissions?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static AclUserPermissions? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AclUserPermissions._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
