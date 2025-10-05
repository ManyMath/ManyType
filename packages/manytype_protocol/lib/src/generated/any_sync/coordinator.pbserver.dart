// This is a generated file - do not edit.
//
// Generated from any_sync/coordinator.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'coordinator.pb.dart' as $0;
import 'coordinator.pbjson.dart';

export 'coordinator.pb.dart';

abstract class CoordinatorServiceBase extends $pb.GeneratedService {
  $async.Future<$0.SpaceSignResponse> spaceSign(
      $pb.ServerContext ctx, $0.SpaceSignRequest request);
  $async.Future<$0.SpaceStatusCheckResponse> spaceStatusCheck(
      $pb.ServerContext ctx, $0.SpaceStatusCheckRequest request);
  $async.Future<$0.SpaceStatusCheckManyResponse> spaceStatusCheckMany(
      $pb.ServerContext ctx, $0.SpaceStatusCheckManyRequest request);
  $async.Future<$0.SpaceStatusChangeResponse> spaceStatusChange(
      $pb.ServerContext ctx, $0.SpaceStatusChangeRequest request);
  $async.Future<$0.SpaceMakeShareableResponse> spaceMakeShareable(
      $pb.ServerContext ctx, $0.SpaceMakeShareableRequest request);
  $async.Future<$0.SpaceMakeUnshareableResponse> spaceMakeUnshareable(
      $pb.ServerContext ctx, $0.SpaceMakeUnshareableRequest request);
  $async.Future<$0.NetworkConfigurationResponse> networkConfiguration(
      $pb.ServerContext ctx, $0.NetworkConfigurationRequest request);
  $async.Future<$0.DeletionLogResponse> deletionLog(
      $pb.ServerContext ctx, $0.DeletionLogRequest request);
  $async.Future<$0.SpaceDeleteResponse> spaceDelete(
      $pb.ServerContext ctx, $0.SpaceDeleteRequest request);
  $async.Future<$0.AccountDeleteResponse> accountDelete(
      $pb.ServerContext ctx, $0.AccountDeleteRequest request);
  $async.Future<$0.AccountRevertDeletionResponse> accountRevertDeletion(
      $pb.ServerContext ctx, $0.AccountRevertDeletionRequest request);
  $async.Future<$0.AclAddRecordResponse> aclAddRecord(
      $pb.ServerContext ctx, $0.AclAddRecordRequest request);
  $async.Future<$0.AclGetRecordsResponse> aclGetRecords(
      $pb.ServerContext ctx, $0.AclGetRecordsRequest request);
  $async.Future<$0.AccountLimitsSetResponse> accountLimitsSet(
      $pb.ServerContext ctx, $0.AccountLimitsSetRequest request);
  $async.Future<$0.AclEventLogResponse> aclEventLog(
      $pb.ServerContext ctx, $0.AclEventLogRequest request);
  $async.Future<$0.AclUploadInviteResponse> aclUploadInvite(
      $pb.ServerContext ctx, $0.AclUploadInviteRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SpaceSign':
        return $0.SpaceSignRequest();
      case 'SpaceStatusCheck':
        return $0.SpaceStatusCheckRequest();
      case 'SpaceStatusCheckMany':
        return $0.SpaceStatusCheckManyRequest();
      case 'SpaceStatusChange':
        return $0.SpaceStatusChangeRequest();
      case 'SpaceMakeShareable':
        return $0.SpaceMakeShareableRequest();
      case 'SpaceMakeUnshareable':
        return $0.SpaceMakeUnshareableRequest();
      case 'NetworkConfiguration':
        return $0.NetworkConfigurationRequest();
      case 'DeletionLog':
        return $0.DeletionLogRequest();
      case 'SpaceDelete':
        return $0.SpaceDeleteRequest();
      case 'AccountDelete':
        return $0.AccountDeleteRequest();
      case 'AccountRevertDeletion':
        return $0.AccountRevertDeletionRequest();
      case 'AclAddRecord':
        return $0.AclAddRecordRequest();
      case 'AclGetRecords':
        return $0.AclGetRecordsRequest();
      case 'AccountLimitsSet':
        return $0.AccountLimitsSetRequest();
      case 'AclEventLog':
        return $0.AclEventLogRequest();
      case 'AclUploadInvite':
        return $0.AclUploadInviteRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SpaceSign':
        return spaceSign(ctx, request as $0.SpaceSignRequest);
      case 'SpaceStatusCheck':
        return spaceStatusCheck(ctx, request as $0.SpaceStatusCheckRequest);
      case 'SpaceStatusCheckMany':
        return spaceStatusCheckMany(
            ctx, request as $0.SpaceStatusCheckManyRequest);
      case 'SpaceStatusChange':
        return spaceStatusChange(ctx, request as $0.SpaceStatusChangeRequest);
      case 'SpaceMakeShareable':
        return spaceMakeShareable(ctx, request as $0.SpaceMakeShareableRequest);
      case 'SpaceMakeUnshareable':
        return spaceMakeUnshareable(
            ctx, request as $0.SpaceMakeUnshareableRequest);
      case 'NetworkConfiguration':
        return networkConfiguration(
            ctx, request as $0.NetworkConfigurationRequest);
      case 'DeletionLog':
        return deletionLog(ctx, request as $0.DeletionLogRequest);
      case 'SpaceDelete':
        return spaceDelete(ctx, request as $0.SpaceDeleteRequest);
      case 'AccountDelete':
        return accountDelete(ctx, request as $0.AccountDeleteRequest);
      case 'AccountRevertDeletion':
        return accountRevertDeletion(
            ctx, request as $0.AccountRevertDeletionRequest);
      case 'AclAddRecord':
        return aclAddRecord(ctx, request as $0.AclAddRecordRequest);
      case 'AclGetRecords':
        return aclGetRecords(ctx, request as $0.AclGetRecordsRequest);
      case 'AccountLimitsSet':
        return accountLimitsSet(ctx, request as $0.AccountLimitsSetRequest);
      case 'AclEventLog':
        return aclEventLog(ctx, request as $0.AclEventLogRequest);
      case 'AclUploadInvite':
        return aclUploadInvite(ctx, request as $0.AclUploadInviteRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      CoordinatorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => CoordinatorServiceBase$messageJson;
}
