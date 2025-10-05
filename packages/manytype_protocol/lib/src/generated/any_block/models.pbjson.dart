// This is a generated file - do not edit.
//
// Generated from any_block/models.proto.

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

@$core.Deprecated('Use smartBlockTypeDescriptor instead')
const SmartBlockType$json = {
  '1': 'SmartBlockType',
  '2': [
    {'1': 'AccountOld', '2': 0},
    {'1': 'Page', '2': 16},
    {'1': 'ProfilePage', '2': 17},
    {'1': 'Home', '2': 32},
    {'1': 'Archive', '2': 48},
    {'1': 'Widget', '2': 112},
    {'1': 'File', '2': 256},
    {'1': 'Template', '2': 288},
    {'1': 'BundledTemplate', '2': 289},
    {'1': 'BundledRelation', '2': 512},
    {'1': 'SubObject', '2': 513},
    {'1': 'BundledObjectType', '2': 514},
    {'1': 'AnytypeProfile', '2': 515},
    {'1': 'Date', '2': 516},
    {'1': 'Workspace', '2': 518},
    {'1': 'STRelation', '2': 521},
    {'1': 'STType', '2': 528},
    {'1': 'STRelationOption', '2': 529},
    {'1': 'SpaceView', '2': 530},
    {'1': 'Identity', '2': 532},
    {'1': 'Participant', '2': 534},
    {'1': 'MissingObject', '2': 519},
    {'1': 'FileObject', '2': 533},
    {'1': 'NotificationObject', '2': 535},
    {'1': 'DevicesObject', '2': 536},
    {'1': 'ChatObjectDeprecated', '2': 537},
    {'1': 'ChatDerivedObject', '2': 544},
    {'1': 'AccountObject', '2': 545},
    {'1': 'DiscussionObject', '2': 546},
  ],
};

/// Descriptor for `SmartBlockType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List smartBlockTypeDescriptor = $convert.base64Decode(
    'Cg5TbWFydEJsb2NrVHlwZRIOCgpBY2NvdW50T2xkEAASCAoEUGFnZRAQEg8KC1Byb2ZpbGVQYW'
    'dlEBESCAoESG9tZRAgEgsKB0FyY2hpdmUQMBIKCgZXaWRnZXQQcBIJCgRGaWxlEIACEg0KCFRl'
    'bXBsYXRlEKACEhQKD0J1bmRsZWRUZW1wbGF0ZRChAhIUCg9CdW5kbGVkUmVsYXRpb24QgAQSDg'
    'oJU3ViT2JqZWN0EIEEEhYKEUJ1bmRsZWRPYmplY3RUeXBlEIIEEhMKDkFueXR5cGVQcm9maWxl'
    'EIMEEgkKBERhdGUQhAQSDgoJV29ya3NwYWNlEIYEEg8KClNUUmVsYXRpb24QiQQSCwoGU1RUeX'
    'BlEJAEEhUKEFNUUmVsYXRpb25PcHRpb24QkQQSDgoJU3BhY2VWaWV3EJIEEg0KCElkZW50aXR5'
    'EJQEEhAKC1BhcnRpY2lwYW50EJYEEhIKDU1pc3NpbmdPYmplY3QQhwQSDwoKRmlsZU9iamVjdB'
    'CVBBIXChJOb3RpZmljYXRpb25PYmplY3QQlwQSEgoNRGV2aWNlc09iamVjdBCYBBIZChRDaGF0'
    'T2JqZWN0RGVwcmVjYXRlZBCZBBIWChFDaGF0RGVyaXZlZE9iamVjdBCgBBISCg1BY2NvdW50T2'
    'JqZWN0EKEEEhUKEERpc2N1c3Npb25PYmplY3QQogQ=');

@$core.Deprecated('Use relationFormatDescriptor instead')
const RelationFormat$json = {
  '1': 'RelationFormat',
  '2': [
    {'1': 'longtext', '2': 0},
    {'1': 'shorttext', '2': 1},
    {'1': 'number', '2': 2},
    {'1': 'status', '2': 3},
    {'1': 'tag', '2': 11},
    {'1': 'date', '2': 4},
    {'1': 'file', '2': 5},
    {'1': 'checkbox', '2': 6},
    {'1': 'url', '2': 7},
    {'1': 'email', '2': 8},
    {'1': 'phone', '2': 9},
    {'1': 'emoji', '2': 10},
    {'1': 'object', '2': 100},
    {'1': 'relations', '2': 101},
  ],
};

/// Descriptor for `RelationFormat`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List relationFormatDescriptor = $convert.base64Decode(
    'Cg5SZWxhdGlvbkZvcm1hdBIMCghsb25ndGV4dBAAEg0KCXNob3J0dGV4dBABEgoKBm51bWJlch'
    'ACEgoKBnN0YXR1cxADEgcKA3RhZxALEggKBGRhdGUQBBIICgRmaWxlEAUSDAoIY2hlY2tib3gQ'
    'BhIHCgN1cmwQBxIJCgVlbWFpbBAIEgkKBXBob25lEAkSCQoFZW1vamkQChIKCgZvYmplY3QQZB'
    'INCglyZWxhdGlvbnMQZQ==');

@$core.Deprecated('Use objectOriginDescriptor instead')
const ObjectOrigin$json = {
  '1': 'ObjectOrigin',
  '2': [
    {'1': 'none', '2': 0},
    {'1': 'clipboard', '2': 1},
    {'1': 'dragAndDrop', '2': 2},
    {'1': 'import', '2': 3},
    {'1': 'webclipper', '2': 4},
    {'1': 'sharingExtension', '2': 5},
    {'1': 'usecase', '2': 6},
    {'1': 'builtin', '2': 7},
    {'1': 'bookmark', '2': 8},
    {'1': 'api', '2': 9},
  ],
};

/// Descriptor for `ObjectOrigin`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List objectOriginDescriptor = $convert.base64Decode(
    'CgxPYmplY3RPcmlnaW4SCAoEbm9uZRAAEg0KCWNsaXBib2FyZBABEg8KC2RyYWdBbmREcm9wEA'
    'ISCgoGaW1wb3J0EAMSDgoKd2ViY2xpcHBlchAEEhQKEHNoYXJpbmdFeHRlbnNpb24QBRILCgd1'
    'c2VjYXNlEAYSCwoHYnVpbHRpbhAHEgwKCGJvb2ttYXJrEAgSBwoDYXBpEAk=');

@$core.Deprecated('Use spaceStatusDescriptor instead')
const SpaceStatus$json = {
  '1': 'SpaceStatus',
  '2': [
    {'1': 'Unknown', '2': 0},
    {'1': 'Loading', '2': 1},
    {'1': 'Ok', '2': 2},
    {'1': 'Missing', '2': 3},
    {'1': 'Error', '2': 4},
    {'1': 'RemoteWaitingDeletion', '2': 5},
    {'1': 'RemoteDeleted', '2': 6},
    {'1': 'SpaceDeleted', '2': 7},
    {'1': 'SpaceActive', '2': 8},
    {'1': 'SpaceJoining', '2': 9},
    {'1': 'SpaceRemoving', '2': 10},
  ],
};

/// Descriptor for `SpaceStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spaceStatusDescriptor = $convert.base64Decode(
    'CgtTcGFjZVN0YXR1cxILCgdVbmtub3duEAASCwoHTG9hZGluZxABEgYKAk9rEAISCwoHTWlzc2'
    'luZxADEgkKBUVycm9yEAQSGQoVUmVtb3RlV2FpdGluZ0RlbGV0aW9uEAUSEQoNUmVtb3RlRGVs'
    'ZXRlZBAGEhAKDFNwYWNlRGVsZXRlZBAHEg8KC1NwYWNlQWN0aXZlEAgSEAoMU3BhY2VKb2luaW'
    '5nEAkSEQoNU3BhY2VSZW1vdmluZxAK');

@$core.Deprecated('Use participantPermissionsDescriptor instead')
const ParticipantPermissions$json = {
  '1': 'ParticipantPermissions',
  '2': [
    {'1': 'Reader', '2': 0},
    {'1': 'Writer', '2': 1},
    {'1': 'Owner', '2': 2},
    {'1': 'NoPermissions', '2': 3},
  ],
};

/// Descriptor for `ParticipantPermissions`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List participantPermissionsDescriptor =
    $convert.base64Decode(
        'ChZQYXJ0aWNpcGFudFBlcm1pc3Npb25zEgoKBlJlYWRlchAAEgoKBldyaXRlchABEgkKBU93bm'
        'VyEAISEQoNTm9QZXJtaXNzaW9ucxAD');

@$core.Deprecated('Use inviteTypeDescriptor instead')
const InviteType$json = {
  '1': 'InviteType',
  '2': [
    {'1': 'Member', '2': 0},
    {'1': 'Guest', '2': 1},
    {'1': 'WithoutApprove', '2': 2},
  ],
};

/// Descriptor for `InviteType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List inviteTypeDescriptor = $convert.base64Decode(
    'CgpJbnZpdGVUeXBlEgoKBk1lbWJlchAAEgkKBUd1ZXN0EAESEgoOV2l0aG91dEFwcHJvdmUQAg'
    '==');

@$core.Deprecated('Use participantStatusDescriptor instead')
const ParticipantStatus$json = {
  '1': 'ParticipantStatus',
  '2': [
    {'1': 'Joining', '2': 0},
    {'1': 'Active', '2': 1},
    {'1': 'Removed', '2': 2},
    {'1': 'Declined', '2': 3},
    {'1': 'Removing', '2': 4},
    {'1': 'Canceled', '2': 5},
  ],
};

/// Descriptor for `ParticipantStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List participantStatusDescriptor = $convert.base64Decode(
    'ChFQYXJ0aWNpcGFudFN0YXR1cxILCgdKb2luaW5nEAASCgoGQWN0aXZlEAESCwoHUmVtb3ZlZB'
    'ACEgwKCERlY2xpbmVkEAMSDAoIUmVtb3ZpbmcQBBIMCghDYW5jZWxlZBAF');

@$core.Deprecated('Use spaceAccessTypeDescriptor instead')
const SpaceAccessType$json = {
  '1': 'SpaceAccessType',
  '2': [
    {'1': 'Private', '2': 0},
    {'1': 'Personal', '2': 1},
    {'1': 'Shared', '2': 2},
  ],
};

/// Descriptor for `SpaceAccessType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spaceAccessTypeDescriptor = $convert.base64Decode(
    'Cg9TcGFjZUFjY2Vzc1R5cGUSCwoHUHJpdmF0ZRAAEgwKCFBlcnNvbmFsEAESCgoGU2hhcmVkEA'
    'I=');

@$core.Deprecated('Use spaceUxTypeDescriptor instead')
const SpaceUxType$json = {
  '1': 'SpaceUxType',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'Data', '2': 1},
    {'1': 'Stream', '2': 2},
    {'1': 'Chat', '2': 3},
    {'1': 'OneToOne', '2': 4},
  ],
};

/// Descriptor for `SpaceUxType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spaceUxTypeDescriptor = $convert.base64Decode(
    'CgtTcGFjZVV4VHlwZRIICgROb25lEAASCAoERGF0YRABEgoKBlN0cmVhbRACEggKBENoYXQQAx'
    'IMCghPbmVUb09uZRAE');

@$core.Deprecated('Use spaceTypeDescriptor instead')
const SpaceType$json = {
  '1': 'SpaceType',
  '2': [
    {'1': 'SpaceTypeUnknown', '2': 0},
    {'1': 'SpaceTypeRegular', '2': 1},
    {'1': 'SpaceTypeTech', '2': 2},
    {'1': 'SpaceTypeChat', '2': 3},
    {'1': 'SpaceTypeOneToOne', '2': 4},
  ],
};

/// Descriptor for `SpaceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spaceTypeDescriptor = $convert.base64Decode(
    'CglTcGFjZVR5cGUSFAoQU3BhY2VUeXBlVW5rbm93bhAAEhQKEFNwYWNlVHlwZVJlZ3VsYXIQAR'
    'IRCg1TcGFjZVR5cGVUZWNoEAISEQoNU3BhY2VUeXBlQ2hhdBADEhUKEVNwYWNlVHlwZU9uZVRv'
    'T25lEAQ=');

@$core.Deprecated('Use imageKindDescriptor instead')
const ImageKind$json = {
  '1': 'ImageKind',
  '2': [
    {'1': 'Basic', '2': 0},
    {'1': 'Cover', '2': 1},
    {'1': 'Icon', '2': 2},
    {'1': 'AutomaticallyAdded', '2': 3},
  ],
};

/// Descriptor for `ImageKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List imageKindDescriptor = $convert.base64Decode(
    'CglJbWFnZUtpbmQSCQoFQmFzaWMQABIJCgVDb3ZlchABEggKBEljb24QAhIWChJBdXRvbWF0aW'
    'NhbGx5QWRkZWQQAw==');

@$core.Deprecated('Use fileIndexingStatusDescriptor instead')
const FileIndexingStatus$json = {
  '1': 'FileIndexingStatus',
  '2': [
    {'1': 'NotIndexed', '2': 0},
    {'1': 'Indexed', '2': 1},
    {'1': 'NotFound', '2': 2},
  ],
};

/// Descriptor for `FileIndexingStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List fileIndexingStatusDescriptor = $convert.base64Decode(
    'ChJGaWxlSW5kZXhpbmdTdGF0dXMSDgoKTm90SW5kZXhlZBAAEgsKB0luZGV4ZWQQARIMCghOb3'
    'RGb3VuZBAC');

@$core.Deprecated('Use spaceShareableStatusDescriptor instead')
const SpaceShareableStatus$json = {
  '1': 'SpaceShareableStatus',
  '2': [
    {'1': 'StatusUnknown', '2': 0},
    {'1': 'StatusShareable', '2': 1},
    {'1': 'StatusNotShareable', '2': 2},
  ],
};

/// Descriptor for `SpaceShareableStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spaceShareableStatusDescriptor = $convert.base64Decode(
    'ChRTcGFjZVNoYXJlYWJsZVN0YXR1cxIRCg1TdGF0dXNVbmtub3duEAASEwoPU3RhdHVzU2hhcm'
    'VhYmxlEAESFgoSU3RhdHVzTm90U2hhcmVhYmxlEAI=');

@$core.Deprecated('Use nameserviceNameTypeDescriptor instead')
const NameserviceNameType$json = {
  '1': 'NameserviceNameType',
  '2': [
    {'1': 'AnyName', '2': 0},
  ],
};

/// Descriptor for `NameserviceNameType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nameserviceNameTypeDescriptor =
    $convert.base64Decode('ChNOYW1lc2VydmljZU5hbWVUeXBlEgsKB0FueU5hbWUQAA==');

@$core.Deprecated('Use deviceNetworkTypeDescriptor instead')
const DeviceNetworkType$json = {
  '1': 'DeviceNetworkType',
  '2': [
    {'1': 'WIFI', '2': 0},
    {'1': 'CELLULAR', '2': 1},
    {'1': 'NOT_CONNECTED', '2': 2},
  ],
};

/// Descriptor for `DeviceNetworkType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deviceNetworkTypeDescriptor = $convert.base64Decode(
    'ChFEZXZpY2VOZXR3b3JrVHlwZRIICgRXSUZJEAASDAoIQ0VMTFVMQVIQARIRCg1OT1RfQ09OTk'
    'VDVEVEEAI=');

@$core.Deprecated('Use syncStatusDescriptor instead')
const SyncStatus$json = {
  '1': 'SyncStatus',
  '2': [
    {'1': 'SyncStatusSynced', '2': 0},
    {'1': 'SyncStatusSyncing', '2': 1},
    {'1': 'SyncStatusError', '2': 2},
    {'1': 'SyncStatusQueued', '2': 3},
  ],
};

/// Descriptor for `SyncStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List syncStatusDescriptor = $convert.base64Decode(
    'CgpTeW5jU3RhdHVzEhQKEFN5bmNTdGF0dXNTeW5jZWQQABIVChFTeW5jU3RhdHVzU3luY2luZx'
    'ABEhMKD1N5bmNTdGF0dXNFcnJvchACEhQKEFN5bmNTdGF0dXNRdWV1ZWQQAw==');

@$core.Deprecated('Use syncErrorDescriptor instead')
const SyncError$json = {
  '1': 'SyncError',
  '2': [
    {'1': 'SyncErrorNull', '2': 0},
    {'1': 'SyncErrorIncompatibleVersion', '2': 2},
    {'1': 'SyncErrorNetworkError', '2': 3},
    {'1': 'SyncErrorOversized', '2': 4},
  ],
};

/// Descriptor for `SyncError`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List syncErrorDescriptor = $convert.base64Decode(
    'CglTeW5jRXJyb3ISEQoNU3luY0Vycm9yTnVsbBAAEiAKHFN5bmNFcnJvckluY29tcGF0aWJsZV'
    'ZlcnNpb24QAhIZChVTeW5jRXJyb3JOZXR3b3JrRXJyb3IQAxIWChJTeW5jRXJyb3JPdmVyc2l6'
    'ZWQQBA==');

@$core.Deprecated('Use templateNamePrefillTypeDescriptor instead')
const TemplateNamePrefillType$json = {
  '1': 'TemplateNamePrefillType',
  '2': [
    {'1': 'Empty', '2': 0},
    {'1': 'FromTemplateName', '2': 1},
  ],
};

/// Descriptor for `TemplateNamePrefillType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List templateNamePrefillTypeDescriptor =
    $convert.base64Decode(
        'ChdUZW1wbGF0ZU5hbWVQcmVmaWxsVHlwZRIJCgVFbXB0eRAAEhQKEEZyb21UZW1wbGF0ZU5hbW'
        'UQAQ==');

@$core.Deprecated('Use smartBlockSnapshotBaseDescriptor instead')
const SmartBlockSnapshotBase$json = {
  '1': 'SmartBlockSnapshotBase',
  '2': [
    {
      '1': 'blocks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block',
      '10': 'blocks'
    },
    {
      '1': 'details',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'details'
    },
    {
      '1': 'fileKeys',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '8': {'3': true},
      '10': 'fileKeys',
    },
    {
      '1': 'extraRelations',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Relation',
      '8': {'3': true},
      '10': 'extraRelations',
    },
    {'1': 'objectTypes', '3': 5, '4': 3, '5': 9, '10': 'objectTypes'},
    {
      '1': 'collections',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'collections'
    },
    {
      '1': 'removedCollectionKeys',
      '3': 8,
      '4': 3,
      '5': 9,
      '10': 'removedCollectionKeys'
    },
    {
      '1': 'relationLinks',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.RelationLink',
      '10': 'relationLinks'
    },
    {'1': 'key', '3': 9, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'originalCreatedTimestamp',
      '3': 10,
      '4': 1,
      '5': 3,
      '10': 'originalCreatedTimestamp'
    },
    {
      '1': 'fileInfo',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.FileInfo',
      '10': 'fileInfo'
    },
  ],
};

/// Descriptor for `SmartBlockSnapshotBase`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List smartBlockSnapshotBaseDescriptor = $convert.base64Decode(
    'ChZTbWFydEJsb2NrU25hcHNob3RCYXNlEiwKBmJsb2NrcxgBIAMoCzIULmFueXR5cGUubW9kZW'
    'wuQmxvY2tSBmJsb2NrcxIxCgdkZXRhaWxzGAIgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVj'
    'dFIHZGV0YWlscxI3CghmaWxlS2V5cxgDIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RCAh'
    'gBUghmaWxlS2V5cxJDCg5leHRyYVJlbGF0aW9ucxgEIAMoCzIXLmFueXR5cGUubW9kZWwuUmVs'
    'YXRpb25CAhgBUg5leHRyYVJlbGF0aW9ucxIgCgtvYmplY3RUeXBlcxgFIAMoCVILb2JqZWN0VH'
    'lwZXMSOQoLY29sbGVjdGlvbnMYBiABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0Ugtjb2xs'
    'ZWN0aW9ucxI0ChVyZW1vdmVkQ29sbGVjdGlvbktleXMYCCADKAlSFXJlbW92ZWRDb2xsZWN0aW'
    '9uS2V5cxJBCg1yZWxhdGlvbkxpbmtzGAcgAygLMhsuYW55dHlwZS5tb2RlbC5SZWxhdGlvbkxp'
    'bmtSDXJlbGF0aW9uTGlua3MSEAoDa2V5GAkgASgJUgNrZXkSOgoYb3JpZ2luYWxDcmVhdGVkVG'
    'ltZXN0YW1wGAogASgDUhhvcmlnaW5hbENyZWF0ZWRUaW1lc3RhbXASMwoIZmlsZUluZm8YCyAB'
    'KAsyFy5hbnl0eXBlLm1vZGVsLkZpbGVJbmZvUghmaWxlSW5mbw==');

@$core.Deprecated('Use searchDescriptor instead')
const Search$json = {
  '1': 'Search',
  '3': [Search_Result$json, Search_Meta$json, Search_Message$json],
};

@$core.Deprecated('Use searchDescriptor instead')
const Search_Result$json = {
  '1': 'Result',
  '2': [
    {'1': 'objectId', '3': 1, '4': 1, '5': 9, '10': 'objectId'},
    {
      '1': 'details',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'details'
    },
    {
      '1': 'meta',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Search.Meta',
      '10': 'meta'
    },
  ],
};

@$core.Deprecated('Use searchDescriptor instead')
const Search_Meta$json = {
  '1': 'Meta',
  '2': [
    {'1': 'highlight', '3': 1, '4': 1, '5': 9, '10': 'highlight'},
    {
      '1': 'highlightRanges',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Range',
      '10': 'highlightRanges'
    },
    {'1': 'blockId', '3': 3, '4': 1, '5': 9, '10': 'blockId'},
    {'1': 'relationKey', '3': 4, '4': 1, '5': 9, '10': 'relationKey'},
    {
      '1': 'relationDetails',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'relationDetails'
    },
  ],
};

@$core.Deprecated('Use searchDescriptor instead')
const Search_Message$json = {
  '1': 'Message',
  '3': [Search_Message_Sort$json, Search_Message_Result$json],
};

@$core.Deprecated('Use searchDescriptor instead')
const Search_Message_Sort$json = {
  '1': 'Sort',
  '2': [
    {
      '1': 'key',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Search.Message.Sort.Key',
      '10': 'key'
    },
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Search.Message.Sort.Type',
      '10': 'type'
    },
  ],
  '4': [Search_Message_Sort_Key$json, Search_Message_Sort_Type$json],
};

@$core.Deprecated('Use searchDescriptor instead')
const Search_Message_Sort_Key$json = {
  '1': 'Key',
  '2': [
    {'1': 'ORDER_ID', '2': 0},
    {'1': 'SCORE', '2': 1},
    {'1': 'CREATED_AT', '2': 2},
    {'1': 'MODIFIED_AT', '2': 3},
  ],
};

@$core.Deprecated('Use searchDescriptor instead')
const Search_Message_Sort_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'Asc', '2': 0},
    {'1': 'Desc', '2': 1},
  ],
};

@$core.Deprecated('Use searchDescriptor instead')
const Search_Message_Result$json = {
  '1': 'Result',
  '2': [
    {'1': 'chatId', '3': 1, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'messageId', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'score', '3': 3, '4': 1, '5': 3, '10': 'score'},
    {'1': 'highlight', '3': 4, '4': 1, '5': 9, '10': 'highlight'},
    {
      '1': 'highlightRanges',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Range',
      '10': 'highlightRanges'
    },
    {
      '1': 'message',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ChatMessage',
      '10': 'message'
    },
  ],
};

