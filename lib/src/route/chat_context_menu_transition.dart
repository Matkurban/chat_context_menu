import 'package:chat_context_menu/src/model/arrow_horizontal_direction.dart';
import 'package:chat_context_menu/src/model/arrow_vertical_direction.dart';
import 'package:flutter/material.dart';

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

///线性淡入 + easeOutBack / easeInBack 缩放，作用在菜单 widget 上。
///Linear fade + easeOutBack / easeInBack scale, applied to the menu widget.
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

  @override
  void initState() {
    super.initState();
    _scale = _createScale();
  }

  CurvedAnimation _createScale() {
    return CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );
  }

  @override
  void didUpdateWidget(ChatContextMenuSheetTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _scale.dispose();
      _scale = _createScale();
    }
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animation,
      child: ScaleTransition(scale: _scale, alignment: widget.alignment, child: widget.child),
    );
  }
}
