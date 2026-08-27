# Chat Context Menu ChangeLog

## 3.2.0

* **`ChatContextMenuAnimationStyle`** — Built-in menu animations, default **`scaleFade`** (existing 150ms overlay fade+scale). New **`cupertinoSheet`** matches Flutter's Cupertino context-menu sheet (335ms, `easeOutBack` / `easeInBack`, linear fade, scale from the arrow). `transitionsBuilder` still overrides both. Optional `transitionDurations` / `transitionDuration` override the style default when non-null.
* **Example** — Third tab (`Animation`) compares the two styles on bubbles, a horizontal menu, and `ChatSelectableText`.
* **Tests** — Widget coverage for both styles, horizontal `cupertinoSheet`, custom `transitionsBuilder` not stacking the sheet transition, and duration overrides.

## 3.1.0

* **Nested Navigator / desktop multi-pane support** — Fixes broken menu positioning and clipping when the anchor lives inside a nested `Navigator` (e.g. desktop "sliding window" layouts where each pane hosts its own Navigator wrapped in `ClipRect`/`Transform.translate`/clipped `Material`).
  * **`useRootNavigator` on `ChatContextMenuWrapper`** (default `false`) — Pushes the menu route onto the root `Navigator` so the menu and barrier cover the whole window instead of being clipped to a single pane.
  * **`useRootOverlay` on `ChatSelectableText`** (default `false`) — Inserts selection handles, menu and barrier into the root `Overlay` for the same reason.
  * **Overlay-space coordinates everywhere** — The anchor rect and pointer position are now measured in the **target Navigator's Overlay coordinate space** (`localToGlobal(..., ancestor: overlayBox)`) instead of raw window coordinates, so menus position correctly regardless of which Navigator the route is pushed onto. Layouts and `buildTransitions` use the actual overlay size instead of `MediaQuery.of(context).size`.
  * **Clip-aware barrier cutout** — `clipAnchorRectForHole` (renamed from `clipAnchorGlobalRectForHole`) now walks the render tree from the anchor to the overlay and intersects with every clipping ancestor (`RenderAbstractViewport`, `ClipRect`/`ClipRRect`/`ClipOval`/`ClipPath`, `Material`/`PhysicalModel` with a non-none `clipBehavior`), so with `excludeAnchorFromBarrier: true` the hole never extends past the visible pane bounds.
  * Backward compatible: with a single full-window Navigator (typical mobile apps) the overlay origin equals the window origin, so behavior is unchanged. Internal `HoleModalDismissScrim.holeRectGlobal` was renamed to `holeRectLocal` and the `intersectHoleOverlayLocal` helper was removed (holes are already overlay-local).
* **Tests** — Added `test/nested_navigator_overlay_test.dart` covering a minimal sliding-pane reproduction (`ClipRect > OverflowBox > Transform.translate > panes with nested Navigators`): menu alignment with/without `useRootNavigator`, hole-barrier hit-testing across panes, clip-chain clamping, and `ChatSelectableText` with `useRootOverlay`.

## 3.0.1

* **Fix `ChatSelectableText` menu overflow** — Menu positioning now measures the full menu shell (`menuPadding` + content), matching `ChatContextMenuWrapper` / `ChatContextMenuVerticalLayout`. Previously only `menuBuilder` content was measured, so horizontal edge clamping underestimated the rendered width and the menu could extend past the screen edge (e.g. right-aligned chat bubbles).
* **Tests** — Added `test/chat_selectable_text_test.dart` to assert the menu stays within `horizontalMargin` at the screen edge.

## 3.0.0

* **BREAKING: `hideMenu` on `widgetBuilder`** — `ContextMenuWidgetBuilder` now receives a third `hideMenu` callback alongside `showMenu`. Callers must update their `widgetBuilder` signature; use `_` if the callback is not needed. `hideMenu` closes the menu only when it is already open (no-op otherwise), matching the behavior of `menuBuilder`'s `hideMenu`.
* **Tests** — Added a widget test verifying `hideMenu` from `widgetBuilder` when the menu is closed and when it is open.
* **Docs** — Updated README / README_ZH examples and customization notes for the new `widgetBuilder` API.

### Migration

```dart
// Before (2.x)
widgetBuilder: (context, showMenu) { ... }

// After (3.0.0)
widgetBuilder: (context, showMenu, hideMenu) { ... }
```

## 2.3.0

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