/// Descriptor for `Search`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchDescriptor = $convert.base64Decode(
    'CgZTZWFyY2gahwEKBlJlc3VsdBIaCghvYmplY3RJZBgBIAEoCVIIb2JqZWN0SWQSMQoHZGV0YW'
    'lscxgCIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSB2RldGFpbHMSLgoEbWV0YRgDIAMo'
    'CzIaLmFueXR5cGUubW9kZWwuU2VhcmNoLk1ldGFSBG1ldGEa4wEKBE1ldGESHAoJaGlnaGxpZ2'
    'h0GAEgASgJUgloaWdobGlnaHQSPgoPaGlnaGxpZ2h0UmFuZ2VzGAIgAygLMhQuYW55dHlwZS5t'
    'b2RlbC5SYW5nZVIPaGlnaGxpZ2h0UmFuZ2VzEhgKB2Jsb2NrSWQYAyABKAlSB2Jsb2NrSWQSIA'
    'oLcmVsYXRpb25LZXkYBCABKAlSC3JlbGF0aW9uS2V5EkEKD3JlbGF0aW9uRGV0YWlscxgFIAEo'
    'CzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSD3JlbGF0aW9uRGV0YWlscxrQAwoHTWVzc2FnZR'
    'rZAQoEU29ydBI4CgNrZXkYASABKA4yJi5hbnl0eXBlLm1vZGVsLlNlYXJjaC5NZXNzYWdlLlNv'
    'cnQuS2V5UgNrZXkSOwoEdHlwZRgCIAEoDjInLmFueXR5cGUubW9kZWwuU2VhcmNoLk1lc3NhZ2'
    'UuU29ydC5UeXBlUgR0eXBlIj8KA0tleRIMCghPUkRFUl9JRBAAEgkKBVNDT1JFEAESDgoKQ1JF'
    'QVRFRF9BVBACEg8KC01PRElGSUVEX0FUEAMiGQoEVHlwZRIHCgNBc2MQABIICgREZXNjEAEa6A'
    'EKBlJlc3VsdBIWCgZjaGF0SWQYASABKAlSBmNoYXRJZBIcCgltZXNzYWdlSWQYAiABKAlSCW1l'
    'c3NhZ2VJZBIUCgVzY29yZRgDIAEoA1IFc2NvcmUSHAoJaGlnaGxpZ2h0GAQgASgJUgloaWdobG'
    'lnaHQSPgoPaGlnaGxpZ2h0UmFuZ2VzGAUgAygLMhQuYW55dHlwZS5tb2RlbC5SYW5nZVIPaGln'
    'aGxpZ2h0UmFuZ2VzEjQKB21lc3NhZ2UYBiABKAsyGi5hbnl0eXBlLm1vZGVsLkNoYXRNZXNzYW'
    'dlUgdtZXNzYWdl');

