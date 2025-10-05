// This is a generated file - do not edit.
//
// Generated from any_sync/crypto.proto.

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

@$core.Deprecated('Use keyTypeDescriptor instead')
const KeyType$json = {
  '1': 'KeyType',
  '2': [
    {'1': 'Ed25519Public', '2': 0},
    {'1': 'Ed25519Private', '2': 1},
    {'1': 'AES', '2': 2},
  ],
};

/// Descriptor for `KeyType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List keyTypeDescriptor = $convert.base64Decode(
    'CgdLZXlUeXBlEhEKDUVkMjU1MTlQdWJsaWMQABISCg5FZDI1NTE5UHJpdmF0ZRABEgcKA0FFUx'
    'AC');

@$core.Deprecated('Use keyDescriptor instead')
const Key$json = {
  '1': 'Key',
  '2': [
    {
      '1': 'Type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.crypto.KeyType',
      '10': 'Type'
    },
    {'1': 'Data', '3': 2, '4': 1, '5': 12, '10': 'Data'},
  ],
};

/// Descriptor for `Key`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyDescriptor = $convert.base64Decode(
    'CgNLZXkSIwoEVHlwZRgBIAEoDjIPLmNyeXB0by5LZXlUeXBlUgRUeXBlEhIKBERhdGEYAiABKA'
    'xSBERhdGE=');
