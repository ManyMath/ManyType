import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';

import 'objects_providers.dart';
import 'session_provider.dart';

typedef ManyTypeSyncRunner =
    Future<void> Function(ManytypeSession session, String networkConfigContent);

typedef ManyTypeProbeRunner =
    Future<NetworkProbeResult> Function(
      ManytypeSession session,
      String networkConfigContent,
    );

enum SyncUiStatus {
  unconfigured,
  ready,
  probing,
  syncing,
  probeSucceeded,
  syncSucceeded,
  localChangesPending,
  failed,
}

class SyncConfigSummary {
  const SyncConfigSummary({
    required this.networkId,
    required this.coordinatorAddress,
    required this.nodeCount,
  });

  final String networkId;
  final String coordinatorAddress;
  final int nodeCount;
}

class SyncUiState {
  const SyncUiState({
    this.networkConfigContent = '',
    this.status = SyncUiStatus.unconfigured,
    this.validationError,
    this.message,
    this.configSummary,
  });

  final String networkConfigContent;
  final SyncUiStatus status;
  final String? validationError;
  final String? message;
  final SyncConfigSummary? configSummary;

  bool get busy =>
      status == SyncUiStatus.probing || status == SyncUiStatus.syncing;

  bool get canRun =>
      networkConfigContent.trim().isNotEmpty &&
      validationError == null &&
      !busy;

  bool get hasError => status == SyncUiStatus.failed || validationError != null;

  SyncUiState copyWith({
    String? networkConfigContent,
    SyncUiStatus? status,
    Object? validationError = _preserve,
    Object? message = _preserve,
    Object? configSummary = _preserve,
  }) {
    return SyncUiState(
      networkConfigContent: networkConfigContent ?? this.networkConfigContent,
      status: status ?? this.status,
      validationError: validationError == _preserve
          ? this.validationError
          : validationError as String?,
      message: message == _preserve ? this.message : message as String?,
      configSummary: configSummary == _preserve
          ? this.configSummary
          : configSummary as SyncConfigSummary?,
    );
  }
}

const Object _preserve = Object();

final syncRunnerProvider = Provider<ManyTypeSyncRunner>((ref) {
  return (session, networkConfigContent) {
    return session.sync.run(networkConfigContent: networkConfigContent);
  };
});

final syncProbeRunnerProvider = Provider<ManyTypeProbeRunner>((ref) {
  return (session, networkConfigContent) {
    return session.probeNetwork.probe(
      networkConfigContent: networkConfigContent,
    );
  };
});

/// In-memory sync setup and results, isolated by account ID.
///
/// Network configuration is deliberately not inferred from the account's
/// legacy `serverAddress` field. A new account remains [SyncUiStatus.unconfigured]
/// until the user supplies a real any-sync network configuration.
final syncControllerProvider =
    StateNotifierProvider.family<SyncController, SyncUiState, String>((ref, _) {
      return SyncController(ref);
    });

class SyncController extends StateNotifier<SyncUiState> {
  SyncController(this._ref) : super(const SyncUiState());

  final Ref _ref;
  var _localMutationRevision = 0;

  /// Records a local write without claiming that an unconfigured account has
  /// ever synced. If a write lands during sync, [sync] compares revisions and
  /// reports the remaining change instead of incorrectly claiming success.
  void markLocalChangesPending() {
    _localMutationRevision++;
    if (state.status == SyncUiStatus.syncSucceeded) {
      state = state.copyWith(
        status: SyncUiStatus.localChangesPending,
        message: 'Local changes are waiting for the next sync.',
      );
    }
  }

  void updateNetworkConfig(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      state = SyncUiState(networkConfigContent: value);
      return;
    }

