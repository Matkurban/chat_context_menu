# ChatContextMenuWrapper API

Source of truth: `lib/src/ui/chat_context_menu_wrapper.dart`.
Exported from `package:chat_context_menu/chat_context_menu.dart`.

`ChatContextMenuWrapper` is a `StatefulWidget`. It has **no** public instance
methods besides the constructor and `createState()`. Menu show/hide is done
through the callbacks passed into `widgetBuilder` / `menuBuilder`.

The widget wraps `widgetBuilder` in a `Listener` (`HitTestBehavior.translucent`)
that records the latest pointer-down position. That point is converted into the
target Navigator overlay coordinate space and used as `pointerRect` when placing
the menu.

Pushing the menu uses `Navigator.of(context, rootNavigator: useRootNavigator)`.
If a route is already open (`_route != null`), a second `showMenu` is ignored.
On dispose, an active route is removed from its navigator.

`hideMenu` pops when the route `isCurrent`, otherwise `removeRoute`. After the
future from `navigator.push` completes, `onClose` is invoked with the pop
result (if the State is still mounted).

## Constructor

```dart
const ChatContextMenuWrapper({
  super.key,
  required this.widgetBuilder,
  required this.menuBuilder,
  this.barrierColor = Colors.transparent,
  this.backgroundColor,
  this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  this.padding = const EdgeInsets.all(8),
  this.requestFocus = false,
  this.shadows,
  this.arrowHeight = 8.0,
  this.arrowWidth = 12.0,
  this.spacing = 6.0,
  this.animationStyle = ChatContextMenuAnimationStyle.scaleFade,
  this.transitionsBuilder,
  this.transitionDurations,
  this.onClose,
  this.horizontalMargin = 10.0,
  this.menuConstraints,
  this.layoutConstraints,
  this.axis = Axis.vertical,
  this.topPadding = kToolbarHeight,
  this.excludeAnchorFromBarrier = false,
  this.barrierAnchorPadding = EdgeInsets.zero,
  this.barrierAnchorBorderRadius,
  this.useRootNavigator = false,
});
```

There is **no** `barrierDismissible` parameter. There are **no**
`mobileTriggerMode` / `desktopTriggerMode` parameters.

## Fields

### `widgetBuilder`

- Type: `ContextMenuWidgetBuilder` → `Widget Function(BuildContext context, VoidCallback showMenu, VoidCallback hideMenu)`
- Required: yes
- Builds the on-page anchor. Call `showMenu` from a gesture or button.
  `hideMenu` closes an open menu and is a no-op when the menu is not open.

### `menuBuilder`

- Type: `ContextMenuContentBuilder` → `Widget Function(BuildContext context, VoidCallback hideMenu)`
- Required: yes
- Builds the floating menu content. The returned widget is wrapped in a
  transparent `Material` before it is shown. Call `hideMenu()` after a menu
  action.

### `barrierColor`

- Type: `Color`
- Default: `Colors.transparent`
- Modal overlay color. Hole-barrier painting and the in-route dismiss scrim
  run only when `excludeAnchorFromBarrier` is true **and** this color's alpha
  is not 0 (`(_barrierColor?.a ?? 0) != 0`).

### `backgroundColor`

- Type: `Color?`
- Default: `null`
- Fill color of the menu shell. Also tints the arrow (the arrow is part of the
  same `ShapeDecoration`).

### `borderRadius`

- Type: `BorderRadius`
- Default: `const BorderRadius.all(Radius.circular(8))`
- Corner radii of the menu container (not the bubble). For a matching cutout
  on the **anchor**, set `barrierAnchorBorderRadius` separately.

### `padding`

- Type: `EdgeInsets`
- Default: `const EdgeInsets.all(8)`
- Insets inside the menu container around `menuBuilder`'s widget.

### `requestFocus`

- Type: `bool`
- Default: `false`
- When `true`, showing the menu takes focus so other focused widgets on the
  page lose focus. Forwarded to the underlying `PageRoute`.

### `shadows`

- Type: `List<BoxShadow>?`
- Default: `null`
- Shadows on the menu `ShapeDecoration`. `null` means no extra shadows.

### `arrowHeight`

- Type: `double`
- Default: `8.0`
- Length of the pointing triangle (how far the arrow sticks out toward the
  anchor). Vertical menus reserve this on the top or bottom; horizontal menus
  reserve it on the left or right.

### `arrowWidth`

- Type: `double`
- Default: `12.0`
- Width of the arrow base along the menu edge.

### `spacing`

- Type: `double`
- Default: `6.0`
- Gap between the menu (including arrow) and the measured anchor rect.

### `animationStyle`

