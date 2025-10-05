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

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'coordinator.pb.dart' as $0;

export 'coordinator.pb.dart';

@$pb.GrpcServiceName('coordinator.Coordinator')
class CoordinatorClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  CoordinatorClient(super.channel, {super.options, super.interceptors});

  /// SpaceSign signs a space creation operation
  $grpc.ResponseFuture<$0.SpaceSignResponse> spaceSign(
    $0.SpaceSignRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spaceSign, request, options: options);
  }

  /// SpaceStatusCheck checks the status of space and tells if it is deleted or not
  $grpc.ResponseFuture<$0.SpaceStatusCheckResponse> spaceStatusCheck(
    $0.SpaceStatusCheckRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spaceStatusCheck, request, options: options);
  }

  /// SpaceStatusCheckMany checks the statuses of spaces and tells if they are deleted or not
  $grpc.ResponseFuture<$0.SpaceStatusCheckManyResponse> spaceStatusCheckMany(
    $0.SpaceStatusCheckManyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spaceStatusCheckMany, request, options: options);
  }

  /// SpaceStatusChange changes the status of space - Deprecated
  $grpc.ResponseFuture<$0.SpaceStatusChangeResponse> spaceStatusChange(
    $0.SpaceStatusChangeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spaceStatusChange, request, options: options);
  }

  /// SpaceMakeShareable makes space shareable
  $grpc.ResponseFuture<$0.SpaceMakeShareableResponse> spaceMakeShareable(
    $0.SpaceMakeShareableRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spaceMakeShareable, request, options: options);
  }

  /// SpaceMakeUnshareable marks space unshareable
  $grpc.ResponseFuture<$0.SpaceMakeUnshareableResponse> spaceMakeUnshareable(
    $0.SpaceMakeUnshareableRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spaceMakeUnshareable, request, options: options);
  }

  /// NetworkConfiguration retrieves the latest network configuration
  $grpc.ResponseFuture<$0.NetworkConfigurationResponse> networkConfiguration(
    $0.NetworkConfigurationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$networkConfiguration, request, options: options);
  }

  /// DeletionLog gets the latest deletion log records
  $grpc.ResponseFuture<$0.DeletionLogResponse> deletionLog(
    $0.DeletionLogRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deletionLog, request, options: options);
  }

  /// SpaceDelete deletes a space
  $grpc.ResponseFuture<$0.SpaceDeleteResponse> spaceDelete(
    $0.SpaceDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$spaceDelete, request, options: options);
  }

  /// AccountDelete deletes an account
  $grpc.ResponseFuture<$0.AccountDeleteResponse> accountDelete(
    $0.AccountDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$accountDelete, request, options: options);
  }

  /// AccountRevertDeletion reverts an account deletion
  $grpc.ResponseFuture<$0.AccountRevertDeletionResponse> accountRevertDeletion(
    $0.AccountRevertDeletionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$accountRevertDeletion, request, options: options);
  }

  /// AclAddRecord adds a new record to acl log. Works only with any-sync-node
  $grpc.ResponseFuture<$0.AclAddRecordResponse> aclAddRecord(
    $0.AclAddRecordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$aclAddRecord, request, options: options);
  }

  /// AclGetRecords gets acl records
  $grpc.ResponseFuture<$0.AclGetRecordsResponse> aclGetRecords(
    $0.AclGetRecordsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$aclGetRecords, request, options: options);
  }

  /// AccountLimitsSet sets limits to the account. Can be used only by a network config member
  $grpc.ResponseFuture<$0.AccountLimitsSetResponse> accountLimitsSet(
    $0.AccountLimitsSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$accountLimitsSet, request, options: options);
  }

  /// EventLog gets the latest event log records
  $grpc.ResponseFuture<$0.AclEventLogResponse> aclEventLog(
    $0.AclEventLogRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$aclEventLog, request, options: options);
  }

  /// AclUploadInvite uploads invite binary data to the filenodes
  $grpc.ResponseFuture<$0.AclUploadInviteResponse> aclUploadInvite(
    $0.AclUploadInviteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$aclUploadInvite, request, options: options);
  }

  // method descriptors

  static final _$spaceSign =
      $grpc.ClientMethod<$0.SpaceSignRequest, $0.SpaceSignResponse>(
          '/coordinator.Coordinator/SpaceSign',
          ($0.SpaceSignRequest value) => value.writeToBuffer(),
          $0.SpaceSignResponse.fromBuffer);
  static final _$spaceStatusCheck = $grpc.ClientMethod<
          $0.SpaceStatusCheckRequest, $0.SpaceStatusCheckResponse>(
      '/coordinator.Coordinator/SpaceStatusCheck',
      ($0.SpaceStatusCheckRequest value) => value.writeToBuffer(),
      $0.SpaceStatusCheckResponse.fromBuffer);
  static final _$spaceStatusCheckMany = $grpc.ClientMethod<
          $0.SpaceStatusCheckManyRequest, $0.SpaceStatusCheckManyResponse>(
      '/coordinator.Coordinator/SpaceStatusCheckMany',
      ($0.SpaceStatusCheckManyRequest value) => value.writeToBuffer(),
      $0.SpaceStatusCheckManyResponse.fromBuffer);
  static final _$spaceStatusChange = $grpc.ClientMethod<
          $0.SpaceStatusChangeRequest, $0.SpaceStatusChangeResponse>(
      '/coordinator.Coordinator/SpaceStatusChange',
      ($0.SpaceStatusChangeRequest value) => value.writeToBuffer(),
      $0.SpaceStatusChangeResponse.fromBuffer);
  static final _$spaceMakeShareable = $grpc.ClientMethod<
          $0.SpaceMakeShareableRequest, $0.SpaceMakeShareableResponse>(
      '/coordinator.Coordinator/SpaceMakeShareable',
      ($0.SpaceMakeShareableRequest value) => value.writeToBuffer(),
      $0.SpaceMakeShareableResponse.fromBuffer);
  static final _$spaceMakeUnshareable = $grpc.ClientMethod<
          $0.SpaceMakeUnshareableRequest, $0.SpaceMakeUnshareableResponse>(
      '/coordinator.Coordinator/SpaceMakeUnshareable',
      ($0.SpaceMakeUnshareableRequest value) => value.writeToBuffer(),
      $0.SpaceMakeUnshareableResponse.fromBuffer);
  static final _$networkConfiguration = $grpc.ClientMethod<
          $0.NetworkConfigurationRequest, $0.NetworkConfigurationResponse>(
      '/coordinator.Coordinator/NetworkConfiguration',
      ($0.NetworkConfigurationRequest value) => value.writeToBuffer(),
      $0.NetworkConfigurationResponse.fromBuffer);
  static final _$deletionLog =
      $grpc.ClientMethod<$0.DeletionLogRequest, $0.DeletionLogResponse>(
          '/coordinator.Coordinator/DeletionLog',
          ($0.DeletionLogRequest value) => value.writeToBuffer(),
          $0.DeletionLogResponse.fromBuffer);
  static final _$spaceDelete =
      $grpc.ClientMethod<$0.SpaceDeleteRequest, $0.SpaceDeleteResponse>(
          '/coordinator.Coordinator/SpaceDelete',
          ($0.SpaceDeleteRequest value) => value.writeToBuffer(),
          $0.SpaceDeleteResponse.fromBuffer);
  static final _$accountDelete =
      $grpc.ClientMethod<$0.AccountDeleteRequest, $0.AccountDeleteResponse>(
          '/coordinator.Coordinator/AccountDelete',
          ($0.AccountDeleteRequest value) => value.writeToBuffer(),
          $0.AccountDeleteResponse.fromBuffer);
  static final _$accountRevertDeletion = $grpc.ClientMethod<
          $0.AccountRevertDeletionRequest, $0.AccountRevertDeletionResponse>(
      '/coordinator.Coordinator/AccountRevertDeletion',
      ($0.AccountRevertDeletionRequest value) => value.writeToBuffer(),
      $0.AccountRevertDeletionResponse.fromBuffer);
  static final _$aclAddRecord =
      $grpc.ClientMethod<$0.AclAddRecordRequest, $0.AclAddRecordResponse>(
          '/coordinator.Coordinator/AclAddRecord',
          ($0.AclAddRecordRequest value) => value.writeToBuffer(),
          $0.AclAddRecordResponse.fromBuffer);
  static final _$aclGetRecords =
      $grpc.ClientMethod<$0.AclGetRecordsRequest, $0.AclGetRecordsResponse>(
          '/coordinator.Coordinator/AclGetRecords',
          ($0.AclGetRecordsRequest value) => value.writeToBuffer(),
          $0.AclGetRecordsResponse.fromBuffer);
  static final _$accountLimitsSet = $grpc.ClientMethod<
          $0.AccountLimitsSetRequest, $0.AccountLimitsSetResponse>(
      '/coordinator.Coordinator/AccountLimitsSet',
      ($0.AccountLimitsSetRequest value) => value.writeToBuffer(),
      $0.AccountLimitsSetResponse.fromBuffer);
  static final _$aclEventLog =
      $grpc.ClientMethod<$0.AclEventLogRequest, $0.AclEventLogResponse>(
          '/coordinator.Coordinator/AclEventLog',
          ($0.AclEventLogRequest value) => value.writeToBuffer(),
          $0.AclEventLogResponse.fromBuffer);
  static final _$aclUploadInvite =
      $grpc.ClientMethod<$0.AclUploadInviteRequest, $0.AclUploadInviteResponse>(
          '/coordinator.Coordinator/AclUploadInvite',
          ($0.AclUploadInviteRequest value) => value.writeToBuffer(),
          $0.AclUploadInviteResponse.fromBuffer);
}

