import 'dart:math';
import 'package:chat_context_menu/src/model/arrow_vertical_direction.dart';
import 'package:chat_context_menu/src/shape/chat_context_menu_vertical_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///文本选中的 Overlay 覆盖层
///Renders text selection overlay with draggable handles
class SelectableTextOverlay extends StatefulWidget {
  const SelectableTextOverlay({
    super.key,
    required this.text,
    required this.textStyle,
    required this.textAlign,
    required this.textDirection,
    required this.maxLines,
    required this.overflow,
    required this.textScaler,
    required this.textWidthBasis,
    required this.textHeightBehavior,
    required this.selectionColor,
    required this.handleColor,
    required this.widgetRect,
    required this.menuBuilder,
    required this.initialSelection,
    required this.onSelectionChanged,
    required this.strutStyle,
    required this.locale,
    required this.softWrap,
    required this.handleSize,
    required this.animation,
    this.enableHapticFeedback = true,
    this.transitionsBuilder,
    this.menuBackgroundColor,
    this.menuBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.menuPadding = const EdgeInsets.all(8),
    this.menuShadows,
    this.arrowHeight = 8.0,
    this.arrowWidth = 12.0,
    this.spacing = 6.0,
    this.horizontalMargin = 10.0,
  });

  ///文本内容
  ///Text content
  final String text;

  ///文本样式
  ///Text style
  final TextStyle textStyle;

  ///文本对齐方式
  ///Text alignment
  final TextAlign textAlign;

  ///文本方向
  ///Text direction
  final TextDirection textDirection;

  ///最大行数
  ///Maximum lines
  final int? maxLines;

  ///溢出处理
  ///Overflow handling
  final TextOverflow overflow;

  ///文本缩放
  ///Text scaler
  final TextScaler textScaler;

  ///文本宽度基准
  ///Text width basis
  final TextWidthBasis textWidthBasis;

  ///文本高度行为
  ///Text height behavior
  final TextHeightBehavior? textHeightBehavior;

  ///选中区域的颜色
  ///Color of the selection highlight
  final Color selectionColor;

  ///选中手柄的颜色
  ///Color of the selection handles
  final Color handleColor;

  ///原始文本组件在屏幕中的位置
  ///The position of the original text widget on screen
  final Rect widgetRect;

  ///构建菜单的回调, 参数为选中的文本和关闭的回调
  ///Builder for the context menu, takes selected text and close callback
  final Widget Function(
    BuildContext context,
    String selectedText,
    VoidCallback hideMenu,
  )
  menuBuilder;

  ///初始选中范围
  ///Initial selection range
  final TextSelection initialSelection;

  ///选中文本变化时的回调
  ///Callback when selected text changes
  final ValueChanged<String>? onSelectionChanged;

  ///StrutStyle
  final StrutStyle? strutStyle;

  ///Locale
  final Locale? locale;

  ///是否自动换行
  ///Whether to soft wrap
  final bool softWrap;

  ///手柄大小
  ///Handle size
  final double handleSize;

  ///路由动画
  ///Route animation for menu transition
  final Animation<double> animation;

  ///是否启用触感反馈
  ///Whether to enable haptic feedback when the menu appears
  final bool enableHapticFeedback;

  ///自定义菜单过渡动画
  ///Custom menu transition animation
  final Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  transitionsBuilder;

  ///菜单容器的背景颜色
  ///Background color of the menu container
  final Color? menuBackgroundColor;

  ///菜单容器的圆角
  ///Rounded corners of menu container
  final BorderRadius menuBorderRadius;

  ///菜单容器的内边距
  ///Padding of menu container
  final EdgeInsets menuPadding;

  ///菜单容器的阴影
  ///Shadows of menu container
  final List<BoxShadow>? menuShadows;

  ///角标的高度
  ///The height of the arrow marker
  final double arrowHeight;

  ///角标的宽度
  ///The width of the arrow marker
  final double arrowWidth;

  ///菜单和选区的间距
  ///Spacing between menu and selection
  final double spacing;

  ///距屏幕左右的最小留白
  ///Minimum horizontal margin from screen edges
  final double horizontalMargin;

  @override
  State<SelectableTextOverlay> createState() => _SelectableTextOverlayState();
}

