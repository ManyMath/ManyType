// This is a generated file - do not edit.
//
// Generated from any_sync/handshake.proto.

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

@$core.Deprecated('Use credentialsTypeDescriptor instead')
const CredentialsType$json = {
  '1': 'CredentialsType',
  '2': [
    {'1': 'SkipVerify', '2': 0},
    {'1': 'SignedPeerIds', '2': 1},
  ],
};

/// Descriptor for `CredentialsType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List credentialsTypeDescriptor = $convert.base64Decode(
    'Cg9DcmVkZW50aWFsc1R5cGUSDgoKU2tpcFZlcmlmeRAAEhEKDVNpZ25lZFBlZXJJZHMQAQ==');

@$core.Deprecated('Use errorDescriptor instead')
const Error$json = {
  '1': 'Error',
  '2': [
    {'1': 'Null', '2': 0},
    {'1': 'Unexpected', '2': 1},
    {'1': 'InvalidCredentials', '2': 2},
    {'1': 'UnexpectedPayload', '2': 3},
    {'1': 'SkipVerifyNotAllowed', '2': 4},
    {'1': 'DeadlineExceeded', '2': 5},
    {'1': 'IncompatibleVersion', '2': 6},
    {'1': 'IncompatibleProto', '2': 7},
  ],
};

/// Descriptor for `Error`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorDescriptor = $convert.base64Decode(
    'CgVFcnJvchIICgROdWxsEAASDgoKVW5leHBlY3RlZBABEhYKEkludmFsaWRDcmVkZW50aWFscx'
    'ACEhUKEVVuZXhwZWN0ZWRQYXlsb2FkEAMSGAoUU2tpcFZlcmlmeU5vdEFsbG93ZWQQBBIUChBE'
    'ZWFkbGluZUV4Y2VlZGVkEAUSFwoTSW5jb21wYXRpYmxlVmVyc2lvbhAGEhUKEUluY29tcGF0aW'
    'JsZVByb3RvEAc=');

@$core.Deprecated('Use protoTypeDescriptor instead')
const ProtoType$json = {
  '1': 'ProtoType',
  '2': [
    {'1': 'DRPC', '2': 0},
  ],
};

/// Descriptor for `ProtoType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List protoTypeDescriptor =
    $convert.base64Decode('CglQcm90b1R5cGUSCAoERFJQQxAA');

@$core.Deprecated('Use encodingDescriptor instead')
const Encoding$json = {
  '1': 'Encoding',
  '2': [
    {'1': 'None', '2': 0},
    {'1': 'Snappy', '2': 1},
  ],
};

/// Descriptor for `Encoding`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List encodingDescriptor =
    $convert.base64Decode('CghFbmNvZGluZxIICgROb25lEAASCgoGU25hcHB5EAE=');

@$core.Deprecated('Use credentialsDescriptor instead')
const Credentials$json = {
  '1': 'Credentials',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anyHandshake.CredentialsType',
      '10': 'type'
    },
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'version', '3': 3, '4': 1, '5': 13, '10': 'version'},
    {'1': 'clientVersion', '3': 4, '4': 1, '5': 9, '10': 'clientVersion'},
  ],
};

/// Descriptor for `Credentials`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List credentialsDescriptor = $convert.base64Decode(
    'CgtDcmVkZW50aWFscxIxCgR0eXBlGAEgASgOMh0uYW55SGFuZHNoYWtlLkNyZWRlbnRpYWxzVH'
    'lwZVIEdHlwZRIYCgdwYXlsb2FkGAIgASgMUgdwYXlsb2FkEhgKB3ZlcnNpb24YAyABKA1SB3Zl'
    'cnNpb24SJAoNY2xpZW50VmVyc2lvbhgEIAEoCVINY2xpZW50VmVyc2lvbg==');

@$core.Deprecated('Use payloadSignedPeerIdsDescriptor instead')
const PayloadSignedPeerIds$json = {
  '1': 'PayloadSignedPeerIds',
  '2': [
    {'1': 'identity', '3': 1, '4': 1, '5': 12, '10': 'identity'},
    {'1': 'sign', '3': 2, '4': 1, '5': 12, '10': 'sign'},
  ],
};

/// Descriptor for `PayloadSignedPeerIds`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List payloadSignedPeerIdsDescriptor = $convert.base64Decode(
    'ChRQYXlsb2FkU2lnbmVkUGVlcklkcxIaCghpZGVudGl0eRgBIAEoDFIIaWRlbnRpdHkSEgoEc2'
    'lnbhgCIAEoDFIEc2lnbg==');

@$core.Deprecated('Use ackDescriptor instead')
const Ack$json = {
  '1': 'Ack',
  '2': [
    {
      '1': 'error',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anyHandshake.Error',
      '10': 'error'
    },
  ],
};

/// Descriptor for `Ack`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ackDescriptor = $convert.base64Decode(
    'CgNBY2sSKQoFZXJyb3IYASABKA4yEy5hbnlIYW5kc2hha2UuRXJyb3JSBWVycm9y');

@$core.Deprecated('Use protoDescriptor instead')
const Proto$json = {
  '1': 'Proto',
  '2': [
    {
      '1': 'proto',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anyHandshake.ProtoType',
      '10': 'proto'
    },
    {
      '1': 'encodings',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.anyHandshake.Encoding',
      '10': 'encodings'
    },
  ],
};

/// Descriptor for `Proto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List protoDescriptor = $convert.base64Decode(
    'CgVQcm90bxItCgVwcm90bxgBIAEoDjIXLmFueUhhbmRzaGFrZS5Qcm90b1R5cGVSBXByb3RvEj'
    'QKCWVuY29kaW5ncxgCIAMoDjIWLmFueUhhbmRzaGFrZS5FbmNvZGluZ1IJZW5jb2Rpbmdz');
