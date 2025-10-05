// This is a generated file - do not edit.
//
// Generated from any_sync/treechange.proto.

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
    {'1': 'GetTreeError', '2': 1},
    {'1': 'FullSyncRequestError', '2': 2},
    {'1': 'ErrorOffset', '2': 400},
  ],
};

/// Descriptor for `ErrorCodes`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorCodesDescriptor = $convert.base64Decode(
    'CgpFcnJvckNvZGVzEg4KClVuZXhwZWN0ZWQQABIQCgxHZXRUcmVlRXJyb3IQARIYChRGdWxsU3'
    'luY1JlcXVlc3RFcnJvchACEhAKC0Vycm9yT2Zmc2V0EJAD');

@$core.Deprecated('Use rootChangeDescriptor instead')
const RootChange$json = {
  '1': 'RootChange',
  '2': [
    {'1': 'aclHeadId', '3': 1, '4': 1, '5': 9, '10': 'aclHeadId'},
    {'1': 'spaceId', '3': 2, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'changeType', '3': 3, '4': 1, '5': 9, '10': 'changeType'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'seed', '3': 5, '4': 1, '5': 12, '10': 'seed'},
    {'1': 'identity', '3': 6, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'changePayload', '3': 7, '4': 1, '5': 12, '10': 'changePayload'},
    {'1': 'isDerived', '3': 8, '4': 1, '5': 8, '10': 'isDerived'},
  ],
};

/// Descriptor for `RootChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rootChangeDescriptor = $convert.base64Decode(
    'CgpSb290Q2hhbmdlEhwKCWFjbEhlYWRJZBgBIAEoCVIJYWNsSGVhZElkEhgKB3NwYWNlSWQYAi'
    'ABKAlSB3NwYWNlSWQSHgoKY2hhbmdlVHlwZRgDIAEoCVIKY2hhbmdlVHlwZRIcCgl0aW1lc3Rh'
    'bXAYBCABKANSCXRpbWVzdGFtcBISCgRzZWVkGAUgASgMUgRzZWVkEhoKCGlkZW50aXR5GAYgAS'
    'gMUghpZGVudGl0eRIkCg1jaGFuZ2VQYXlsb2FkGAcgASgMUg1jaGFuZ2VQYXlsb2FkEhwKCWlz'
    'RGVyaXZlZBgIIAEoCFIJaXNEZXJpdmVk');

@$core.Deprecated('Use treeChangeDescriptor instead')
const TreeChange$json = {
  '1': 'TreeChange',
  '2': [
    {'1': 'treeHeadIds', '3': 1, '4': 3, '5': 9, '10': 'treeHeadIds'},
    {'1': 'aclHeadId', '3': 2, '4': 1, '5': 9, '10': 'aclHeadId'},
    {'1': 'snapshotBaseId', '3': 3, '4': 1, '5': 9, '10': 'snapshotBaseId'},
    {'1': 'changesData', '3': 4, '4': 1, '5': 12, '10': 'changesData'},
    {'1': 'readKeyId', '3': 5, '4': 1, '5': 9, '10': 'readKeyId'},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'identity', '3': 7, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'isSnapshot', '3': 8, '4': 1, '5': 8, '10': 'isSnapshot'},
    {'1': 'dataType', '3': 9, '4': 1, '5': 9, '10': 'dataType'},
  ],
};

/// Descriptor for `TreeChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeChangeDescriptor = $convert.base64Decode(
    'CgpUcmVlQ2hhbmdlEiAKC3RyZWVIZWFkSWRzGAEgAygJUgt0cmVlSGVhZElkcxIcCglhY2xIZW'
    'FkSWQYAiABKAlSCWFjbEhlYWRJZBImCg5zbmFwc2hvdEJhc2VJZBgDIAEoCVIOc25hcHNob3RC'
    'YXNlSWQSIAoLY2hhbmdlc0RhdGEYBCABKAxSC2NoYW5nZXNEYXRhEhwKCXJlYWRLZXlJZBgFIA'
    'EoCVIJcmVhZEtleUlkEhwKCXRpbWVzdGFtcBgGIAEoA1IJdGltZXN0YW1wEhoKCGlkZW50aXR5'
    'GAcgASgMUghpZGVudGl0eRIeCgppc1NuYXBzaG90GAggASgIUgppc1NuYXBzaG90EhoKCGRhdG'
    'FUeXBlGAkgASgJUghkYXRhVHlwZQ==');

