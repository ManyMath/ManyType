import 'package:flutter/widgets.dart';
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
    final syncController = ref.read(syncControllerProvider.notifier);
    final theme = MTheme.of(context);

    return MDialogContent(
      title: 'Sync',
      description:
          'Paste an any-sync client.yml config to probe the coordinator or '
          'sync this local space.',
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
            description: 'Use inline client.yml content, not a file path.',
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
