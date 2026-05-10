import 'package:flutter/material.dart';

/// Maps [holeRectGlobal] through [overlayBox] then intersects [viewportLocal] (`Offset.zero & size`).
Rect intersectHoleOverlayLocal({
  required RenderBox overlayBox,
  required Rect holeRectGlobal,
  required Rect viewportLocal,
}) {
  final Offset topLeft = overlayBox.globalToLocal(holeRectGlobal.topLeft);
  final Offset bottomRight = overlayBox.globalToLocal(holeRectGlobal.bottomRight);
  final Rect mapped = Rect.fromLTRB(topLeft.dx, topLeft.dy, bottomRight.dx, bottomRight.dy);
  return mapped.intersect(viewportLocal);
}

/// Cutout in **viewport-local** coordinates.
RRect anchoredHoleShape({
  required Rect holeLocalIntersectedViewport,
  required BorderRadius? borderRadius,
  required TextDirection textDirection,
}) {
  final Rect hole = holeLocalIntersectedViewport;
  if (!hole.isFinite || hole.width <= 0 || hole.height <= 0) {
    return RRect.zero;
  }
  if (borderRadius == null || borderRadius == BorderRadius.zero) {
    return RRect.fromRectXY(hole, 0, 0);
  }
  return borderRadius.resolve(textDirection).toRRect(hole);
}
