// This is a generated file - do not edit.
//
// Generated from any_sync/spacesync.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use errCodesDescriptor instead')
const ErrCodes$json = {
  '1': 'ErrCodes',
  '2': [
    {'1': 'Unexpected', '2': 0},
    {'1': 'SpaceMissing', '2': 1},
    {'1': 'SpaceExists', '2': 2},
    {'1': 'SpaceNotInCache', '2': 3},
    {'1': 'SpaceIsDeleted', '2': 4},
    {'1': 'PeerIsNotResponsible', '2': 5},
    {'1': 'ReceiptIsInvalid', '2': 6},
    {'1': 'InvalidPayload', '2': 7},
    {'1': 'DuplicateRequest', '2': 8},
    {'1': 'TooManyRequestsFromPeer', '2': 9},
    {'1': 'ErrorOffset', '2': 100},
  ],
};

/// Descriptor for `ErrCodes`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errCodesDescriptor = $convert.base64Decode(
    'CghFcnJDb2RlcxIOCgpVbmV4cGVjdGVkEAASEAoMU3BhY2VNaXNzaW5nEAESDwoLU3BhY2VFeG'
    'lzdHMQAhITCg9TcGFjZU5vdEluQ2FjaGUQAxISCg5TcGFjZUlzRGVsZXRlZBAEEhgKFFBlZXJJ'
    'c05vdFJlc3BvbnNpYmxlEAUSFAoQUmVjZWlwdElzSW52YWxpZBAGEhIKDkludmFsaWRQYXlsb2'
    'FkEAcSFAoQRHVwbGljYXRlUmVxdWVzdBAIEhsKF1Rvb01hbnlSZXF1ZXN0c0Zyb21QZWVyEAkS'
    'DwoLRXJyb3JPZmZzZXQQZA==');

@$core.Deprecated('Use spaceSubscriptionActionDescriptor instead')
const SpaceSubscriptionAction$json = {
  '1': 'SpaceSubscriptionAction',
  '2': [
    {'1': 'Subscribe', '2': 0},
    {'1': 'Unsubscribe', '2': 1},
  ],
};

/// Descriptor for `SpaceSubscriptionAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spaceSubscriptionActionDescriptor =
    $convert.base64Decode(
        'ChdTcGFjZVN1YnNjcmlwdGlvbkFjdGlvbhINCglTdWJzY3JpYmUQABIPCgtVbnN1YnNjcmliZR'
        'AB');

@$core.Deprecated('Use diffTypeDescriptor instead')
const DiffType$json = {
  '1': 'DiffType',
  '2': [
    {'1': 'Initial', '2': 0},
    {'1': 'V1', '2': 1},
    {'1': 'V2', '2': 2},
    {'1': 'V3', '2': 3},
  ],
};

/// Descriptor for `DiffType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List diffTypeDescriptor = $convert.base64Decode(
    'CghEaWZmVHlwZRILCgdJbml0aWFsEAASBgoCVjEQARIGCgJWMhACEgYKAlYzEAM=');

@$core.Deprecated('Use objectTypeDescriptor instead')
const ObjectType$json = {
  '1': 'ObjectType',
  '2': [
    {'1': 'Tree', '2': 0},
    {'1': 'Acl', '2': 1},
    {'1': 'KeyValue', '2': 2},
  ],
};

/// Descriptor for `ObjectType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List objectTypeDescriptor = $convert.base64Decode(
    'CgpPYmplY3RUeXBlEggKBFRyZWUQABIHCgNBY2wQARIMCghLZXlWYWx1ZRAC');

@$core.Deprecated('Use headSyncRangeDescriptor instead')
const HeadSyncRange$json = {
  '1': 'HeadSyncRange',
  '2': [
    {'1': 'from', '3': 1, '4': 1, '5': 4, '10': 'from'},
    {'1': 'to', '3': 2, '4': 1, '5': 4, '10': 'to'},
    {'1': 'limit', '3': 3, '4': 1, '5': 13, '10': 'limit'},
    {'1': 'elements', '3': 4, '4': 1, '5': 8, '10': 'elements'},
  ],
};

/// Descriptor for `HeadSyncRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List headSyncRangeDescriptor = $convert.base64Decode(
    'Cg1IZWFkU3luY1JhbmdlEhIKBGZyb20YASABKARSBGZyb20SDgoCdG8YAiABKARSAnRvEhQKBW'
    'xpbWl0GAMgASgNUgVsaW1pdBIaCghlbGVtZW50cxgEIAEoCFIIZWxlbWVudHM=');

