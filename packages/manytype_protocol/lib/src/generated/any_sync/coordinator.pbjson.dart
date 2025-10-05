// This is a generated file - do not edit.
//
// Generated from any_sync/coordinator.proto.

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

@$core.Deprecated('Use errorCodesDescriptor instead')
const ErrorCodes$json = {
  '1': 'ErrorCodes',
  '2': [
    {'1': 'Unexpected', '2': 0},
    {'1': 'SpaceDeleted', '2': 1},
    {'1': 'SpaceDeletionPending', '2': 2},
    {'1': 'SpaceCreated', '2': 3},
    {'1': 'SpaceNotExists', '2': 4},
    {'1': 'SpaceLimitReached', '2': 5},
    {'1': 'AccountDeleted', '2': 6},
    {'1': 'Forbidden', '2': 7},
    {'1': 'AclHeadIsMissing', '2': 8},
    {'1': 'AclNonEmpty', '2': 9},
    {'1': 'SpaceNotShareable', '2': 10},
    {'1': 'ErrorOffset', '2': 300},
  ],
};

/// Descriptor for `ErrorCodes`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorCodesDescriptor = $convert.base64Decode(
    'CgpFcnJvckNvZGVzEg4KClVuZXhwZWN0ZWQQABIQCgxTcGFjZURlbGV0ZWQQARIYChRTcGFjZU'
    'RlbGV0aW9uUGVuZGluZxACEhAKDFNwYWNlQ3JlYXRlZBADEhIKDlNwYWNlTm90RXhpc3RzEAQS'
    'FQoRU3BhY2VMaW1pdFJlYWNoZWQQBRISCg5BY2NvdW50RGVsZXRlZBAGEg0KCUZvcmJpZGRlbh'
    'AHEhQKEEFjbEhlYWRJc01pc3NpbmcQCBIPCgtBY2xOb25FbXB0eRAJEhUKEVNwYWNlTm90U2hh'
    'cmVhYmxlEAoSEAoLRXJyb3JPZmZzZXQQrAI=');

@$core.Deprecated('Use spaceStatusDescriptor instead')
const SpaceStatus$json = {
  '1': 'SpaceStatus',
  '2': [
    {'1': 'SpaceStatusCreated', '2': 0},
    {'1': 'SpaceStatusPendingDeletion', '2': 1},
    {'1': 'SpaceStatusDeletionStarted', '2': 2},
    {'1': 'SpaceStatusDeleted', '2': 3},
    {'1': 'SpaceStatusNotExists', '2': 4},
  ],
};

/// Descriptor for `SpaceStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spaceStatusDescriptor = $convert.base64Decode(
    'CgtTcGFjZVN0YXR1cxIWChJTcGFjZVN0YXR1c0NyZWF0ZWQQABIeChpTcGFjZVN0YXR1c1Blbm'
    'RpbmdEZWxldGlvbhABEh4KGlNwYWNlU3RhdHVzRGVsZXRpb25TdGFydGVkEAISFgoSU3BhY2VT'
    'dGF0dXNEZWxldGVkEAMSGAoUU3BhY2VTdGF0dXNOb3RFeGlzdHMQBA==');

@$core.Deprecated('Use spacePermissionsDescriptor instead')
const SpacePermissions$json = {
  '1': 'SpacePermissions',
  '2': [
    {'1': 'SpacePermissionsUnknown', '2': 0},
    {'1': 'SpacePermissionsOwner', '2': 1},
  ],
};

/// Descriptor for `SpacePermissions`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spacePermissionsDescriptor = $convert.base64Decode(
    'ChBTcGFjZVBlcm1pc3Npb25zEhsKF1NwYWNlUGVybWlzc2lvbnNVbmtub3duEAASGQoVU3BhY2'
    'VQZXJtaXNzaW9uc093bmVyEAE=');

@$core.Deprecated('Use nodeTypeDescriptor instead')
const NodeType$json = {
  '1': 'NodeType',
  '2': [
    {'1': 'TreeAPI', '2': 0},
    {'1': 'FileAPI', '2': 1},
    {'1': 'CoordinatorAPI', '2': 2},
    {'1': 'ConsensusAPI', '2': 3},
    {'1': 'NamingNodeAPI', '2': 4},
    {'1': 'PaymentProcessingAPI', '2': 5},
  ],
};

/// Descriptor for `NodeType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nodeTypeDescriptor = $convert.base64Decode(
    'CghOb2RlVHlwZRILCgdUcmVlQVBJEAASCwoHRmlsZUFQSRABEhIKDkNvb3JkaW5hdG9yQVBJEA'
    'ISEAoMQ29uc2Vuc3VzQVBJEAMSEQoNTmFtaW5nTm9kZUFQSRAEEhgKFFBheW1lbnRQcm9jZXNz'
    'aW5nQVBJEAU=');

@$core.Deprecated('Use deletionPayloadTypeDescriptor instead')
const DeletionPayloadType$json = {
  '1': 'DeletionPayloadType',
  '2': [
    {'1': 'Tree', '2': 0},
    {'1': 'Confirm', '2': 1},
    {'1': 'Account', '2': 2},
  ],
};

