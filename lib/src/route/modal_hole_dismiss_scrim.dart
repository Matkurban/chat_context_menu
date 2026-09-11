import 'package:chat_context_menu/src/route/hole_cutout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Full-screen hit target beneath the floating menu: [PointerDownEvent] outside the punched
/// [holeShape] invokes [Navigator.maybePop]; inside the hole [hitTest] returns false so the anchor
/// below receives the gesture. Painting is handled by [HoleModalBarrier].
class HoleModalDismissScrim extends StatelessWidget {
  const HoleModalDismissScrim({
    super.key,
    required this.holeRectLocal,
    this.anchorBorderRadius,
    required this.dismissible,
  });

  /// Hole rect in the coordinate space of the Overlay hosting the route (the scrim fills the
  /// route page, which fills the overlay).
  final Rect holeRectLocal;
  final BorderRadius? anchorBorderRadius;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    void onMaskedPointerDown() {
      if (!context.mounted) return;
      if (dismissible) {
        Navigator.maybePop(context);
      } else {
        SystemSound.play(SystemSoundType.alert);
      }
    }

    return LayoutBuilder(
      builder: (BuildContext layoutContext, BoxConstraints constraints) {
        final Rect viewportLocal = Offset.zero & constraints.biggest;
        // [holeRectLocal] is already overlay-local, matching our own local space.
        final Rect holeRect = holeRectLocal.intersect(viewportLocal);

        final TextDirection td =
            Directionality.maybeOf(layoutContext) ??
            Directionality.maybeOf(context) ??
            TextDirection.ltr;

        final RRect holeShape = anchoredHoleShape(
          holeLocalIntersectedViewport: holeRect,
          borderRadius: anchorBorderRadius,
          textDirection: td,
        );

        return _MaskedHoleDismissHitTarget(
          viewport: viewportLocal,
          holeShape: holeShape,
          onMaskedPointerDown: onMaskedPointerDown,
        );
      },
    );
  }
}

class _MaskedHoleDismissHitTarget extends LeafRenderObjectWidget {
  const _MaskedHoleDismissHitTarget({
    required this.viewport,
    required this.holeShape,
    required this.onMaskedPointerDown,
  });

  final Rect viewport;
  final RRect holeShape;
  final VoidCallback onMaskedPointerDown;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMaskedHoleDismissHitTarget(
      viewport: viewport,
      holeShape: holeShape,
      onMaskedPointerDown: onMaskedPointerDown,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderMaskedHoleDismissHitTarget renderObject,
  ) {
    renderObject
      ..viewport = viewport
      ..holeShape = holeShape
      ..onMaskedPointerDown = onMaskedPointerDown;
  }
}

class RenderMaskedHoleDismissHitTarget extends RenderBox {
  RenderMaskedHoleDismissHitTarget({
    required Rect viewport,
    required RRect holeShape,
    required VoidCallback onMaskedPointerDown,
  }) : _viewport = viewport,
       _holeShape = holeShape,
       _onMaskedPointerDown = onMaskedPointerDown;

  Rect _viewport;
  RRect _holeShape;
  VoidCallback _onMaskedPointerDown;

  set viewport(Rect value) {
    if (value == _viewport) return;
    _viewport = value;
    markNeedsLayout();
  }

  set holeShape(RRect value) {
    if (value == _holeShape) return;
    _holeShape = value;
    markNeedsLayout();
  }

  set onMaskedPointerDown(VoidCallback value) {
    if (_onMaskedPointerDown == value) return;
    _onMaskedPointerDown = value;
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    if (_holeShape.contains(position)) return false;
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _onMaskedPointerDown();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Rect>('viewport', _viewport));
    properties.add(DiagnosticsProperty<RRect>('holeShape', _holeShape));
  }
}
