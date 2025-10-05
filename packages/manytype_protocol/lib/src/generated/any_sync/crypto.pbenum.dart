// This is a generated file - do not edit.
//
// Generated from any_sync/crypto.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class KeyType extends $pb.ProtobufEnum {
  static const KeyType Ed25519Public =
      KeyType._(0, _omitEnumNames ? '' : 'Ed25519Public');
  static const KeyType Ed25519Private =
      KeyType._(1, _omitEnumNames ? '' : 'Ed25519Private');
  static const KeyType AES = KeyType._(2, _omitEnumNames ? '' : 'AES');

  static const $core.List<KeyType> values = <KeyType>[
    Ed25519Public,
    Ed25519Private,
    AES,
  ];

  static final $core.List<KeyType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static KeyType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const KeyType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
