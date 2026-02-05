import 'package:chat_context_menu/src/layout/chat_context_menu_horizontal_layout.dart';
import 'package:chat_context_menu/src/ui/chat_context_menu_horizontal_widget.dart';
import 'package:chat_context_menu/src/layout/chat_context_menu_vertical_layout.dart';
import 'package:chat_context_menu/src/ui/chat_context_menu_vertical_widget.dart';
import 'package:flutter/material.dart';

class ChatContextRoute extends PageRoute {
  final Rect widgetRect;
  final Widget menuItems;
  final Color? _barrierColor;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final List<BoxShadow>? shadows;
  final double arrowHeight;
  final double arrowWidth;
  final double spacing;
  final double horizontalMargin;
  final Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )?
  transitionsBuilder;

  final BoxConstraints? menuConstraints;
  final BoxConstraints? layoutConstraints;
  final Axis axis;
  final Rect? pointerRect;
  final double topPadding;

  ChatContextRoute({
    super.settings,
    super.requestFocus,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.barrierDismissible,
    required this.widgetRect,
    required this.menuItems,
    Color? barrierColor,
    this.backgroundColor,
    required this.borderRadius,
    required this.padding,
    this.shadows,
    required this.arrowHeight,
    required this.arrowWidth,
    required this.spacing,
    required this.horizontalMargin,
    this.transitionsBuilder,
    this.menuConstraints,
    this.layoutConstraints,
    required this.axis,
    this.pointerRect,
    required this.topPadding,
  }) : _barrierColor = barrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => _barrierColor;

  @override
  String? get barrierLabel => 'chat_context_menu';

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    if (axis == Axis.horizontal) {
      return ChatContextMenuHorizontalLayout(
        widgetRect: widgetRect,
        padding: padding,
        arrowHeight: arrowHeight,
        spacing: spacing,
        arrowWidth: arrowWidth,
        borderRadius: borderRadius,
        verticalMargin: horizontalMargin,
        topPadding: topPadding,
        childBuilder: (context, arrowOffset, arrowDirection) {
          return ChatContextMenuHorizontalWidget(
            items: menuItems,
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            padding: padding,
            arrowOffset: arrowOffset,
            arrowDirection: arrowDirection,
            shadows: shadows,
            arrowHeight: arrowHeight,
            arrowWidth: arrowWidth,
            menuConstraints: menuConstraints,
          );
        },
      );
    }

    return ChatContextMenuVerticalLayout(
      widgetRect: widgetRect,
      pointerRect: pointerRect,
      padding: padding,
      arrowHeight: arrowHeight,
      spacing: spacing,
      arrowWidth: arrowWidth,
      borderRadius: borderRadius,
      horizontalMargin: horizontalMargin,
      layoutConstraints: layoutConstraints,
      topPadding: topPadding,
      childBuilder: (context, arrowOffset, isArrowUp) {
        return ChatContextMenuVerticalWidget(
          items: menuItems,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          padding: padding,
          arrowOffset: arrowOffset,
          isArrowUp: isArrowUp,
          shadows: shadows,
          arrowHeight: arrowHeight,
          arrowWidth: arrowWidth,
          constraints: menuConstraints,
        );
      },
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Size screenSize = MediaQuery.of(context).size;
    final Offset center = pointerRect?.center ?? widgetRect.center;
    // Calculate alignment (-1.0 to 1.0)
    final double alignX = (center.dx / screenSize.width) * 2 - 1;
    final double alignY = (center.dy / screenSize.height) * 2 - 1;
    final Alignment alignment = Alignment(alignX, alignY);
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.fastOutSlowIn,
    );
    return transitionsBuilder?.call(
          context,
          animation,
          secondaryAnimation,
          child,
        ) ??
        FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: curve,
            alignment: alignment,
            child: child,
          ),
        );
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);
}
