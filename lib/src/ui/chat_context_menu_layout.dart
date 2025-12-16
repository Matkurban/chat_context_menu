import 'package:flutter/material.dart';

class ChatContextMenuLayout extends StatefulWidget {
  final Rect widgetRect;
  final Widget Function(
    BuildContext context,
    double? arrowOffset,
    bool isArrowUp,
  )
  childBuilder;

  const ChatContextMenuLayout({
    super.key,
    required this.widgetRect,
    required this.childBuilder,
  });

  @override
  State<ChatContextMenuLayout> createState() => _ChatContextMenuLayoutState();
}

class _ChatContextMenuLayoutState extends State<ChatContextMenuLayout> {
  final GlobalKey _childKey = GlobalKey();
  Size? _childSize;
  Offset? _childPosition;
  double? _arrowOffset;
  bool _isArrowUp = false;

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
    final Size screenSize = MediaQuery.of(context).size;
    final Rect widgetRect = widget.widgetRect;
    final double arrowHeight = 8.0; // Matches ChatContextMenuShape default

    // Calculate available space
    final double bottomSpace = screenSize.height - widgetRect.bottom;
    final double topSpace = widgetRect.top;

    final double totalHeight =
        childSize.height + arrowHeight + 10; // 10 padding

    bool isArrowUp = true;
    double y = widgetRect.bottom + 10;

    // Prefer bottom, but check if it fits
    if (y + totalHeight > screenSize.height) {
      // If it doesn't fit bottom, try top
      if (topSpace > totalHeight) {
        y = widgetRect.top - childSize.height - arrowHeight - 10;
        isArrowUp = false;
      } else {
        // If it fits neither, pick the one with more space
        if (topSpace > bottomSpace) {
          y = widgetRect.top - childSize.height - arrowHeight - 10;
          isArrowUp = false;
        }
        // else keep bottom (default)
      }
    }

    double x = widgetRect.center.dx - childSize.width / 2;
    if (x < 10) x = 10;
    if (x + childSize.width > screenSize.width - 10) {
      x = screenSize.width - childSize.width - 10;
    }

    // Calculate arrow offset relative to the child's left edge
    double arrowOffset = widgetRect.center.dx - x;

    // Clamp arrow offset to be within the child
    // We assume border radius is around 12.0, so keep arrow away from corners
    final double safeMargin = 12.0 + 6.0; // Radius + half arrow width
    if (arrowOffset < safeMargin) arrowOffset = safeMargin;
    if (arrowOffset > childSize.width - safeMargin)
      arrowOffset = childSize.width - safeMargin;

    if (mounted) {
      setState(() {
        _childSize = childSize;
        _childPosition = Offset(x, y);
        _arrowOffset = arrowOffset;
        _isArrowUp = isArrowUp;
      });
    }
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
              child: widget.childBuilder(context, null, false),
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
