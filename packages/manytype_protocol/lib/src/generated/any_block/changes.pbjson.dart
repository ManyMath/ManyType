// This is a generated file - do not edit.
//
// Generated from any_block/changes.proto.

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

@$core.Deprecated('Use modifyOpDescriptor instead')
const ModifyOp$json = {
  '1': 'ModifyOp',
  '2': [
    {'1': 'Set', '2': 0},
    {'1': 'Unset', '2': 1},
    {'1': 'Inc', '2': 2},
    {'1': 'AddToSet', '2': 3},
    {'1': 'Pull', '2': 4},
  ],
};

/// Descriptor for `ModifyOp`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List modifyOpDescriptor = $convert.base64Decode(
    'CghNb2RpZnlPcBIHCgNTZXQQABIJCgVVbnNldBABEgcKA0luYxACEgwKCEFkZFRvU2V0EAMSCA'
    'oEUHVsbBAE');

@$core.Deprecated('Use changeDescriptor instead')
const Change$json = {
  '1': 'Change',
  '2': [
    {
      '1': 'content',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Change.Content',
      '10': 'content'
    },
    {
      '1': 'snapshot',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.Snapshot',
      '10': 'snapshot'
    },
    {
      '1': 'fileKeys',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Change.FileKeys',
      '10': 'fileKeys'
    },
    {'1': 'timestamp', '3': 7, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'version', '3': 8, '4': 1, '5': 13, '10': 'version'},
    {'1': 'changeType', '3': 9, '4': 1, '5': 13, '10': 'changeType'},
  ],
  '3': [
    Change_Snapshot$json,
    Change_FileKeys$json,
    Change_Content$json,
    Change_BlockCreate$json,
    Change_BlockUpdate$json,
    Change_BlockRemove$json,
    Change_BlockMove$json,
    Change_BlockDuplicate$json,
    Change_DetailsSet$json,
    Change_DetailsUnset$json,
    Change_RelationAdd$json,
    Change_RelationRemove$json,
    Change_ObjectTypeAdd$json,
    Change_ObjectTypeRemove$json,
    Change_StoreKeySet$json,
    Change_StoreKeyUnset$json,
    Change_StoreSliceUpdate$json,
    Change_OriginalCreatedTimestampSet$json,
    Change_SetFileInfo$json,
    Change_NotificationCreate$json,
    Change_NotificationUpdate$json,
    Change_DeviceAdd$json,
    Change_DeviceUpdate$json
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_Snapshot$json = {
  '1': 'Snapshot',
  '2': [
    {
      '1': 'logHeads',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Change.Snapshot.LogHeadsEntry',
      '10': 'logHeads'
    },
    {
      '1': 'data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.SmartBlockSnapshotBase',
      '10': 'data'
    },
    {
      '1': 'fileKeys',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Change.FileKeys',
      '10': 'fileKeys'
    },
  ],
  '3': [Change_Snapshot_LogHeadsEntry$json],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_Snapshot_LogHeadsEntry$json = {
  '1': 'LogHeadsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_FileKeys$json = {
  '1': 'FileKeys',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    {
      '1': 'keys',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Change.FileKeys.KeysEntry',
      '10': 'keys'
    },
  ],
  '3': [Change_FileKeys_KeysEntry$json],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_FileKeys_KeysEntry$json = {
  '1': 'KeysEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_Content$json = {
  '1': 'Content',
  '2': [
    {
      '1': 'blockCreate',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.BlockCreate',
      '9': 0,
      '10': 'blockCreate'
    },
    {
      '1': 'blockUpdate',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.BlockUpdate',
      '9': 0,
      '10': 'blockUpdate'
    },
    {
      '1': 'blockRemove',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.BlockRemove',
      '9': 0,
      '10': 'blockRemove'
    },
    {
      '1': 'blockMove',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.BlockMove',
      '9': 0,
      '10': 'blockMove'
    },
    {
      '1': 'blockDuplicate',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.BlockDuplicate',
      '9': 0,
      '10': 'blockDuplicate'
    },
    {
      '1': 'relationAdd',
      '3': 50,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.RelationAdd',
      '9': 0,
      '10': 'relationAdd'
    },
    {
      '1': 'relationRemove',
      '3': 51,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.RelationRemove',
      '9': 0,
      '10': 'relationRemove'
    },
    {
      '1': 'detailsSet',
      '3': 100,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.DetailsSet',
      '9': 0,
      '10': 'detailsSet'
    },
    {
      '1': 'detailsUnset',
      '3': 101,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.DetailsUnset',
      '9': 0,
      '10': 'detailsUnset'
    },
    {
      '1': 'objectTypeAdd',
      '3': 105,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.ObjectTypeAdd',
      '9': 0,
      '10': 'objectTypeAdd'
    },
    {
      '1': 'objectTypeRemove',
      '3': 106,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.ObjectTypeRemove',
      '9': 0,
      '10': 'objectTypeRemove'
    },
    {
      '1': 'storeKeySet',
      '3': 107,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.StoreKeySet',
      '9': 0,
      '10': 'storeKeySet'
    },
    {
      '1': 'storeKeyUnset',
      '3': 108,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.StoreKeyUnset',
      '9': 0,
      '10': 'storeKeyUnset'
    },
    {
      '1': 'storeSliceUpdate',
      '3': 109,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.StoreSliceUpdate',
      '9': 0,
      '10': 'storeSliceUpdate'
    },
    {
      '1': 'originalCreatedTimestampSet',
      '3': 110,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.OriginalCreatedTimestampSet',
      '9': 0,
      '10': 'originalCreatedTimestampSet'
    },
    {
      '1': 'setFileInfo',
      '3': 111,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.SetFileInfo',
      '9': 0,
      '10': 'setFileInfo'
    },
    {
      '1': 'notificationCreate',
      '3': 112,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.NotificationCreate',
      '9': 0,
      '10': 'notificationCreate'
    },
    {
      '1': 'notificationUpdate',
      '3': 113,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.NotificationUpdate',
      '9': 0,
      '10': 'notificationUpdate'
    },
    {
      '1': 'deviceAdd',
      '3': 114,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.DeviceAdd',
      '9': 0,
      '10': 'deviceAdd'
    },
    {
      '1': 'deviceUpdate',
      '3': 115,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.DeviceUpdate',
      '9': 0,
      '10': 'deviceUpdate'
    },
  ],
  '8': [
    {'1': 'value'},
  ],
  '9': [
    {'1': 102, '2': 103},
    {'1': 103, '2': 104},
    {'1': 104, '2': 105},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_BlockCreate$json = {
  '1': 'BlockCreate',
  '2': [
    {'1': 'targetId', '3': 1, '4': 1, '5': 9, '10': 'targetId'},
    {
      '1': 'position',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Position',
      '10': 'position'
    },
    {
      '1': 'blocks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block',
      '10': 'blocks'
    },
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_BlockUpdate$json = {
  '1': 'BlockUpdate',
  '2': [
    {'1': 'events', '3': 2, '4': 3, '5': 12, '10': 'events'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_BlockRemove$json = {
  '1': 'BlockRemove',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 9, '10': 'ids'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_BlockMove$json = {
  '1': 'BlockMove',
  '2': [
    {'1': 'targetId', '3': 1, '4': 1, '5': 9, '10': 'targetId'},
    {
      '1': 'position',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Position',
      '10': 'position'
    },
    {'1': 'ids', '3': 3, '4': 3, '5': 9, '10': 'ids'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_BlockDuplicate$json = {
  '1': 'BlockDuplicate',
  '2': [
    {'1': 'targetId', '3': 1, '4': 1, '5': 9, '10': 'targetId'},
    {
      '1': 'position',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Position',
      '10': 'position'
    },
    {'1': 'ids', '3': 3, '4': 3, '5': 9, '10': 'ids'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_DetailsSet$json = {
  '1': 'DetailsSet',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Value',
      '10': 'value'
    },
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_DetailsUnset$json = {
  '1': 'DetailsUnset',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_RelationAdd$json = {
  '1': 'RelationAdd',
  '2': [
    {
      '1': 'relationLinks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.RelationLink',
      '10': 'relationLinks'
    },
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_RelationRemove$json = {
  '1': 'RelationRemove',
  '2': [
    {'1': 'relationKey', '3': 1, '4': 3, '5': 9, '10': 'relationKey'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_ObjectTypeAdd$json = {
  '1': 'ObjectTypeAdd',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'key', '3': 2, '4': 1, '5': 9, '10': 'key'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_ObjectTypeRemove$json = {
  '1': 'ObjectTypeRemove',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'key', '3': 2, '4': 1, '5': 9, '10': 'key'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_StoreKeySet$json = {
  '1': 'StoreKeySet',
  '2': [
    {'1': 'path', '3': 1, '4': 3, '5': 9, '10': 'path'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Value',
      '10': 'value'
    },
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_StoreKeyUnset$json = {
  '1': 'StoreKeyUnset',
  '2': [
    {'1': 'path', '3': 1, '4': 3, '5': 9, '10': 'path'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_StoreSliceUpdate$json = {
  '1': 'StoreSliceUpdate',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'add',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.StoreSliceUpdate.Add',
      '9': 0,
      '10': 'add'
    },
    {
      '1': 'remove',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.StoreSliceUpdate.Remove',
      '9': 0,
      '10': 'remove'
    },
    {
      '1': 'move',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Change.StoreSliceUpdate.Move',
      '9': 0,
      '10': 'move'
    },
  ],
  '3': [
    Change_StoreSliceUpdate_Add$json,
    Change_StoreSliceUpdate_Remove$json,
    Change_StoreSliceUpdate_Move$json
  ],
  '8': [
    {'1': 'operation'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_StoreSliceUpdate_Add$json = {
  '1': 'Add',
  '2': [
    {'1': 'afterId', '3': 1, '4': 1, '5': 9, '10': 'afterId'},
    {'1': 'ids', '3': 2, '4': 3, '5': 9, '10': 'ids'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_StoreSliceUpdate_Remove$json = {
  '1': 'Remove',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 9, '10': 'ids'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_StoreSliceUpdate_Move$json = {
  '1': 'Move',
  '2': [
    {'1': 'afterId', '3': 1, '4': 1, '5': 9, '10': 'afterId'},
    {'1': 'ids', '3': 2, '4': 3, '5': 9, '10': 'ids'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_OriginalCreatedTimestampSet$json = {
  '1': 'OriginalCreatedTimestampSet',
  '2': [
    {'1': 'ts', '3': 1, '4': 1, '5': 3, '10': 'ts'},
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_SetFileInfo$json = {
  '1': 'SetFileInfo',
  '2': [
    {
      '1': 'fileInfo',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.FileInfo',
      '10': 'fileInfo'
    },
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_NotificationCreate$json = {
  '1': 'NotificationCreate',
  '2': [
    {
      '1': 'notification',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification',
      '10': 'notification'
    },
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_NotificationUpdate$json = {
  '1': 'NotificationUpdate',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Notification.Status',
      '10': 'status'
    },
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_DeviceAdd$json = {
  '1': 'DeviceAdd',
  '2': [
    {
      '1': 'device',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.DeviceInfo',
      '10': 'device'
    },
  ],
};

@$core.Deprecated('Use changeDescriptor instead')
const Change_DeviceUpdate$json = {
  '1': 'DeviceUpdate',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Change`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeDescriptor = $convert.base64Decode(
    'CgZDaGFuZ2USNwoHY29udGVudBgDIAMoCzIdLmFueXR5cGUubW9kZWwuQ2hhbmdlLkNvbnRlbn'
    'RSB2NvbnRlbnQSOgoIc25hcHNob3QYBCABKAsyHi5hbnl0eXBlLm1vZGVsLkNoYW5nZS5TbmFw'
    'c2hvdFIIc25hcHNob3QSOgoIZmlsZUtleXMYBiADKAsyHi5hbnl0eXBlLm1vZGVsLkNoYW5nZS'
    '5GaWxlS2V5c1IIZmlsZUtleXMSHAoJdGltZXN0YW1wGAcgASgDUgl0aW1lc3RhbXASGAoHdmVy'
    'c2lvbhgIIAEoDVIHdmVyc2lvbhIeCgpjaGFuZ2VUeXBlGAkgASgNUgpjaGFuZ2VUeXBlGogCCg'
    'hTbmFwc2hvdBJICghsb2dIZWFkcxgBIAMoCzIsLmFueXR5cGUubW9kZWwuQ2hhbmdlLlNuYXBz'
    'aG90LkxvZ0hlYWRzRW50cnlSCGxvZ0hlYWRzEjkKBGRhdGEYAiABKAsyJS5hbnl0eXBlLm1vZG'
    'VsLlNtYXJ0QmxvY2tTbmFwc2hvdEJhc2VSBGRhdGESOgoIZmlsZUtleXMYAyADKAsyHi5hbnl0'
    'eXBlLm1vZGVsLkNoYW5nZS5GaWxlS2V5c1IIZmlsZUtleXMaOwoNTG9nSGVhZHNFbnRyeRIQCg'
    'NrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgBGpUBCghGaWxlS2V5cxIS'
    'CgRoYXNoGAEgASgJUgRoYXNoEjwKBGtleXMYAiADKAsyKC5hbnl0eXBlLm1vZGVsLkNoYW5nZS'
    '5GaWxlS2V5cy5LZXlzRW50cnlSBGtleXMaNwoJS2V5c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5'
    'EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAEavQwKB0NvbnRlbnQSRQoLYmxvY2tDcmVhdGUYAS'
    'ABKAsyIS5hbnl0eXBlLm1vZGVsLkNoYW5nZS5CbG9ja0NyZWF0ZUgAUgtibG9ja0NyZWF0ZRJF'
    'CgtibG9ja1VwZGF0ZRgCIAEoCzIhLmFueXR5cGUubW9kZWwuQ2hhbmdlLkJsb2NrVXBkYXRlSA'
    'BSC2Jsb2NrVXBkYXRlEkUKC2Jsb2NrUmVtb3ZlGAMgASgLMiEuYW55dHlwZS5tb2RlbC5DaGFu'
    'Z2UuQmxvY2tSZW1vdmVIAFILYmxvY2tSZW1vdmUSPwoJYmxvY2tNb3ZlGAQgASgLMh8uYW55dH'
    'lwZS5tb2RlbC5DaGFuZ2UuQmxvY2tNb3ZlSABSCWJsb2NrTW92ZRJOCg5ibG9ja0R1cGxpY2F0'
    'ZRgFIAEoCzIkLmFueXR5cGUubW9kZWwuQ2hhbmdlLkJsb2NrRHVwbGljYXRlSABSDmJsb2NrRH'
    'VwbGljYXRlEkUKC3JlbGF0aW9uQWRkGDIgASgLMiEuYW55dHlwZS5tb2RlbC5DaGFuZ2UuUmVs'
    'YXRpb25BZGRIAFILcmVsYXRpb25BZGQSTgoOcmVsYXRpb25SZW1vdmUYMyABKAsyJC5hbnl0eX'
    'BlLm1vZGVsLkNoYW5nZS5SZWxhdGlvblJlbW92ZUgAUg5yZWxhdGlvblJlbW92ZRJCCgpkZXRh'
    'aWxzU2V0GGQgASgLMiAuYW55dHlwZS5tb2RlbC5DaGFuZ2UuRGV0YWlsc1NldEgAUgpkZXRhaW'
    'xzU2V0EkgKDGRldGFpbHNVbnNldBhlIAEoCzIiLmFueXR5cGUubW9kZWwuQ2hhbmdlLkRldGFp'
    'bHNVbnNldEgAUgxkZXRhaWxzVW5zZXQSSwoNb2JqZWN0VHlwZUFkZBhpIAEoCzIjLmFueXR5cG'
    'UubW9kZWwuQ2hhbmdlLk9iamVjdFR5cGVBZGRIAFINb2JqZWN0VHlwZUFkZBJUChBvYmplY3RU'
    'eXBlUmVtb3ZlGGogASgLMiYuYW55dHlwZS5tb2RlbC5DaGFuZ2UuT2JqZWN0VHlwZVJlbW92ZU'
    'gAUhBvYmplY3RUeXBlUmVtb3ZlEkUKC3N0b3JlS2V5U2V0GGsgASgLMiEuYW55dHlwZS5tb2Rl'
    'bC5DaGFuZ2UuU3RvcmVLZXlTZXRIAFILc3RvcmVLZXlTZXQSSwoNc3RvcmVLZXlVbnNldBhsIA'
    'EoCzIjLmFueXR5cGUubW9kZWwuQ2hhbmdlLlN0b3JlS2V5VW5zZXRIAFINc3RvcmVLZXlVbnNl'
    'dBJUChBzdG9yZVNsaWNlVXBkYXRlGG0gASgLMiYuYW55dHlwZS5tb2RlbC5DaGFuZ2UuU3Rvcm'
    'VTbGljZVVwZGF0ZUgAUhBzdG9yZVNsaWNlVXBkYXRlEnUKG29yaWdpbmFsQ3JlYXRlZFRpbWVz'
    'dGFtcFNldBhuIAEoCzIxLmFueXR5cGUubW9kZWwuQ2hhbmdlLk9yaWdpbmFsQ3JlYXRlZFRpbW'
    'VzdGFtcFNldEgAUhtvcmlnaW5hbENyZWF0ZWRUaW1lc3RhbXBTZXQSRQoLc2V0RmlsZUluZm8Y'
    'byABKAsyIS5hbnl0eXBlLm1vZGVsLkNoYW5nZS5TZXRGaWxlSW5mb0gAUgtzZXRGaWxlSW5mbx'
    'JaChJub3RpZmljYXRpb25DcmVhdGUYcCABKAsyKC5hbnl0eXBlLm1vZGVsLkNoYW5nZS5Ob3Rp'
    'ZmljYXRpb25DcmVhdGVIAFISbm90aWZpY2F0aW9uQ3JlYXRlEloKEm5vdGlmaWNhdGlvblVwZG'
    'F0ZRhxIAEoCzIoLmFueXR5cGUubW9kZWwuQ2hhbmdlLk5vdGlmaWNhdGlvblVwZGF0ZUgAUhJu'
    'b3RpZmljYXRpb25VcGRhdGUSPwoJZGV2aWNlQWRkGHIgASgLMh8uYW55dHlwZS5tb2RlbC5DaG'
    'FuZ2UuRGV2aWNlQWRkSABSCWRldmljZUFkZBJICgxkZXZpY2VVcGRhdGUYcyABKAsyIi5hbnl0'
    'eXBlLm1vZGVsLkNoYW5nZS5EZXZpY2VVcGRhdGVIAFIMZGV2aWNlVXBkYXRlQgcKBXZhbHVlSg'
    'QIZhBnSgQIZxBoSgQIaBBpGpIBCgtCbG9ja0NyZWF0ZRIaCgh0YXJnZXRJZBgBIAEoCVIIdGFy'
    'Z2V0SWQSOQoIcG9zaXRpb24YAiABKA4yHS5hbnl0eXBlLm1vZGVsLkJsb2NrLlBvc2l0aW9uUg'
    'hwb3NpdGlvbhIsCgZibG9ja3MYAyADKAsyFC5hbnl0eXBlLm1vZGVsLkJsb2NrUgZibG9ja3Ma'
    'JQoLQmxvY2tVcGRhdGUSFgoGZXZlbnRzGAIgAygMUgZldmVudHMaHwoLQmxvY2tSZW1vdmUSEA'
    'oDaWRzGAEgAygJUgNpZHMadAoJQmxvY2tNb3ZlEhoKCHRhcmdldElkGAEgASgJUgh0YXJnZXRJ'
    'ZBI5Cghwb3NpdGlvbhgCIAEoDjIdLmFueXR5cGUubW9kZWwuQmxvY2suUG9zaXRpb25SCHBvc2'
    'l0aW9uEhAKA2lkcxgDIAMoCVIDaWRzGnkKDkJsb2NrRHVwbGljYXRlEhoKCHRhcmdldElkGAEg'
    'ASgJUgh0YXJnZXRJZBI5Cghwb3NpdGlvbhgCIAEoDjIdLmFueXR5cGUubW9kZWwuQmxvY2suUG'
    '9zaXRpb25SCHBvc2l0aW9uEhAKA2lkcxgDIAMoCVIDaWRzGkwKCkRldGFpbHNTZXQSEAoDa2V5'
    'GAEgASgJUgNrZXkSLAoFdmFsdWUYAiABKAsyFi5nb29nbGUucHJvdG9idWYuVmFsdWVSBXZhbH'
    'VlGiAKDERldGFpbHNVbnNldBIQCgNrZXkYASABKAlSA2tleRpQCgtSZWxhdGlvbkFkZBJBCg1y'
    'ZWxhdGlvbkxpbmtzGAEgAygLMhsuYW55dHlwZS5tb2RlbC5SZWxhdGlvbkxpbmtSDXJlbGF0aW'
    '9uTGlua3MaMgoOUmVsYXRpb25SZW1vdmUSIAoLcmVsYXRpb25LZXkYASADKAlSC3JlbGF0aW9u'
    'S2V5GjMKDU9iamVjdFR5cGVBZGQSEAoDdXJsGAEgASgJUgN1cmwSEAoDa2V5GAIgASgJUgNrZX'
    'kaNgoQT2JqZWN0VHlwZVJlbW92ZRIQCgN1cmwYASABKAlSA3VybBIQCgNrZXkYAiABKAlSA2tl'
    'eRpPCgtTdG9yZUtleVNldBISCgRwYXRoGAEgAygJUgRwYXRoEiwKBXZhbHVlGAIgASgLMhYuZ2'
    '9vZ2xlLnByb3RvYnVmLlZhbHVlUgV2YWx1ZRojCg1TdG9yZUtleVVuc2V0EhIKBHBhdGgYASAD'
    'KAlSBHBhdGgagAMKEFN0b3JlU2xpY2VVcGRhdGUSEAoDa2V5GAEgASgJUgNrZXkSPgoDYWRkGA'
    'IgASgLMiouYW55dHlwZS5tb2RlbC5DaGFuZ2UuU3RvcmVTbGljZVVwZGF0ZS5BZGRIAFIDYWRk'
    'EkcKBnJlbW92ZRgDIAEoCzItLmFueXR5cGUubW9kZWwuQ2hhbmdlLlN0b3JlU2xpY2VVcGRhdG'
    'UuUmVtb3ZlSABSBnJlbW92ZRJBCgRtb3ZlGAQgASgLMisuYW55dHlwZS5tb2RlbC5DaGFuZ2Uu'
    'U3RvcmVTbGljZVVwZGF0ZS5Nb3ZlSABSBG1vdmUaMQoDQWRkEhgKB2FmdGVySWQYASABKAlSB2'
    'FmdGVySWQSEAoDaWRzGAIgAygJUgNpZHMaGgoGUmVtb3ZlEhAKA2lkcxgBIAMoCVIDaWRzGjIK'
    'BE1vdmUSGAoHYWZ0ZXJJZBgBIAEoCVIHYWZ0ZXJJZBIQCgNpZHMYAiADKAlSA2lkc0ILCglvcG'
    'VyYXRpb24aLQobT3JpZ2luYWxDcmVhdGVkVGltZXN0YW1wU2V0Eg4KAnRzGAEgASgDUgJ0cxpC'
    'CgtTZXRGaWxlSW5mbxIzCghmaWxlSW5mbxgBIAEoCzIXLmFueXR5cGUubW9kZWwuRmlsZUluZm'
    '9SCGZpbGVJbmZvGlUKEk5vdGlmaWNhdGlvbkNyZWF0ZRI/Cgxub3RpZmljYXRpb24YASABKAsy'
    'Gy5hbnl0eXBlLm1vZGVsLk5vdGlmaWNhdGlvblIMbm90aWZpY2F0aW9uGmAKEk5vdGlmaWNhdG'
    'lvblVwZGF0ZRIOCgJpZBgBIAEoCVICaWQSOgoGc3RhdHVzGAIgASgOMiIuYW55dHlwZS5tb2Rl'
    'bC5Ob3RpZmljYXRpb24uU3RhdHVzUgZzdGF0dXMaPgoJRGV2aWNlQWRkEjEKBmRldmljZRgBIA'
    'EoCzIZLmFueXR5cGUubW9kZWwuRGV2aWNlSW5mb1IGZGV2aWNlGjIKDERldmljZVVwZGF0ZRIO'
    'CgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use changeNoSnapshotDescriptor instead')
const ChangeNoSnapshot$json = {
  '1': 'ChangeNoSnapshot',
  '2': [
    {
      '1': 'content',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Change.Content',
      '10': 'content'
    },
    {
      '1': 'fileKeys',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Change.FileKeys',
      '10': 'fileKeys'
    },
    {'1': 'timestamp', '3': 7, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'version', '3': 8, '4': 1, '5': 13, '10': 'version'},
    {'1': 'changeType', '3': 9, '4': 1, '5': 13, '10': 'changeType'},
  ],
};

/// Descriptor for `ChangeNoSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeNoSnapshotDescriptor = $convert.base64Decode(
    'ChBDaGFuZ2VOb1NuYXBzaG90EjcKB2NvbnRlbnQYAyADKAsyHS5hbnl0eXBlLm1vZGVsLkNoYW'
    '5nZS5Db250ZW50Ugdjb250ZW50EjoKCGZpbGVLZXlzGAYgAygLMh4uYW55dHlwZS5tb2RlbC5D'
    'aGFuZ2UuRmlsZUtleXNSCGZpbGVLZXlzEhwKCXRpbWVzdGFtcBgHIAEoA1IJdGltZXN0YW1wEh'
    'gKB3ZlcnNpb24YCCABKA1SB3ZlcnNpb24SHgoKY2hhbmdlVHlwZRgJIAEoDVIKY2hhbmdlVHlw'
    'ZQ==');

@$core.Deprecated('Use storeChangeDescriptor instead')
const StoreChange$json = {
  '1': 'StoreChange',
  '2': [
    {
      '1': 'changeSet',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.StoreChangeContent',
      '10': 'changeSet'
    },
  ],
};

/// Descriptor for `StoreChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeChangeDescriptor = $convert.base64Decode(
    'CgtTdG9yZUNoYW5nZRI/CgljaGFuZ2VTZXQYASADKAsyIS5hbnl0eXBlLm1vZGVsLlN0b3JlQ2'
    'hhbmdlQ29udGVudFIJY2hhbmdlU2V0');

@$core.Deprecated('Use storeChangeContentDescriptor instead')
const StoreChangeContent$json = {
  '1': 'StoreChangeContent',
  '2': [
    {
      '1': 'create',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.DocumentCreate',
      '9': 0,
      '10': 'create'
    },
    {
      '1': 'modify',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.DocumentModify',
      '9': 0,
      '10': 'modify'
    },
    {
      '1': 'delete',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.DocumentDelete',
      '9': 0,
      '10': 'delete'
    },
  ],
  '8': [
    {'1': 'change'},
  ],
};

/// Descriptor for `StoreChangeContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeChangeContentDescriptor = $convert.base64Decode(
    'ChJTdG9yZUNoYW5nZUNvbnRlbnQSNwoGY3JlYXRlGAEgASgLMh0uYW55dHlwZS5tb2RlbC5Eb2'
    'N1bWVudENyZWF0ZUgAUgZjcmVhdGUSNwoGbW9kaWZ5GAIgASgLMh0uYW55dHlwZS5tb2RlbC5E'
    'b2N1bWVudE1vZGlmeUgAUgZtb2RpZnkSNwoGZGVsZXRlGAMgASgLMh0uYW55dHlwZS5tb2RlbC'
    '5Eb2N1bWVudERlbGV0ZUgAUgZkZWxldGVCCAoGY2hhbmdl');

@$core.Deprecated('Use documentCreateDescriptor instead')
const DocumentCreate$json = {
  '1': 'DocumentCreate',
  '2': [
    {'1': 'collection', '3': 1, '4': 1, '5': 9, '10': 'collection'},
    {'1': 'documentId', '3': 2, '4': 1, '5': 9, '10': 'documentId'},
    {'1': 'value', '3': 3, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `DocumentCreate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentCreateDescriptor = $convert.base64Decode(
    'Cg5Eb2N1bWVudENyZWF0ZRIeCgpjb2xsZWN0aW9uGAEgASgJUgpjb2xsZWN0aW9uEh4KCmRvY3'
    'VtZW50SWQYAiABKAlSCmRvY3VtZW50SWQSFAoFdmFsdWUYAyABKAlSBXZhbHVl');

@$core.Deprecated('Use documentModifyDescriptor instead')
const DocumentModify$json = {
  '1': 'DocumentModify',
  '2': [
    {'1': 'collection', '3': 1, '4': 1, '5': 9, '10': 'collection'},
    {'1': 'documentId', '3': 2, '4': 1, '5': 9, '10': 'documentId'},
    {
      '1': 'keys',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.KeyModify',
      '10': 'keys'
    },
  ],
};

/// Descriptor for `DocumentModify`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentModifyDescriptor = $convert.base64Decode(
    'Cg5Eb2N1bWVudE1vZGlmeRIeCgpjb2xsZWN0aW9uGAEgASgJUgpjb2xsZWN0aW9uEh4KCmRvY3'
    'VtZW50SWQYAiABKAlSCmRvY3VtZW50SWQSLAoEa2V5cxgEIAMoCzIYLmFueXR5cGUubW9kZWwu'
    'S2V5TW9kaWZ5UgRrZXlz');

@$core.Deprecated('Use keyModifyDescriptor instead')
const KeyModify$json = {
  '1': 'KeyModify',
  '2': [
    {'1': 'keyPath', '3': 1, '4': 3, '5': 9, '10': 'keyPath'},
    {
      '1': 'modifyOp',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.ModifyOp',
      '10': 'modifyOp'
    },
    {'1': 'modifyValue', '3': 4, '4': 1, '5': 9, '10': 'modifyValue'},
  ],
};

/// Descriptor for `KeyModify`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyModifyDescriptor = $convert.base64Decode(
    'CglLZXlNb2RpZnkSGAoHa2V5UGF0aBgBIAMoCVIHa2V5UGF0aBIzCghtb2RpZnlPcBgDIAEoDj'
    'IXLmFueXR5cGUubW9kZWwuTW9kaWZ5T3BSCG1vZGlmeU9wEiAKC21vZGlmeVZhbHVlGAQgASgJ'
    'Ugttb2RpZnlWYWx1ZQ==');

@$core.Deprecated('Use documentDeleteDescriptor instead')
const DocumentDelete$json = {
  '1': 'DocumentDelete',
  '2': [
    {'1': 'collection', '3': 1, '4': 1, '5': 9, '10': 'collection'},
    {'1': 'documentId', '3': 2, '4': 1, '5': 9, '10': 'documentId'},
  ],
};

/// Descriptor for `DocumentDelete`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List documentDeleteDescriptor = $convert.base64Decode(
    'Cg5Eb2N1bWVudERlbGV0ZRIeCgpjb2xsZWN0aW9uGAEgASgJUgpjb2xsZWN0aW9uEh4KCmRvY3'
    'VtZW50SWQYAiABKAlSCmRvY3VtZW50SWQ=');
