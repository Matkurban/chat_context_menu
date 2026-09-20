# Typedefs and trigger-mode enums

Source: `lib/src/model/statement.dart`, `lib/src/model/menu_trigger_mode.dart`.
Exported from `package:chat_context_menu/chat_context_menu.dart`.

## `ContextMenuWidgetBuilder`

```dart
typedef ContextMenuWidgetBuilder = Widget Function(
  BuildContext context,
  VoidCallback showMenu,
  VoidCallback hideMenu,
);
```

Used only as `ChatContextMenuWrapper.widgetBuilder`.

* `showMenu` measures the wrapper's render box in the target overlay, pushes
  the menu route, and is ignored if a route is already open or the render box
  is missing.
* `hideMenu` pops or removes that route. If no route is stored, it returns
  immediately.

Since 3.0.0 the third argument is required. This is invalid:

```dart
widgetBuilder: (context, showMenu) { ... }
```

Use `_` if `hideMenu` is unused:

```dart
widgetBuilder: (context, showMenu, _) { ... }
```

## `ContextMenuContentBuilder`

```dart
typedef ContextMenuContentBuilder = Widget Function(
  BuildContext context,
  VoidCallback hideMenu,
);
```

Used only as `ChatContextMenuWrapper.menuBuilder`.

`ChatSelectableText.menuBuilder` is **not** this typedef. It is a four-argument
function `(context, selectedText, hideMenu, selectAll)`.

## `MobileTriggerMode`

```dart
enum MobileTriggerMode {
  tap,
  doubleTap,
  longPress,
}
```

| Value | Documented meaning in source |
| --- | --- |
| `tap` | Trigger on a single tap |
| `doubleTap` | Trigger on a double tap |
| `longPress` | Trigger on a long press |

**No public widget reads this enum.** `ChatContextMenuWrapper` does not take a
trigger-mode parameter. Attach `GestureDetector` / `InkWell` / `IconButton`
handlers in `widgetBuilder` instead. Do not pass `mobileTriggerMode:` to the
wrapper constructor.

## `DesktopTriggerMode`

```dart
enum DesktopTriggerMode {
  rightClick,
  leftClick,
}
```

| Value | Documented meaning in source |
| --- | --- |
| `rightClick` | Trigger on the secondary mouse button |
| `leftClick` | Trigger on the primary mouse button |

**No public widget reads this enum.** Same rule as `MobileTriggerMode`.
