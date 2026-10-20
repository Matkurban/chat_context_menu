import 'dart:math';

import 'package:chat_context_menu/src/model/arrow_horizontal_direction.dart';
import 'package:chat_context_menu/src/model/menu_position_mode.dart';
import 'package:chat_context_menu/src/route/chat_context_menu_transition.dart';
import 'package:flutter/widgets.dart';

/// 横向布局的 Context Menu
/// Horizontal layout for Context Menu
class ChatContextMenuHorizontalLayout extends StatefulWidget {
  const ChatContextMenuHorizontalLayout({
    super.key,
    required this.widgetRect,
    this.pointerRect,
    this.positionMode = ChatContextMenuPositionMode.outside,
    required this.childBuilder,
    required this.padding,
    required this.arrowHeight,
    required this.spacing,
    required this.arrowWidth,
    required this.borderRadius,
    required this.horizontalMargin,
    required this.topPadding,
    this.animation,
    this.applyCupertinoSheetTransition = false,
  });

  final Rect widgetRect;
  final Rect? pointerRect;
  final ChatContextMenuPositionMode positionMode;
  final Widget Function(
    BuildContext context,
    double? arrowOffset,
    ArrowHorizontalDirection arrowDirection,
  )
  childBuilder;

  final EdgeInsets padding;
  final double arrowHeight;
  final double spacing;
  final double arrowWidth;
  final BorderRadius borderRadius;
  final double horizontalMargin;
  final double topPadding;
  final Animation<double>? animation;
  final bool applyCupertinoSheetTransition;

  @override
  State<ChatContextMenuHorizontalLayout> createState() => _ChatContextMenuHorizontalLayoutState();
}

class _ChatContextMenuHorizontalLayoutState extends State<ChatContextMenuHorizontalLayout> {
  final GlobalKey _childKey = GlobalKey();

  Size? _childSize;

  Offset? _childPosition;

  double? _arrowOffset;

  ArrowHorizontalDirection _arrowDirection = ArrowHorizontalDirection.left;

  EdgeInsets get padding => widget.padding;

  double get arrowHeight => widget.arrowHeight;

  double get spacing => widget.spacing;

  double get arrowWidth => widget.arrowWidth;

  BorderRadius get borderRadius => widget.borderRadius;

