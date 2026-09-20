# ChatSelectableText API

Source of truth: `lib/src/ui/chat_selectable_text.dart`.
Exported from `package:chat_context_menu/chat_context_menu.dart`.

`ChatSelectableText` is a `StatefulWidget`. It has **no** public instance
methods besides the constructor and `createState()`. Selection is driven by
built-in gestures; menu actions go through `menuBuilder`.

State is private (`_ChatSelectableTextState`). Callers cannot obtain a
controller or call `selectAll` from outside the `menuBuilder` callback.

## Constructor

```dart
const ChatSelectableText(
  this.data, {
  super.key,
  this.style,
  this.textAlign = TextAlign.start,
  this.textDirection,
  this.maxLines,
  this.overflow = TextOverflow.clip,
  this.textScaler = TextScaler.noScaling,
  this.textWidthBasis = TextWidthBasis.parent,
  this.textHeightBehavior,
  this.strutStyle,
  this.locale,
  this.softWrap = true,
  this.selectAllOnActivate = true,
  this.selectionColor,
  this.handleColor,
  this.handleSize = 16.0,
  this.autoScrollEdgeExtent = 0.0,
  this.autoScrollSpeed = 10.0,
  this.enableHapticFeedback = true,
  required this.menuBuilder,
  this.onSelectionChanged,
  this.onMenuClosed,
  this.transitionsBuilder,
  this.animationStyle = ChatContextMenuAnimationStyle.scaleFade,
  this.transitionDuration,
  this.menuBackgroundColor,
  this.menuBorderRadius = const BorderRadius.all(Radius.circular(8)),
  this.menuPadding = const EdgeInsets.all(8),
  this.menuShadows,
  this.arrowHeight = 8.0,
  this.arrowWidth = 12.0,
  this.spacing = 0.0,
  this.horizontalMargin = 10.0,
  this.axis = Axis.vertical,
  this.useRootOverlay = false,
});
```

`data` is positional. There is no `widgetBuilder`. There is no
`useRootNavigator`, no `barrierColor`, and no `transitionDurations`.

## Fields

### `data`

- Type: `String`
- Required: yes (positional)
- Text content. Rendered as a single `TextSpan`. Changing `data` while
  selection is active deactivates selection.

### `style`

- Type: `TextStyle?`
- Default: `null`
- Merged with `DefaultTextStyle` when null or when `style.inherit` is true
  (`defaultTextStyle.style.merge(effectiveStyle)`). Changing `style` while
  selection is active deactivates selection.

### `textAlign`

- Type: `TextAlign`
- Default: `TextAlign.start`
- Passed to `RichText` and `TextPainter`.

### `textDirection`

- Type: `TextDirection?`
- Default: `null` → `Directionality.of(context)`
- Passed to `RichText` and `TextPainter`.

### `maxLines`

- Type: `int?`
- Default: `null`
- Passed to `RichText` and `TextPainter`. `null` means unlimited.

### `overflow`

- Type: `TextOverflow`
- Default: `TextOverflow.clip`
- Passed to `RichText` only (`TextPainter` is laid out to the render box
  width).

### `textScaler`

- Type: `TextScaler`
- Default: `TextScaler.noScaling`
- Passed to `RichText` and `TextPainter`.

### `textWidthBasis`

- Type: `TextWidthBasis`
- Default: `TextWidthBasis.parent`
- Passed to `RichText` and `TextPainter`.

### `textHeightBehavior`

- Type: `TextHeightBehavior?`
- Default: `null`
- Passed to `RichText` and `TextPainter`.

### `strutStyle`

- Type: `StrutStyle?`
- Default: `null`
- Passed to `RichText` and `TextPainter`.

### `locale`

- Type: `Locale?`
- Default: `null`
- Passed to `RichText` and `TextPainter`.

### `softWrap`

- Type: `bool`
- Default: `true`
- Passed to `RichText`.

### `selectAllOnActivate`

- Type: `bool`
- Default: `true`
- Long-press and inactive right-click:
  - `true`: `TextSelection(baseOffset: 0, extentOffset: data.length)`
  - `false`: word at the press (`TextPainter.getWordBoundary`). Collapsed
    word ranges abort activation.
- Double-click, triple-click, and tap-while-active always select word /
  paragraph regardless of this flag.

### `selectionColor`

- Type: `Color?`
- Default: `null` → `Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)`
- Fill of the selection highlight `CustomPainter`.

### `handleColor`

- Type: `Color?`
- Default: `null` → `Theme.of(context).colorScheme.primary`
- Fill of the base and extent drag handles.

### `handleSize`

- Type: `double`
- Default: `16.0`
- Logical size of each handle widget. Also added into the gap used when
  placing the menu (`handleSize + spacing`).

### `autoScrollEdgeExtent`

- Type: `double`
- Default: **`0.0`**
- While dragging a handle, auto-scroll starts when the pointer is within this
  many pixels of the parent `Scrollable` viewport's top (dragging the base
  handle) or bottom (dragging the extent handle). `0.0` means the pointer
  must reach the viewport edge. Auto-scroll stops when the corresponding
  selection end hits offset `0` or `data.length`.

### `autoScrollSpeed`

- Type: `double`
- Default: `10.0`
- Pixels per ticker frame added to `ScrollPosition` while auto-scrolling
  (`jumpTo`, clamped to min/max extent).

### `enableHapticFeedback`