/// Descriptor for `DeletionPayloadType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deletionPayloadTypeDescriptor = $convert.base64Decode(
    'ChNEZWxldGlvblBheWxvYWRUeXBlEggKBFRyZWUQABILCgdDb25maXJtEAESCwoHQWNjb3VudB'
    'AC');

@$core.Deprecated('Use deletionLogRecordStatusDescriptor instead')
const DeletionLogRecordStatus$json = {
  '1': 'DeletionLogRecordStatus',
  '2': [
    {'1': 'Ok', '2': 0},
    {'1': 'RemovePrepare', '2': 1},
    {'1': 'Remove', '2': 2},
  ],
};

/// Descriptor for `DeletionLogRecordStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deletionLogRecordStatusDescriptor =
    $convert.base64Decode(
        'ChdEZWxldGlvbkxvZ1JlY29yZFN0YXR1cxIGCgJPaxAAEhEKDVJlbW92ZVByZXBhcmUQARIKCg'
        'ZSZW1vdmUQAg==');

@$core.Deprecated('Use aclEventLogRecordTypeDescriptor instead')
const AclEventLogRecordType$json = {
  '1': 'AclEventLogRecordType',
  '2': [
    {'1': 'RecordTypeSpaceReceipt', '2': 0},
    {'1': 'RecordTypeSpaceShared', '2': 1},
    {'1': 'RecordTypeSpaceUnshared', '2': 2},
    {'1': 'RecordTypeSpaceAclAddRecord', '2': 3},
  ],
};

/// Descriptor for `AclEventLogRecordType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List aclEventLogRecordTypeDescriptor = $convert.base64Decode(
    'ChVBY2xFdmVudExvZ1JlY29yZFR5cGUSGgoWUmVjb3JkVHlwZVNwYWNlUmVjZWlwdBAAEhkKFV'
    'JlY29yZFR5cGVTcGFjZVNoYXJlZBABEhsKF1JlY29yZFR5cGVTcGFjZVVuc2hhcmVkEAISHwob'
    'UmVjb3JkVHlwZVNwYWNlQWNsQWRkUmVjb3JkEAM=');

@$core.Deprecated('Use spaceSignRequestDescriptor instead')
const SpaceSignRequest$json = {
  '1': 'SpaceSignRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'header', '3': 2, '4': 1, '5': 12, '10': 'header'},
    {'1': 'oldIdentity', '3': 3, '4': 1, '5': 12, '10': 'oldIdentity'},
    {
      '1': 'newIdentitySignature',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'newIdentitySignature'
    },
    {'1': 'forceRequest', '3': 5, '4': 1, '5': 8, '10': 'forceRequest'},
  ],
};

/// Descriptor for `SpaceSignRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceSignRequestDescriptor = $convert.base64Decode(
    'ChBTcGFjZVNpZ25SZXF1ZXN0EhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQSFgoGaGVhZGVyGA'
    'IgASgMUgZoZWFkZXISIAoLb2xkSWRlbnRpdHkYAyABKAxSC29sZElkZW50aXR5EjIKFG5ld0lk'
    'ZW50aXR5U2lnbmF0dXJlGAQgASgMUhRuZXdJZGVudGl0eVNpZ25hdHVyZRIiCgxmb3JjZVJlcX'
    'Vlc3QYBSABKAhSDGZvcmNlUmVxdWVzdA==');

@$core.Deprecated('Use spaceLimitsDescriptor instead')
const SpaceLimits$json = {
  '1': 'SpaceLimits',
  '2': [
    {'1': 'readMembers', '3': 1, '4': 1, '5': 13, '10': 'readMembers'},
    {'1': 'writeMembers', '3': 2, '4': 1, '5': 13, '10': 'writeMembers'},
  ],
};

/// Descriptor for `SpaceLimits`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceLimitsDescriptor = $convert.base64Decode(
    'CgtTcGFjZUxpbWl0cxIgCgtyZWFkTWVtYmVycxgBIAEoDVILcmVhZE1lbWJlcnMSIgoMd3JpdG'
    'VNZW1iZXJzGAIgASgNUgx3cml0ZU1lbWJlcnM=');

@$core.Deprecated('Use spaceStatusPayloadDescriptor instead')
const SpaceStatusPayload$json = {
  '1': 'SpaceStatusPayload',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.coordinator.SpaceStatus',
      '10': 'status'
    },
    {
      '1': 'deletionTimestamp',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'deletionTimestamp'
    },
    {
      '1': 'permissions',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.coordinator.SpacePermissions',
      '10': 'permissions'
    },
    {
      '1': 'limits',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.coordinator.SpaceLimits',
      '10': 'limits'
    },
    {'1': 'isShared', '3': 5, '4': 1, '5': 8, '10': 'isShared'},
  ],
};

