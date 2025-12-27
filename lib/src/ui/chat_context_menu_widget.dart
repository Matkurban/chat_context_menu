import 'package:chat_context_menu/src/ui/chat_context_menu_shape.dart';
import 'package:flutter/material.dart';

class ChatContextMenuWidget extends StatelessWidget {
  final Widget items;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final double? arrowOffset;
  final bool isArrowUp;
  final List<BoxShadow>? shadows;

  const ChatContextMenuWidget({
    super.key,
    required this.items,
    this.backgroundColor,
    this.borderRadius,
    required this.padding,
    this.arrowOffset,
    this.isArrowUp = false,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: padding,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shadows: shadows,
          shape: arrowOffset != null
              ? ChatContextMenuShape(
                  arrowOffset: arrowOffset!,
                  isArrowUp: isArrowUp,
                  borderRadius: borderRadius ?? BorderRadius.circular(10),
                )
              : RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(10),
                ),
        ),
        child: items,
      ),
    );
  }
}