@$core.Deprecated('Use noDataTreeChangeDescriptor instead')
const NoDataTreeChange$json = {
  '1': 'NoDataTreeChange',
  '2': [
    {'1': 'treeHeadIds', '3': 1, '4': 3, '5': 9, '10': 'treeHeadIds'},
    {'1': 'aclHeadId', '3': 2, '4': 1, '5': 9, '10': 'aclHeadId'},
    {'1': 'snapshotBaseId', '3': 3, '4': 1, '5': 9, '10': 'snapshotBaseId'},
    {'1': 'readKeyId', '3': 5, '4': 1, '5': 9, '10': 'readKeyId'},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'identity', '3': 7, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'isSnapshot', '3': 8, '4': 1, '5': 8, '10': 'isSnapshot'},
    {'1': 'dataType', '3': 9, '4': 1, '5': 9, '10': 'dataType'},
  ],
};

/// Descriptor for `NoDataTreeChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noDataTreeChangeDescriptor = $convert.base64Decode(
    'ChBOb0RhdGFUcmVlQ2hhbmdlEiAKC3RyZWVIZWFkSWRzGAEgAygJUgt0cmVlSGVhZElkcxIcCg'
    'lhY2xIZWFkSWQYAiABKAlSCWFjbEhlYWRJZBImCg5zbmFwc2hvdEJhc2VJZBgDIAEoCVIOc25h'
    'cHNob3RCYXNlSWQSHAoJcmVhZEtleUlkGAUgASgJUglyZWFkS2V5SWQSHAoJdGltZXN0YW1wGA'
    'YgASgDUgl0aW1lc3RhbXASGgoIaWRlbnRpdHkYByABKAxSCGlkZW50aXR5Eh4KCmlzU25hcHNo'
    'b3QYCCABKAhSCmlzU25hcHNob3QSGgoIZGF0YVR5cGUYCSABKAlSCGRhdGFUeXBl');

@$core.Deprecated('Use reducedTreeChangeDescriptor instead')
const ReducedTreeChange$json = {
  '1': 'ReducedTreeChange',
  '2': [
    {'1': 'treeHeadIds', '3': 1, '4': 3, '5': 9, '10': 'treeHeadIds'},
  ],
};

/// Descriptor for `ReducedTreeChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reducedTreeChangeDescriptor = $convert.base64Decode(
    'ChFSZWR1Y2VkVHJlZUNoYW5nZRIgCgt0cmVlSGVhZElkcxgBIAMoCVILdHJlZUhlYWRJZHM=');

