// This is a generated file - do not edit.
//
// Generated from any_sync/file.proto.

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
    {'1': 'CIDNotFound', '2': 1},
    {'1': 'Forbidden', '2': 2},
    {'1': 'LimitExceeded', '2': 3},
    {'1': 'QuerySizeExceeded', '2': 4},
    {'1': 'WrongHash', '2': 5},
    {'1': 'NotEnoughSpace', '2': 6},
    {'1': 'ErrorOffset', '2': 200},
  ],
};

/// Descriptor for `ErrCodes`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errCodesDescriptor = $convert.base64Decode(
    'CghFcnJDb2RlcxIOCgpVbmV4cGVjdGVkEAASDwoLQ0lETm90Rm91bmQQARINCglGb3JiaWRkZW'
    '4QAhIRCg1MaW1pdEV4Y2VlZGVkEAMSFQoRUXVlcnlTaXplRXhjZWVkZWQQBBINCglXcm9uZ0hh'
    'c2gQBRISCg5Ob3RFbm91Z2hTcGFjZRAGEhAKC0Vycm9yT2Zmc2V0EMgB');

@$core.Deprecated('Use availabilityStatusDescriptor instead')
const AvailabilityStatus$json = {
  '1': 'AvailabilityStatus',
  '2': [
    {'1': 'NotExists', '2': 0},
    {'1': 'Exists', '2': 1},
    {'1': 'ExistsInSpace', '2': 2},
  ],
};

/// Descriptor for `AvailabilityStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List availabilityStatusDescriptor = $convert.base64Decode(
    'ChJBdmFpbGFiaWxpdHlTdGF0dXMSDQoJTm90RXhpc3RzEAASCgoGRXhpc3RzEAESEQoNRXhpc3'
    'RzSW5TcGFjZRAC');

@$core.Deprecated('Use okDescriptor instead')
const Ok$json = {
  '1': 'Ok',
};

/// Descriptor for `Ok`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List okDescriptor = $convert.base64Decode('CgJPaw==');

@$core.Deprecated('Use blockGetRequestDescriptor instead')
const BlockGetRequest$json = {
  '1': 'BlockGetRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'cid', '3': 2, '4': 1, '5': 12, '10': 'cid'},
    {'1': 'wait', '3': 3, '4': 1, '5': 8, '10': 'wait'},
  ],
};

/// Descriptor for `BlockGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockGetRequestDescriptor = $convert.base64Decode(
    'Cg9CbG9ja0dldFJlcXVlc3QSGAoHc3BhY2VJZBgBIAEoCVIHc3BhY2VJZBIQCgNjaWQYAiABKA'
    'xSA2NpZBISCgR3YWl0GAMgASgIUgR3YWl0');

