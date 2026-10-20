import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:material_ui/material_ui.dart';
import 'package:example/context_menu_pane.dart';

class ChatContextMenuPage extends StatefulWidget {
  const ChatContextMenuPage({super.key});

  @override
  State<ChatContextMenuPage> createState() => _ChatContextMenuPageState();
}

class _ChatContextMenuPageState extends State<ChatContextMenuPage> {
  ChatContextMenuPositionMode _positionMode = ChatContextMenuPositionMode.outside;
  Axis _axis = Axis.vertical;

  final List<String> _messages = [
    "Hello!",
    "Right-click or long-press anywhere on a bubble.",
    "Switch between 'outside' and 'pointer' above to compare menu positioning.",
    "Im Fine hah ",
    "and you?",
    "Im good too, thanks for asking.",
    "This is a long press / right click context menu demo.",
    "In 'pointer' mode, the menu and its arrow appear right where you clicked!",
    "This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.",
    "You can see different options.",
    "Like Reply, Copy, Forward, Delete.",
    "It mimics the iOS style context menu.",
    "Hope",
    "Like Reply, Copy, Forward, Delete.",
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Context Menu'),
        actions: [
          ChatContextMenuWrapper(
            backgroundColor: colorScheme.surface,
            spacing: 0,
            topPadding: 0,
            widgetBuilder:
                (BuildContext context, void Function() showMenu, void Function() hideMenu) {
                  return IconButton(icon: const Icon(Icons.more_vert), onPressed: showMenu);
                },
            shadows: [
              BoxShadow(color: colorScheme.onSurface.withValues(alpha: 0.15), blurRadius: 32),
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
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
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
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final isMe = index % 2 == 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: ChatContextMenuWrapper(
                          barrierColor: Colors.black26,
                          excludeAnchorFromBarrier: true,
                          backgroundColor: colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          barrierAnchorBorderRadius: BorderRadius.circular(8),
                          axis: _axis,
                          positionMode: _positionMode,
                          spacing: 2,
                          shadows: [
                            BoxShadow(
                              color: colorScheme.onSurface.withValues(alpha: 0.15),
                              blurRadius: 32,
                            ),
                          ],
                          menuBuilder: (context, hideMenu) {
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
                          widgetBuilder: (context, showMenu, hideMenu) {
                            return Material(
                              type: .transparency,
                              child: GestureDetector(
                                onLongPress: showMenu,
                                onSecondaryTap: showMenu,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  constraints: BoxConstraints(maxWidth: size.width * 0.7),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? colorScheme.primary
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _messages[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isMe ? colorScheme.onPrimary : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
