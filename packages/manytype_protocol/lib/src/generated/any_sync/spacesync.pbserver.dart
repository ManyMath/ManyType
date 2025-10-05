// This is a generated file - do not edit.
//
// Generated from any_sync/spacesync.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'spacesync.pb.dart' as $0;
import 'spacesync.pbjson.dart';

export 'spacesync.pb.dart';

abstract class SpaceSyncServiceBase extends $pb.GeneratedService {
  $async.Future<$0.HeadSyncResponse> headSync(
      $pb.ServerContext ctx, $0.HeadSyncRequest request);
  $async.Future<$0.StoreDiffResponse> storeDiff(
      $pb.ServerContext ctx, $0.StoreDiffRequest request);
  $async.Future<$0.StoreKeyValue> storeElements(
      $pb.ServerContext ctx, $0.StoreKeyValue request);
  $async.Future<$0.SpacePushResponse> spacePush(
      $pb.ServerContext ctx, $0.SpacePushRequest request);
  $async.Future<$0.SpacePullResponse> spacePull(
      $pb.ServerContext ctx, $0.SpacePullRequest request);
  $async.Future<$0.ObjectSyncMessage> objectSyncStream(
      $pb.ServerContext ctx, $0.ObjectSyncMessage request);
  $async.Future<$0.ObjectSyncMessage> objectSync(
      $pb.ServerContext ctx, $0.ObjectSyncMessage request);
  $async.Future<$0.ObjectSyncMessage> objectSyncRequestStream(
      $pb.ServerContext ctx, $0.ObjectSyncMessage request);
  $async.Future<$0.AclAddRecordResponse> aclAddRecord(
      $pb.ServerContext ctx, $0.AclAddRecordRequest request);
  $async.Future<$0.AclGetRecordsResponse> aclGetRecords(
      $pb.ServerContext ctx, $0.AclGetRecordsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'HeadSync':
        return $0.HeadSyncRequest();
      case 'StoreDiff':
        return $0.StoreDiffRequest();
      case 'StoreElements':
        return $0.StoreKeyValue();
      case 'SpacePush':
        return $0.SpacePushRequest();
      case 'SpacePull':
        return $0.SpacePullRequest();
      case 'ObjectSyncStream':
        return $0.ObjectSyncMessage();
      case 'ObjectSync':
        return $0.ObjectSyncMessage();
      case 'ObjectSyncRequestStream':
        return $0.ObjectSyncMessage();
      case 'AclAddRecord':
        return $0.AclAddRecordRequest();
      case 'AclGetRecords':
        return $0.AclGetRecordsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'HeadSync':
        return headSync(ctx, request as $0.HeadSyncRequest);
      case 'StoreDiff':
        return storeDiff(ctx, request as $0.StoreDiffRequest);
      case 'StoreElements':
        return storeElements(ctx, request as $0.StoreKeyValue);
      case 'SpacePush':
        return spacePush(ctx, request as $0.SpacePushRequest);
      case 'SpacePull':
        return spacePull(ctx, request as $0.SpacePullRequest);
      case 'ObjectSyncStream':
        return objectSyncStream(ctx, request as $0.ObjectSyncMessage);
      case 'ObjectSync':
        return objectSync(ctx, request as $0.ObjectSyncMessage);
      case 'ObjectSyncRequestStream':
        return objectSyncRequestStream(ctx, request as $0.ObjectSyncMessage);
      case 'AclAddRecord':
        return aclAddRecord(ctx, request as $0.AclAddRecordRequest);
      case 'AclGetRecords':
        return aclGetRecords(ctx, request as $0.AclGetRecordsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SpaceSyncServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SpaceSyncServiceBase$messageJson;
}
