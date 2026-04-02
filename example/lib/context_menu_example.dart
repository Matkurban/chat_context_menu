import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:example/context_menu_pane.dart';

class ChatContextMenuPage extends StatefulWidget {
  const ChatContextMenuPage({super.key});

  @override
  State<ChatContextMenuPage> createState() => _ChatContextMenuPageState();
}

class _ChatContextMenuPageState extends State<ChatContextMenuPage> {
  final List<String> _messages = [
    "Hello!",
    "Hello!",
    "How are you?",
    "Im Fine hah ",
    "and you?",
    "Im good too, thanks for asking.",
    "This is a long press context menu demo.",
    "Try long pressing on any message.",
    "Try long pressing on any message.",
    "This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.",
    "This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.This design pattern helps to separate presentation from business logic. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.",
    "You can see different options.",
    "Like Reply, Copy, Forward, Delete.",
    "It mimics the iOS style context menu.",
    "Hope",
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
            widgetBuilder: (BuildContext context, void Function() showMenu) {
              return IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: showMenu,
              );
            },
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
          ),
        ],
      ),
      body: Column(
        children: [
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
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ChatContextMenuWrapper(
                          barrierColor: Colors.transparent,
                          backgroundColor: colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          axis: .vertical,
                          // constraints: constraints,
                          // layoutConstraints: constraints,
                          spacing: 2,
                          shadows: [
                            BoxShadow(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.15,
                              ),
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
                          widgetBuilder: (context, showMenu) {
                            return GestureDetector(
                              onLongPress: showMenu,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: size.width * 0.7,
                                ),
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
