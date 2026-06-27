import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manyui/manyui.dart';

import '../state/objects_providers.dart';

/// Detail pane: renders the replayed object state from `readCommand`.
///
/// The core exposes the replay as rendered report lines (there is no
/// structured block model on the read path yet), so this parses the known
/// line shapes: `[id] Text: "..."`, `[id] [Checkbox|Numbered|Toggle|Quote|
/// Callout] ...`, `Text (updated): "..."` — into styled paragraphs and
/// leaves everything else as muted metadata. Deliberately shallow; a
/// structured block renderer is phase 2.
/// TODO(manytype): replace line parsing with a structured replay API.
class ObjectDetailView extends ConsumerWidget {
  const ObjectDetailView({
    super.key,
    required this.objectId,
    required this.spaceId,
    this.onBack,
  });

  final String objectId;
  final String spaceId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final detail = ref.watch(objectDetailProvider(objectId));
    final metas = ref.watch(objectsProvider(spaceId)).valueOrNull;
    String title = objectId;
    if (metas != null) {
      for (final meta in metas) {
        if (meta.id == objectId) {
          title = meta.displayName;
          break;
        }
      }
    }

    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (onBack != null) ...<Widget>[
                  MButton(
                    variant: MButtonVariant.ghost,
                    onPressed: onBack,
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.typography.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              objectId,
              style: theme.typography.code.copyWith(
                fontSize: 11,
                color: theme.colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const MDivider(),
            const SizedBox(height: 12),
            Expanded(
              child: detail.when(
                loading: () => const Center(child: MProgress.indeterminate()),
                error: (e, _) => Text(
                  'Could not read object: $e',
                  style: theme.typography.bodySmall.copyWith(
                    color: theme.colors.destructive,
                  ),
                ),
                data: (result) {
                  if (result == null || result.notFound) {
                    return Text(
                      'Object not found in the local store.',
                      style: theme.typography.bodySmall.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    );
                  }
                  return ListView(children: _renderLines(theme, result.lines));
                },
              ),
            ),
            // TODO(manytype): phase 2 editing (editCommand requires a
            // network config; offline edits need a tree_builder wrapper).
          ],
        ),
      ),
    );
  }
}

final _textBlock = RegExp(r'^\[[^\]]+\] Text: "(.*)"$');
final _updatedText = RegExp(r'^Text \(updated\): "(.*)"$');
final _taggedBlock = RegExp(
  r'^\[[^\]]+\] (\[[x ]\] )?\[(Checkbox|Numbered|Toggle|Quote|'
  r'Callout)\] (.*)$',
);

List<Widget> _renderLines(MThemeData theme, List<String> lines) {
  final widgets = <Widget>[];
  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) {
      widgets.add(const SizedBox(height: 8));
      continue;
    }

    final text = _textBlock.firstMatch(line) ?? _updatedText.firstMatch(line);
    if (text != null) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(text.group(1)!, style: theme.typography.body),
        ),
      );
      continue;
    }

    final tagged = _taggedBlock.firstMatch(line);
    if (tagged != null) {
      final checkMark = tagged.group(1);
      final tag = tagged.group(2)!;
      final content = tagged.group(3)!;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: switch (tag) {
            'Quote' => Text(
              content,
              style: theme.typography.body.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            'Checkbox' => Text(
              '${checkMark == '[x] ' ? '☑' : '☐'} $content',
              style: theme.typography.body,
            ),
            'Numbered' => Text('•  $content', style: theme.typography.body),
            _ => Text('$content  ($tag)', style: theme.typography.body),
          },
        ),
      );
      continue;
    }

    if (line.contains('[Dataview]') || line.startsWith('(could not decode')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '[unsupported block]',
            style: theme.typography.bodySmall.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      );
      continue;
    }

    // Metadata / replay diagnostics (object id, change ids, details).
    widgets.add(
      Text(
        line,
        style: theme.typography.code.copyWith(
          fontSize: 11,
          color: theme.colors.mutedForeground,
        ),
      ),
    );
  }
  return widgets;
}
