---
name: chat-context-menu-selectable-text
description: >-
  Use when implementing or editing ChatSelectableText, chat bubble text
  selection, selection handles, copy/select-all menus, or selectable-text
  overlay menus.
---

# ChatSelectableText

Import only the barrel. Never import `package:chat_context_menu/src/...`.

```dart
import 'package:chat_context_menu/chat_context_menu.dart';
```

This is **not** Flutter's `SelectableText`. It renders with `RichText`,
computes geometry with `TextPainter`, and puts handles, menu, and a tap-to-
dismiss barrier into an `Overlay`.

For wrapping an arbitrary bubble (not selectable text), use
`chat-context-menu-wrapper`.

## Rules

* Required: positional `data` and `menuBuilder(context, selectedText, hideMenu, selectAll)`.
  That builder is **not** `ContextMenuContentBuilder` (which has only two args).
* Duration field is `transitionDuration` (singular). Custom animation is
  `transitionsBuilder` **without** `secondaryAnimation`. Do not copy
  `ChatContextMenuWrapper` signatures here.
* Nested Navigator / clipped pane: `useRootOverlay: true`. There is no
  `useRootNavigator` on this widget.
* Default `spacing` is `0.0`. Default `autoScrollEdgeExtent` is `0.0`. Do not
  use README tables for defaults.
* Changing `data` or `style` while selection is active deactivates selection
  (`didUpdateWidget`).
* `selectAll` updates the range and keeps the menu open. Call `hideMenu()` to
  dismiss.

## Gestures (built in)

| Input | Effect |
| --- | --- |
| Long-press | Activates selection. `selectAllOnActivate: true` (default) selects all text; `false` selects the word at the press. |
| Mouse left-drag | Mouse-only (`PointerDeviceKind.mouse`). Anchors at press (`DragStartBehavior.down`), updates live, shows handles+menu on release. Empty/collapsed selection deactivates. Touch drags still scroll parent lists. |
| Right-click (secondary) | If inactive: same activation as long-press. If already active: re-selects the word under the pointer. |
| Double-click | Selects the word at the pointer. |
| Triple-click | Selects the newline-delimited paragraph. |
| Tap while active | Re-selects the word under the pointer. |
| Tap the overlay barrier | Hides the menu and clears selection. |

Hover cursor is `SystemMouseCursors.text`. First activation plays
`HapticFeedback.mediumImpact` when `enableHapticFeedback` is true. Mouse-drag
completion does not haptic.

## Implement

1. Put `ChatSelectableText` where the bubble text belongs.
2. Implement `menuBuilder` with Copy (`Clipboard.setData` + `hideMenu`) and
   Select All (`selectAll`).
3. Style selection/handles with `selectionColor` / `handleColor` (null uses
   theme primary; selection highlight uses 30% alpha).
4. Set `axis`, `animationStyle`, and `useRootOverlay` when the layout needs them.
5. Confirm every field against
   [references/selectable-text-api.md](references/selectable-text-api.md).

## Examples

### Basic copy / select all

```dart
import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ChatSelectableText(
  'Long press to select text and open the menu.',
  style: const TextStyle(fontSize: 16),
  menuBackgroundColor: Colors.white,
  menuShadows: const [
    BoxShadow(color: Colors.black12, blurRadius: 32),
  ],
  menuBuilder: (
    BuildContext context,
    String selectedText,
    VoidCallback hideMenu,
    VoidCallback selectAll,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: selectedText));
            hideMenu();
          },
        ),
        IconButton(icon: const Icon(Icons.select_all), onPressed: selectAll),
      ],
    );
  },
)
```

### Word-only activation

```dart
ChatSelectableText(
  'Long press a word to select just that word.',
  selectAllOnActivate: false,
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
        TextButton(onPressed: selectAll, child: const Text('Select All')),
      ],
    );
  },
)
```

### Horizontal menu + Cupertino sheet

```dart
ChatSelectableText(
  'Drag, right-click, double-click, or triple-click.',
  axis: Axis.horizontal,
  animationStyle: ChatContextMenuAnimationStyle.cupertinoSheet,
  menuBuilder: (context, selectedText, hideMenu, selectAll) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(onPressed: hideMenu, child: const Text('Copy')),
        TextButton(onPressed: selectAll, child: const Text('Select All')),
      ],
    );
  },
)
```

### Nested Navigator overlay

```dart
ChatSelectableText(
  message,
  useRootOverlay: true,
  menuBuilder: (context, selectedText, hideMenu, selectAll) {
    return TextButton(onPressed: hideMenu, child: const Text('Copy'));
  },
)
```

### Custom `transitionsBuilder` (no `secondaryAnimation`)

```dart
ChatSelectableText(
  message,
  transitionsBuilder: (
    BuildContext context,
    Animation<double> animation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  },
  menuBuilder: (context, selectedText, hideMenu, selectAll) {
    return TextButton(onPressed: hideMenu, child: const Text('Copy'));
  },
)
```

## References

* Every constructor field, `createState`, gestures, and overlay behavior:
  [references/selectable-text-api.md](references/selectable-text-api.md)
* Shared `ChatContextMenuAnimationStyle` members:
  `chat-context-menu-wrapper` → `references/animation-and-shapes-api.md`
