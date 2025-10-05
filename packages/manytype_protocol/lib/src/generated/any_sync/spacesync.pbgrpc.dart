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

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'spacesync.pb.dart' as $0;

export 'spacesync.pb.dart';

@$pb.GrpcServiceName('spacesync.SpaceSync')
class SpaceSyncClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SpaceSyncClient(super.channel, {super.options, super.interceptors});

  /// HeadSync compares all objects and their hashes in a space
  $grpc.ResponseFuture<$0.HeadSyncResponse> headSync(
    $0.HeadSyncRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$headSync, request, options: options);
  }

  /// StoreDiff compares all objects and their hashes in a space
  $grpc.ResponseFuture<$0.StoreDiffResponse> storeDiff(
    $0.StoreDiffRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$storeDiff, request, options: options);
  }

  /// StoreElements exchanges elements between peers
  $grpc.ResponseStream<$0.StoreKeyValue> storeElements(
    $async.Stream<$0.StoreKeyValue> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$storeElements, request, options: options);
  }

  /// SpacePush sends new space to the node
  $grpc.ResponseFuture<$0.SpacePushResponse> spacePush(
    $0.SpacePushRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spacePush, request, options: options);
  }

  /// SpacePull gets space from the remote peer
  $grpc.ResponseFuture<$0.SpacePullResponse> spacePull(
    $0.SpacePullRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spacePull, request, options: options);
  }

  /// ObjectSyncStream opens object sync stream with node or client
  $grpc.ResponseStream<$0.ObjectSyncMessage> objectSyncStream(
    $async.Stream<$0.ObjectSyncMessage> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$objectSyncStream, request, options: options);
  }

  /// ObjectSync sends object sync message and synchronously gets response message
  $grpc.ResponseFuture<$0.ObjectSyncMessage> objectSync(
    $0.ObjectSyncMessage request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$objectSync, request, options: options);
  }

  /// ObjectSyncRequestStream opens sends a request and gets streamed response
  $grpc.ResponseStream<$0.ObjectSyncMessage> objectSyncRequestStream(
    $0.ObjectSyncMessage request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$objectSyncRequestStream, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// AclAddRecord adds a new record to acl log. Works only with any-sync-node
  /// deprecated: use coordinator api
  $grpc.ResponseFuture<$0.AclAddRecordResponse> aclAddRecord(
    $0.AclAddRecordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$aclAddRecord, request, options: options);
  }

  /// AclGetRecords gets acl records
  /// deprecated: use coordinator api
  $grpc.ResponseFuture<$0.AclGetRecordsResponse> aclGetRecords(
    $0.AclGetRecordsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$aclGetRecords, request, options: options);
  }

  // method descriptors

  static final _$headSync =
      $grpc.ClientMethod<$0.HeadSyncRequest, $0.HeadSyncResponse>(
          '/spacesync.SpaceSync/HeadSync',
          ($0.HeadSyncRequest value) => value.writeToBuffer(),
          $0.HeadSyncResponse.fromBuffer);
  static final _$storeDiff =
      $grpc.ClientMethod<$0.StoreDiffRequest, $0.StoreDiffResponse>(
          '/spacesync.SpaceSync/StoreDiff',
          ($0.StoreDiffRequest value) => value.writeToBuffer(),
          $0.StoreDiffResponse.fromBuffer);
  static final _$storeElements =
      $grpc.ClientMethod<$0.StoreKeyValue, $0.StoreKeyValue>(
          '/spacesync.SpaceSync/StoreElements',
          ($0.StoreKeyValue value) => value.writeToBuffer(),
          $0.StoreKeyValue.fromBuffer);
  static final _$spacePush =
      $grpc.ClientMethod<$0.SpacePushRequest, $0.SpacePushResponse>(
          '/spacesync.SpaceSync/SpacePush',
          ($0.SpacePushRequest value) => value.writeToBuffer(),
          $0.SpacePushResponse.fromBuffer);
  static final _$spacePull =
      $grpc.ClientMethod<$0.SpacePullRequest, $0.SpacePullResponse>(
          '/spacesync.SpaceSync/SpacePull',
          ($0.SpacePullRequest value) => value.writeToBuffer(),
          $0.SpacePullResponse.fromBuffer);
  static final _$objectSyncStream =
      $grpc.ClientMethod<$0.ObjectSyncMessage, $0.ObjectSyncMessage>(
          '/spacesync.SpaceSync/ObjectSyncStream',
          ($0.ObjectSyncMessage value) => value.writeToBuffer(),
          $0.ObjectSyncMessage.fromBuffer);
  static final _$objectSync =
      $grpc.ClientMethod<$0.ObjectSyncMessage, $0.ObjectSyncMessage>(
          '/spacesync.SpaceSync/ObjectSync',
          ($0.ObjectSyncMessage value) => value.writeToBuffer(),
          $0.ObjectSyncMessage.fromBuffer);
  static final _$objectSyncRequestStream =
      $grpc.ClientMethod<$0.ObjectSyncMessage, $0.ObjectSyncMessage>(
          '/spacesync.SpaceSync/ObjectSyncRequestStream',
          ($0.ObjectSyncMessage value) => value.writeToBuffer(),
          $0.ObjectSyncMessage.fromBuffer);
  static final _$aclAddRecord =
      $grpc.ClientMethod<$0.AclAddRecordRequest, $0.AclAddRecordResponse>(
          '/spacesync.SpaceSync/AclAddRecord',
          ($0.AclAddRecordRequest value) => value.writeToBuffer(),
          $0.AclAddRecordResponse.fromBuffer);
  static final _$aclGetRecords =
      $grpc.ClientMethod<$0.AclGetRecordsRequest, $0.AclGetRecordsResponse>(
          '/spacesync.SpaceSync/AclGetRecords',
          ($0.AclGetRecordsRequest value) => value.writeToBuffer(),
          $0.AclGetRecordsResponse.fromBuffer);
}

