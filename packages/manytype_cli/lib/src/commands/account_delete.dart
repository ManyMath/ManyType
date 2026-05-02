import 'dart:async';

import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/coordinator_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_cli/src/session.dart';

/// Unlike `SpaceDelete`'s `SpaceStatusCheck` reread, `AccountDelete`
/// has no per-account status RPC, and `DeletionLog` records are scoped by
/// `space_id`, not account identity (see `DeletionLogRecord` in
/// `coordinator.proto`) — so a positive `AccountDeleteResponse` cannot be
/// independently reread and confirmed the way `SpaceDelete` can. Phase 50
/// evidence backs this up: the `manytype_server` stub surface returns
/// `ok: true` with a positive timestamp yet never changes any observable
/// state, so response success alone is known to be an unreliable signal.
/// Until a bounded, replayable acceptance path is captured, this command
/// can only ever report `unsupported-surface-or-scenario`.
const String kAccountDeleteVerificationCaveat =
    'AccountDelete has no reread/status-check RPC analogous to SpaceStatusCheck, '
    'and DeletionLog records are space-scoped, not account-scoped, so a '
    'response cannot be independently verified. Reported outcomes are '
    'therefore capped at unsupported-surface-or-scenario until a bounded, '
    'replayable acceptance path is captured.';

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

AccountDeleteAssessment assessAccountDeleteContract({
  required bool responseOk,
  required String? responseError,
}) {
  if (!responseOk) {
    return AccountDeleteAssessment(
      outcome: 'unsupported-surface-or-scenario',
      supported: false,
      observedSurfaceLabel: 'request-rejected',
      reason:
          'AccountDelete RPC did not complete successfully on the observed surface: ${responseError ?? 'unknown error'}.',
    );
  }
  return const AccountDeleteAssessment(
    outcome: 'unsupported-surface-or-scenario',
    supported: false,
    observedSurfaceLabel: 'response-succeeded-but-unverifiable',
    reason:
        'The delete request returned ok, but $kAccountDeleteVerificationCaveat',
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
  });

  final DateTime capturedAt;
  final AccountDeleteAssessment assessment;
  final String? networkConfigPath;
  final String? networkConfigContent;
  final String coordinatorAddress;
  final Map<String, Object?> response;

  Map<String, Object?> toJson() => {
        'captured_at': capturedAt.toIso8601String(),
        'command': 'account-delete',
        'verification_caveat': kAccountDeleteVerificationCaveat,
        'assessment': assessment.toJson(),
        'network_config_path': networkConfigPath,
        'coordinator_address': coordinatorAddress,
        'response': response,
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
  } finally {
    bridge.freeHandle(handleId);
  }

  final assessment = assessAccountDeleteContract(
    responseOk: responseOk,
    responseError: responseError,
  );

  return AccountDeleteReport(
    capturedAt: DateTime.now().toUtc(),
    assessment: assessment,
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
    coordinatorAddress: coordinatorAddress,
    response: responseJson,
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
