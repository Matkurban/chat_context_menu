# Chat Context Menu

A Flutter package that provides an iOS-style chat context menu with customizable appearance and animations. This package handles the positioning, arrow indicator, and background blur/dimming, allowing you to provide any widget as the menu content.

## Features

*   **iOS-style Context Menu:** Smooth animations and layout similar to native iOS context menus.
*   **Automatic Positioning:** The menu is automatically positioned near the target widget, with smart overflow handling.
*   **Arrow Indicator:** An optional arrow points to the target widget.
*   **Customizable Appearance:** Configure background color, border radius, and barrier color.
*   **Flexible Content:** You provide the widget for the menu content, giving you full control over the items and layout.
*   **Easy Integration:** Wrap any widget with `ChatContextMenuWrapper` to enable the context menu.

## Screenshots

|               Light Mode                |                 Dark Mode                 |
|:---------------------------------------:|:-----------------------------------------:|
| ![Screenshot 1](doc/screenshot/img.png) | ![Screenshot 2](doc/screenshot/img_1.png) |

## Getting started

Add `chat_context_menu` to your `pubspec.yaml`:

```yaml
dependencies:
  chat_context_menu: ^1.0.0
```

## Usage

Wrap the widget you want to trigger the menu (usually a chat bubble) with `ChatContextMenuWrapper`.

```dart
import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatMessage({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return ChatContextMenuWrapper(
      // Customize the menu appearance
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      
      // Build the menu content
      menuBuilder: (context, hideMenu) {
        return Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  hideMenu();
                  print('Reply tapped');
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  hideMenu();
                  print('Copy tapped');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  hideMenu();
                  print('Delete tapped');
                },
              ),
            ],
          ),
        );
      },
      // Build the child widget and provide the showMenu callback
      widgetBuilder: (context, showMenu) {
        return GestureDetector(
          onLongPress: showMenu,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(message),
          ),
        );
      },
    );
  }
}
```

## Customization

You can customize the `ChatContextMenuWrapper` with the following properties:

*   `menuBuilder`: A builder function that returns the widget to display in the menu. It provides a `hideMenu` callback.
*   `barrierColor`: Color of the background overlay.
*   `backgroundColor`: Background color of the menu container.
*   `borderRadius`: Border radius of the menu container.
*   `padding`: Padding inside the menu container.

## Additional information

For more details, check the `example` folder in the repository.