@$core.Deprecated('Use blockGetResponseDescriptor instead')
const BlockGetResponse$json = {
  '1': 'BlockGetResponse',
  '2': [
    {'1': 'cid', '3': 1, '4': 1, '5': 12, '10': 'cid'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `BlockGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockGetResponseDescriptor = $convert.base64Decode(
    'ChBCbG9ja0dldFJlc3BvbnNlEhAKA2NpZBgBIAEoDFIDY2lkEhIKBGRhdGEYAiABKAxSBGRhdG'
    'E=');

@$core.Deprecated('Use blockPushRequestDescriptor instead')
const BlockPushRequest$json = {
  '1': 'BlockPushRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'fileId', '3': 2, '4': 1, '5': 9, '10': 'fileId'},
    {'1': 'cid', '3': 3, '4': 1, '5': 12, '10': 'cid'},
    {'1': 'data', '3': 4, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `BlockPushRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockPushRequestDescriptor = $convert.base64Decode(
    'ChBCbG9ja1B1c2hSZXF1ZXN0EhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQSFgoGZmlsZUlkGA'
    'IgASgJUgZmaWxlSWQSEAoDY2lkGAMgASgMUgNjaWQSEgoEZGF0YRgEIAEoDFIEZGF0YQ==');

@$core.Deprecated('Use blocksCheckRequestDescriptor instead')
const BlocksCheckRequest$json = {
  '1': 'BlocksCheckRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'cids', '3': 2, '4': 3, '5': 12, '10': 'cids'},
  ],
};

/// Descriptor for `BlocksCheckRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blocksCheckRequestDescriptor = $convert.base64Decode(
    'ChJCbG9ja3NDaGVja1JlcXVlc3QSGAoHc3BhY2VJZBgBIAEoCVIHc3BhY2VJZBISCgRjaWRzGA'
    'IgAygMUgRjaWRz');

@$core.Deprecated('Use blocksCheckResponseDescriptor instead')
const BlocksCheckResponse$json = {
  '1': 'BlocksCheckResponse',
  '2': [
    {
      '1': 'blocksAvailability',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.filesync.BlockAvailability',
      '10': 'blocksAvailability'
    },
  ],
};

/// Descriptor for `BlocksCheckResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blocksCheckResponseDescriptor = $convert.base64Decode(
    'ChNCbG9ja3NDaGVja1Jlc3BvbnNlEksKEmJsb2Nrc0F2YWlsYWJpbGl0eRgBIAMoCzIbLmZpbG'
    'VzeW5jLkJsb2NrQXZhaWxhYmlsaXR5UhJibG9ja3NBdmFpbGFiaWxpdHk=');

@$core.Deprecated('Use blockAvailabilityDescriptor instead')
const BlockAvailability$json = {
  '1': 'BlockAvailability',
  '2': [
    {'1': 'cid', '3': 1, '4': 1, '5': 12, '10': 'cid'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.filesync.AvailabilityStatus',
      '10': 'status'
    },
  ],
};

/// Descriptor for `BlockAvailability`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockAvailabilityDescriptor = $convert.base64Decode(
    'ChFCbG9ja0F2YWlsYWJpbGl0eRIQCgNjaWQYASABKAxSA2NpZBI0CgZzdGF0dXMYAiABKA4yHC'
    '5maWxlc3luYy5BdmFpbGFiaWxpdHlTdGF0dXNSBnN0YXR1cw==');

@$core.Deprecated('Use blocksBindRequestDescriptor instead')
const BlocksBindRequest$json = {
  '1': 'BlocksBindRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'fileId', '3': 2, '4': 1, '5': 9, '10': 'fileId'},
    {'1': 'cids', '3': 3, '4': 3, '5': 12, '10': 'cids'},
  ],
};

/// Descriptor for `BlocksBindRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blocksBindRequestDescriptor = $convert.base64Decode(
    'ChFCbG9ja3NCaW5kUmVxdWVzdBIYCgdzcGFjZUlkGAEgASgJUgdzcGFjZUlkEhYKBmZpbGVJZB'
    'gCIAEoCVIGZmlsZUlkEhIKBGNpZHMYAyADKAxSBGNpZHM=');

@$core.Deprecated('Use filesDeleteRequestDescriptor instead')
const FilesDeleteRequest$json = {
  '1': 'FilesDeleteRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'fileIds', '3': 2, '4': 3, '5': 9, '10': 'fileIds'},
  ],
};

/// Descriptor for `FilesDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filesDeleteRequestDescriptor = $convert.base64Decode(
    'ChJGaWxlc0RlbGV0ZVJlcXVlc3QSGAoHc3BhY2VJZBgBIAEoCVIHc3BhY2VJZBIYCgdmaWxlSW'
    'RzGAIgAygJUgdmaWxlSWRz');

@$core.Deprecated('Use filesDeleteResponseDescriptor instead')
const FilesDeleteResponse$json = {
  '1': 'FilesDeleteResponse',
};

/// Descriptor for `FilesDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filesDeleteResponseDescriptor =
    $convert.base64Decode('ChNGaWxlc0RlbGV0ZVJlc3BvbnNl');