class _SelectableTextOverlayState extends State<SelectableTextOverlay> {
  late TextSelection _selection;
  final GlobalKey _textKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  TextPainter? _textPainter;
  bool _isDraggingBase = false;
  bool _isDraggingExtent = false;
  Size? _menuSize;
  bool _menuMeasured = false;

  @override
  void initState() {
    super.initState();
    _selection = widget.initialSelection;
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildTextPainter();
    });
  }

  void _measureMenu() {
    final RenderBox? renderBox =
        _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      setState(() {
        _menuSize = renderBox.size;
        _menuMeasured = true;
      });
    }
  }

  void _buildTextPainter() {
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.textStyle),
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      maxLines: widget.maxLines,
      textScaler: widget.textScaler,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      strutStyle: widget.strutStyle,
      locale: widget.locale,
    );
    tp.layout(maxWidth: widget.widgetRect.width);
    setState(() {
      _textPainter = tp;
    });
    // 在 textPainter 设置后的下一帧再测量菜单
    // Measure menu in the next frame after textPainter is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureMenu();
    });
  }

  String get _selectedText {
    if (_selection.isCollapsed) return '';
    final int start = _selection.start;
    final int end = _selection.end;
    return widget.text.substring(start, end);
  }

  TextPosition _getTextPositionForOffset(Offset localOffset) {
    if (_textPainter == null) return const TextPosition(offset: 0);
    return _textPainter!.getPositionForOffset(localOffset);
  }

  void _updateSelection(TextSelection newSelection) {
    if (newSelection != _selection) {
      setState(() => _selection = newSelection);
      final text = _selectedText;
      if (text.isNotEmpty) {
        widget.onSelectionChanged?.call(text);
      }
    }
  }

  ///移动单词边界（双击选词用）
  TextSelection _selectWordAtPosition(TextPosition position) {
    if (_textPainter == null) {
      return TextSelection.collapsed(offset: position.offset);
    }
    final TextRange word = _textPainter!.getWordBoundary(position);
    return TextSelection(baseOffset: word.start, extentOffset: word.end);
  }

  void _hideMenu() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _textPainter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ///背景点击关闭
        ///Tap on background to close
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _hideMenu,
          ),
        ),

        ///选中高亮 + 文本渲染
        ///Selection highlight + Text rendering
        Positioned(
          left: widget.widgetRect.left,
          top: widget.widgetRect.top,
          width: widget.widgetRect.width,
          child: GestureDetector(
            onTapDown: (details) {
              final localOffset = details.localPosition;
              final position = _getTextPositionForOffset(localOffset);
              _updateSelection(_selectWordAtPosition(position));
            },
            child: CustomPaint(
              foregroundPainter: _textPainter != null
                  ? _SelectionPainter(
                      textPainter: _textPainter!,
                      selection: _selection,
                      selectionColor: widget.selectionColor,
                    )
                  : null,
              child: Text(
                widget.text,
                key: _textKey,
                style: widget.textStyle,
                textAlign: widget.textAlign,
                textDirection: widget.textDirection,
                maxLines: widget.maxLines,
                overflow: widget.overflow,
                textScaler: widget.textScaler,
                textWidthBasis: widget.textWidthBasis,
                textHeightBehavior: widget.textHeightBehavior,
                strutStyle: widget.strutStyle,
                locale: widget.locale,
                softWrap: widget.softWrap,
              ),
            ),
          ),
        ),

        ///选中手柄 (base)
        ///Selection handle (base / start)
        if (_textPainter != null && !_selection.isCollapsed)
          _DraggableHandle(
            textPainter: _textPainter!,
            selectionOffset: _selection.baseOffset,
            widgetRect: widget.widgetRect,
            handleSize: widget.handleSize,
            handleColor: widget.handleColor,
            isBase: true,
            onPanStart: (_) => _isDraggingBase = true,
            onPanUpdate: (details) {
              final Offset globalPos = details.globalPosition;
              final Offset localOffset = Offset(
                globalPos.dx - widget.widgetRect.left,
                globalPos.dy - widget.widgetRect.top,
              );
              final TextPosition position = _getTextPositionForOffset(
                localOffset,
              );
              if (_isDraggingBase) {
                final int newBase = position.offset;
                final int extent = _selection.extentOffset;
                if (newBase != extent) {
                  _updateSelection(
                    TextSelection(
                      baseOffset: min(newBase, extent),
                      extentOffset: max(newBase, extent),
                    ),
                  );
                }
              }
            },
            onPanEnd: (_) => _isDraggingBase = false,
          ),

        ///选中手柄 (extent)
        ///Selection handle (extent / end)
        if (_textPainter != null && !_selection.isCollapsed)
          _DraggableHandle(
            textPainter: _textPainter!,
            selectionOffset: _selection.extentOffset,
            widgetRect: widget.widgetRect,
            handleSize: widget.handleSize,
            handleColor: widget.handleColor,
            isBase: false,
            onPanStart: (_) => _isDraggingExtent = true,
            onPanUpdate: (details) {
              final Offset globalPos = details.globalPosition;
              final Offset localOffset = Offset(
                globalPos.dx - widget.widgetRect.left,
                globalPos.dy - widget.widgetRect.top,
              );
              final TextPosition position = _getTextPositionForOffset(
                localOffset,
              );
              if (_isDraggingExtent) {
                final int base = _selection.baseOffset;
                final int newExtent = position.offset;
                if (base != newExtent) {
                  _updateSelection(
                    TextSelection(
                      baseOffset: min(base, newExtent),
                      extentOffset: max(base, newExtent),
                    ),
                  );
                }
              }
            },
            onPanEnd: (_) => _isDraggingExtent = false,
          ),

        ///菜单
        ///Context menu
        if (!_selection.isCollapsed && _textPainter != null)
          if (!_menuMeasured)
            Positioned(
              left: -9999,
              top: -9999,
              child: Opacity(
                opacity: 0,
                child: Material(
                  key: _menuKey,
                  type: MaterialType.transparency,
                  color: Colors.transparent,
                  child: widget.menuBuilder(context, _selectedText, _hideMenu),
                ),
              ),
            )
          else
            _PositionedMenu(
              textPainter: _textPainter!,
              selection: _selection,
              widgetRect: widget.widgetRect,
              handleSize: widget.handleSize,
              menuSize: _menuSize,
              menuBuilder: widget.menuBuilder,
              selectedText: _selectedText,
              onHideMenu: _hideMenu,
              animation: widget.animation,
              transitionsBuilder: widget.transitionsBuilder,
              menuBackgroundColor: widget.menuBackgroundColor,
              menuBorderRadius: widget.menuBorderRadius,
              menuPadding: widget.menuPadding,
              menuShadows: widget.menuShadows,
              arrowHeight: widget.arrowHeight,
              arrowWidth: widget.arrowWidth,
              spacing: widget.spacing,
              horizontalMargin: widget.horizontalMargin,
            ),
      ],
    );
  }
}

