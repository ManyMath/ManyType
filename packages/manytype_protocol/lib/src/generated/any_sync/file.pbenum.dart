// This is a generated file - do not edit.
//
// Generated from any_sync/file.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ErrCodes extends $pb.ProtobufEnum {
  static const ErrCodes Unexpected =
      ErrCodes._(0, _omitEnumNames ? '' : 'Unexpected');
  static const ErrCodes CIDNotFound =
      ErrCodes._(1, _omitEnumNames ? '' : 'CIDNotFound');
  static const ErrCodes Forbidden =
      ErrCodes._(2, _omitEnumNames ? '' : 'Forbidden');
  static const ErrCodes DeprecatedLimitExceeded_ =
      ErrCodes._(3, _omitEnumNames ? '' : '_DeprecatedLimitExceeded');
  static const ErrCodes QuerySizeExceeded =
      ErrCodes._(4, _omitEnumNames ? '' : 'QuerySizeExceeded');
  static const ErrCodes WrongHash =
      ErrCodes._(5, _omitEnumNames ? '' : 'WrongHash');
  static const ErrCodes NotEnoughSpace =
      ErrCodes._(6, _omitEnumNames ? '' : 'NotEnoughSpace');
  static const ErrCodes AclRecordNotFound =
      ErrCodes._(7, _omitEnumNames ? '' : 'AclRecordNotFound');
  static const ErrCodes LimitExceeded =
      ErrCodes._(8, _omitEnumNames ? '' : 'LimitExceeded');
  static const ErrCodes ErrorOffset =
      ErrCodes._(200, _omitEnumNames ? '' : 'ErrorOffset');

  static const $core.List<ErrCodes> values = <ErrCodes>[
    Unexpected,
    CIDNotFound,
    Forbidden,
    DeprecatedLimitExceeded_,
    QuerySizeExceeded,
    WrongHash,
    NotEnoughSpace,
    AclRecordNotFound,
    LimitExceeded,
    ErrorOffset,
  ];

  static final $core.Map<$core.int, ErrCodes> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static ErrCodes? valueOf($core.int value) => _byValue[value];

  const ErrCodes._(super.value, super.name);
}

class AvailabilityStatus extends $pb.ProtobufEnum {
  static const AvailabilityStatus NotExists =
      AvailabilityStatus._(0, _omitEnumNames ? '' : 'NotExists');
  static const AvailabilityStatus Exists =
      AvailabilityStatus._(1, _omitEnumNames ? '' : 'Exists');
  static const AvailabilityStatus ExistsInSpace =
      AvailabilityStatus._(2, _omitEnumNames ? '' : 'ExistsInSpace');

  static const $core.List<AvailabilityStatus> values = <AvailabilityStatus>[
    NotExists,
    Exists,
    ExistsInSpace,
  ];

  static final $core.List<AvailabilityStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static AvailabilityStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AvailabilityStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
