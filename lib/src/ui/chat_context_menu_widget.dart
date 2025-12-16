import 'package:chat_context_menu/src/ui/chat_context_menu_shape.dart';
import 'package:flutter/material.dart';

class ChatContextMenuWidget extends StatelessWidget {
  final Widget items;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? arrowOffset;
  final bool isArrowUp;

  const ChatContextMenuWidget({
    super.key,
    required this.items,
    required this.backgroundColor,
    required this.borderRadius,
    this.padding,
    this.arrowOffset,
    this.isArrowUp = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: padding ?? const EdgeInsets.all(12.0),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: arrowOffset != null
              ? ChatContextMenuShape(
                  arrowOffset: arrowOffset!,
                  isArrowUp: isArrowUp,
                  borderRadius: borderRadius,
                )
              : RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: items,
      ),
    );
  }
}