///选区高亮绘制
///Paints the selection highlight rectangles
class _SelectionPainter extends CustomPainter {
  final TextPainter textPainter;
  final TextSelection selection;
  final Color selectionColor;

  _SelectionPainter({
    required this.textPainter,
    required this.selection,
    required this.selectionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selection.isCollapsed) return;

    final List<TextBox> boxes = textPainter.getBoxesForSelection(selection);
    final Paint paint = Paint()..color = selectionColor;
    for (final TextBox box in boxes) {
      canvas.drawRect(
        Rect.fromLTRB(box.left, box.top, box.right, box.bottom),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SelectionPainter oldDelegate) {
    return oldDelegate.selection != selection ||
        oldDelegate.selectionColor != selectionColor;
  }
}

///可拖拽的选区手柄
///Draggable selection handle with positioning
class _DraggableHandle extends StatelessWidget {
  const _DraggableHandle({
    required this.textPainter,
    required this.selectionOffset,
    required this.widgetRect,
    required this.handleSize,
    required this.handleColor,
    required this.isBase,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final TextPainter textPainter;
  final int selectionOffset;
  final Rect widgetRect;
  final double handleSize;
  final Color handleColor;
  final bool isBase;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    final caretOffset = textPainter.getOffsetForCaret(
      TextPosition(offset: selectionOffset),
      Rect.zero,
    );
    final double lineHeight = textPainter.preferredLineHeight;
    final double circleRadius = handleSize / 3;
    final double totalHeight = lineHeight + circleRadius * 2;
    final double handleX = widgetRect.left + caretOffset.dx;
    final double handleY = isBase
        ? widgetRect.top + caretOffset.dy - totalHeight + lineHeight
        : widgetRect.top + caretOffset.dy;

    return Positioned(
      left: handleX - handleSize / 2,
      top: handleY,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: _SelectionHandle(
          color: handleColor,
          size: handleSize,
          lineHeight: lineHeight,
          isBase: isBase,
        ),
      ),
    );
  }
}

///菜单定位组件
///Positioned context menu with arrow
class _PositionedMenu extends StatelessWidget {
  const _PositionedMenu({
    required this.textPainter,
    required this.selection,
    required this.widgetRect,
    required this.handleSize,
    required this.menuSize,
    required this.menuBuilder,
    required this.selectedText,
    required this.onHideMenu,
    required this.animation,
    this.transitionsBuilder,
    this.menuBackgroundColor,
    required this.menuBorderRadius,
    required this.menuPadding,
    this.menuShadows,
    required this.arrowHeight,
    required this.arrowWidth,
    required this.spacing,
    required this.horizontalMargin,
  });

  final TextPainter textPainter;
  final TextSelection selection;
  final Rect widgetRect;
  final double handleSize;
  final Size? menuSize;
  final Widget Function(
    BuildContext context,
    String selectedText,
    VoidCallback hideMenu,
  )
  menuBuilder;
  final String selectedText;
  final VoidCallback onHideMenu;
  final Animation<double> animation;
  final Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  transitionsBuilder;
  final Color? menuBackgroundColor;
  final BorderRadius menuBorderRadius;
  final EdgeInsets menuPadding;
  final List<BoxShadow>? menuShadows;
  final double arrowHeight;
  final double arrowWidth;
  final double spacing;
  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // 计算选区的顶部和底部位置
    final baseCaretOffset = textPainter.getOffsetForCaret(
      TextPosition(offset: selection.baseOffset),
      Rect.zero,
    );
    final extentCaretOffset = textPainter.getOffsetForCaret(
      TextPosition(offset: selection.extentOffset),
      Rect.zero,
    );

    final double selectionTopY =
        widgetRect.top + min(baseCaretOffset.dy, extentCaretOffset.dy);
    final double selectionBottomY =
        widgetRect.top +
        max(baseCaretOffset.dy, extentCaretOffset.dy) +
        textPainter.preferredLineHeight;
    final double selectionCenterX =
        widgetRect.left + (baseCaretOffset.dx + extentCaretOffset.dx) / 2;

    final double menuWidth = menuSize?.width ?? 200;
    final double menuHeight = menuSize?.height ?? 48;

    // 菜单总高度包含箭头
    final double totalMenuHeight = menuHeight + arrowHeight;
    // 菜单和选区的总间距（包含手柄）
    final double totalSpacing = handleSize + spacing;

    // 决定箭头方向：优先上方(箭头朝下)
    ArrowVerticalDirection arrowDirection;
    double menuY;

    final double spaceAbove = selectionTopY - topPadding;
    final double spaceBelow = screenHeight - bottomPadding - selectionBottomY;

    if (spaceAbove >= totalMenuHeight + totalSpacing) {
      arrowDirection = ArrowVerticalDirection.down;
      menuY = selectionTopY - totalSpacing - totalMenuHeight;
    } else if (spaceBelow >= totalMenuHeight + totalSpacing) {
      arrowDirection = ArrowVerticalDirection.up;
      menuY = selectionBottomY + totalSpacing;
    } else {
      if (spaceAbove > spaceBelow) {
        arrowDirection = ArrowVerticalDirection.down;
        menuY = selectionTopY - totalSpacing - totalMenuHeight;
      } else {
        arrowDirection = ArrowVerticalDirection.up;
        menuY = selectionBottomY + totalSpacing;
      }
    }

    // 水平位置：以选区中心为参考
    double menuX = selectionCenterX - menuWidth / 2;
    if (menuX < horizontalMargin) menuX = horizontalMargin;
    if (menuX + menuWidth > screenWidth - horizontalMargin) {
      menuX = screenWidth - menuWidth - horizontalMargin;
    }

    // 垂直边界约束
    if (menuY < topPadding) menuY = topPadding;
    if (menuY + totalMenuHeight > screenHeight - bottomPadding) {
      menuY = screenHeight - bottomPadding - totalMenuHeight;
    }

    // 计算箭头偏移量（相对于菜单左边缘）
    double arrowOffset = selectionCenterX - menuX;

    // 箭头安全区域：避免进入圆角
    final double safeMargin = _maxRadius(menuBorderRadius) + arrowWidth / 2;
    if (arrowOffset < safeMargin) arrowOffset = safeMargin;
    if (arrowOffset > menuWidth - safeMargin) {
      arrowOffset = menuWidth - safeMargin;
    }

    final Widget menuWidget = Material(
      type: MaterialType.transparency,
      color: Colors.transparent,
      child: Container(
        padding: menuPadding,
        decoration: ShapeDecoration(
          color: menuBackgroundColor,
          shadows: menuShadows,
          shape: ChatContextMenuVerticalShape(
            arrowOffset: arrowOffset,
            isArrowUp: arrowDirection,
            borderRadius: menuBorderRadius,
            arrowHeight: arrowHeight,
            arrowWidth: arrowWidth,
          ),
        ),
        child: menuBuilder(context, selectedText, onHideMenu),
      ),
    );

    // 计算菜单中心对齐
    final Offset menuCenter = Offset(
      menuX + menuWidth / 2,
      menuY + totalMenuHeight / 2,
    );
    final double alignX = (menuCenter.dx / screenSize.width) * 2 - 1;
    final double alignY = (menuCenter.dy / screenSize.height) * 2 - 1;
    final Alignment alignment = Alignment(alignX, alignY);

    final Animation<double> curve = animation.drive(
      CurveTween(curve: Curves.fastOutSlowIn),
    );

    final Widget animatedMenu =
        transitionsBuilder?.call(
          context,
          animation,
          menuCenter,
          alignment,
          menuWidget,
        ) ??
        FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: curve,
            alignment: alignment,
            child: menuWidget,
          ),
        );

