import 'dart:async';

import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/coordinator_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_cli/src/session.dart';

/// Unlike `SpaceDelete`'s `SpaceStatusCheck` reread, `AccountDelete` has no
/// per-account status RPC, and `DeletionLog` records are scoped by
/// `space_id`, not account identity (see `DeletionLogRecord` in
/// `coordinator.proto`): so a positive `AccountDeleteResponse` alone cannot
/// be independently reread and confirmed the way `SpaceDelete` can.
///
/// The official self-hosted oracle does expose one observable, replayable
/// signal for this RPC, though: a second `AccountDelete` call for an
/// already-deleted account is rejected with "account is deleted"
/// (`test_vectors/phase50/oracle_account_delete.json`). `manytype_server`
/// now mirrors this idempotency contract (see `handle_account_delete` in
/// `rust/manytype_server/src/coordinator.rs`), so this command issues a
/// second `AccountDelete` call for the same identity immediately after the
/// first succeeds, and accepts the bounded contract only if that second call
/// is independently rejected on the same grounds.
const String kAccountDeleteVerificationCaveat =
    'AccountDelete has no reread/status-check RPC analogous to SpaceStatusCheck, '
    'and DeletionLog records are space-scoped, not account-scoped, so a '
    'single response cannot be independently verified. Acceptance instead '
    'requires a second AccountDelete call for the same identity to be '
    'rejected with "account is deleted": the one observable, replayable '
    'signal the official any-sync coordinator exposes for this RPC.';

class AccountDeleteAssessment {
  const AccountDeleteAssessment({
    required this.outcome,
    required this.supported,
    required this.observedSurfaceLabel,
    required this.reason,
  });

  final String outcome;
  final bool supported;
  final String observedSurfaceLabel;
  final String reason;

  Map<String, Object?> toJson() => {
        'outcome': outcome,
        'supported': supported,
        'observed_surface_label': observedSurfaceLabel,
        'reason': reason,
      };
}

/// [secondCallOk]/[secondCallError] describe a second `AccountDelete` call
/// issued for the same identity immediately after the first succeeded. This
/// is the only independently-observable signal any-sync exposes for account
/// deletion: see [kAccountDeleteVerificationCaveat].
AccountDeleteAssessment assessAccountDeleteContract({
  required bool responseOk,
  required String? responseError,
  bool? secondCallOk,
  String? secondCallError,
}) {
  if (!responseOk) {
    return AccountDeleteAssessment(
      outcome: 'unsupported-surface-or-scenario',
      supported: false,
      observedSurfaceLabel: 'request-rejected',
      reason:
          'AccountDelete request failed: ${responseError ?? 'unknown error'}.',
    );
  }

  final rejectedAsDeleted = secondCallOk == false &&
      (secondCallError?.toLowerCase().contains('account is deleted') ?? false);
  if (rejectedAsDeleted) {
    return const AccountDeleteAssessment(
      outcome: 'supported-and-verified',
      supported: true,
      observedSurfaceLabel: 'accepted-account-delete-idempotency-surface',
      reason:
          'The first AccountDelete request succeeded. A second request '
          'for the same identity was rejected with "account is '
          'deleted", confirming the expected response to a repeated '
          'AccountDelete request.',
    );
  }

  return AccountDeleteAssessment(
    outcome: 'unsupported-surface-or-scenario',
    supported: false,
    observedSurfaceLabel: 'response-succeeded-but-unverifiable',
    reason: 'The delete request returned ok, but the repeat-call idempotency '
        'check did not confirm deletion (secondCallOk: $secondCallOk, '
        'secondCallError: ${secondCallError ?? 'none'}). '
        '$kAccountDeleteVerificationCaveat',
  );
}

/// Structured report produced by [accountDeleteCommand]. `toJson()` matches
/// the `--json` CLI output shape.
class AccountDeleteReport {
  const AccountDeleteReport({
    required this.capturedAt,
    required this.assessment,
    this.networkConfigPath,
    this.networkConfigContent,
    required this.coordinatorAddress,
    required this.response,
    required this.secondResponse,
  });