/// Descriptor for `SpaceStatusPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceStatusPayloadDescriptor = $convert.base64Decode(
    'ChJTcGFjZVN0YXR1c1BheWxvYWQSMAoGc3RhdHVzGAEgASgOMhguY29vcmRpbmF0b3IuU3BhY2'
    'VTdGF0dXNSBnN0YXR1cxIsChFkZWxldGlvblRpbWVzdGFtcBgCIAEoA1IRZGVsZXRpb25UaW1l'
    'c3RhbXASPwoLcGVybWlzc2lvbnMYAyABKA4yHS5jb29yZGluYXRvci5TcGFjZVBlcm1pc3Npb2'
    '5zUgtwZXJtaXNzaW9ucxIwCgZsaW1pdHMYBCABKAsyGC5jb29yZGluYXRvci5TcGFjZUxpbWl0'
    'c1IGbGltaXRzEhoKCGlzU2hhcmVkGAUgASgIUghpc1NoYXJlZA==');

@$core.Deprecated('Use spaceSignResponseDescriptor instead')
const SpaceSignResponse$json = {
  '1': 'SpaceSignResponse',
  '2': [
    {
      '1': 'receipt',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.coordinator.SpaceReceiptWithSignature',
      '10': 'receipt'
    },
  ],
};

/// Descriptor for `SpaceSignResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceSignResponseDescriptor = $convert.base64Decode(
    'ChFTcGFjZVNpZ25SZXNwb25zZRJACgdyZWNlaXB0GAEgASgLMiYuY29vcmRpbmF0b3IuU3BhY2'
    'VSZWNlaXB0V2l0aFNpZ25hdHVyZVIHcmVjZWlwdA==');

@$core.Deprecated('Use spaceReceiptWithSignatureDescriptor instead')
const SpaceReceiptWithSignature$json = {
  '1': 'SpaceReceiptWithSignature',
  '2': [
    {
      '1': 'spaceReceiptPayload',
      '3': 1,
      '4': 1,
      '5': 12,
      '10': 'spaceReceiptPayload'
    },
    {'1': 'signature', '3': 2, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `SpaceReceiptWithSignature`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceReceiptWithSignatureDescriptor =
    $convert.base64Decode(
        'ChlTcGFjZVJlY2VpcHRXaXRoU2lnbmF0dXJlEjAKE3NwYWNlUmVjZWlwdFBheWxvYWQYASABKA'
        'xSE3NwYWNlUmVjZWlwdFBheWxvYWQSHAoJc2lnbmF0dXJlGAIgASgMUglzaWduYXR1cmU=');

@$core.Deprecated('Use spaceReceiptDescriptor instead')
const SpaceReceipt$json = {
  '1': 'SpaceReceipt',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'peerId', '3': 2, '4': 1, '5': 9, '10': 'peerId'},
    {'1': 'accountIdentity', '3': 3, '4': 1, '5': 12, '10': 'accountIdentity'},
    {'1': 'networkId', '3': 4, '4': 1, '5': 9, '10': 'networkId'},
    {'1': 'validUntil', '3': 5, '4': 1, '5': 4, '10': 'validUntil'},
  ],
};

/// Descriptor for `SpaceReceipt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceReceiptDescriptor = $convert.base64Decode(
    'CgxTcGFjZVJlY2VpcHQSGAoHc3BhY2VJZBgBIAEoCVIHc3BhY2VJZBIWCgZwZWVySWQYAiABKA'
    'lSBnBlZXJJZBIoCg9hY2NvdW50SWRlbnRpdHkYAyABKAxSD2FjY291bnRJZGVudGl0eRIcCglu'
    'ZXR3b3JrSWQYBCABKAlSCW5ldHdvcmtJZBIeCgp2YWxpZFVudGlsGAUgASgEUgp2YWxpZFVudG'
    'ls');

@$core.Deprecated('Use spaceStatusCheckRequestDescriptor instead')
const SpaceStatusCheckRequest$json = {
  '1': 'SpaceStatusCheckRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
  ],
};

/// Descriptor for `SpaceStatusCheckRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceStatusCheckRequestDescriptor =
    $convert.base64Decode(
        'ChdTcGFjZVN0YXR1c0NoZWNrUmVxdWVzdBIYCgdzcGFjZUlkGAEgASgJUgdzcGFjZUlk');

@$core.Deprecated('Use spaceStatusCheckResponseDescriptor instead')
const SpaceStatusCheckResponse$json = {
  '1': 'SpaceStatusCheckResponse',
  '2': [
    {
      '1': 'payload',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.coordinator.SpaceStatusPayload',
      '10': 'payload'
    },
  ],
};

/// Descriptor for `SpaceStatusCheckResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceStatusCheckResponseDescriptor =
    $convert.base64Decode(
        'ChhTcGFjZVN0YXR1c0NoZWNrUmVzcG9uc2USOQoHcGF5bG9hZBgBIAEoCzIfLmNvb3JkaW5hdG'
        '9yLlNwYWNlU3RhdHVzUGF5bG9hZFIHcGF5bG9hZA==');

@$core.Deprecated('Use spaceStatusCheckManyRequestDescriptor instead')
const SpaceStatusCheckManyRequest$json = {
  '1': 'SpaceStatusCheckManyRequest',
  '2': [
    {'1': 'spaceIds', '3': 1, '4': 3, '5': 9, '10': 'spaceIds'},
  ],
};

