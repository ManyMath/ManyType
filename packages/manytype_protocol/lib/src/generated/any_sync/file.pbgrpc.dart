// This is a generated file - do not edit.
//
// Generated from any_sync/file.proto.

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

import 'file.pb.dart' as $0;

export 'file.pb.dart';

@$pb.GrpcServiceName('filesync.File')
class FileClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FileClient(super.channel, {super.options, super.interceptors});

  /// BlockGet gets one block from a server
  $grpc.ResponseFuture<$0.BlockGetResponse> blockGet(
    $0.BlockGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$blockGet, request, options: options);
  }

  /// BlockPush pushes one block to a server
  $grpc.ResponseFuture<$0.Ok> blockPush(
    $0.BlockPushRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$blockPush, request, options: options);
  }

  /// BlocksCheck checks is CIDs exists
  $grpc.ResponseFuture<$0.BlocksCheckResponse> blocksCheck(
    $0.BlocksCheckRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$blocksCheck, request, options: options);
  }

  /// BlocksBind binds CIDs to space
  $grpc.ResponseFuture<$0.Ok> blocksBind(
    $0.BlocksBindRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$blocksBind, request, options: options);
  }

  /// FilesDelete deletes files by id
  $grpc.ResponseFuture<$0.FilesDeleteResponse> filesDelete(
    $0.FilesDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$filesDelete, request, options: options);
  }

  /// FilesInfo return info by given files id
  $grpc.ResponseFuture<$0.FilesInfoResponse> filesInfo(
    $0.FilesInfoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$filesInfo, request, options: options);
  }

  /// FilesGet returns a stream that streams all file ids in the space
  $grpc.ResponseStream<$0.FilesGetResponse> filesGet(
    $0.FilesGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$filesGet, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Check checks the connection and credentials
  $grpc.ResponseFuture<$0.CheckResponse> check(
    $0.CheckRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$check, request, options: options);
  }

  /// SpaceInfo returns usage, limit, etc about space
  $grpc.ResponseFuture<$0.SpaceInfoResponse> spaceInfo(
    $0.SpaceInfoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spaceInfo, request, options: options);
  }

  /// AccountInfo returns usage, limit, etc by all spaces
  $grpc.ResponseFuture<$0.AccountInfoResponse> accountInfo(
    $0.AccountInfoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$accountInfo, request, options: options);
  }

  /// AccountLimitSet sets the account file storage limit (available only for nodeconf members)
  $grpc.ResponseFuture<$0.Ok> accountLimitSet(
    $0.AccountLimitSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$accountLimitSet, request, options: options);
  }

  /// SpaceLimitSet sets the space limit. Limit 0 means space will use account limits.
  $grpc.ResponseFuture<$0.Ok> spaceLimitSet(
    $0.SpaceLimitSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spaceLimitSet, request, options: options);
  }

  // method descriptors

  static final _$blockGet =
      $grpc.ClientMethod<$0.BlockGetRequest, $0.BlockGetResponse>(
          '/filesync.File/BlockGet',
          ($0.BlockGetRequest value) => value.writeToBuffer(),
          $0.BlockGetResponse.fromBuffer);
  static final _$blockPush = $grpc.ClientMethod<$0.BlockPushRequest, $0.Ok>(
      '/filesync.File/BlockPush',
      ($0.BlockPushRequest value) => value.writeToBuffer(),
      $0.Ok.fromBuffer);
  static final _$blocksCheck =
      $grpc.ClientMethod<$0.BlocksCheckRequest, $0.BlocksCheckResponse>(
          '/filesync.File/BlocksCheck',
          ($0.BlocksCheckRequest value) => value.writeToBuffer(),
          $0.BlocksCheckResponse.fromBuffer);
  static final _$blocksBind = $grpc.ClientMethod<$0.BlocksBindRequest, $0.Ok>(
      '/filesync.File/BlocksBind',
      ($0.BlocksBindRequest value) => value.writeToBuffer(),
      $0.Ok.fromBuffer);
  static final _$filesDelete =
      $grpc.ClientMethod<$0.FilesDeleteRequest, $0.FilesDeleteResponse>(
          '/filesync.File/FilesDelete',
          ($0.FilesDeleteRequest value) => value.writeToBuffer(),
          $0.FilesDeleteResponse.fromBuffer);
  static final _$filesInfo =
      $grpc.ClientMethod<$0.FilesInfoRequest, $0.FilesInfoResponse>(
          '/filesync.File/FilesInfo',
          ($0.FilesInfoRequest value) => value.writeToBuffer(),
          $0.FilesInfoResponse.fromBuffer);
  static final _$filesGet =
      $grpc.ClientMethod<$0.FilesGetRequest, $0.FilesGetResponse>(
          '/filesync.File/FilesGet',
          ($0.FilesGetRequest value) => value.writeToBuffer(),
          $0.FilesGetResponse.fromBuffer);
  static final _$check = $grpc.ClientMethod<$0.CheckRequest, $0.CheckResponse>(
      '/filesync.File/Check',
      ($0.CheckRequest value) => value.writeToBuffer(),
      $0.CheckResponse.fromBuffer);
  static final _$spaceInfo =
      $grpc.ClientMethod<$0.SpaceInfoRequest, $0.SpaceInfoResponse>(
          '/filesync.File/SpaceInfo',
          ($0.SpaceInfoRequest value) => value.writeToBuffer(),
          $0.SpaceInfoResponse.fromBuffer);
  static final _$accountInfo =
      $grpc.ClientMethod<$0.AccountInfoRequest, $0.AccountInfoResponse>(
          '/filesync.File/AccountInfo',
          ($0.AccountInfoRequest value) => value.writeToBuffer(),
          $0.AccountInfoResponse.fromBuffer);
  static final _$accountLimitSet =
      $grpc.ClientMethod<$0.AccountLimitSetRequest, $0.Ok>(
          '/filesync.File/AccountLimitSet',
          ($0.AccountLimitSetRequest value) => value.writeToBuffer(),
          $0.Ok.fromBuffer);
  static final _$spaceLimitSet =
      $grpc.ClientMethod<$0.SpaceLimitSetRequest, $0.Ok>(
          '/filesync.File/SpaceLimitSet',
          ($0.SpaceLimitSetRequest value) => value.writeToBuffer(),
          $0.Ok.fromBuffer);
}