@$core.Deprecated('Use headSyncResultDescriptor instead')
const HeadSyncResult$json = {
  '1': 'HeadSyncResult',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 12, '10': 'hash'},
    {
      '1': 'elements',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.spacesync.HeadSyncResultElement',
      '10': 'elements'
    },
    {'1': 'count', '3': 3, '4': 1, '5': 13, '10': 'count'},
  ],
};

/// Descriptor for `HeadSyncResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List headSyncResultDescriptor = $convert.base64Decode(
    'Cg5IZWFkU3luY1Jlc3VsdBISCgRoYXNoGAEgASgMUgRoYXNoEjwKCGVsZW1lbnRzGAIgAygLMi'
    'Auc3BhY2VzeW5jLkhlYWRTeW5jUmVzdWx0RWxlbWVudFIIZWxlbWVudHMSFAoFY291bnQYAyAB'
    'KA1SBWNvdW50');

@$core.Deprecated('Use headSyncResultElementDescriptor instead')
const HeadSyncResultElement$json = {
  '1': 'HeadSyncResultElement',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'head', '3': 2, '4': 1, '5': 9, '10': 'head'},
  ],
};

/// Descriptor for `HeadSyncResultElement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List headSyncResultElementDescriptor = $convert.base64Decode(
    'ChVIZWFkU3luY1Jlc3VsdEVsZW1lbnQSDgoCaWQYASABKAlSAmlkEhIKBGhlYWQYAiABKAlSBG'
    'hlYWQ=');

@$core.Deprecated('Use headSyncRequestDescriptor instead')
const HeadSyncRequest$json = {
  '1': 'HeadSyncRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {
      '1': 'ranges',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.spacesync.HeadSyncRange',
      '10': 'ranges'
    },
    {
      '1': 'diffType',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.spacesync.DiffType',
      '10': 'diffType'
    },
  ],
};

/// Descriptor for `HeadSyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List headSyncRequestDescriptor = $convert.base64Decode(
    'Cg9IZWFkU3luY1JlcXVlc3QSGAoHc3BhY2VJZBgBIAEoCVIHc3BhY2VJZBIwCgZyYW5nZXMYAi'
    'ADKAsyGC5zcGFjZXN5bmMuSGVhZFN5bmNSYW5nZVIGcmFuZ2VzEi8KCGRpZmZUeXBlGAMgASgO'
    'MhMuc3BhY2VzeW5jLkRpZmZUeXBlUghkaWZmVHlwZQ==');

@$core.Deprecated('Use headSyncResponseDescriptor instead')
const HeadSyncResponse$json = {
  '1': 'HeadSyncResponse',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.spacesync.HeadSyncResult',
      '10': 'results'
    },
    {
      '1': 'diffType',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.spacesync.DiffType',
      '10': 'diffType'
    },
  ],
};

/// Descriptor for `HeadSyncResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List headSyncResponseDescriptor = $convert.base64Decode(
    'ChBIZWFkU3luY1Jlc3BvbnNlEjMKB3Jlc3VsdHMYASADKAsyGS5zcGFjZXN5bmMuSGVhZFN5bm'
    'NSZXN1bHRSB3Jlc3VsdHMSLwoIZGlmZlR5cGUYAiABKA4yEy5zcGFjZXN5bmMuRGlmZlR5cGVS'
    'CGRpZmZUeXBl');

@$core.Deprecated('Use objectSyncMessageDescriptor instead')
const ObjectSyncMessage$json = {
  '1': 'ObjectSyncMessage',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'requestId', '3': 2, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'replyId', '3': 3, '4': 1, '5': 9, '10': 'replyId'},
    {'1': 'payload', '3': 4, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'objectId', '3': 5, '4': 1, '5': 9, '10': 'objectId'},
    {
      '1': 'objectType',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.spacesync.ObjectType',
      '10': 'objectType'
    },
  ],
};

/// Descriptor for `ObjectSyncMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List objectSyncMessageDescriptor = $convert.base64Decode(
    'ChFPYmplY3RTeW5jTWVzc2FnZRIYCgdzcGFjZUlkGAEgASgJUgdzcGFjZUlkEhwKCXJlcXVlc3'
    'RJZBgCIAEoCVIJcmVxdWVzdElkEhgKB3JlcGx5SWQYAyABKAlSB3JlcGx5SWQSGAoHcGF5bG9h'
    'ZBgEIAEoDFIHcGF5bG9hZBIaCghvYmplY3RJZBgFIAEoCVIIb2JqZWN0SWQSNQoKb2JqZWN0VH'
    'lwZRgGIAEoDjIVLnNwYWNlc3luYy5PYmplY3RUeXBlUgpvYmplY3RUeXBl');

