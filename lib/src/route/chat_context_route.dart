import 'package:chat_context_menu/src/ui/chat_context_menu_vertical_layout.dart';
import 'package:chat_context_menu/src/ui/chat_context_menu_widget.dart';
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

  final BoxConstraints? constraints;

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
    this.constraints,
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
    return ChatContextMenuVerticalLayout(
      widgetRect: widgetRect,
      padding: padding,
      arrowHeight: arrowHeight,
      spacing: spacing,
      arrowWidth: arrowWidth,
      borderRadius: borderRadius,
      horizontalMargin: horizontalMargin,
      childBuilder: (context, arrowOffset, isArrowUp) {
        return ChatContextMenuWidget(
          items: menuItems,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          padding: padding,
          arrowOffset: arrowOffset,
          isArrowUp: isArrowUp,
          shadows: shadows,
          arrowHeight: arrowHeight,
          arrowWidth: arrowWidth,
          constraints: constraints,
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
    final Offset center = widgetRect.center;
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