@$core.Deprecated('Use filesInfoRequestDescriptor instead')
const FilesInfoRequest$json = {
  '1': 'FilesInfoRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'fileIds', '3': 2, '4': 3, '5': 9, '10': 'fileIds'},
  ],
};

/// Descriptor for `FilesInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filesInfoRequestDescriptor = $convert.base64Decode(
    'ChBGaWxlc0luZm9SZXF1ZXN0EhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQSGAoHZmlsZUlkcx'
    'gCIAMoCVIHZmlsZUlkcw==');

@$core.Deprecated('Use filesInfoResponseDescriptor instead')
const FilesInfoResponse$json = {
  '1': 'FilesInfoResponse',
  '2': [
    {
      '1': 'filesInfo',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.filesync.FileInfo',
      '10': 'filesInfo'
    },
  ],
};

/// Descriptor for `FilesInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filesInfoResponseDescriptor = $convert.base64Decode(
    'ChFGaWxlc0luZm9SZXNwb25zZRIwCglmaWxlc0luZm8YASADKAsyEi5maWxlc3luYy5GaWxlSW'
    '5mb1IJZmlsZXNJbmZv');

@$core.Deprecated('Use fileInfoDescriptor instead')
const FileInfo$json = {
  '1': 'FileInfo',
  '2': [
    {'1': 'fileId', '3': 1, '4': 1, '5': 9, '10': 'fileId'},
    {'1': 'usageBytes', '3': 2, '4': 1, '5': 4, '10': 'usageBytes'},
    {'1': 'cidsCount', '3': 3, '4': 1, '5': 13, '10': 'cidsCount'},
  ],
};

/// Descriptor for `FileInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileInfoDescriptor = $convert.base64Decode(
    'CghGaWxlSW5mbxIWCgZmaWxlSWQYASABKAlSBmZpbGVJZBIeCgp1c2FnZUJ5dGVzGAIgASgEUg'
    'p1c2FnZUJ5dGVzEhwKCWNpZHNDb3VudBgDIAEoDVIJY2lkc0NvdW50');

@$core.Deprecated('Use filesGetRequestDescriptor instead')
const FilesGetRequest$json = {
  '1': 'FilesGetRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
  ],
};

/// Descriptor for `FilesGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filesGetRequestDescriptor = $convert.base64Decode(
    'Cg9GaWxlc0dldFJlcXVlc3QSGAoHc3BhY2VJZBgBIAEoCVIHc3BhY2VJZA==');

@$core.Deprecated('Use filesGetResponseDescriptor instead')
const FilesGetResponse$json = {
  '1': 'FilesGetResponse',
  '2': [
    {'1': 'fileId', '3': 1, '4': 1, '5': 9, '10': 'fileId'},
  ],
};

/// Descriptor for `FilesGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filesGetResponseDescriptor = $convert
    .base64Decode('ChBGaWxlc0dldFJlc3BvbnNlEhYKBmZpbGVJZBgBIAEoCVIGZmlsZUlk');

@$core.Deprecated('Use checkRequestDescriptor instead')
const CheckRequest$json = {
  '1': 'CheckRequest',
};

/// Descriptor for `CheckRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkRequestDescriptor =
    $convert.base64Decode('CgxDaGVja1JlcXVlc3Q=');

@$core.Deprecated('Use checkResponseDescriptor instead')
const CheckResponse$json = {
  '1': 'CheckResponse',
  '2': [
    {'1': 'spaceIds', '3': 1, '4': 3, '5': 9, '10': 'spaceIds'},
    {'1': 'allowWrite', '3': 2, '4': 1, '5': 8, '10': 'allowWrite'},
  ],
};

/// Descriptor for `CheckResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkResponseDescriptor = $convert.base64Decode(
    'Cg1DaGVja1Jlc3BvbnNlEhoKCHNwYWNlSWRzGAEgAygJUghzcGFjZUlkcxIeCgphbGxvd1dyaX'
    'RlGAIgASgIUgphbGxvd1dyaXRl');

@$core.Deprecated('Use spaceInfoRequestDescriptor instead')
const SpaceInfoRequest$json = {
  '1': 'SpaceInfoRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
  ],
};

