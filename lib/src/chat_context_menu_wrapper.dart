import 'package:chat_context_menu/src/chat_context_route.dart';
import 'package:chat_context_menu/src/statement.dart';
import 'package:flutter/material.dart';

class ChatContextMenuWrapper extends StatefulWidget {
  const ChatContextMenuWrapper({
    super.key,
    required this.widgetBuilder,
    required this.menuBuilder,
    this.barrierColor = Colors.transparent,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.padding = const EdgeInsets.all(8),
    this.requestFocus = false,
    this.shadows,
    this.transitionsBuilder,
  });

  final ContextMenuWidgetBuilder widgetBuilder;
  final ContextMenuContentBuilder menuBuilder;
  final Color barrierColor;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final bool requestFocus;
  final List<BoxShadow>? shadows;
  final Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )?
  transitionsBuilder;

  @override
  State<ChatContextMenuWrapper> createState() => _ChatContextMenuWrapperState();
}

class _ChatContextMenuWrapperState extends State<ChatContextMenuWrapper> {
  ChatContextRoute? _route;

  void _showMenu() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Rect widgetRect = offset & renderBox.size;

    _route = ChatContextRoute(
      widgetRect: widgetRect,
      menuItems: widget.menuBuilder(context, _hideMenu),
      barrierColor: widget.barrierColor,
      backgroundColor: widget.backgroundColor,
      borderRadius: widget.borderRadius,
      requestFocus: widget.requestFocus,
      padding: widget.padding,
      shadows: widget.shadows,
      transitionsBuilder: widget.transitionsBuilder,
    );

    Navigator.of(context).push(_route!).then((_) {
      _route = null;
    });
  }

  void _hideMenu() {
    if (_route != null) {
      if (_route!.isCurrent) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).removeRoute(_route!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetBuilder(context, _showMenu);
  }
}
