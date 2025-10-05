// This is a generated file - do not edit.
//
// Generated from any_sync/consensus.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'consensus.pb.dart' as $0;
import 'consensus.pbjson.dart';

export 'consensus.pb.dart';

abstract class ConsensusServiceBase extends $pb.GeneratedService {
  $async.Future<$0.Ok> logAdd($pb.ServerContext ctx, $0.LogAddRequest request);
  $async.Future<$0.RawRecordWithId> recordAdd(
      $pb.ServerContext ctx, $0.RecordAddRequest request);
  $async.Future<$0.LogWatchEvent> logWatch(
      $pb.ServerContext ctx, $0.LogWatchRequest request);
  $async.Future<$0.Ok> logDelete(
      $pb.ServerContext ctx, $0.LogDeleteRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'LogAdd':
        return $0.LogAddRequest();
      case 'RecordAdd':
        return $0.RecordAddRequest();
      case 'LogWatch':
        return $0.LogWatchRequest();
      case 'LogDelete':
        return $0.LogDeleteRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'LogAdd':
        return logAdd(ctx, request as $0.LogAddRequest);
      case 'RecordAdd':
        return recordAdd(ctx, request as $0.RecordAddRequest);
      case 'LogWatch':
        return logWatch(ctx, request as $0.LogWatchRequest);
      case 'LogDelete':
        return logDelete(ctx, request as $0.LogDeleteRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ConsensusServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => ConsensusServiceBase$messageJson;
}