/// Descriptor for `SpaceInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceInfoRequestDescriptor = $convert.base64Decode(
    'ChBTcGFjZUluZm9SZXF1ZXN0EhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQ=');

@$core.Deprecated('Use spaceInfoResponseDescriptor instead')
const SpaceInfoResponse$json = {
  '1': 'SpaceInfoResponse',
  '2': [
    {'1': 'limitBytes', '3': 1, '4': 1, '5': 4, '10': 'limitBytes'},
    {'1': 'totalUsageBytes', '3': 2, '4': 1, '5': 4, '10': 'totalUsageBytes'},
    {'1': 'cidsCount', '3': 3, '4': 1, '5': 4, '10': 'cidsCount'},
    {'1': 'filesCount', '3': 4, '4': 1, '5': 4, '10': 'filesCount'},
    {'1': 'spaceUsageBytes', '3': 5, '4': 1, '5': 4, '10': 'spaceUsageBytes'},
    {'1': 'spaceId', '3': 6, '4': 1, '5': 9, '10': 'spaceId'},
  ],
};

/// Descriptor for `SpaceInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceInfoResponseDescriptor = $convert.base64Decode(
    'ChFTcGFjZUluZm9SZXNwb25zZRIeCgpsaW1pdEJ5dGVzGAEgASgEUgpsaW1pdEJ5dGVzEigKD3'
    'RvdGFsVXNhZ2VCeXRlcxgCIAEoBFIPdG90YWxVc2FnZUJ5dGVzEhwKCWNpZHNDb3VudBgDIAEo'
    'BFIJY2lkc0NvdW50Eh4KCmZpbGVzQ291bnQYBCABKARSCmZpbGVzQ291bnQSKAoPc3BhY2VVc2'
    'FnZUJ5dGVzGAUgASgEUg9zcGFjZVVzYWdlQnl0ZXMSGAoHc3BhY2VJZBgGIAEoCVIHc3BhY2VJ'
    'ZA==');

@$core.Deprecated('Use accountInfoRequestDescriptor instead')
const AccountInfoRequest$json = {
  '1': 'AccountInfoRequest',
};

/// Descriptor for `AccountInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountInfoRequestDescriptor =
    $convert.base64Decode('ChJBY2NvdW50SW5mb1JlcXVlc3Q=');

@$core.Deprecated('Use accountInfoResponseDescriptor instead')
const AccountInfoResponse$json = {
  '1': 'AccountInfoResponse',
  '2': [
    {'1': 'limitBytes', '3': 1, '4': 1, '5': 4, '10': 'limitBytes'},
    {'1': 'totalUsageBytes', '3': 2, '4': 1, '5': 4, '10': 'totalUsageBytes'},
    {'1': 'totalCidsCount', '3': 3, '4': 1, '5': 4, '10': 'totalCidsCount'},
    {
      '1': 'spaces',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.filesync.SpaceInfoResponse',
      '10': 'spaces'
    },
    {
      '1': 'accountLimitBytes',
      '3': 5,
      '4': 1,
      '5': 4,
      '10': 'accountLimitBytes'
    },
  ],
};

/// Descriptor for `AccountInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountInfoResponseDescriptor = $convert.base64Decode(
    'ChNBY2NvdW50SW5mb1Jlc3BvbnNlEh4KCmxpbWl0Qnl0ZXMYASABKARSCmxpbWl0Qnl0ZXMSKA'
    'oPdG90YWxVc2FnZUJ5dGVzGAIgASgEUg90b3RhbFVzYWdlQnl0ZXMSJgoOdG90YWxDaWRzQ291'
    'bnQYAyABKARSDnRvdGFsQ2lkc0NvdW50EjMKBnNwYWNlcxgEIAMoCzIbLmZpbGVzeW5jLlNwYW'
    'NlSW5mb1Jlc3BvbnNlUgZzcGFjZXMSLAoRYWNjb3VudExpbWl0Qnl0ZXMYBSABKARSEWFjY291'
    'bnRMaW1pdEJ5dGVz');

