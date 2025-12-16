import 'package:chat_context_menu/src/chat_context_route.dart';
import 'package:chat_context_menu/src/statement.dart';
import 'package:flutter/material.dart';

class ChatContextMenuWrapper extends StatefulWidget {
  const ChatContextMenuWrapper({
    super.key,
    required this.widgetBuilder,
    required this.menuItems,
    this.barrierColor = Colors.transparent,
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  final ContextMenuWidgetBuilder widgetBuilder;
  final Widget menuItems;
  final Color barrierColor;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  @override
  State<ChatContextMenuWrapper> createState() => _ChatContextMenuWrapperState();
}

class _ChatContextMenuWrapperState extends State<ChatContextMenuWrapper> {
  void _showMenu() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Rect widgetRect = offset & renderBox.size;

    Navigator.of(context).push(
      ChatContextRoute(
        widgetRect: widgetRect,
        menuItems: widget.menuItems,
        barrierColor: widget.barrierColor,
        backgroundColor: widget.backgroundColor,
        borderRadius: widget.borderRadius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetBuilder(context, _showMenu);
  }
}