@$core.Deprecated('Use spacePushRequestDescriptor instead')
const SpacePushRequest$json = {
  '1': 'SpacePushRequest',
  '2': [
    {
      '1': 'payload',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.spacesync.SpacePayload',
      '10': 'payload'
    },
    {'1': 'Credential', '3': 2, '4': 1, '5': 12, '10': 'Credential'},
  ],
};

/// Descriptor for `SpacePushRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spacePushRequestDescriptor = $convert.base64Decode(
    'ChBTcGFjZVB1c2hSZXF1ZXN0EjEKB3BheWxvYWQYASABKAsyFy5zcGFjZXN5bmMuU3BhY2VQYX'
    'lsb2FkUgdwYXlsb2FkEh4KCkNyZWRlbnRpYWwYAiABKAxSCkNyZWRlbnRpYWw=');

@$core.Deprecated('Use spacePushResponseDescriptor instead')
const SpacePushResponse$json = {
  '1': 'SpacePushResponse',
};

/// Descriptor for `SpacePushResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spacePushResponseDescriptor =
    $convert.base64Decode('ChFTcGFjZVB1c2hSZXNwb25zZQ==');

@$core.Deprecated('Use spacePullRequestDescriptor instead')
const SpacePullRequest$json = {
  '1': 'SpacePullRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `SpacePullRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spacePullRequestDescriptor =
    $convert.base64Decode('ChBTcGFjZVB1bGxSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use spacePullResponseDescriptor instead')
const SpacePullResponse$json = {
  '1': 'SpacePullResponse',
  '2': [
    {
      '1': 'payload',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.spacesync.SpacePayload',
      '10': 'payload'
    },
    {
      '1': 'aclRecords',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.spacesync.AclRecord',
      '10': 'aclRecords'
    },
  ],
};

/// Descriptor for `SpacePullResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spacePullResponseDescriptor = $convert.base64Decode(
    'ChFTcGFjZVB1bGxSZXNwb25zZRIxCgdwYXlsb2FkGAEgASgLMhcuc3BhY2VzeW5jLlNwYWNlUG'
    'F5bG9hZFIHcGF5bG9hZBI0CgphY2xSZWNvcmRzGAIgAygLMhQuc3BhY2VzeW5jLkFjbFJlY29y'
    'ZFIKYWNsUmVjb3Jkcw==');

