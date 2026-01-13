import 'package:chat_context_menu/src/model/arrow_direction.dart';
import 'package:flutter/material.dart';

///容器的箭头形状
///Arrow shape of the container
class ChatContextMenuVerticalShape extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double arrowOffset;
  final ArrowDirection isArrowUp;
  final BorderRadius borderRadius;

  const ChatContextMenuVerticalShape({
    required this.arrowWidth,
    required this.arrowHeight,
    required this.arrowOffset,
    required this.isArrowUp,
    required this.borderRadius,
  });

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.only(
      top: isArrowUp == .up ? arrowHeight : 0,
      bottom: isArrowUp == .up ? 0 : arrowHeight,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double left = rect.left;
    final double right = rect.right;
    final double top = rect.top + (isArrowUp == .up ? arrowHeight : 0);
    final double bottom = rect.bottom - (isArrowUp == .up ? 0 : arrowHeight);

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

    // Draw arrow
    final double arrowX = left + arrowOffset;

    final Path arrowPath = Path();
    switch (isArrowUp) {
      case ArrowDirection.up:
        arrowPath.moveTo(arrowX - arrowWidth / 2, top);
        arrowPath.lineTo(arrowX, rect.top);
        arrowPath.lineTo(arrowX + arrowWidth / 2, top);
        break;
      case ArrowDirection.down:
        arrowPath.moveTo(arrowX - arrowWidth / 2, bottom);
        arrowPath.lineTo(arrowX, rect.bottom);
        arrowPath.lineTo(arrowX + arrowWidth / 2, bottom);
        break;
    }
    arrowPath.close();

    return Path.combine(PathOperation.union, path, arrowPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return ChatContextMenuVerticalShape(
      arrowWidth: arrowWidth * t,
      arrowHeight: arrowHeight * t,
      arrowOffset: arrowOffset * t,
      isArrowUp: isArrowUp,
      borderRadius: borderRadius * t,
    );
  }
}
