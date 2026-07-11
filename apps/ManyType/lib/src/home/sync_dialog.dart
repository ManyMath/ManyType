import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_hooks/manyui_hooks.dart';

import '../state/sync_controller.dart';

Future<void> showSyncDialog(
  BuildContext context, {
  required String accountId,
  required String spaceId,
}) {
  return showMDialog<void>(
    context,
    semanticLabel: 'Configure sync',
    builder: (context) => _SyncDialog(accountId: accountId, spaceId: spaceId),
  );
}

class _SyncDialog extends HookConsumerWidget {
  const _SyncDialog({required this.accountId, required this.spaceId});

  final String accountId;
  final String spaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = syncControllerProvider(accountId);
    final state = ref.watch(provider);
    final yamlController = useMController<String>(state.networkConfigContent);
    final addressController = useMController<String>('127.0.0.1:33020');
    final peerController = useMController<String>('');
    final networkController = useMController<String>('local-net');
    final serverHostController = useMController<String>('127.0.0.1');
    final serverHosts = useMControllerValue(serverHostController);
    final quickError = useState<String?>(null);
    final commandCopied = useState(false);
    final syncController = ref.read(provider.notifier);
    final theme = MTheme.of(context);
    final syncControlsEnabled =
        state.supported && !state.busy && !state.restoring;

    useEffect(() {
      if (yamlController.value != state.networkConfigContent) {
        yamlController.value = state.networkConfigContent;
      }
      return null;
    }, <Object?>[state.networkConfigContent]);

    String? serverCommand;
    String? serverCommandError;
    try {
      serverCommand = buildSelfHostedDockerStartCommand(
        externalListenHosts: serverHosts,
      );
    } catch (error) {
      serverCommandError = syncErrorMessage(error);
    }

    void connectSelfHosted() {
      try {
        final content = syncController.useSelfHostedConfig(
          coordinatorAddress: addressController.value,
          peerId: peerController.value,
          networkId: networkController.value,
        );
        yamlController.value = content;
        quickError.value = null;
      } catch (error) {
        quickError.value = syncErrorMessage(error);
      }
    }

    Future<void> copyServerCommand() async {
      final command = serverCommand;
      if (command == null) return;
      await Clipboard.setData(ClipboardData(text: command));
      commandCopied.value = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (context.mounted) commandCopied.value = false;
    }

