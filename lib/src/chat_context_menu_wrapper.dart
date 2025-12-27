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
    this.arrowHeight = 8.0,
    this.arrowWidth = 12.0,
    this.spacing = 10.0,
    this.transitionsBuilder,
  });

  ///在页面中显示的组件
  ///Components displayed on the page
  final ContextMenuWidgetBuilder widgetBuilder;

  ///显示的 context menu 组件
  ///Displayed context menu widget
  final ContextMenuContentBuilder menuBuilder;

  ///屏障颜色 （背景叠加层的颜色。）
  ///Color of the background overlay.
  final Color barrierColor;

  ///context menu容器的背景颜色。
  ///也作用于角标的颜色
  ///Background color of the menu container.
  ///Also affects the color of the marker
  final Color? backgroundColor;

  ///context menu容器的圆角
  ///Rounded corners of context menu container
  final BorderRadius borderRadius;

  ///context menu容器的内边距
  ///Padding corners of context menu container
  final EdgeInsets padding;

  ///是否在显示的的时候获取焦点
  ///默认为 false 如果为 true 那么在context menu显示的时候你页面中的其他具有焦点的组件将失去焦点
  ///Whether to get focus when displayed
  ///The default is false. If it is true, other focused components in your page will lose focus when the context menu is displayed.
  final bool requestFocus;

  ///context menu容器的阴影
  ///Shadows corners of context menu container
  final List<BoxShadow>? shadows;

  ///角标的高度
  ///The height of the marker
  final double arrowHeight;

  ///角标的宽度
  ///The width of the marker
  final double arrowWidth;

  ///context menu 和组件的间距
  ///Spacing between context menu and components
  final double spacing;

  ///自定义出现的动画
  ///Customize the animation that appears
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
      arrowHeight: widget.arrowHeight,
      arrowWidth: widget.arrowWidth,
      spacing: widget.spacing,
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