/// Descriptor for `SpaceStatusCheckManyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceStatusCheckManyRequestDescriptor =
    $convert.base64Decode(
        'ChtTcGFjZVN0YXR1c0NoZWNrTWFueVJlcXVlc3QSGgoIc3BhY2VJZHMYASADKAlSCHNwYWNlSW'
        'Rz');

@$core.Deprecated('Use spaceStatusCheckManyResponseDescriptor instead')
const SpaceStatusCheckManyResponse$json = {
  '1': 'SpaceStatusCheckManyResponse',
  '2': [
    {
      '1': 'payloads',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.coordinator.SpaceStatusPayload',
      '10': 'payloads'
    },
    {
      '1': 'accountLimits',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.coordinator.AccountLimits',
      '10': 'accountLimits'
    },
  ],
};

/// Descriptor for `SpaceStatusCheckManyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceStatusCheckManyResponseDescriptor =
    $convert.base64Decode(
        'ChxTcGFjZVN0YXR1c0NoZWNrTWFueVJlc3BvbnNlEjsKCHBheWxvYWRzGAEgAygLMh8uY29vcm'
        'RpbmF0b3IuU3BhY2VTdGF0dXNQYXlsb2FkUghwYXlsb2FkcxJACg1hY2NvdW50TGltaXRzGAIg'
        'ASgLMhouY29vcmRpbmF0b3IuQWNjb3VudExpbWl0c1INYWNjb3VudExpbWl0cw==');

@$core.Deprecated('Use accountLimitsDescriptor instead')
const AccountLimits$json = {
  '1': 'AccountLimits',
  '2': [
    {
      '1': 'sharedSpacesLimit',
      '3': 1,
      '4': 1,
      '5': 13,
      '10': 'sharedSpacesLimit'
    },
  ],
};

/// Descriptor for `AccountLimits`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountLimitsDescriptor = $convert.base64Decode(
    'Cg1BY2NvdW50TGltaXRzEiwKEXNoYXJlZFNwYWNlc0xpbWl0GAEgASgNUhFzaGFyZWRTcGFjZX'
    'NMaW1pdA==');

@$core.Deprecated('Use spaceStatusChangeRequestDescriptor instead')
const SpaceStatusChangeRequest$json = {
  '1': 'SpaceStatusChangeRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {
      '1': 'deletionPayloadId',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'deletionPayloadId'
    },
    {'1': 'deletionPayload', '3': 3, '4': 1, '5': 12, '10': 'deletionPayload'},
    {
      '1': 'deletionPayloadType',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.coordinator.DeletionPayloadType',
      '10': 'deletionPayloadType'
    },
  ],
};

/// Descriptor for `SpaceStatusChangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceStatusChangeRequestDescriptor = $convert.base64Decode(
    'ChhTcGFjZVN0YXR1c0NoYW5nZVJlcXVlc3QSGAoHc3BhY2VJZBgBIAEoCVIHc3BhY2VJZBIsCh'
    'FkZWxldGlvblBheWxvYWRJZBgCIAEoCVIRZGVsZXRpb25QYXlsb2FkSWQSKAoPZGVsZXRpb25Q'
    'YXlsb2FkGAMgASgMUg9kZWxldGlvblBheWxvYWQSUgoTZGVsZXRpb25QYXlsb2FkVHlwZRgEIA'
    'EoDjIgLmNvb3JkaW5hdG9yLkRlbGV0aW9uUGF5bG9hZFR5cGVSE2RlbGV0aW9uUGF5bG9hZFR5'
    'cGU=');

@$core.Deprecated('Use spaceStatusChangeResponseDescriptor instead')
const SpaceStatusChangeResponse$json = {
  '1': 'SpaceStatusChangeResponse',
  '2': [
    {
      '1': 'payload',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.coordinator.SpaceStatusPayload',
      '10': 'payload'
    },
  ],
};

/// Descriptor for `SpaceStatusChangeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceStatusChangeResponseDescriptor =
    $convert.base64Decode(
        'ChlTcGFjZVN0YXR1c0NoYW5nZVJlc3BvbnNlEjkKB3BheWxvYWQYASABKAsyHy5jb29yZGluYX'
        'Rvci5TcGFjZVN0YXR1c1BheWxvYWRSB3BheWxvYWQ=');

@$core.Deprecated('Use spaceMakeShareableRequestDescriptor instead')
const SpaceMakeShareableRequest$json = {
  '1': 'SpaceMakeShareableRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
  ],
};

/// Descriptor for `SpaceMakeShareableRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceMakeShareableRequestDescriptor =
    $convert.base64Decode(
        'ChlTcGFjZU1ha2VTaGFyZWFibGVSZXF1ZXN0EhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQ=');

@$core.Deprecated('Use spaceMakeShareableResponseDescriptor instead')
const SpaceMakeShareableResponse$json = {
  '1': 'SpaceMakeShareableResponse',
};

