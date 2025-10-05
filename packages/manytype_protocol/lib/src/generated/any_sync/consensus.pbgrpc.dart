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

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'consensus.pb.dart' as $0;

export 'consensus.pb.dart';

@$pb.GrpcServiceName('consensusProto.Consensus')
class ConsensusClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ConsensusClient(super.channel, {super.options, super.interceptors});

  /// LogAdd adds new log to consensus
  $grpc.ResponseFuture<$0.Ok> logAdd(
    $0.LogAddRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$logAdd, request, options: options);
  }

  /// RecordAdd adds new record to log
  $grpc.ResponseFuture<$0.RawRecordWithId> recordAdd(
    $0.RecordAddRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$recordAdd, request, options: options);
  }

  /// LogWatch fetches log and subscribes for a changes
  $grpc.ResponseStream<$0.LogWatchEvent> logWatch(
    $async.Stream<$0.LogWatchRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$logWatch, request, options: options);
  }

  /// LogDelete deletes the log from the consensus
  $grpc.ResponseFuture<$0.Ok> logDelete(
    $0.LogDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$logDelete, request, options: options);
  }

  // method descriptors

  static final _$logAdd = $grpc.ClientMethod<$0.LogAddRequest, $0.Ok>(
      '/consensusProto.Consensus/LogAdd',
      ($0.LogAddRequest value) => value.writeToBuffer(),
      $0.Ok.fromBuffer);
  static final _$recordAdd =
      $grpc.ClientMethod<$0.RecordAddRequest, $0.RawRecordWithId>(
          '/consensusProto.Consensus/RecordAdd',
          ($0.RecordAddRequest value) => value.writeToBuffer(),
          $0.RawRecordWithId.fromBuffer);
  static final _$logWatch =
      $grpc.ClientMethod<$0.LogWatchRequest, $0.LogWatchEvent>(
          '/consensusProto.Consensus/LogWatch',
          ($0.LogWatchRequest value) => value.writeToBuffer(),
          $0.LogWatchEvent.fromBuffer);
  static final _$logDelete = $grpc.ClientMethod<$0.LogDeleteRequest, $0.Ok>(
      '/consensusProto.Consensus/LogDelete',
      ($0.LogDeleteRequest value) => value.writeToBuffer(),
      $0.Ok.fromBuffer);
}

@$pb.GrpcServiceName('consensusProto.Consensus')
abstract class ConsensusServiceBase extends $grpc.Service {
  $core.String get $name => 'consensusProto.Consensus';

  ConsensusServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LogAddRequest, $0.Ok>(
        'LogAdd',
        logAdd_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LogAddRequest.fromBuffer(value),
        ($0.Ok value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecordAddRequest, $0.RawRecordWithId>(
        'RecordAdd',
        recordAdd_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RecordAddRequest.fromBuffer(value),
        ($0.RawRecordWithId value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogWatchRequest, $0.LogWatchEvent>(
        'LogWatch',
        logWatch,
        true,
        true,
        ($core.List<$core.int> value) => $0.LogWatchRequest.fromBuffer(value),
        ($0.LogWatchEvent value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogDeleteRequest, $0.Ok>(
        'LogDelete',
        logDelete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LogDeleteRequest.fromBuffer(value),
        ($0.Ok value) => value.writeToBuffer()));
  }

  $async.Future<$0.Ok> logAdd_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LogAddRequest> $request) async {
    return logAdd($call, await $request);
  }

  $async.Future<$0.Ok> logAdd($grpc.ServiceCall call, $0.LogAddRequest request);

  $async.Future<$0.RawRecordWithId> recordAdd_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RecordAddRequest> $request) async {
    return recordAdd($call, await $request);
  }

  $async.Future<$0.RawRecordWithId> recordAdd(
      $grpc.ServiceCall call, $0.RecordAddRequest request);

  $async.Stream<$0.LogWatchEvent> logWatch(
      $grpc.ServiceCall call, $async.Stream<$0.LogWatchRequest> request);

  $async.Future<$0.Ok> logDelete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LogDeleteRequest> $request) async {
    return logDelete($call, await $request);
  }

  $async.Future<$0.Ok> logDelete(
      $grpc.ServiceCall call, $0.LogDeleteRequest request);
}
