import 'package:chat_context_menu/src/model/arrow_horizontal_direction.dart';
import 'package:chat_context_menu/src/shape/chat_context_menu_horizontal_shape.dart';
import 'package:flutter/material.dart';

/// 横向显示的 Context Menu Widget
/// Horizontal Context Menu Widget
class ChatContextMenuHorizontalWidget extends StatelessWidget {
  final Widget items;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double? arrowOffset;
  final ArrowHorizontalDirection arrowDirection;
  final List<BoxShadow>? shadows;
  final double arrowHeight;
  final double arrowWidth;
  final BoxConstraints? constraints;

  const ChatContextMenuHorizontalWidget({
    super.key,
    required this.items,
    this.backgroundColor,
    required this.borderRadius,
    required this.padding,
    this.arrowOffset,
    required this.arrowDirection,
    this.shadows,
    required this.arrowHeight,
    required this.arrowWidth,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      constraints: constraints,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shadows: shadows,
        shape: arrowOffset != null
            ? ChatContextMenuHorizontalShape(
                arrowOffset: arrowOffset!,
                arrowDirection: arrowDirection,
                borderRadius: borderRadius,
                arrowHeight: arrowHeight,
                arrowWidth: arrowWidth,
                padding: padding,
              )
            : RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      child: items,
    );
  }
}
