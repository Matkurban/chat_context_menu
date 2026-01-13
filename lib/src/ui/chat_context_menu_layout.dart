import 'dart:math';

import 'package:chat_context_menu/src/model/arrow_direction.dart';
import 'package:flutter/material.dart';

class ChatContextMenuLayout extends StatefulWidget {
  const ChatContextMenuLayout({
    super.key,
    required this.widgetRect,
    required this.childBuilder,
    required this.padding,
    required this.arrowHeight,
    required this.spacing,
    required this.arrowWidth,
    required this.borderRadius,
    required this.horizontalMargin,
  });

  final Rect widgetRect;
  final Widget Function(
    BuildContext context,
    double? arrowOffset,
    ArrowDirection isArrowUp,
  )
  childBuilder;

  final EdgeInsets padding;
  final double arrowHeight;
  final double spacing;
  final double arrowWidth;
  final BorderRadius borderRadius;
  final double horizontalMargin;

  @override
  State<ChatContextMenuLayout> createState() => _ChatContextMenuLayoutState();
}

class _ChatContextMenuLayoutState extends State<ChatContextMenuLayout> {
  final GlobalKey _childKey = GlobalKey();
  Size? _childSize;
  Offset? _childPosition;
  double? _arrowOffset;
  ArrowDirection _isArrowUp = .down;

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
    final RenderBox? renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Size childSize = renderBox.size;
    final MediaQueryData media = MediaQuery.of(context);
    final Size screenSize = media.size;
    final Rect widgetRect = widget.widgetRect;

    final double topLimit = media.padding.top + kToolbarHeight;
    final double bottomLimit =
        screenSize.height -
        (media.padding.bottom +
            kBottomNavigationBarHeight +
            media.viewInsets.bottom);

    // Calculate available space
    final double bottomSpace = bottomLimit - widgetRect.bottom;
    final double topSpace = widgetRect.top - topLimit;

    final double totalHeight = childSize.height + arrowHeight + spacing;

    ArrowDirection isArrowUp = .up;
    double y = widgetRect.bottom + spacing;

    // Prefer bottom, but check if it fits
    if (y + totalHeight > bottomLimit) {
      // If it doesn't fit bottom, try top
      if (topSpace > totalHeight) {
        y = widgetRect.top - childSize.height - arrowHeight - spacing;
        isArrowUp = .down;
      } else {
        // If it fits neither, pick the one with more space
        if (topSpace > bottomSpace) {
          y = widgetRect.top - childSize.height - arrowHeight - spacing;
          isArrowUp = .down;
        } else {
          // else keep bottom (default), but clamp to bottomLimit
          if (y + totalHeight > bottomLimit) {
            final double maxY = bottomLimit - childSize.height - arrowHeight;
            if (maxY <= widgetRect.bottom) {
              // Not enough room below without covering the anchor; flip to top.
              y = widgetRect.top - childSize.height - arrowHeight - spacing;
              isArrowUp = .down;
            } else {
              // Clamp within bottom limit while keeping spacing from the anchor.
              y = max(maxY, widgetRect.bottom + spacing);
            }
          }
        }
      }
    }

    double x = widgetRect.center.dx - childSize.width / 2;
    if (x < horizontalMargin) x = horizontalMargin;
    if (x + childSize.width > screenSize.width - horizontalMargin) {
      x = screenSize.width - childSize.width - horizontalMargin;
    }

    // Calculate arrow offset relative to the child's left edge
    double arrowOffset = widgetRect.center.dx - x;

    // Clamp arrow offset to be within the child using provided radius and width
    // to keep the arrow away from rounded corners.
    final double safeMargin =
        _maxRadius(borderRadius) + arrowWidth / 2; // Radius + half arrow width
    if (arrowOffset < safeMargin) arrowOffset = safeMargin;
    if (arrowOffset > childSize.width - safeMargin) {
      arrowOffset = childSize.width - safeMargin;
    }

    if (mounted) {
      setState(() {
        _childSize = childSize;
        _childPosition = Offset(x, y);
        _arrowOffset = arrowOffset;
        _isArrowUp = isArrowUp;
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

  @override
  Widget build(BuildContext context) {
    if (_childSize == null) {
      return Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              key: _childKey,
              child: widget.childBuilder(context, null, .down),
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
          child: widget.childBuilder(context, _arrowOffset, _isArrowUp),
        ),
      ],
    );
  }
}