@$core.Deprecated('Use aclRecordDescriptor instead')
const AclRecord$json = {
  '1': 'AclRecord',
  '2': [
    {'1': 'aclPayload', '3': 1, '4': 1, '5': 12, '10': 'aclPayload'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `AclRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclRecordDescriptor = $convert.base64Decode(
    'CglBY2xSZWNvcmQSHgoKYWNsUGF5bG9hZBgBIAEoDFIKYWNsUGF5bG9hZBIOCgJpZBgCIAEoCV'
    'ICaWQ=');

@$core.Deprecated('Use spacePayloadDescriptor instead')
const SpacePayload$json = {
  '1': 'SpacePayload',
  '2': [
    {
      '1': 'spaceHeader',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.spacesync.RawSpaceHeaderWithId',
      '10': 'spaceHeader'
    },
    {'1': 'aclPayload', '3': 2, '4': 1, '5': 12, '10': 'aclPayload'},
    {'1': 'aclPayloadId', '3': 3, '4': 1, '5': 9, '10': 'aclPayloadId'},
    {
      '1': 'spaceSettingsPayload',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'spaceSettingsPayload'
    },
    {
      '1': 'spaceSettingsPayloadId',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'spaceSettingsPayloadId'
    },
  ],
};

/// Descriptor for `SpacePayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spacePayloadDescriptor = $convert.base64Decode(
    'CgxTcGFjZVBheWxvYWQSQQoLc3BhY2VIZWFkZXIYASABKAsyHy5zcGFjZXN5bmMuUmF3U3BhY2'
    'VIZWFkZXJXaXRoSWRSC3NwYWNlSGVhZGVyEh4KCmFjbFBheWxvYWQYAiABKAxSCmFjbFBheWxv'
    'YWQSIgoMYWNsUGF5bG9hZElkGAMgASgJUgxhY2xQYXlsb2FkSWQSMgoUc3BhY2VTZXR0aW5nc1'
    'BheWxvYWQYBCABKAxSFHNwYWNlU2V0dGluZ3NQYXlsb2FkEjYKFnNwYWNlU2V0dGluZ3NQYXls'
    'b2FkSWQYBSABKAlSFnNwYWNlU2V0dGluZ3NQYXlsb2FkSWQ=');

@$core.Deprecated('Use spaceHeaderDescriptor instead')
const SpaceHeader$json = {
  '1': 'SpaceHeader',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'spaceType', '3': 3, '4': 1, '5': 9, '10': 'spaceType'},
    {'1': 'replicationKey', '3': 4, '4': 1, '5': 4, '10': 'replicationKey'},
    {'1': 'seed', '3': 5, '4': 1, '5': 12, '10': 'seed'},
    {
      '1': 'spaceHeaderPayload',
      '3': 6,
      '4': 1,
      '5': 12,
      '10': 'spaceHeaderPayload'
    },
  ],
};

/// Descriptor for `SpaceHeader`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceHeaderDescriptor = $convert.base64Decode(
    'CgtTcGFjZUhlYWRlchIaCghpZGVudGl0eRgBIAEoDFIIaWRlbnRpdHkSHAoJdGltZXN0YW1wGA'
    'IgASgDUgl0aW1lc3RhbXASHAoJc3BhY2VUeXBlGAMgASgJUglzcGFjZVR5cGUSJgoOcmVwbGlj'
    'YXRpb25LZXkYBCABKARSDnJlcGxpY2F0aW9uS2V5EhIKBHNlZWQYBSABKAxSBHNlZWQSLgoSc3'
    'BhY2VIZWFkZXJQYXlsb2FkGAYgASgMUhJzcGFjZUhlYWRlclBheWxvYWQ=');

