import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///文本选择示例页面
///Example page demonstrating ChatSelectableText
class ChatSelectableTextPage extends StatefulWidget {
  const ChatSelectableTextPage({super.key});

  @override
  State<ChatSelectableTextPage> createState() => _ChatSelectableTextPageState();
}

class _ChatSelectableTextPageState extends State<ChatSelectableTextPage> {
  String _lastSelectedText = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('ChatSelectableText Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ///基础用法
          ///Basic usage
          Text('Basic Usage (Long Press)', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ChatSelectableText(
              'This is a basic selectable text. Long press to select text and see the context menu appear. You can drag the handles to adjust the selection range.',
              style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
              menuBackgroundColor: colorScheme.surface,
              menuShadows: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  blurRadius: 32,
                ),
              ],
              menuBuilder: (context, selectedText, hideMenu) {
                return _buildMenuPane(
                  colorScheme: colorScheme,
                  selectedText: selectedText,
                  hideMenu: hideMenu,
                );
              },
              onSelectionChanged: (text) {
                setState(() => _lastSelectedText = text);
              },
            ),
          ),

          const SizedBox(height: 24),

          ///自定义颜色
          ///Custom colors
          Text('Custom Selection Color', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ChatSelectableText(
              'This example uses custom selection and handle colors. The selection highlight is orange and the handles are deep orange.',
              style: TextStyle(fontSize: 30, color: colorScheme.onSurface),
              selectionColor: Colors.orange.withValues(alpha: 0.35),
              handleColor: Colors.deepOrange,
              menuBackgroundColor: colorScheme.surface,
              menuShadows: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  blurRadius: 32,
                ),
              ],
              menuBuilder: (context, selectedText, hideMenu) {
                return _buildMenuPane(
                  colorScheme: colorScheme,
                  selectedText: selectedText,
                  hideMenu: hideMenu,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          ///双击触发
          ///Double tap trigger
          Text('Double Tap Trigger', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ChatSelectableText(
              'Double tap this text to trigger selection mode. This demonstrates the doubleTap trigger mode for mobile platforms.',
              style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
              mobileTriggerMode: MobileTriggerMode.doubleTap,
              menuBackgroundColor: colorScheme.surface,
              menuShadows: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  blurRadius: 32,
                ),
              ],
              menuBuilder: (context, selectedText, hideMenu) {
                debugPrint("选择的文本: $selectedText");
                return _buildMenuPane(
                  colorScheme: colorScheme,
                  selectedText: selectedText,
                  hideMenu: hideMenu,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          ///聊天气泡中的使用
          ///Usage in chat bubbles
          Text('Chat Bubble Example', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildChatBubble(
            text:
                'This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability.',
            isMe: false,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _buildChatBubble(
            text: 'That sounds great! I love how clean the architecture is.',
            isMe: true,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _buildChatBubble(
            text:
                'Yes, it also makes it easier to write unit tests and swap out implementations when needed.',
            isMe: false,
            colorScheme: colorScheme,
          ),

          const SizedBox(height: 24),

          ///显示最后选中的文本
          ///Show last selected text
          if (_lastSelectedText.isNotEmpty) ...[
            Text('Last Selected Text:', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _lastSelectedText,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildChatBubble({
    required String text,
    required bool isMe,
    required ColorScheme colorScheme,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ChatSelectableText(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
          selectionColor: isMe
              ? Colors.white.withValues(alpha: 0.3)
              : colorScheme.primary.withValues(alpha: 0.3),
          handleColor: isMe ? Colors.white : colorScheme.primary,
          menuBackgroundColor: colorScheme.surface,
          menuShadows: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.15),
              blurRadius: 32,
            ),
          ],
          menuBuilder: (context, selectedText, hideMenu) {
            return _buildMenuPane(
              colorScheme: colorScheme,
              selectedText: selectedText,
              hideMenu: hideMenu,
            );
          },
          onSelectionChanged: (text) {
            setState(() => _lastSelectedText = text);
          },
        ),
      ),
    );
  }

  Widget _buildMenuPane({
    required ColorScheme colorScheme,
    required String selectedText,
    required VoidCallback hideMenu,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MenuButton(
          icon: Icons.copy_outlined,
          label: 'Copy',
          colorScheme: colorScheme,
          onTap: () {
            Clipboard.setData(ClipboardData(text: selectedText));
            hideMenu();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        _MenuButton(
          icon: Icons.select_all_outlined,
          label: 'Select All',
          colorScheme: colorScheme,
          onTap: () {
            hideMenu();
          },
        ),
        _MenuButton(
          icon: Icons.search_outlined,
          label: 'Search',
          colorScheme: colorScheme,
          onTap: () {
            hideMenu();
          },
        ),
        _MenuButton(
          icon: Icons.share_outlined,
          label: 'Share',
          colorScheme: colorScheme,
          onTap: () {
            hideMenu();
          },
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.colorScheme,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurface),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
