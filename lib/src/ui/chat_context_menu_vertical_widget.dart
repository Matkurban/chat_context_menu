import 'package:chat_context_menu/src/model/arrow_vertical_direction.dart';
import 'package:chat_context_menu/src/shape/chat_context_menu_vertical_shape.dart';
import 'package:flutter/material.dart';

class ChatContextMenuVerticalWidget extends StatelessWidget {
  final Widget items;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double? arrowOffset;
  final ArrowVerticalDirection isArrowUp;
  final List<BoxShadow>? shadows;
  final double arrowHeight;
  final double arrowWidth;
  final BoxConstraints? constraints;

  const ChatContextMenuVerticalWidget({
    super.key,
    required this.items,
    this.backgroundColor,
    required this.borderRadius,
    required this.padding,
    this.arrowOffset,
    required this.isArrowUp,
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
            ? ChatContextMenuVerticalShape(
                arrowOffset: arrowOffset!,
                isArrowUp: isArrowUp,
                borderRadius: borderRadius,
                arrowHeight: arrowHeight,
                arrowWidth: arrowWidth,
              )
            : RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      child: items,
    );
  }
}
