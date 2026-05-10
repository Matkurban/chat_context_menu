# Chat Context Menu ChangeLog

## 2.2.0

* **Hole barrier and dismiss scrim** — When `excludeAnchorFromBarrier` is true and `barrierColor` is non-transparent, the modal uses a punched overlay plus an in-route full-screen dismiss layer (`HoleModalDismissScrim`) so taps on the dimmed area reliably close the menu (fixes hits not reaching the underlying barrier stack entry). Barrier painting remains in `HoleModalBarrier` (hit-test transparent); dismiss uses the same hole geometry as the visual cutout.
* **`barrierAnchorBorderRadius` on `ChatContextMenuWrapper`** — Optional `BorderRadius` for the anchor cutout so the hole can match rounded chat bubbles (`RRect` painting and hit testing via `anchoredHoleShape` / `intersectHoleOverlayLocal`).
* **Anchor rect clipping** — Before pushing the route, the anchor global `Rect` is clipped with `clipAnchorGlobalRectForHole`: intersect with the innermost `RenderAbstractViewport` (e.g. `ListView` viewport) and with `MediaQuery` size, so very tall list items no longer “punch” the overlay through the input bar or other UI below the scroll viewport.
* **Route `offstage` gating** — `_useHoleBarrier` no longer requires `!offstage`; the dismiss scrim stays in the page subtree while `Offstage` still suppresses interaction until the route is onstage.
* Example: `barrierAnchorBorderRadius` aligned with bubble decoration (`BorderRadius.circular(10)` in the chat demo).

## 2.1.0

* Add `ChatSelectableText` widget — a fully custom selectable text widget built from the ground up
  - Uses `RichText` for rendering, `TextPainter` for selection geometry, `OverlayEntry` for handles/menu, `CompositedTransformFollower` for positioning
  - Text selection with draggable handles (base & extent) for adjustable selection range
  - Customizable selection highlight color (`selectionColor`) and handle color (`handleColor`)
  - Context menu with arrow indicator, smart positioning with pointer-position fallback for long text
  - `selectAllOnActivate` property — when `true` (default), selects all text on activation; when `false`, selects the tapped word
  - `selectAll` callback provided in `menuBuilder` for programmatic select-all from the menu
  - Auto-scroll when dragging handles near viewport edges (`autoScrollEdgeExtent`, `autoScrollSpeed`)
  - Haptic feedback on selection activation (`enableHapticFeedback`)
  - Handle visibility — handles are automatically hidden when scrolled outside the viewport
  - Menu-only animation (text and selection appear immediately, only the menu panel animates)
  - Customizable menu appearance: `menuBackgroundColor`, `menuBorderRadius`, `menuPadding`, `menuShadows`
  - Customizable arrow: `arrowHeight`, `arrowWidth`, `spacing`, `horizontalMargin`
  - `onSelectionChanged` callback provides the currently selected text
  - `onMenuClosed` callback triggered when the menu is dismissed
  - Custom `transitionsBuilder` for menu animation

## 1.7.4

* transitionsBuilder add centerOffset parameter to control the animation origin point


## 1.7.3

* transitionsBuilder add alignment parameter to control the animation origin point

## 1.7.2

* Use pointer (finger press) position as anchor when the widget is taller than available space for the context menu

## 1.7.1

* Fix `CurvedAnimation` listener leak in route transitions — replaced with `animation.drive(CurveTween(...))`
* Fix `barrierDismissible` parameter being ignored (getter was hardcoded to `true`)
* Fix potential crash when widget is disposed while menu is closing (added `mounted` check)
* Add `dispose` to `ChatContextMenuWrapperState` to clean up active route on widget removal
* Rename `verticalMargin` to `horizontalMargin` in `ChatContextMenuHorizontalLayout` for correct semantics
* Fix `getInnerPath` in both shape classes to properly return inset path
* Remove unused `padding` parameter from `ChatContextMenuHorizontalShape`

## 1.7.0

** Add topPadding parameter

## 1.6.0

** Fix the issue of duplicate calculations in spacing

## 1.5.6

**The `constraints` parameter has been renamed to `menuConstraints`
** Added `layoutConstraints` parameter
** fix bug

## 1.5.1

** Export `shape` class

## 1.5.0

**Add `constraints` properties , to set maximum width and height for the context menu
** Add `axis` properties , to set the direction of the context menu (vertical or horizontal)

## 1.4.0

* add `onClose` callback , triggered when the context menu is closed
* add `horizontalMargin` properties , Minimum horizontal margin from screen edges

## 1.3.0

* Add custom shadows attribute
* Add custom corner mark width and height
* Add properties for custom display spacing
* Add custom animation properties

## 1.2.0

* update `requestFocus` parameter default `false`

## 1.1.0

* Added `requestFocus` parameter to `ChatContextMenuWrapper` to control focus behavior. Set it to `false` to prevent the menu from stealing focus from input fields.

## 1.0.0

* Initial release of `chat_context_menu`.
* Added `ChatContextMenuWrapper` for easy integration.
* Supported customizable menu content via `menuBuilder`.
* Implemented automatic positioning with arrow indicator.
* Added customization options for colors and border radius.
