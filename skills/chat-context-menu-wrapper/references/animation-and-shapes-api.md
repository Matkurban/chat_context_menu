# Animation style and exported shapes

Source: `lib/src/model/menu_animation_style.dart`,
`lib/src/shape/chat_context_menu_horizontal_shape.dart`,
`lib/src/shape/chat_context_menu_vertical_shape.dart`.

All three types are exported from `package:chat_context_menu/chat_context_menu.dart`.

Prefer configuring menus through `ChatContextMenuWrapper` / `ChatSelectableText`
(`animationStyle`, `axis`, `arrowHeight`, `arrowWidth`, `borderRadius`). The
shape classes are the `ShapeBorder` implementations those widgets use internally.

## `ChatContextMenuAnimationStyle`

```dart
enum ChatContextMenuAnimationStyle {
  scaleFade,
  cupertinoSheet;
}
```

Used by both `ChatContextMenuWrapper.animationStyle` and
`ChatSelectableText.animationStyle`. A non-null `transitionsBuilder` on the
widget overrides both values.

### `scaleFade`

Default. Duration `150ms`. The overlay page uses one
`Curves.fastOutSlowIn` curve for both `FadeTransition` and `ScaleTransition`.
Scale origin is the pointer (or the anchor center) mapped to an `Alignment` in
the overlay.

On `ChatContextMenuWrapper` this runs in the route's `buildTransitions`. On
`ChatSelectableText` it wraps the menu overlay entry the same way.

### `cupertinoSheet`

Duration `335ms`. The route (or overlay) does **not** apply the page-level
fade+scale. Instead the menu widget itself uses `ChatContextMenuSheetTransition`:
open `Curves.easeOutBack`, close `Curves.easeInBack`, linear fade, scale from
the arrow edge (clamped so the scale factor stays in a valid range).

### `defaultDuration`

```dart
Duration get defaultDuration
```

| Value | Result |
| --- | --- |
| `scaleFade` | `Duration(milliseconds: 150)` |
| `cupertinoSheet` | `Duration(milliseconds: 335)` |

### `resolveDuration`

```dart
Duration resolveDuration(Duration? override) => override ?? defaultDuration;
```

`ChatContextMenuWrapper` calls this with `transitionDurations`.
`ChatSelectableText` calls this with `transitionDuration`.

## `ChatContextMenuHorizontalShape`

`ShapeBorder` for a menu sitting to the **left or right** of the anchor
(`Axis.horizontal`). The arrow is a triangle on the left or right edge.

`ArrowHorizontalDirection` is the type of `arrowDirection`. That enum lives in
`lib/src/model/arrow_horizontal_direction.dart` and is **not** re-exported from
the barrel. Do not import `src/` to construct this shape. Let the package
instantiate it.

### Constructor

```dart
const ChatContextMenuHorizontalShape({
  required this.arrowWidth,
  required this.arrowHeight,
  required this.arrowOffset,
  required this.arrowDirection,
  required this.borderRadius,
});
```

### Fields

| Field | Type | Meaning |
| --- | --- | --- |
| `arrowWidth` | `double` | Base of the triangle along the vertical menu edge. |
| `arrowHeight` | `double` | How far the tip sticks out (horizontal inset reserved in `dimensions`). |
| `arrowOffset` | `double` | Distance from the **top** of the rounded rect to the arrow tip. |
| `arrowDirection` | `ArrowHorizontalDirection` | `left`: tip points left (menu is on the right of the anchor). `right`: tip points right (menu is on the left of the anchor). |
| `borderRadius` | `BorderRadius` | Corners of the body, not including the arrow. |

### Methods

#### `dimensions`

```dart
@override
EdgeInsetsGeometry get dimensions
```

Returns `EdgeInsets.only(left: arrowHeight)` when the arrow points left, or
`EdgeInsets.only(right: arrowHeight)` when it points right. That inset is the
space reserved for the triangle.

#### `getInnerPath`

```dart
@override
Path getInnerPath(Rect rect, {TextDirection? textDirection})
```

Deflates `rect` by `dimensions` and returns a rounded-rect path using
`borderRadius` corners. No arrow on the inner path.

#### `getOuterPath`

```dart
@override
Path getOuterPath(Rect rect, {TextDirection? textDirection})
```

Builds the rounded body inset by `arrowHeight` on the arrow side, then unions a
closed triangular arrow whose tip lies on `rect.left` or `rect.right` at
`top + arrowOffset`.

#### `paint`

```dart
@override
void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
```

Empty. Fill and shadows come from `ShapeDecoration`, not from this method.

#### `scale`

```dart
@override
ShapeBorder scale(double t)
```

Returns a new `ChatContextMenuHorizontalShape` with `arrowWidth`, `arrowHeight`,
`arrowOffset`, and `borderRadius` multiplied by `t`. `arrowDirection` is
unchanged.

## `ChatContextMenuVerticalShape`

`ShapeBorder` for a menu sitting **above or below** the anchor
(`Axis.vertical`). The arrow is a triangle on the top or bottom edge.

The field is named `isArrowUp` but its type is `ArrowVerticalDirection`, **not**
`bool`. `ArrowVerticalDirection` is **not** barrel-exported. Do not import
`src/` to construct this shape.

### Constructor

```dart
const ChatContextMenuVerticalShape({
  required this.arrowWidth,
  required this.arrowHeight,
  required this.arrowOffset,
  required this.isArrowUp,
  required this.borderRadius,
});
```

### Fields

| Field | Type | Meaning |
| --- | --- | --- |
| `arrowWidth` | `double` | Base of the triangle along the horizontal menu edge. |
| `arrowHeight` | `double` | How far the tip sticks out (vertical inset reserved in `dimensions`). |
| `arrowOffset` | `double` | Distance from the **left** of the rounded rect to the arrow tip. |
| `isArrowUp` | `ArrowVerticalDirection` | `up`: tip points up (menu is below the anchor). `down`: tip points down (menu is above the anchor). |
| `borderRadius` | `BorderRadius` | Corners of the body, not including the arrow. |

### Methods

#### `dimensions`

```dart
@override
EdgeInsetsGeometry get dimensions
```

`EdgeInsets.only(top: arrowHeight)` when `isArrowUp == ArrowVerticalDirection.up`,
otherwise `EdgeInsets.only(bottom: arrowHeight)`.

#### `getInnerPath`

```dart
@override
Path getInnerPath(Rect rect, {TextDirection? textDirection})
```

Same pattern as the horizontal shape: deflate by `dimensions`, rounded rect,
no arrow.

#### `getOuterPath`

```dart
@override
Path getOuterPath(Rect rect, {TextDirection? textDirection})
```

Rounded body inset on the top or bottom by `arrowHeight`, unioned with a
triangle whose tip is on `rect.top` or `rect.bottom` at `left + arrowOffset`.

#### `paint`

```dart
@override
void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
```

Empty. Fill comes from `ShapeDecoration`.

#### `scale`

```dart
@override
ShapeBorder scale(double t)
```

Returns a new `ChatContextMenuVerticalShape` with `arrowWidth`, `arrowHeight`,
`arrowOffset`, and `borderRadius` multiplied by `t`. `isArrowUp` is unchanged.
