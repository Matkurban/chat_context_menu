import 'package:chat_context_menu/src/model/arrow_horizontal_direction.dart';
import 'package:chat_context_menu/src/model/arrow_vertical_direction.dart';
import 'package:material_ui/material_ui.dart';

///Cupertino 操作菜单 sheet 的缩放原点：贴在箭头指向锚点的那条边上。
///Scale origin for the Cupertino sheet: the edge whose arrow points at the anchor.
Alignment sheetScaleAlignment({
  required Axis axis,
  ArrowVerticalDirection? vertical,
  ArrowHorizontalDirection? horizontal,
  double? arrowOffset,
  Size? menuSize,
}) {
  switch (axis) {
    case Axis.vertical:
      final double x = _normalizedArrow(arrowOffset, menuSize?.width);
      final double y = vertical == ArrowVerticalDirection.up ? -1.0 : 1.0;
      return Alignment(x, y);
    case Axis.horizontal:
      final double x = horizontal == ArrowHorizontalDirection.left ? -1.0 : 1.0;
      final double y = _normalizedArrow(arrowOffset, menuSize?.height);
      return Alignment(x, y);
  }
}

double _normalizedArrow(double? arrowOffset, double? extent) {
  if (arrowOffset == null || extent == null || extent <= 0) {
    return 0.0;
  }
  return ((arrowOffset / extent) * 2 - 1).clamp(-1.0, 1.0);
}

///Clamps [easeOutBack] overshoot and [easeInBack] undershoot so scale never
///goes negative (a flipped sliver) or arbitrarily large.
class _ClampedScale extends Animatable<double> {
  const _ClampedScale();

  @override
  double transform(double t) => t.clamp(0.0, 2.0);
}

///线性淡入 + easeOutBack / easeInBack 缩放，作用在菜单 widget 上。
///关闭时透明度在缩放收完前归零，避免极小尺寸下 BoxShadow 剩下一小块矩形。
///Linear fade + easeOutBack / easeInBack scale, applied to the menu widget.
///On dismiss, opacity hits 0 before scale does so the shadow blob never shows.
class ChatContextMenuSheetTransition extends StatefulWidget {
  const ChatContextMenuSheetTransition({
    super.key,
    required this.animation,
    required this.alignment,
    required this.child,
  });

  final Animation<double> animation;
  final Alignment alignment;
  final Widget child;

  @override
  State<ChatContextMenuSheetTransition> createState() => _ChatContextMenuSheetTransitionState();
}

class _ChatContextMenuSheetTransitionState extends State<ChatContextMenuSheetTransition> {
  late CurvedAnimation _scale;
  late CurvedAnimation _opacity;
  late Animation<double> _clampedScale;

  @override
  void initState() {
    super.initState();
    _bindAnimations();
  }

  void _bindAnimations() {
    _scale = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );
    _clampedScale = _scale.drive(const _ClampedScale());
    _opacity = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.linear,
      reverseCurve: const Interval(0.5, 1.0),
    );
  }

  @override
  void didUpdateWidget(ChatContextMenuSheetTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _scale.dispose();
      _opacity.dispose();
      _bindAnimations();
    }
  }

  @override
  void dispose() {
    _scale.dispose();
    _opacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _clampedScale,
        alignment: widget.alignment,
        child: widget.child,
      ),
    );
  }
}
