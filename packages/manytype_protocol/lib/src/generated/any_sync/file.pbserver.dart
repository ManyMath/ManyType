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

import 'package:protobuf/protobuf.dart' as $pb;

import 'file.pb.dart' as $0;
import 'file.pbjson.dart';

export 'file.pb.dart';

abstract class FileServiceBase extends $pb.GeneratedService {
  $async.Future<$0.BlockGetResponse> blockGet(
      $pb.ServerContext ctx, $0.BlockGetRequest request);
  $async.Future<$0.Ok> blockPush(
      $pb.ServerContext ctx, $0.BlockPushRequest request);
  $async.Future<$0.BlocksCheckResponse> blocksCheck(
      $pb.ServerContext ctx, $0.BlocksCheckRequest request);
  $async.Future<$0.Ok> blocksBind(
      $pb.ServerContext ctx, $0.BlocksBindRequest request);
  $async.Future<$0.FilesDeleteResponse> filesDelete(
      $pb.ServerContext ctx, $0.FilesDeleteRequest request);
  $async.Future<$0.FilesInfoResponse> filesInfo(
      $pb.ServerContext ctx, $0.FilesInfoRequest request);
  $async.Future<$0.FilesGetResponse> filesGet(
      $pb.ServerContext ctx, $0.FilesGetRequest request);
  $async.Future<$0.CheckResponse> check(
      $pb.ServerContext ctx, $0.CheckRequest request);
  $async.Future<$0.SpaceInfoResponse> spaceInfo(
      $pb.ServerContext ctx, $0.SpaceInfoRequest request);
  $async.Future<$0.AccountInfoResponse> accountInfo(
      $pb.ServerContext ctx, $0.AccountInfoRequest request);
  $async.Future<$0.Ok> accountLimitSet(
      $pb.ServerContext ctx, $0.AccountLimitSetRequest request);
  $async.Future<$0.Ok> spaceLimitSet(
      $pb.ServerContext ctx, $0.SpaceLimitSetRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'BlockGet':
        return $0.BlockGetRequest();
      case 'BlockPush':
        return $0.BlockPushRequest();
      case 'BlocksCheck':
        return $0.BlocksCheckRequest();
      case 'BlocksBind':
        return $0.BlocksBindRequest();
      case 'FilesDelete':
        return $0.FilesDeleteRequest();
      case 'FilesInfo':
        return $0.FilesInfoRequest();
      case 'FilesGet':
        return $0.FilesGetRequest();
      case 'Check':
        return $0.CheckRequest();
      case 'SpaceInfo':
        return $0.SpaceInfoRequest();
      case 'AccountInfo':
        return $0.AccountInfoRequest();
      case 'AccountLimitSet':
        return $0.AccountLimitSetRequest();
      case 'SpaceLimitSet':
        return $0.SpaceLimitSetRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'BlockGet':
        return blockGet(ctx, request as $0.BlockGetRequest);
      case 'BlockPush':
        return blockPush(ctx, request as $0.BlockPushRequest);
      case 'BlocksCheck':
        return blocksCheck(ctx, request as $0.BlocksCheckRequest);
      case 'BlocksBind':
        return blocksBind(ctx, request as $0.BlocksBindRequest);
      case 'FilesDelete':
        return filesDelete(ctx, request as $0.FilesDeleteRequest);
      case 'FilesInfo':
        return filesInfo(ctx, request as $0.FilesInfoRequest);
      case 'FilesGet':
        return filesGet(ctx, request as $0.FilesGetRequest);
      case 'Check':
        return check(ctx, request as $0.CheckRequest);
      case 'SpaceInfo':
        return spaceInfo(ctx, request as $0.SpaceInfoRequest);
      case 'AccountInfo':
        return accountInfo(ctx, request as $0.AccountInfoRequest);
      case 'AccountLimitSet':
        return accountLimitSet(ctx, request as $0.AccountLimitSetRequest);
      case 'SpaceLimitSet':
        return spaceLimitSet(ctx, request as $0.SpaceLimitSetRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => FileServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => FileServiceBase$messageJson;
}
