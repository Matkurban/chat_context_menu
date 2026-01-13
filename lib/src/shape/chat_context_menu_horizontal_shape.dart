import 'package:chat_context_menu/src/model/arrow_horizontal_direction.dart';
import 'package:flutter/material.dart';

/// 横向容器的箭头形状
/// Arrow shape of the horizontal container
class ChatContextMenuHorizontalShape extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double arrowOffset;
  final ArrowHorizontalDirection arrowDirection;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  const ChatContextMenuHorizontalShape({
    required this.arrowWidth,
    required this.arrowHeight,
    required this.arrowOffset,
    required this.arrowDirection,
    required this.borderRadius,
    this.padding = EdgeInsets.zero,
  });

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.only(
      left: arrowDirection == ArrowHorizontalDirection.left ? arrowHeight : 0,
      right: arrowDirection == ArrowHorizontalDirection.right ? arrowHeight : 0,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double left =
        rect.left +
        (arrowDirection == ArrowHorizontalDirection.left ? arrowHeight : 0);
    final double right =
        rect.right -
        (arrowDirection == ArrowHorizontalDirection.right ? arrowHeight : 0);
    final double top = rect.top;
    final double bottom = rect.bottom;

    final RRect rrect = RRect.fromLTRBAndCorners(
      left,
      top,
      right,
      bottom,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    final Path path = Path()..addRRect(rrect);

    // Draw arrow - arrowOffset 已经包含 padding.top 的补偿
    final double arrowY = top + arrowOffset + padding.top;

    final Path arrowPath = Path();
    switch (arrowDirection) {
      case ArrowHorizontalDirection.left:
        // Arrow pointing left (menu is on the right side of anchor)
        arrowPath.moveTo(left, arrowY - arrowWidth / 2);
        arrowPath.lineTo(rect.left, arrowY);
        arrowPath.lineTo(left, arrowY + arrowWidth / 2);
        break;
      case ArrowHorizontalDirection.right:
        // Arrow pointing right (menu is on the left side of anchor)
        arrowPath.moveTo(right, arrowY - arrowWidth / 2);
        arrowPath.lineTo(rect.right, arrowY);
        arrowPath.lineTo(right, arrowY + arrowWidth / 2);
        break;
    }
    arrowPath.close();

    return Path.combine(PathOperation.union, path, arrowPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return ChatContextMenuHorizontalShape(
      arrowWidth: arrowWidth * t,
      arrowHeight: arrowHeight * t,
      arrowOffset: arrowOffset * t,
      arrowDirection: arrowDirection,
      borderRadius: borderRadius * t,
      padding: padding * t,
    );
  }
}