@$core.Deprecated('Use rawSpaceHeaderDescriptor instead')
const RawSpaceHeader$json = {
  '1': 'RawSpaceHeader',
  '2': [
    {'1': 'spaceHeader', '3': 1, '4': 1, '5': 12, '10': 'spaceHeader'},
    {'1': 'signature', '3': 2, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `RawSpaceHeader`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rawSpaceHeaderDescriptor = $convert.base64Decode(
    'Cg5SYXdTcGFjZUhlYWRlchIgCgtzcGFjZUhlYWRlchgBIAEoDFILc3BhY2VIZWFkZXISHAoJc2'
    'lnbmF0dXJlGAIgASgMUglzaWduYXR1cmU=');

@$core.Deprecated('Use rawSpaceHeaderWithIdDescriptor instead')
const RawSpaceHeaderWithId$json = {
  '1': 'RawSpaceHeaderWithId',
  '2': [
    {'1': 'rawHeader', '3': 1, '4': 1, '5': 12, '10': 'rawHeader'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `RawSpaceHeaderWithId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rawSpaceHeaderWithIdDescriptor = $convert.base64Decode(
    'ChRSYXdTcGFjZUhlYWRlcldpdGhJZBIcCglyYXdIZWFkZXIYASABKAxSCXJhd0hlYWRlchIOCg'
    'JpZBgCIAEoCVICaWQ=');

@$core.Deprecated('Use spaceSettingsContentDescriptor instead')
const SpaceSettingsContent$json = {
  '1': 'SpaceSettingsContent',
  '2': [
    {
      '1': 'objectDelete',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.spacesync.ObjectDelete',
      '9': 0,
      '10': 'objectDelete'
    },
    {
      '1': 'spaceDelete',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.spacesync.SpaceDelete',
      '9': 0,
      '10': 'spaceDelete'
    },
  ],
  '8': [
    {'1': 'value'},
  ],
};

/// Descriptor for `SpaceSettingsContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceSettingsContentDescriptor = $convert.base64Decode(
    'ChRTcGFjZVNldHRpbmdzQ29udGVudBI9CgxvYmplY3REZWxldGUYASABKAsyFy5zcGFjZXN5bm'
    'MuT2JqZWN0RGVsZXRlSABSDG9iamVjdERlbGV0ZRI6CgtzcGFjZURlbGV0ZRgCIAEoCzIWLnNw'
    'YWNlc3luYy5TcGFjZURlbGV0ZUgAUgtzcGFjZURlbGV0ZUIHCgV2YWx1ZQ==');

@$core.Deprecated('Use objectDeleteDescriptor instead')
const ObjectDelete$json = {
  '1': 'ObjectDelete',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `ObjectDelete`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List objectDeleteDescriptor =
    $convert.base64Decode('CgxPYmplY3REZWxldGUSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use storeHeaderDescriptor instead')
const StoreHeader$json = {
  '1': 'StoreHeader',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'storageName', '3': 2, '4': 1, '5': 9, '10': 'storageName'},
  ],
};

/// Descriptor for `StoreHeader`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeHeaderDescriptor = $convert.base64Decode(
    'CgtTdG9yZUhlYWRlchIYCgdzcGFjZUlkGAEgASgJUgdzcGFjZUlkEiAKC3N0b3JhZ2VOYW1lGA'
    'IgASgJUgtzdG9yYWdlTmFtZQ==');

@$core.Deprecated('Use spaceDeleteDescriptor instead')
const SpaceDelete$json = {
  '1': 'SpaceDelete',
  '2': [
    {'1': 'deleterPeerId', '3': 1, '4': 1, '5': 9, '10': 'deleterPeerId'},
  ],
};

/// Descriptor for `SpaceDelete`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceDeleteDescriptor = $convert.base64Decode(
    'CgtTcGFjZURlbGV0ZRIkCg1kZWxldGVyUGVlcklkGAEgASgJUg1kZWxldGVyUGVlcklk');

@$core.Deprecated('Use spaceSettingsSnapshotDescriptor instead')
const SpaceSettingsSnapshot$json = {
  '1': 'SpaceSettingsSnapshot',
  '2': [
    {'1': 'deletedIds', '3': 1, '4': 3, '5': 9, '10': 'deletedIds'},
    {'1': 'deleterPeerId', '3': 2, '4': 1, '5': 9, '10': 'deleterPeerId'},
  ],
};

/// Descriptor for `SpaceSettingsSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceSettingsSnapshotDescriptor = $convert.base64Decode(
    'ChVTcGFjZVNldHRpbmdzU25hcHNob3QSHgoKZGVsZXRlZElkcxgBIAMoCVIKZGVsZXRlZElkcx'
    'IkCg1kZWxldGVyUGVlcklkGAIgASgJUg1kZWxldGVyUGVlcklk');

@$core.Deprecated('Use settingsDataDescriptor instead')
const SettingsData$json = {
  '1': 'SettingsData',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.spacesync.SpaceSettingsContent',
      '10': 'content'
    },
    {
      '1': 'snapshot',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.spacesync.SpaceSettingsSnapshot',
      '10': 'snapshot'
    },
  ],
};

/// Descriptor for `SettingsData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingsDataDescriptor = $convert.base64Decode(
    'CgxTZXR0aW5nc0RhdGESOQoHY29udGVudBgBIAMoCzIfLnNwYWNlc3luYy5TcGFjZVNldHRpbm'
    'dzQ29udGVudFIHY29udGVudBI8CghzbmFwc2hvdBgCIAEoCzIgLnNwYWNlc3luYy5TcGFjZVNl'
    'dHRpbmdzU25hcHNob3RSCHNuYXBzaG90');

@$core.Deprecated('Use spaceSubscriptionDescriptor instead')
const SpaceSubscription$json = {
  '1': 'SpaceSubscription',
  '2': [
    {'1': 'spaceIds', '3': 1, '4': 3, '5': 9, '10': 'spaceIds'},
    {
      '1': 'action',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.spacesync.SpaceSubscriptionAction',
      '10': 'action'
    },
  ],
};

/// Descriptor for `SpaceSubscription`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceSubscriptionDescriptor = $convert.base64Decode(
    'ChFTcGFjZVN1YnNjcmlwdGlvbhIaCghzcGFjZUlkcxgBIAMoCVIIc3BhY2VJZHMSOgoGYWN0aW'
    '9uGAIgASgOMiIuc3BhY2VzeW5jLlNwYWNlU3Vic2NyaXB0aW9uQWN0aW9uUgZhY3Rpb24=');

@$core.Deprecated('Use aclAddRecordRequestDescriptor instead')
const AclAddRecordRequest$json = {
  '1': 'AclAddRecordRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `AclAddRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAddRecordRequestDescriptor = $convert.base64Decode(
    'ChNBY2xBZGRSZWNvcmRSZXF1ZXN0EhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQSGAoHcGF5bG'
    '9hZBgCIAEoDFIHcGF5bG9hZA==');