    return Positioned(left: menuX, top: menuY, child: animatedMenu);
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
}

///选区手柄绘制
///Selection handle widget (circle with vertical line)
class _SelectionHandle extends StatelessWidget {
  const _SelectionHandle({
    required this.color,
    required this.size,
    required this.lineHeight,
    required this.isBase,
  });

  final Color color;
  final double size;
  final double lineHeight;
  final bool isBase;

  @override
  Widget build(BuildContext context) {
    final double circleRadius = size / 3;
    final double totalHeight = lineHeight + circleRadius * 2;
    return SizedBox(
      width: size,
      height: totalHeight,
      child: CustomPaint(
        painter: _HandlePainter(color: color, isBase: isBase),
      ),
    );
  }
}

///手柄形状绘制器（圆形 + 竖线）
///Handle shape painter (circle with vertical line)
class _HandlePainter extends CustomPainter {
  final Color color;
  final bool isBase;

  _HandlePainter({required this.color, required this.isBase});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double radius = w / 3;
    final double lineWidth = 2.0;

    if (isBase) {
      // base 手柄在选区上方: 圆在上, 竖线在下
      final double cx = w / 2;
      final double circleY = radius;
      final double lineHeight = h - radius * 2;

      // 圆
      canvas.drawCircle(Offset(cx, circleY), radius, paint);
      // 竖线
      canvas.drawRect(
        Rect.fromLTWH(cx - lineWidth / 2, radius * 2, lineWidth, lineHeight),
        paint,
      );
    } else {
      // extent 手柄在选区下方: 竖线在上, 圆在下
      final double cx = w / 2;
      final double circleY = h - radius;
      final double lineHeight = h - radius * 2;

      // 竖线
      canvas.drawRect(
        Rect.fromLTWH(cx - lineWidth / 2, 0, lineWidth, lineHeight),
        paint,
      );
      // 圆
      canvas.drawCircle(Offset(cx, circleY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandlePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isBase != isBase;
  }
}
