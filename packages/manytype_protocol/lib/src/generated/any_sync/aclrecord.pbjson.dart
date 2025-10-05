// This is a generated file - do not edit.
//
// Generated from any_sync/aclrecord.proto.

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

@$core.Deprecated('Use aclInviteTypeDescriptor instead')
const AclInviteType$json = {
  '1': 'AclInviteType',
  '2': [
    {'1': 'RequestToJoin', '2': 0},
    {'1': 'AnyoneCanJoin', '2': 1},
  ],
};

/// Descriptor for `AclInviteType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List aclInviteTypeDescriptor = $convert.base64Decode(
    'Cg1BY2xJbnZpdGVUeXBlEhEKDVJlcXVlc3RUb0pvaW4QABIRCg1BbnlvbmVDYW5Kb2luEAE=');

@$core.Deprecated('Use aclUserPermissionsDescriptor instead')
const AclUserPermissions$json = {
  '1': 'AclUserPermissions',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'Owner', '2': 1},
    {'1': 'Admin', '2': 2},
    {'1': 'Writer', '2': 3},
    {'1': 'Reader', '2': 4},
    {'1': 'Guest', '2': 5},
  ],
};

/// Descriptor for `AclUserPermissions`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List aclUserPermissionsDescriptor = $convert.base64Decode(
    'ChJBY2xVc2VyUGVybWlzc2lvbnMSCAoETm9uZRAAEgkKBU93bmVyEAESCQoFQWRtaW4QAhIKCg'
    'ZXcml0ZXIQAxIKCgZSZWFkZXIQBBIJCgVHdWVzdBAF');

@$core.Deprecated('Use aclRootDescriptor instead')
const AclRoot$json = {
  '1': 'AclRoot',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'masterKey', '3': 2, '4': 1, '5': 12, '10': 'masterKey'},
    {'1': 'spaceId', '3': 3, '4': 1, '5': 9, '10': 'spaceId'},
    {
      '1': 'encryptedReadKey',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'encryptedReadKey'
    },
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
    {
      '1': 'identitySignature',
      '3': 6,
      '4': 1,
      '5': 12,
      '10': 'identitySignature'
    },
    {'1': 'metadataPubKey', '3': 7, '4': 1, '5': 12, '10': 'metadataPubKey'},
    {
      '1': 'encryptedMetadataPrivKey',
      '3': 8,
      '4': 1,
      '5': 12,
      '10': 'encryptedMetadataPrivKey'
    },
    {
      '1': 'encryptedOwnerMetadata',
      '3': 9,
      '4': 1,
      '5': 12,
      '10': 'encryptedOwnerMetadata'
    },
  ],
};

/// Descriptor for `AclRoot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclRootDescriptor = $convert.base64Decode(
    'CgdBY2xSb290EhoKCGlkZW50aXR5GAEgASgMUghpZGVudGl0eRIcCgltYXN0ZXJLZXkYAiABKA'
    'xSCW1hc3RlcktleRIYCgdzcGFjZUlkGAMgASgJUgdzcGFjZUlkEioKEGVuY3J5cHRlZFJlYWRL'
    'ZXkYBCABKAxSEGVuY3J5cHRlZFJlYWRLZXkSHAoJdGltZXN0YW1wGAUgASgDUgl0aW1lc3RhbX'
    'ASLAoRaWRlbnRpdHlTaWduYXR1cmUYBiABKAxSEWlkZW50aXR5U2lnbmF0dXJlEiYKDm1ldGFk'
    'YXRhUHViS2V5GAcgASgMUg5tZXRhZGF0YVB1YktleRI6ChhlbmNyeXB0ZWRNZXRhZGF0YVByaX'
    'ZLZXkYCCABKAxSGGVuY3J5cHRlZE1ldGFkYXRhUHJpdktleRI2ChZlbmNyeXB0ZWRPd25lck1l'
    'dGFkYXRhGAkgASgMUhZlbmNyeXB0ZWRPd25lck1ldGFkYXRh');

@$core.Deprecated('Use aclAccountInviteDescriptor instead')
const AclAccountInvite$json = {
  '1': 'AclAccountInvite',
  '2': [
    {'1': 'inviteKey', '3': 1, '4': 1, '5': 12, '10': 'inviteKey'},
    {
      '1': 'inviteType',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.aclrecord.AclInviteType',
      '10': 'inviteType'
    },
    {
      '1': 'permissions',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.aclrecord.AclUserPermissions',
      '10': 'permissions'
    },
    {
      '1': 'encryptedReadKey',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'encryptedReadKey'
    },
  ],
};