@$core.Deprecated('Use accountLimitSetRequestDescriptor instead')
const AccountLimitSetRequest$json = {
  '1': 'AccountLimitSetRequest',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 9, '10': 'identity'},
    {'1': 'limit', '3': 2, '4': 1, '5': 4, '10': 'limit'},
  ],
};

/// Descriptor for `AccountLimitSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountLimitSetRequestDescriptor =
    $convert.base64Decode(
        'ChZBY2NvdW50TGltaXRTZXRSZXF1ZXN0EhoKCGlkZW50aXR5GAEgASgJUghpZGVudGl0eRIUCg'
        'VsaW1pdBgCIAEoBFIFbGltaXQ=');

@$core.Deprecated('Use spaceLimitSetRequestDescriptor instead')
const SpaceLimitSetRequest$json = {
  '1': 'SpaceLimitSetRequest',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 4, '10': 'limit'},
  ],
};

/// Descriptor for `SpaceLimitSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceLimitSetRequestDescriptor = $convert.base64Decode(
    'ChRTcGFjZUxpbWl0U2V0UmVxdWVzdBIYCgdzcGFjZUlkGAEgASgJUgdzcGFjZUlkEhQKBWxpbW'
    'l0GAIgASgEUgVsaW1pdA==');

const $core.Map<$core.String, $core.dynamic> FileServiceBase$json = {
  '1': 'File',
  '2': [
    {
      '1': 'BlockGet',
      '2': '.filesync.BlockGetRequest',
      '3': '.filesync.BlockGetResponse'
    },
    {'1': 'BlockPush', '2': '.filesync.BlockPushRequest', '3': '.filesync.Ok'},
    {
      '1': 'BlocksCheck',
      '2': '.filesync.BlocksCheckRequest',
      '3': '.filesync.BlocksCheckResponse'
    },
    {
      '1': 'BlocksBind',
      '2': '.filesync.BlocksBindRequest',
      '3': '.filesync.Ok'
    },
    {
      '1': 'FilesDelete',
      '2': '.filesync.FilesDeleteRequest',
      '3': '.filesync.FilesDeleteResponse'
    },
    {
      '1': 'FilesInfo',
      '2': '.filesync.FilesInfoRequest',
      '3': '.filesync.FilesInfoResponse'
    },
    {
      '1': 'FilesGet',
      '2': '.filesync.FilesGetRequest',
      '3': '.filesync.FilesGetResponse',
      '6': true
    },
    {
      '1': 'Check',
      '2': '.filesync.CheckRequest',
      '3': '.filesync.CheckResponse'
    },
    {
      '1': 'SpaceInfo',
      '2': '.filesync.SpaceInfoRequest',
      '3': '.filesync.SpaceInfoResponse'
    },
    {
      '1': 'AccountInfo',
      '2': '.filesync.AccountInfoRequest',
      '3': '.filesync.AccountInfoResponse'
    },
    {
      '1': 'AccountLimitSet',
      '2': '.filesync.AccountLimitSetRequest',
      '3': '.filesync.Ok'
    },
    {
      '1': 'SpaceLimitSet',
      '2': '.filesync.SpaceLimitSetRequest',
      '3': '.filesync.Ok'
    },
  ],
};