  double get horizontalMargin => widget.horizontalMargin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePosition());
  }

  void _calculatePosition() {
    final RenderBox? renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Size childSize = renderBox.size;
    final MediaQueryData media = MediaQuery.of(context);
    // The layout fills the route page, which fills the target Navigator's Overlay. Use that size
    // as the available area: [widgetRect] is overlay-local, and with nested Navigators the
    // overlay may be smaller than the MediaQuery window.
    final RenderBox? layoutBox = context.findRenderObject() as RenderBox?;
    final Size screenSize = (layoutBox != null && layoutBox.hasSize && layoutBox.size.isFinite)
        ? layoutBox.size
        : media.size;
    final Rect widgetRect = widget.widgetRect;
    final bool usePointerAnchor =
        widget.positionMode == ChatContextMenuPositionMode.pointer && widget.pointerRect != null;
    final Rect anchorRect = usePointerAnchor ? widget.pointerRect! : widgetRect;

    final double leftLimit = media.padding.left + horizontalMargin;
    final double rightLimit = screenSize.width - media.padding.right - horizontalMargin;

    final double topLimit = media.padding.top + widget.topPadding;
    final double bottomLimit = screenSize.height - (media.padding.bottom + media.viewInsets.bottom);

    // Calculate available space on left and right
    // Menu width includes arrow height since arrow is part of the shape
    final double menuTotalWidth = childSize.width + arrowHeight;
    final double rightSpace = rightLimit - anchorRect.right - spacing;
    final double leftSpace = anchorRect.left - leftLimit - spacing;

    ArrowHorizontalDirection arrowDirection;
    double x;

    // Determine which side to show the menu
    final bool fitsRight = rightSpace >= menuTotalWidth;
    final bool fitsLeft = leftSpace >= menuTotalWidth;

    if (fitsRight) {
      // Show on right side, arrow points left
      x = anchorRect.right + spacing;
      arrowDirection = ArrowHorizontalDirection.left;
    } else if (fitsLeft) {
      // Show on left side, arrow points right
      x = anchorRect.left - spacing - childSize.width - arrowHeight;
      arrowDirection = ArrowHorizontalDirection.right;
    } else {
      // Neither side fits perfectly, pick the one with more space
      if (leftSpace > rightSpace) {
        x = anchorRect.left - spacing - childSize.width - arrowHeight;
        arrowDirection = ArrowHorizontalDirection.right;
        // Clamp to left limit
        if (x < leftLimit) {
          x = leftLimit;
        }
      } else {
        x = anchorRect.right + spacing;
        arrowDirection = ArrowHorizontalDirection.left;
        // Clamp to right limit
        if (x + menuTotalWidth > rightLimit) {
          x = rightLimit - menuTotalWidth;
        }
      }
    }

    // Calculate Y position with alignment logic
    double y;

    // 计算锚点中心位置的 Y 坐标
    final double anchorCenterY = anchorRect.center.dy;

    // 安全边距：箭头需要在圆角之外，同时考虑箭头宽度
    final double safeMargin = _maxRadius(borderRadius) + arrowWidth / 2;

    if (usePointerAnchor) {
      // 点击位置模式：菜单在垂直方向居中对齐点击坐标，并在上下边界内收敛
      y = anchorCenterY - childSize.height / 2;
      if (y + childSize.height > bottomLimit - horizontalMargin) {
        y = bottomLimit - horizontalMargin - childSize.height;
      }
      if (y < topLimit + horizontalMargin) {
        y = topLimit + horizontalMargin;
      }
    } else {
      // 默认：context_menu 顶部与子组件顶部对齐
      final double topAlignedY = anchorRect.top;

      // 检查顶部对齐时，底部是否有足够空间
      final bool fitsWithTopAlign =
          topAlignedY + childSize.height <= bottomLimit - horizontalMargin;

      if (fitsWithTopAlign) {
        // 顶部对齐，底部空间足够
        y = topAlignedY;
        // 确保不超出顶部边界
        if (y < topLimit + horizontalMargin) {
          y = topLimit + horizontalMargin;
        }
      } else {
        // 底部空间不足，改为底部对齐
        // context_menu 底部与子组件底部对齐
        y = anchorRect.bottom - childSize.height;
        // 确保不超出顶部边界
        if (y < topLimit + horizontalMargin) {
          y = topLimit + horizontalMargin;
        }
      }
    }

    // Calculate arrow offset - arrow should point to the center of anchor
    // Arrow offset is relative to menu's top edge (不包含 padding)
    double arrowOffset = anchorCenterY - y;

    // Clamp arrow offset to be within the menu's valid area
    // to keep the arrow away from rounded corners
    if (arrowOffset < safeMargin) {
      arrowOffset = safeMargin;
    }
    if (arrowOffset > childSize.height - safeMargin) {
      arrowOffset = childSize.height - safeMargin;
    }

    if (mounted) {
      setState(() {
        _childSize = childSize;
        _childPosition = Offset(x, y);
        _arrowOffset = arrowOffset;
        _arrowDirection = arrowDirection;
      });
    }
  }

  double _maxRadius(BorderRadius radius) {
    return <double>[
      radius.topLeft.x,
      radius.topLeft.y,
      radius.topRight.x,
      radius.topRight.y,
      radius.bottomLeft.x,
      radius.bottomLeft.y,
      radius.bottomRight.x,
      radius.bottomRight.y,
    ].reduce(max);
  }

  Widget _decorateMenu(Widget child) {
    if (!widget.applyCupertinoSheetTransition) {
      return child;
    }
    return ChatContextMenuSheetTransition(
      animation: widget.animation!,
      alignment: sheetScaleAlignment(
        axis: Axis.horizontal,
        horizontal: _arrowDirection,
        arrowOffset: _arrowOffset,
        menuSize: _childSize,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_childSize == null) {
      return Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0,
              child: Container(
                key: _childKey,
                child: widget.childBuilder(context, null, ArrowHorizontalDirection.left),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Positioned(
          left: _childPosition!.dx,
          top: _childPosition!.dy,
          child: _decorateMenu(widget.childBuilder(context, _arrowOffset, _arrowDirection)),
        ),
      ],
    );
  }
}