/// Descriptor for `AclAccountInvite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountInviteDescriptor = $convert.base64Decode(
    'ChBBY2xBY2NvdW50SW52aXRlEhwKCWludml0ZUtleRgBIAEoDFIJaW52aXRlS2V5EjgKCmludm'
    'l0ZVR5cGUYAiABKA4yGC5hY2xyZWNvcmQuQWNsSW52aXRlVHlwZVIKaW52aXRlVHlwZRI/Cgtw'
    'ZXJtaXNzaW9ucxgDIAEoDjIdLmFjbHJlY29yZC5BY2xVc2VyUGVybWlzc2lvbnNSC3Blcm1pc3'
    'Npb25zEioKEGVuY3J5cHRlZFJlYWRLZXkYBCABKAxSEGVuY3J5cHRlZFJlYWRLZXk=');

@$core.Deprecated('Use aclAccountInviteChangeDescriptor instead')
const AclAccountInviteChange$json = {
  '1': 'AclAccountInviteChange',
  '2': [
    {'1': 'inviteRecordId', '3': 1, '4': 1, '5': 9, '10': 'inviteRecordId'},
    {
      '1': 'permissions',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.aclrecord.AclUserPermissions',
      '10': 'permissions'
    },
  ],
};

/// Descriptor for `AclAccountInviteChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountInviteChangeDescriptor = $convert.base64Decode(
    'ChZBY2xBY2NvdW50SW52aXRlQ2hhbmdlEiYKDmludml0ZVJlY29yZElkGAEgASgJUg5pbnZpdG'
    'VSZWNvcmRJZBI/CgtwZXJtaXNzaW9ucxgCIAEoDjIdLmFjbHJlY29yZC5BY2xVc2VyUGVybWlz'
    'c2lvbnNSC3Blcm1pc3Npb25z');

@$core.Deprecated('Use aclAccountRequestJoinDescriptor instead')
const AclAccountRequestJoin$json = {
  '1': 'AclAccountRequestJoin',
  '2': [
    {'1': 'inviteIdentity', '3': 1, '4': 1, '5': 12, '10': 'inviteIdentity'},
    {'1': 'inviteRecordId', '3': 2, '4': 1, '5': 9, '10': 'inviteRecordId'},
    {
      '1': 'inviteIdentitySignature',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'inviteIdentitySignature'
    },
    {'1': 'metadata', '3': 4, '4': 1, '5': 12, '10': 'metadata'},
  ],
};

/// Descriptor for `AclAccountRequestJoin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountRequestJoinDescriptor = $convert.base64Decode(
    'ChVBY2xBY2NvdW50UmVxdWVzdEpvaW4SJgoOaW52aXRlSWRlbnRpdHkYASABKAxSDmludml0ZU'
    'lkZW50aXR5EiYKDmludml0ZVJlY29yZElkGAIgASgJUg5pbnZpdGVSZWNvcmRJZBI4ChdpbnZp'
    'dGVJZGVudGl0eVNpZ25hdHVyZRgDIAEoDFIXaW52aXRlSWRlbnRpdHlTaWduYXR1cmUSGgoIbW'
    'V0YWRhdGEYBCABKAxSCG1ldGFkYXRh');

@$core.Deprecated('Use aclAccountInviteJoinDescriptor instead')
const AclAccountInviteJoin$json = {
  '1': 'AclAccountInviteJoin',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'inviteRecordId', '3': 2, '4': 1, '5': 9, '10': 'inviteRecordId'},
    {
      '1': 'inviteIdentitySignature',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'inviteIdentitySignature'
    },
    {'1': 'metadata', '3': 4, '4': 1, '5': 12, '10': 'metadata'},
    {
      '1': 'encryptedReadKey',
      '3': 5,
      '4': 1,
      '5': 12,
      '10': 'encryptedReadKey'
    },
    {
      '1': 'permissions',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.aclrecord.AclUserPermissions',
      '10': 'permissions'
    },
  ],
};

