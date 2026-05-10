import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Clips [anchorGlobal] (logical global coords from [RenderBox.localToGlobal]) so the barrier
/// hole matches what the user sees: long list children keep a full layout height, but only the
/// viewport-visible part should be punched out.
///
/// 1. Intersect with the innermost [RenderAbstractViewport] ancestor of [anchorRenderBox], if any.
/// 2. Intersect with [MediaQuery.sizeOf] bounds.
///
/// If clipping would empty the rect, returns [anchorGlobal].
Rect clipAnchorGlobalRectForHole({
  required BuildContext context,
  required Rect anchorGlobal,
  required RenderBox anchorRenderBox,
}) {
  Rect result = anchorGlobal;

  final RenderAbstractViewport? abstractViewport =
      RenderAbstractViewport.maybeOf(anchorRenderBox);
  if (abstractViewport != null) {
    final RenderBox viewportBox = abstractViewport as RenderBox;
    final Rect viewportGlobal = viewportBox.localToGlobal(Offset.zero) & viewportBox.size;
    final Rect next = result.intersect(viewportGlobal);
    if (next.width > 0 && next.height > 0) {
      result = next;
    }
  }

  final MediaQueryData? mq = MediaQuery.maybeOf(context);
  if (mq != null) {
    final Rect window = Offset.zero & mq.size;
    final Rect next = result.intersect(window);
    if (next.width > 0 && next.height > 0) {
      result = next;
    }
  }

  if (!(result.left.isFinite && result.top.isFinite) || result.width <= 0 || result.height <= 0) {
    return anchorGlobal;
  }
  return result;
}