@$pb.GrpcServiceName('filesync.File')
abstract class FileServiceBase extends $grpc.Service {
  $core.String get $name => 'filesync.File';

  FileServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.BlockGetRequest, $0.BlockGetResponse>(
        'BlockGet',
        blockGet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BlockGetRequest.fromBuffer(value),
        ($0.BlockGetResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BlockPushRequest, $0.Ok>(
        'BlockPush',
        blockPush_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BlockPushRequest.fromBuffer(value),
        ($0.Ok value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.BlocksCheckRequest, $0.BlocksCheckResponse>(
            'BlocksCheck',
            blocksCheck_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.BlocksCheckRequest.fromBuffer(value),
            ($0.BlocksCheckResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BlocksBindRequest, $0.Ok>(
        'BlocksBind',
        blocksBind_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BlocksBindRequest.fromBuffer(value),
        ($0.Ok value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.FilesDeleteRequest, $0.FilesDeleteResponse>(
            'FilesDelete',
            filesDelete_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.FilesDeleteRequest.fromBuffer(value),
            ($0.FilesDeleteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FilesInfoRequest, $0.FilesInfoResponse>(
        'FilesInfo',
        filesInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FilesInfoRequest.fromBuffer(value),
        ($0.FilesInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FilesGetRequest, $0.FilesGetResponse>(
        'FilesGet',
        filesGet_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.FilesGetRequest.fromBuffer(value),
        ($0.FilesGetResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CheckRequest, $0.CheckResponse>(
        'Check',
        check_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CheckRequest.fromBuffer(value),
        ($0.CheckResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpaceInfoRequest, $0.SpaceInfoResponse>(
        'SpaceInfo',
        spaceInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SpaceInfoRequest.fromBuffer(value),
        ($0.SpaceInfoResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AccountInfoRequest, $0.AccountInfoResponse>(
            'AccountInfo',
            accountInfo_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AccountInfoRequest.fromBuffer(value),
            ($0.AccountInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AccountLimitSetRequest, $0.Ok>(
        'AccountLimitSet',
        accountLimitSet_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AccountLimitSetRequest.fromBuffer(value),
        ($0.Ok value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpaceLimitSetRequest, $0.Ok>(
        'SpaceLimitSet',
        spaceLimitSet_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SpaceLimitSetRequest.fromBuffer(value),
        ($0.Ok value) => value.writeToBuffer()));
  }

  $async.Future<$0.BlockGetResponse> blockGet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BlockGetRequest> $request) async {
    return blockGet($call, await $request);
  }

  $async.Future<$0.BlockGetResponse> blockGet(
      $grpc.ServiceCall call, $0.BlockGetRequest request);

  $async.Future<$0.Ok> blockPush_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BlockPushRequest> $request) async {
    return blockPush($call, await $request);
  }

  $async.Future<$0.Ok> blockPush(
      $grpc.ServiceCall call, $0.BlockPushRequest request);

  $async.Future<$0.BlocksCheckResponse> blocksCheck_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BlocksCheckRequest> $request) async {
    return blocksCheck($call, await $request);
  }

  $async.Future<$0.BlocksCheckResponse> blocksCheck(
      $grpc.ServiceCall call, $0.BlocksCheckRequest request);

  $async.Future<$0.Ok> blocksBind_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BlocksBindRequest> $request) async {
    return blocksBind($call, await $request);
  }

  $async.Future<$0.Ok> blocksBind(
      $grpc.ServiceCall call, $0.BlocksBindRequest request);

  $async.Future<$0.FilesDeleteResponse> filesDelete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FilesDeleteRequest> $request) async {
    return filesDelete($call, await $request);
  }

  $async.Future<$0.FilesDeleteResponse> filesDelete(
      $grpc.ServiceCall call, $0.FilesDeleteRequest request);

  $async.Future<$0.FilesInfoResponse> filesInfo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FilesInfoRequest> $request) async {
    return filesInfo($call, await $request);
  }

  $async.Future<$0.FilesInfoResponse> filesInfo(
      $grpc.ServiceCall call, $0.FilesInfoRequest request);

  $async.Stream<$0.FilesGetResponse> filesGet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FilesGetRequest> $request) async* {
    yield* filesGet($call, await $request);
  }

  $async.Stream<$0.FilesGetResponse> filesGet(
      $grpc.ServiceCall call, $0.FilesGetRequest request);

  $async.Future<$0.CheckResponse> check_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.CheckRequest> $request) async {
    return check($call, await $request);
  }

  $async.Future<$0.CheckResponse> check(
      $grpc.ServiceCall call, $0.CheckRequest request);

  $async.Future<$0.SpaceInfoResponse> spaceInfo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SpaceInfoRequest> $request) async {
    return spaceInfo($call, await $request);
  }

  $async.Future<$0.SpaceInfoResponse> spaceInfo(
      $grpc.ServiceCall call, $0.SpaceInfoRequest request);

  $async.Future<$0.AccountInfoResponse> accountInfo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AccountInfoRequest> $request) async {
    return accountInfo($call, await $request);
  }

  $async.Future<$0.AccountInfoResponse> accountInfo(
      $grpc.ServiceCall call, $0.AccountInfoRequest request);

  $async.Future<$0.Ok> accountLimitSet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AccountLimitSetRequest> $request) async {
    return accountLimitSet($call, await $request);
  }

  $async.Future<$0.Ok> accountLimitSet(
      $grpc.ServiceCall call, $0.AccountLimitSetRequest request);

  $async.Future<$0.Ok> spaceLimitSet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SpaceLimitSetRequest> $request) async {
    return spaceLimitSet($call, await $request);
  }

  $async.Future<$0.Ok> spaceLimitSet(
      $grpc.ServiceCall call, $0.SpaceLimitSetRequest request);
}