/// Descriptor for `AclAccountInviteJoin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountInviteJoinDescriptor = $convert.base64Decode(
    'ChRBY2xBY2NvdW50SW52aXRlSm9pbhIaCghpZGVudGl0eRgBIAEoDFIIaWRlbnRpdHkSJgoOaW'
    '52aXRlUmVjb3JkSWQYAiABKAlSDmludml0ZVJlY29yZElkEjgKF2ludml0ZUlkZW50aXR5U2ln'
    'bmF0dXJlGAMgASgMUhdpbnZpdGVJZGVudGl0eVNpZ25hdHVyZRIaCghtZXRhZGF0YRgEIAEoDF'
    'IIbWV0YWRhdGESKgoQZW5jcnlwdGVkUmVhZEtleRgFIAEoDFIQZW5jcnlwdGVkUmVhZEtleRI/'
    'CgtwZXJtaXNzaW9ucxgGIAEoDjIdLmFjbHJlY29yZC5BY2xVc2VyUGVybWlzc2lvbnNSC3Blcm'
    '1pc3Npb25z');

@$core.Deprecated('Use aclAccountRequestAcceptDescriptor instead')
const AclAccountRequestAccept$json = {
  '1': 'AclAccountRequestAccept',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'requestRecordId', '3': 2, '4': 1, '5': 9, '10': 'requestRecordId'},
    {
      '1': 'encryptedReadKey',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'encryptedReadKey'
    },
    {
      '1': 'permissions',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.aclrecord.AclUserPermissions',
      '10': 'permissions'
    },
  ],
};

/// Descriptor for `AclAccountRequestAccept`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountRequestAcceptDescriptor = $convert.base64Decode(
    'ChdBY2xBY2NvdW50UmVxdWVzdEFjY2VwdBIaCghpZGVudGl0eRgBIAEoDFIIaWRlbnRpdHkSKA'
    'oPcmVxdWVzdFJlY29yZElkGAIgASgJUg9yZXF1ZXN0UmVjb3JkSWQSKgoQZW5jcnlwdGVkUmVh'
    'ZEtleRgDIAEoDFIQZW5jcnlwdGVkUmVhZEtleRI/CgtwZXJtaXNzaW9ucxgEIAEoDjIdLmFjbH'
    'JlY29yZC5BY2xVc2VyUGVybWlzc2lvbnNSC3Blcm1pc3Npb25z');

@$core.Deprecated('Use aclAccountRequestDeclineDescriptor instead')
const AclAccountRequestDecline$json = {
  '1': 'AclAccountRequestDecline',
  '2': [
    {'1': 'requestRecordId', '3': 1, '4': 1, '5': 9, '10': 'requestRecordId'},
  ],
};

/// Descriptor for `AclAccountRequestDecline`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountRequestDeclineDescriptor =
    $convert.base64Decode(
        'ChhBY2xBY2NvdW50UmVxdWVzdERlY2xpbmUSKAoPcmVxdWVzdFJlY29yZElkGAEgASgJUg9yZX'
        'F1ZXN0UmVjb3JkSWQ=');

@$core.Deprecated('Use aclAccountInviteRevokeDescriptor instead')
const AclAccountInviteRevoke$json = {
  '1': 'AclAccountInviteRevoke',
  '2': [
    {'1': 'inviteRecordId', '3': 1, '4': 1, '5': 9, '10': 'inviteRecordId'},
  ],
};

/// Descriptor for `AclAccountInviteRevoke`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountInviteRevokeDescriptor =
    $convert.base64Decode(
        'ChZBY2xBY2NvdW50SW52aXRlUmV2b2tlEiYKDmludml0ZVJlY29yZElkGAEgASgJUg5pbnZpdG'
        'VSZWNvcmRJZA==');

@$core.Deprecated('Use aclEncryptedReadKeyDescriptor instead')
const AclEncryptedReadKey$json = {
  '1': 'AclEncryptedReadKey',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 12, '10': 'identity'},
    {
      '1': 'encryptedReadKey',
      '3': 2,
      '4': 1,
      '5': 12,
      '10': 'encryptedReadKey'
    },
  ],
};

/// Descriptor for `AclEncryptedReadKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclEncryptedReadKeyDescriptor = $convert.base64Decode(
    'ChNBY2xFbmNyeXB0ZWRSZWFkS2V5EhoKCGlkZW50aXR5GAEgASgMUghpZGVudGl0eRIqChBlbm'
    'NyeXB0ZWRSZWFkS2V5GAIgASgMUhBlbmNyeXB0ZWRSZWFkS2V5');

@$core.Deprecated('Use aclAccountPermissionChangesDescriptor instead')
const AclAccountPermissionChanges$json = {
  '1': 'AclAccountPermissionChanges',
  '2': [
    {
      '1': 'changes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.aclrecord.AclAccountPermissionChange',
      '10': 'changes'
    },
  ],
};

