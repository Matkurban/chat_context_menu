import 'package:flutter/material.dart';

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
