// This is a generated file - do not edit.
//
// Generated from any_sync/consensus.proto.

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
  static const ErrCodes LogExists =
      ErrCodes._(1, _omitEnumNames ? '' : 'LogExists');
  static const ErrCodes LogNotFound =
      ErrCodes._(2, _omitEnumNames ? '' : 'LogNotFound');
  static const ErrCodes RecordConflict =
      ErrCodes._(3, _omitEnumNames ? '' : 'RecordConflict');
  static const ErrCodes Forbidden =
      ErrCodes._(4, _omitEnumNames ? '' : 'Forbidden');
  static const ErrCodes InvalidPayload =
      ErrCodes._(5, _omitEnumNames ? '' : 'InvalidPayload');
  static const ErrCodes ErrorOffset =
      ErrCodes._(500, _omitEnumNames ? '' : 'ErrorOffset');

  static const $core.List<ErrCodes> values = <ErrCodes>[
    Unexpected,
    LogExists,
    LogNotFound,
    RecordConflict,
    Forbidden,
    InvalidPayload,
    ErrorOffset,
  ];

  static final $core.Map<$core.int, ErrCodes> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static ErrCodes? valueOf($core.int value) => _byValue[value];

  const ErrCodes._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