@$core.Deprecated('Use blockDescriptor instead')
const Block$json = {
  '1': 'Block',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'fields',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'fields'
    },
    {
      '1': 'restrictions',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Restrictions',
      '10': 'restrictions'
    },
    {'1': 'childrenIds', '3': 4, '4': 3, '5': 9, '10': 'childrenIds'},
    {'1': 'backgroundColor', '3': 5, '4': 1, '5': 9, '10': 'backgroundColor'},
    {
      '1': 'align',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Align',
      '10': 'align'
    },
    {
      '1': 'verticalAlign',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.VerticalAlign',
      '10': 'verticalAlign'
    },
    {
      '1': 'smartblock',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Smartblock',
      '9': 0,
      '10': 'smartblock'
    },
    {
      '1': 'text',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Text',
      '9': 0,
      '10': 'text'
    },
    {
      '1': 'file',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.File',
      '9': 0,
      '10': 'file'
    },
    {
      '1': 'layout',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Layout',
      '9': 0,
      '10': 'layout'
    },
    {
      '1': 'div',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Div',
      '9': 0,
      '10': 'div'
    },
    {
      '1': 'bookmark',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Bookmark',
      '9': 0,
      '10': 'bookmark'
    },
    {
      '1': 'icon',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Icon',
      '9': 0,
      '10': 'icon'
    },
    {
      '1': 'link',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Link',
      '9': 0,
      '10': 'link'
    },
    {
      '1': 'dataview',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview',
      '9': 0,
      '10': 'dataview'
    },
    {
      '1': 'relation',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Relation',
      '9': 0,
      '10': 'relation'
    },
    {
      '1': 'featuredRelations',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.FeaturedRelations',
      '9': 0,
      '10': 'featuredRelations'
    },
    {
      '1': 'latex',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Latex',
      '9': 0,
      '10': 'latex'
    },
    {
      '1': 'tableOfContents',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.TableOfContents',
      '9': 0,
      '10': 'tableOfContents'
    },
    {
      '1': 'table',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Table',
      '9': 0,
      '10': 'table'
    },
    {
      '1': 'tableColumn',
      '3': 27,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.TableColumn',
      '9': 0,
      '10': 'tableColumn'
    },
    {
      '1': 'tableRow',
      '3': 28,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.TableRow',
      '9': 0,
      '10': 'tableRow'
    },
    {
      '1': 'widget',
      '3': 29,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Widget',
      '9': 0,
      '10': 'widget'
    },
    {
      '1': 'chat',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Chat',
      '9': 0,
      '10': 'chat'
    },
  ],
  '3': [Block_Restrictions$json, Block_Content$json],
  '4': [Block_Position$json, Block_Align$json, Block_VerticalAlign$json],
  '8': [
    {'1': 'content'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Restrictions$json = {
  '1': 'Restrictions',
  '2': [
    {'1': 'read', '3': 1, '4': 1, '5': 8, '10': 'read'},
    {'1': 'edit', '3': 2, '4': 1, '5': 8, '10': 'edit'},
    {'1': 'remove', '3': 3, '4': 1, '5': 8, '10': 'remove'},
    {'1': 'drag', '3': 4, '4': 1, '5': 8, '10': 'drag'},
    {'1': 'dropOn', '3': 5, '4': 1, '5': 8, '10': 'dropOn'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content$json = {
  '1': 'Content',
  '3': [
    Block_Content_Layout$json,
    Block_Content_Link$json,
    Block_Content_Div$json,
    Block_Content_Bookmark$json,
    Block_Content_Icon$json,
    Block_Content_FeaturedRelations$json,
    Block_Content_Text$json,
    Block_Content_File$json,
    Block_Content_Smartblock$json,
    Block_Content_Dataview$json,
    Block_Content_Relation$json,
    Block_Content_Latex$json,
    Block_Content_TableOfContents$json,
    Block_Content_Table$json,
    Block_Content_TableColumn$json,
    Block_Content_TableRow$json,
    Block_Content_Widget$json,
    Block_Content_Chat$json
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Layout$json = {
  '1': 'Layout',
  '2': [
    {
      '1': 'style',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Layout.Style',
      '10': 'style'
    },
  ],
  '4': [Block_Content_Layout_Style$json],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Layout_Style$json = {
  '1': 'Style',
  '2': [
    {'1': 'Row', '2': 0},
    {'1': 'Column', '2': 1},
    {'1': 'Div', '2': 2},
    {'1': 'Header', '2': 3},
    {'1': 'TableRows', '2': 4},
    {'1': 'TableColumns', '2': 5},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Link$json = {
  '1': 'Link',
  '2': [
    {'1': 'targetBlockId', '3': 1, '4': 1, '5': 9, '10': 'targetBlockId'},
    {
      '1': 'style',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Link.Style',
      '10': 'style'
    },
    {
      '1': 'fields',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'fields'
    },
    {
      '1': 'iconSize',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Link.IconSize',
      '10': 'iconSize'
    },
    {
      '1': 'cardStyle',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Link.CardStyle',
      '10': 'cardStyle'
    },
    {
      '1': 'description',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Link.Description',
      '10': 'description'
    },
    {'1': 'relations', '3': 7, '4': 3, '5': 9, '10': 'relations'},
  ],
  '4': [
    Block_Content_Link_IconSize$json,
    Block_Content_Link_Style$json,
    Block_Content_Link_Description$json,
    Block_Content_Link_CardStyle$json
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Link_IconSize$json = {
  '1': 'IconSize',
  '2': [
    {'1': 'SizeNone', '2': 0},
    {'1': 'SizeSmall', '2': 1},
    {'1': 'SizeMedium', '2': 2},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Link_Style$json = {
  '1': 'Style',
  '2': [
    {'1': 'Page', '2': 0},
    {'1': 'Dataview', '2': 1},
    {'1': 'Dashboard', '2': 2},
    {'1': 'Archive', '2': 3},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Link_Description$json = {
  '1': 'Description',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'Added', '2': 1},
    {'1': 'Content', '2': 2},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Link_CardStyle$json = {
  '1': 'CardStyle',
  '2': [
    {'1': 'Text', '2': 0},
    {'1': 'Card', '2': 1},
    {'1': 'Inline', '2': 2},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Div$json = {
  '1': 'Div',
  '2': [
    {
      '1': 'style',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Div.Style',
      '10': 'style'
    },
  ],
  '4': [Block_Content_Div_Style$json],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Div_Style$json = {
  '1': 'Style',
  '2': [
    {'1': 'Line', '2': 0},
    {'1': 'Dots', '2': 1},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Bookmark$json = {
  '1': 'Bookmark',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'imageHash', '3': 4, '4': 1, '5': 9, '10': 'imageHash'},
    {'1': 'faviconHash', '3': 5, '4': 1, '5': 9, '10': 'faviconHash'},
    {
      '1': 'type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.LinkPreview.Type',
      '10': 'type'
    },
    {'1': 'targetObjectId', '3': 7, '4': 1, '5': 9, '10': 'targetObjectId'},
    {
      '1': 'state',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Bookmark.State',
      '10': 'state'
    },
  ],
  '4': [Block_Content_Bookmark_State$json],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Bookmark_State$json = {
  '1': 'State',
  '2': [
    {'1': 'Empty', '2': 0},
    {'1': 'Fetching', '2': 1},
    {'1': 'Done', '2': 2},
    {'1': 'Error', '2': 3},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Icon$json = {
  '1': 'Icon',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_FeaturedRelations$json = {
  '1': 'FeaturedRelations',
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Text$json = {
  '1': 'Text',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'style',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Text.Style',
      '10': 'style'
    },
    {
      '1': 'marks',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Text.Marks',
      '10': 'marks'
    },
    {'1': 'checked', '3': 4, '4': 1, '5': 8, '10': 'checked'},
    {'1': 'color', '3': 5, '4': 1, '5': 9, '10': 'color'},
    {'1': 'iconEmoji', '3': 6, '4': 1, '5': 9, '10': 'iconEmoji'},
    {'1': 'iconImage', '3': 7, '4': 1, '5': 9, '10': 'iconImage'},
  ],
  '3': [Block_Content_Text_Marks$json, Block_Content_Text_Mark$json],
  '4': [Block_Content_Text_Style$json],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Text_Marks$json = {
  '1': 'Marks',
  '2': [
    {
      '1': 'marks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Text.Mark',
      '10': 'marks'
    },
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Text_Mark$json = {
  '1': 'Mark',
  '2': [
    {
      '1': 'range',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Range',
      '10': 'range'
    },
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Text.Mark.Type',
      '10': 'type'
    },
    {'1': 'param', '3': 3, '4': 1, '5': 9, '10': 'param'},
  ],
  '4': [Block_Content_Text_Mark_Type$json],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Text_Mark_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'Strikethrough', '2': 0},
    {'1': 'Keyboard', '2': 1},
    {'1': 'Italic', '2': 2},
    {'1': 'Bold', '2': 3},
    {'1': 'Underscored', '2': 4},
    {'1': 'Link', '2': 5},
    {'1': 'TextColor', '2': 6},
    {'1': 'BackgroundColor', '2': 7},
    {'1': 'Mention', '2': 8},
    {'1': 'Emoji', '2': 9},
    {'1': 'Object', '2': 10},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Text_Style$json = {
  '1': 'Style',
  '2': [
    {'1': 'Paragraph', '2': 0},
    {'1': 'Header1', '2': 1},
    {'1': 'Header2', '2': 2},
    {'1': 'Header3', '2': 3},
    {'1': 'Header4', '2': 4},
    {'1': 'Quote', '2': 5},
    {'1': 'Code', '2': 6},
    {'1': 'Title', '2': 7},
    {'1': 'Checkbox', '2': 8},
    {'1': 'Marked', '2': 9},
    {'1': 'Numbered', '2': 10},
    {'1': 'Toggle', '2': 11},
    {'1': 'Description', '2': 12},
    {'1': 'Callout', '2': 13},
    {'1': 'ToggleHeader1', '2': 14},
    {'1': 'ToggleHeader2', '2': 15},
    {'1': 'ToggleHeader3', '2': 16},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_File$json = {
  '1': 'File',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.File.Type',
      '10': 'type'
    },
    {'1': 'mime', '3': 4, '4': 1, '5': 9, '10': 'mime'},
    {'1': 'size', '3': 5, '4': 1, '5': 3, '10': 'size'},
    {'1': 'addedAt', '3': 6, '4': 1, '5': 3, '10': 'addedAt'},
    {'1': 'targetObjectId', '3': 9, '4': 1, '5': 9, '10': 'targetObjectId'},
    {
      '1': 'state',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.File.State',
      '10': 'state'
    },
    {
      '1': 'style',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.File.Style',
      '10': 'style'
    },
  ],
  '4': [
    Block_Content_File_Type$json,
    Block_Content_File_Style$json,
    Block_Content_File_State$json
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_File_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'File', '2': 1},
    {'1': 'Image', '2': 2},
    {'1': 'Video', '2': 3},
    {'1': 'Audio', '2': 4},
    {'1': 'PDF', '2': 5},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_File_Style$json = {
  '1': 'Style',
  '2': [
    {'1': 'Auto', '2': 0},
    {'1': 'Link', '2': 1},
    {'1': 'Embed', '2': 2},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_File_State$json = {
  '1': 'State',
  '2': [
    {'1': 'Empty', '2': 0},
    {'1': 'Uploading', '2': 1},
    {'1': 'Done', '2': 2},
    {'1': 'Error', '2': 3},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Smartblock$json = {
  '1': 'Smartblock',
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview$json = {
  '1': 'Dataview',
  '2': [
    {'1': 'source', '3': 1, '4': 3, '5': 9, '10': 'source'},
    {
      '1': 'views',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.View',
      '10': 'views'
    },
    {'1': 'activeView', '3': 3, '4': 1, '5': 9, '10': 'activeView'},
    {
      '1': 'relations',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Relation',
      '10': 'relations'
    },
    {
      '1': 'groupOrders',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.GroupOrder',
      '10': 'groupOrders'
    },
    {
      '1': 'objectOrders',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.ObjectOrder',
      '10': 'objectOrders'
    },
    {
      '1': 'relationLinks',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.RelationLink',
      '10': 'relationLinks'
    },
    {'1': 'TargetObjectId', '3': 6, '4': 1, '5': 9, '10': 'TargetObjectId'},
    {'1': 'isCollection', '3': 14, '4': 1, '5': 8, '10': 'isCollection'},
  ],
  '3': [
    Block_Content_Dataview_View$json,
    Block_Content_Dataview_Relation$json,
    Block_Content_Dataview_Sort$json,
    Block_Content_Dataview_Filter$json,
    Block_Content_Dataview_GroupOrder$json,
    Block_Content_Dataview_ViewGroup$json,
    Block_Content_Dataview_ObjectOrder$json,
    Block_Content_Dataview_Group$json,
    Block_Content_Dataview_Status$json,
    Block_Content_Dataview_Tag$json,
    Block_Content_Dataview_Checkbox$json,
    Block_Content_Dataview_Date$json
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_View$json = {
  '1': 'View',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.View.Type',
      '10': 'type'
    },
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'sorts',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.Sort',
      '10': 'sorts'
    },
    {
      '1': 'filters',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.Filter',
      '10': 'filters'
    },
    {
      '1': 'relations',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.Relation',
      '10': 'relations'
    },
    {'1': 'coverRelationKey', '3': 7, '4': 1, '5': 9, '10': 'coverRelationKey'},
    {'1': 'hideIcon', '3': 8, '4': 1, '5': 8, '10': 'hideIcon'},
    {
      '1': 'cardSize',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.View.Size',
      '10': 'cardSize'
    },
    {'1': 'coverFit', '3': 10, '4': 1, '5': 8, '10': 'coverFit'},
    {
      '1': 'groupRelationKey',
      '3': 11,
      '4': 1,
      '5': 9,
      '10': 'groupRelationKey'
    },
    {
      '1': 'groupBackgroundColors',
      '3': 12,
      '4': 1,
      '5': 8,
      '10': 'groupBackgroundColors'
    },
    {'1': 'pageLimit', '3': 13, '4': 1, '5': 5, '10': 'pageLimit'},
    {
      '1': 'defaultTemplateId',
      '3': 14,
      '4': 1,
      '5': 9,
      '10': 'defaultTemplateId'
    },
    {
      '1': 'defaultObjectTypeId',
      '3': 15,
      '4': 1,
      '5': 9,
      '10': 'defaultObjectTypeId'
    },
    {'1': 'endRelationKey', '3': 16, '4': 1, '5': 9, '10': 'endRelationKey'},
    {'1': 'wrapContent', '3': 17, '4': 1, '5': 8, '10': 'wrapContent'},
    {
      '1': 'listSize',
      '3': 18,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.View.ListSize',
      '10': 'listSize'
    },
    {'1': 'alternateRows', '3': 19, '4': 1, '5': 8, '10': 'alternateRows'},
  ],
  '4': [
    Block_Content_Dataview_View_Type$json,
    Block_Content_Dataview_View_Size$json,
    Block_Content_Dataview_View_ListSize$json
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_View_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'Table', '2': 0},
    {'1': 'List', '2': 1},
    {'1': 'Gallery', '2': 2},
    {'1': 'Kanban', '2': 3},
    {'1': 'Calendar', '2': 4},
    {'1': 'Graph', '2': 5},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_View_Size$json = {
  '1': 'Size',
  '2': [
    {'1': 'Small', '2': 0},
    {'1': 'Medium', '2': 1},
    {'1': 'Large', '2': 2},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_View_ListSize$json = {
  '1': 'ListSize',
  '2': [
    {'1': 'Compact', '2': 0},
    {'1': 'Regular', '2': 1},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Relation$json = {
  '1': 'Relation',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'isVisible', '3': 2, '4': 1, '5': 8, '10': 'isVisible'},
    {'1': 'width', '3': 3, '4': 1, '5': 5, '10': 'width'},
    {'1': 'dateIncludeTime', '3': 5, '4': 1, '5': 8, '10': 'dateIncludeTime'},
    {
      '1': 'timeFormat',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.Relation.TimeFormat',
      '10': 'timeFormat'
    },
    {
      '1': 'dateFormat',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.Relation.DateFormat',
      '10': 'dateFormat'
    },
    {
      '1': 'formula',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.Relation.FormulaType',
      '10': 'formula'
    },
    {
      '1': 'align',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Align',
      '10': 'align'
    },
  ],
  '4': [
    Block_Content_Dataview_Relation_DateFormat$json,
    Block_Content_Dataview_Relation_TimeFormat$json,
    Block_Content_Dataview_Relation_FormulaType$json
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Relation_DateFormat$json = {
  '1': 'DateFormat',
  '2': [
    {'1': 'MonthAbbrBeforeDay', '2': 0},
    {'1': 'MonthAbbrAfterDay', '2': 1},
    {'1': 'Short', '2': 2},
    {'1': 'ShortUS', '2': 3},
    {'1': 'ISO', '2': 4},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Relation_TimeFormat$json = {
  '1': 'TimeFormat',
  '2': [
    {'1': 'Format12', '2': 0},
    {'1': 'Format24', '2': 1},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Relation_FormulaType$json = {
  '1': 'FormulaType',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'Count', '2': 1},
    {'1': 'CountValue', '2': 2},
    {'1': 'CountDistinct', '2': 3},
    {'1': 'CountEmpty', '2': 4},
    {'1': 'CountNotEmpty', '2': 5},
    {'1': 'PercentEmpty', '2': 6},
    {'1': 'PercentNotEmpty', '2': 7},
    {'1': 'MathSum', '2': 8},
    {'1': 'MathAverage', '2': 9},
    {'1': 'MathMedian', '2': 10},
    {'1': 'MathMin', '2': 11},
    {'1': 'MathMax', '2': 12},
    {'1': 'Range', '2': 13},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Sort$json = {
  '1': 'Sort',
  '2': [
    {'1': 'RelationKey', '3': 1, '4': 1, '5': 9, '10': 'RelationKey'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.Sort.Type',
      '10': 'type'
    },
    {
      '1': 'customOrder',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.google.protobuf.Value',
      '10': 'customOrder'
    },
    {
      '1': 'format',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.RelationFormat',
      '10': 'format'
    },
    {'1': 'includeTime', '3': 5, '4': 1, '5': 8, '10': 'includeTime'},
    {'1': 'id', '3': 6, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'emptyPlacement',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.Sort.EmptyType',
      '10': 'emptyPlacement'
    },
    {'1': 'noCollate', '3': 8, '4': 1, '5': 8, '10': 'noCollate'},
  ],
  '4': [
    Block_Content_Dataview_Sort_Type$json,
    Block_Content_Dataview_Sort_EmptyType$json
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Sort_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'Asc', '2': 0},
    {'1': 'Desc', '2': 1},
    {'1': 'Custom', '2': 2},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Sort_EmptyType$json = {
  '1': 'EmptyType',
  '2': [
    {'1': 'NotSpecified', '2': 0},
    {'1': 'Start', '2': 1},
    {'1': 'End', '2': 2},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Filter$json = {
  '1': 'Filter',
  '2': [
    {'1': 'id', '3': 9, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'operator',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.Filter.Operator',
      '10': 'operator'
    },
    {'1': 'RelationKey', '3': 2, '4': 1, '5': 9, '10': 'RelationKey'},
    {'1': 'relationProperty', '3': 5, '4': 1, '5': 9, '10': 'relationProperty'},
    {
      '1': 'condition',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.Filter.Condition',
      '10': 'condition'
    },
    {
      '1': 'value',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Value',
      '10': 'value'
    },
    {
      '1': 'quickOption',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Dataview.Filter.QuickOption',
      '10': 'quickOption'
    },
    {
      '1': 'format',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.RelationFormat',
      '10': 'format'
    },
    {'1': 'includeTime', '3': 8, '4': 1, '5': 8, '10': 'includeTime'},
    {
      '1': 'nestedFilters',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.Filter',
      '10': 'nestedFilters'
    },
  ],
  '4': [
    Block_Content_Dataview_Filter_Operator$json,
    Block_Content_Dataview_Filter_Condition$json,
    Block_Content_Dataview_Filter_QuickOption$json
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Filter_Operator$json = {
  '1': 'Operator',
  '2': [
    {'1': 'No', '2': 0},
    {'1': 'Or', '2': 1},
    {'1': 'And', '2': 2},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Filter_Condition$json = {
  '1': 'Condition',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'Equal', '2': 1},
    {'1': 'NotEqual', '2': 2},
    {'1': 'Greater', '2': 3},
    {'1': 'Less', '2': 4},
    {'1': 'GreaterOrEqual', '2': 5},
    {'1': 'LessOrEqual', '2': 6},
    {'1': 'Like', '2': 7},
    {'1': 'NotLike', '2': 8},
    {'1': 'In', '2': 9},
    {'1': 'NotIn', '2': 10},
    {'1': 'Empty', '2': 11},
    {'1': 'NotEmpty', '2': 12},
    {'1': 'AllIn', '2': 13},
    {'1': 'NotAllIn', '2': 14},
    {'1': 'ExactIn', '2': 15},
    {'1': 'NotExactIn', '2': 16},
    {'1': 'Exists', '2': 17},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Filter_QuickOption$json = {
  '1': 'QuickOption',
  '2': [
    {'1': 'ExactDate', '2': 0},
    {'1': 'Yesterday', '2': 1},
    {'1': 'Today', '2': 2},
    {'1': 'Tomorrow', '2': 3},
    {'1': 'LastWeek', '2': 4},
    {'1': 'CurrentWeek', '2': 5},
    {'1': 'NextWeek', '2': 6},
    {'1': 'LastMonth', '2': 7},
    {'1': 'CurrentMonth', '2': 8},
    {'1': 'NextMonth', '2': 9},
    {'1': 'NumberOfDaysAgo', '2': 10},
    {'1': 'NumberOfDaysNow', '2': 11},
    {'1': 'LastYear', '2': 12},
    {'1': 'CurrentYear', '2': 13},
    {'1': 'NextYear', '2': 14},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_GroupOrder$json = {
  '1': 'GroupOrder',
  '2': [
    {'1': 'viewId', '3': 1, '4': 1, '5': 9, '10': 'viewId'},
    {
      '1': 'viewGroups',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.ViewGroup',
      '10': 'viewGroups'
    },
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_ViewGroup$json = {
  '1': 'ViewGroup',
  '2': [
    {'1': 'groupId', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'index', '3': 2, '4': 1, '5': 5, '10': 'index'},
    {'1': 'hidden', '3': 3, '4': 1, '5': 8, '10': 'hidden'},
    {'1': 'backgroundColor', '3': 4, '4': 1, '5': 9, '10': 'backgroundColor'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_ObjectOrder$json = {
  '1': 'ObjectOrder',
  '2': [
    {'1': 'viewId', '3': 1, '4': 1, '5': 9, '10': 'viewId'},
    {'1': 'groupId', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'objectIds', '3': 3, '4': 3, '5': 9, '10': 'objectIds'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Group$json = {
  '1': 'Group',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.Status',
      '9': 0,
      '10': 'status'
    },
    {
      '1': 'tag',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.Tag',
      '9': 0,
      '10': 'tag'
    },
    {
      '1': 'checkbox',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.Checkbox',
      '9': 0,
      '10': 'checkbox'
    },
    {
      '1': 'date',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Dataview.Date',
      '9': 0,
      '10': 'date'
    },
  ],
  '8': [
    {'1': 'Value'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Tag$json = {
  '1': 'Tag',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 9, '10': 'ids'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Checkbox$json = {
  '1': 'Checkbox',
  '2': [
    {'1': 'checked', '3': 1, '4': 1, '5': 8, '10': 'checked'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Dataview_Date$json = {
  '1': 'Date',
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Relation$json = {
  '1': 'Relation',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Latex$json = {
  '1': 'Latex',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'processor',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Latex.Processor',
      '10': 'processor'
    },
  ],
  '4': [Block_Content_Latex_Processor$json],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Latex_Processor$json = {
  '1': 'Processor',
  '2': [
    {'1': 'Latex', '2': 0},
    {'1': 'Mermaid', '2': 1},
    {'1': 'Chart', '2': 2},
    {'1': 'Youtube', '2': 3},
    {'1': 'Vimeo', '2': 4},
    {'1': 'Soundcloud', '2': 5},
    {'1': 'GoogleMaps', '2': 6},
    {'1': 'Miro', '2': 7},
    {'1': 'Figma', '2': 8},
    {'1': 'Twitter', '2': 9},
    {'1': 'OpenStreetMap', '2': 10},
    {'1': 'Reddit', '2': 11},
    {'1': 'Facebook', '2': 12},
    {'1': 'Instagram', '2': 13},
    {'1': 'Telegram', '2': 14},
    {'1': 'GithubGist', '2': 15},
    {'1': 'Codepen', '2': 16},
    {'1': 'Bilibili', '2': 17},
    {'1': 'Excalidraw', '2': 18},
    {'1': 'Kroki', '2': 19},
    {'1': 'Graphviz', '2': 20},
    {'1': 'Sketchfab', '2': 21},
    {'1': 'Image', '2': 22},
    {'1': 'Drawio', '2': 23},
    {'1': 'Spotify', '2': 24},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_TableOfContents$json = {
  '1': 'TableOfContents',
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Table$json = {
  '1': 'Table',
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_TableColumn$json = {
  '1': 'TableColumn',
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_TableRow$json = {
  '1': 'TableRow',
  '2': [
    {'1': 'isHeader', '3': 1, '4': 1, '5': 8, '10': 'isHeader'},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Widget$json = {
  '1': 'Widget',
  '2': [
    {
      '1': 'layout',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Widget.Layout',
      '10': 'layout'
    },
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'viewId', '3': 3, '4': 1, '5': 9, '10': 'viewId'},
    {'1': 'autoAdded', '3': 4, '4': 1, '5': 8, '10': 'autoAdded'},
  ],
  '4': [Block_Content_Widget_Layout$json],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Widget_Layout$json = {
  '1': 'Layout',
  '2': [
    {'1': 'Link', '2': 0},
    {'1': 'Tree', '2': 1},
    {'1': 'List', '2': 2},
    {'1': 'CompactList', '2': 3},
    {'1': 'View', '2': 4},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Content_Chat$json = {
  '1': 'Chat',
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Position$json = {
  '1': 'Position',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'Top', '2': 1},
    {'1': 'Bottom', '2': 2},
    {'1': 'Left', '2': 3},
    {'1': 'Right', '2': 4},
    {'1': 'Inner', '2': 5},
    {'1': 'Replace', '2': 6},
    {'1': 'InnerFirst', '2': 7},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_Align$json = {
  '1': 'Align',
  '2': [
    {'1': 'AlignLeft', '2': 0},
    {'1': 'AlignCenter', '2': 1},
    {'1': 'AlignRight', '2': 2},
    {'1': 'AlignJustify', '2': 3},
  ],
};

@$core.Deprecated('Use blockDescriptor instead')
const Block_VerticalAlign$json = {
  '1': 'VerticalAlign',
  '2': [
    {'1': 'VerticalAlignTop', '2': 0},
    {'1': 'VerticalAlignMiddle', '2': 1},
    {'1': 'VerticalAlignBottom', '2': 2},
  ],
};

/// Descriptor for `Block`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockDescriptor = $convert.base64Decode(
    'CgVCbG9jaxIOCgJpZBgBIAEoCVICaWQSLwoGZmllbGRzGAIgASgLMhcuZ29vZ2xlLnByb3RvYn'
    'VmLlN0cnVjdFIGZmllbGRzEkUKDHJlc3RyaWN0aW9ucxgDIAEoCzIhLmFueXR5cGUubW9kZWwu'
    'QmxvY2suUmVzdHJpY3Rpb25zUgxyZXN0cmljdGlvbnMSIAoLY2hpbGRyZW5JZHMYBCADKAlSC2'
    'NoaWxkcmVuSWRzEigKD2JhY2tncm91bmRDb2xvchgFIAEoCVIPYmFja2dyb3VuZENvbG9yEjAK'
    'BWFsaWduGAYgASgOMhouYW55dHlwZS5tb2RlbC5CbG9jay5BbGlnblIFYWxpZ24SSAoNdmVydG'
    'ljYWxBbGlnbhgHIAEoDjIiLmFueXR5cGUubW9kZWwuQmxvY2suVmVydGljYWxBbGlnblINdmVy'
    'dGljYWxBbGlnbhJJCgpzbWFydGJsb2NrGAsgASgLMicuYW55dHlwZS5tb2RlbC5CbG9jay5Db2'
    '50ZW50LlNtYXJ0YmxvY2tIAFIKc21hcnRibG9jaxI3CgR0ZXh0GA4gASgLMiEuYW55dHlwZS5t'
    'b2RlbC5CbG9jay5Db250ZW50LlRleHRIAFIEdGV4dBI3CgRmaWxlGA8gASgLMiEuYW55dHlwZS'
    '5tb2RlbC5CbG9jay5Db250ZW50LkZpbGVIAFIEZmlsZRI9CgZsYXlvdXQYECABKAsyIy5hbnl0'
    'eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuTGF5b3V0SABSBmxheW91dBI0CgNkaXYYESABKAsyIC'
    '5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuRGl2SABSA2RpdhJDCghib29rbWFyaxgSIAEo'
    'CzIlLmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC5Cb29rbWFya0gAUghib29rbWFyaxI3Cg'
    'RpY29uGBMgASgLMiEuYW55dHlwZS5tb2RlbC5CbG9jay5Db250ZW50Lkljb25IAFIEaWNvbhI3'
    'CgRsaW5rGBQgASgLMiEuYW55dHlwZS5tb2RlbC5CbG9jay5Db250ZW50LkxpbmtIAFIEbGluax'
    'JDCghkYXRhdmlldxgVIAEoCzIlLmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC5EYXRhdmll'
    'd0gAUghkYXRhdmlldxJDCghyZWxhdGlvbhgWIAEoCzIlLmFueXR5cGUubW9kZWwuQmxvY2suQ2'
    '9udGVudC5SZWxhdGlvbkgAUghyZWxhdGlvbhJeChFmZWF0dXJlZFJlbGF0aW9ucxgXIAEoCzIu'
    'LmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC5GZWF0dXJlZFJlbGF0aW9uc0gAUhFmZWF0dX'
    'JlZFJlbGF0aW9ucxI6CgVsYXRleBgYIAEoCzIiLmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVu'
    'dC5MYXRleEgAUgVsYXRleBJYCg90YWJsZU9mQ29udGVudHMYGSABKAsyLC5hbnl0eXBlLm1vZG'
    'VsLkJsb2NrLkNvbnRlbnQuVGFibGVPZkNvbnRlbnRzSABSD3RhYmxlT2ZDb250ZW50cxI6CgV0'
    'YWJsZRgaIAEoCzIiLmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC5UYWJsZUgAUgV0YWJsZR'
    'JMCgt0YWJsZUNvbHVtbhgbIAEoCzIoLmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC5UYWJs'
    'ZUNvbHVtbkgAUgt0YWJsZUNvbHVtbhJDCgh0YWJsZVJvdxgcIAEoCzIlLmFueXR5cGUubW9kZW'
    'wuQmxvY2suQ29udGVudC5UYWJsZVJvd0gAUgh0YWJsZVJvdxI9CgZ3aWRnZXQYHSABKAsyIy5h'
    'bnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuV2lkZ2V0SABSBndpZGdldBI3CgRjaGF0GB4gAS'
    'gLMiEuYW55dHlwZS5tb2RlbC5CbG9jay5Db250ZW50LkNoYXRIAFIEY2hhdBp6CgxSZXN0cmlj'
    'dGlvbnMSEgoEcmVhZBgBIAEoCFIEcmVhZBISCgRlZGl0GAIgASgIUgRlZGl0EhYKBnJlbW92ZR'
    'gDIAEoCFIGcmVtb3ZlEhIKBGRyYWcYBCABKAhSBGRyYWcSFgoGZHJvcE9uGAUgASgIUgZkcm9w'
    'T24ayUAKB0NvbnRlbnQanQEKBkxheW91dBI/CgVzdHlsZRgBIAEoDjIpLmFueXR5cGUubW9kZW'
    'wuQmxvY2suQ29udGVudC5MYXlvdXQuU3R5bGVSBXN0eWxlIlIKBVN0eWxlEgcKA1JvdxAAEgoK'
    'BkNvbHVtbhABEgcKA0RpdhACEgoKBkhlYWRlchADEg0KCVRhYmxlUm93cxAEEhAKDFRhYmxlQ2'
    '9sdW1ucxAFGvIECgRMaW5rEiQKDXRhcmdldEJsb2NrSWQYASABKAlSDXRhcmdldEJsb2NrSWQS'
    'PQoFc3R5bGUYAiABKA4yJy5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuTGluay5TdHlsZV'
    'IFc3R5bGUSLwoGZmllbGRzGAMgASgLMhcuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdFIGZmllbGRz'
    'EkYKCGljb25TaXplGAQgASgOMiouYW55dHlwZS5tb2RlbC5CbG9jay5Db250ZW50LkxpbmsuSW'
    'NvblNpemVSCGljb25TaXplEkkKCWNhcmRTdHlsZRgFIAEoDjIrLmFueXR5cGUubW9kZWwuQmxv'
    'Y2suQ29udGVudC5MaW5rLkNhcmRTdHlsZVIJY2FyZFN0eWxlEk8KC2Rlc2NyaXB0aW9uGAYgAS'
    'gOMi0uYW55dHlwZS5tb2RlbC5CbG9jay5Db250ZW50LkxpbmsuRGVzY3JpcHRpb25SC2Rlc2Ny'
    'aXB0aW9uEhwKCXJlbGF0aW9ucxgHIAMoCVIJcmVsYXRpb25zIjcKCEljb25TaXplEgwKCFNpem'
    'VOb25lEAASDQoJU2l6ZVNtYWxsEAESDgoKU2l6ZU1lZGl1bRACIjsKBVN0eWxlEggKBFBhZ2UQ'
    'ABIMCghEYXRhdmlldxABEg0KCURhc2hib2FyZBACEgsKB0FyY2hpdmUQAyIvCgtEZXNjcmlwdG'
    'lvbhIICgROb25lEAASCQoFQWRkZWQQARILCgdDb250ZW50EAIiKwoJQ2FyZFN0eWxlEggKBFRl'
    'eHQQABIICgRDYXJkEAESCgoGSW5saW5lEAIaYAoDRGl2EjwKBXN0eWxlGAEgASgOMiYuYW55dH'
    'lwZS5tb2RlbC5CbG9jay5Db250ZW50LkRpdi5TdHlsZVIFc3R5bGUiGwoFU3R5bGUSCAoETGlu'
    'ZRAAEggKBERvdHMQARrrAgoIQm9va21hcmsSEAoDdXJsGAEgASgJUgN1cmwSFAoFdGl0bGUYAi'
    'ABKAlSBXRpdGxlEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIcCglpbWFnZUhh'
    'c2gYBCABKAlSCWltYWdlSGFzaBIgCgtmYXZpY29uSGFzaBgFIAEoCVILZmF2aWNvbkhhc2gSMw'
    'oEdHlwZRgGIAEoDjIfLmFueXR5cGUubW9kZWwuTGlua1ByZXZpZXcuVHlwZVIEdHlwZRImCg50'
    'YXJnZXRPYmplY3RJZBgHIAEoCVIOdGFyZ2V0T2JqZWN0SWQSQQoFc3RhdGUYCCABKA4yKy5hbn'
    'l0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuQm9va21hcmsuU3RhdGVSBXN0YXRlIjUKBVN0YXRl'
    'EgkKBUVtcHR5EAASDAoIRmV0Y2hpbmcQARIICgREb25lEAISCQoFRXJyb3IQAxoaCgRJY29uEh'
    'IKBG5hbWUYASABKAlSBG5hbWUaEwoRRmVhdHVyZWRSZWxhdGlvbnMa8gYKBFRleHQSEgoEdGV4'
    'dBgBIAEoCVIEdGV4dBI9CgVzdHlsZRgCIAEoDjInLmFueXR5cGUubW9kZWwuQmxvY2suQ29udG'
    'VudC5UZXh0LlN0eWxlUgVzdHlsZRI9CgVtYXJrcxgDIAEoCzInLmFueXR5cGUubW9kZWwuQmxv'
    'Y2suQ29udGVudC5UZXh0Lk1hcmtzUgVtYXJrcxIYCgdjaGVja2VkGAQgASgIUgdjaGVja2VkEh'
    'QKBWNvbG9yGAUgASgJUgVjb2xvchIcCglpY29uRW1vamkYBiABKAlSCWljb25FbW9qaRIcCglp'
    'Y29uSW1hZ2UYByABKAlSCWljb25JbWFnZRpFCgVNYXJrcxI8CgVtYXJrcxgBIAMoCzImLmFueX'
    'R5cGUubW9kZWwuQmxvY2suQ29udGVudC5UZXh0Lk1hcmtSBW1hcmtzGqwCCgRNYXJrEioKBXJh'
    'bmdlGAEgASgLMhQuYW55dHlwZS5tb2RlbC5SYW5nZVIFcmFuZ2USPwoEdHlwZRgCIAEoDjIrLm'
    'FueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC5UZXh0Lk1hcmsuVHlwZVIEdHlwZRIUCgVwYXJh'
    'bRgDIAEoCVIFcGFyYW0ioAEKBFR5cGUSEQoNU3RyaWtldGhyb3VnaBAAEgwKCEtleWJvYXJkEA'
    'ESCgoGSXRhbGljEAISCAoEQm9sZBADEg8KC1VuZGVyc2NvcmVkEAQSCAoETGluaxAFEg0KCVRl'
    'eHRDb2xvchAGEhMKD0JhY2tncm91bmRDb2xvchAHEgsKB01lbnRpb24QCBIJCgVFbW9qaRAJEg'
    'oKBk9iamVjdBAKIvUBCgVTdHlsZRINCglQYXJhZ3JhcGgQABILCgdIZWFkZXIxEAESCwoHSGVh'
    'ZGVyMhACEgsKB0hlYWRlcjMQAxILCgdIZWFkZXI0EAQSCQoFUXVvdGUQBRIICgRDb2RlEAYSCQ'
    'oFVGl0bGUQBxIMCghDaGVja2JveBAIEgoKBk1hcmtlZBAJEgwKCE51bWJlcmVkEAoSCgoGVG9n'
    'Z2xlEAsSDwoLRGVzY3JpcHRpb24QDBILCgdDYWxsb3V0EA0SEQoNVG9nZ2xlSGVhZGVyMRAOEh'
    'EKDVRvZ2dsZUhlYWRlcjIQDxIRCg1Ub2dnbGVIZWFkZXIzEBAa+AMKBEZpbGUSEgoEaGFzaBgB'
    'IAEoCVIEaGFzaBISCgRuYW1lGAIgASgJUgRuYW1lEjoKBHR5cGUYAyABKA4yJi5hbnl0eXBlLm'
    '1vZGVsLkJsb2NrLkNvbnRlbnQuRmlsZS5UeXBlUgR0eXBlEhIKBG1pbWUYBCABKAlSBG1pbWUS'
    'EgoEc2l6ZRgFIAEoA1IEc2l6ZRIYCgdhZGRlZEF0GAYgASgDUgdhZGRlZEF0EiYKDnRhcmdldE'
    '9iamVjdElkGAkgASgJUg50YXJnZXRPYmplY3RJZBI9CgVzdGF0ZRgHIAEoDjInLmFueXR5cGUu'
    'bW9kZWwuQmxvY2suQ29udGVudC5GaWxlLlN0YXRlUgVzdGF0ZRI9CgVzdHlsZRgIIAEoDjInLm'
    'FueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC5GaWxlLlN0eWxlUgVzdHlsZSJECgRUeXBlEggK'
    'BE5vbmUQABIICgRGaWxlEAESCQoFSW1hZ2UQAhIJCgVWaWRlbxADEgkKBUF1ZGlvEAQSBwoDUE'
    'RGEAUiJgoFU3R5bGUSCAoEQXV0bxAAEggKBExpbmsQARIJCgVFbWJlZBACIjYKBVN0YXRlEgkK'
    'BUVtcHR5EAASDQoJVXBsb2FkaW5nEAESCAoERG9uZRACEgkKBUVycm9yEAMaDAoKU21hcnRibG'
    '9jaxqMJQoIRGF0YXZpZXcSFgoGc291cmNlGAEgAygJUgZzb3VyY2USQAoFdmlld3MYAiADKAsy'
    'Ki5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuRGF0YXZpZXcuVmlld1IFdmlld3MSHgoKYW'
    'N0aXZlVmlldxgDIAEoCVIKYWN0aXZlVmlldxI1CglyZWxhdGlvbnMYBCADKAsyFy5hbnl0eXBl'
    'Lm1vZGVsLlJlbGF0aW9uUglyZWxhdGlvbnMSUgoLZ3JvdXBPcmRlcnMYDCADKAsyMC5hbnl0eX'
    'BlLm1vZGVsLkJsb2NrLkNvbnRlbnQuRGF0YXZpZXcuR3JvdXBPcmRlclILZ3JvdXBPcmRlcnMS'
    'VQoMb2JqZWN0T3JkZXJzGA0gAygLMjEuYW55dHlwZS5tb2RlbC5CbG9jay5Db250ZW50LkRhdG'
    'F2aWV3Lk9iamVjdE9yZGVyUgxvYmplY3RPcmRlcnMSQQoNcmVsYXRpb25MaW5rcxgFIAMoCzIb'
    'LmFueXR5cGUubW9kZWwuUmVsYXRpb25MaW5rUg1yZWxhdGlvbkxpbmtzEiYKDlRhcmdldE9iam'
    'VjdElkGAYgASgJUg5UYXJnZXRPYmplY3RJZBIiCgxpc0NvbGxlY3Rpb24YDiABKAhSDGlzQ29s'
    'bGVjdGlvbhq4CAoEVmlldxIOCgJpZBgBIAEoCVICaWQSQwoEdHlwZRgCIAEoDjIvLmFueXR5cG'
    'UubW9kZWwuQmxvY2suQ29udGVudC5EYXRhdmlldy5WaWV3LlR5cGVSBHR5cGUSEgoEbmFtZRgD'
    'IAEoCVIEbmFtZRJACgVzb3J0cxgEIAMoCzIqLmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC'
    '5EYXRhdmlldy5Tb3J0UgVzb3J0cxJGCgdmaWx0ZXJzGAUgAygLMiwuYW55dHlwZS5tb2RlbC5C'
    'bG9jay5Db250ZW50LkRhdGF2aWV3LkZpbHRlclIHZmlsdGVycxJMCglyZWxhdGlvbnMYBiADKA'
    'syLi5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuRGF0YXZpZXcuUmVsYXRpb25SCXJlbGF0'
    'aW9ucxIqChBjb3ZlclJlbGF0aW9uS2V5GAcgASgJUhBjb3ZlclJlbGF0aW9uS2V5EhoKCGhpZG'
    'VJY29uGAggASgIUghoaWRlSWNvbhJLCghjYXJkU2l6ZRgJIAEoDjIvLmFueXR5cGUubW9kZWwu'
    'QmxvY2suQ29udGVudC5EYXRhdmlldy5WaWV3LlNpemVSCGNhcmRTaXplEhoKCGNvdmVyRml0GA'
    'ogASgIUghjb3ZlckZpdBIqChBncm91cFJlbGF0aW9uS2V5GAsgASgJUhBncm91cFJlbGF0aW9u'
    'S2V5EjQKFWdyb3VwQmFja2dyb3VuZENvbG9ycxgMIAEoCFIVZ3JvdXBCYWNrZ3JvdW5kQ29sb3'
    'JzEhwKCXBhZ2VMaW1pdBgNIAEoBVIJcGFnZUxpbWl0EiwKEWRlZmF1bHRUZW1wbGF0ZUlkGA4g'
    'ASgJUhFkZWZhdWx0VGVtcGxhdGVJZBIwChNkZWZhdWx0T2JqZWN0VHlwZUlkGA8gASgJUhNkZW'
    'ZhdWx0T2JqZWN0VHlwZUlkEiYKDmVuZFJlbGF0aW9uS2V5GBAgASgJUg5lbmRSZWxhdGlvbktl'
    'eRIgCgt3cmFwQ29udGVudBgRIAEoCFILd3JhcENvbnRlbnQSTwoIbGlzdFNpemUYEiABKA4yMy'
    '5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuRGF0YXZpZXcuVmlldy5MaXN0U2l6ZVIIbGlz'
    'dFNpemUSJAoNYWx0ZXJuYXRlUm93cxgTIAEoCFINYWx0ZXJuYXRlUm93cyJNCgRUeXBlEgkKBV'
    'RhYmxlEAASCAoETGlzdBABEgsKB0dhbGxlcnkQAhIKCgZLYW5iYW4QAxIMCghDYWxlbmRhchAE'
    'EgkKBUdyYXBoEAUiKAoEU2l6ZRIJCgVTbWFsbBAAEgoKBk1lZGl1bRABEgkKBUxhcmdlEAIiJA'
    'oITGlzdFNpemUSCwoHQ29tcGFjdBAAEgsKB1JlZ3VsYXIQARqlBgoIUmVsYXRpb24SEAoDa2V5'
    'GAEgASgJUgNrZXkSHAoJaXNWaXNpYmxlGAIgASgIUglpc1Zpc2libGUSFAoFd2lkdGgYAyABKA'
    'VSBXdpZHRoEigKD2RhdGVJbmNsdWRlVGltZRgFIAEoCFIPZGF0ZUluY2x1ZGVUaW1lElkKCnRp'
    'bWVGb3JtYXQYBiABKA4yOS5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuRGF0YXZpZXcuUm'
    'VsYXRpb24uVGltZUZvcm1hdFIKdGltZUZvcm1hdBJZCgpkYXRlRm9ybWF0GAcgASgOMjkuYW55'
    'dHlwZS5tb2RlbC5CbG9jay5Db250ZW50LkRhdGF2aWV3LlJlbGF0aW9uLkRhdGVGb3JtYXRSCm'
    'RhdGVGb3JtYXQSVAoHZm9ybXVsYRgIIAEoDjI6LmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVu'
    'dC5EYXRhdmlldy5SZWxhdGlvbi5Gb3JtdWxhVHlwZVIHZm9ybXVsYRIwCgVhbGlnbhgJIAEoDj'
    'IaLmFueXR5cGUubW9kZWwuQmxvY2suQWxpZ25SBWFsaWduIlwKCkRhdGVGb3JtYXQSFgoSTW9u'
    'dGhBYmJyQmVmb3JlRGF5EAASFQoRTW9udGhBYmJyQWZ0ZXJEYXkQARIJCgVTaG9ydBACEgsKB1'
    'Nob3J0VVMQAxIHCgNJU08QBCIoCgpUaW1lRm9ybWF0EgwKCEZvcm1hdDEyEAASDAoIRm9ybWF0'
    'MjQQASLiAQoLRm9ybXVsYVR5cGUSCAoETm9uZRAAEgkKBUNvdW50EAESDgoKQ291bnRWYWx1ZR'
    'ACEhEKDUNvdW50RGlzdGluY3QQAxIOCgpDb3VudEVtcHR5EAQSEQoNQ291bnROb3RFbXB0eRAF'
    'EhAKDFBlcmNlbnRFbXB0eRAGEhMKD1BlcmNlbnROb3RFbXB0eRAHEgsKB01hdGhTdW0QCBIPCg'
    'tNYXRoQXZlcmFnZRAJEg4KCk1hdGhNZWRpYW4QChILCgdNYXRoTWluEAsSCwoHTWF0aE1heBAM'
    'EgkKBVJhbmdlEA0a5gMKBFNvcnQSIAoLUmVsYXRpb25LZXkYASABKAlSC1JlbGF0aW9uS2V5Ek'
    'MKBHR5cGUYAiABKA4yLy5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuRGF0YXZpZXcuU29y'
    'dC5UeXBlUgR0eXBlEjgKC2N1c3RvbU9yZGVyGAMgAygLMhYuZ29vZ2xlLnByb3RvYnVmLlZhbH'
    'VlUgtjdXN0b21PcmRlchI1CgZmb3JtYXQYBCABKA4yHS5hbnl0eXBlLm1vZGVsLlJlbGF0aW9u'
    'Rm9ybWF0UgZmb3JtYXQSIAoLaW5jbHVkZVRpbWUYBSABKAhSC2luY2x1ZGVUaW1lEg4KAmlkGA'
    'YgASgJUgJpZBJcCg5lbXB0eVBsYWNlbWVudBgHIAEoDjI0LmFueXR5cGUubW9kZWwuQmxvY2su'
    'Q29udGVudC5EYXRhdmlldy5Tb3J0LkVtcHR5VHlwZVIOZW1wdHlQbGFjZW1lbnQSHAoJbm9Db2'
    'xsYXRlGAggASgIUglub0NvbGxhdGUiJQoEVHlwZRIHCgNBc2MQABIICgREZXNjEAESCgoGQ3Vz'
    'dG9tEAIiMQoJRW1wdHlUeXBlEhAKDE5vdFNwZWNpZmllZBAAEgkKBVN0YXJ0EAESBwoDRW5kEA'
    'Ia2AgKBkZpbHRlchIOCgJpZBgJIAEoCVICaWQSUQoIb3BlcmF0b3IYASABKA4yNS5hbnl0eXBl'
    'Lm1vZGVsLkJsb2NrLkNvbnRlbnQuRGF0YXZpZXcuRmlsdGVyLk9wZXJhdG9yUghvcGVyYXRvch'
    'IgCgtSZWxhdGlvbktleRgCIAEoCVILUmVsYXRpb25LZXkSKgoQcmVsYXRpb25Qcm9wZXJ0eRgF'
    'IAEoCVIQcmVsYXRpb25Qcm9wZXJ0eRJUCgljb25kaXRpb24YAyABKA4yNi5hbnl0eXBlLm1vZG'
    'VsLkJsb2NrLkNvbnRlbnQuRGF0YXZpZXcuRmlsdGVyLkNvbmRpdGlvblIJY29uZGl0aW9uEiwK'
    'BXZhbHVlGAQgASgLMhYuZ29vZ2xlLnByb3RvYnVmLlZhbHVlUgV2YWx1ZRJaCgtxdWlja09wdG'
    'lvbhgGIAEoDjI4LmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC5EYXRhdmlldy5GaWx0ZXIu'
    'UXVpY2tPcHRpb25SC3F1aWNrT3B0aW9uEjUKBmZvcm1hdBgHIAEoDjIdLmFueXR5cGUubW9kZW'
    'wuUmVsYXRpb25Gb3JtYXRSBmZvcm1hdBIgCgtpbmNsdWRlVGltZRgIIAEoCFILaW5jbHVkZVRp'
    'bWUSUgoNbmVzdGVkRmlsdGVycxgKIAMoCzIsLmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC'
    '5EYXRhdmlldy5GaWx0ZXJSDW5lc3RlZEZpbHRlcnMiIwoIT3BlcmF0b3ISBgoCTm8QABIGCgJP'
    'chABEgcKA0FuZBACIu8BCglDb25kaXRpb24SCAoETm9uZRAAEgkKBUVxdWFsEAESDAoITm90RX'
    'F1YWwQAhILCgdHcmVhdGVyEAMSCAoETGVzcxAEEhIKDkdyZWF0ZXJPckVxdWFsEAUSDwoLTGVz'
    'c09yRXF1YWwQBhIICgRMaWtlEAcSCwoHTm90TGlrZRAIEgYKAkluEAkSCQoFTm90SW4QChIJCg'
    'VFbXB0eRALEgwKCE5vdEVtcHR5EAwSCQoFQWxsSW4QDRIMCghOb3RBbGxJbhAOEgsKB0V4YWN0'
    'SW4QDxIOCgpOb3RFeGFjdEluEBASCgoGRXhpc3RzEBEi+AEKC1F1aWNrT3B0aW9uEg0KCUV4YW'
    'N0RGF0ZRAAEg0KCVllc3RlcmRheRABEgkKBVRvZGF5EAISDAoIVG9tb3Jyb3cQAxIMCghMYXN0'
    'V2VlaxAEEg8KC0N1cnJlbnRXZWVrEAUSDAoITmV4dFdlZWsQBhINCglMYXN0TW9udGgQBxIQCg'
    'xDdXJyZW50TW9udGgQCBINCglOZXh0TW9udGgQCRITCg9OdW1iZXJPZkRheXNBZ28QChITCg9O'
    'dW1iZXJPZkRheXNOb3cQCxIMCghMYXN0WWVhchAMEg8KC0N1cnJlbnRZZWFyEA0SDAoITmV4dF'
    'llYXIQDhp1CgpHcm91cE9yZGVyEhYKBnZpZXdJZBgBIAEoCVIGdmlld0lkEk8KCnZpZXdHcm91'
    'cHMYAiADKAsyLy5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuRGF0YXZpZXcuVmlld0dyb3'
    'VwUgp2aWV3R3JvdXBzGn0KCVZpZXdHcm91cBIYCgdncm91cElkGAEgASgJUgdncm91cElkEhQK'
    'BWluZGV4GAIgASgFUgVpbmRleBIWCgZoaWRkZW4YAyABKAhSBmhpZGRlbhIoCg9iYWNrZ3JvdW'
    '5kQ29sb3IYBCABKAlSD2JhY2tncm91bmRDb2xvchpdCgtPYmplY3RPcmRlchIWCgZ2aWV3SWQY'
    'ASABKAlSBnZpZXdJZBIYCgdncm91cElkGAIgASgJUgdncm91cElkEhwKCW9iamVjdElkcxgDIA'
    'MoCVIJb2JqZWN0SWRzGrcCCgVHcm91cBIOCgJpZBgBIAEoCVICaWQSRgoGc3RhdHVzGAIgASgL'
    'MiwuYW55dHlwZS5tb2RlbC5CbG9jay5Db250ZW50LkRhdGF2aWV3LlN0YXR1c0gAUgZzdGF0dX'
    'MSPQoDdGFnGAMgASgLMikuYW55dHlwZS5tb2RlbC5CbG9jay5Db250ZW50LkRhdGF2aWV3LlRh'
    'Z0gAUgN0YWcSTAoIY2hlY2tib3gYBCABKAsyLi5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbn'
    'QuRGF0YXZpZXcuQ2hlY2tib3hIAFIIY2hlY2tib3gSQAoEZGF0ZRgFIAEoCzIqLmFueXR5cGUu'
    'bW9kZWwuQmxvY2suQ29udGVudC5EYXRhdmlldy5EYXRlSABSBGRhdGVCBwoFVmFsdWUaGAoGU3'
    'RhdHVzEg4KAmlkGAEgASgJUgJpZBoXCgNUYWcSEAoDaWRzGAEgAygJUgNpZHMaJAoIQ2hlY2ti'
    'b3gSGAoHY2hlY2tlZBgBIAEoCFIHY2hlY2tlZBoGCgREYXRlGhwKCFJlbGF0aW9uEhAKA2tleR'
    'gBIAEoCVIDa2V5GsMDCgVMYXRleBISCgR0ZXh0GAEgASgJUgR0ZXh0EkoKCXByb2Nlc3NvchgC'
    'IAEoDjIsLmFueXR5cGUubW9kZWwuQmxvY2suQ29udGVudC5MYXRleC5Qcm9jZXNzb3JSCXByb2'
    'Nlc3NvciLZAgoJUHJvY2Vzc29yEgkKBUxhdGV4EAASCwoHTWVybWFpZBABEgkKBUNoYXJ0EAIS'
    'CwoHWW91dHViZRADEgkKBVZpbWVvEAQSDgoKU291bmRjbG91ZBAFEg4KCkdvb2dsZU1hcHMQBh'
    'IICgRNaXJvEAcSCQoFRmlnbWEQCBILCgdUd2l0dGVyEAkSEQoNT3BlblN0cmVldE1hcBAKEgoK'
    'BlJlZGRpdBALEgwKCEZhY2Vib29rEAwSDQoJSW5zdGFncmFtEA0SDAoIVGVsZWdyYW0QDhIOCg'
    'pHaXRodWJHaXN0EA8SCwoHQ29kZXBlbhAQEgwKCEJpbGliaWxpEBESDgoKRXhjYWxpZHJhdxAS'
    'EgkKBUtyb2tpEBMSDAoIR3JhcGh2aXoQFBINCglTa2V0Y2hmYWIQFRIJCgVJbWFnZRAWEgoKBk'
    'RyYXdpbxAXEgsKB1Nwb3RpZnkQGBoRCg9UYWJsZU9mQ29udGVudHMaBwoFVGFibGUaDQoLVGFi'
    'bGVDb2x1bW4aJgoIVGFibGVSb3cSGgoIaXNIZWFkZXIYASABKAhSCGlzSGVhZGVyGtsBCgZXaW'
    'RnZXQSQgoGbGF5b3V0GAEgASgOMiouYW55dHlwZS5tb2RlbC5CbG9jay5Db250ZW50LldpZGdl'
    'dC5MYXlvdXRSBmxheW91dBIUCgVsaW1pdBgCIAEoBVIFbGltaXQSFgoGdmlld0lkGAMgASgJUg'
    'Z2aWV3SWQSHAoJYXV0b0FkZGVkGAQgASgIUglhdXRvQWRkZWQiQQoGTGF5b3V0EggKBExpbmsQ'
    'ABIICgRUcmVlEAESCAoETGlzdBACEg8KC0NvbXBhY3RMaXN0EAMSCAoEVmlldxAEGgYKBENoYX'
    'QiZgoIUG9zaXRpb24SCAoETm9uZRAAEgcKA1RvcBABEgoKBkJvdHRvbRACEggKBExlZnQQAxIJ'
    'CgVSaWdodBAEEgkKBUlubmVyEAUSCwoHUmVwbGFjZRAGEg4KCklubmVyRmlyc3QQByJJCgVBbG'
    'lnbhINCglBbGlnbkxlZnQQABIPCgtBbGlnbkNlbnRlchABEg4KCkFsaWduUmlnaHQQAhIQCgxB'
    'bGlnbkp1c3RpZnkQAyJXCg1WZXJ0aWNhbEFsaWduEhQKEFZlcnRpY2FsQWxpZ25Ub3AQABIXCh'
    'NWZXJ0aWNhbEFsaWduTWlkZGxlEAESFwoTVmVydGljYWxBbGlnbkJvdHRvbRACQgkKB2NvbnRl'
    'bnQ=');

@$core.Deprecated('Use blockMetaOnlyDescriptor instead')
const BlockMetaOnly$json = {
  '1': 'BlockMetaOnly',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'fields',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'fields'
    },
  ],
};

/// Descriptor for `BlockMetaOnly`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockMetaOnlyDescriptor = $convert.base64Decode(
    'Cg1CbG9ja01ldGFPbmx5Eg4KAmlkGAEgASgJUgJpZBIvCgZmaWVsZHMYAiABKAsyFy5nb29nbG'
    'UucHJvdG9idWYuU3RydWN0UgZmaWVsZHM=');

@$core.Deprecated('Use rangeDescriptor instead')
const Range$json = {
  '1': 'Range',
  '2': [
    {'1': 'from', '3': 1, '4': 1, '5': 5, '10': 'from'},
    {'1': 'to', '3': 2, '4': 1, '5': 5, '10': 'to'},
  ],
};

/// Descriptor for `Range`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rangeDescriptor = $convert.base64Decode(
    'CgVSYW5nZRISCgRmcm9tGAEgASgFUgRmcm9tEg4KAnRvGAIgASgFUgJ0bw==');

@$core.Deprecated('Use accountDescriptor instead')
const Account$json = {
  '1': 'Account',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'config',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Account.Config',
      '10': 'config'
    },
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Account.Status',
      '10': 'status'
    },
    {
      '1': 'info',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Account.Info',
      '10': 'info'
    },
  ],
  '3': [
    Account_Config$json,
    Account_Status$json,
    Account_Info$json,
    Account_Auth$json
  ],
  '4': [Account_StatusType$json],
};

@$core.Deprecated('Use accountDescriptor instead')
const Account_Config$json = {
  '1': 'Config',
  '2': [
    {'1': 'enableDataview', '3': 1, '4': 1, '5': 8, '10': 'enableDataview'},
    {'1': 'enableDebug', '3': 2, '4': 1, '5': 8, '10': 'enableDebug'},
    {
      '1': 'enablePrereleaseChannel',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'enablePrereleaseChannel'
    },
    {'1': 'enableSpaces', '3': 4, '4': 1, '5': 8, '10': 'enableSpaces'},
    {
      '1': 'extra',
      '3': 100,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'extra'
    },
  ],
};

@$core.Deprecated('Use accountDescriptor instead')
const Account_Status$json = {
  '1': 'Status',
  '2': [
    {
      '1': 'statusType',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Account.StatusType',
      '10': 'statusType'
    },
    {'1': 'deletionDate', '3': 2, '4': 1, '5': 3, '10': 'deletionDate'},
  ],
};

@$core.Deprecated('Use accountDescriptor instead')
const Account_Info$json = {
  '1': 'Info',
  '2': [
    {'1': 'homeObjectId', '3': 2, '4': 1, '5': 9, '10': 'homeObjectId'},
    {'1': 'archiveObjectId', '3': 3, '4': 1, '5': 9, '10': 'archiveObjectId'},
    {'1': 'profileObjectId', '3': 4, '4': 1, '5': 9, '10': 'profileObjectId'},
    {
      '1': 'marketplaceWorkspaceId',
      '3': 11,
      '4': 1,
      '5': 9,
      '10': 'marketplaceWorkspaceId'
    },
    {
      '1': 'workspaceObjectId',
      '3': 15,
      '4': 1,
      '5': 9,
      '10': 'workspaceObjectId'
    },
    {'1': 'spaceChatId', '3': 16, '4': 1, '5': 9, '10': 'spaceChatId'},
    {'1': 'deviceId', '3': 8, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'accountSpaceId', '3': 9, '4': 1, '5': 9, '10': 'accountSpaceId'},
    {'1': 'widgetsId', '3': 10, '4': 1, '5': 9, '10': 'widgetsId'},
    {'1': 'spaceViewId', '3': 13, '4': 1, '5': 9, '10': 'spaceViewId'},
    {'1': 'techSpaceId', '3': 14, '4': 1, '5': 9, '10': 'techSpaceId'},
    {'1': 'gatewayUrl', '3': 101, '4': 1, '5': 9, '10': 'gatewayUrl'},
    {
      '1': 'localStoragePath',
      '3': 103,
      '4': 1,
      '5': 9,
      '10': 'localStoragePath'
    },
    {'1': 'timeZone', '3': 104, '4': 1, '5': 9, '10': 'timeZone'},
    {'1': 'analyticsId', '3': 105, '4': 1, '5': 9, '10': 'analyticsId'},
    {'1': 'networkId', '3': 106, '4': 1, '5': 9, '10': 'networkId'},
    {'1': 'ethereumAddress', '3': 107, '4': 1, '5': 9, '10': 'ethereumAddress'},
    {'1': 'metaDataKey', '3': 108, '4': 1, '5': 9, '10': 'metaDataKey'},
  ],
};

@$core.Deprecated('Use accountDescriptor instead')
const Account_Auth$json = {
  '1': 'Auth',
  '3': [Account_Auth_AppInfo$json],
  '4': [Account_Auth_LocalApiScope$json],
};

@$core.Deprecated('Use accountDescriptor instead')
const Account_Auth_AppInfo$json = {
  '1': 'AppInfo',
  '2': [
    {'1': 'appHash', '3': 1, '4': 1, '5': 9, '10': 'appHash'},
    {'1': 'appName', '3': 2, '4': 1, '5': 9, '10': 'appName'},
    {'1': 'appKey', '3': 4, '4': 1, '5': 9, '10': 'appKey'},
    {'1': 'createdAt', '3': 5, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'expireAt', '3': 6, '4': 1, '5': 3, '10': 'expireAt'},
    {
      '1': 'scope',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Account.Auth.LocalApiScope',
      '10': 'scope'
    },
    {'1': 'isActive', '3': 8, '4': 1, '5': 8, '10': 'isActive'},
  ],
};

@$core.Deprecated('Use accountDescriptor instead')
const Account_Auth_LocalApiScope$json = {
  '1': 'LocalApiScope',
  '2': [
    {'1': 'Limited', '2': 0},
    {'1': 'JsonAPI', '2': 1},
    {'1': 'Full', '2': 2},
  ],
};

@$core.Deprecated('Use accountDescriptor instead')
const Account_StatusType$json = {
  '1': 'StatusType',
  '2': [
    {'1': 'Active', '2': 0},
    {'1': 'PendingDeletion', '2': 1},
    {'1': 'StartedDeletion', '2': 2},
    {'1': 'Deleted', '2': 3},
  ],
};

/// Descriptor for `Account`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDescriptor = $convert.base64Decode(
    'CgdBY2NvdW50Eg4KAmlkGAEgASgJUgJpZBI1CgZjb25maWcYBCABKAsyHS5hbnl0eXBlLm1vZG'
    'VsLkFjY291bnQuQ29uZmlnUgZjb25maWcSNQoGc3RhdHVzGAUgASgLMh0uYW55dHlwZS5tb2Rl'
    'bC5BY2NvdW50LlN0YXR1c1IGc3RhdHVzEi8KBGluZm8YBiABKAsyGy5hbnl0eXBlLm1vZGVsLk'
    'FjY291bnQuSW5mb1IEaW5mbxrfAQoGQ29uZmlnEiYKDmVuYWJsZURhdGF2aWV3GAEgASgIUg5l'
    'bmFibGVEYXRhdmlldxIgCgtlbmFibGVEZWJ1ZxgCIAEoCFILZW5hYmxlRGVidWcSOAoXZW5hYm'
    'xlUHJlcmVsZWFzZUNoYW5uZWwYAyABKAhSF2VuYWJsZVByZXJlbGVhc2VDaGFubmVsEiIKDGVu'
    'YWJsZVNwYWNlcxgEIAEoCFIMZW5hYmxlU3BhY2VzEi0KBWV4dHJhGGQgASgLMhcuZ29vZ2xlLn'
    'Byb3RvYnVmLlN0cnVjdFIFZXh0cmEabwoGU3RhdHVzEkEKCnN0YXR1c1R5cGUYASABKA4yIS5h'
    'bnl0eXBlLm1vZGVsLkFjY291bnQuU3RhdHVzVHlwZVIKc3RhdHVzVHlwZRIiCgxkZWxldGlvbk'
    'RhdGUYAiABKANSDGRlbGV0aW9uRGF0ZRqgBQoESW5mbxIiCgxob21lT2JqZWN0SWQYAiABKAlS'
    'DGhvbWVPYmplY3RJZBIoCg9hcmNoaXZlT2JqZWN0SWQYAyABKAlSD2FyY2hpdmVPYmplY3RJZB'
    'IoCg9wcm9maWxlT2JqZWN0SWQYBCABKAlSD3Byb2ZpbGVPYmplY3RJZBI2ChZtYXJrZXRwbGFj'
    'ZVdvcmtzcGFjZUlkGAsgASgJUhZtYXJrZXRwbGFjZVdvcmtzcGFjZUlkEiwKEXdvcmtzcGFjZU'
    '9iamVjdElkGA8gASgJUhF3b3Jrc3BhY2VPYmplY3RJZBIgCgtzcGFjZUNoYXRJZBgQIAEoCVIL'
    'c3BhY2VDaGF0SWQSGgoIZGV2aWNlSWQYCCABKAlSCGRldmljZUlkEiYKDmFjY291bnRTcGFjZU'
    'lkGAkgASgJUg5hY2NvdW50U3BhY2VJZBIcCgl3aWRnZXRzSWQYCiABKAlSCXdpZGdldHNJZBIg'
    'CgtzcGFjZVZpZXdJZBgNIAEoCVILc3BhY2VWaWV3SWQSIAoLdGVjaFNwYWNlSWQYDiABKAlSC3'
    'RlY2hTcGFjZUlkEh4KCmdhdGV3YXlVcmwYZSABKAlSCmdhdGV3YXlVcmwSKgoQbG9jYWxTdG9y'
    'YWdlUGF0aBhnIAEoCVIQbG9jYWxTdG9yYWdlUGF0aBIaCgh0aW1lWm9uZRhoIAEoCVIIdGltZV'
    'pvbmUSIAoLYW5hbHl0aWNzSWQYaSABKAlSC2FuYWx5dGljc0lkEhwKCW5ldHdvcmtJZBhqIAEo'
    'CVIJbmV0d29ya0lkEigKD2V0aGVyZXVtQWRkcmVzcxhrIAEoCVIPZXRoZXJldW1BZGRyZXNzEi'
    'AKC21ldGFEYXRhS2V5GGwgASgJUgttZXRhRGF0YUtleRqqAgoEQXV0aBrsAQoHQXBwSW5mbxIY'
    'CgdhcHBIYXNoGAEgASgJUgdhcHBIYXNoEhgKB2FwcE5hbWUYAiABKAlSB2FwcE5hbWUSFgoGYX'
    'BwS2V5GAQgASgJUgZhcHBLZXkSHAoJY3JlYXRlZEF0GAUgASgDUgljcmVhdGVkQXQSGgoIZXhw'
    'aXJlQXQYBiABKANSCGV4cGlyZUF0Ej8KBXNjb3BlGAcgASgOMikuYW55dHlwZS5tb2RlbC5BY2'
    'NvdW50LkF1dGguTG9jYWxBcGlTY29wZVIFc2NvcGUSGgoIaXNBY3RpdmUYCCABKAhSCGlzQWN0'
    'aXZlIjMKDUxvY2FsQXBpU2NvcGUSCwoHTGltaXRlZBAAEgsKB0pzb25BUEkQARIICgRGdWxsEA'
    'IiTwoKU3RhdHVzVHlwZRIKCgZBY3RpdmUQABITCg9QZW5kaW5nRGVsZXRpb24QARITCg9TdGFy'
    'dGVkRGVsZXRpb24QAhILCgdEZWxldGVkEAM=');

@$core.Deprecated('Use linkPreviewDescriptor instead')
const LinkPreview$json = {
  '1': 'LinkPreview',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'imageUrl', '3': 4, '4': 1, '5': 9, '10': 'imageUrl'},
    {'1': 'faviconUrl', '3': 5, '4': 1, '5': 9, '10': 'faviconUrl'},
    {
      '1': 'type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.LinkPreview.Type',
      '10': 'type'
    },
  ],
  '4': [LinkPreview_Type$json],
};

@$core.Deprecated('Use linkPreviewDescriptor instead')
const LinkPreview_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'Unknown', '2': 0},
    {'1': 'Page', '2': 1},
    {'1': 'Image', '2': 2},
    {'1': 'Text', '2': 3},
  ],
};

/// Descriptor for `LinkPreview`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkPreviewDescriptor = $convert.base64Decode(
    'CgtMaW5rUHJldmlldxIQCgN1cmwYASABKAlSA3VybBIUCgV0aXRsZRgCIAEoCVIFdGl0bGUSIA'
    'oLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEhoKCGltYWdlVXJsGAQgASgJUghpbWFn'
    'ZVVybBIeCgpmYXZpY29uVXJsGAUgASgJUgpmYXZpY29uVXJsEjMKBHR5cGUYBiABKA4yHy5hbn'
    'l0eXBlLm1vZGVsLkxpbmtQcmV2aWV3LlR5cGVSBHR5cGUiMgoEVHlwZRILCgdVbmtub3duEAAS'
    'CAoEUGFnZRABEgkKBUltYWdlEAISCAoEVGV4dBAD');

@$core.Deprecated('Use restrictionsDescriptor instead')
const Restrictions$json = {
  '1': 'Restrictions',
  '2': [
    {
      '1': 'object',
      '3': 1,
      '4': 3,
      '5': 14,
      '6': '.anytype.model.Restrictions.ObjectRestriction',
      '10': 'object'
    },
    {
      '1': 'dataview',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Restrictions.DataviewRestrictions',
      '10': 'dataview'
    },
  ],
  '3': [Restrictions_DataviewRestrictions$json],
  '4': [
    Restrictions_ObjectRestriction$json,
    Restrictions_DataviewRestriction$json
  ],
};

@$core.Deprecated('Use restrictionsDescriptor instead')
const Restrictions_DataviewRestrictions$json = {
  '1': 'DataviewRestrictions',
  '2': [
    {'1': 'blockId', '3': 1, '4': 1, '5': 9, '10': 'blockId'},
    {
      '1': 'restrictions',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.anytype.model.Restrictions.DataviewRestriction',
      '10': 'restrictions'
    },
  ],
};

@$core.Deprecated('Use restrictionsDescriptor instead')
const Restrictions_ObjectRestriction$json = {
  '1': 'ObjectRestriction',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'Delete', '2': 1},
    {'1': 'Relations', '2': 2},
    {'1': 'Blocks', '2': 3},
    {'1': 'Details', '2': 4},
    {'1': 'TypeChange', '2': 5},
    {'1': 'LayoutChange', '2': 6},
    {'1': 'Template', '2': 7},
    {'1': 'Duplicate', '2': 8},
    {'1': 'CreateObjectOfThisType', '2': 9},
    {'1': 'Publish', '2': 10},
  ],
};

@$core.Deprecated('Use restrictionsDescriptor instead')
const Restrictions_DataviewRestriction$json = {
  '1': 'DataviewRestriction',
  '2': [
    {'1': 'DVNone', '2': 0},
    {'1': 'DVRelation', '2': 1},
    {'1': 'DVCreateObject', '2': 2},
    {'1': 'DVViews', '2': 3},
  ],
};

/// Descriptor for `Restrictions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restrictionsDescriptor = $convert.base64Decode(
    'CgxSZXN0cmljdGlvbnMSRQoGb2JqZWN0GAEgAygOMi0uYW55dHlwZS5tb2RlbC5SZXN0cmljdG'
    'lvbnMuT2JqZWN0UmVzdHJpY3Rpb25SBm9iamVjdBJMCghkYXRhdmlldxgCIAMoCzIwLmFueXR5'
    'cGUubW9kZWwuUmVzdHJpY3Rpb25zLkRhdGF2aWV3UmVzdHJpY3Rpb25zUghkYXRhdmlldxqFAQ'
    'oURGF0YXZpZXdSZXN0cmljdGlvbnMSGAoHYmxvY2tJZBgBIAEoCVIHYmxvY2tJZBJTCgxyZXN0'
    'cmljdGlvbnMYAiADKA4yLy5hbnl0eXBlLm1vZGVsLlJlc3RyaWN0aW9ucy5EYXRhdmlld1Jlc3'
    'RyaWN0aW9uUgxyZXN0cmljdGlvbnMiuQEKEU9iamVjdFJlc3RyaWN0aW9uEggKBE5vbmUQABIK'
    'CgZEZWxldGUQARINCglSZWxhdGlvbnMQAhIKCgZCbG9ja3MQAxILCgdEZXRhaWxzEAQSDgoKVH'
    'lwZUNoYW5nZRAFEhAKDExheW91dENoYW5nZRAGEgwKCFRlbXBsYXRlEAcSDQoJRHVwbGljYXRl'
    'EAgSGgoWQ3JlYXRlT2JqZWN0T2ZUaGlzVHlwZRAJEgsKB1B1Ymxpc2gQCiJSChNEYXRhdmlld1'
    'Jlc3RyaWN0aW9uEgoKBkRWTm9uZRAAEg4KCkRWUmVsYXRpb24QARISCg5EVkNyZWF0ZU9iamVj'
    'dBACEgsKB0RWVmlld3MQAw==');

@$core.Deprecated('Use objectDescriptor instead')
const Object$json = {
  '1': 'Object',
  '3': [Object_ChangePayload$json],
};

@$core.Deprecated('Use objectDescriptor instead')
const Object_ChangePayload$json = {
  '1': 'ChangePayload',
  '2': [
    {
      '1': 'smartBlockType',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.SmartBlockType',
      '10': 'smartBlockType'
    },
    {'1': 'key', '3': 2, '4': 1, '5': 9, '10': 'key'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `Object`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List objectDescriptor = $convert.base64Decode(
    'CgZPYmplY3QafAoNQ2hhbmdlUGF5bG9hZBJFCg5zbWFydEJsb2NrVHlwZRgBIAEoDjIdLmFueX'
    'R5cGUubW9kZWwuU21hcnRCbG9ja1R5cGVSDnNtYXJ0QmxvY2tUeXBlEhAKA2tleRgCIAEoCVID'
    'a2V5EhIKBGRhdGEYAyABKAxSBGRhdGE=');

@$core.Deprecated('Use spaceObjectHeaderDescriptor instead')
const SpaceObjectHeader$json = {
  '1': 'SpaceObjectHeader',
  '2': [
    {'1': 'spaceID', '3': 1, '4': 1, '5': 9, '10': 'spaceID'},
  ],
};

/// Descriptor for `SpaceObjectHeader`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List spaceObjectHeaderDescriptor = $convert.base64Decode(
    'ChFTcGFjZU9iamVjdEhlYWRlchIYCgdzcGFjZUlEGAEgASgJUgdzcGFjZUlE');

@$core.Deprecated('Use objectTypeDescriptor instead')
const ObjectType$json = {
  '1': 'ObjectType',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'relationLinks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.RelationLink',
      '10': 'relationLinks'
    },
    {
      '1': 'layout',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.ObjectType.Layout',
      '10': 'layout'
    },
    {'1': 'iconEmoji', '3': 5, '4': 1, '5': 9, '10': 'iconEmoji'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'hidden', '3': 7, '4': 1, '5': 8, '10': 'hidden'},
    {'1': 'readonly', '3': 10, '4': 1, '5': 8, '10': 'readonly'},
    {
      '1': 'types',
      '3': 8,
      '4': 3,
      '5': 14,
      '6': '.anytype.model.SmartBlockType',
      '10': 'types'
    },
    {'1': 'isArchived', '3': 9, '4': 1, '5': 8, '10': 'isArchived'},
    {
      '1': 'installedByDefault',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'installedByDefault'
    },
    {'1': 'key', '3': 12, '4': 1, '5': 9, '10': 'key'},
    {'1': 'revision', '3': 13, '4': 1, '5': 3, '10': 'revision'},
    {
      '1': 'restrictObjectCreation',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'restrictObjectCreation'
    },
    {'1': 'iconColor', '3': 15, '4': 1, '5': 3, '10': 'iconColor'},
    {'1': 'iconName', '3': 16, '4': 1, '5': 9, '10': 'iconName'},
    {'1': 'pluralName', '3': 17, '4': 1, '5': 9, '10': 'pluralName'},
  ],
  '4': [ObjectType_Layout$json],
};

@$core.Deprecated('Use objectTypeDescriptor instead')
const ObjectType_Layout$json = {
  '1': 'Layout',
  '2': [
    {'1': 'basic', '2': 0},
    {'1': 'profile', '2': 1},
    {'1': 'todo', '2': 2},
    {'1': 'set', '2': 3},
    {'1': 'objectType', '2': 4},
    {'1': 'relation', '2': 5},
    {'1': 'file', '2': 6},
    {'1': 'dashboard', '2': 7},
    {'1': 'image', '2': 8},
    {'1': 'note', '2': 9},
    {'1': 'space', '2': 10},
    {'1': 'bookmark', '2': 11},
    {'1': 'relationOptionsList', '2': 12},
    {'1': 'relationOption', '2': 13},
    {'1': 'collection', '2': 14},
    {'1': 'audio', '2': 15},
    {'1': 'video', '2': 16},
    {'1': 'date', '2': 17},
    {'1': 'spaceView', '2': 18},
    {'1': 'participant', '2': 19},
    {'1': 'pdf', '2': 20},
    {'1': 'chatDeprecated', '2': 21},
    {'1': 'chatDerived', '2': 22},
    {'1': 'tag', '2': 23},
    {'1': 'notification', '2': 24},
    {'1': 'missingObject', '2': 25},
    {'1': 'devices', '2': 26},
    {'1': 'discussion', '2': 27},
  ],
};

/// Descriptor for `ObjectType`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List objectTypeDescriptor = $convert.base64Decode(
    'CgpPYmplY3RUeXBlEhAKA3VybBgBIAEoCVIDdXJsEhIKBG5hbWUYAiABKAlSBG5hbWUSQQoNcm'
    'VsYXRpb25MaW5rcxgDIAMoCzIbLmFueXR5cGUubW9kZWwuUmVsYXRpb25MaW5rUg1yZWxhdGlv'
    'bkxpbmtzEjgKBmxheW91dBgEIAEoDjIgLmFueXR5cGUubW9kZWwuT2JqZWN0VHlwZS5MYXlvdX'
    'RSBmxheW91dBIcCglpY29uRW1vamkYBSABKAlSCWljb25FbW9qaRIgCgtkZXNjcmlwdGlvbhgG'
    'IAEoCVILZGVzY3JpcHRpb24SFgoGaGlkZGVuGAcgASgIUgZoaWRkZW4SGgoIcmVhZG9ubHkYCi'
    'ABKAhSCHJlYWRvbmx5EjMKBXR5cGVzGAggAygOMh0uYW55dHlwZS5tb2RlbC5TbWFydEJsb2Nr'
    'VHlwZVIFdHlwZXMSHgoKaXNBcmNoaXZlZBgJIAEoCFIKaXNBcmNoaXZlZBIuChJpbnN0YWxsZW'
    'RCeURlZmF1bHQYCyABKAhSEmluc3RhbGxlZEJ5RGVmYXVsdBIQCgNrZXkYDCABKAlSA2tleRIa'
    'CghyZXZpc2lvbhgNIAEoA1IIcmV2aXNpb24SNgoWcmVzdHJpY3RPYmplY3RDcmVhdGlvbhgOIA'
    'EoCFIWcmVzdHJpY3RPYmplY3RDcmVhdGlvbhIcCglpY29uQ29sb3IYDyABKANSCWljb25Db2xv'
    'chIaCghpY29uTmFtZRgQIAEoCVIIaWNvbk5hbWUSHgoKcGx1cmFsTmFtZRgRIAEoCVIKcGx1cm'
    'FsTmFtZSKOAwoGTGF5b3V0EgkKBWJhc2ljEAASCwoHcHJvZmlsZRABEggKBHRvZG8QAhIHCgNz'
    'ZXQQAxIOCgpvYmplY3RUeXBlEAQSDAoIcmVsYXRpb24QBRIICgRmaWxlEAYSDQoJZGFzaGJvYX'
    'JkEAcSCQoFaW1hZ2UQCBIICgRub3RlEAkSCQoFc3BhY2UQChIMCghib29rbWFyaxALEhcKE3Jl'
    'bGF0aW9uT3B0aW9uc0xpc3QQDBISCg5yZWxhdGlvbk9wdGlvbhANEg4KCmNvbGxlY3Rpb24QDh'
    'IJCgVhdWRpbxAPEgkKBXZpZGVvEBASCAoEZGF0ZRAREg0KCXNwYWNlVmlldxASEg8KC3BhcnRp'
    'Y2lwYW50EBMSBwoDcGRmEBQSEgoOY2hhdERlcHJlY2F0ZWQQFRIPCgtjaGF0RGVyaXZlZBAWEg'
    'cKA3RhZxAXEhAKDG5vdGlmaWNhdGlvbhAYEhEKDW1pc3NpbmdPYmplY3QQGRILCgdkZXZpY2Vz'
    'EBoSDgoKZGlzY3Vzc2lvbhAb');

@$core.Deprecated('Use layoutDescriptor instead')
const Layout$json = {
  '1': 'Layout',
  '2': [
    {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.ObjectType.Layout',
      '10': 'id'
    },
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'requiredRelations',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Relation',
      '10': 'requiredRelations'
    },
  ],
};

/// Descriptor for `Layout`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutDescriptor = $convert.base64Decode(
    'CgZMYXlvdXQSMAoCaWQYASABKA4yIC5hbnl0eXBlLm1vZGVsLk9iamVjdFR5cGUuTGF5b3V0Ug'
    'JpZBISCgRuYW1lGAIgASgJUgRuYW1lEkUKEXJlcXVpcmVkUmVsYXRpb25zGAMgAygLMhcuYW55'
    'dHlwZS5tb2RlbC5SZWxhdGlvblIRcmVxdWlyZWRSZWxhdGlvbnM=');

@$core.Deprecated('Use relationWithValueDescriptor instead')
const RelationWithValue$json = {
  '1': 'RelationWithValue',
  '2': [
    {
      '1': 'relation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Relation',
      '10': 'relation'
    },
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

/// Descriptor for `RelationWithValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List relationWithValueDescriptor = $convert.base64Decode(
    'ChFSZWxhdGlvbldpdGhWYWx1ZRIzCghyZWxhdGlvbhgBIAEoCzIXLmFueXR5cGUubW9kZWwuUm'
    'VsYXRpb25SCHJlbGF0aW9uEiwKBXZhbHVlGAIgASgLMhYuZ29vZ2xlLnByb3RvYnVmLlZhbHVl'
    'UgV2YWx1ZQ==');

@$core.Deprecated('Use relationDescriptor instead')
const Relation$json = {
  '1': 'Relation',
  '2': [
    {'1': 'id', '3': 100, '4': 1, '5': 9, '10': 'id'},
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'format',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.RelationFormat',
      '10': 'format'
    },
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'defaultValue',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Value',
      '10': 'defaultValue'
    },
    {
      '1': 'dataSource',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Relation.DataSource',
      '10': 'dataSource'
    },
    {'1': 'hidden', '3': 6, '4': 1, '5': 8, '10': 'hidden'},
    {'1': 'readOnly', '3': 7, '4': 1, '5': 8, '10': 'readOnly'},
    {
      '1': 'readOnlyRelation',
      '3': 15,
      '4': 1,
      '5': 8,
      '10': 'readOnlyRelation'
    },
    {'1': 'multi', '3': 8, '4': 1, '5': 8, '10': 'multi'},
    {'1': 'objectTypes', '3': 9, '4': 3, '5': 9, '10': 'objectTypes'},
    {
      '1': 'selectDict',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Relation.Option',
      '10': 'selectDict'
    },
    {'1': 'maxCount', '3': 13, '4': 1, '5': 5, '10': 'maxCount'},
    {'1': 'description', '3': 14, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'scope',
      '3': 20,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Relation.Scope',
      '10': 'scope'
    },
    {'1': 'creator', '3': 21, '4': 1, '5': 9, '10': 'creator'},
    {'1': 'revision', '3': 22, '4': 1, '5': 3, '10': 'revision'},
    {'1': 'includeTime', '3': 23, '4': 1, '5': 8, '10': 'includeTime'},
  ],
  '3': [Relation_Option$json],
  '4': [Relation_Scope$json, Relation_DataSource$json],
};

@$core.Deprecated('Use relationDescriptor instead')
const Relation_Option$json = {
  '1': 'Option',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {'1': 'color', '3': 3, '4': 1, '5': 9, '10': 'color'},
    {'1': 'relationKey', '3': 5, '4': 1, '5': 9, '10': 'relationKey'},
    {'1': 'orderId', '3': 6, '4': 1, '5': 9, '10': 'orderId'},
  ],
};

@$core.Deprecated('Use relationDescriptor instead')
const Relation_Scope$json = {
  '1': 'Scope',
  '2': [
    {'1': 'object', '2': 0},
    {'1': 'type', '2': 1},
    {'1': 'setOfTheSameType', '2': 2},
    {'1': 'objectsOfTheSameType', '2': 3},
    {'1': 'library', '2': 4},
  ],
};

@$core.Deprecated('Use relationDescriptor instead')
const Relation_DataSource$json = {
  '1': 'DataSource',
  '2': [
    {'1': 'details', '2': 0},
    {'1': 'derived', '2': 1},
    {'1': 'account', '2': 2},
    {'1': 'local', '2': 3},
  ],
};

/// Descriptor for `Relation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List relationDescriptor = $convert.base64Decode(
    'CghSZWxhdGlvbhIOCgJpZBhkIAEoCVICaWQSEAoDa2V5GAEgASgJUgNrZXkSNQoGZm9ybWF0GA'
    'IgASgOMh0uYW55dHlwZS5tb2RlbC5SZWxhdGlvbkZvcm1hdFIGZm9ybWF0EhIKBG5hbWUYAyAB'
    'KAlSBG5hbWUSOgoMZGVmYXVsdFZhbHVlGAQgASgLMhYuZ29vZ2xlLnByb3RvYnVmLlZhbHVlUg'
    'xkZWZhdWx0VmFsdWUSQgoKZGF0YVNvdXJjZRgFIAEoDjIiLmFueXR5cGUubW9kZWwuUmVsYXRp'
    'b24uRGF0YVNvdXJjZVIKZGF0YVNvdXJjZRIWCgZoaWRkZW4YBiABKAhSBmhpZGRlbhIaCghyZW'
    'FkT25seRgHIAEoCFIIcmVhZE9ubHkSKgoQcmVhZE9ubHlSZWxhdGlvbhgPIAEoCFIQcmVhZE9u'
    'bHlSZWxhdGlvbhIUCgVtdWx0aRgIIAEoCFIFbXVsdGkSIAoLb2JqZWN0VHlwZXMYCSADKAlSC2'
    '9iamVjdFR5cGVzEj4KCnNlbGVjdERpY3QYDCADKAsyHi5hbnl0eXBlLm1vZGVsLlJlbGF0aW9u'
    'Lk9wdGlvblIKc2VsZWN0RGljdBIaCghtYXhDb3VudBgNIAEoBVIIbWF4Q291bnQSIAoLZGVzY3'
    'JpcHRpb24YDiABKAlSC2Rlc2NyaXB0aW9uEjMKBXNjb3BlGBQgASgOMh0uYW55dHlwZS5tb2Rl'
    'bC5SZWxhdGlvbi5TY29wZVIFc2NvcGUSGAoHY3JlYXRvchgVIAEoCVIHY3JlYXRvchIaCghyZX'
    'Zpc2lvbhgWIAEoA1IIcmV2aXNpb24SIAoLaW5jbHVkZVRpbWUYFyABKAhSC2luY2x1ZGVUaW1l'
    'Gn4KBk9wdGlvbhIOCgJpZBgBIAEoCVICaWQSEgoEdGV4dBgCIAEoCVIEdGV4dBIUCgVjb2xvch'
    'gDIAEoCVIFY29sb3ISIAoLcmVsYXRpb25LZXkYBSABKAlSC3JlbGF0aW9uS2V5EhgKB29yZGVy'
    'SWQYBiABKAlSB29yZGVySWQiWgoFU2NvcGUSCgoGb2JqZWN0EAASCAoEdHlwZRABEhQKEHNldE'
    '9mVGhlU2FtZVR5cGUQAhIYChRvYmplY3RzT2ZUaGVTYW1lVHlwZRADEgsKB2xpYnJhcnkQBCI+'
    'CgpEYXRhU291cmNlEgsKB2RldGFpbHMQABILCgdkZXJpdmVkEAESCwoHYWNjb3VudBACEgkKBW'
    'xvY2FsEAM=');

@$core.Deprecated('Use relationLinkDescriptor instead')
const RelationLink$json = {
  '1': 'RelationLink',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'format',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.RelationFormat',
      '10': 'format'
    },
  ],
};

/// Descriptor for `RelationLink`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List relationLinkDescriptor = $convert.base64Decode(
    'CgxSZWxhdGlvbkxpbmsSEAoDa2V5GAEgASgJUgNrZXkSNQoGZm9ybWF0GAIgASgOMh0uYW55dH'
    'lwZS5tb2RlbC5SZWxhdGlvbkZvcm1hdFIGZm9ybWF0');

@$core.Deprecated('Use relationsDescriptor instead')
const Relations$json = {
  '1': 'Relations',
  '2': [
    {
      '1': 'relations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Relation',
      '10': 'relations'
    },
  ],
};

/// Descriptor for `Relations`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List relationsDescriptor = $convert.base64Decode(
    'CglSZWxhdGlvbnMSNQoJcmVsYXRpb25zGAEgAygLMhcuYW55dHlwZS5tb2RlbC5SZWxhdGlvbl'
    'IJcmVsYXRpb25z');

@$core.Deprecated('Use relationOptionsDescriptor instead')
const RelationOptions$json = {
  '1': 'RelationOptions',
  '2': [
    {
      '1': 'options',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Relation.Option',
      '10': 'options'
    },
  ],
};

/// Descriptor for `RelationOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List relationOptionsDescriptor = $convert.base64Decode(
    'Cg9SZWxhdGlvbk9wdGlvbnMSOAoHb3B0aW9ucxgBIAMoCzIeLmFueXR5cGUubW9kZWwuUmVsYX'
    'Rpb24uT3B0aW9uUgdvcHRpb25z');

@$core.Deprecated('Use internalFlagDescriptor instead')
const InternalFlag$json = {
  '1': 'InternalFlag',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.InternalFlag.Value',
      '10': 'value'
    },
  ],
  '4': [InternalFlag_Value$json],
};

@$core.Deprecated('Use internalFlagDescriptor instead')
const InternalFlag_Value$json = {
  '1': 'Value',
  '2': [
    {'1': 'editorDeleteEmpty', '2': 0},
    {'1': 'editorSelectType', '2': 1},
    {'1': 'editorSelectTemplate', '2': 2},
    {'1': 'collectionDontIndexLinks', '2': 3},
  ],
};

/// Descriptor for `InternalFlag`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List internalFlagDescriptor = $convert.base64Decode(
    'CgxJbnRlcm5hbEZsYWcSNwoFdmFsdWUYASABKA4yIS5hbnl0eXBlLm1vZGVsLkludGVybmFsRm'
    'xhZy5WYWx1ZVIFdmFsdWUibAoFVmFsdWUSFQoRZWRpdG9yRGVsZXRlRW1wdHkQABIUChBlZGl0'
    'b3JTZWxlY3RUeXBlEAESGAoUZWRpdG9yU2VsZWN0VGVtcGxhdGUQAhIcChhjb2xsZWN0aW9uRG'
    '9udEluZGV4TGlua3MQAw==');

@$core.Deprecated('Use objectViewDescriptor instead')
const ObjectView$json = {
  '1': 'ObjectView',
  '2': [
    {'1': 'rootId', '3': 1, '4': 1, '5': 9, '10': 'rootId'},
    {
      '1': 'blocks',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block',
      '10': 'blocks'
    },
    {
      '1': 'details',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.ObjectView.DetailsSet',
      '10': 'details'
    },
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.SmartBlockType',
      '10': 'type'
    },
    {
      '1': 'relations',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Relation',
      '10': 'relations'
    },
    {
      '1': 'relationLinks',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.RelationLink',
      '10': 'relationLinks'
    },
    {
      '1': 'restrictions',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Restrictions',
      '10': 'restrictions'
    },
    {
      '1': 'history',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ObjectView.HistorySize',
      '10': 'history'
    },
    {
      '1': 'blockParticipants',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.ObjectView.BlockParticipant',
      '10': 'blockParticipants'
    },
  ],
  '3': [
    ObjectView_DetailsSet$json,
    ObjectView_RelationWithValuePerObject$json,
    ObjectView_HistorySize$json,
    ObjectView_BlockParticipant$json
  ],
};

@$core.Deprecated('Use objectViewDescriptor instead')
const ObjectView_DetailsSet$json = {
  '1': 'DetailsSet',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'details',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'details'
    },
    {'1': 'subIds', '3': 3, '4': 3, '5': 9, '10': 'subIds'},
  ],
};

@$core.Deprecated('Use objectViewDescriptor instead')
const ObjectView_RelationWithValuePerObject$json = {
  '1': 'RelationWithValuePerObject',
  '2': [
    {'1': 'objectId', '3': 1, '4': 1, '5': 9, '10': 'objectId'},
    {
      '1': 'relations',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.RelationWithValue',
      '10': 'relations'
    },
  ],
};

@$core.Deprecated('Use objectViewDescriptor instead')
const ObjectView_HistorySize$json = {
  '1': 'HistorySize',
  '2': [
    {'1': 'undo', '3': 1, '4': 1, '5': 5, '10': 'undo'},
    {'1': 'redo', '3': 2, '4': 1, '5': 5, '10': 'redo'},
  ],
};

@$core.Deprecated('Use objectViewDescriptor instead')
const ObjectView_BlockParticipant$json = {
  '1': 'BlockParticipant',
  '2': [
    {'1': 'blockId', '3': 1, '4': 1, '5': 9, '10': 'blockId'},
    {'1': 'participantId', '3': 2, '4': 1, '5': 9, '10': 'participantId'},
  ],
};

/// Descriptor for `ObjectView`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List objectViewDescriptor = $convert.base64Decode(
    'CgpPYmplY3RWaWV3EhYKBnJvb3RJZBgBIAEoCVIGcm9vdElkEiwKBmJsb2NrcxgCIAMoCzIULm'
    'FueXR5cGUubW9kZWwuQmxvY2tSBmJsb2NrcxI+CgdkZXRhaWxzGAMgAygLMiQuYW55dHlwZS5t'
    'b2RlbC5PYmplY3RWaWV3LkRldGFpbHNTZXRSB2RldGFpbHMSMQoEdHlwZRgEIAEoDjIdLmFueX'
    'R5cGUubW9kZWwuU21hcnRCbG9ja1R5cGVSBHR5cGUSNQoJcmVsYXRpb25zGAcgAygLMhcuYW55'
    'dHlwZS5tb2RlbC5SZWxhdGlvblIJcmVsYXRpb25zEkEKDXJlbGF0aW9uTGlua3MYCiADKAsyGy'
    '5hbnl0eXBlLm1vZGVsLlJlbGF0aW9uTGlua1INcmVsYXRpb25MaW5rcxI/CgxyZXN0cmljdGlv'
    'bnMYCCABKAsyGy5hbnl0eXBlLm1vZGVsLlJlc3RyaWN0aW9uc1IMcmVzdHJpY3Rpb25zEj8KB2'
    'hpc3RvcnkYCSABKAsyJS5hbnl0eXBlLm1vZGVsLk9iamVjdFZpZXcuSGlzdG9yeVNpemVSB2hp'
    'c3RvcnkSWAoRYmxvY2tQYXJ0aWNpcGFudHMYCyADKAsyKi5hbnl0eXBlLm1vZGVsLk9iamVjdF'
    'ZpZXcuQmxvY2tQYXJ0aWNpcGFudFIRYmxvY2tQYXJ0aWNpcGFudHMaZwoKRGV0YWlsc1NldBIO'
    'CgJpZBgBIAEoCVICaWQSMQoHZGV0YWlscxgCIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3'
    'RSB2RldGFpbHMSFgoGc3ViSWRzGAMgAygJUgZzdWJJZHMaeAoaUmVsYXRpb25XaXRoVmFsdWVQ'
    'ZXJPYmplY3QSGgoIb2JqZWN0SWQYASABKAlSCG9iamVjdElkEj4KCXJlbGF0aW9ucxgCIAMoCz'
    'IgLmFueXR5cGUubW9kZWwuUmVsYXRpb25XaXRoVmFsdWVSCXJlbGF0aW9ucxo1CgtIaXN0b3J5'
    'U2l6ZRISCgR1bmRvGAEgASgFUgR1bmRvEhIKBHJlZG8YAiABKAVSBHJlZG8aUgoQQmxvY2tQYX'
    'J0aWNpcGFudBIYCgdibG9ja0lkGAEgASgJUgdibG9ja0lkEiQKDXBhcnRpY2lwYW50SWQYAiAB'
    'KAlSDXBhcnRpY2lwYW50SWQ=');

@$core.Deprecated('Use participantPermissionChangeDescriptor instead')
const ParticipantPermissionChange$json = {
  '1': 'ParticipantPermissionChange',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 9, '10': 'identity'},
    {
      '1': 'perms',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.ParticipantPermissions',
      '10': 'perms'
    },
  ],
};

/// Descriptor for `ParticipantPermissionChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantPermissionChangeDescriptor =
    $convert.base64Decode(
        'ChtQYXJ0aWNpcGFudFBlcm1pc3Npb25DaGFuZ2USGgoIaWRlbnRpdHkYASABKAlSCGlkZW50aX'
        'R5EjsKBXBlcm1zGAIgASgOMiUuYW55dHlwZS5tb2RlbC5QYXJ0aWNpcGFudFBlcm1pc3Npb25z'
        'UgVwZXJtcw==');

@$core.Deprecated('Use metadataDescriptor instead')
const Metadata$json = {
  '1': 'Metadata',
  '2': [
    {
      '1': 'identity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Metadata.Payload.IdentityPayload',
      '9': 0,
      '10': 'identity'
    },
  ],
  '3': [Metadata_Payload$json],
  '8': [
    {'1': 'payload'},
  ],
};

@$core.Deprecated('Use metadataDescriptor instead')
const Metadata_Payload$json = {
  '1': 'Payload',
  '3': [Metadata_Payload_IdentityPayload$json],
};

@$core.Deprecated('Use metadataDescriptor instead')
const Metadata_Payload_IdentityPayload$json = {
  '1': 'IdentityPayload',
  '2': [
    {'1': 'profileSymKey', '3': 1, '4': 1, '5': 12, '10': 'profileSymKey'},
  ],
};

/// Descriptor for `Metadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metadataDescriptor = $convert.base64Decode(
    'CghNZXRhZGF0YRJNCghpZGVudGl0eRgBIAEoCzIvLmFueXR5cGUubW9kZWwuTWV0YWRhdGEuUG'
    'F5bG9hZC5JZGVudGl0eVBheWxvYWRIAFIIaWRlbnRpdHkaQgoHUGF5bG9hZBo3Cg9JZGVudGl0'
    'eVBheWxvYWQSJAoNcHJvZmlsZVN5bUtleRgBIAEoDFINcHJvZmlsZVN5bUtleUIJCgdwYXlsb2'
    'Fk');

@$core.Deprecated('Use notificationDescriptor instead')
const Notification$json = {
  '1': 'Notification',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'createTime', '3': 2, '4': 1, '5': 3, '10': 'createTime'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Notification.Status',
      '10': 'status'
    },
    {'1': 'isLocal', '3': 5, '4': 1, '5': 8, '10': 'isLocal'},
    {
      '1': 'import',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.Import',
      '9': 0,
      '10': 'import'
    },
    {
      '1': 'export',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.Export',
      '9': 0,
      '10': 'export'
    },
    {
      '1': 'galleryImport',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.GalleryImport',
      '9': 0,
      '10': 'galleryImport'
    },
    {
      '1': 'requestToJoin',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.RequestToJoin',
      '9': 0,
      '10': 'requestToJoin'
    },
    {
      '1': 'test',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.Test',
      '9': 0,
      '10': 'test'
    },
    {
      '1': 'participantRequestApproved',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.ParticipantRequestApproved',
      '9': 0,
      '10': 'participantRequestApproved'
    },
    {
      '1': 'requestToLeave',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.RequestToLeave',
      '9': 0,
      '10': 'requestToLeave'
    },
    {
      '1': 'participantRemove',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.ParticipantRemove',
      '9': 0,
      '10': 'participantRemove'
    },
    {
      '1': 'participantRequestDecline',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.ParticipantRequestDecline',
      '9': 0,
      '10': 'participantRequestDecline'
    },
    {
      '1': 'participantPermissionsChange',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Notification.ParticipantPermissionsChange',
      '9': 0,
      '10': 'participantPermissionsChange'
    },
    {'1': 'space', '3': 7, '4': 1, '5': 9, '10': 'space'},
    {'1': 'aclHeadId', '3': 14, '4': 1, '5': 9, '10': 'aclHeadId'},
  ],
  '3': [
    Notification_Import$json,
    Notification_Export$json,
    Notification_GalleryImport$json,
    Notification_RequestToJoin$json,
    Notification_Test$json,
    Notification_ParticipantRequestApproved$json,
    Notification_RequestToLeave$json,
    Notification_ParticipantRemove$json,
    Notification_ParticipantRequestDecline$json,
    Notification_ParticipantPermissionsChange$json
  ],
  '4': [Notification_Status$json, Notification_ActionType$json],
  '8': [
    {'1': 'payload'},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_Import$json = {
  '1': 'Import',
  '2': [
    {'1': 'processId', '3': 1, '4': 1, '5': 9, '10': 'processId'},
    {
      '1': 'errorCode',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Import.ErrorCode',
      '10': 'errorCode'
    },
    {
      '1': 'importType',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Import.Type',
      '10': 'importType'
    },
    {'1': 'spaceId', '3': 4, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'spaceName', '3': 6, '4': 1, '5': 9, '10': 'spaceName'},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_Export$json = {
  '1': 'Export',
  '2': [
    {
      '1': 'errorCode',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Notification.Export.Code',
      '10': 'errorCode'
    },
    {
      '1': 'exportType',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Export.Format',
      '10': 'exportType'
    },
  ],
  '4': [Notification_Export_Code$json],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_Export_Code$json = {
  '1': 'Code',
  '2': [
    {'1': 'NULL', '2': 0},
    {'1': 'UNKNOWN_ERROR', '2': 1},
    {'1': 'BAD_INPUT', '2': 2},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_GalleryImport$json = {
  '1': 'GalleryImport',
  '2': [
    {'1': 'processId', '3': 1, '4': 1, '5': 9, '10': 'processId'},
    {
      '1': 'errorCode',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Import.ErrorCode',
      '10': 'errorCode'
    },
    {'1': 'spaceId', '3': 3, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'spaceName', '3': 5, '4': 1, '5': 9, '10': 'spaceName'},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_RequestToJoin$json = {
  '1': 'RequestToJoin',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'identity', '3': 2, '4': 1, '5': 9, '10': 'identity'},
    {'1': 'identityName', '3': 3, '4': 1, '5': 9, '10': 'identityName'},
    {'1': 'identityIcon', '3': 4, '4': 1, '5': 9, '10': 'identityIcon'},
    {'1': 'spaceName', '3': 5, '4': 1, '5': 9, '10': 'spaceName'},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_Test$json = {
  '1': 'Test',
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_ParticipantRequestApproved$json = {
  '1': 'ParticipantRequestApproved',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {
      '1': 'permissions',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.ParticipantPermissions',
      '10': 'permissions'
    },
    {'1': 'spaceName', '3': 5, '4': 1, '5': 9, '10': 'spaceName'},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_RequestToLeave$json = {
  '1': 'RequestToLeave',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'identity', '3': 2, '4': 1, '5': 9, '10': 'identity'},
    {'1': 'identityName', '3': 3, '4': 1, '5': 9, '10': 'identityName'},
    {'1': 'identityIcon', '3': 4, '4': 1, '5': 9, '10': 'identityIcon'},
    {'1': 'spaceName', '3': 5, '4': 1, '5': 9, '10': 'spaceName'},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_ParticipantRemove$json = {
  '1': 'ParticipantRemove',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 9, '10': 'identity'},
    {'1': 'identityName', '3': 2, '4': 1, '5': 9, '10': 'identityName'},
    {'1': 'identityIcon', '3': 3, '4': 1, '5': 9, '10': 'identityIcon'},
    {'1': 'spaceId', '3': 4, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'spaceName', '3': 5, '4': 1, '5': 9, '10': 'spaceName'},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_ParticipantRequestDecline$json = {
  '1': 'ParticipantRequestDecline',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'spaceName', '3': 3, '4': 1, '5': 9, '10': 'spaceName'},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_ParticipantPermissionsChange$json = {
  '1': 'ParticipantPermissionsChange',
  '2': [
    {'1': 'spaceId', '3': 1, '4': 1, '5': 9, '10': 'spaceId'},
    {
      '1': 'permissions',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.ParticipantPermissions',
      '10': 'permissions'
    },
    {'1': 'spaceName', '3': 3, '4': 1, '5': 9, '10': 'spaceName'},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'Created', '2': 0},
    {'1': 'Shown', '2': 1},
    {'1': 'Read', '2': 2},
    {'1': 'Replied', '2': 3},
  ],
};

@$core.Deprecated('Use notificationDescriptor instead')
const Notification_ActionType$json = {
  '1': 'ActionType',
  '2': [
    {'1': 'CLOSE', '2': 0},
  ],
};

/// Descriptor for `Notification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDescriptor = $convert.base64Decode(
    'CgxOb3RpZmljYXRpb24SDgoCaWQYASABKAlSAmlkEh4KCmNyZWF0ZVRpbWUYAiABKANSCmNyZW'
    'F0ZVRpbWUSOgoGc3RhdHVzGAQgASgOMiIuYW55dHlwZS5tb2RlbC5Ob3RpZmljYXRpb24uU3Rh'
    'dHVzUgZzdGF0dXMSGAoHaXNMb2NhbBgFIAEoCFIHaXNMb2NhbBI8CgZpbXBvcnQYBiABKAsyIi'
    '5hbnl0eXBlLm1vZGVsLk5vdGlmaWNhdGlvbi5JbXBvcnRIAFIGaW1wb3J0EjwKBmV4cG9ydBgI'
    'IAEoCzIiLmFueXR5cGUubW9kZWwuTm90aWZpY2F0aW9uLkV4cG9ydEgAUgZleHBvcnQSUQoNZ2'
    'FsbGVyeUltcG9ydBgJIAEoCzIpLmFueXR5cGUubW9kZWwuTm90aWZpY2F0aW9uLkdhbGxlcnlJ'
    'bXBvcnRIAFINZ2FsbGVyeUltcG9ydBJRCg1yZXF1ZXN0VG9Kb2luGAogASgLMikuYW55dHlwZS'
    '5tb2RlbC5Ob3RpZmljYXRpb24uUmVxdWVzdFRvSm9pbkgAUg1yZXF1ZXN0VG9Kb2luEjYKBHRl'
    'c3QYCyABKAsyIC5hbnl0eXBlLm1vZGVsLk5vdGlmaWNhdGlvbi5UZXN0SABSBHRlc3QSeAoacG'
    'FydGljaXBhbnRSZXF1ZXN0QXBwcm92ZWQYDSABKAsyNi5hbnl0eXBlLm1vZGVsLk5vdGlmaWNh'
    'dGlvbi5QYXJ0aWNpcGFudFJlcXVlc3RBcHByb3ZlZEgAUhpwYXJ0aWNpcGFudFJlcXVlc3RBcH'
    'Byb3ZlZBJUCg5yZXF1ZXN0VG9MZWF2ZRgPIAEoCzIqLmFueXR5cGUubW9kZWwuTm90aWZpY2F0'
    'aW9uLlJlcXVlc3RUb0xlYXZlSABSDnJlcXVlc3RUb0xlYXZlEl0KEXBhcnRpY2lwYW50UmVtb3'
    'ZlGBAgASgLMi0uYW55dHlwZS5tb2RlbC5Ob3RpZmljYXRpb24uUGFydGljaXBhbnRSZW1vdmVI'
    'AFIRcGFydGljaXBhbnRSZW1vdmUSdQoZcGFydGljaXBhbnRSZXF1ZXN0RGVjbGluZRgRIAEoCz'
    'I1LmFueXR5cGUubW9kZWwuTm90aWZpY2F0aW9uLlBhcnRpY2lwYW50UmVxdWVzdERlY2xpbmVI'
    'AFIZcGFydGljaXBhbnRSZXF1ZXN0RGVjbGluZRJ+ChxwYXJ0aWNpcGFudFBlcm1pc3Npb25zQ2'
    'hhbmdlGBIgASgLMjguYW55dHlwZS5tb2RlbC5Ob3RpZmljYXRpb24uUGFydGljaXBhbnRQZXJt'
    'aXNzaW9uc0NoYW5nZUgAUhxwYXJ0aWNpcGFudFBlcm1pc3Npb25zQ2hhbmdlEhQKBXNwYWNlGA'
    'cgASgJUgVzcGFjZRIcCglhY2xIZWFkSWQYDiABKAlSCWFjbEhlYWRJZBrtAQoGSW1wb3J0EhwK'
    'CXByb2Nlc3NJZBgBIAEoCVIJcHJvY2Vzc0lkEj0KCWVycm9yQ29kZRgCIAEoDjIfLmFueXR5cG'
    'UubW9kZWwuSW1wb3J0LkVycm9yQ29kZVIJZXJyb3JDb2RlEjoKCmltcG9ydFR5cGUYAyABKA4y'
    'Gi5hbnl0eXBlLm1vZGVsLkltcG9ydC5UeXBlUgppbXBvcnRUeXBlEhgKB3NwYWNlSWQYBCABKA'
    'lSB3NwYWNlSWQSEgoEbmFtZRgFIAEoCVIEbmFtZRIcCglzcGFjZU5hbWUYBiABKAlSCXNwYWNl'
    'TmFtZRrBAQoGRXhwb3J0EkUKCWVycm9yQ29kZRgCIAEoDjInLmFueXR5cGUubW9kZWwuTm90aW'
    'ZpY2F0aW9uLkV4cG9ydC5Db2RlUgllcnJvckNvZGUSPAoKZXhwb3J0VHlwZRgDIAEoDjIcLmFu'
    'eXR5cGUubW9kZWwuRXhwb3J0LkZvcm1hdFIKZXhwb3J0VHlwZSIyCgRDb2RlEggKBE5VTEwQAB'
    'IRCg1VTktOT1dOX0VSUk9SEAESDQoJQkFEX0lOUFVUEAIauAEKDUdhbGxlcnlJbXBvcnQSHAoJ'
    'cHJvY2Vzc0lkGAEgASgJUglwcm9jZXNzSWQSPQoJZXJyb3JDb2RlGAIgASgOMh8uYW55dHlwZS'
    '5tb2RlbC5JbXBvcnQuRXJyb3JDb2RlUgllcnJvckNvZGUSGAoHc3BhY2VJZBgDIAEoCVIHc3Bh'
    'Y2VJZBISCgRuYW1lGAQgASgJUgRuYW1lEhwKCXNwYWNlTmFtZRgFIAEoCVIJc3BhY2VOYW1lGq'
    'sBCg1SZXF1ZXN0VG9Kb2luEhgKB3NwYWNlSWQYASABKAlSB3NwYWNlSWQSGgoIaWRlbnRpdHkY'
    'AiABKAlSCGlkZW50aXR5EiIKDGlkZW50aXR5TmFtZRgDIAEoCVIMaWRlbnRpdHlOYW1lEiIKDG'
    'lkZW50aXR5SWNvbhgEIAEoCVIMaWRlbnRpdHlJY29uEhwKCXNwYWNlTmFtZRgFIAEoCVIJc3Bh'
    'Y2VOYW1lGgYKBFRlc3QanQEKGlBhcnRpY2lwYW50UmVxdWVzdEFwcHJvdmVkEhgKB3NwYWNlSW'
    'QYASABKAlSB3NwYWNlSWQSRwoLcGVybWlzc2lvbnMYAiABKA4yJS5hbnl0eXBlLm1vZGVsLlBh'
    'cnRpY2lwYW50UGVybWlzc2lvbnNSC3Blcm1pc3Npb25zEhwKCXNwYWNlTmFtZRgFIAEoCVIJc3'
    'BhY2VOYW1lGqwBCg5SZXF1ZXN0VG9MZWF2ZRIYCgdzcGFjZUlkGAEgASgJUgdzcGFjZUlkEhoK'
    'CGlkZW50aXR5GAIgASgJUghpZGVudGl0eRIiCgxpZGVudGl0eU5hbWUYAyABKAlSDGlkZW50aX'
    'R5TmFtZRIiCgxpZGVudGl0eUljb24YBCABKAlSDGlkZW50aXR5SWNvbhIcCglzcGFjZU5hbWUY'
    'BSABKAlSCXNwYWNlTmFtZRqvAQoRUGFydGljaXBhbnRSZW1vdmUSGgoIaWRlbnRpdHkYASABKA'
    'lSCGlkZW50aXR5EiIKDGlkZW50aXR5TmFtZRgCIAEoCVIMaWRlbnRpdHlOYW1lEiIKDGlkZW50'
    'aXR5SWNvbhgDIAEoCVIMaWRlbnRpdHlJY29uEhgKB3NwYWNlSWQYBCABKAlSB3NwYWNlSWQSHA'
    'oJc3BhY2VOYW1lGAUgASgJUglzcGFjZU5hbWUaUwoZUGFydGljaXBhbnRSZXF1ZXN0RGVjbGlu'
    'ZRIYCgdzcGFjZUlkGAEgASgJUgdzcGFjZUlkEhwKCXNwYWNlTmFtZRgDIAEoCVIJc3BhY2VOYW'
    '1lGp8BChxQYXJ0aWNpcGFudFBlcm1pc3Npb25zQ2hhbmdlEhgKB3NwYWNlSWQYASABKAlSB3Nw'
    'YWNlSWQSRwoLcGVybWlzc2lvbnMYAiABKA4yJS5hbnl0eXBlLm1vZGVsLlBhcnRpY2lwYW50UG'
    'VybWlzc2lvbnNSC3Blcm1pc3Npb25zEhwKCXNwYWNlTmFtZRgDIAEoCVIJc3BhY2VOYW1lIjcK'
    'BlN0YXR1cxILCgdDcmVhdGVkEAASCQoFU2hvd24QARIICgRSZWFkEAISCwoHUmVwbGllZBADIh'
    'cKCkFjdGlvblR5cGUSCQoFQ0xPU0UQAEIJCgdwYXlsb2Fk');

@$core.Deprecated('Use exportDescriptor instead')
const Export$json = {
  '1': 'Export',
  '4': [Export_Format$json],
};

@$core.Deprecated('Use exportDescriptor instead')
const Export_Format$json = {
  '1': 'Format',
  '2': [
    {'1': 'Markdown', '2': 0},
    {'1': 'Protobuf', '2': 1},
    {'1': 'JSON', '2': 2},
    {'1': 'DOT', '2': 3},
    {'1': 'SVG', '2': 4},
    {'1': 'GRAPH_JSON', '2': 5},
  ],
};

/// Descriptor for `Export`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportDescriptor = $convert.base64Decode(
    'CgZFeHBvcnQiUAoGRm9ybWF0EgwKCE1hcmtkb3duEAASDAoIUHJvdG9idWYQARIICgRKU09OEA'
    'ISBwoDRE9UEAMSBwoDU1ZHEAQSDgoKR1JBUEhfSlNPThAF');

@$core.Deprecated('Use importDescriptor instead')
const Import$json = {
  '1': 'Import',
  '4': [Import_Type$json, Import_ErrorCode$json],
};

@$core.Deprecated('Use importDescriptor instead')
const Import_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'Notion', '2': 0},
    {'1': 'Markdown', '2': 1},
    {'1': 'External', '2': 2},
    {'1': 'Pb', '2': 3},
    {'1': 'Html', '2': 4},
    {'1': 'Txt', '2': 5},
    {'1': 'Csv', '2': 6},
    {'1': 'Obsidian', '2': 7},
  ],
};

@$core.Deprecated('Use importDescriptor instead')
const Import_ErrorCode$json = {
  '1': 'ErrorCode',
  '2': [
    {'1': 'NULL', '2': 0},
    {'1': 'UNKNOWN_ERROR', '2': 1},
    {'1': 'BAD_INPUT', '2': 2},
    {'1': 'INTERNAL_ERROR', '2': 3},
    {'1': 'FILE_LOAD_ERROR', '2': 8},
    {'1': 'IMPORT_IS_CANCELED', '2': 6},
    {'1': 'NOTION_NO_OBJECTS_IN_INTEGRATION', '2': 5},
    {'1': 'NOTION_SERVER_IS_UNAVAILABLE', '2': 12},
    {'1': 'NOTION_RATE_LIMIT_EXCEEDED', '2': 13},
    {'1': 'FILE_IMPORT_NO_OBJECTS_IN_ZIP_ARCHIVE', '2': 14},
    {'1': 'FILE_IMPORT_NO_OBJECTS_IN_DIRECTORY', '2': 17},
    {'1': 'HTML_WRONG_HTML_STRUCTURE', '2': 10},
    {'1': 'PB_NOT_ANYBLOCK_FORMAT', '2': 11},
    {'1': 'CSV_LIMIT_OF_ROWS_OR_RELATIONS_EXCEEDED', '2': 7},
    {'1': 'INSUFFICIENT_PERMISSIONS', '2': 9},
  ],
};

/// Descriptor for `Import`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDescriptor = $convert.base64Decode(
    'CgZJbXBvcnQiYAoEVHlwZRIKCgZOb3Rpb24QABIMCghNYXJrZG93bhABEgwKCEV4dGVybmFsEA'
    'ISBgoCUGIQAxIICgRIdG1sEAQSBwoDVHh0EAUSBwoDQ3N2EAYSDAoIT2JzaWRpYW4QByK6AwoJ'
    'RXJyb3JDb2RlEggKBE5VTEwQABIRCg1VTktOT1dOX0VSUk9SEAESDQoJQkFEX0lOUFVUEAISEg'
    'oOSU5URVJOQUxfRVJST1IQAxITCg9GSUxFX0xPQURfRVJST1IQCBIWChJJTVBPUlRfSVNfQ0FO'
    'Q0VMRUQQBhIkCiBOT1RJT05fTk9fT0JKRUNUU19JTl9JTlRFR1JBVElPThAFEiAKHE5PVElPTl'
    '9TRVJWRVJfSVNfVU5BVkFJTEFCTEUQDBIeChpOT1RJT05fUkFURV9MSU1JVF9FWENFRURFRBAN'
    'EikKJUZJTEVfSU1QT1JUX05PX09CSkVDVFNfSU5fWklQX0FSQ0hJVkUQDhInCiNGSUxFX0lNUE'
    '9SVF9OT19PQkpFQ1RTX0lOX0RJUkVDVE9SWRAREh0KGUhUTUxfV1JPTkdfSFRNTF9TVFJVQ1RV'
    'UkUQChIaChZQQl9OT1RfQU5ZQkxPQ0tfRk9STUFUEAsSKwonQ1NWX0xJTUlUX09GX1JPV1NfT1'
    'JfUkVMQVRJT05TX0VYQ0VFREVEEAcSHAoYSU5TVUZGSUNJRU5UX1BFUk1JU1NJT05TEAk=');

@$core.Deprecated('Use inviteDescriptor instead')
const Invite$json = {
  '1': 'Invite',
  '2': [
    {'1': 'payload', '3': 1, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'signature', '3': 2, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `Invite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteDescriptor = $convert.base64Decode(
    'CgZJbnZpdGUSGAoHcGF5bG9hZBgBIAEoDFIHcGF5bG9hZBIcCglzaWduYXR1cmUYAiABKAxSCX'
    'NpZ25hdHVyZQ==');

@$core.Deprecated('Use invitePayloadDescriptor instead')
const InvitePayload$json = {
  '1': 'InvitePayload',
  '2': [
    {'1': 'creatorIdentity', '3': 1, '4': 1, '5': 9, '10': 'creatorIdentity'},
    {'1': 'creatorName', '3': 2, '4': 1, '5': 9, '10': 'creatorName'},
    {'1': 'creatorIconCid', '3': 12, '4': 1, '5': 9, '10': 'creatorIconCid'},
    {
      '1': 'creatorIconEncryptionKeys',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.FileEncryptionKey',
      '10': 'creatorIconEncryptionKeys'
    },
    {'1': 'aclKey', '3': 3, '4': 1, '5': 12, '10': 'aclKey'},
    {'1': 'spaceId', '3': 4, '4': 1, '5': 9, '10': 'spaceId'},
    {'1': 'spaceName', '3': 5, '4': 1, '5': 9, '10': 'spaceName'},
    {'1': 'spaceIconCid', '3': 6, '4': 1, '5': 9, '10': 'spaceIconCid'},
    {'1': 'spaceIconOption', '3': 10, '4': 1, '5': 13, '10': 'spaceIconOption'},
    {'1': 'spaceUxType', '3': 11, '4': 1, '5': 13, '10': 'spaceUxType'},
    {'1': 'spaceType', '3': 14, '4': 1, '5': 13, '10': 'spaceType'},
    {
      '1': 'spaceIconEncryptionKeys',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.FileEncryptionKey',
      '10': 'spaceIconEncryptionKeys'
    },
    {
      '1': 'inviteType',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.InviteType',
      '10': 'inviteType'
    },
    {'1': 'guestKey', '3': 9, '4': 1, '5': 12, '10': 'guestKey'},
  ],
};

/// Descriptor for `InvitePayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitePayloadDescriptor = $convert.base64Decode(
    'Cg1JbnZpdGVQYXlsb2FkEigKD2NyZWF0b3JJZGVudGl0eRgBIAEoCVIPY3JlYXRvcklkZW50aX'
    'R5EiAKC2NyZWF0b3JOYW1lGAIgASgJUgtjcmVhdG9yTmFtZRImCg5jcmVhdG9ySWNvbkNpZBgM'
    'IAEoCVIOY3JlYXRvckljb25DaWQSXgoZY3JlYXRvckljb25FbmNyeXB0aW9uS2V5cxgNIAMoCz'
    'IgLmFueXR5cGUubW9kZWwuRmlsZUVuY3J5cHRpb25LZXlSGWNyZWF0b3JJY29uRW5jcnlwdGlv'
    'bktleXMSFgoGYWNsS2V5GAMgASgMUgZhY2xLZXkSGAoHc3BhY2VJZBgEIAEoCVIHc3BhY2VJZB'
    'IcCglzcGFjZU5hbWUYBSABKAlSCXNwYWNlTmFtZRIiCgxzcGFjZUljb25DaWQYBiABKAlSDHNw'
    'YWNlSWNvbkNpZBIoCg9zcGFjZUljb25PcHRpb24YCiABKA1SD3NwYWNlSWNvbk9wdGlvbhIgCg'
    'tzcGFjZVV4VHlwZRgLIAEoDVILc3BhY2VVeFR5cGUSHAoJc3BhY2VUeXBlGA4gASgNUglzcGFj'
    'ZVR5cGUSWgoXc3BhY2VJY29uRW5jcnlwdGlvbktleXMYByADKAsyIC5hbnl0eXBlLm1vZGVsLk'
    'ZpbGVFbmNyeXB0aW9uS2V5UhdzcGFjZUljb25FbmNyeXB0aW9uS2V5cxI5CgppbnZpdGVUeXBl'
    'GAggASgOMhkuYW55dHlwZS5tb2RlbC5JbnZpdGVUeXBlUgppbnZpdGVUeXBlEhoKCGd1ZXN0S2'
    'V5GAkgASgMUghndWVzdEtleQ==');

@$core.Deprecated('Use identityProfileDescriptor instead')
const IdentityProfile$json = {
  '1': 'IdentityProfile',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 9, '10': 'identity'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'iconCid', '3': 3, '4': 1, '5': 9, '10': 'iconCid'},
    {
      '1': 'iconEncryptionKeys',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.FileEncryptionKey',
      '10': 'iconEncryptionKeys'
    },
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'globalName', '3': 6, '4': 1, '5': 9, '10': 'globalName'},
  ],
};

/// Descriptor for `IdentityProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List identityProfileDescriptor = $convert.base64Decode(
    'Cg9JZGVudGl0eVByb2ZpbGUSGgoIaWRlbnRpdHkYASABKAlSCGlkZW50aXR5EhIKBG5hbWUYAi'
    'ABKAlSBG5hbWUSGAoHaWNvbkNpZBgDIAEoCVIHaWNvbkNpZBJQChJpY29uRW5jcnlwdGlvbktl'
    'eXMYBCADKAsyIC5hbnl0eXBlLm1vZGVsLkZpbGVFbmNyeXB0aW9uS2V5UhJpY29uRW5jcnlwdG'
    'lvbktleXMSIAoLZGVzY3JpcHRpb24YBSABKAlSC2Rlc2NyaXB0aW9uEh4KCmdsb2JhbE5hbWUY'
    'BiABKAlSCmdsb2JhbE5hbWU=');

@$core.Deprecated('Use identityProfileWithKeyDescriptor instead')
const IdentityProfileWithKey$json = {
  '1': 'IdentityProfileWithKey',
  '2': [
    {
      '1': 'identityProfile',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.IdentityProfile',
      '10': 'identityProfile'
    },
    {'1': 'requestMetadata', '3': 2, '4': 1, '5': 12, '10': 'requestMetadata'},
  ],
};

/// Descriptor for `IdentityProfileWithKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List identityProfileWithKeyDescriptor = $convert.base64Decode(
    'ChZJZGVudGl0eVByb2ZpbGVXaXRoS2V5EkgKD2lkZW50aXR5UHJvZmlsZRgBIAEoCzIeLmFueX'
    'R5cGUubW9kZWwuSWRlbnRpdHlQcm9maWxlUg9pZGVudGl0eVByb2ZpbGUSKAoPcmVxdWVzdE1l'
    'dGFkYXRhGAIgASgMUg9yZXF1ZXN0TWV0YWRhdGE=');

@$core.Deprecated('Use fileInfoDescriptor instead')
const FileInfo$json = {
  '1': 'FileInfo',
  '2': [
    {'1': 'fileId', '3': 1, '4': 1, '5': 9, '10': 'fileId'},
    {
      '1': 'encryptionKeys',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.FileEncryptionKey',
      '10': 'encryptionKeys'
    },
  ],
};

/// Descriptor for `FileInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileInfoDescriptor = $convert.base64Decode(
    'CghGaWxlSW5mbxIWCgZmaWxlSWQYASABKAlSBmZpbGVJZBJICg5lbmNyeXB0aW9uS2V5cxgCIA'
    'MoCzIgLmFueXR5cGUubW9kZWwuRmlsZUVuY3J5cHRpb25LZXlSDmVuY3J5cHRpb25LZXlz');

@$core.Deprecated('Use fileEncryptionKeyDescriptor instead')
const FileEncryptionKey$json = {
  '1': 'FileEncryptionKey',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'key', '3': 2, '4': 1, '5': 9, '10': 'key'},
  ],
};

/// Descriptor for `FileEncryptionKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileEncryptionKeyDescriptor = $convert.base64Decode(
    'ChFGaWxlRW5jcnlwdGlvbktleRISCgRwYXRoGAEgASgJUgRwYXRoEhAKA2tleRgCIAEoCVIDa2'
    'V5');

@$core.Deprecated('Use manifestInfoDescriptor instead')
const ManifestInfo$json = {
  '1': 'ManifestInfo',
  '2': [
    {'1': 'schema', '3': 1, '4': 1, '5': 9, '10': '\$schema'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'author', '3': 4, '4': 1, '5': 9, '10': 'author'},
    {'1': 'license', '3': 5, '4': 1, '5': 9, '10': 'license'},
    {'1': 'title', '3': 6, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    {'1': 'screenshots', '3': 8, '4': 3, '5': 9, '10': 'screenshots'},
    {'1': 'downloadLink', '3': 9, '4': 1, '5': 9, '10': 'downloadLink'},
    {'1': 'fileSize', '3': 10, '4': 1, '5': 5, '10': 'fileSize'},
    {'1': 'categories', '3': 11, '4': 3, '5': 9, '10': 'categories'},
    {'1': 'language', '3': 12, '4': 1, '5': 9, '10': 'language'},
  ],
};

/// Descriptor for `ManifestInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List manifestInfoDescriptor = $convert.base64Decode(
    'CgxNYW5pZmVzdEluZm8SFwoGc2NoZW1hGAEgASgJUgckc2NoZW1hEg4KAmlkGAIgASgJUgJpZB'
    'ISCgRuYW1lGAMgASgJUgRuYW1lEhYKBmF1dGhvchgEIAEoCVIGYXV0aG9yEhgKB2xpY2Vuc2UY'
    'BSABKAlSB2xpY2Vuc2USFAoFdGl0bGUYBiABKAlSBXRpdGxlEiAKC2Rlc2NyaXB0aW9uGAcgAS'
    'gJUgtkZXNjcmlwdGlvbhIgCgtzY3JlZW5zaG90cxgIIAMoCVILc2NyZWVuc2hvdHMSIgoMZG93'
    'bmxvYWRMaW5rGAkgASgJUgxkb3dubG9hZExpbmsSGgoIZmlsZVNpemUYCiABKAVSCGZpbGVTaX'
    'plEh4KCmNhdGVnb3JpZXMYCyADKAlSCmNhdGVnb3JpZXMSGgoIbGFuZ3VhZ2UYDCABKAlSCGxh'
    'bmd1YWdl');

@$core.Deprecated('Use membershipDescriptor instead')
const Membership$json = {
  '1': 'Membership',
  '2': [
    {'1': 'tier', '3': 1, '4': 1, '5': 13, '10': 'tier'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Membership.Status',
      '10': 'status'
    },
    {'1': 'dateStarted', '3': 3, '4': 1, '5': 4, '10': 'dateStarted'},
    {'1': 'dateEnds', '3': 4, '4': 1, '5': 4, '10': 'dateEnds'},
    {'1': 'isAutoRenew', '3': 5, '4': 1, '5': 8, '10': 'isAutoRenew'},
    {
      '1': 'paymentMethod',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Membership.PaymentMethod',
      '10': 'paymentMethod'
    },
    {'1': 'nsName', '3': 7, '4': 1, '5': 9, '10': 'nsName'},
    {
      '1': 'nsNameType',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.NameserviceNameType',
      '10': 'nsNameType'
    },
    {'1': 'userEmail', '3': 9, '4': 1, '5': 9, '10': 'userEmail'},
    {
      '1': 'subscribeToNewsletter',
      '3': 10,
      '4': 1,
      '5': 8,
      '10': 'subscribeToNewsletter'
    },
  ],
  '4': [
    Membership_Status$json,
    Membership_PaymentMethod$json,
    Membership_EmailVerificationStatus$json
  ],
};

@$core.Deprecated('Use membershipDescriptor instead')
const Membership_Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'StatusUnknown', '2': 0},
    {'1': 'StatusPending', '2': 1},
    {'1': 'StatusActive', '2': 2},
    {'1': 'StatusPendingRequiresFinalization', '2': 3},
  ],
};

@$core.Deprecated('Use membershipDescriptor instead')
const Membership_PaymentMethod$json = {
  '1': 'PaymentMethod',
  '2': [
    {'1': 'MethodNone', '2': 0},
    {'1': 'MethodStripe', '2': 1},
    {'1': 'MethodCrypto', '2': 2},
    {'1': 'MethodInappApple', '2': 3},
    {'1': 'MethodInappGoogle', '2': 4},
  ],
};

@$core.Deprecated('Use membershipDescriptor instead')
const Membership_EmailVerificationStatus$json = {
  '1': 'EmailVerificationStatus',
  '2': [
    {'1': 'StatusNotVerified', '2': 0},
    {'1': 'StatusCodeSent', '2': 1},
    {'1': 'StatusVerified', '2': 2},
  ],
};

/// Descriptor for `Membership`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipDescriptor = $convert.base64Decode(
    'CgpNZW1iZXJzaGlwEhIKBHRpZXIYASABKA1SBHRpZXISOAoGc3RhdHVzGAIgASgOMiAuYW55dH'
    'lwZS5tb2RlbC5NZW1iZXJzaGlwLlN0YXR1c1IGc3RhdHVzEiAKC2RhdGVTdGFydGVkGAMgASgE'
    'UgtkYXRlU3RhcnRlZBIaCghkYXRlRW5kcxgEIAEoBFIIZGF0ZUVuZHMSIAoLaXNBdXRvUmVuZX'
    'cYBSABKAhSC2lzQXV0b1JlbmV3Ek0KDXBheW1lbnRNZXRob2QYBiABKA4yJy5hbnl0eXBlLm1v'
    'ZGVsLk1lbWJlcnNoaXAuUGF5bWVudE1ldGhvZFINcGF5bWVudE1ldGhvZBIWCgZuc05hbWUYBy'
    'ABKAlSBm5zTmFtZRJCCgpuc05hbWVUeXBlGAggASgOMiIuYW55dHlwZS5tb2RlbC5OYW1lc2Vy'
    'dmljZU5hbWVUeXBlUgpuc05hbWVUeXBlEhwKCXVzZXJFbWFpbBgJIAEoCVIJdXNlckVtYWlsEj'
    'QKFXN1YnNjcmliZVRvTmV3c2xldHRlchgKIAEoCFIVc3Vic2NyaWJlVG9OZXdzbGV0dGVyImcK'
    'BlN0YXR1cxIRCg1TdGF0dXNVbmtub3duEAASEQoNU3RhdHVzUGVuZGluZxABEhAKDFN0YXR1c0'
    'FjdGl2ZRACEiUKIVN0YXR1c1BlbmRpbmdSZXF1aXJlc0ZpbmFsaXphdGlvbhADInAKDVBheW1l'
    'bnRNZXRob2QSDgoKTWV0aG9kTm9uZRAAEhAKDE1ldGhvZFN0cmlwZRABEhAKDE1ldGhvZENyeX'
    'B0bxACEhQKEE1ldGhvZEluYXBwQXBwbGUQAxIVChFNZXRob2RJbmFwcEdvb2dsZRAEIlgKF0Vt'
    'YWlsVmVyaWZpY2F0aW9uU3RhdHVzEhUKEVN0YXR1c05vdFZlcmlmaWVkEAASEgoOU3RhdHVzQ2'
    '9kZVNlbnQQARISCg5TdGF0dXNWZXJpZmllZBAC');

@$core.Deprecated('Use membershipTierDataDescriptor instead')
const MembershipTierData$json = {
  '1': 'MembershipTierData',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'isTest', '3': 4, '4': 1, '5': 8, '10': 'isTest'},
    {
      '1': 'periodType',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.MembershipTierData.PeriodType',
      '10': 'periodType'
    },
    {'1': 'periodValue', '3': 6, '4': 1, '5': 13, '10': 'periodValue'},
    {
      '1': 'priceStripeUsdCents',
      '3': 7,
      '4': 1,
      '5': 13,
      '10': 'priceStripeUsdCents'
    },
    {
      '1': 'anyNamesCountIncluded',
      '3': 8,
      '4': 1,
      '5': 13,
      '10': 'anyNamesCountIncluded'
    },
    {
      '1': 'anyNameMinLength',
      '3': 9,
      '4': 1,
      '5': 13,
      '10': 'anyNameMinLength'
    },
    {'1': 'features', '3': 10, '4': 3, '5': 9, '10': 'features'},
    {'1': 'colorStr', '3': 11, '4': 1, '5': 9, '10': 'colorStr'},
    {'1': 'stripeProductId', '3': 12, '4': 1, '5': 9, '10': 'stripeProductId'},
    {'1': 'stripeManageUrl', '3': 13, '4': 1, '5': 9, '10': 'stripeManageUrl'},
    {'1': 'iosProductId', '3': 15, '4': 1, '5': 9, '10': 'iosProductId'},
    {'1': 'iosManageUrl', '3': 16, '4': 1, '5': 9, '10': 'iosManageUrl'},
    {
      '1': 'androidProductId',
      '3': 17,
      '4': 1,
      '5': 9,
      '10': 'androidProductId'
    },
    {
      '1': 'androidManageUrl',
      '3': 18,
      '4': 1,
      '5': 9,
      '10': 'androidManageUrl'
    },
    {'1': 'offer', '3': 19, '4': 1, '5': 9, '10': 'offer'},
  ],
  '4': [MembershipTierData_PeriodType$json],
};

@$core.Deprecated('Use membershipTierDataDescriptor instead')
const MembershipTierData_PeriodType$json = {
  '1': 'PeriodType',
  '2': [
    {'1': 'PeriodTypeUnknown', '2': 0},
    {'1': 'PeriodTypeUnlimited', '2': 1},
    {'1': 'PeriodTypeDays', '2': 2},
    {'1': 'PeriodTypeWeeks', '2': 3},
    {'1': 'PeriodTypeMonths', '2': 4},
    {'1': 'PeriodTypeYears', '2': 5},
  ],
};

/// Descriptor for `MembershipTierData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipTierDataDescriptor = $convert.base64Decode(
    'ChJNZW1iZXJzaGlwVGllckRhdGESDgoCaWQYASABKA1SAmlkEhIKBG5hbWUYAiABKAlSBG5hbW'
    'USIAoLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEhYKBmlzVGVzdBgEIAEoCFIGaXNU'
    'ZXN0EkwKCnBlcmlvZFR5cGUYBSABKA4yLC5hbnl0eXBlLm1vZGVsLk1lbWJlcnNoaXBUaWVyRG'
    'F0YS5QZXJpb2RUeXBlUgpwZXJpb2RUeXBlEiAKC3BlcmlvZFZhbHVlGAYgASgNUgtwZXJpb2RW'
    'YWx1ZRIwChNwcmljZVN0cmlwZVVzZENlbnRzGAcgASgNUhNwcmljZVN0cmlwZVVzZENlbnRzEj'
    'QKFWFueU5hbWVzQ291bnRJbmNsdWRlZBgIIAEoDVIVYW55TmFtZXNDb3VudEluY2x1ZGVkEioK'
    'EGFueU5hbWVNaW5MZW5ndGgYCSABKA1SEGFueU5hbWVNaW5MZW5ndGgSGgoIZmVhdHVyZXMYCi'
    'ADKAlSCGZlYXR1cmVzEhoKCGNvbG9yU3RyGAsgASgJUghjb2xvclN0chIoCg9zdHJpcGVQcm9k'
    'dWN0SWQYDCABKAlSD3N0cmlwZVByb2R1Y3RJZBIoCg9zdHJpcGVNYW5hZ2VVcmwYDSABKAlSD3'
    'N0cmlwZU1hbmFnZVVybBIiCgxpb3NQcm9kdWN0SWQYDyABKAlSDGlvc1Byb2R1Y3RJZBIiCgxp'
    'b3NNYW5hZ2VVcmwYECABKAlSDGlvc01hbmFnZVVybBIqChBhbmRyb2lkUHJvZHVjdElkGBEgAS'
    'gJUhBhbmRyb2lkUHJvZHVjdElkEioKEGFuZHJvaWRNYW5hZ2VVcmwYEiABKAlSEGFuZHJvaWRN'
    'YW5hZ2VVcmwSFAoFb2ZmZXIYEyABKAlSBW9mZmVyIpABCgpQZXJpb2RUeXBlEhUKEVBlcmlvZF'
    'R5cGVVbmtub3duEAASFwoTUGVyaW9kVHlwZVVubGltaXRlZBABEhIKDlBlcmlvZFR5cGVEYXlz'
    'EAISEwoPUGVyaW9kVHlwZVdlZWtzEAMSFAoQUGVyaW9kVHlwZU1vbnRocxAEEhMKD1BlcmlvZF'
    'R5cGVZZWFycxAF');

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2$json = {
  '1': 'MembershipV2',
  '3': [
    MembershipV2_Amount$json,
    MembershipV2_Invoice$json,
    MembershipV2_Features$json,
    MembershipV2_Product$json,
    MembershipV2_PurchaseInfo$json,
    MembershipV2_ProductStatus$json,
    MembershipV2_PurchasedProduct$json,
    MembershipV2_CartProduct$json,
    MembershipV2_Cart$json,
    MembershipV2_Data$json
  ],
  '4': [
    MembershipV2_Platform$json,
    MembershipV2_PaymentProvider$json,
    MembershipV2_Period$json
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_Amount$json = {
  '1': 'Amount',
  '2': [
    {'1': 'currency', '3': 1, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'amountCents', '3': 2, '4': 1, '5': 3, '10': 'amountCents'},
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_Invoice$json = {
  '1': 'Invoice',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 4, '10': 'date'},
    {
      '1': 'total',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.MembershipV2.Amount',
      '10': 'total'
    },
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_Features$json = {
  '1': 'Features',
  '2': [
    {'1': 'storageBytes', '3': 1, '4': 1, '5': 4, '10': 'storageBytes'},
    {'1': 'spaceReaders', '3': 2, '4': 1, '5': 13, '10': 'spaceReaders'},
    {'1': 'spaceWriters', '3': 3, '4': 1, '5': 13, '10': 'spaceWriters'},
    {'1': 'sharedSpaces', '3': 4, '4': 1, '5': 13, '10': 'sharedSpaces'},
    {'1': 'teamSeats', '3': 5, '4': 1, '5': 13, '10': 'teamSeats'},
    {'1': 'anyNameCount', '3': 6, '4': 1, '5': 13, '10': 'anyNameCount'},
    {'1': 'anyNameMinLen', '3': 7, '4': 1, '5': 13, '10': 'anyNameMinLen'},
    {'1': 'privateSpaces', '3': 8, '4': 1, '5': 13, '10': 'privateSpaces'},
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_Product$json = {
  '1': 'Product',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'isTopLevel', '3': 4, '4': 1, '5': 8, '10': 'isTopLevel'},
    {'1': 'isHidden', '3': 5, '4': 1, '5': 8, '10': 'isHidden'},
    {'1': 'isIntro', '3': 6, '4': 1, '5': 8, '10': 'isIntro'},
    {'1': 'isUpgradeable', '3': 7, '4': 1, '5': 8, '10': 'isUpgradeable'},
    {
      '1': 'pricesYearly',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.MembershipV2.Amount',
      '10': 'pricesYearly'
    },
    {
      '1': 'pricesMonthly',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.MembershipV2.Amount',
      '10': 'pricesMonthly'
    },
    {'1': 'colorStr', '3': 10, '4': 1, '5': 9, '10': 'colorStr'},
    {'1': 'offer', '3': 11, '4': 1, '5': 9, '10': 'offer'},
    {
      '1': 'features',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.MembershipV2.Features',
      '10': 'features'
    },
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_PurchaseInfo$json = {
  '1': 'PurchaseInfo',
  '2': [
    {'1': 'dateStarted', '3': 1, '4': 1, '5': 4, '10': 'dateStarted'},
    {'1': 'dateEnds', '3': 2, '4': 1, '5': 4, '10': 'dateEnds'},
    {'1': 'isAutoRenew', '3': 3, '4': 1, '5': 8, '10': 'isAutoRenew'},
    {
      '1': 'period',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.MembershipV2.Period',
      '10': 'period'
    },
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_ProductStatus$json = {
  '1': 'ProductStatus',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.MembershipV2.ProductStatus.Status',
      '10': 'status'
    },
  ],
  '4': [MembershipV2_ProductStatus_Status$json],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_ProductStatus_Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'StatusUnknown', '2': 0},
    {'1': 'StatusPending', '2': 1},
    {'1': 'StatusActive', '2': 2},
    {'1': 'StatusPendingRequiresAnyNameAllocation', '2': 3},
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_PurchasedProduct$json = {
  '1': 'PurchasedProduct',
  '2': [
    {
      '1': 'product',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.MembershipV2.Product',
      '10': 'product'
    },
    {
      '1': 'purchaseInfo',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.MembershipV2.PurchaseInfo',
      '10': 'purchaseInfo'
    },
    {
      '1': 'productStatus',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.MembershipV2.ProductStatus',
      '10': 'productStatus'
    },
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_CartProduct$json = {
  '1': 'CartProduct',
  '2': [
    {
      '1': 'product',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.MembershipV2.Product',
      '10': 'product'
    },
    {'1': 'isYearly', '3': 2, '4': 1, '5': 8, '10': 'isYearly'},
    {'1': 'remove', '3': 3, '4': 1, '5': 8, '10': 'remove'},
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_Cart$json = {
  '1': 'Cart',
  '2': [
    {
      '1': 'products',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.MembershipV2.CartProduct',
      '10': 'products'
    },
    {
      '1': 'total',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.MembershipV2.Amount',
      '10': 'total'
    },
    {
      '1': 'totalNextInvoice',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.MembershipV2.Amount',
      '10': 'totalNextInvoice'
    },
    {'1': 'nextInvoiceDate', '3': 4, '4': 1, '5': 4, '10': 'nextInvoiceDate'},
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_Data$json = {
  '1': 'Data',
  '2': [
    {
      '1': 'products',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.MembershipV2.PurchasedProduct',
      '10': 'products'
    },
    {
      '1': 'nextInvoice',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.MembershipV2.Invoice',
      '10': 'nextInvoice'
    },
    {'1': 'teamOwnerID', '3': 3, '4': 1, '5': 9, '10': 'teamOwnerID'},
    {
      '1': 'paymentProvider',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.MembershipV2.PaymentProvider',
      '10': 'paymentProvider'
    },
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_Platform$json = {
  '1': 'Platform',
  '2': [
    {'1': 'Unknown', '2': 0},
    {'1': 'Desktop', '2': 1},
    {'1': 'MobileIOS', '2': 2},
    {'1': 'MobileAndroid', '2': 3},
    {'1': 'Web', '2': 4},
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_PaymentProvider$json = {
  '1': 'PaymentProvider',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'Stripe', '2': 1},
    {'1': 'Crypto', '2': 2},
    {'1': 'BillingPortal', '2': 3},
    {'1': 'AppStore', '2': 4},
    {'1': 'GooglePlay', '2': 5},
  ],
};

@$core.Deprecated('Use membershipV2Descriptor instead')
const MembershipV2_Period$json = {
  '1': 'Period',
  '2': [
    {'1': 'Unlimited', '2': 0},
    {'1': 'Monthly', '2': 1},
    {'1': 'Yearly', '2': 2},
    {'1': 'ThreeYears', '2': 3},
  ],
};

/// Descriptor for `MembershipV2`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipV2Descriptor = $convert.base64Decode(
    'CgxNZW1iZXJzaGlwVjIaRgoGQW1vdW50EhoKCGN1cnJlbmN5GAEgASgJUghjdXJyZW5jeRIgCg'
    'thbW91bnRDZW50cxgCIAEoA1ILYW1vdW50Q2VudHMaVwoHSW52b2ljZRISCgRkYXRlGAEgASgE'
    'UgRkYXRlEjgKBXRvdGFsGAIgASgLMiIuYW55dHlwZS5tb2RlbC5NZW1iZXJzaGlwVjIuQW1vdW'
    '50UgV0b3RhbBqoAgoIRmVhdHVyZXMSIgoMc3RvcmFnZUJ5dGVzGAEgASgEUgxzdG9yYWdlQnl0'
    'ZXMSIgoMc3BhY2VSZWFkZXJzGAIgASgNUgxzcGFjZVJlYWRlcnMSIgoMc3BhY2VXcml0ZXJzGA'
    'MgASgNUgxzcGFjZVdyaXRlcnMSIgoMc2hhcmVkU3BhY2VzGAQgASgNUgxzaGFyZWRTcGFjZXMS'
    'HAoJdGVhbVNlYXRzGAUgASgNUgl0ZWFtU2VhdHMSIgoMYW55TmFtZUNvdW50GAYgASgNUgxhbn'
    'lOYW1lQ291bnQSJAoNYW55TmFtZU1pbkxlbhgHIAEoDVINYW55TmFtZU1pbkxlbhIkCg1wcml2'
    'YXRlU3BhY2VzGAggASgNUg1wcml2YXRlU3BhY2VzGtEDCgdQcm9kdWN0Eg4KAmlkGAEgASgJUg'
    'JpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlv'
    'bhIeCgppc1RvcExldmVsGAQgASgIUgppc1RvcExldmVsEhoKCGlzSGlkZGVuGAUgASgIUghpc0'
    'hpZGRlbhIYCgdpc0ludHJvGAYgASgIUgdpc0ludHJvEiQKDWlzVXBncmFkZWFibGUYByABKAhS'
    'DWlzVXBncmFkZWFibGUSRgoMcHJpY2VzWWVhcmx5GAggAygLMiIuYW55dHlwZS5tb2RlbC5NZW'
    '1iZXJzaGlwVjIuQW1vdW50UgxwcmljZXNZZWFybHkSSAoNcHJpY2VzTW9udGhseRgJIAMoCzIi'
    'LmFueXR5cGUubW9kZWwuTWVtYmVyc2hpcFYyLkFtb3VudFINcHJpY2VzTW9udGhseRIaCghjb2'
    'xvclN0chgKIAEoCVIIY29sb3JTdHISFAoFb2ZmZXIYCyABKAlSBW9mZmVyEkAKCGZlYXR1cmVz'
    'GAwgASgLMiQuYW55dHlwZS5tb2RlbC5NZW1iZXJzaGlwVjIuRmVhdHVyZXNSCGZlYXR1cmVzGq'
    'oBCgxQdXJjaGFzZUluZm8SIAoLZGF0ZVN0YXJ0ZWQYASABKARSC2RhdGVTdGFydGVkEhoKCGRh'
    'dGVFbmRzGAIgASgEUghkYXRlRW5kcxIgCgtpc0F1dG9SZW5ldxgDIAEoCFILaXNBdXRvUmVuZX'
    'cSOgoGcGVyaW9kGAQgASgOMiIuYW55dHlwZS5tb2RlbC5NZW1iZXJzaGlwVjIuUGVyaW9kUgZw'
    'ZXJpb2QaxwEKDVByb2R1Y3RTdGF0dXMSSAoGc3RhdHVzGAEgASgOMjAuYW55dHlwZS5tb2RlbC'
    '5NZW1iZXJzaGlwVjIuUHJvZHVjdFN0YXR1cy5TdGF0dXNSBnN0YXR1cyJsCgZTdGF0dXMSEQoN'
    'U3RhdHVzVW5rbm93bhAAEhEKDVN0YXR1c1BlbmRpbmcQARIQCgxTdGF0dXNBY3RpdmUQAhIqCi'
    'ZTdGF0dXNQZW5kaW5nUmVxdWlyZXNBbnlOYW1lQWxsb2NhdGlvbhADGvABChBQdXJjaGFzZWRQ'
    'cm9kdWN0Ej0KB3Byb2R1Y3QYASABKAsyIy5hbnl0eXBlLm1vZGVsLk1lbWJlcnNoaXBWMi5Qcm'
    '9kdWN0Ugdwcm9kdWN0EkwKDHB1cmNoYXNlSW5mbxgCIAEoCzIoLmFueXR5cGUubW9kZWwuTWVt'
    'YmVyc2hpcFYyLlB1cmNoYXNlSW5mb1IMcHVyY2hhc2VJbmZvEk8KDXByb2R1Y3RTdGF0dXMYAy'
    'ABKAsyKS5hbnl0eXBlLm1vZGVsLk1lbWJlcnNoaXBWMi5Qcm9kdWN0U3RhdHVzUg1wcm9kdWN0'
    'U3RhdHVzGoABCgtDYXJ0UHJvZHVjdBI9Cgdwcm9kdWN0GAEgASgLMiMuYW55dHlwZS5tb2RlbC'
    '5NZW1iZXJzaGlwVjIuUHJvZHVjdFIHcHJvZHVjdBIaCghpc1llYXJseRgCIAEoCFIIaXNZZWFy'
    'bHkSFgoGcmVtb3ZlGAMgASgIUgZyZW1vdmUa/wEKBENhcnQSQwoIcHJvZHVjdHMYASADKAsyJy'
    '5hbnl0eXBlLm1vZGVsLk1lbWJlcnNoaXBWMi5DYXJ0UHJvZHVjdFIIcHJvZHVjdHMSOAoFdG90'
    'YWwYAiABKAsyIi5hbnl0eXBlLm1vZGVsLk1lbWJlcnNoaXBWMi5BbW91bnRSBXRvdGFsEk4KEH'
    'RvdGFsTmV4dEludm9pY2UYAyABKAsyIi5hbnl0eXBlLm1vZGVsLk1lbWJlcnNoaXBWMi5BbW91'
    'bnRSEHRvdGFsTmV4dEludm9pY2USKAoPbmV4dEludm9pY2VEYXRlGAQgASgEUg9uZXh0SW52b2'
    'ljZURhdGUakAIKBERhdGESSAoIcHJvZHVjdHMYASADKAsyLC5hbnl0eXBlLm1vZGVsLk1lbWJl'
    'cnNoaXBWMi5QdXJjaGFzZWRQcm9kdWN0Ughwcm9kdWN0cxJFCgtuZXh0SW52b2ljZRgCIAEoCz'
    'IjLmFueXR5cGUubW9kZWwuTWVtYmVyc2hpcFYyLkludm9pY2VSC25leHRJbnZvaWNlEiAKC3Rl'
    'YW1Pd25lcklEGAMgASgJUgt0ZWFtT3duZXJJRBJVCg9wYXltZW50UHJvdmlkZXIYBCABKA4yKy'
    '5hbnl0eXBlLm1vZGVsLk1lbWJlcnNoaXBWMi5QYXltZW50UHJvdmlkZXJSD3BheW1lbnRQcm92'
    'aWRlciJPCghQbGF0Zm9ybRILCgdVbmtub3duEAASCwoHRGVza3RvcBABEg0KCU1vYmlsZUlPUx'
    'ACEhEKDU1vYmlsZUFuZHJvaWQQAxIHCgNXZWIQBCJkCg9QYXltZW50UHJvdmlkZXISCAoETm9u'
    'ZRAAEgoKBlN0cmlwZRABEgoKBkNyeXB0bxACEhEKDUJpbGxpbmdQb3J0YWwQAxIMCghBcHBTdG'
    '9yZRAEEg4KCkdvb2dsZVBsYXkQBSJACgZQZXJpb2QSDQoJVW5saW1pdGVkEAASCwoHTW9udGhs'
    'eRABEgoKBlllYXJseRACEg4KClRocmVlWWVhcnMQAw==');

@$core.Deprecated('Use detailDescriptor instead')
const Detail$json = {
  '1': 'Detail',
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

/// Descriptor for `Detail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detailDescriptor = $convert.base64Decode(
    'CgZEZXRhaWwSEAoDa2V5GAEgASgJUgNrZXkSLAoFdmFsdWUYAiABKAsyFi5nb29nbGUucHJvdG'
    '9idWYuVmFsdWVSBXZhbHVl');

@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = {
  '1': 'DeviceInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'addDate', '3': 3, '4': 1, '5': 3, '10': 'addDate'},
    {'1': 'archived', '3': 4, '4': 1, '5': 8, '10': 'archived'},
    {'1': 'isConnected', '3': 5, '4': 1, '5': 8, '10': 'isConnected'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VJbmZvEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhgKB2FkZE'
    'RhdGUYAyABKANSB2FkZERhdGUSGgoIYXJjaGl2ZWQYBCABKAhSCGFyY2hpdmVkEiAKC2lzQ29u'
    'bmVjdGVkGAUgASgIUgtpc0Nvbm5lY3RlZA==');

@$core.Deprecated('Use chatStateDescriptor instead')
const ChatState$json = {
  '1': 'ChatState',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ChatState.UnreadState',
      '10': 'messages'
    },
    {
      '1': 'mentions',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ChatState.UnreadState',
      '10': 'mentions'
    },
    {'1': 'lastStateId', '3': 3, '4': 1, '5': 9, '10': 'lastStateId'},
    {'1': 'order', '3': 4, '4': 1, '5': 3, '10': 'order'},
    {
      '1': 'unreadReactionOrderId',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'unreadReactionOrderId'
    },
  ],
  '3': [ChatState_UnreadState$json],
};

@$core.Deprecated('Use chatStateDescriptor instead')
const ChatState_UnreadState$json = {
  '1': 'UnreadState',
  '2': [
    {'1': 'oldestOrderId', '3': 1, '4': 1, '5': 9, '10': 'oldestOrderId'},
    {'1': 'counter', '3': 2, '4': 1, '5': 5, '10': 'counter'},
  ],
};

/// Descriptor for `ChatState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStateDescriptor = $convert.base64Decode(
    'CglDaGF0U3RhdGUSQAoIbWVzc2FnZXMYASABKAsyJC5hbnl0eXBlLm1vZGVsLkNoYXRTdGF0ZS'
    '5VbnJlYWRTdGF0ZVIIbWVzc2FnZXMSQAoIbWVudGlvbnMYAiABKAsyJC5hbnl0eXBlLm1vZGVs'
    'LkNoYXRTdGF0ZS5VbnJlYWRTdGF0ZVIIbWVudGlvbnMSIAoLbGFzdFN0YXRlSWQYAyABKAlSC2'
    'xhc3RTdGF0ZUlkEhQKBW9yZGVyGAQgASgDUgVvcmRlchI0ChV1bnJlYWRSZWFjdGlvbk9yZGVy'
    'SWQYBSABKAlSFXVucmVhZFJlYWN0aW9uT3JkZXJJZBpNCgtVbnJlYWRTdGF0ZRIkCg1vbGRlc3'
    'RPcmRlcklkGAEgASgJUg1vbGRlc3RPcmRlcklkEhgKB2NvdW50ZXIYAiABKAVSB2NvdW50ZXI=');

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage$json = {
  '1': 'ChatMessage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'orderId', '3': 2, '4': 1, '5': 9, '10': 'orderId'},
    {'1': 'creator', '3': 3, '4': 1, '5': 9, '10': 'creator'},
    {'1': 'createdAt', '3': 4, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'modifiedAt', '3': 9, '4': 1, '5': 3, '10': 'modifiedAt'},
    {'1': 'stateId', '3': 11, '4': 1, '5': 9, '10': 'stateId'},
    {'1': 'replyToMessageId', '3': 5, '4': 1, '5': 9, '10': 'replyToMessageId'},
    {
      '1': 'message',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ChatMessage.MessageContent',
      '10': 'message'
    },
    {
      '1': 'attachments',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.ChatMessage.Attachment',
      '10': 'attachments'
    },
    {
      '1': 'reactions',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ChatMessage.Reactions',
      '10': 'reactions'
    },
    {'1': 'read', '3': 10, '4': 1, '5': 8, '10': 'read'},
    {'1': 'mentionRead', '3': 12, '4': 1, '5': 8, '10': 'mentionRead'},
    {'1': 'hasMention', '3': 14, '4': 1, '5': 8, '10': 'hasMention'},
    {'1': 'synced', '3': 13, '4': 1, '5': 8, '10': 'synced'},
    {'1': 'pinned', '3': 15, '4': 1, '5': 8, '10': 'pinned'},
    {'1': 'unreadReaction', '3': 16, '4': 1, '5': 8, '10': 'unreadReaction'},
    {
      '1': 'blocks',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.ChatMessage.MessageBlock',
      '10': 'blocks'
    },
  ],
  '3': [
    ChatMessage_MessageContent$json,
    ChatMessage_Attachment$json,
    ChatMessage_Reactions$json,
    ChatMessage_MessageBlock$json,
    ChatMessage_MessageBlockText$json,
    ChatMessage_MessageBlockLink$json,
    ChatMessage_MessageBlockEmbed$json
  ],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_MessageContent$json = {
  '1': 'MessageContent',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'style',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Text.Style',
      '10': 'style'
    },
    {
      '1': 'marks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Text.Mark',
      '10': 'marks'
    },
  ],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_Attachment$json = {
  '1': 'Attachment',
  '2': [
    {'1': 'target', '3': 1, '4': 1, '5': 9, '10': 'target'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.ChatMessage.Attachment.AttachmentType',
      '10': 'type'
    },
  ],
  '4': [ChatMessage_Attachment_AttachmentType$json],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_Attachment_AttachmentType$json = {
  '1': 'AttachmentType',
  '2': [
    {'1': 'FILE', '2': 0},
    {'1': 'IMAGE', '2': 1},
    {'1': 'LINK', '2': 2},
  ],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_Reactions$json = {
  '1': 'Reactions',
  '2': [
    {
      '1': 'reactions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.ChatMessage.Reactions.ReactionsEntry',
      '10': 'reactions'
    },
  ],
  '3': [
    ChatMessage_Reactions_ReactionsEntry$json,
    ChatMessage_Reactions_IdentityList$json
  ],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_Reactions_ReactionsEntry$json = {
  '1': 'ReactionsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ChatMessage.Reactions.IdentityList',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_Reactions_IdentityList$json = {
  '1': 'IdentityList',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 9, '10': 'ids'},
  ],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_MessageBlock$json = {
  '1': 'MessageBlock',
  '2': [
    {
      '1': 'text',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ChatMessage.MessageBlockText',
      '9': 0,
      '10': 'text'
    },
    {
      '1': 'link',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ChatMessage.MessageBlockLink',
      '9': 0,
      '10': 'link'
    },
    {
      '1': 'embed',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.ChatMessage.MessageBlockEmbed',
      '9': 0,
      '10': 'embed'
    },
  ],
  '8': [
    {'1': 'content'},
  ],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_MessageBlockText$json = {
  '1': 'MessageBlockText',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'style',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Text.Style',
      '10': 'style'
    },
    {
      '1': 'marks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anytype.model.Block.Content.Text.Mark',
      '10': 'marks'
    },
    {'1': 'checked', '3': 4, '4': 1, '5': 8, '10': 'checked'},
    {'1': 'lang', '3': 5, '4': 1, '5': 9, '10': 'lang'},
  ],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_MessageBlockLink$json = {
  '1': 'MessageBlockLink',
  '2': [
    {'1': 'targetObjectId', '3': 1, '4': 1, '5': 9, '10': 'targetObjectId'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.ChatMessage.MessageBlockLink.LinkType',
      '10': 'type'
    },
  ],
  '4': [ChatMessage_MessageBlockLink_LinkType$json],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_MessageBlockLink_LinkType$json = {
  '1': 'LinkType',
  '2': [
    {'1': 'Object', '2': 0},
    {'1': 'File', '2': 1},
    {'1': 'Image', '2': 2},
    {'1': 'Bookmark', '2': 3},
  ],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_MessageBlockEmbed$json = {
  '1': 'MessageBlockEmbed',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'processor',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Latex.Processor',
      '10': 'processor'
    },
  ],
};

/// Descriptor for `ChatMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessageDescriptor = $convert.base64Decode(
    'CgtDaGF0TWVzc2FnZRIOCgJpZBgBIAEoCVICaWQSGAoHb3JkZXJJZBgCIAEoCVIHb3JkZXJJZB'
    'IYCgdjcmVhdG9yGAMgASgJUgdjcmVhdG9yEhwKCWNyZWF0ZWRBdBgEIAEoA1IJY3JlYXRlZEF0'
    'Eh4KCm1vZGlmaWVkQXQYCSABKANSCm1vZGlmaWVkQXQSGAoHc3RhdGVJZBgLIAEoCVIHc3RhdG'
    'VJZBIqChByZXBseVRvTWVzc2FnZUlkGAUgASgJUhByZXBseVRvTWVzc2FnZUlkEkMKB21lc3Nh'
    'Z2UYBiABKAsyKS5hbnl0eXBlLm1vZGVsLkNoYXRNZXNzYWdlLk1lc3NhZ2VDb250ZW50UgdtZX'
    'NzYWdlEkcKC2F0dGFjaG1lbnRzGAcgAygLMiUuYW55dHlwZS5tb2RlbC5DaGF0TWVzc2FnZS5B'
    'dHRhY2htZW50UgthdHRhY2htZW50cxJCCglyZWFjdGlvbnMYCCABKAsyJC5hbnl0eXBlLm1vZG'
    'VsLkNoYXRNZXNzYWdlLlJlYWN0aW9uc1IJcmVhY3Rpb25zEhIKBHJlYWQYCiABKAhSBHJlYWQS'
    'IAoLbWVudGlvblJlYWQYDCABKAhSC21lbnRpb25SZWFkEh4KCmhhc01lbnRpb24YDiABKAhSCm'
    'hhc01lbnRpb24SFgoGc3luY2VkGA0gASgIUgZzeW5jZWQSFgoGcGlubmVkGA8gASgIUgZwaW5u'
    'ZWQSJgoOdW5yZWFkUmVhY3Rpb24YECABKAhSDnVucmVhZFJlYWN0aW9uEj8KBmJsb2NrcxgRIA'
    'MoCzInLmFueXR5cGUubW9kZWwuQ2hhdE1lc3NhZ2UuTWVzc2FnZUJsb2NrUgZibG9ja3MaoQEK'
    'Dk1lc3NhZ2VDb250ZW50EhIKBHRleHQYASABKAlSBHRleHQSPQoFc3R5bGUYAiABKA4yJy5hbn'
    'l0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuVGV4dC5TdHlsZVIFc3R5bGUSPAoFbWFya3MYAyAD'
    'KAsyJi5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuVGV4dC5NYXJrUgVtYXJrcxqfAQoKQX'
    'R0YWNobWVudBIWCgZ0YXJnZXQYASABKAlSBnRhcmdldBJICgR0eXBlGAIgASgOMjQuYW55dHlw'
    'ZS5tb2RlbC5DaGF0TWVzc2FnZS5BdHRhY2htZW50LkF0dGFjaG1lbnRUeXBlUgR0eXBlIi8KDk'
    'F0dGFjaG1lbnRUeXBlEggKBEZJTEUQABIJCgVJTUFHRRABEggKBExJTksQAhrxAQoJUmVhY3Rp'
    'b25zElEKCXJlYWN0aW9ucxgBIAMoCzIzLmFueXR5cGUubW9kZWwuQ2hhdE1lc3NhZ2UuUmVhY3'
    'Rpb25zLlJlYWN0aW9uc0VudHJ5UglyZWFjdGlvbnMabwoOUmVhY3Rpb25zRW50cnkSEAoDa2V5'
    'GAEgASgJUgNrZXkSRwoFdmFsdWUYAiABKAsyMS5hbnl0eXBlLm1vZGVsLkNoYXRNZXNzYWdlLl'
    'JlYWN0aW9ucy5JZGVudGl0eUxpc3RSBXZhbHVlOgI4ARogCgxJZGVudGl0eUxpc3QSEAoDaWRz'
    'GAEgAygJUgNpZHMa5QEKDE1lc3NhZ2VCbG9jaxJBCgR0ZXh0GAEgASgLMisuYW55dHlwZS5tb2'
    'RlbC5DaGF0TWVzc2FnZS5NZXNzYWdlQmxvY2tUZXh0SABSBHRleHQSQQoEbGluaxgCIAEoCzIr'
    'LmFueXR5cGUubW9kZWwuQ2hhdE1lc3NhZ2UuTWVzc2FnZUJsb2NrTGlua0gAUgRsaW5rEkQKBW'
    'VtYmVkGAMgASgLMiwuYW55dHlwZS5tb2RlbC5DaGF0TWVzc2FnZS5NZXNzYWdlQmxvY2tFbWJl'
    'ZEgAUgVlbWJlZEIJCgdjb250ZW50GtEBChBNZXNzYWdlQmxvY2tUZXh0EhIKBHRleHQYASABKA'
    'lSBHRleHQSPQoFc3R5bGUYAiABKA4yJy5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuVGV4'
    'dC5TdHlsZVIFc3R5bGUSPAoFbWFya3MYAyADKAsyJi5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbn'
    'RlbnQuVGV4dC5NYXJrUgVtYXJrcxIYCgdjaGVja2VkGAQgASgIUgdjaGVja2VkEhIKBGxhbmcY'
    'BSABKAlSBGxhbmcavwEKEE1lc3NhZ2VCbG9ja0xpbmsSJgoOdGFyZ2V0T2JqZWN0SWQYASABKA'
    'lSDnRhcmdldE9iamVjdElkEkgKBHR5cGUYAiABKA4yNC5hbnl0eXBlLm1vZGVsLkNoYXRNZXNz'
    'YWdlLk1lc3NhZ2VCbG9ja0xpbmsuTGlua1R5cGVSBHR5cGUiOQoITGlua1R5cGUSCgoGT2JqZW'
    'N0EAASCAoERmlsZRABEgkKBUltYWdlEAISDAoIQm9va21hcmsQAxpzChFNZXNzYWdlQmxvY2tF'
    'bWJlZBISCgR0ZXh0GAEgASgJUgR0ZXh0EkoKCXByb2Nlc3NvchgCIAEoDjIsLmFueXR5cGUubW'
    '9kZWwuQmxvY2suQ29udGVudC5MYXRleC5Qcm9jZXNzb3JSCXByb2Nlc3Nvcg==');
