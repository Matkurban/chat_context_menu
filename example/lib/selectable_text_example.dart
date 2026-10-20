import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

///可选择文本自定义菜单示例
///Example page demonstrating ChatSelectableText
class ChatSelectableTextPage extends StatefulWidget {
  const ChatSelectableTextPage({super.key});

  @override
  State<ChatSelectableTextPage> createState() => _ChatSelectableTextPageState();
}

class _ChatSelectableTextPageState extends State<ChatSelectableTextPage> {
  String _lastSelectedText = '';
  ChatContextMenuPositionMode _positionMode = ChatContextMenuPositionMode.outside;
  Axis _axis = Axis.vertical;

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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<ChatContextMenuPositionMode>(
                segments: const <ButtonSegment<ChatContextMenuPositionMode>>[
                  ButtonSegment<ChatContextMenuPositionMode>(
                    value: ChatContextMenuPositionMode.outside,
                    label: Text('outside'),
                    icon: Icon(Icons.crop_free),
                  ),
                  ButtonSegment<ChatContextMenuPositionMode>(
                    value: ChatContextMenuPositionMode.pointer,
                    label: Text('pointer'),
                    icon: Icon(Icons.mouse),
                  ),
                ],
                selected: <ChatContextMenuPositionMode>{_positionMode},
                onSelectionChanged: (Set<ChatContextMenuPositionMode> selection) {
                  setState(() => _positionMode = selection.first);
                },
              ),
              SegmentedButton<Axis>(
                segments: const <ButtonSegment<Axis>>[
                  ButtonSegment<Axis>(
                    value: Axis.vertical,
                    label: Text('vertical'),
                    icon: Icon(Icons.swap_vert),
                  ),
                  ButtonSegment<Axis>(
                    value: Axis.horizontal,
                    label: Text('horizontal'),
                    icon: Icon(Icons.swap_horiz),
                  ),
                ],
                selected: <Axis>{_axis},
                onSelectionChanged: (Set<Axis> selection) {
                  setState(() => _axis = selection.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          ///基础用法
          Text('Basic Usage (Custom Selection)', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ChatSelectableText(
              'Long-press, right-click, double-click, or drag with the mouse to select text. '
              'Toggle between outside and pointer mode above to see the menu anchor either '
              'outside the selection bounds or directly at your click position.',
              style: TextStyle(fontSize: 24, color: colorScheme.onSurface),
              menuBackgroundColor: colorScheme.surface,
              handleSize: 24,
              axis: _axis,
              positionMode: _positionMode,
              menuShadows: [
                BoxShadow(color: colorScheme.onSurface.withValues(alpha: 0.15), blurRadius: 32),
              ],
              menuBuilder: (context, selectedText, hideMenu, selectAll) {
                return _buildMenuPane(
                  colorScheme: colorScheme,
                  selectedText: selectedText,
                  hideMenu: hideMenu,
                  selectAll: selectAll,
                );
              },
              onSelectionChanged: (text) {
                setState(() => _lastSelectedText = text);
              },
            ),
          ),

          const SizedBox(height: 24),

          ///长文本
          Text('Long Text (Scrollable)', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ChatSelectableText(
              'Flutter is Google\'s UI toolkit for building natively compiled applications '
              'for mobile, web, and desktop from a single codebase. Flutter works with existing '
              'code, is used by developers and organizations around the world, and is free and '
              'open source. Flutter uses Dart as its programming language. Dart is a client-optimized '
              'language for fast apps on any platform. It is developed by Google and is used to build '
              'mobile, desktop, server, and web applications. Dart is an object-oriented, class-based, '
              'garbage-collected language with C-style syntax. Dart can compile to either native code '
              'or JavaScript. It supports interfaces, mixins, abstract classes, reified generics, and '
              'type inference. Flutter provides a rich set of widgets that implement Material Design and '
              'Cupertino (iOS-style) design patterns. These widgets look and feel native on each platform.',
              style: TextStyle(fontSize: 22, color: colorScheme.onSurface),
              menuBackgroundColor: colorScheme.surface,
              axis: _axis,
              positionMode: _positionMode,
              menuShadows: [
                BoxShadow(color: colorScheme.onSurface.withValues(alpha: 0.15), blurRadius: 32),
              ],
              menuBuilder: (context, selectedText, hideMenu, selectAll) {
                debugPrint('Selected text: $selectedText');
                return _buildMenuPane(
                  colorScheme: colorScheme,
                  selectedText: selectedText,
                  hideMenu: hideMenu,
                  selectAll: selectAll,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          ///聊天气泡
          Text('Chat Bubble Example', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildChatBubble(
            text: 'ChatSelectableText makes text selection easy with built-in handles and mouse/touch gestures.',
            isMe: false,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _buildChatBubble(
            text: 'And the custom menu looks great in both outside and pointer modes!',
            isMe: true,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _buildChatBubble(text: 'And', isMe: true, colorScheme: colorScheme),

          const SizedBox(height: 24),

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
                style: TextStyle(fontSize: 14, color: colorScheme.onPrimaryContainer),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ChatSelectableText(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
          axis: _axis,
          positionMode: _positionMode,
          menuBackgroundColor: colorScheme.surface,
          menuShadows: [
            BoxShadow(color: colorScheme.onSurface.withValues(alpha: 0.15), blurRadius: 32),
          ],
          menuBuilder: (context, selectedText, hideMenu, selectAll) {
            return _buildMenuPane(
              colorScheme: colorScheme,
              selectedText: selectedText,
              hideMenu: hideMenu,
              selectAll: selectAll,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuPane({
    required ColorScheme colorScheme,
    required String selectedText,
    required VoidCallback hideMenu,
    required VoidCallback selectAll,
  }) {
    return Material(
      type: .transparency,
      child: Row(
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
            onTap: selectAll,
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
      ),
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
            Text(label, style: TextStyle(color: colorScheme.onSurface, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
