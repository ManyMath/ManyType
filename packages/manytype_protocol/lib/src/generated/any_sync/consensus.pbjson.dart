// This is a generated file - do not edit.
//
// Generated from any_sync/consensus.proto.

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
    {'1': 'LogExists', '2': 1},
    {'1': 'LogNotFound', '2': 2},
    {'1': 'RecordConflict', '2': 3},
    {'1': 'Forbidden', '2': 4},
    {'1': 'InvalidPayload', '2': 5},
    {'1': 'ErrorOffset', '2': 500},
  ],
};

/// Descriptor for `ErrCodes`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errCodesDescriptor = $convert.base64Decode(
    'CghFcnJDb2RlcxIOCgpVbmV4cGVjdGVkEAASDQoJTG9nRXhpc3RzEAESDwoLTG9nTm90Rm91bm'
    'QQAhISCg5SZWNvcmRDb25mbGljdBADEg0KCUZvcmJpZGRlbhAEEhIKDkludmFsaWRQYXlsb2Fk'
    'EAUSEAoLRXJyb3JPZmZzZXQQ9AM=');

@$core.Deprecated('Use logDescriptor instead')
const Log$json = {
  '1': 'Log',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'records',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.consensusProto.RawRecordWithId',
      '10': 'records'
    },
  ],
};

/// Descriptor for `Log`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logDescriptor = $convert.base64Decode(
    'CgNMb2cSDgoCaWQYASABKAlSAmlkEjkKB3JlY29yZHMYAyADKAsyHy5jb25zZW5zdXNQcm90by'
    '5SYXdSZWNvcmRXaXRoSWRSB3JlY29yZHM=');

@$core.Deprecated('Use rawRecordDescriptor instead')
const RawRecord$json = {
  '1': 'RawRecord',
  '2': [
    {'1': 'payload', '3': 1, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'signature', '3': 2, '4': 1, '5': 12, '10': 'signature'},
    {
      '1': 'acceptorIdentity',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'acceptorIdentity'
    },
    {
      '1': 'acceptorSignature',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'acceptorSignature'
    },
    {
      '1': 'acceptorTimestamp',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'acceptorTimestamp'
    },
  ],
};

/// Descriptor for `RawRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rawRecordDescriptor = $convert.base64Decode(
    'CglSYXdSZWNvcmQSGAoHcGF5bG9hZBgBIAEoDFIHcGF5bG9hZBIcCglzaWduYXR1cmUYAiABKA'
    'xSCXNpZ25hdHVyZRIqChBhY2NlcHRvcklkZW50aXR5GAMgASgMUhBhY2NlcHRvcklkZW50aXR5'
    'EiwKEWFjY2VwdG9yU2lnbmF0dXJlGAQgASgMUhFhY2NlcHRvclNpZ25hdHVyZRIsChFhY2NlcH'
    'RvclRpbWVzdGFtcBgFIAEoA1IRYWNjZXB0b3JUaW1lc3RhbXA=');

