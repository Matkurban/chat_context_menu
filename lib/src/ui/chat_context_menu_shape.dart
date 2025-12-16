import 'package:flutter/material.dart';

class ChatContextMenuShape extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double arrowOffset;
  final bool isArrowUp;
  final BorderRadius borderRadius;

  const ChatContextMenuShape({
    this.arrowWidth = 12.0,
    this.arrowHeight = 8.0,
    required this.arrowOffset,
    required this.isArrowUp,
    required this.borderRadius,
  });

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.only(top: isArrowUp ? arrowHeight : 0, bottom: isArrowUp ? 0 : arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double left = rect.left;
    final double right = rect.right;
    final double top = rect.top + (isArrowUp ? arrowHeight : 0);
    final double bottom = rect.bottom - (isArrowUp ? 0 : arrowHeight);

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
    // Clamp arrowX to be within the rounded corners
    // We assume the arrow should be within the straight part of the edge
    // But for simplicity, let's just draw it.

    final Path arrowPath = Path();
    if (isArrowUp) {
      arrowPath.moveTo(arrowX - arrowWidth / 2, top);
      arrowPath.lineTo(arrowX, rect.top);
      arrowPath.lineTo(arrowX + arrowWidth / 2, top);
    } else {
      arrowPath.moveTo(arrowX - arrowWidth / 2, bottom);
      arrowPath.lineTo(arrowX, rect.bottom);
      arrowPath.lineTo(arrowX + arrowWidth / 2, bottom);
    }
    arrowPath.close();

    return Path.combine(PathOperation.union, path, arrowPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return ChatContextMenuShape(
      arrowWidth: arrowWidth * t,
      arrowHeight: arrowHeight * t,
      arrowOffset: arrowOffset * t,
      isArrowUp: isArrowUp,
      borderRadius: borderRadius * t,
    );
  }
}