    try {
      final config = parseNetworkConfig(trimmed);
      final coordinator = requireCoordinatorNode(config);
      state = SyncUiState(
        networkConfigContent: value,
        status: SyncUiStatus.ready,
        message: _readyMessage(config),
        configSummary: SyncConfigSummary(
          networkId: _networkLabel(config.networkId),
          coordinatorAddress: chooseBestAddress(coordinator.addresses),
          nodeCount: config.nodes.length,
        ),
      );
    } catch (e) {
      state = SyncUiState(
        networkConfigContent: value,
        status: SyncUiStatus.failed,
        validationError: syncErrorMessage(e),
      );
    }
  }

  String useSelfHostedConfig({
    required String coordinatorAddress,
    required String peerId,
    String networkId = 'local-net',
    String configId = 'local',
  }) {
    final content = buildSelfHostedNetworkConfig(
      coordinatorAddress: coordinatorAddress,
      peerId: peerId,
      networkId: networkId,
      configId: configId,
    );
    updateNetworkConfig(content);
    return content;
  }

  Future<void> probe() async {
    final content = _validNetworkConfigContent();
    if (content == null) return;

    state = state.copyWith(
      status: SyncUiStatus.probing,
      message: 'Probing coordinator...',
      validationError: null,
    );

    try {
      final session = await _requireSession();
      final result = await _ref.read(syncProbeRunnerProvider)(session, content);
      state = state.copyWith(
        status: SyncUiStatus.probeSucceeded,
        message:
            'Network ${_networkLabel(result.networkId)} responded from '
            '${result.coordinatorAddress} with ${result.nodeCount} nodes.',
        configSummary: SyncConfigSummary(
          networkId: _networkLabel(result.networkId),
          coordinatorAddress: result.coordinatorAddress,
          nodeCount: result.nodeCount,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncUiStatus.failed,
        message: 'Network probe failed: ${syncErrorMessage(e)}',
      );
    }
  }

  Future<void> sync({required String spaceId}) async {
    final content = _validNetworkConfigContent();
    if (content == null) return;
    final mutationRevisionAtStart = _localMutationRevision;

    state = state.copyWith(
      status: SyncUiStatus.syncing,
      message: 'Syncing space...',
      validationError: null,
    );

    try {
      final session = await _requireSession();
      await _ref.read(syncRunnerProvider)(session, content);
      _ref.invalidate(objectsProvider(spaceId));
      _ref.invalidate(objectBlocksProvider);
      _ref.invalidate(objectRelationsProvider);
      _ref.invalidate(objectDetailProvider);
      final changedWhileSyncing =
          _localMutationRevision != mutationRevisionAtStart;
      state = state.copyWith(
        status: changedWhileSyncing
            ? SyncUiStatus.localChangesPending
            : SyncUiStatus.syncSucceeded,
        message: changedWhileSyncing
            ? 'Sync completed, but newer local changes are still pending.'
            : 'Sync completed. Local objects are refreshing.',
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncUiStatus.failed,
        message: 'Sync failed: ${syncErrorMessage(e)}',
      );
    }
  }

  String? _validNetworkConfigContent() {
    final content = state.networkConfigContent.trim();
    if (content.isEmpty) {
      state = state.copyWith(
        status: SyncUiStatus.failed,
        validationError: 'Paste a client.yml network config first.',
        message: null,
      );
      return null;
    }

    if (state.validationError != null) {
      return null;
    }

    return content;
  }

  Future<ManytypeSession> _requireSession() async {
    final session = await _ref.read(sessionProvider.future);
    if (session == null) {
      throw StateError('Open an account before syncing.');
    }
    return session;
  }
}

String buildSelfHostedNetworkConfig({
  required String coordinatorAddress,
  required String peerId,
  String networkId = 'local-net',
  String configId = 'local',
}) {
  final address = _requiredSingleLine(coordinatorAddress, 'coordinatorAddress');
  final normalizedAddress = normalizeQuicAddress(address);
  final peer = _requiredSingleLine(peerId, 'peerId');
  final network = _requiredSingleLine(networkId, 'networkId');
  final id = _requiredSingleLine(configId, 'configId');

  return '''
id: $id
networkId: $network
nodes:
  - peerId: $peer
    addresses:
      - quic://$normalizedAddress
      - $normalizedAddress
    types:
      - coordinator
      - tree
      - file
      - consensus
''';
}

String buildSelfHostedDockerStartCommand({
  required String externalListenHosts,
}) {
  final hosts = _requiredSingleLine(externalListenHosts, 'externalListenHosts');
  final escapedHosts = _escapeEnvDoubleQuoted(hosts);

  return '''
cd docker/any-sync
cat > .env.override <<'EOF'
EXTERNAL_LISTEN_HOSTS="$escapedHosts"
EOF
make start
'''
      .trim();
}

String _readyMessage(NetworkConfigFile config) {
  final network = _networkLabel(config.networkId);
  final nodeCount = config.nodes.length;
  return 'Configured network $network with $nodeCount node '
      '${nodeCount == 1 ? 'entry' : 'entries'}. Probe the coordinator to '
      'verify availability.';
}

String _requiredSingleLine(String value, String field) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    throw StateError('$field is required');
  }
  if (trimmed.contains('\n') || trimmed.contains('\r')) {
    throw StateError('$field must be a single line');
  }
  return trimmed;
}

String _escapeEnvDoubleQuoted(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll(r'$', r'\$');
}

String _networkLabel(String networkId) {
  final trimmed = networkId.trim();
  return trimmed.isEmpty ? 'unknown' : trimmed;
}

String syncErrorMessage(Object error) {
  final text = error.toString();
  if (text.startsWith('Exception: ')) {
    return text.substring('Exception: '.length);
  }
  if (text.startsWith('StateError: ')) {
    return text.substring('StateError: '.length);
  }
  if (text.startsWith('UnsupportedError: ')) {
    return text.substring('UnsupportedError: '.length);
  }
  return text;
}