/// Descriptor for `SpaceMakeShareableResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceMakeShareableResponseDescriptor =
    $convert.base64Decode('ChpTcGFjZU1ha2VTaGFyZWFibGVSZXNwb25zZQ==');

@$core.Deprecated('Use spaceMakeUnshareableRequestDescriptor instead')
const SpaceMakeUnshareableRequest$json = {
  '1': 'SpaceMakeUnshareableRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'aclHead', '3': 2, '4': 1, '5': 9, '10': 'aclHead'},
  ],
};

/// Descriptor for `SpaceMakeUnshareableRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceMakeUnshareableRequestDescriptor =
    $convert.base64Decode(
        'ChtTcGFjZU1ha2VVbnNoYXJlYWJsZVJlcXVlc3QSGAoHc3BhY2VJZBgBIAEoCVIHc3BhY2VJZB'
        'IYCgdhY2xIZWFkGAIgASgJUgdhY2xIZWFk');

@$core.Deprecated('Use spaceMakeUnshareableResponseDescriptor instead')
const SpaceMakeUnshareableResponse$json = {
  '1': 'SpaceMakeUnshareableResponse',
};

/// Descriptor for `SpaceMakeUnshareableResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceMakeUnshareableResponseDescriptor =
    $convert.base64Decode('ChxTcGFjZU1ha2VVbnNoYXJlYWJsZVJlc3BvbnNl');

@$core.Deprecated('Use networkConfigurationRequestDescriptor instead')
const NetworkConfigurationRequest$json = {
  '1': 'NetworkConfigurationRequest',
  '2': [
    {'1': 'currentId', '3': 1, '4': 1, '5': 9, '10': 'currentId'},
  ],
};

/// Descriptor for `NetworkConfigurationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkConfigurationRequestDescriptor =
    $convert.base64Decode(
        'ChtOZXR3b3JrQ29uZmlndXJhdGlvblJlcXVlc3QSHAoJY3VycmVudElkGAEgASgJUgljdXJyZW'
        '50SWQ=');

@$core.Deprecated('Use networkConfigurationResponseDescriptor instead')
const NetworkConfigurationResponse$json = {
  '1': 'NetworkConfigurationResponse',
  '2': [
    {'1': 'configurationId', '3': 1, '4': 1, '5': 9, '10': 'configurationId'},
    {'1': 'networkId', '3': 2, '4': 1, '5': 9, '10': 'networkId'},
    {
      '1': 'nodes',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.coordinator.Node',
      '10': 'nodes'
    },
    {'1': 'creationTimeUnix', '3': 4, '4': 1, '5': 4, '10': 'creationTimeUnix'},
  ],
};

/// Descriptor for `NetworkConfigurationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkConfigurationResponseDescriptor = $convert.base64Decode(
    'ChxOZXR3b3JrQ29uZmlndXJhdGlvblJlc3BvbnNlEigKD2NvbmZpZ3VyYXRpb25JZBgBIAEoCV'
    'IPY29uZmlndXJhdGlvbklkEhwKCW5ldHdvcmtJZBgCIAEoCVIJbmV0d29ya0lkEicKBW5vZGVz'
    'GAMgAygLMhEuY29vcmRpbmF0b3IuTm9kZVIFbm9kZXMSKgoQY3JlYXRpb25UaW1lVW5peBgEIA'
    'EoBFIQY3JlYXRpb25UaW1lVW5peA==');

@$core.Deprecated('Use nodeDescriptor instead')
const Node$json = {
  '1': 'Node',
  '2': [
    {'1': 'peerId', '3': 1, '4': 1, '5': 9, '10': 'peerId'},
    {'1': 'addresses', '3': 2, '4': 3, '5': 9, '10': 'addresses'},
    {
      '1': 'types',
      '3': 3,
      '4': 3,
      '5': 14,
      '6': '.coordinator.NodeType',
      '10': 'types'
    },
  ],
};

/// Descriptor for `Node`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeDescriptor = $convert.base64Decode(
    'CgROb2RlEhYKBnBlZXJJZBgBIAEoCVIGcGVlcklkEhwKCWFkZHJlc3NlcxgCIAMoCVIJYWRkcm'
    'Vzc2VzEisKBXR5cGVzGAMgAygOMhUuY29vcmRpbmF0b3IuTm9kZVR5cGVSBXR5cGVz');