- Type: `ChatContextMenuAnimationStyle`
- Default: `ChatContextMenuAnimationStyle.scaleFade`
- Built-in appearance. Ignored when `transitionsBuilder` is non-null.
  See [animation-and-shapes-api.md](animation-and-shapes-api.md).

### `transitionsBuilder`

- Type:

  ```dart
  Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  ```

- Default: `null`
- Custom route transition. Non-null **replaces** both `scaleFade` and
  `cupertinoSheet`. Returning `null` from the callback falls through to the
  default fade+scale (`Curves.fastOutSlowIn`) in `buildTransitions`.
- This signature **includes** `secondaryAnimation`. Do not copy the
  `ChatSelectableText.transitionsBuilder` signature here.
- `centerOffset` is the pointer center when known, otherwise the anchor
  center, in overlay coordinates. `alignment` is that point mapped to
  `Alignment` using the overlay size.

### `transitionDurations`

- Type: `Duration?`
- Default: `null`
- When non-null, used as the route `transitionDuration`. When `null`,
  `animationStyle.resolveDuration(null)` is used (`150ms` for `scaleFade`,
  `335ms` for `cupertinoSheet`).
- Name is **plural**. `ChatSelectableText` uses `transitionDuration`
  (singular).

### `onClose`

- Type: `void Function(dynamic result)?`
- Default: `null`
- Invoked after the menu route is popped or removed, with the `Navigator.push`
  future's value. Not called if the wrapper State is unmounted.

### `horizontalMargin`

- Type: `double`
- Default: `10.0`
- Minimum inset from the overlay's left and right edges when placing the menu.

### `menuConstraints`

- Type: `BoxConstraints?`
- Default: `null`
- Constraints applied to the menu container widget.

### `layoutConstraints`

- Type: `BoxConstraints?`
- Default: `null`
- Optional override of available space used when deciding vertical/horizontal
  placement. When `null`, layout uses overlay/screen metrics.

### `axis`

- Type: `Axis`
- Default: `Axis.vertical`
- `Axis.vertical`: menu above or below the anchor, vertical arrow.
- `Axis.horizontal`: menu to the left or right of the anchor, horizontal arrow.

### `topPadding`

- Type: `double`
- Default: `kToolbarHeight`
- Extra top inset treated as occupied (AppBar). Set to `0` when the wrapper
  itself lives in an `AppBar`.

### `excludeAnchorFromBarrier`

- Type: `bool`
- Default: `false`
- When `false`, Flutter's usual full-sheet modal barrier dims the whole
  overlay, including the anchor.
- When `true` **and** `barrierColor` is non-transparent, the barrier paints a
  hole over the clipped anchor rect (plus `barrierAnchorPadding`) and an
  in-route dismiss scrim closes the menu on shaded taps. The hole is clamped
  to clipping ancestors (scroll viewport, `ClipRect` / `ClipRRect`, clipped
  `Material`, and the overlay) so a tall list item does not brighten UI
  outside the visible pane.

### `barrierAnchorPadding`

- Type: `EdgeInsets`
- Default: `EdgeInsets.zero`
- Inflates (or shrinks, with negative insets) the hole around the measured
  anchor rect. Only meaningful with the hole barrier.

### `barrierAnchorBorderRadius`

- Type: `BorderRadius?`
- Default: `null`
- Corner radii of the punched hole. Match the bubble `BoxDecoration.borderRadius`.
  When `null`, the hole is a rectangle.

### `useRootNavigator`

- Type: `bool`
- Default: `false`
- `false`: push onto the nearest `Navigator` (typical mobile apps).
- `true`: push onto the root `Navigator` so the menu and barrier are not
  clipped by a pane `ClipRect` / nested navigator overlay.
- Anchor measurement always uses `localToGlobal(..., ancestor: overlayBox)` of
  the **chosen** navigator's overlay.

## Methods

### `createState`

```dart
@override
State<ChatContextMenuWrapper> createState() => _ChatContextMenuWrapperState();
```

Returns the private State. Callers do not subclass or invoke this.

## Not part of this widget

Do not invent these constructor names on `ChatContextMenuWrapper`:

| Name | Reality |
| --- | --- |
| `barrierDismissible` | Exists only on the unexported `ChatContextRoute`, default `true`. The wrapper never passes it, so tapping the dimmed area always dismisses. |
| `mobileTriggerMode` / `desktopTriggerMode` | Exported enums are unused by any widget. Bind gestures in `widgetBuilder`. |
| `useRootOverlay` | That flag is on `ChatSelectableText` only. |
| `transitionDuration` | Wrapper field is `transitionDurations`. |
