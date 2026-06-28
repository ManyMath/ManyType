import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:manyui/manyui.dart';
import 'package:manyui_hooks/manyui_hooks.dart';

/// Prompts for a single-line text value, seeded with [initialValue].
/// Returns the trimmed new value, or null if cancelled or unchanged.
Future<String?> promptEditAccountField(
  BuildContext context, {
  required String title,
  required String label,
  required String? initialValue,
}) async {
  final theme = MTheme.of(context);
  return showMDialog<String>(
    context,
    builder: (BuildContext ctx) => _EditFieldDialog(
      theme: theme,
      title: title,
      label: label,
      initialValue: initialValue ?? '',
    ),
  );
}

class _EditFieldDialog extends HookWidget {
  const _EditFieldDialog({
    required this.theme,
    required this.title,
    required this.label,
    required this.initialValue,
  });

  final MThemeData theme;
  final String title;
  final String label;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    final controller = useMController<String>(initialValue);
    final value = useState(initialValue);

    final bool valid = value.value.trim().isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: theme.typography.title),
          const SizedBox(height: 16),
          MLabel(label),
          const SizedBox(height: 8),
          MTextField(
            controller: controller,
            semanticLabel: label,
            onChanged: (v) => value.value = v,
            onSubmitted: (_) {
              if (valid) Navigator.of(context).pop(value.value.trim());
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              MButton(
                variant: MButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              MButton(
                onPressed: valid
                    ? () => Navigator.of(context).pop(value.value.trim())
                    : null,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
