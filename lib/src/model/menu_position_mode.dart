///菜单定位模式
///Menu positioning mode
enum ChatContextMenuPositionMode {
  ///默认模式：以包裹的组件（或文本选区）边界为基准，在组件外部计算显示位置；
  ///当组件尺寸超出可用空间放不下菜单时，回退到按压/点击位置。
  ///Default mode: positions the menu outside the wrapped widget (or text selection) bounds,
  ///falling back to the pointer position when the anchor is too large to fit the menu.
  outside,

  ///点击位置模式：直接以鼠标/手指按压坐标为锚点，从点击位置显示菜单（角标指向点击坐标）。
  ///Pointer mode: anchors the menu directly at the pointer/click position (with the arrow
  ///pointing to the clicked point).
  pointer,
}
