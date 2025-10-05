// This is a generated file - do not edit.
//
// Generated from any_block/changes.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ModifyOp extends $pb.ProtobufEnum {
  static const ModifyOp Set = ModifyOp._(0, _omitEnumNames ? '' : 'Set');
  static const ModifyOp Unset = ModifyOp._(1, _omitEnumNames ? '' : 'Unset');
  static const ModifyOp Inc = ModifyOp._(2, _omitEnumNames ? '' : 'Inc');
  static const ModifyOp AddToSet =
      ModifyOp._(3, _omitEnumNames ? '' : 'AddToSet');
  static const ModifyOp Pull = ModifyOp._(4, _omitEnumNames ? '' : 'Pull');

  static const $core.List<ModifyOp> values = <ModifyOp>[
    Set,
    Unset,
    Inc,
    AddToSet,
    Pull,
  ];

  static final $core.List<ModifyOp?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ModifyOp? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ModifyOp._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