/// Descriptor for `AclAccountPermissionChanges`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountPermissionChangesDescriptor =
    $convert.base64Decode(
        'ChtBY2xBY2NvdW50UGVybWlzc2lvbkNoYW5nZXMSPwoHY2hhbmdlcxgBIAMoCzIlLmFjbHJlY2'
        '9yZC5BY2xBY2NvdW50UGVybWlzc2lvbkNoYW5nZVIHY2hhbmdlcw==');

@$core.Deprecated('Use aclAccountsAddDescriptor instead')
const AclAccountsAdd$json = {
  '1': 'AclAccountsAdd',
  '2': [
    {
      '1': 'additions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.aclrecord.AclAccountAdd',
      '10': 'additions'
    },
  ],
};

/// Descriptor for `AclAccountsAdd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountsAddDescriptor = $convert.base64Decode(
    'Cg5BY2xBY2NvdW50c0FkZBI2CglhZGRpdGlvbnMYASADKAsyGC5hY2xyZWNvcmQuQWNsQWNjb3'
    'VudEFkZFIJYWRkaXRpb25z');

@$core.Deprecated('Use aclAccountAddDescriptor instead')
const AclAccountAdd$json = {
  '1': 'AclAccountAdd',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 12, '10': 'identity'},
    {
      '1': 'permissions',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.aclrecord.AclUserPermissions',
      '10': 'permissions'
    },
    {'1': 'metadata', '3': 3, '4': 1, '5': 12, '10': 'metadata'},
    {
      '1': 'encryptedReadKey',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'encryptedReadKey'
    },
  ],
};

/// Descriptor for `AclAccountAdd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountAddDescriptor = $convert.base64Decode(
    'Cg1BY2xBY2NvdW50QWRkEhoKCGlkZW50aXR5GAEgASgMUghpZGVudGl0eRI/CgtwZXJtaXNzaW'
    '9ucxgCIAEoDjIdLmFjbHJlY29yZC5BY2xVc2VyUGVybWlzc2lvbnNSC3Blcm1pc3Npb25zEhoK'
    'CG1ldGFkYXRhGAMgASgMUghtZXRhZGF0YRIqChBlbmNyeXB0ZWRSZWFkS2V5GAQgASgMUhBlbm'
    'NyeXB0ZWRSZWFkS2V5');

@$core.Deprecated('Use aclAccountRequestCancelDescriptor instead')
const AclAccountRequestCancel$json = {
  '1': 'AclAccountRequestCancel',
  '2': [
    {'1': 'recordId', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
  ],
};

/// Descriptor for `AclAccountRequestCancel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountRequestCancelDescriptor =
    $convert.base64Decode(
        'ChdBY2xBY2NvdW50UmVxdWVzdENhbmNlbBIaCghyZWNvcmRJZBgBIAEoCVIIcmVjb3JkSWQ=');

@$core.Deprecated('Use aclAccountPermissionChangeDescriptor instead')
const AclAccountPermissionChange$json = {
  '1': 'AclAccountPermissionChange',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 12, '10': 'identity'},
    {
      '1': 'permissions',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.aclrecord.AclUserPermissions',
      '10': 'permissions'
    },
  ],
};

/// Descriptor for `AclAccountPermissionChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountPermissionChangeDescriptor =
    $convert.base64Decode(
        'ChpBY2xBY2NvdW50UGVybWlzc2lvbkNoYW5nZRIaCghpZGVudGl0eRgBIAEoDFIIaWRlbnRpdH'
        'kSPwoLcGVybWlzc2lvbnMYAiABKA4yHS5hY2xyZWNvcmQuQWNsVXNlclBlcm1pc3Npb25zUgtw'
        'ZXJtaXNzaW9ucw==');

@$core.Deprecated('Use aclReadKeyChangeDescriptor instead')
const AclReadKeyChange$json = {
  '1': 'AclReadKeyChange',
  '2': [
    {
      '1': 'accountKeys',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.aclrecord.AclEncryptedReadKey',
      '10': 'accountKeys'
    },
    {'1': 'metadataPubKey', '3': 2, '4': 1, '5': 12, '10': 'metadataPubKey'},
    {
      '1': 'encryptedMetadataPrivKey',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'encryptedMetadataPrivKey'
    },
    {
      '1': 'encryptedOldReadKey',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'encryptedOldReadKey'
    },
    {
      '1': 'inviteKeys',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.aclrecord.AclEncryptedReadKey',
      '10': 'inviteKeys'
    },
  ],
};

