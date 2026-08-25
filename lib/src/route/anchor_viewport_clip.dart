import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Clips [anchorRect] (expressed in [overlayBox]'s coordinate space, i.e. the result of
/// `anchorRenderBox.localToGlobal(Offset.zero, ancestor: overlayBox)`) so the barrier hole matches
/// what the user actually sees:
///
/// 1. Walk the render tree from [anchorRenderBox] up to [overlayBox] (or the render tree root when
///    [overlayBox] is null) and intersect with the bounds of every clipping ancestor:
///    [RenderAbstractViewport]s (long list children keep a full layout height, but only the
///    viewport-visible part should be punched out), `ClipRect`/`ClipRRect`/`ClipOval`/`ClipPath`,
///    and `Material`/`PhysicalModel` render objects with a non-none `clipBehavior` (e.g. a pane
///    card shell in a desktop multi-pane layout).
/// 2. Intersect with [overlayBox]'s own bounds ([MediaQuery] window when [overlayBox] is null).
///
/// If clipping would empty the rect, returns [anchorRect] unchanged.
Rect clipAnchorRectForHole({
  required BuildContext context,
  required Rect anchorRect,
  required RenderBox anchorRenderBox,
  RenderBox? overlayBox,
}) {
  Rect result = anchorRect;

  void intersectWith(Rect other) {
    final Rect next = result.intersect(other);
    if (next.width > 0 && next.height > 0) {
      result = next;
    }
  }

  RenderObject? node = anchorRenderBox.parent;
  while (node != null && !identical(node, overlayBox)) {
    if (_clipsItsContents(node) && node is RenderBox && node.hasSize) {
      // getTransformTo maps through every Transform/offset between the clip ancestor and the
      // overlay, so the clip bounds land in the same coordinate space as [anchorRect].
      final Rect clipBoundsInOverlay = MatrixUtils.transformRect(
        node.getTransformTo(overlayBox),
        Offset.zero & node.size,
      );
      intersectWith(clipBoundsInOverlay);
    }
    node = node.parent;
  }

  if (overlayBox != null && overlayBox.hasSize) {
    intersectWith(Offset.zero & overlayBox.size);
  } else {
    final MediaQueryData? mq = MediaQuery.maybeOf(context);
    if (mq != null) {
      intersectWith(Offset.zero & mq.size);
    }
  }

  if (!(result.left.isFinite && result.top.isFinite) || result.width <= 0 || result.height <= 0) {
    return anchorRect;
  }
  return result;
}

bool _clipsItsContents(RenderObject node) {
  if (node is RenderAbstractViewport) return true;
  if (node is RenderClipRect) return node.clipBehavior != Clip.none;
  if (node is RenderClipRRect) return node.clipBehavior != Clip.none;
  if (node is RenderClipOval) return node.clipBehavior != Clip.none;
  if (node is RenderClipPath) return node.clipBehavior != Clip.none;
  if (node is RenderPhysicalModel) return node.clipBehavior != Clip.none;
  if (node is RenderPhysicalShape) return node.clipBehavior != Clip.none;
  return false;
}
