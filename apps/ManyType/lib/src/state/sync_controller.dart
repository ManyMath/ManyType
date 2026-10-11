import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';
// AccountRegistry's host persistence API is not yet exported by the package
// barrel.
// ignore: implementation_imports
import 'package:manytype_cli/src/account_registry.dart';

import 'objects_providers.dart';
import 'session_provider.dart';
import 'sync_transport_platform.dart';

typedef ManyTypeSyncRunner =
    Future<void> Function(ManytypeSession session, String networkConfigContent);

typedef ManyTypeProbeRunner =
    Future<NetworkProbeResult> Function(
      ManytypeSession session,
      String networkConfigContent,
    );

enum SyncUiStatus {
  unsupported,
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
    this.restoring = false,
    this.validationError,
    this.message,
    this.configSummary,
    this.configuredAt,
    this.lastProbeAt,
    this.lastSuccessfulSyncAt,
    this.pendingLocalChanges = false,
    this.lastError,
  });

  final String networkConfigContent;
  final SyncUiStatus status;
  final bool restoring;
  final String? validationError;
  final String? message;
  final SyncConfigSummary? configSummary;
  final DateTime? configuredAt;
  final DateTime? lastProbeAt;
  final DateTime? lastSuccessfulSyncAt;
  final bool pendingLocalChanges;
  final String? lastError;

  bool get busy =>
      status == SyncUiStatus.probing || status == SyncUiStatus.syncing;

  bool get supported => status != SyncUiStatus.unsupported;

  bool get canRun =>
      networkConfigContent.trim().isNotEmpty &&
      validationError == null &&
      supported &&
      !restoring &&
      !busy;

  bool get hasError => status == SyncUiStatus.failed || validationError != null;

  SyncUiState copyWith({
    String? networkConfigContent,
    SyncUiStatus? status,
    bool? restoring,
    Object? validationError = _preserve,
    Object? message = _preserve,
    Object? configSummary = _preserve,
    Object? configuredAt = _preserve,
    Object? lastProbeAt = _preserve,
    Object? lastSuccessfulSyncAt = _preserve,
    bool? pendingLocalChanges,
    Object? lastError = _preserve,
  }) {
    return SyncUiState(
      networkConfigContent: networkConfigContent ?? this.networkConfigContent,
      status: status ?? this.status,
      restoring: restoring ?? this.restoring,
      validationError: validationError == _preserve
          ? this.validationError
          : validationError as String?,
      message: message == _preserve ? this.message : message as String?,
      configSummary: configSummary == _preserve
          ? this.configSummary
          : configSummary as SyncConfigSummary?,
      configuredAt: configuredAt == _preserve
          ? this.configuredAt
          : configuredAt as DateTime?,
      lastProbeAt: lastProbeAt == _preserve
          ? this.lastProbeAt
          : lastProbeAt as DateTime?,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt == _preserve
          ? this.lastSuccessfulSyncAt
          : lastSuccessfulSyncAt as DateTime?,
      pendingLocalChanges: pendingLocalChanges ?? this.pendingLocalChanges,
      lastError: lastError == _preserve ? this.lastError : lastError as String?,
    );
  }
}

const Object _preserve = Object();

abstract interface class SyncMetadataStore {
  Future<AccountSyncMetadata> load(String accountId);

  Future<void> save(String accountId, AccountSyncMetadata metadata);
}

class AccountRegistrySyncMetadataStore implements SyncMetadataStore {
  const AccountRegistrySyncMetadataStore();

  @override
  Future<AccountSyncMetadata> load(String accountId) {
    return AccountRegistry.loadSyncMetadata(accountId);
  }

  @override
  Future<void> save(String accountId, AccountSyncMetadata metadata) {
    return AccountRegistry.saveSyncMetadata(accountId, metadata);
  }
}

final syncMetadataStoreProvider = Provider<SyncMetadataStore>(
  (ref) => const AccountRegistrySyncMetadataStore(),
);

