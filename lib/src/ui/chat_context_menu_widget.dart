import 'package:chat_context_menu/src/model/arrow_direction.dart';
import 'package:chat_context_menu/src/ui/chat_context_menu_shape.dart';
import 'package:flutter/material.dart';

class ChatContextMenuWidget extends StatelessWidget {
  final Widget items;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double? arrowOffset;
  final ArrowDirection isArrowUp;
  final List<BoxShadow>? shadows;
  final double arrowHeight;
  final double arrowWidth;
  final BoxConstraints? constraints;

  const ChatContextMenuWidget({
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
    return IntrinsicWidth(
      child: Container(
        padding: padding,
        constraints: constraints,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shadows: shadows,
          shape: arrowOffset != null
              ? ChatContextMenuShape(
                  arrowOffset: arrowOffset!,
                  isArrowUp: isArrowUp,
                  borderRadius: borderRadius,
                  arrowHeight: arrowHeight,
                  arrowWidth: arrowWidth,
                )
              : RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: items,
      ),
    );
  }
}