@$core.Deprecated('Use rawTreeChangeDescriptor instead')
const RawTreeChange$json = {
  '1': 'RawTreeChange',
  '2': [
    {'1': 'payload', '3': 1, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'signature', '3': 2, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `RawTreeChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rawTreeChangeDescriptor = $convert.base64Decode(
    'Cg1SYXdUcmVlQ2hhbmdlEhgKB3BheWxvYWQYASABKAxSB3BheWxvYWQSHAoJc2lnbmF0dXJlGA'
    'IgASgMUglzaWduYXR1cmU=');

@$core.Deprecated('Use rawTreeChangeWithIdDescriptor instead')
const RawTreeChangeWithId$json = {
  '1': 'RawTreeChangeWithId',
  '2': [
    {'1': 'rawChange', '3': 1, '4': 1, '5': 12, '10': 'rawChange'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `RawTreeChangeWithId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rawTreeChangeWithIdDescriptor = $convert.base64Decode(
    'ChNSYXdUcmVlQ2hhbmdlV2l0aElkEhwKCXJhd0NoYW5nZRgBIAEoDFIJcmF3Q2hhbmdlEg4KAm'
    'lkGAIgASgJUgJpZA==');

@$core.Deprecated('Use treeSyncMessageDescriptor instead')
const TreeSyncMessage$json = {
  '1': 'TreeSyncMessage',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.treechange.TreeSyncContentValue',
      '10': 'content'
    },
    {
      '1': 'rootChange',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.treechange.RawTreeChangeWithId',
      '10': 'rootChange'
    },
  ],
};

/// Descriptor for `TreeSyncMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeSyncMessageDescriptor = $convert.base64Decode(
    'Cg9UcmVlU3luY01lc3NhZ2USOgoHY29udGVudBgBIAEoCzIgLnRyZWVjaGFuZ2UuVHJlZVN5bm'
    'NDb250ZW50VmFsdWVSB2NvbnRlbnQSPwoKcm9vdENoYW5nZRgCIAEoCzIfLnRyZWVjaGFuZ2Uu'
    'UmF3VHJlZUNoYW5nZVdpdGhJZFIKcm9vdENoYW5nZQ==');

@$core.Deprecated('Use treeSyncContentValueDescriptor instead')
const TreeSyncContentValue$json = {
  '1': 'TreeSyncContentValue',
  '2': [
    {
      '1': 'headUpdate',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.treechange.TreeHeadUpdate',
      '9': 0,
      '10': 'headUpdate'
    },
    {
      '1': 'fullSyncRequest',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.treechange.TreeFullSyncRequest',
      '9': 0,
      '10': 'fullSyncRequest'
    },
    {
      '1': 'fullSyncResponse',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.treechange.TreeFullSyncResponse',
      '9': 0,
      '10': 'fullSyncResponse'
    },
    {
      '1': 'errorResponse',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.treechange.TreeErrorResponse',
      '9': 0,
      '10': 'errorResponse'
    },
  ],
  '8': [
    {'1': 'value'},
  ],
};

/// Descriptor for `TreeSyncContentValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeSyncContentValueDescriptor = $convert.base64Decode(
    'ChRUcmVlU3luY0NvbnRlbnRWYWx1ZRI8CgpoZWFkVXBkYXRlGAEgASgLMhoudHJlZWNoYW5nZS'
    '5UcmVlSGVhZFVwZGF0ZUgAUgpoZWFkVXBkYXRlEksKD2Z1bGxTeW5jUmVxdWVzdBgCIAEoCzIf'
    'LnRyZWVjaGFuZ2UuVHJlZUZ1bGxTeW5jUmVxdWVzdEgAUg9mdWxsU3luY1JlcXVlc3QSTgoQZn'
    'VsbFN5bmNSZXNwb25zZRgDIAEoCzIgLnRyZWVjaGFuZ2UuVHJlZUZ1bGxTeW5jUmVzcG9uc2VI'
    'AFIQZnVsbFN5bmNSZXNwb25zZRJFCg1lcnJvclJlc3BvbnNlGAQgASgLMh0udHJlZWNoYW5nZS'
    '5UcmVlRXJyb3JSZXNwb25zZUgAUg1lcnJvclJlc3BvbnNlQgcKBXZhbHVl');

@$core.Deprecated('Use treeHeadUpdateDescriptor instead')
const TreeHeadUpdate$json = {
  '1': 'TreeHeadUpdate',
  '2': [
    {'1': 'heads', '3': 1, '4': 3, '5': 9, '10': 'heads'},
    {
      '1': 'changes',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.treechange.RawTreeChangeWithId',
      '10': 'changes'
    },
    {'1': 'snapshotPath', '3': 3, '4': 3, '5': 9, '10': 'snapshotPath'},
  ],
};