@$core.Deprecated('Use rawRecordWithIdDescriptor instead')
const RawRecordWithId$json = {
  '1': 'RawRecordWithId',
  '2': [
    {'1': 'payload', '3': 1, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `RawRecordWithId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rawRecordWithIdDescriptor = $convert.base64Decode(
    'Cg9SYXdSZWNvcmRXaXRoSWQSGAoHcGF5bG9hZBgBIAEoDFIHcGF5bG9hZBIOCgJpZBgCIAEoCV'
    'ICaWQ=');

@$core.Deprecated('Use recordDescriptor instead')
const Record$json = {
  '1': 'Record',
  '2': [
    {'1': 'prevId', '3': 1, '4': 1, '5': 9, '10': 'prevId'},
    {'1': 'identity', '3': 2, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `Record`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordDescriptor = $convert.base64Decode(
    'CgZSZWNvcmQSFgoGcHJldklkGAEgASgJUgZwcmV2SWQSGgoIaWRlbnRpdHkYAiABKAxSCGlkZW'
    '50aXR5EhIKBGRhdGEYAyABKAxSBGRhdGESHAoJdGltZXN0YW1wGAQgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use okDescriptor instead')
const Ok$json = {
  '1': 'Ok',
};

/// Descriptor for `Ok`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List okDescriptor = $convert.base64Decode('CgJPaw==');

@$core.Deprecated('Use logAddRequestDescriptor instead')
const LogAddRequest$json = {
  '1': 'LogAddRequest',
  '2': [
    {'1': 'logId', '3': 1, '4': 1, '5': 9, '10': 'logId'},
    {
      '1': 'record',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.consensusProto.RawRecordWithId',
      '10': 'record'
    },
  ],
};

/// Descriptor for `LogAddRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logAddRequestDescriptor = $convert.base64Decode(
    'Cg1Mb2dBZGRSZXF1ZXN0EhQKBWxvZ0lkGAEgASgJUgVsb2dJZBI3CgZyZWNvcmQYAiABKAsyHy'
    '5jb25zZW5zdXNQcm90by5SYXdSZWNvcmRXaXRoSWRSBnJlY29yZA==');

@$core.Deprecated('Use recordAddRequestDescriptor instead')
const RecordAddRequest$json = {
  '1': 'RecordAddRequest',
  '2': [
    {'1': 'logId', '3': 1, '4': 1, '5': 9, '10': 'logId'},
    {
      '1': 'record',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.consensusProto.RawRecord',
      '10': 'record'
    },
  ],
};

/// Descriptor for `RecordAddRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordAddRequestDescriptor = $convert.base64Decode(
    'ChBSZWNvcmRBZGRSZXF1ZXN0EhQKBWxvZ0lkGAEgASgJUgVsb2dJZBIxCgZyZWNvcmQYAiABKA'
    'syGS5jb25zZW5zdXNQcm90by5SYXdSZWNvcmRSBnJlY29yZA==');

@$core.Deprecated('Use logWatchRequestDescriptor instead')
const LogWatchRequest$json = {
  '1': 'LogWatchRequest',
  '2': [
    {'1': 'watchIds', '3': 1, '4': 3, '5': 9, '10': 'watchIds'},
    {'1': 'unwatchIds', '3': 2, '4': 3, '5': 9, '10': 'unwatchIds'},
  ],
};

/// Descriptor for `LogWatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logWatchRequestDescriptor = $convert.base64Decode(
    'Cg9Mb2dXYXRjaFJlcXVlc3QSGgoId2F0Y2hJZHMYASADKAlSCHdhdGNoSWRzEh4KCnVud2F0Y2'
    'hJZHMYAiADKAlSCnVud2F0Y2hJZHM=');

@$core.Deprecated('Use logWatchEventDescriptor instead')
const LogWatchEvent$json = {
  '1': 'LogWatchEvent',
  '2': [
    {'1': 'logId', '3': 1, '4': 1, '5': 9, '10': 'logId'},
    {
      '1': 'records',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.consensusProto.RawRecordWithId',
      '10': 'records'
    },
    {
      '1': 'error',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.consensusProto.Err',
      '10': 'error'
    },
  ],
};

/// Descriptor for `LogWatchEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logWatchEventDescriptor = $convert.base64Decode(
    'Cg1Mb2dXYXRjaEV2ZW50EhQKBWxvZ0lkGAEgASgJUgVsb2dJZBI5CgdyZWNvcmRzGAIgAygLMh'
    '8uY29uc2Vuc3VzUHJvdG8uUmF3UmVjb3JkV2l0aElkUgdyZWNvcmRzEikKBWVycm9yGAMgASgL'
    'MhMuY29uc2Vuc3VzUHJvdG8uRXJyUgVlcnJvcg==');

@$core.Deprecated('Use logDeleteRequestDescriptor instead')
const LogDeleteRequest$json = {
  '1': 'LogDeleteRequest',
  '2': [
    {'1': 'logId', '3': 1, '4': 1, '5': 9, '10': 'logId'},
  ],
};

/// Descriptor for `LogDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logDeleteRequestDescriptor = $convert
    .base64Decode('ChBMb2dEZWxldGVSZXF1ZXN0EhQKBWxvZ0lkGAEgASgJUgVsb2dJZA==');

@$core.Deprecated('Use errDescriptor instead')
const Err$json = {
  '1': 'Err',
  '2': [
    {
      '1': 'error',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.consensusProto.ErrCodes',
      '10': 'error'
    },
  ],
};

/// Descriptor for `Err`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errDescriptor = $convert.base64Decode(
    'CgNFcnISLgoFZXJyb3IYASABKA4yGC5jb25zZW5zdXNQcm90by5FcnJDb2Rlc1IFZXJyb3I=');

@$core.Deprecated('Use logSyncContentValueDescriptor instead')
const LogSyncContentValue$json = {
  '1': 'LogSyncContentValue',
  '2': [
    {
      '1': 'headUpdate',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.consensusProto.LogHeadUpdate',
      '9': 0,
      '10': 'headUpdate'
    },
    {
      '1': 'fullSyncRequest',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.consensusProto.LogFullSyncRequest',
      '9': 0,
      '10': 'fullSyncRequest'
    },
    {
      '1': 'fullSyncResponse',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.consensusProto.LogFullSyncResponse',
      '9': 0,
      '10': 'fullSyncResponse'
    },
  ],
  '8': [
    {'1': 'value'},
  ],
};