final syncClockProvider = Provider<DateTime Function()>(
  (ref) =>
      () => DateTime.now().toUtc(),
);

final nativeSyncSupportedProvider = Provider<bool>(
  (ref) => !kIsWeb && nativeSyncTransportAvailable,
);

final syncRunnerProvider = Provider<ManyTypeSyncRunner>((ref) {
  if (kIsWeb) {
    return (_, __) => Future<void>.error(
      UnsupportedError('Native sync transport is unavailable on web.'),
    );
  }
  return (session, networkConfigContent) {
    return session.sync.run(networkConfigContent: networkConfigContent);
  };
});

final syncProbeRunnerProvider = Provider<ManyTypeProbeRunner>((ref) {
  if (kIsWeb) {
    return (_, __) => Future<NetworkProbeResult>.error(
      UnsupportedError('Native sync transport is unavailable on web.'),
    );
  }
  return (session, networkConfigContent) {
    return session.probeNetwork.probe(
      networkConfigContent: networkConfigContent,
    );
  };
});

/// Durable sync setup and results, isolated by account ID.
///
/// Network configuration is not inferred from the account's
/// legacy `serverAddress` field. A new account remains
/// [SyncUiStatus.unconfigured] until the user supplies a real any-sync network
/// configuration. Browser builds and platforms without the native transport
/// bridge remain offline-only and never reach either runner, both of which
/// eventually instantiate that bridge.
final syncControllerProvider =
    StateNotifierProvider.family<SyncController, SyncUiState, String>((
      ref,
      id,
    ) {
      return SyncController(ref, id);
    });

class SyncController extends StateNotifier<SyncUiState> {
  SyncController(this._ref, this._accountId)
    : _supported = _ref.read(nativeSyncSupportedProvider),
      _metadataStore = _ref.read(syncMetadataStoreProvider),
      _clock = _ref.read(syncClockProvider),
      super(
        _ref.read(nativeSyncSupportedProvider)
            ? const SyncUiState(restoring: true)
            : const SyncUiState(
                status: SyncUiStatus.unsupported,
                message: syncUnavailableMessage,
              ),
      ) {
    initialized = _supported ? _restore() : Future<void>.value();
  }

  final Ref _ref;
  final String _accountId;
  final bool _supported;
  final SyncMetadataStore _metadataStore;
  final DateTime Function() _clock;
  late final Future<void> initialized;
  AccountSyncMetadata _metadata = const AccountSyncMetadata();
  Future<void> _metadataQueue = Future<void>.value();
  var _configurationRevision = 0;
  var _localMutationRevision = 0;

  Future<void> _restore() async {
    try {
      final restored = await _metadataStore.load(_accountId);
      _metadata = restored;
      if (!mounted) return;
      if (_configurationRevision == 0) {
        final merged = restored.copyWith(
          pendingLocalChanges:
              restored.pendingLocalChanges || state.pendingLocalChanges,
        );
        state = _stateFromMetadata(merged).copyWith(restoring: false);
      } else {
        state = state.copyWith(restoring: false);
      }
    } catch (error) {
      if (!mounted) return;
      final message =
          'Could not restore sync settings: ${syncErrorMessage(error)}';
      state = state.copyWith(
        status: SyncUiStatus.failed,
        restoring: false,
        message: message,
        lastError: syncErrorMessage(error),
      );
    }
  }

  /// Waits until all metadata writes requested before this call are durable.
  /// Tests use this to model an application restart without timing guesses.
  Future<void> flushPersistence() async {
    await initialized;
    await _metadataQueue;
  }

