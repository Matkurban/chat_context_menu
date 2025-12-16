import 'package:chat_context_menu/src/ui/chat_context_menu_layout.dart';
import 'package:chat_context_menu/src/ui/chat_context_menu_widget.dart';
import 'package:flutter/material.dart';

class ChatContextRoute extends PageRoute {
  final Rect widgetRect;
  final Widget menuItems;
  final Color? _barrierColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

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
    this.borderRadius,
    this.padding,
  }) : _barrierColor = barrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => _barrierColor ?? Colors.black26;

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
    return ChatContextMenuLayout(
      widgetRect: widgetRect,
      childBuilder: (context, arrowOffset, isArrowUp) {
        return ChatContextMenuWidget(
          items: menuItems,
          backgroundColor: backgroundColor ?? const Color(0xCCF9F9F9),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          padding: padding ?? EdgeInsets.all(8),
          arrowOffset: arrowOffset,
          isArrowUp: isArrowUp,
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
    return FadeTransition(opacity: animation, child: child);
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);
}
