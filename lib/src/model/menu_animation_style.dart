///内置菜单出现/消失动画
///Built-in menu appearance animation
enum ChatContextMenuAnimationStyle {
  ///现有样式：150ms，同一条 [Curves.fastOutSlowIn] 做淡入 + 整页 [ScaleTransition]
  ///Current style: 150ms fade + overlay [ScaleTransition] with [Curves.fastOutSlowIn]
  scaleFade,

  ///Cupertino 操作菜单：335ms，打开 [Curves.easeOutBack] / 关闭 [Curves.easeInBack]，
  ///透明度线性，[Transform.scale] 作用在菜单本身、原点在箭头一侧
  ///Cupertino action sheet: 335ms, [Curves.easeOutBack] in / [Curves.easeInBack] out,
  ///linear fade, scale the menu widget from the arrow edge
  cupertinoSheet;

  ///该样式的默认动画时长
  ///Default duration for this style
  Duration get defaultDuration {
    return switch (this) {
      ChatContextMenuAnimationStyle.scaleFade => const Duration(milliseconds: 150),
      ChatContextMenuAnimationStyle.cupertinoSheet => const Duration(milliseconds: 335),
    };
  }

  ///调用方传入 [override] 时用之，否则用 [defaultDuration]
  ///Uses [override] when provided, otherwise [defaultDuration]
  Duration resolveDuration(Duration? override) => override ?? defaultDuration;
}