@$pb.GrpcServiceName('coordinator.Coordinator')
abstract class CoordinatorServiceBase extends $grpc.Service {
  $core.String get $name => 'coordinator.Coordinator';

  CoordinatorServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SpaceSignRequest, $0.SpaceSignResponse>(
        'SpaceSign',
        spaceSign_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SpaceSignRequest.fromBuffer(value),
        ($0.SpaceSignResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpaceStatusCheckRequest,
            $0.SpaceStatusCheckResponse>(
        'SpaceStatusCheck',
        spaceStatusCheck_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SpaceStatusCheckRequest.fromBuffer(value),
        ($0.SpaceStatusCheckResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpaceStatusCheckManyRequest,
            $0.SpaceStatusCheckManyResponse>(
        'SpaceStatusCheckMany',
        spaceStatusCheckMany_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SpaceStatusCheckManyRequest.fromBuffer(value),
        ($0.SpaceStatusCheckManyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpaceStatusChangeRequest,
            $0.SpaceStatusChangeResponse>(
        'SpaceStatusChange',
        spaceStatusChange_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SpaceStatusChangeRequest.fromBuffer(value),
        ($0.SpaceStatusChangeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpaceMakeShareableRequest,
            $0.SpaceMakeShareableResponse>(
        'SpaceMakeShareable',
        spaceMakeShareable_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SpaceMakeShareableRequest.fromBuffer(value),
        ($0.SpaceMakeShareableResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpaceMakeUnshareableRequest,
            $0.SpaceMakeUnshareableResponse>(
        'SpaceMakeUnshareable',
        spaceMakeUnshareable_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SpaceMakeUnshareableRequest.fromBuffer(value),
        ($0.SpaceMakeUnshareableResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.NetworkConfigurationRequest,
            $0.NetworkConfigurationResponse>(
        'NetworkConfiguration',
        networkConfiguration_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.NetworkConfigurationRequest.fromBuffer(value),
        ($0.NetworkConfigurationResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeletionLogRequest, $0.DeletionLogResponse>(
            'DeletionLog',
            deletionLog_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeletionLogRequest.fromBuffer(value),
            ($0.DeletionLogResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SpaceDeleteRequest, $0.SpaceDeleteResponse>(
            'SpaceDelete',
            spaceDelete_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SpaceDeleteRequest.fromBuffer(value),
            ($0.SpaceDeleteResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AccountDeleteRequest, $0.AccountDeleteResponse>(
            'AccountDelete',
            accountDelete_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AccountDeleteRequest.fromBuffer(value),
            ($0.AccountDeleteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AccountRevertDeletionRequest,
            $0.AccountRevertDeletionResponse>(
        'AccountRevertDeletion',
        accountRevertDeletion_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AccountRevertDeletionRequest.fromBuffer(value),
        ($0.AccountRevertDeletionResponse value) => value.writeToBuffer()));
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
    $addMethod($grpc.ServiceMethod<$0.AccountLimitsSetRequest,
            $0.AccountLimitsSetResponse>(
        'AccountLimitsSet',
        accountLimitsSet_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AccountLimitsSetRequest.fromBuffer(value),
        ($0.AccountLimitsSetResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AclEventLogRequest, $0.AclEventLogResponse>(
            'AclEventLog',
            aclEventLog_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AclEventLogRequest.fromBuffer(value),
            ($0.AclEventLogResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AclUploadInviteRequest,
            $0.AclUploadInviteResponse>(
        'AclUploadInvite',
        aclUploadInvite_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AclUploadInviteRequest.fromBuffer(value),
        ($0.AclUploadInviteResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.SpaceSignResponse> spaceSign_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SpaceSignRequest> $request) async {
    return spaceSign($call, await $request);
  }

  $async.Future<$0.SpaceSignResponse> spaceSign(
      $grpc.ServiceCall call, $0.SpaceSignRequest request);

  $async.Future<$0.SpaceStatusCheckResponse> spaceStatusCheck_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SpaceStatusCheckRequest> $request) async {
    return spaceStatusCheck($call, await $request);
  }

  $async.Future<$0.SpaceStatusCheckResponse> spaceStatusCheck(
      $grpc.ServiceCall call, $0.SpaceStatusCheckRequest request);

  $async.Future<$0.SpaceStatusCheckManyResponse> spaceStatusCheckMany_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SpaceStatusCheckManyRequest> $request) async {
    return spaceStatusCheckMany($call, await $request);
  }

  $async.Future<$0.SpaceStatusCheckManyResponse> spaceStatusCheckMany(
      $grpc.ServiceCall call, $0.SpaceStatusCheckManyRequest request);

  $async.Future<$0.SpaceStatusChangeResponse> spaceStatusChange_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SpaceStatusChangeRequest> $request) async {
    return spaceStatusChange($call, await $request);
  }

  $async.Future<$0.SpaceStatusChangeResponse> spaceStatusChange(
      $grpc.ServiceCall call, $0.SpaceStatusChangeRequest request);

  $async.Future<$0.SpaceMakeShareableResponse> spaceMakeShareable_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SpaceMakeShareableRequest> $request) async {
    return spaceMakeShareable($call, await $request);
  }

  $async.Future<$0.SpaceMakeShareableResponse> spaceMakeShareable(
      $grpc.ServiceCall call, $0.SpaceMakeShareableRequest request);

  $async.Future<$0.SpaceMakeUnshareableResponse> spaceMakeUnshareable_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SpaceMakeUnshareableRequest> $request) async {
    return spaceMakeUnshareable($call, await $request);
  }

  $async.Future<$0.SpaceMakeUnshareableResponse> spaceMakeUnshareable(
      $grpc.ServiceCall call, $0.SpaceMakeUnshareableRequest request);

  $async.Future<$0.NetworkConfigurationResponse> networkConfiguration_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.NetworkConfigurationRequest> $request) async {
    return networkConfiguration($call, await $request);
  }

  $async.Future<$0.NetworkConfigurationResponse> networkConfiguration(
      $grpc.ServiceCall call, $0.NetworkConfigurationRequest request);

  $async.Future<$0.DeletionLogResponse> deletionLog_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeletionLogRequest> $request) async {
    return deletionLog($call, await $request);
  }

  $async.Future<$0.DeletionLogResponse> deletionLog(
      $grpc.ServiceCall call, $0.DeletionLogRequest request);

  $async.Future<$0.SpaceDeleteResponse> spaceDelete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SpaceDeleteRequest> $request) async {
    return spaceDelete($call, await $request);
  }

  $async.Future<$0.SpaceDeleteResponse> spaceDelete(
      $grpc.ServiceCall call, $0.SpaceDeleteRequest request);

  $async.Future<$0.AccountDeleteResponse> accountDelete_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AccountDeleteRequest> $request) async {
    return accountDelete($call, await $request);
  }

  $async.Future<$0.AccountDeleteResponse> accountDelete(
      $grpc.ServiceCall call, $0.AccountDeleteRequest request);

  $async.Future<$0.AccountRevertDeletionResponse> accountRevertDeletion_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AccountRevertDeletionRequest> $request) async {
    return accountRevertDeletion($call, await $request);
  }

  $async.Future<$0.AccountRevertDeletionResponse> accountRevertDeletion(
      $grpc.ServiceCall call, $0.AccountRevertDeletionRequest request);

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

  $async.Future<$0.AccountLimitsSetResponse> accountLimitsSet_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AccountLimitsSetRequest> $request) async {
    return accountLimitsSet($call, await $request);
  }

  $async.Future<$0.AccountLimitsSetResponse> accountLimitsSet(
      $grpc.ServiceCall call, $0.AccountLimitsSetRequest request);

  $async.Future<$0.AclEventLogResponse> aclEventLog_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AclEventLogRequest> $request) async {
    return aclEventLog($call, await $request);
  }

  $async.Future<$0.AclEventLogResponse> aclEventLog(
      $grpc.ServiceCall call, $0.AclEventLogRequest request);

  $async.Future<$0.AclUploadInviteResponse> aclUploadInvite_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AclUploadInviteRequest> $request) async {
    return aclUploadInvite($call, await $request);
  }

  $async.Future<$0.AclUploadInviteResponse> aclUploadInvite(
      $grpc.ServiceCall call, $0.AclUploadInviteRequest request);
}