/// Descriptor for `AclReadKeyChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclReadKeyChangeDescriptor = $convert.base64Decode(
    'ChBBY2xSZWFkS2V5Q2hhbmdlEkAKC2FjY291bnRLZXlzGAEgAygLMh4uYWNscmVjb3JkLkFjbE'
    'VuY3J5cHRlZFJlYWRLZXlSC2FjY291bnRLZXlzEiYKDm1ldGFkYXRhUHViS2V5GAIgASgMUg5t'
    'ZXRhZGF0YVB1YktleRI6ChhlbmNyeXB0ZWRNZXRhZGF0YVByaXZLZXkYAyABKAxSGGVuY3J5cH'
    'RlZE1ldGFkYXRhUHJpdktleRIwChNlbmNyeXB0ZWRPbGRSZWFkS2V5GAQgASgMUhNlbmNyeXB0'
    'ZWRPbGRSZWFkS2V5Ej4KCmludml0ZUtleXMYBSADKAsyHi5hY2xyZWNvcmQuQWNsRW5jcnlwdG'
    'VkUmVhZEtleVIKaW52aXRlS2V5cw==');

@$core.Deprecated('Use aclAccountRemoveDescriptor instead')
const AclAccountRemove$json = {
  '1': 'AclAccountRemove',
  '2': [
    {'1': 'identities', '3': 1, '4': 3, '5': 12, '10': 'identities'},
    {
      '1': 'readKeyChange',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclReadKeyChange',
      '10': 'readKeyChange'
    },
  ],
};

/// Descriptor for `AclAccountRemove`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountRemoveDescriptor = $convert.base64Decode(
    'ChBBY2xBY2NvdW50UmVtb3ZlEh4KCmlkZW50aXRpZXMYASADKAxSCmlkZW50aXRpZXMSQQoNcm'
    'VhZEtleUNoYW5nZRgCIAEoCzIbLmFjbHJlY29yZC5BY2xSZWFkS2V5Q2hhbmdlUg1yZWFkS2V5'
    'Q2hhbmdl');

@$core.Deprecated('Use aclAccountRequestRemoveDescriptor instead')
const AclAccountRequestRemove$json = {
  '1': 'AclAccountRequestRemove',
};

/// Descriptor for `AclAccountRequestRemove`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclAccountRequestRemoveDescriptor =
    $convert.base64Decode('ChdBY2xBY2NvdW50UmVxdWVzdFJlbW92ZQ==');

@$core.Deprecated('Use aclContentValueDescriptor instead')
const AclContentValue$json = {
  '1': 'AclContentValue',
  '2': [
    {
      '1': 'invite',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountInvite',
      '9': 0,
      '10': 'invite'
    },
    {
      '1': 'inviteRevoke',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountInviteRevoke',
      '9': 0,
      '10': 'inviteRevoke'
    },
    {
      '1': 'requestJoin',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountRequestJoin',
      '9': 0,
      '10': 'requestJoin'
    },
    {
      '1': 'requestAccept',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountRequestAccept',
      '9': 0,
      '10': 'requestAccept'
    },
    {
      '1': 'permissionChange',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountPermissionChange',
      '9': 0,
      '10': 'permissionChange'
    },
    {
      '1': 'accountRemove',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountRemove',
      '9': 0,
      '10': 'accountRemove'
    },
    {
      '1': 'readKeyChange',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclReadKeyChange',
      '9': 0,
      '10': 'readKeyChange'
    },
    {
      '1': 'requestDecline',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountRequestDecline',
      '9': 0,
      '10': 'requestDecline'
    },
    {
      '1': 'accountRequestRemove',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountRequestRemove',
      '9': 0,
      '10': 'accountRequestRemove'
    },
    {
      '1': 'permissionChanges',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountPermissionChanges',
      '9': 0,
      '10': 'permissionChanges'
    },
    {
      '1': 'accountsAdd',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountsAdd',
      '9': 0,
      '10': 'accountsAdd'
    },
    {
      '1': 'requestCancel',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountRequestCancel',
      '9': 0,
      '10': 'requestCancel'
    },
    {
      '1': 'inviteJoin',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountInviteJoin',
      '9': 0,
      '10': 'inviteJoin'
    },
    {
      '1': 'inviteChange',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.aclrecord.AclAccountInviteChange',
      '9': 0,
      '10': 'inviteChange'
    },
  ],
  '8': [
    {'1': 'value'},
  ],
};

