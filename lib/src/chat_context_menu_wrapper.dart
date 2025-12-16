import 'package:chat_context_menu/src/chat_context_route.dart';
import 'package:chat_context_menu/src/statement.dart';
import 'package:flutter/material.dart';

class ChatContextMenuWrapper extends StatefulWidget {
  const ChatContextMenuWrapper({
    super.key,
    required this.widgetBuilder,
    required this.menuBuilder,
    this.barrierColor = Colors.transparent,
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  final ContextMenuWidgetBuilder widgetBuilder;
  final ContextMenuContentBuilder menuBuilder;
  final Color barrierColor;
  final Color backgroundColor;
  final BorderRadius borderRadius;

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