@$pb.GrpcServiceName('spacesync.SpaceSync')
abstract class SpaceSyncServiceBase extends $grpc.Service {
  $core.String get $name => 'spacesync.SpaceSync';

  SpaceSyncServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HeadSyncRequest, $0.HeadSyncResponse>(
        'HeadSync',
        headSync_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HeadSyncRequest.fromBuffer(value),
        ($0.HeadSyncResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StoreDiffRequest, $0.StoreDiffResponse>(
        'StoreDiff',
        storeDiff_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StoreDiffRequest.fromBuffer(value),
        ($0.StoreDiffResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StoreKeyValue, $0.StoreKeyValue>(
        'StoreElements',
        storeElements,
        true,
        true,
        ($core.List<$core.int> value) => $0.StoreKeyValue.fromBuffer(value),
        ($0.StoreKeyValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpacePushRequest, $0.SpacePushResponse>(
        'SpacePush',
        spacePush_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SpacePushRequest.fromBuffer(value),
        ($0.SpacePushResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpacePullRequest, $0.SpacePullResponse>(
        'SpacePull',
        spacePull_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SpacePullRequest.fromBuffer(value),
        ($0.SpacePullResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ObjectSyncMessage, $0.ObjectSyncMessage>(
        'ObjectSyncStream',
        objectSyncStream,
        true,
        true,
        ($core.List<$core.int> value) => $0.ObjectSyncMessage.fromBuffer(value),
        ($0.ObjectSyncMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ObjectSyncMessage, $0.ObjectSyncMessage>(
        'ObjectSync',
        objectSync_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ObjectSyncMessage.fromBuffer(value),
        ($0.ObjectSyncMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ObjectSyncMessage, $0.ObjectSyncMessage>(
        'ObjectSyncRequestStream',
        objectSyncRequestStream_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.ObjectSyncMessage.fromBuffer(value),
        ($0.ObjectSyncMessage value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AclAddRecordRequest, $0.AclAddRecordResponse>(
            'AclAddRecord',
            aclAddRecord_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AclAddRecordRequest.fromBuffer(value),
            ($0.AclAddRecordResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AclGetRecordsRequest, $0.AclGetRecordsResponse>(
            'AclGetRecords',
            aclGetRecords_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AclGetRecordsRequest.fromBuffer(value),
            ($0.AclGetRecordsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.HeadSyncResponse> headSync_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HeadSyncRequest> $request) async {
    return headSync($call, await $request);
  }

  $async.Future<$0.HeadSyncResponse> headSync(
      $grpc.ServiceCall call, $0.HeadSyncRequest request);

  $async.Future<$0.StoreDiffResponse> storeDiff_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StoreDiffRequest> $request) async {
    return storeDiff($call, await $request);
  }

  $async.Future<$0.StoreDiffResponse> storeDiff(
      $grpc.ServiceCall call, $0.StoreDiffRequest request);

  $async.Stream<$0.StoreKeyValue> storeElements(
      $grpc.ServiceCall call, $async.Stream<$0.StoreKeyValue> request);

  $async.Future<$0.SpacePushResponse> spacePush_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SpacePushRequest> $request) async {
    return spacePush($call, await $request);
  }

  $async.Future<$0.SpacePushResponse> spacePush(
      $grpc.ServiceCall call, $0.SpacePushRequest request);

  $async.Future<$0.SpacePullResponse> spacePull_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SpacePullRequest> $request) async {
    return spacePull($call, await $request);
  }

  $async.Future<$0.SpacePullResponse> spacePull(
      $grpc.ServiceCall call, $0.SpacePullRequest request);

  $async.Stream<$0.ObjectSyncMessage> objectSyncStream(
      $grpc.ServiceCall call, $async.Stream<$0.ObjectSyncMessage> request);

  $async.Future<$0.ObjectSyncMessage> objectSync_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ObjectSyncMessage> $request) async {
    return objectSync($call, await $request);
  }

  $async.Future<$0.ObjectSyncMessage> objectSync(
      $grpc.ServiceCall call, $0.ObjectSyncMessage request);

  $async.Stream<$0.ObjectSyncMessage> objectSyncRequestStream_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ObjectSyncMessage> $request) async* {
    yield* objectSyncRequestStream($call, await $request);
  }

  $async.Stream<$0.ObjectSyncMessage> objectSyncRequestStream(
      $grpc.ServiceCall call, $0.ObjectSyncMessage request);

  $async.Future<$0.AclAddRecordResponse> aclAddRecord_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AclAddRecordRequest> $request) async {
    return aclAddRecord($call, await $request);
  }

  $async.Future<$0.AclAddRecordResponse> aclAddRecord(
      $grpc.ServiceCall call, $0.AclAddRecordRequest request);

  $async.Future<$0.AclGetRecordsResponse> aclGetRecords_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AclGetRecordsRequest> $request) async {
    return aclGetRecords($call, await $request);
  }

  $async.Future<$0.AclGetRecordsResponse> aclGetRecords(
      $grpc.ServiceCall call, $0.AclGetRecordsRequest request);
}