  final DateTime capturedAt;
  final AccountDeleteAssessment assessment;
  final String? networkConfigPath;
  final String? networkConfigContent;
  final String coordinatorAddress;
  final Map<String, Object?> response;

  /// Result of the immediate second `AccountDelete` call for the same
  /// identity, used to prove idempotency: see [kAccountDeleteVerificationCaveat].
  final Map<String, Object?> secondResponse;

  Map<String, Object?> toJson() => {
        'captured_at': capturedAt.toIso8601String(),
        'command': 'account-delete',
        'verification_caveat': kAccountDeleteVerificationCaveat,
        'assessment': assessment.toJson(),
        'network_config_path': networkConfigPath,
        'coordinator_address': coordinatorAddress,
        'response': response,
        'second_response': secondResponse,
      };
}

Future<AccountDeleteReport> accountDeleteCommand({
  required CliConfig config,
  String? networkConfigPath,
  String? networkConfigContent,
}) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final networkConfig = await resolveNetworkConfig(
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
  );
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);

  final bridge = NativeBridge();
  final handleId =
      bridge.connect(coordinatorAddress, identity.seed, identity.accountSeed);
  final coordinator = CoordinatorService(invoker: bridge.invoke);

  Map<String, Object?> responseJson;
  bool responseOk;
  String? responseError;
  Map<String, Object?> secondResponseJson;
  bool? secondResponseOk;
  String? secondResponseError;
  try {
    final networkConfiguration =
        coordinator.networkConfigurationForHandle(handleId);
    try {
      final response = await coordinator.accountDelete(
        handleId: handleId,
        identity: identity,
        networkId: networkConfiguration.networkId,
      );
      responseOk = true;
      responseError = null;
      responseJson = {
        'ok': true,
        'value': {
          'to_be_deleted_timestamp': response.toBeDeletedTimestamp.toInt(),
        },
      };
    } catch (error) {
      responseOk = false;
      responseError = error.toString();
      responseJson = {
        'ok': false,
        'error': responseError,
      };
    }

    if (responseOk) {
      // Immediately repeat the call for the same identity: this is the one
      // observable, replayable signal any-sync exposes for AccountDelete
      // (see kAccountDeleteVerificationCaveat).
      try {
        final secondResponse = await coordinator.accountDelete(
          handleId: handleId,
          identity: identity,
          networkId: networkConfiguration.networkId,
        );
        secondResponseOk = true;
        secondResponseError = null;
        secondResponseJson = {
          'ok': true,
          'value': {
            'to_be_deleted_timestamp':
                secondResponse.toBeDeletedTimestamp.toInt(),
          },
        };
      } catch (error) {
        secondResponseOk = false;
        secondResponseError = error.toString();
        secondResponseJson = {
          'ok': false,
          'error': secondResponseError,
        };
      }
    } else {
      secondResponseOk = null;
      secondResponseError = null;
      secondResponseJson = {
        'ok': null,
        'skipped': 'first call did not succeed'
      };
    }
  } finally {
    bridge.freeHandle(handleId);
  }

  final assessment = assessAccountDeleteContract(
    responseOk: responseOk,
    responseError: responseError,
    secondCallOk: secondResponseOk,
    secondCallError: secondResponseError,
  );

  return AccountDeleteReport(
    capturedAt: DateTime.now().toUtc(),
    assessment: assessment,
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
    coordinatorAddress: coordinatorAddress,
    response: responseJson,
    secondResponse: secondResponseJson,
  );
}

/// Library-facing facade over the protocol-level `AccountDelete` probe, for
/// consumers that hold a [ManytypeSession] instead of driving the CLI
/// directly. Exposed as `session.accountDelete`: distinct from
/// `session.accounts.remove`, which only deletes the local account profile
/// (config + db) and never calls the coordinator.
class AccountDeleteFacade {
  const AccountDeleteFacade(this._session);

  final ManytypeSession _session;

  Future<AccountDeleteReport> run({
    String? networkConfigPath,
    String? networkConfigContent,
  }) {
    return accountDeleteCommand(
      config: _session.config,
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
    );
  }
}
