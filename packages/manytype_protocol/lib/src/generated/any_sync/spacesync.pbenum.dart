// This is a generated file - do not edit.
//
// Generated from any_sync/spacesync.proto.

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
  static const ErrCodes SpaceMissing =
      ErrCodes._(1, _omitEnumNames ? '' : 'SpaceMissing');
  static const ErrCodes SpaceExists =
      ErrCodes._(2, _omitEnumNames ? '' : 'SpaceExists');
  static const ErrCodes SpaceNotInCache =
      ErrCodes._(3, _omitEnumNames ? '' : 'SpaceNotInCache');
  static const ErrCodes SpaceIsDeleted =
      ErrCodes._(4, _omitEnumNames ? '' : 'SpaceIsDeleted');
  static const ErrCodes PeerIsNotResponsible =
      ErrCodes._(5, _omitEnumNames ? '' : 'PeerIsNotResponsible');
  static const ErrCodes ReceiptIsInvalid =
      ErrCodes._(6, _omitEnumNames ? '' : 'ReceiptIsInvalid');
  static const ErrCodes InvalidPayload =
      ErrCodes._(7, _omitEnumNames ? '' : 'InvalidPayload');
  static const ErrCodes DuplicateRequest =
      ErrCodes._(8, _omitEnumNames ? '' : 'DuplicateRequest');
  static const ErrCodes TooManyRequestsFromPeer =
      ErrCodes._(9, _omitEnumNames ? '' : 'TooManyRequestsFromPeer');
  static const ErrCodes ErrorOffset =
      ErrCodes._(100, _omitEnumNames ? '' : 'ErrorOffset');

  static const $core.List<ErrCodes> values = <ErrCodes>[
    Unexpected,
    SpaceMissing,
    SpaceExists,
    SpaceNotInCache,
    SpaceIsDeleted,
    PeerIsNotResponsible,
    ReceiptIsInvalid,
    InvalidPayload,
    DuplicateRequest,
    TooManyRequestsFromPeer,
    ErrorOffset,
  ];

  static final $core.Map<$core.int, ErrCodes> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static ErrCodes? valueOf($core.int value) => _byValue[value];

  const ErrCodes._(super.value, super.name);
}

/// SpaceSubscription contains in ObjectSyncMessage.Payload and indicates that we need to subscribe or unsubscribe the current stream to this space
class SpaceSubscriptionAction extends $pb.ProtobufEnum {
  static const SpaceSubscriptionAction Subscribe =
      SpaceSubscriptionAction._(0, _omitEnumNames ? '' : 'Subscribe');
  static const SpaceSubscriptionAction Unsubscribe =
      SpaceSubscriptionAction._(1, _omitEnumNames ? '' : 'Unsubscribe');

  static const $core.List<SpaceSubscriptionAction> values =
      <SpaceSubscriptionAction>[
    Subscribe,
    Unsubscribe,
  ];

  static final $core.List<SpaceSubscriptionAction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static SpaceSubscriptionAction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SpaceSubscriptionAction._(super.value, super.name);
}

/// DiffType is a type of diff
class DiffType extends $pb.ProtobufEnum {
  static const DiffType Initial =
      DiffType._(0, _omitEnumNames ? '' : 'Initial');
  static const DiffType V1 = DiffType._(1, _omitEnumNames ? '' : 'V1');
  static const DiffType V2 = DiffType._(2, _omitEnumNames ? '' : 'V2');
  static const DiffType V3 = DiffType._(3, _omitEnumNames ? '' : 'V3');

  static const $core.List<DiffType> values = <DiffType>[
    Initial,
    V1,
    V2,
    V3,
  ];

  static final $core.List<DiffType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static DiffType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DiffType._(super.value, super.name);
}

/// ObjectType is a type of object
class ObjectType extends $pb.ProtobufEnum {
  static const ObjectType Tree = ObjectType._(0, _omitEnumNames ? '' : 'Tree');
  static const ObjectType Acl = ObjectType._(1, _omitEnumNames ? '' : 'Acl');
  static const ObjectType KeyValue =
      ObjectType._(2, _omitEnumNames ? '' : 'KeyValue');

  static const $core.List<ObjectType> values = <ObjectType>[
    Tree,
    Acl,
    KeyValue,
  ];

  static final $core.List<ObjectType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ObjectType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ObjectType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