  Future<void> _persist(
    AccountSyncMetadata Function(AccountSyncMetadata current) update,
  ) {
    final completer = Completer<void>();
    _metadataQueue = _metadataQueue.then((_) async {
      try {
        await initialized;
        final next = update(_metadata);
        await _metadataStore.save(_accountId, next);
        _metadata = next;
        completer.complete();
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  void _persistInBackground(
    AccountSyncMetadata Function(AccountSyncMetadata current) update,
  ) {
    unawaited(
      _persist(update).catchError((Object error) {
        if (!mounted) return;
        final detail = syncErrorMessage(error);
        state = state.copyWith(
          status: SyncUiStatus.failed,
          message: 'Could not save sync state: $detail',
          lastError: detail,
        );
      }),
    );
  }

  /// Durably marks the account pending before a local write begins, without
  /// claiming that an unconfigured account has ever synced. If a write lands
  /// during sync, [sync] compares revisions and reports the remaining change
  /// instead of incorrectly claiming success.
  Future<void> markLocalChangesPending() async {
    _localMutationRevision++;
    if (!_supported) return;
    final nextStatus = state.networkConfigContent.trim().isEmpty
        ? SyncUiStatus.unconfigured
        : SyncUiStatus.localChangesPending;
    state = state.copyWith(
      status: nextStatus,
      pendingLocalChanges: true,
      message: state.networkConfigContent.trim().isEmpty
          ? 'Local changes are stored only on this device. Configure sync to '
                'send them to another device.'
          : 'Local changes are waiting for the next sync.',
    );
    try {
      await _persist((current) => current.copyWith(pendingLocalChanges: true));
    } catch (error) {
      if (mounted) {
        final detail = syncErrorMessage(error);
        state = state.copyWith(
          status: SyncUiStatus.failed,
          message:
              'The change was not saved because its pending-sync marker '
              'could not be recorded: $detail',
          lastError: detail,
        );
      }
      rethrow;
    }
  }

  void updateNetworkConfig(String value) {
    if (!_supported) {
      state = state.copyWith(
        status: SyncUiStatus.unsupported,
        message: syncUnavailableMessage,
      );
      return;
    }

    final revision = ++_configurationRevision;
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      state = SyncUiState(
        networkConfigContent: value,
        status: SyncUiStatus.unconfigured,
        pendingLocalChanges: state.pendingLocalChanges,
        message: state.pendingLocalChanges
            ? 'Local changes are stored only on this device. Configure sync '
                  'to send them to another device.'
            : null,
      );
      _persistInBackground((current) {
        if (revision != _configurationRevision) return current;
        return AccountSyncMetadata(
          pendingLocalChanges: current.pendingLocalChanges,
        );
      });
      return;
    }

    try {
      final config = parseNetworkConfig(trimmed);
      final coordinator = requireCoordinatorNode(config);
      final configuredAt = _metadata.networkConfigContent.trim() == trimmed
          ? _metadata.configuredAt ?? _clock()
          : _clock();
      final reapplied =
          state.validationError == null &&
          state.networkConfigContent.trim() == trimmed;
      state = reapplied
          ? state.copyWith(networkConfigContent: value)
          : SyncUiState(
              networkConfigContent: value,
              status: state.pendingLocalChanges
                  ? SyncUiStatus.localChangesPending
                  : SyncUiStatus.ready,
              message: _readyMessage(config),
              configSummary: _configSummary(config, coordinator),
              configuredAt: configuredAt,
              pendingLocalChanges: state.pendingLocalChanges,
            );
      _persistInBackground((current) {
        if (revision != _configurationRevision) return current;
        final unchanged = current.networkConfigContent.trim() == trimmed;
        return AccountSyncMetadata(
          networkConfigContent: value,
          configuredAt: unchanged
              ? current.configuredAt ?? configuredAt
              : configuredAt,
          lastProbeAt: unchanged ? current.lastProbeAt : null,
          lastSuccessfulSyncAt: unchanged ? current.lastSuccessfulSyncAt : null,
          pendingLocalChanges: current.pendingLocalChanges,
        );
      });
    } catch (e) {
      state = state.copyWith(
        networkConfigContent: value,
        status: SyncUiStatus.failed,
        restoring: false,
        validationError: syncErrorMessage(e),
        message: null,
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
    if (!_supported) {
      state = state.copyWith(
        status: SyncUiStatus.unsupported,
        message: syncUnavailableMessage,
      );
      return;
    }
    await flushPersistence();
    if (!mounted) return;
    final content = _validNetworkConfigContent();
    if (content == null) return;

    state = state.copyWith(
      status: SyncUiStatus.probing,
      message: 'Probing coordinator...',
      validationError: null,
    );

    late final NetworkProbeResult result;
    try {
      final session = await _requireSession();
      result = await _ref.read(syncProbeRunnerProvider)(session, content);
    } catch (error) {
      if (!mounted) return;
      final detail = syncErrorMessage(error);
      final probedAt = _clock();
      Object? persistenceError;
      try {
        await _persist(
          (current) =>
              current.copyWith(lastProbeAt: probedAt, lastError: detail),
        );
      } catch (error) {
        persistenceError = error;
      }
      if (!mounted) return;
      state = state.copyWith(
        status: SyncUiStatus.failed,
        message: persistenceError == null
            ? 'Network probe failed: $detail'
            : 'Network probe failed: $detail. Its result could not be saved: '
                  '${syncErrorMessage(persistenceError)}',
        lastProbeAt: probedAt,
        lastError: detail,
      );
      return;
    }

    if (!mounted) return;
    final probedAt = _clock();
    try {
      await _persist(
        (current) => current.copyWith(lastProbeAt: probedAt, lastError: null),
      );
    } catch (error) {
      if (!mounted) return;
      final detail = syncErrorMessage(error);
      state = state.copyWith(
        status: SyncUiStatus.failed,
        message:
            'The network responded, but its probe result could not be '
            'saved: $detail',
        configSummary: SyncConfigSummary(
          networkId: _networkLabel(result.networkId),
          coordinatorAddress: result.coordinatorAddress,
          nodeCount: result.nodeCount,
        ),
        lastProbeAt: probedAt,
        lastError: detail,
      );
      return;
    }

    if (!mounted) return;
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
      lastProbeAt: probedAt,
      lastError: null,
    );
  }

  Future<void> sync({required String spaceId}) async {
    if (!_supported) {
      state = state.copyWith(
        status: SyncUiStatus.unsupported,
        message: syncUnavailableMessage,
      );
      return;
    }
    await flushPersistence();
    if (!mounted) return;
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
    } catch (error) {
      if (!mounted) return;
      final detail = syncErrorMessage(error);
      Object? persistenceError;
      try {
        await _persist((current) => current.copyWith(lastError: detail));
      } catch (error) {
        persistenceError = error;
      }
      if (!mounted) return;
      state = state.copyWith(
        status: SyncUiStatus.failed,
        message: persistenceError == null
            ? 'Sync failed: $detail'
            : 'Sync failed: $detail. Its error could not be saved: '
                  '${syncErrorMessage(persistenceError)}',
        lastError: detail,
      );
      return;
    }

    if (!mounted) return;
    _ref.invalidate(objectsProvider(spaceId));
    _ref.invalidate(objectBlocksProvider);
    _ref.invalidate(objectRelationsProvider);
    _ref.invalidate(objectDetailProvider);
    final changedWhileSyncing =
        _localMutationRevision != mutationRevisionAtStart;
    final syncedAt = _clock();
    try {
      await _persist(
        (current) => current.copyWith(
          lastSuccessfulSyncAt: syncedAt,
          pendingLocalChanges: changedWhileSyncing,
          lastError: null,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final detail = syncErrorMessage(error);
      state = state.copyWith(
        status: SyncUiStatus.failed,
        message: 'Sync completed, but its status could not be saved: $detail',
        lastSuccessfulSyncAt: syncedAt,
        pendingLocalChanges: changedWhileSyncing,
        lastError: detail,
      );
      return;
    }

    if (!mounted) return;
    state = state.copyWith(
      status: changedWhileSyncing
          ? SyncUiStatus.localChangesPending
          : SyncUiStatus.syncSucceeded,
      message: changedWhileSyncing
          ? 'Sync completed, but newer local changes are still pending.'
          : 'Sync completed. Local objects are refreshing.',
      lastSuccessfulSyncAt: syncedAt,
      pendingLocalChanges: changedWhileSyncing,
      lastError: null,
    );
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

const String syncUnavailableMessage = kIsWeb
    ? 'Sync is disabled in the browser editor. Your recovery identity and '
          'documents stay in this browser; use ManyType on macOS or Linux to '
          'configure and run device sync.'
    : 'Sync is not available on this platform yet. Your recovery identity '
          'and documents stay on this device; use ManyType on macOS or Linux '
          'to configure and run device sync.';

SyncConfigSummary _configSummary(
  NetworkConfigFile config,
  NetworkConfigNode coordinator,
) {
  return SyncConfigSummary(
    networkId: _networkLabel(config.networkId),
    coordinatorAddress: chooseBestAddress(coordinator.addresses),
    nodeCount: config.nodes.length,
  );
}

SyncUiState _stateFromMetadata(AccountSyncMetadata metadata) {
  final content = metadata.networkConfigContent;
  if (content.trim().isEmpty) {
    return SyncUiState(
      status: SyncUiStatus.unconfigured,
      pendingLocalChanges: metadata.pendingLocalChanges,
      lastError: metadata.lastError,
      message: metadata.pendingLocalChanges
          ? 'Local changes are stored only on this device. Configure sync to '
                'send them to another device.'
          : null,
    );
  }

  try {
    final config = parseNetworkConfig(content.trim());
    final coordinator = requireCoordinatorNode(config);
    final status = metadata.lastError != null
        ? SyncUiStatus.failed
        : metadata.pendingLocalChanges
        ? SyncUiStatus.localChangesPending
        : metadata.lastSuccessfulSyncAt != null
        ? SyncUiStatus.syncSucceeded
        : metadata.lastProbeAt != null
        ? SyncUiStatus.probeSucceeded
        : SyncUiStatus.ready;
    return SyncUiState(
      networkConfigContent: content,
      status: status,
      message: switch (status) {
        SyncUiStatus.failed => 'Last sync action failed: ${metadata.lastError}',
        SyncUiStatus.localChangesPending =>
          'Local changes are waiting for the next sync.',
        SyncUiStatus.syncSucceeded => 'A previous sync completed successfully.',
        SyncUiStatus.probeSucceeded =>
          'The coordinator responded previously. No successful sync is '
              'recorded yet.',
        _ => _readyMessage(config),
      },
      configSummary: _configSummary(config, coordinator),
      configuredAt: metadata.configuredAt,
      lastProbeAt: metadata.lastProbeAt,
      lastSuccessfulSyncAt: metadata.lastSuccessfulSyncAt,
      pendingLocalChanges: metadata.pendingLocalChanges,
      lastError: metadata.lastError,
    );
  } catch (error) {
    final detail = syncErrorMessage(error);
    return SyncUiState(
      networkConfigContent: content,
      status: SyncUiStatus.failed,
      validationError: detail,
      message: 'Saved network configuration is invalid: $detail',
      configuredAt: metadata.configuredAt,
      lastProbeAt: metadata.lastProbeAt,
      lastSuccessfulSyncAt: metadata.lastSuccessfulSyncAt,
      pendingLocalChanges: metadata.pendingLocalChanges,
      lastError: metadata.lastError,
    );
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
  if (text.startsWith('Bad state: ')) {
    return text.substring('Bad state: '.length);
  }
  if (text.startsWith('Unsupported operation: ')) {
    return text.substring('Unsupported operation: '.length);
  }
  return text;
}
