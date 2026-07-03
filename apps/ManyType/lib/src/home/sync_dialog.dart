import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_hooks/manyui_hooks.dart';

import '../state/sync_controller.dart';

Future<void> showSyncDialog(BuildContext context, {required String spaceId}) {
  return showMDialog<void>(
    context,
    semanticLabel: 'Configure sync',
    builder: (context) => _SyncDialog(spaceId: spaceId),
  );
}

class _SyncDialog extends HookConsumerWidget {
  const _SyncDialog({required this.spaceId});

  final String spaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncControllerProvider);
    final controller = useMController<String>(state.networkConfigContent);
    final selfHostedAddressController = useMController<String>(
      '127.0.0.1:33020',
    );
    final selfHostedPeerController = useMController<String>('');
    final selfHostedNetworkController = useMController<String>('local-net');
    final selfHostedServerHostController = useMController<String>('127.0.0.1');
    final selfHostedServerHosts = useMControllerValue(
      selfHostedServerHostController,
    );
    final selfHostedError = useState<String?>(null);
    final selfHostedCommandCopied = useState(false);
    final syncController = ref.read(syncControllerProvider.notifier);
    final theme = MTheme.of(context);

    String? selfHostedCommand;
    String? selfHostedCommandError;
    try {
      selfHostedCommand = buildSelfHostedDockerStartCommand(
        externalListenHosts: selfHostedServerHosts,
      );
    } on Object catch (error) {
      selfHostedCommandError = syncErrorMessage(error);
    }

    void useSelfHostedConfig() {
      try {
        final content = syncController.useSelfHostedConfig(
          coordinatorAddress: selfHostedAddressController.value,
          peerId: selfHostedPeerController.value,
          networkId: selfHostedNetworkController.value,
        );
        controller.value = content;
        selfHostedError.value = null;
      } on Object catch (error) {
        selfHostedError.value = syncErrorMessage(error);
      }
    }

    Future<void> copySelfHostedCommand() async {
      final command = selfHostedCommand;
      if (command == null) return;

      await Clipboard.setData(ClipboardData(text: command));
      selfHostedCommandCopied.value = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        selfHostedCommandCopied.value = false;
      }
    }

    return MDialogContent(
      title: 'Sync',
      description:
          'Configure an any-sync network, then probe the coordinator or sync '
          'this local space.',
      content: Column(
        mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),
          ],
          MField(
            label: 'Network config YAML',
            description: 'Inline client.yml content.',
            enabled: !state.busy,
            errorText: state.validationError,
            child: MTextField(
              controller: controller,
              minLines: 8,
              maxLines: 10,
              enabled: !state.busy,
              placeholder:
                  'id: local\nnetworkId: local-net\nnodes:\n'
                  '  - peerId: coordinator\n'
                  '    addresses:\n'
                  '      - quic://127.0.0.1:1014\n'
                  '    types:\n'
                  '      - coordinator',
              semanticLabel: 'Network config YAML',
              onChanged: syncController.updateNetworkConfig,
            ),
          ),
          const SizedBox(height: 16),
          MInsetPanel(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MSectionHeader(
                  title: 'Self-hosted',
                  titleStyle: theme.typography.label,
                  description: 'Generate client.yml for a single coordinator.',
                ),
                const SizedBox(height: 12),
                MField(
                  label: 'Coordinator address',
                  enabled: !state.busy,
                  child: MTextField(
                    controller: selfHostedAddressController,
                    enabled: !state.busy,
                    placeholder: '127.0.0.1:33020',
                    semanticLabel: 'Coordinator address',
                  ),
                ),
                const SizedBox(height: 12),
                MField(
                  label: 'Peer ID',
                  enabled: !state.busy,
                  child: MTextField(
                    controller: selfHostedPeerController,
                    enabled: !state.busy,
                    placeholder: 'Server peer ID',
                    semanticLabel: 'Peer ID',
                  ),
                ),
                const SizedBox(height: 12),
                MField(
                  label: 'Network ID',
                  enabled: !state.busy,
                  child: MTextField(
                    controller: selfHostedNetworkController,
                    enabled: !state.busy,
                    placeholder: 'local-net',
                    semanticLabel: 'Network ID',
                  ),
                ),
                if (selfHostedError.value != null) ...<Widget>[
                  const SizedBox(height: 12),
                  MAlert(
                    variant: MAlertVariant.destructive,
                    message: selfHostedError.value!,
                  ),
                ],
                const SizedBox(height: 12),
                MActionRow(
                  children: <Widget>[
                    MButton(
                      variant: MButtonVariant.outline,
                      onPressed: state.busy ? null : useSelfHostedConfig,
                      child: const Text('Use self-hosted config'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const MDivider(),
                const SizedBox(height: 12),
                MSectionHeader(
                  title: 'Server bootstrap',
                  titleStyle: theme.typography.label,
                  description:
                      'Start the checked-in Docker stack and generate '
                      'etc/client.yml.',
                ),
                const SizedBox(height: 12),
                MField(
                  label: 'External listen hosts',
                  description:
                      'Hostnames or IP addresses the server should advertise.',
                  enabled: !state.busy,
                  errorText: selfHostedCommandError,
                  child: MTextField(
                    controller: selfHostedServerHostController,
                    enabled: !state.busy,
                    placeholder: '127.0.0.1',
                    semanticLabel: 'External listen hosts',
                    onChanged: (_) => selfHostedCommandCopied.value = false,
                  ),
                ),
                const SizedBox(height: 12),
                MField(
                  label: 'Start command',
                  description:
                      'Run from the ManyType repository root before importing '
                      'the generated client.yml.',
                  child: MInsetPanel(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      selfHostedCommand ?? 'Enter an external host first.',
                      style: theme.typography.code.copyWith(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                MActionRow(
                  children: <Widget>[
                    MButton(
                      variant: MButtonVariant.outline,
                      size: MButtonSize.sm,
                      onPressed: selfHostedCommand == null
                          ? null
                          : copySelfHostedCommand,
                      child: Text(
                        selfHostedCommandCopied.value
                            ? 'Copied'
                            : 'Copy command',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.message != null) ...<Widget>[
            const SizedBox(height: 12),
            MAlert(
              variant: state.status == SyncUiStatus.failed
                  ? MAlertVariant.destructive
                  : MAlertVariant.neutral,
              message: state.message!,
              leading: state.busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
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
