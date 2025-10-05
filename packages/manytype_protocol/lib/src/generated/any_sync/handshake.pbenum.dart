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

class CredentialsType extends $pb.ProtobufEnum {
  /// SkipVerify using when identity is not required, for example in p2p cases
  static const CredentialsType SkipVerify =
      CredentialsType._(0, _omitEnumNames ? '' : 'SkipVerify');

  /// SignedPeerIds using a payload containing PayloadSignedPeerIds message
  static const CredentialsType SignedPeerIds =
      CredentialsType._(1, _omitEnumNames ? '' : 'SignedPeerIds');

  static const $core.List<CredentialsType> values = <CredentialsType>[
    SkipVerify,
    SignedPeerIds,
  ];

  static final $core.List<CredentialsType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static CredentialsType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CredentialsType._(super.value, super.name);
}

class Error extends $pb.ProtobufEnum {
  static const Error Null = Error._(0, _omitEnumNames ? '' : 'Null');
  static const Error Unexpected =
      Error._(1, _omitEnumNames ? '' : 'Unexpected');
  static const Error InvalidCredentials =
      Error._(2, _omitEnumNames ? '' : 'InvalidCredentials');
  static const Error UnexpectedPayload =
      Error._(3, _omitEnumNames ? '' : 'UnexpectedPayload');
  static const Error SkipVerifyNotAllowed =
      Error._(4, _omitEnumNames ? '' : 'SkipVerifyNotAllowed');
  static const Error DeadlineExceeded =
      Error._(5, _omitEnumNames ? '' : 'DeadlineExceeded');
  static const Error IncompatibleVersion =
      Error._(6, _omitEnumNames ? '' : 'IncompatibleVersion');
  static const Error IncompatibleProto =
      Error._(7, _omitEnumNames ? '' : 'IncompatibleProto');

  static const $core.List<Error> values = <Error>[
    Null,
    Unexpected,
    InvalidCredentials,
    UnexpectedPayload,
    SkipVerifyNotAllowed,
    DeadlineExceeded,
    IncompatibleVersion,
    IncompatibleProto,
  ];

  static final $core.List<Error?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static Error? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Error._(super.value, super.name);
}

class ProtoType extends $pb.ProtobufEnum {
  static const ProtoType DRPC = ProtoType._(0, _omitEnumNames ? '' : 'DRPC');

  static const $core.List<ProtoType> values = <ProtoType>[
    DRPC,
  ];

  static final $core.List<ProtoType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 0);
  static ProtoType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProtoType._(super.value, super.name);
}

class Encoding extends $pb.ProtobufEnum {
  static const Encoding None = Encoding._(0, _omitEnumNames ? '' : 'None');
  static const Encoding Snappy = Encoding._(1, _omitEnumNames ? '' : 'Snappy');

  static const $core.List<Encoding> values = <Encoding>[
    None,
    Snappy,
  ];

  static final $core.List<Encoding?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static Encoding? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Encoding._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
