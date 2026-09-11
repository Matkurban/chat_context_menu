import 'package:chat_context_menu/src/route/hole_cutout.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

/// Expands [rect] by [padding] applied per edge (typically used for barrier cutout).
Rect inflateRectByEdgeInsets(Rect rect, EdgeInsets padding) {
  return Rect.fromLTRB(
    rect.left - padding.left,
    rect.top - padding.top,
    rect.right + padding.right,
    rect.bottom + padding.bottom,
  );
}

/// Barrier that **only paints** overlay color with a punched hole; it does **not**
/// participate in hit-testing so taps route to sibling layers (`HoleModalDismissScrim`).
class HoleModalBarrier extends StatelessWidget {
  const HoleModalBarrier({
    super.key,
    required this.animation,
    required this.holeRectLogical,
    this.anchorBorderRadius,
  });

  /// Typically `animation!.drive(ColorTween(...).chain(CurveTween(curve: barrierCurve)))`.
  final Animation<Color?> animation;

  /// Hole in the coordinate space of the Overlay hosting this barrier (the barrier fills the
  /// overlay, so its own local space matches the overlay's).
  final Rect holeRectLogical;

  /// Matches the anchored widget silhouette (same as `Container`/`Material` bubble radius).
  final BorderRadius? anchorBorderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext animatedContext, Widget? _) {
          return LayoutBuilder(
            builder: (BuildContext layoutContext, BoxConstraints constraints) {
              final Rect viewportLocal = Offset.zero & constraints.biggest;
              // [holeRectLogical] is already overlay-local; the barrier fills the overlay, so
              // clamping to our own bounds is all that is needed.
              final Rect holeRectOverlay = holeRectLogical.intersect(viewportLocal);

              final TextDirection td = Directionality.maybeOf(layoutContext) ?? TextDirection.ltr;
              final RRect holeShape = anchoredHoleShape(
                holeLocalIntersectedViewport: holeRectOverlay,
                borderRadius: anchorBorderRadius,
                textDirection: td,
              );

              final Color color = animation.value ?? const Color(0x00000000);

              return HoleBarrierPainterLayer(
                viewport: viewportLocal,
                holeShape: holeShape,
                color: color,
              );
            },
          );
        },
      ),
    );
  }
}

class HoleBarrierPainterLayer extends LeafRenderObjectWidget {
  const HoleBarrierPainterLayer({
    super.key,
    required this.viewport,
    required this.holeShape,
    required this.color,
  });

  final Rect viewport;
  final RRect holeShape;
  final Color color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHoleBarrierPainter(viewport: viewport, holeShape: holeShape, color: color);
  }

  @override
  void updateRenderObject(BuildContext context, RenderHoleBarrierPainter renderObject) {
    renderObject
      ..viewport = viewport
      ..holeShape = holeShape
      ..color = color;
  }
}

class RenderHoleBarrierPainter extends RenderBox {
  RenderHoleBarrierPainter({required Rect viewport, required RRect holeShape, required Color color})
    : _viewport = viewport,
      _holeShape = holeShape,
      _color = color;

  Rect _viewport;
  RRect _holeShape;
  Color _color;

  set viewport(Rect value) {
    if (value == _viewport) return;
    _viewport = value;
    markNeedsPaint();
  }

  set holeShape(RRect value) {
    if (value == _holeShape) return;
    _holeShape = value;
    markNeedsPaint();
  }

  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  double computeMinIntrinsicWidth(double height) => _viewport.width;

  @override
  double computeMaxIntrinsicWidth(double height) => _viewport.width;

  @override
  double computeMinIntrinsicHeight(double width) => _viewport.height;

  @override
  double computeMaxIntrinsicHeight(double width) => _viewport.height;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  /// Visual-only overlay: touch handling happens in `HoleModalDismissScrim`.
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_color.a == 0) return;
    final Rect background = Offset.zero & size;
    final Path path = Path()
      ..addRect(background.shift(offset))
      ..addRRect(_holeShape.shift(offset))
      ..fillType = PathFillType.evenOdd;
    context.canvas.drawPath(path, Paint()..color = _color);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Rect>('viewport', _viewport));
    properties.add(DiagnosticsProperty<RRect>('holeShape', _holeShape));
    properties.add(ColorProperty('color', _color));
  }
}