/// Descriptor for `LogSyncContentValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logSyncContentValueDescriptor = $convert.base64Decode(
    'ChNMb2dTeW5jQ29udGVudFZhbHVlEj8KCmhlYWRVcGRhdGUYASABKAsyHS5jb25zZW5zdXNQcm'
    '90by5Mb2dIZWFkVXBkYXRlSABSCmhlYWRVcGRhdGUSTgoPZnVsbFN5bmNSZXF1ZXN0GAIgASgL'
    'MiIuY29uc2Vuc3VzUHJvdG8uTG9nRnVsbFN5bmNSZXF1ZXN0SABSD2Z1bGxTeW5jUmVxdWVzdB'
    'JRChBmdWxsU3luY1Jlc3BvbnNlGAMgASgLMiMuY29uc2Vuc3VzUHJvdG8uTG9nRnVsbFN5bmNS'
    'ZXNwb25zZUgAUhBmdWxsU3luY1Jlc3BvbnNlQgcKBXZhbHVl');

@$core.Deprecated('Use logSyncMessageDescriptor instead')
const LogSyncMessage$json = {
  '1': 'LogSyncMessage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
    {
      '1': 'content',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.consensusProto.LogSyncContentValue',
      '10': 'content'
    },
  ],
};

/// Descriptor for `LogSyncMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logSyncMessageDescriptor = $convert.base64Decode(
    'Cg5Mb2dTeW5jTWVzc2FnZRIOCgJpZBgBIAEoCVICaWQSGAoHcGF5bG9hZBgCIAEoDFIHcGF5bG'
    '9hZBI9Cgdjb250ZW50GAMgASgLMiMuY29uc2Vuc3VzUHJvdG8uTG9nU3luY0NvbnRlbnRWYWx1'
    'ZVIHY29udGVudA==');

@$core.Deprecated('Use logHeadUpdateDescriptor instead')
const LogHeadUpdate$json = {
  '1': 'LogHeadUpdate',
  '2': [
    {'1': 'head', '3': 1, '4': 1, '5': 9, '10': 'head'},
    {
      '1': 'records',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.consensusProto.RawRecordWithId',
      '10': 'records'
    },
  ],
};

/// Descriptor for `LogHeadUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logHeadUpdateDescriptor = $convert.base64Decode(
    'Cg1Mb2dIZWFkVXBkYXRlEhIKBGhlYWQYASABKAlSBGhlYWQSOQoHcmVjb3JkcxgCIAMoCzIfLm'
    'NvbnNlbnN1c1Byb3RvLlJhd1JlY29yZFdpdGhJZFIHcmVjb3Jkcw==');

@$core.Deprecated('Use logFullSyncRequestDescriptor instead')
const LogFullSyncRequest$json = {
  '1': 'LogFullSyncRequest',
  '2': [
    {'1': 'head', '3': 1, '4': 1, '5': 9, '10': 'head'},
    {
      '1': 'records',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.consensusProto.RawRecordWithId',
      '10': 'records'
    },
  ],
};

/// Descriptor for `LogFullSyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logFullSyncRequestDescriptor = $convert.base64Decode(
    'ChJMb2dGdWxsU3luY1JlcXVlc3QSEgoEaGVhZBgBIAEoCVIEaGVhZBI5CgdyZWNvcmRzGAIgAy'
    'gLMh8uY29uc2Vuc3VzUHJvdG8uUmF3UmVjb3JkV2l0aElkUgdyZWNvcmRz');

@$core.Deprecated('Use logFullSyncResponseDescriptor instead')
const LogFullSyncResponse$json = {
  '1': 'LogFullSyncResponse',
  '2': [
    {'1': 'head', '3': 1, '4': 1, '5': 9, '10': 'head'},
    {
      '1': 'records',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.consensusProto.RawRecordWithId',
      '10': 'records'
    },
  ],
};

/// Descriptor for `LogFullSyncResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logFullSyncResponseDescriptor = $convert.base64Decode(
    'ChNMb2dGdWxsU3luY1Jlc3BvbnNlEhIKBGhlYWQYASABKAlSBGhlYWQSOQoHcmVjb3JkcxgCIA'
    'MoCzIfLmNvbnNlbnN1c1Byb3RvLlJhd1JlY29yZFdpdGhJZFIHcmVjb3Jkcw==');