@$core.Deprecated('Use aclAddRecordResponseDescriptor instead')
const AclAddRecordResponse$json = {
  '1': 'AclAddRecordResponse',
  '2': [
    {'1': 'recordId', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `AclAddRecordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAddRecordResponseDescriptor = $convert.base64Decode(
    'ChRBY2xBZGRSZWNvcmRSZXNwb25zZRIaCghyZWNvcmRJZBgBIAEoCVIIcmVjb3JkSWQSGAoHcG'
    'F5bG9hZBgCIAEoDFIHcGF5bG9hZA==');

@$core.Deprecated('Use aclGetRecordsRequestDescriptor instead')
const AclGetRecordsRequest$json = {
  '1': 'AclGetRecordsRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'aclHead', '3': 2, '4': 1, '5': 9, '10': 'aclHead'},
  ],
};

/// Descriptor for `AclGetRecordsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclGetRecordsRequestDescriptor = $convert.base64Decode(
    'ChRBY2xHZXRSZWNvcmRzUmVxdWVzdBIYCgdzcGFjZUlkGAEgASgJUgdzcGFjZUlkEhgKB2FjbE'
    'hlYWQYAiABKAlSB2FjbEhlYWQ=');

@$core.Deprecated('Use aclGetRecordsResponseDescriptor instead')
const AclGetRecordsResponse$json = {
  '1': 'AclGetRecordsResponse',
  '2': [
    {'1': 'records', '3': 1, '4': 3, '5': 12, '10': 'records'},
  ],
};

/// Descriptor for `AclGetRecordsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclGetRecordsResponseDescriptor =
    $convert.base64Decode(
        'ChVBY2xHZXRSZWNvcmRzUmVzcG9uc2USGAoHcmVjb3JkcxgBIAMoDFIHcmVjb3Jkcw==');

@$core.Deprecated('Use storeDiffRequestDescriptor instead')
const StoreDiffRequest$json = {
  '1': 'StoreDiffRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {
      '1': 'ranges',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.spacesync.HeadSyncRange',
      '10': 'ranges'
    },
  ],
};

/// Descriptor for `StoreDiffRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeDiffRequestDescriptor = $convert.base64Decode(
    'ChBTdG9yZURpZmZSZXF1ZXN0EhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQSMAoGcmFuZ2VzGA'
    'IgAygLMhguc3BhY2VzeW5jLkhlYWRTeW5jUmFuZ2VSBnJhbmdlcw==');

@$core.Deprecated('Use storeDiffResponseDescriptor instead')
const StoreDiffResponse$json = {
  '1': 'StoreDiffResponse',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.spacesync.HeadSyncResult',
      '10': 'results'
    },
  ],
};

/// Descriptor for `StoreDiffResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeDiffResponseDescriptor = $convert.base64Decode(
    'ChFTdG9yZURpZmZSZXNwb25zZRIzCgdyZXN1bHRzGAEgAygLMhkuc3BhY2VzeW5jLkhlYWRTeW'
    '5jUmVzdWx0UgdyZXN1bHRz');

@$core.Deprecated('Use storeKeyValueDescriptor instead')
const StoreKeyValue$json = {
  '1': 'StoreKeyValue',
  '2': [
    {'1': 'keyPeerId', '3': 1, '4': 1, '5': 9, '10': 'keyPeerId'},
    {'1': 'value', '3': 2, '4': 1, '5': 12, '10': 'value'},
    {
      '1': 'identitySignature',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'identitySignature'
    },
    {'1': 'peerSignature', '3': 4, '4': 1, '5': 12, '10': 'peerSignature'},
    {'1': 'spaceId', '3': 5, '4': 1, '5': 9, '10': 'spaceId'},
  ],
};

/// Descriptor for `StoreKeyValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeKeyValueDescriptor = $convert.base64Decode(
    'Cg1TdG9yZUtleVZhbHVlEhwKCWtleVBlZXJJZBgBIAEoCVIJa2V5UGVlcklkEhQKBXZhbHVlGA'
    'IgASgMUgV2YWx1ZRIsChFpZGVudGl0eVNpZ25hdHVyZRgDIAEoDFIRaWRlbnRpdHlTaWduYXR1'
    'cmUSJAoNcGVlclNpZ25hdHVyZRgEIAEoDFINcGVlclNpZ25hdHVyZRIYCgdzcGFjZUlkGAUgAS'
    'gJUgdzcGFjZUlk');