/// Descriptor for `TreeHeadUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeHeadUpdateDescriptor = $convert.base64Decode(
    'Cg5UcmVlSGVhZFVwZGF0ZRIUCgVoZWFkcxgBIAMoCVIFaGVhZHMSOQoHY2hhbmdlcxgCIAMoCz'
    'IfLnRyZWVjaGFuZ2UuUmF3VHJlZUNoYW5nZVdpdGhJZFIHY2hhbmdlcxIiCgxzbmFwc2hvdFBh'
    'dGgYAyADKAlSDHNuYXBzaG90UGF0aA==');

@$core.Deprecated('Use treeFullSyncRequestDescriptor instead')
const TreeFullSyncRequest$json = {
  '1': 'TreeFullSyncRequest',
  '2': [
    {'1': 'heads', '3': 1, '4': 3, '5': 9, '10': 'heads'},
    {
      '1': 'changes',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.treechange.RawTreeChangeWithId',
      '10': 'changes'
    },
    {'1': 'snapshotPath', '3': 3, '4': 3, '5': 9, '10': 'snapshotPath'},
  ],
};

/// Descriptor for `TreeFullSyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeFullSyncRequestDescriptor = $convert.base64Decode(
    'ChNUcmVlRnVsbFN5bmNSZXF1ZXN0EhQKBWhlYWRzGAEgAygJUgVoZWFkcxI5CgdjaGFuZ2VzGA'
    'IgAygLMh8udHJlZWNoYW5nZS5SYXdUcmVlQ2hhbmdlV2l0aElkUgdjaGFuZ2VzEiIKDHNuYXBz'
    'aG90UGF0aBgDIAMoCVIMc25hcHNob3RQYXRo');

@$core.Deprecated('Use treeFullSyncResponseDescriptor instead')
const TreeFullSyncResponse$json = {
  '1': 'TreeFullSyncResponse',
  '2': [
    {'1': 'heads', '3': 1, '4': 3, '5': 9, '10': 'heads'},
    {
      '1': 'changes',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.treechange.RawTreeChangeWithId',
      '10': 'changes'
    },
    {'1': 'snapshotPath', '3': 3, '4': 3, '5': 9, '10': 'snapshotPath'},
  ],
};

/// Descriptor for `TreeFullSyncResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeFullSyncResponseDescriptor = $convert.base64Decode(
    'ChRUcmVlRnVsbFN5bmNSZXNwb25zZRIUCgVoZWFkcxgBIAMoCVIFaGVhZHMSOQoHY2hhbmdlcx'
    'gCIAMoCzIfLnRyZWVjaGFuZ2UuUmF3VHJlZUNoYW5nZVdpdGhJZFIHY2hhbmdlcxIiCgxzbmFw'
    'c2hvdFBhdGgYAyADKAlSDHNuYXBzaG90UGF0aA==');

@$core.Deprecated('Use treeErrorResponseDescriptor instead')
const TreeErrorResponse$json = {
  '1': 'TreeErrorResponse',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 9, '10': 'error'},
    {'1': 'errCode', '3': 2, '4': 1, '5': 4, '10': 'errCode'},
  ],
};

/// Descriptor for `TreeErrorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeErrorResponseDescriptor = $convert.base64Decode(
    'ChFUcmVlRXJyb3JSZXNwb25zZRIUCgVlcnJvchgBIAEoCVIFZXJyb3ISGAoHZXJyQ29kZRgCIA'
    'EoBFIHZXJyQ29kZQ==');

@$core.Deprecated('Use treeChangeInfoDescriptor instead')
const TreeChangeInfo$json = {
  '1': 'TreeChangeInfo',
  '2': [
    {'1': 'changeType', '3': 1, '4': 1, '5': 9, '10': 'changeType'},
    {'1': 'changePayload', '3': 2, '4': 1, '5': 12, '10': 'changePayload'},
  ],
};

/// Descriptor for `TreeChangeInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeChangeInfoDescriptor = $convert.base64Decode(
    'Cg5UcmVlQ2hhbmdlSW5mbxIeCgpjaGFuZ2VUeXBlGAEgASgJUgpjaGFuZ2VUeXBlEiQKDWNoYW'
    '5nZVBheWxvYWQYAiABKAxSDWNoYW5nZVBheWxvYWQ=');
