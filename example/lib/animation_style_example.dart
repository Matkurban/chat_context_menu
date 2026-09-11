import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:example/context_menu_pane.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

///对照 [ChatContextMenuAnimationStyle.scaleFade] 与
///[ChatContextMenuAnimationStyle.cupertinoSheet] 的测试页。
class AnimationStylePage extends StatefulWidget {
  const AnimationStylePage({super.key});

  @override
  State<AnimationStylePage> createState() => _AnimationStylePageState();
}

class _AnimationStylePageState extends State<AnimationStylePage> {
  ChatContextMenuAnimationStyle _style =
      ChatContextMenuAnimationStyle.scaleFade;

  static const List<String> _messages = <String>[
    'Long-press this bubble (left, vertical menu).',
    'Long-press this bubble (right, vertical menu).',
    'Switch the style above, then open the menu again.',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final Size size = MediaQuery.sizeOf(context);
    final Duration duration = _style.resolveDuration(null);

    return Scaffold(
      appBar: AppBar(title: const Text('Animation styles')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SegmentedButton<ChatContextMenuAnimationStyle>(
            segments: const <ButtonSegment<ChatContextMenuAnimationStyle>>[
              ButtonSegment<ChatContextMenuAnimationStyle>(
                value: ChatContextMenuAnimationStyle.scaleFade,
                label: Text('scaleFade'),
                icon: Icon(Icons.tune),
              ),
              ButtonSegment<ChatContextMenuAnimationStyle>(
                value: ChatContextMenuAnimationStyle.cupertinoSheet,
                label: Text('cupertinoSheet'),
                icon: Icon(Icons.animation),
              ),
            ],
            selected: <ChatContextMenuAnimationStyle>{_style},
            onSelectionChanged: (Set<ChatContextMenuAnimationStyle> next) {
              setState(() => _style = next.first);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'style: ${_style.name}  ·  duration: ${duration.inMilliseconds}ms',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'scaleFade keeps the current overlay fade+scale. '
            'cupertinoSheet bounces the menu in from the arrow like iOS.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text('Vertical menu', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (int index = 0; index < _messages.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: index.isEven
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: _buildBubbleMenu(
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  size: size,
                  text: _messages[index],
                  isMe: index.isOdd,
                  axis: Axis.vertical,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Horizontal menu', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildBubbleMenu(
              colorScheme: colorScheme,
              textTheme: textTheme,
              size: size,
              text: 'Long-press — menu opens to the side',
              isMe: false,
              axis: Axis.horizontal,
            ),
          ),
          const SizedBox(height: 24),
          Text('ChatSelectableText', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ChatSelectableText(
              'Long-press to select this text. The selection menu uses the same '
              'animationStyle as the bubbles above.',
              style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
              animationStyle: _style,
              menuBackgroundColor: colorScheme.surface,
              menuShadows: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  blurRadius: 32,
                ),
              ],
              menuBuilder: (context, selectedText, hideMenu, selectAll) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: selectedText));
                        hideMenu();
                      },
                      child: const Text('Copy'),
                    ),
                    TextButton(
                      onPressed: selectAll,
                      child: const Text('Select All'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleMenu({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Size size,
    required String text,
    required bool isMe,
    required Axis axis,
  }) {
    return ChatContextMenuWrapper(
      animationStyle: _style,
      barrierColor: Colors.black26,
      excludeAnchorFromBarrier: true,
      backgroundColor: colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      barrierAnchorBorderRadius: BorderRadius.circular(8),
      axis: axis,
      spacing: 2,
      shadows: [
        BoxShadow(
          color: colorScheme.onSurface.withValues(alpha: 0.15),
          blurRadius: 32,
        ),
      ],
      menuBuilder: (BuildContext context, void Function() hideMenu) {
        return ContextMenuPane(
          textTheme: textTheme,
          colorScheme: colorScheme,
          onReplayTap: hideMenu,
          onForwardTap: hideMenu,
          onCopyTap: hideMenu,
          onDeleteTap: hideMenu,
          onMoreTap: hideMenu,
          onQuoteTap: hideMenu,
          onSelectTap: hideMenu,
        );
      },
      widgetBuilder:
          (
            BuildContext context,
            void Function() showMenu,
            void Function() hideMenu,
          ) {
            return GestureDetector(
              onLongPress: showMenu,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                constraints: BoxConstraints(maxWidth: size.width * 0.7),
                decoration: BoxDecoration(
                  color: isMe
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMe ? colorScheme.onPrimary : null,
                  ),
                ),
              ),
            );
          },
    );
  }
}