@$core.Deprecated('Use fileServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    FileServiceBase$messageJson = {
  '.filesync.BlockGetRequest': BlockGetRequest$json,
  '.filesync.BlockGetResponse': BlockGetResponse$json,
  '.filesync.BlockPushRequest': BlockPushRequest$json,
  '.filesync.Ok': Ok$json,
  '.filesync.BlocksCheckRequest': BlocksCheckRequest$json,
  '.filesync.BlocksCheckResponse': BlocksCheckResponse$json,
  '.filesync.BlockAvailability': BlockAvailability$json,
  '.filesync.BlocksBindRequest': BlocksBindRequest$json,
  '.filesync.FilesDeleteRequest': FilesDeleteRequest$json,
  '.filesync.FilesDeleteResponse': FilesDeleteResponse$json,
  '.filesync.FilesInfoRequest': FilesInfoRequest$json,
  '.filesync.FilesInfoResponse': FilesInfoResponse$json,
  '.filesync.FileInfo': FileInfo$json,
  '.filesync.FilesGetRequest': FilesGetRequest$json,
  '.filesync.FilesGetResponse': FilesGetResponse$json,
  '.filesync.CheckRequest': CheckRequest$json,
  '.filesync.CheckResponse': CheckResponse$json,
  '.filesync.SpaceInfoRequest': SpaceInfoRequest$json,
  '.filesync.SpaceInfoResponse': SpaceInfoResponse$json,
  '.filesync.AccountInfoRequest': AccountInfoRequest$json,
  '.filesync.AccountInfoResponse': AccountInfoResponse$json,
  '.filesync.AccountLimitSetRequest': AccountLimitSetRequest$json,
  '.filesync.SpaceLimitSetRequest': SpaceLimitSetRequest$json,
};

/// Descriptor for `File`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List fileServiceDescriptor = $convert.base64Decode(
    'CgRGaWxlEkEKCEJsb2NrR2V0EhkuZmlsZXN5bmMuQmxvY2tHZXRSZXF1ZXN0GhouZmlsZXN5bm'
    'MuQmxvY2tHZXRSZXNwb25zZRI1CglCbG9ja1B1c2gSGi5maWxlc3luYy5CbG9ja1B1c2hSZXF1'
    'ZXN0GgwuZmlsZXN5bmMuT2sSSgoLQmxvY2tzQ2hlY2sSHC5maWxlc3luYy5CbG9ja3NDaGVja1'
    'JlcXVlc3QaHS5maWxlc3luYy5CbG9ja3NDaGVja1Jlc3BvbnNlEjcKCkJsb2Nrc0JpbmQSGy5m'
    'aWxlc3luYy5CbG9ja3NCaW5kUmVxdWVzdBoMLmZpbGVzeW5jLk9rEkoKC0ZpbGVzRGVsZXRlEh'
    'wuZmlsZXN5bmMuRmlsZXNEZWxldGVSZXF1ZXN0Gh0uZmlsZXN5bmMuRmlsZXNEZWxldGVSZXNw'
    'b25zZRJECglGaWxlc0luZm8SGi5maWxlc3luYy5GaWxlc0luZm9SZXF1ZXN0GhsuZmlsZXN5bm'
    'MuRmlsZXNJbmZvUmVzcG9uc2USQwoIRmlsZXNHZXQSGS5maWxlc3luYy5GaWxlc0dldFJlcXVl'
    'c3QaGi5maWxlc3luYy5GaWxlc0dldFJlc3BvbnNlMAESOAoFQ2hlY2sSFi5maWxlc3luYy5DaG'
    'Vja1JlcXVlc3QaFy5maWxlc3luYy5DaGVja1Jlc3BvbnNlEkQKCVNwYWNlSW5mbxIaLmZpbGVz'
    'eW5jLlNwYWNlSW5mb1JlcXVlc3QaGy5maWxlc3luYy5TcGFjZUluZm9SZXNwb25zZRJKCgtBY2'
    'NvdW50SW5mbxIcLmZpbGVzeW5jLkFjY291bnRJbmZvUmVxdWVzdBodLmZpbGVzeW5jLkFjY291'
    'bnRJbmZvUmVzcG9uc2USQQoPQWNjb3VudExpbWl0U2V0EiAuZmlsZXN5bmMuQWNjb3VudExpbW'
    'l0U2V0UmVxdWVzdBoMLmZpbGVzeW5jLk9rEj0KDVNwYWNlTGltaXRTZXQSHi5maWxlc3luYy5T'
    'cGFjZUxpbWl0U2V0UmVxdWVzdBoMLmZpbGVzeW5jLk9r');
