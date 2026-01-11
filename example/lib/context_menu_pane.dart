import 'package:flutter/material.dart';

class ContextMenuPane extends StatelessWidget {
  const ContextMenuPane({
    super.key,
    required this.textTheme,
    required this.colorScheme,
    this.onReplayTap,
    this.onCopyTap,
    this.onForwardTap,
    this.onDeleteTap,
    this.onQuoteTap,
    this.onSelectTap,
    this.onMoreTap,
  });

  final TextTheme textTheme;

  final ColorScheme colorScheme;

  final VoidCallback? onReplayTap;

  final VoidCallback? onCopyTap;

  final VoidCallback? onForwardTap;

  final VoidCallback? onDeleteTap;

  final VoidCallback? onQuoteTap;

  final VoidCallback? onSelectTap;

  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisSize: .min,
            children: [
              ContextMenuItem(
                icon: Icons.reply_outlined,
                label: 'Reply',
                colorScheme: colorScheme,
                onTap: onReplayTap,
              ),
              ContextMenuItem(
                icon: Icons.copy_outlined,
                label: 'Copy',
                colorScheme: colorScheme,
                onTap: onCopyTap,
              ),
              ContextMenuItem(
                icon: Icons.forward_outlined,
                label: 'Forward',
                colorScheme: colorScheme,
                onTap: onForwardTap,
              ),
              ContextMenuItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                colorScheme: colorScheme,
                onTap: onDeleteTap,
              ),
              ContextMenuItem(
                icon: Icons.format_quote_outlined,
                label: 'Quote',
                colorScheme: colorScheme,
                onTap: onQuoteTap,
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisSize: .min,
            children: [
              ContextMenuItem(
                icon: Icons.select_all_outlined,
                label: 'Select',
                colorScheme: colorScheme,
                onTap: onSelectTap,
              ),
              ContextMenuItem(
                icon: Icons.more_outlined,
                label: 'More',
                colorScheme: colorScheme,
                onTap: onMoreTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContextMenuItem extends StatelessWidget {
  const ContextMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    required this.colorScheme,
  });

  final IconData icon;

  final String label;

  final VoidCallback? onTap;

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: .symmetric(vertical: 4),
        width: 54,
        child: Column(
          spacing: 2,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurface),
            Text(
              label,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
