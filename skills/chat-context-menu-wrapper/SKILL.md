---
name: chat-context-menu-wrapper
description: >-
  Use when implementing or editing ChatContextMenuWrapper, chat bubble
  context menus, barrier cutouts, menu animation, ChatContextMenuAnimationStyle,
  or ChatContextMenuHorizontalShape / ChatContextMenuVerticalShape.
---

# ChatContextMenuWrapper

Import only the barrel. Never import `package:chat_context_menu/src/...`.

```dart
import 'package:chat_context_menu/chat_context_menu.dart';
```

This skill covers `ChatContextMenuWrapper` and the types it shares
(`ChatContextMenuAnimationStyle`, builder typedefs, exported shapes). For
selectable chat text, use `chat-context-menu-selectable-text`.

## Rules

* Always pass **both** builders. `widgetBuilder` is `(context, showMenu, hideMenu)`
  (three arguments since 3.0.0). `menuBuilder` is `(context, hideMenu)`.
* Wire the trigger yourself on the anchor (`onLongPress`, `onPressed`, right-click).
  `ChatContextMenuWrapper` has **no** trigger-mode constructor parameters.
  Do not pass `MobileTriggerMode`, `DesktopTriggerMode`, or `barrierDismissible`.
* Call `hideMenu()` from a menu item after the action. `hideMenu` from
  `widgetBuilder` is a no-op when the menu is not open.
* For a chat-bubble cutout: set a **non-transparent** `barrierColor` **and**
  `excludeAnchorFromBarrier: true`. Match `barrierAnchorBorderRadius` to the
  bubble radius. A transparent barrier never punches a hole, even if
  `excludeAnchorFromBarrier` is true.
* Nested Navigator / clipped desktop pane: `useRootNavigator: true`.
* A non-null `transitionsBuilder` overrides both built-in animation styles.
  Its signature **includes** `secondaryAnimation`. Duration override is
  `transitionDurations` (plural).
* Wrap only the visual anchor. The package measures the outer `Listener` around
  `widgetBuilder`; wrapping a large parent makes an oversized hole.

## Implement

1. Add `chat_context_menu` and import the barrel.
2. Wrap the anchor with `ChatContextMenuWrapper`.
3. In `widgetBuilder`, return the bubble/button and call `showMenu` from the
   intended gesture.
4. In `menuBuilder`, return any widget (row, column, custom pane). Close with
   `hideMenu()`.
5. Tune barrier, axis, animation, and nested-navigator flags as needed.
6. Before finishing, confirm the constructor against
   [references/wrapper-api.md](references/wrapper-api.md). Do not copy README
   property tables; they can lag the source.

## Examples

### Long-press chat bubble

```dart
import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.text, required this.isMe});

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BorderRadius bubbleRadius = BorderRadius.circular(8);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ChatContextMenuWrapper(
        barrierColor: Colors.black26,
        excludeAnchorFromBarrier: true,
        barrierAnchorBorderRadius: bubbleRadius,
        backgroundColor: colors.surface,
        borderRadius: BorderRadius.circular(10),
        spacing: 2,
        shadows: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.15),
            blurRadius: 32,
          ),
        ],
        menuBuilder: (BuildContext context, VoidCallback hideMenu) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  hideMenu();
                },
                child: const Text('Copy'),
              ),
              TextButton(onPressed: hideMenu, child: const Text('Delete')),
            ],
          );
        },
        widgetBuilder: (
          BuildContext context,
          VoidCallback showMenu,
          VoidCallback hideMenu,
        ) {
          return GestureDetector(
            onLongPress: showMenu,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? colors.primary : colors.surfaceContainerHighest,
                borderRadius: bubbleRadius,
              ),
              child: Text(
                text,
                style: TextStyle(color: isMe ? colors.onPrimary : null),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### AppBar action (set `topPadding` to 0)

```dart
ChatContextMenuWrapper(
  backgroundColor: Theme.of(context).colorScheme.surface,
  spacing: 0,
  topPadding: 0,
  widgetBuilder: (
    BuildContext context,
    VoidCallback showMenu,
    VoidCallback hideMenu,
  ) {
    return IconButton(icon: const Icon(Icons.more_vert), onPressed: showMenu);
  },
  menuBuilder: (BuildContext context, VoidCallback hideMenu) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(onPressed: hideMenu, child: const Text('Settings')),
      ],
    );
  },
)
```

### Built-in animation styles

```dart
ChatContextMenuWrapper(
  animationStyle: ChatContextMenuAnimationStyle.cupertinoSheet,
  // Optional: transitionDurations: const Duration(milliseconds: 400),
  widgetBuilder: (context, showMenu, hideMenu) { /* ... */ },
  menuBuilder: (context, hideMenu) { /* ... */ },
)
```

### Nested Navigator / clipped pane

```dart
ChatContextMenuWrapper(
  useRootNavigator: true,
  widgetBuilder: (context, showMenu, hideMenu) { /* ... */ },
  menuBuilder: (context, hideMenu) { /* ... */ },
)
```

### Custom `transitionsBuilder` (note `secondaryAnimation`)

```dart
ChatContextMenuWrapper(
  transitionsBuilder: (
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  },
  widgetBuilder: (context, showMenu, hideMenu) { /* ... */ },
  menuBuilder: (context, hideMenu) { /* ... */ },
)
```

## References

* Constructor fields and `createState`: [references/wrapper-api.md](references/wrapper-api.md)
* `ChatContextMenuAnimationStyle` and exported `ShapeBorder` types:
  [references/animation-and-shapes-api.md](references/animation-and-shapes-api.md)
* Typedefs and unused trigger enums:
  [references/typedefs-and-enums.md](references/typedefs-and-enums.md)
