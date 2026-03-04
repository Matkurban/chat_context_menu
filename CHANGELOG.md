# Chat Context Menu ChangeLog

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