@$core.Deprecated('Use storeKeyValuesDescriptor instead')
const StoreKeyValues$json = {
  '1': 'StoreKeyValues',
  '2': [
    {
      '1': 'keyValues',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.spacesync.StoreKeyValue',
      '10': 'keyValues'
    },
  ],
};

/// Descriptor for `StoreKeyValues`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeKeyValuesDescriptor = $convert.base64Decode(
    'Cg5TdG9yZUtleVZhbHVlcxI2CglrZXlWYWx1ZXMYASADKAsyGC5zcGFjZXN5bmMuU3RvcmVLZX'
    'lWYWx1ZVIJa2V5VmFsdWVz');

@$core.Deprecated('Use storeKeyInnerDescriptor instead')
const StoreKeyInner$json = {
  '1': 'StoreKeyInner',
  '2': [
    {'1': 'peer', '3': 1, '4': 1, '5': 12, '10': 'peer'},
    {'1': 'identity', '3': 2, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'value', '3': 3, '4': 1, '5': 12, '10': 'value'},
    {'1': 'timestampMicro', '3': 4, '4': 1, '5': 3, '10': 'timestampMicro'},
    {'1': 'aclHeadId', '3': 5, '4': 1, '5': 9, '10': 'aclHeadId'},
    {'1': 'key', '3': 6, '4': 1, '5': 9, '10': 'key'},
  ],
};

/// Descriptor for `StoreKeyInner`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeKeyInnerDescriptor = $convert.base64Decode(
    'Cg1TdG9yZUtleUlubmVyEhIKBHBlZXIYASABKAxSBHBlZXISGgoIaWRlbnRpdHkYAiABKAxSCG'
    'lkZW50aXR5EhQKBXZhbHVlGAMgASgMUgV2YWx1ZRImCg50aW1lc3RhbXBNaWNybxgEIAEoA1IO'
    'dGltZXN0YW1wTWljcm8SHAoJYWNsSGVhZElkGAUgASgJUglhY2xIZWFkSWQSEAoDa2V5GAYgAS'
    'gJUgNrZXk=');

@$core.Deprecated('Use storageHeaderDescriptor instead')
const StorageHeader$json = {
  '1': 'StorageHeader',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'storageName', '3': 2, '4': 1, '5': 9, '10': 'storageName'},
  ],
};

/// Descriptor for `StorageHeader`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storageHeaderDescriptor = $convert.base64Decode(
    'Cg1TdG9yYWdlSGVhZGVyEhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQSIAoLc3RvcmFnZU5hbW'
    'UYAiABKAlSC3N0b3JhZ2VOYW1l');

const $core.Map<$core.String, $core.dynamic> SpaceSyncServiceBase$json = {
  '1': 'SpaceSync',
  '2': [
    {
      '1': 'HeadSync',
      '2': '.spacesync.HeadSyncRequest',
      '3': '.spacesync.HeadSyncResponse'
    },
    {
      '1': 'StoreDiff',
      '2': '.spacesync.StoreDiffRequest',
      '3': '.spacesync.StoreDiffResponse'
    },
    {
      '1': 'StoreElements',
      '2': '.spacesync.StoreKeyValue',
      '3': '.spacesync.StoreKeyValue',
      '5': true,
      '6': true
    },
    {
      '1': 'SpacePush',
      '2': '.spacesync.SpacePushRequest',
      '3': '.spacesync.SpacePushResponse'
    },
    {
      '1': 'SpacePull',
      '2': '.spacesync.SpacePullRequest',
      '3': '.spacesync.SpacePullResponse'
    },
    {
      '1': 'ObjectSyncStream',
      '2': '.spacesync.ObjectSyncMessage',
      '3': '.spacesync.ObjectSyncMessage',
      '5': true,
      '6': true
    },
    {
      '1': 'ObjectSync',
      '2': '.spacesync.ObjectSyncMessage',
      '3': '.spacesync.ObjectSyncMessage'
    },
    {
      '1': 'ObjectSyncRequestStream',
      '2': '.spacesync.ObjectSyncMessage',
      '3': '.spacesync.ObjectSyncMessage',
      '6': true
    },
    {
      '1': 'AclAddRecord',
      '2': '.spacesync.AclAddRecordRequest',
      '3': '.spacesync.AclAddRecordResponse'
    },
    {
      '1': 'AclGetRecords',
      '2': '.spacesync.AclGetRecordsRequest',
      '3': '.spacesync.AclGetRecordsResponse'
    },
  ],
};

