import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:example/app_theme.dart';
import 'package:example/context_menu_pane.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Context Menu',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: .system,
      debugShowCheckedModeBanner: false,
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
    "You can see different options.",
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

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Context Menu')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                      axis: .horizontal,
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
                      widgetBuilder: (context, showMenu) {
                        return GestureDetector(
                          onLongPress: showMenu,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