/// Descriptor for `AclContentValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclContentValueDescriptor = $convert.base64Decode(
    'Cg9BY2xDb250ZW50VmFsdWUSNQoGaW52aXRlGAEgASgLMhsuYWNscmVjb3JkLkFjbEFjY291bn'
    'RJbnZpdGVIAFIGaW52aXRlEkcKDGludml0ZVJldm9rZRgCIAEoCzIhLmFjbHJlY29yZC5BY2xB'
    'Y2NvdW50SW52aXRlUmV2b2tlSABSDGludml0ZVJldm9rZRJECgtyZXF1ZXN0Sm9pbhgDIAEoCz'
    'IgLmFjbHJlY29yZC5BY2xBY2NvdW50UmVxdWVzdEpvaW5IAFILcmVxdWVzdEpvaW4SSgoNcmVx'
    'dWVzdEFjY2VwdBgEIAEoCzIiLmFjbHJlY29yZC5BY2xBY2NvdW50UmVxdWVzdEFjY2VwdEgAUg'
    '1yZXF1ZXN0QWNjZXB0ElMKEHBlcm1pc3Npb25DaGFuZ2UYBSABKAsyJS5hY2xyZWNvcmQuQWNs'
    'QWNjb3VudFBlcm1pc3Npb25DaGFuZ2VIAFIQcGVybWlzc2lvbkNoYW5nZRJDCg1hY2NvdW50Um'
    'Vtb3ZlGAYgASgLMhsuYWNscmVjb3JkLkFjbEFjY291bnRSZW1vdmVIAFINYWNjb3VudFJlbW92'
    'ZRJDCg1yZWFkS2V5Q2hhbmdlGAcgASgLMhsuYWNscmVjb3JkLkFjbFJlYWRLZXlDaGFuZ2VIAF'
    'INcmVhZEtleUNoYW5nZRJNCg5yZXF1ZXN0RGVjbGluZRgIIAEoCzIjLmFjbHJlY29yZC5BY2xB'
    'Y2NvdW50UmVxdWVzdERlY2xpbmVIAFIOcmVxdWVzdERlY2xpbmUSWAoUYWNjb3VudFJlcXVlc3'
    'RSZW1vdmUYCSABKAsyIi5hY2xyZWNvcmQuQWNsQWNjb3VudFJlcXVlc3RSZW1vdmVIAFIUYWNj'
    'b3VudFJlcXVlc3RSZW1vdmUSVgoRcGVybWlzc2lvbkNoYW5nZXMYCiABKAsyJi5hY2xyZWNvcm'
    'QuQWNsQWNjb3VudFBlcm1pc3Npb25DaGFuZ2VzSABSEXBlcm1pc3Npb25DaGFuZ2VzEj0KC2Fj'
    'Y291bnRzQWRkGAsgASgLMhkuYWNscmVjb3JkLkFjbEFjY291bnRzQWRkSABSC2FjY291bnRzQW'
    'RkEkoKDXJlcXVlc3RDYW5jZWwYDCABKAsyIi5hY2xyZWNvcmQuQWNsQWNjb3VudFJlcXVlc3RD'
    'YW5jZWxIAFINcmVxdWVzdENhbmNlbBJBCgppbnZpdGVKb2luGA0gASgLMh8uYWNscmVjb3JkLk'
    'FjbEFjY291bnRJbnZpdGVKb2luSABSCmludml0ZUpvaW4SRwoMaW52aXRlQ2hhbmdlGA4gASgL'
    'MiEuYWNscmVjb3JkLkFjbEFjY291bnRJbnZpdGVDaGFuZ2VIAFIMaW52aXRlQ2hhbmdlQgcKBX'
    'ZhbHVl');

@$core.Deprecated('Use aclDataDescriptor instead')
const AclData$json = {
  '1': 'AclData',
  '2': [
    {
      '1': 'aclContent',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.aclrecord.AclContentValue',
      '10': 'aclContent'
    },
  ],
};

/// Descriptor for `AclData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aclDataDescriptor = $convert.base64Decode(
    'CgdBY2xEYXRhEjoKCmFjbENvbnRlbnQYASADKAsyGi5hY2xyZWNvcmQuQWNsQ29udGVudFZhbH'
    'VlUgphY2xDb250ZW50');