@$core.Deprecated('Use spaceSyncServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SpaceSyncServiceBase$messageJson = {
  '.spacesync.HeadSyncRequest': HeadSyncRequest$json,
  '.spacesync.HeadSyncRange': HeadSyncRange$json,
  '.spacesync.HeadSyncResponse': HeadSyncResponse$json,
  '.spacesync.HeadSyncResult': HeadSyncResult$json,
  '.spacesync.HeadSyncResultElement': HeadSyncResultElement$json,
  '.spacesync.StoreDiffRequest': StoreDiffRequest$json,
  '.spacesync.StoreDiffResponse': StoreDiffResponse$json,
  '.spacesync.StoreKeyValue': StoreKeyValue$json,
  '.spacesync.SpacePushRequest': SpacePushRequest$json,
  '.spacesync.SpacePayload': SpacePayload$json,
  '.spacesync.RawSpaceHeaderWithId': RawSpaceHeaderWithId$json,
  '.spacesync.SpacePushResponse': SpacePushResponse$json,
  '.spacesync.SpacePullRequest': SpacePullRequest$json,
  '.spacesync.SpacePullResponse': SpacePullResponse$json,
  '.spacesync.AclRecord': AclRecord$json,
  '.spacesync.ObjectSyncMessage': ObjectSyncMessage$json,
  '.spacesync.AclAddRecordRequest': AclAddRecordRequest$json,
  '.spacesync.AclAddRecordResponse': AclAddRecordResponse$json,
  '.spacesync.AclGetRecordsRequest': AclGetRecordsRequest$json,
  '.spacesync.AclGetRecordsResponse': AclGetRecordsResponse$json,
};

/// Descriptor for `SpaceSync`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List spaceSyncServiceDescriptor = $convert.base64Decode(
    'CglTcGFjZVN5bmMSQwoISGVhZFN5bmMSGi5zcGFjZXN5bmMuSGVhZFN5bmNSZXF1ZXN0Ghsuc3'
    'BhY2VzeW5jLkhlYWRTeW5jUmVzcG9uc2USRgoJU3RvcmVEaWZmEhsuc3BhY2VzeW5jLlN0b3Jl'
    'RGlmZlJlcXVlc3QaHC5zcGFjZXN5bmMuU3RvcmVEaWZmUmVzcG9uc2USRwoNU3RvcmVFbGVtZW'
    '50cxIYLnNwYWNlc3luYy5TdG9yZUtleVZhbHVlGhguc3BhY2VzeW5jLlN0b3JlS2V5VmFsdWUo'
    'ATABEkYKCVNwYWNlUHVzaBIbLnNwYWNlc3luYy5TcGFjZVB1c2hSZXF1ZXN0Ghwuc3BhY2VzeW'
    '5jLlNwYWNlUHVzaFJlc3BvbnNlEkYKCVNwYWNlUHVsbBIbLnNwYWNlc3luYy5TcGFjZVB1bGxS'
    'ZXF1ZXN0Ghwuc3BhY2VzeW5jLlNwYWNlUHVsbFJlc3BvbnNlElIKEE9iamVjdFN5bmNTdHJlYW'
    '0SHC5zcGFjZXN5bmMuT2JqZWN0U3luY01lc3NhZ2UaHC5zcGFjZXN5bmMuT2JqZWN0U3luY01l'
    'c3NhZ2UoATABEkgKCk9iamVjdFN5bmMSHC5zcGFjZXN5bmMuT2JqZWN0U3luY01lc3NhZ2UaHC'
    '5zcGFjZXN5bmMuT2JqZWN0U3luY01lc3NhZ2USVwoXT2JqZWN0U3luY1JlcXVlc3RTdHJlYW0S'
    'HC5zcGFjZXN5bmMuT2JqZWN0U3luY01lc3NhZ2UaHC5zcGFjZXN5bmMuT2JqZWN0U3luY01lc3'
    'NhZ2UwARJPCgxBY2xBZGRSZWNvcmQSHi5zcGFjZXN5bmMuQWNsQWRkUmVjb3JkUmVxdWVzdBof'
    'LnNwYWNlc3luYy5BY2xBZGRSZWNvcmRSZXNwb25zZRJSCg1BY2xHZXRSZWNvcmRzEh8uc3BhY2'
    'VzeW5jLkFjbEdldFJlY29yZHNSZXF1ZXN0GiAuc3BhY2VzeW5jLkFjbEdldFJlY29yZHNSZXNw'
    'b25zZQ==');