    return MDialogContent(
      title: 'Sync',
      description: !state.supported
          ? 'Browser workspaces are offline-only.'
          : state.configSummary == null
          ? 'Connect this workspace to an any-sync coordinator.'
          : 'A network config is loaded. Probe it to verify availability or '
                'start a real sync.',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!state.supported) ...<Widget>[
            const MAlert(
              variant: MAlertVariant.neutral,
              message:
                  'Sync is disabled in the browser editor. Your recovery '
                  'identity and documents stay in this browser; use the '
                  'native ManyType app to configure and run device sync.',
            ),
            const SizedBox(height: 16),
          ],
          if (state.supported) ...<Widget>[
            MInsetPanel(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (state.configSummary != null) ...<Widget>[
                    MPropertyRow(
                      label: 'Network',
                      layout: MPropertyRowLayout.inline,
                      value: Text(state.configSummary!.networkId),
                    ),
                    const SizedBox(height: 8),
                    MPropertyRow(
                      label: 'Coordinator',
                      layout: MPropertyRowLayout.inline,
                      valueStyle: theme.typography.code,
                      value: Text(
                        state.configSummary!.coordinatorAddress,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: MDivider(),
                    ),
                  ],
                  MPropertyRow(
                    label: 'Configured',
                    layout: MPropertyRowLayout.inline,
                    value: Text(_formatTimestamp(state.configuredAt)),
                  ),
                  const SizedBox(height: 8),
                  MPropertyRow(
                    label: 'Last probe',
                    layout: MPropertyRowLayout.inline,
                    value: Text(_formatTimestamp(state.lastProbeAt)),
                  ),
                  const SizedBox(height: 8),
                  MPropertyRow(
                    label: 'Last successful sync',
                    layout: MPropertyRowLayout.inline,
                    value: Text(_formatTimestamp(state.lastSuccessfulSyncAt)),
                  ),
                  const SizedBox(height: 8),
                  MPropertyRow(
                    label: 'Local changes',
                    layout: MPropertyRowLayout.inline,
                    value: Text(
                      state.pendingLocalChanges ? 'Pending' : 'None pending',
                    ),
                  ),
                  if (state.lastError != null) ...<Widget>[
                    const SizedBox(height: 8),
                    MPropertyRow(
                      label: 'Last error',
                      value: Text(state.lastError!, textAlign: TextAlign.right),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Self-hosted coordinator', style: theme.typography.label),
          const SizedBox(height: 10),
          MField(
            label: 'Coordinator address',
            child: MTextField(
              controller: addressController,
              enabled: syncControlsEnabled,
              placeholder: '127.0.0.1:33020',
              semanticLabel: 'Coordinator address',
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final peer = MField(
                label: 'Peer ID',
                child: MTextField(
                  controller: peerController,
                  enabled: syncControlsEnabled,
                  placeholder: 'Coordinator peer ID',
                  semanticLabel: 'Peer ID',
                ),
              );
              final network = MField(
                label: 'Network ID',
                child: MTextField(
                  controller: networkController,
                  enabled: syncControlsEnabled,
                  placeholder: 'local-net',
                  semanticLabel: 'Network ID',
                ),
              );
              if (constraints.maxWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[peer, const SizedBox(height: 10), network],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: peer),
                  const SizedBox(width: 10),
                  Expanded(child: network),
                ],
              );
            },
          ),
          if (quickError.value != null) ...<Widget>[
            const SizedBox(height: 10),
            MAlert(
              variant: MAlertVariant.destructive,
              message: quickError.value!,
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: MButton(
              variant: MButtonVariant.outline,
              size: MButtonSize.sm,
              onPressed: syncControlsEnabled ? connectSelfHosted : null,
              child: const Text('Use configuration'),
            ),
          ),
          const SizedBox(height: 16),
          MAccordion(
            semanticLabel: 'Advanced sync setup',
            items: <MAccordionItem>[
              MAccordionItem(
                id: 'advanced',
                title: const Text('Advanced setup'),
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      MField(
                        label: 'Network config YAML',
                        description: 'Paste an existing any-sync client.yml.',
                        enabled: syncControlsEnabled,
                        errorText: state.validationError,
                        child: MTextField(
                          controller: yamlController,
                          minLines: 7,
                          maxLines: 10,
                          enabled: syncControlsEnabled,
                          placeholder:
                              'id: local\nnetworkId: local-net\nnodes:',
                          semanticLabel: 'Network config YAML',
                          onChanged: syncController.updateNetworkConfig,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const MDivider(),
                      const SizedBox(height: 16),
                      MSectionHeader(
                        title: 'Server bootstrap',
                        titleStyle: theme.typography.label,
                        description: 'Generate the local Docker start command.',
                      ),
                      const SizedBox(height: 12),
                      MField(
                        label: 'External listen hosts',
                        enabled: !state.busy,
                        errorText: serverCommandError,
                        child: MTextField(
                          controller: serverHostController,
                          enabled: !state.busy,
                          placeholder: '127.0.0.1',
                          semanticLabel: 'External listen hosts',
                          onChanged: (_) => commandCopied.value = false,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MField(
                        label: 'Start command',
                        child: MInsetPanel(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            serverCommand ?? 'Enter an external host first.',
                            style: theme.typography.code.copyWith(fontSize: 12),
                            softWrap: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: MIconButton(
                          icon: commandCopied.value
                              ? MIconData.check
                              : MIconData.copy,
                          label: commandCopied.value
                              ? 'Command copied'
                              : 'Copy command',
                          variant: MButtonVariant.outline,
                          size: MButtonSize.sm,
                          onPressed: serverCommand == null
                              ? null
                              : copyServerCommand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (state.message != null && state.supported) ...<Widget>[
            const SizedBox(height: 12),
            MAlert(
              variant: state.status == SyncUiStatus.failed
                  ? MAlertVariant.destructive
                  : MAlertVariant.neutral,
              message: state.message!,
              leading: state.busy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: MCircularProgress.indeterminate(),
                    )
                  : null,
            ),
          ],
        ],
      ),
      actions: <Widget>[
        MButton(
          variant: MButtonVariant.outline,
          onPressed: state.busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        MButton(
          variant: MButtonVariant.outline,
          onPressed: state.canRun ? syncController.probe : null,
          child: Text(
            state.status == SyncUiStatus.probing ? 'Probing...' : 'Probe',
          ),
        ),
        MButton(
          onPressed: state.canRun
              ? () => syncController.sync(spaceId: spaceId)
              : null,
          child: Text(
            state.status == SyncUiStatus.syncing ? 'Syncing...' : 'Sync now',
          ),
        ),
      ],
    );
  }
}

String _formatTimestamp(DateTime? value) {
  if (value == null) return 'Never';
  final local = value.toLocal();
  String twoDigits(int part) => part.toString().padLeft(2, '0');
  return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)} '
      '${local.timeZoneName}';
}