@$core.Deprecated('Use deletionConfirmPayloadWithSignatureDescriptor instead')
const DeletionConfirmPayloadWithSignature$json = {
  '1': 'DeletionConfirmPayloadWithSignature',
  '2': [
    {'1': 'deletionPayload', '3': 1, '4': 1, '5': 12, '10': 'deletionPayload'},
    {'1': 'signature', '3': 2, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `DeletionConfirmPayloadWithSignature`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deletionConfirmPayloadWithSignatureDescriptor =
    $convert.base64Decode(
        'CiNEZWxldGlvbkNvbmZpcm1QYXlsb2FkV2l0aFNpZ25hdHVyZRIoCg9kZWxldGlvblBheWxvYW'
        'QYASABKAxSD2RlbGV0aW9uUGF5bG9hZBIcCglzaWduYXR1cmUYAiABKAxSCXNpZ25hdHVyZQ==');

@$core.Deprecated('Use deletionConfirmPayloadDescriptor instead')
const DeletionConfirmPayload$json = {
  '1': 'DeletionConfirmPayload',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'peerId', '3': 2, '4': 1, '5': 9, '10': 'peerId'},
    {'1': 'accountIdentity', '3': 3, '4': 1, '5': 12, '10': 'accountIdentity'},
    {'1': 'networkId', '3': 4, '4': 1, '5': 9, '10': 'networkId'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `DeletionConfirmPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deletionConfirmPayloadDescriptor = $convert.base64Decode(
    'ChZEZWxldGlvbkNvbmZpcm1QYXlsb2FkEhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQSFgoGcG'
    'VlcklkGAIgASgJUgZwZWVySWQSKAoPYWNjb3VudElkZW50aXR5GAMgASgMUg9hY2NvdW50SWRl'
    'bnRpdHkSHAoJbmV0d29ya0lkGAQgASgJUgluZXR3b3JrSWQSHAoJdGltZXN0YW1wGAUgASgDUg'
    'l0aW1lc3RhbXA=');

@$core.Deprecated('Use deletionLogRequestDescriptor instead')
const DeletionLogRequest$json = {
  '1': 'DeletionLogRequest',
  '2': [
    {'1': 'afterId', '3': 1, '4': 1, '5': 9, '10': 'afterId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 13, '10': 'limit'},
  ],
};

/// Descriptor for `DeletionLogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deletionLogRequestDescriptor = $convert.base64Decode(
    'ChJEZWxldGlvbkxvZ1JlcXVlc3QSGAoHYWZ0ZXJJZBgBIAEoCVIHYWZ0ZXJJZBIUCgVsaW1pdB'
    'gCIAEoDVIFbGltaXQ=');

@$core.Deprecated('Use deletionLogResponseDescriptor instead')
const DeletionLogResponse$json = {
  '1': 'DeletionLogResponse',
  '2': [
    {
      '1': 'records',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.coordinator.DeletionLogRecord',
      '10': 'records'
    },
    {'1': 'hasMore', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `DeletionLogResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deletionLogResponseDescriptor = $convert.base64Decode(
    'ChNEZWxldGlvbkxvZ1Jlc3BvbnNlEjgKB3JlY29yZHMYASADKAsyHi5jb29yZGluYXRvci5EZW'
    'xldGlvbkxvZ1JlY29yZFIHcmVjb3JkcxIYCgdoYXNNb3JlGAIgASgIUgdoYXNNb3Jl');

@$core.Deprecated('Use deletionLogRecordDescriptor instead')
const DeletionLogRecord$json = {
  '1': 'DeletionLogRecord',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'spaceId', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.coordinator.DeletionLogRecordStatus',
      '10': 'status'
    },
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'fileGroup', '3': 5, '4': 1, '5': 9, '10': 'fileGroup'},
  ],
};

/// Descriptor for `DeletionLogRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deletionLogRecordDescriptor = $convert.base64Decode(
    'ChFEZWxldGlvbkxvZ1JlY29yZBIOCgJpZBgBIAEoCVICaWQSGAoHc3BhY2VJZBgCIAEoCVIHc3'
    'BhY2VJZBI8CgZzdGF0dXMYAyABKA4yJC5jb29yZGluYXRvci5EZWxldGlvbkxvZ1JlY29yZFN0'
    'YXR1c1IGc3RhdHVzEhwKCXRpbWVzdGFtcBgEIAEoA1IJdGltZXN0YW1wEhwKCWZpbGVHcm91cB'
    'gFIAEoCVIJZmlsZUdyb3Vw');

@$core.Deprecated('Use spaceDeleteRequestDescriptor instead')
const SpaceDeleteRequest$json = {
  '1': 'SpaceDeleteRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {
      '1': 'deletionPayloadId',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'deletionPayloadId'
    },
    {'1': 'deletionPayload', '3': 3, '4': 1, '5': 12, '10': 'deletionPayload'},
    {'1': 'deletionDuration', '3': 4, '4': 1, '5': 3, '10': 'deletionDuration'},
  ],
};

/// Descriptor for `SpaceDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceDeleteRequestDescriptor = $convert.base64Decode(
    'ChJTcGFjZURlbGV0ZVJlcXVlc3QSGAoHc3BhY2VJZBgBIAEoCVIHc3BhY2VJZBIsChFkZWxldG'
    'lvblBheWxvYWRJZBgCIAEoCVIRZGVsZXRpb25QYXlsb2FkSWQSKAoPZGVsZXRpb25QYXlsb2Fk'
    'GAMgASgMUg9kZWxldGlvblBheWxvYWQSKgoQZGVsZXRpb25EdXJhdGlvbhgEIAEoA1IQZGVsZX'
    'Rpb25EdXJhdGlvbg==');

@$core.Deprecated('Use spaceDeleteResponseDescriptor instead')
const SpaceDeleteResponse$json = {
  '1': 'SpaceDeleteResponse',
  '2': [
    {
      '1': 'toBeDeletedTimestamp',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'toBeDeletedTimestamp'
    },
  ],
};

/// Descriptor for `SpaceDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceDeleteResponseDescriptor = $convert.base64Decode(
    'ChNTcGFjZURlbGV0ZVJlc3BvbnNlEjIKFHRvQmVEZWxldGVkVGltZXN0YW1wGAEgASgDUhR0b0'
    'JlRGVsZXRlZFRpbWVzdGFtcA==');

@$core.Deprecated('Use accountDeleteRequestDescriptor instead')
const AccountDeleteRequest$json = {
  '1': 'AccountDeleteRequest',
  '2': [
    {
      '1': 'deletionPayloadId',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'deletionPayloadId'
    },
    {'1': 'deletionPayload', '3': 2, '4': 1, '5': 12, '10': 'deletionPayload'},
  ],
};

/// Descriptor for `AccountDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDeleteRequestDescriptor = $convert.base64Decode(
    'ChRBY2NvdW50RGVsZXRlUmVxdWVzdBIsChFkZWxldGlvblBheWxvYWRJZBgBIAEoCVIRZGVsZX'
    'Rpb25QYXlsb2FkSWQSKAoPZGVsZXRpb25QYXlsb2FkGAIgASgMUg9kZWxldGlvblBheWxvYWQ=');

@$core.Deprecated('Use accountDeletionConfirmPayloadDescriptor instead')
const AccountDeletionConfirmPayload$json = {
  '1': 'AccountDeletionConfirmPayload',
  '2': [
    {'1': 'peerId', '3': 1, '4': 1, '5': 9, '10': 'peerId'},
    {'1': 'accountIdentity', '3': 2, '4': 1, '5': 12, '10': 'accountIdentity'},
    {'1': 'networkId', '3': 3, '4': 1, '5': 9, '10': 'networkId'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `AccountDeletionConfirmPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDeletionConfirmPayloadDescriptor =
    $convert.base64Decode(
        'Ch1BY2NvdW50RGVsZXRpb25Db25maXJtUGF5bG9hZBIWCgZwZWVySWQYASABKAlSBnBlZXJJZB'
        'IoCg9hY2NvdW50SWRlbnRpdHkYAiABKAxSD2FjY291bnRJZGVudGl0eRIcCgluZXR3b3JrSWQY'
        'AyABKAlSCW5ldHdvcmtJZBIcCgl0aW1lc3RhbXAYBCABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use accountDeleteResponseDescriptor instead')
const AccountDeleteResponse$json = {
  '1': 'AccountDeleteResponse',
  '2': [
    {
      '1': 'toBeDeletedTimestamp',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'toBeDeletedTimestamp'
    },
  ],
};

/// Descriptor for `AccountDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDeleteResponseDescriptor = $convert.base64Decode(
    'ChVBY2NvdW50RGVsZXRlUmVzcG9uc2USMgoUdG9CZURlbGV0ZWRUaW1lc3RhbXAYASABKANSFH'
    'RvQmVEZWxldGVkVGltZXN0YW1w');

@$core.Deprecated('Use accountRevertDeletionRequestDescriptor instead')
const AccountRevertDeletionRequest$json = {
  '1': 'AccountRevertDeletionRequest',
};

/// Descriptor for `AccountRevertDeletionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountRevertDeletionRequestDescriptor =
    $convert.base64Decode('ChxBY2NvdW50UmV2ZXJ0RGVsZXRpb25SZXF1ZXN0');

@$core.Deprecated('Use accountRevertDeletionResponseDescriptor instead')
const AccountRevertDeletionResponse$json = {
  '1': 'AccountRevertDeletionResponse',
};

/// Descriptor for `AccountRevertDeletionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountRevertDeletionResponseDescriptor =
    $convert.base64Decode('Ch1BY2NvdW50UmV2ZXJ0RGVsZXRpb25SZXNwb25zZQ==');

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

@$core.Deprecated('Use accountLimitsSetRequestDescriptor instead')
const AccountLimitsSetRequest$json = {
  '1': 'AccountLimitsSetRequest',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 9, '10': 'identity'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
    {
      '1': 'fileStorageLimitBytes',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'fileStorageLimitBytes'
    },
    {
      '1': 'spaceMembersRead',
      '3': 4,
      '4': 1,
      '5': 13,
      '10': 'spaceMembersRead'
    },
    {
      '1': 'spaceMembersWrite',
      '3': 5,
      '4': 1,
      '5': 13,
      '10': 'spaceMembersWrite'
    },
    {
      '1': 'sharedSpacesLimit',
      '3': 6,
      '4': 1,
      '5': 13,
      '10': 'sharedSpacesLimit'
    },
  ],
};

/// Descriptor for `AccountLimitsSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountLimitsSetRequestDescriptor = $convert.base64Decode(
    'ChdBY2NvdW50TGltaXRzU2V0UmVxdWVzdBIaCghpZGVudGl0eRgBIAEoCVIIaWRlbnRpdHkSFg'
    'oGcmVhc29uGAIgASgJUgZyZWFzb24SNAoVZmlsZVN0b3JhZ2VMaW1pdEJ5dGVzGAMgASgEUhVm'
    'aWxlU3RvcmFnZUxpbWl0Qnl0ZXMSKgoQc3BhY2VNZW1iZXJzUmVhZBgEIAEoDVIQc3BhY2VNZW'
    '1iZXJzUmVhZBIsChFzcGFjZU1lbWJlcnNXcml0ZRgFIAEoDVIRc3BhY2VNZW1iZXJzV3JpdGUS'
    'LAoRc2hhcmVkU3BhY2VzTGltaXQYBiABKA1SEXNoYXJlZFNwYWNlc0xpbWl0');

@$core.Deprecated('Use accountLimitsSetResponseDescriptor instead')
const AccountLimitsSetResponse$json = {
  '1': 'AccountLimitsSetResponse',
};

/// Descriptor for `AccountLimitsSetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountLimitsSetResponseDescriptor =
    $convert.base64Decode('ChhBY2NvdW50TGltaXRzU2V0UmVzcG9uc2U=');

@$core.Deprecated('Use aclEventLogRequestDescriptor instead')
const AclEventLogRequest$json = {
  '1': 'AclEventLogRequest',
  '2': [
    {'1': 'accountIdentity', '3': 1, '4': 1, '5': 9, '10': 'accountIdentity'},
    {'1': 'afterId', '3': 2, '4': 1, '5': 9, '10': 'afterId'},
    {'1': 'limit', '3': 3, '4': 1, '5': 13, '10': 'limit'},
  ],
};

/// Descriptor for `AclEventLogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclEventLogRequestDescriptor = $convert.base64Decode(
    'ChJBY2xFdmVudExvZ1JlcXVlc3QSKAoPYWNjb3VudElkZW50aXR5GAEgASgJUg9hY2NvdW50SW'
    'RlbnRpdHkSGAoHYWZ0ZXJJZBgCIAEoCVIHYWZ0ZXJJZBIUCgVsaW1pdBgDIAEoDVIFbGltaXQ=');

@$core.Deprecated('Use aclEventLogResponseDescriptor instead')
const AclEventLogResponse$json = {
  '1': 'AclEventLogResponse',
  '2': [
    {
      '1': 'records',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.coordinator.AclEventLogRecord',
      '10': 'records'
    },
    {'1': 'hasMore', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `AclEventLogResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclEventLogResponseDescriptor = $convert.base64Decode(
    'ChNBY2xFdmVudExvZ1Jlc3BvbnNlEjgKB3JlY29yZHMYASADKAsyHi5jb29yZGluYXRvci5BY2'
    'xFdmVudExvZ1JlY29yZFIHcmVjb3JkcxIYCgdoYXNNb3JlGAIgASgIUgdoYXNNb3Jl');

@$core.Deprecated('Use aclEventLogRecordDescriptor instead')
const AclEventLogRecord$json = {
  '1': 'AclEventLogRecord',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'spaceId', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.coordinator.AclEventLogRecordType',
      '10': 'type'
    },
    {'1': 'aclChangeId', '3': 5, '4': 1, '5': 9, '10': 'aclChangeId'},
  ],
};

/// Descriptor for `AclEventLogRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclEventLogRecordDescriptor = $convert.base64Decode(
    'ChFBY2xFdmVudExvZ1JlY29yZBIOCgJpZBgBIAEoCVICaWQSGAoHc3BhY2VJZBgCIAEoCVIHc3'
    'BhY2VJZBIcCgl0aW1lc3RhbXAYAyABKANSCXRpbWVzdGFtcBI2CgR0eXBlGAQgASgOMiIuY29v'
    'cmRpbmF0b3IuQWNsRXZlbnRMb2dSZWNvcmRUeXBlUgR0eXBlEiAKC2FjbENoYW5nZUlkGAUgAS'
    'gJUgthY2xDaGFuZ2VJZA==');

@$core.Deprecated('Use aclUploadInviteRequestDescriptor instead')
const AclUploadInviteRequest$json = {
  '1': 'AclUploadInviteRequest',
  '2': [
    {'1': 'cid', '3': 1, '4': 1, '5': 12, '10': 'cid'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `AclUploadInviteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclUploadInviteRequestDescriptor =
    $convert.base64Decode(
        'ChZBY2xVcGxvYWRJbnZpdGVSZXF1ZXN0EhAKA2NpZBgBIAEoDFIDY2lkEhIKBGRhdGEYAiABKA'
        'xSBGRhdGE=');

@$core.Deprecated('Use aclUploadInviteResponseDescriptor instead')
const AclUploadInviteResponse$json = {
  '1': 'AclUploadInviteResponse',
};

/// Descriptor for `AclUploadInviteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclUploadInviteResponseDescriptor =
    $convert.base64Decode('ChdBY2xVcGxvYWRJbnZpdGVSZXNwb25zZQ==');