- Type: `bool`
- Default: `true`
- On the **first** activation (`!wasActive`), plays
  `HapticFeedback.mediumImpact`. Subsequent updates and mouse-drag finish
  (`haptic: false`) do not.

### `menuBuilder`

- Type:

  ```dart
  Widget Function(
    BuildContext context,
    String selectedText,
    VoidCallback hideMenu,
    VoidCallback selectAll,
  )
  ```

- Required: yes
- `selectedText` is the substring for the current `TextSelection`.
- `hideMenu` reverses the menu animation if it has progressed, then clears
  overlays and selection and calls `onMenuClosed`.
- `selectAll` sets the selection to the full string and refreshes handles and
  menu; it does **not** close the menu.

### `onSelectionChanged`

- Type: `ValueChanged<String>?`
- Default: `null`
- Called with the selected substring when the selection becomes non-empty
  after an update or activation. Not called for empty text.

### `onMenuClosed`

- Type: `VoidCallback?`
- Default: `null`
- Called from `_deactivateSelection` after overlays are removed and selection
  is collapsed. That includes barrier tap, `hideMenu()`, empty mouse-drag
  release, and `data`/`style` changes.

### `transitionsBuilder`

- Type:

  ```dart
  Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  ```

- Default: `null`
- Non-null **replaces** both built-in styles. Returning `null` from a call
  falls through to the built-in transition for `animationStyle`.
- **No** `secondaryAnimation` parameter. Do not use the wrapper's six-arg
  signature.

### `animationStyle`

- Type: `ChatContextMenuAnimationStyle`
- Default: `ChatContextMenuAnimationStyle.scaleFade`
- `scaleFade`: overlay fade+scale, `Curves.fastOutSlowIn`.
- `cupertinoSheet`: scale the menu from the arrow with `easeOutBack` /
  `easeInBack` and a linear fade.
- Ignored when `transitionsBuilder` is non-null and returns a widget.

### `transitionDuration`

- Type: `Duration?`
- Default: `null` → `animationStyle.resolveDuration(null)` (`150ms` /
  `335ms`)
- Passed to the menu `AnimationController`. Name is **singular**.

### `menuBackgroundColor`

- Type: `Color?`
- Default: `null`
- `ShapeDecoration` color of the menu shell (and arrow).

### `menuBorderRadius`

- Type: `BorderRadius`
- Default: `const BorderRadius.all(Radius.circular(8))`
- Menu body corners. Also used to keep the arrow offset clear of the corner
  radius.

### `menuPadding`

- Type: `EdgeInsets`
- Default: `const EdgeInsets.all(8)`
- Insets inside the menu shell. Positioning measures the **full shell**
  (padding + content), not content alone.

### `menuShadows`

- Type: `List<BoxShadow>?`
- Default: `null`
- Shadows on the menu `ShapeDecoration`.

### `arrowHeight`

- Type: `double`
- Default: `8.0`
- Arrow protrusion. Vertical menus add it to total height; horizontal menus
  add it to total width.

### `arrowWidth`

- Type: `double`
- Default: `12.0`
- Arrow base along the menu edge.

### `spacing`

- Type: `double`
- Default: **`0.0`**
- Extra gap between selection and menu, added to `handleSize`. Wrapper's
  default spacing is `6.0`; do not mix them up.

### `horizontalMargin`

- Type: `double`
- Default: `10.0`
- Minimum inset from overlay left/right when clamping the menu.

### `axis`

- Type: `Axis`
- Default: `Axis.vertical`
- `Axis.vertical`: menu above/below the selection. Prefers space above, then
  below; if neither side of the **full selection** fits, falls back to the
  press-position line as the anchor.
- `Axis.horizontal`: menu left/right of the selection. **Prefers the right
  side** (arrow points left). If neither side fits, falls back to a 1×1 rect
  at the press position.

Coordinates are overlay-local (`useRootOverlay` selects which overlay).

### `useRootOverlay`

- Type: `bool`
- Default: `false`
- `Overlay.of(context, rootOverlay: useRootOverlay)` for barrier, handles,
  and menu. `true` covers the window in nested-Navigator / `ClipRect` panes.
  Positioning always uses that overlay's coordinate space.

## Methods

### `createState`

```dart
@override
State<ChatSelectableText> createState() => _ChatSelectableTextState();
```

Returns the private State. Callers do not subclass or invoke this.

## Overlay and scroll behavior

* Barrier is a full-overlay translucent `GestureDetector` (`onTap: hideMenu`).
  There is no dim color and no hole cutout API on this widget.
* Handles are `CompositedTransformFollower`s on a `LayerLink` targeting the
  text. Dragging a handle updates the range and can auto-scroll.
* While the parent `Scrollable` reports scrolling, handles and menu are
  removed; they are restored when scrolling stops.
* Menu animation uses an `AnimationController` vsync'd on the State.

## Not part of this widget

| Name | Reality |
| --- | --- |
| `useRootNavigator` | Wrapper-only. Use `useRootOverlay`. |
| `transitionDurations` | Wrapper-only. Use `transitionDuration`. |
| `widgetBuilder` / `ContextMenuContentBuilder` | Wrapper-only. |
| `barrierColor` / `excludeAnchorFromBarrier` | Wrapper-only. |
| `autoScrollEdgeExtent: 48.0` | Constructor default is `0.0`. |
| `spacing: 6.0` | Constructor default is `0.0`. |
