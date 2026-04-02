import 'package:chat_context_menu/src/ui/selectable_text_overlay.dart';
import 'package:flutter/material.dart';

///文本选择路由
///Route for displaying selectable text overlay
class SelectableTextRoute extends PageRoute {
  SelectableTextRoute({
    required this.text,
    required this.textStyle,
    required this.textAlign,
    required this.textDirection,
    required this.maxLines,
    required this.overflow,
    required this.textScaler,
    required this.textWidthBasis,
    required this.textHeightBehavior,
    required this.selectionColor,
    required this.handleColor,
    required this.widgetRect,
    required this.menuBuilder,
    required this.initialSelection,
    required this.onSelectionChanged,
    required this.strutStyle,
    required this.locale,
    required this.softWrap,
    required this.handleSize,
    this.enableHapticFeedback = true,
    this.menuBackgroundColor,
    this.menuBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.menuPadding = const EdgeInsets.all(8),
    this.menuShadows,
    this.arrowHeight = 8.0,
    this.arrowWidth = 12.0,
    this.spacing = 6.0,
    this.horizontalMargin = 10.0,
    Color? barrierColor,
    this.transitionsBuilder,
    required this.transitionDurations,
  }) : _barrierColor = barrierColor ?? Colors.transparent;

  final String text;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final int? maxLines;
  final TextOverflow overflow;
  final TextScaler textScaler;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color selectionColor;
  final Color handleColor;
  final Rect widgetRect;
  final Widget Function(
    BuildContext context,
    String selectedText,
    VoidCallback hideMenu,
  )
  menuBuilder;
  final TextSelection initialSelection;
  final ValueChanged<String>? onSelectionChanged;
  final StrutStyle? strutStyle;
  final Locale? locale;
  final bool softWrap;
  final double handleSize;
  final bool enableHapticFeedback;
  final Color? menuBackgroundColor;
  final BorderRadius menuBorderRadius;
  final EdgeInsets menuPadding;
  final List<BoxShadow>? menuShadows;
  final double arrowHeight;
  final double arrowWidth;
  final double spacing;
  final double horizontalMargin;
  final Color _barrierColor;

  ///自定义菜单动画
  ///Customize the menu animation
  final Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  transitionsBuilder;

  ///菜单动画时长
  ///Duration of menu animation
  final Duration transitionDurations;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => _barrierColor;

  @override
  String? get barrierLabel => 'selectable_text_overlay';

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SelectableTextOverlay(
      text: text,
      textStyle: textStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      textScaler: textScaler,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
      handleColor: handleColor,
      widgetRect: widgetRect,
      menuBuilder: menuBuilder,
      initialSelection: initialSelection,
      onSelectionChanged: onSelectionChanged,
      strutStyle: strutStyle,
      locale: locale,
      softWrap: softWrap,
      handleSize: handleSize,
      animation: animation,
      enableHapticFeedback: enableHapticFeedback,
      transitionsBuilder: transitionsBuilder,
      menuBackgroundColor: menuBackgroundColor,
      menuBorderRadius: menuBorderRadius,
      menuPadding: menuPadding,
      menuShadows: menuShadows,
      arrowHeight: arrowHeight,
      arrowWidth: arrowWidth,
      spacing: spacing,
      horizontalMargin: horizontalMargin,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => transitionDurations;
}
