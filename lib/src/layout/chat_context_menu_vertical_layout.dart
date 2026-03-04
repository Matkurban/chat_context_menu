import 'dart:math';

import 'package:chat_context_menu/src/model/arrow_vertical_direction.dart';
import 'package:flutter/material.dart';

class ChatContextMenuVerticalLayout extends StatefulWidget {
  const ChatContextMenuVerticalLayout({
    super.key,
    required this.widgetRect,
    this.pointerRect,
    required this.childBuilder,
    required this.padding,
    required this.arrowHeight,
    required this.spacing,
    required this.arrowWidth,
    required this.borderRadius,
    required this.horizontalMargin,
    this.layoutConstraints,
    required this.topPadding,
  });

  final Rect widgetRect;
  final Rect? pointerRect;
  final Widget Function(
    BuildContext context,
    double? arrowOffset,
    ArrowVerticalDirection isArrowUp,
  )
  childBuilder;

  final EdgeInsets padding;
  final double arrowHeight;
  final double spacing;
  final double arrowWidth;
  final BorderRadius borderRadius;
  final double horizontalMargin;
  final BoxConstraints? layoutConstraints;
  final double topPadding;

  @override
  State<ChatContextMenuVerticalLayout> createState() =>
      _ChatContextMenuVerticalLayoutState();
}

class _ChatContextMenuVerticalLayoutState
    extends State<ChatContextMenuVerticalLayout> {
  final GlobalKey _childKey = GlobalKey();
  Size? _childSize;
  Offset? _childPosition;
  double? _arrowOffset;
  ArrowVerticalDirection _isArrowUp = .down;
  double? _maxHeight;

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

    final double topLimit = media.padding.top + widget.topPadding;
    final double screenBottomLimit =
        screenSize.height - (media.padding.bottom + media.viewInsets.bottom);
    final double availableHeightFromConstraints =
        (widget.layoutConstraints != null &&
            widget.layoutConstraints!.maxHeight.isFinite)
        ? widget.layoutConstraints!.maxHeight
        : screenBottomLimit - topLimit;
    final double bottomLimit = topLimit + availableHeightFromConstraints;

    final double availableHeight = bottomLimit - topLimit;
    final double maxChildHeight = max(0, availableHeight - arrowHeight);
    double constrainedChildHeight = childSize.height;
    double effectiveSpacing = spacing;

    if (constrainedChildHeight > maxChildHeight) {
      constrainedChildHeight = maxChildHeight;
      // When content is taller than the available screen height,
      // drop spacing to keep the menu visible.
      effectiveSpacing = 0;
    }

    final double menuHeight = constrainedChildHeight + arrowHeight;
    final double totalHeight = menuHeight + effectiveSpacing;
    final double widgetBottomSpace = bottomLimit - widgetRect.bottom;
    final double widgetTopSpace = widgetRect.top - topLimit;
    final bool fitsWithWidgetAnchor =
        widgetTopSpace >= totalHeight || widgetBottomSpace >= totalHeight;
    final bool usePointerAnchor =
        widget.pointerRect != null && !fitsWithWidgetAnchor;

    // Calculate available space
    final Rect anchorRect = usePointerAnchor ? widget.pointerRect! : widgetRect;
    final double bottomSpace = bottomLimit - anchorRect.bottom;
    final double topSpace = anchorRect.top - topLimit;

    ArrowVerticalDirection isArrowUp = .up;
    double y = anchorRect.bottom + effectiveSpacing;

    // Prefer bottom, but check if it fits
    if (y + menuHeight > bottomLimit) {
      // If it doesn't fit bottom, try top
      if (topSpace > totalHeight) {
        y =
            anchorRect.top -
            constrainedChildHeight -
            arrowHeight -
            effectiveSpacing;
        isArrowUp = .down;
      } else {
        // If it fits neither, pick the one with more space
        if (topSpace > bottomSpace) {
          y =
              anchorRect.top -
              constrainedChildHeight -
              arrowHeight -
              effectiveSpacing;
          isArrowUp = .down;
        } else {
          // else keep bottom (default), but clamp to bottomLimit
          if (y + totalHeight > bottomLimit) {
            final double maxY =
                bottomLimit - constrainedChildHeight - arrowHeight;
            if (maxY <= anchorRect.bottom) {
              // Not enough room below without covering the anchor; flip to top.
              y =
                  anchorRect.top -
                  constrainedChildHeight -
                  arrowHeight -
                  effectiveSpacing;
              isArrowUp = .down;
            } else {
              // Clamp within bottom limit while keeping spacing from the anchor.
              y = max(maxY, anchorRect.bottom + effectiveSpacing);
            }
          }
        }
      }
    }

    final double minY = topLimit;
    final double maxY = bottomLimit - menuHeight;
    if (y < minY) y = minY;
    if (y > maxY) y = maxY;

    double x = anchorRect.center.dx - childSize.width / 2;
    if (x < horizontalMargin) x = horizontalMargin;
    if (x + childSize.width > screenSize.width - horizontalMargin) {
      x = screenSize.width - childSize.width - horizontalMargin;
    }

    // Calculate arrow offset relative to the child's left edge
    double arrowOffset = anchorRect.center.dx - x;

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
        _childSize = Size(childSize.width, constrainedChildHeight);
        _childPosition = Offset(x, y);
        _arrowOffset = arrowOffset;
        _isArrowUp = isArrowUp;
        _maxHeight = constrainedChildHeight < childSize.height
            ? constrainedChildHeight
            : null;
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
            child: Opacity(
              opacity: 0,
              child: Container(
                key: _childKey,
                child: widget.childBuilder(context, null, .down),
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
          child: _maxHeight == null
              ? widget.childBuilder(context, _arrowOffset, _isArrowUp)
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: _maxHeight!),
                  child: widget.childBuilder(context, _arrowOffset, _isArrowUp),
                ),
        ),
      ],
    );
  }
}
