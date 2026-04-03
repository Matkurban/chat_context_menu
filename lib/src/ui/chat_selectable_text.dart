import 'dart:math';

import 'package:chat_context_menu/src/model/arrow_vertical_direction.dart';
import 'package:chat_context_menu/src/shape/chat_context_menu_vertical_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

///从底层完全自定义实现的可选择文本组件
///使用 RichText 渲染文本，TextPainter 计算选区几何，
///OverlayEntry 显示手柄和菜单，CompositedTransformFollower 跟踪位置
///
///Fully custom selectable text widget built from the ground up.
///Uses RichText for rendering, TextPainter for selection geometry,
///OverlayEntry for handles and menu, CompositedTransformFollower for positioning.
class ChatSelectableText extends StatefulWidget {
  const ChatSelectableText(
    this.data, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textScaler = TextScaler.noScaling,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.strutStyle,
    this.locale,
    this.softWrap = true,
    this.selectAllOnActivate = true,
    this.selectionColor,
    this.handleColor,
    this.handleSize = 16.0,
    this.autoScrollEdgeExtent = 48.0,
    this.autoScrollSpeed = 10.0,
    this.enableHapticFeedback = true,
    required this.menuBuilder,
    this.onSelectionChanged,
    this.onMenuClosed,
    this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 150),
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
  final String data;

  ///文本样式
  final TextStyle? style;

  ///文本对齐方式
  final TextAlign textAlign;

  ///文本方向
  final TextDirection? textDirection;

  ///最大行数
  final int? maxLines;

  ///溢出处理
  final TextOverflow overflow;

  ///文本缩放
  final TextScaler textScaler;

  ///文本宽度基准
  final TextWidthBasis textWidthBasis;

  ///文本高度行为
  final TextHeightBehavior? textHeightBehavior;

  ///StrutStyle
  final StrutStyle? strutStyle;

  ///Locale
  final Locale? locale;

  ///是否自动换行
  final bool softWrap;

  ///激活选择时是否全选文本，默认为true
  ///When true, selects all text on activation; when false, selects the word at tap position.
  final bool selectAllOnActivate;

  ///选中区域的颜色
  final Color? selectionColor;

  ///选中手柄的颜色
  final Color? handleColor;

  ///手柄大小
  final double handleSize;

  ///拖拽手柄时距离视口边缘多少像素开始自动滚动
  ///Distance from viewport edge to start auto-scrolling when dragging handles.
  final double autoScrollEdgeExtent;

  ///自动滚动的速度（每帧像素数）
  ///Auto-scroll speed in pixels per frame.
  final double autoScrollSpeed;

  ///是否启用触感反馈
  final bool enableHapticFeedback;

  ///构建菜单的回调
  final Widget Function(
    BuildContext context,
    String selectedText,
    VoidCallback hideMenu,
    VoidCallback selectAll,
  )
  menuBuilder;

  ///选中文本变化时的回调
  final ValueChanged<String>? onSelectionChanged;

  ///菜单关闭时的回调
  final VoidCallback? onMenuClosed;

  ///自定义菜单动画
  final Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  transitionsBuilder;

  ///菜单动画时长
  final Duration transitionDuration;

  ///菜单容器的背景颜色
  final Color? menuBackgroundColor;

  ///菜单容器的圆角
  final BorderRadius menuBorderRadius;

  ///菜单容器的内边距
  final EdgeInsets menuPadding;

  ///菜单容器的阴影
  final List<BoxShadow>? menuShadows;

  ///角标的高度
  final double arrowHeight;

  ///角标的宽度
  final double arrowWidth;

  ///菜单和选区的间距
  final double spacing;

  ///距屏幕左右的最小留白
  final double horizontalMargin;

  @override
  State<ChatSelectableText> createState() => _ChatSelectableTextState();
}

class _ChatSelectableTextState extends State<ChatSelectableText> with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  TextPainter? _textPainter;
  TextSelection _selection = const TextSelection.collapsed(offset: -1);
  bool _isActive = false;

  OverlayEntry? _handleBaseEntry;
  OverlayEntry? _handleExtentEntry;
  OverlayEntry? _menuEntry;
  OverlayEntry? _barrierEntry;

  AnimationController? _menuAnimationController;

  final GlobalKey _menuMeasureKey = GlobalKey();
  Size? _menuSize;

  bool _isDraggingBase = false;
  bool _isDraggingExtent = false;

  Offset? _activationGlobalPosition;

  ScrollPosition? _scrollPosition;
  bool _isScrolling = false;

  Ticker? _autoScrollTicker;
  double _autoScrollDirection = 0; // -1 up, +1 down, 0 stop
  Offset? _lastDragGlobalPosition;
  bool _lastDragIsBase = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildTextPainter();
  }

  @override
  void didUpdateWidget(ChatSelectableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.style != widget.style) {
      _buildTextPainter();
      if (_isActive) {
        _deactivateSelection();
      }
    }
  }

  void _buildTextPainter() {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveStyle = widget.style ?? defaultTextStyle.style;
    if (widget.style == null || widget.style!.inherit) {
      effectiveStyle = defaultTextStyle.style.merge(effectiveStyle);
    }

    _textPainter?.dispose();
    _textPainter = TextPainter(
      text: TextSpan(text: widget.data, style: effectiveStyle),
      textAlign: widget.textAlign,
      textDirection: widget.textDirection ?? Directionality.of(context),
      maxLines: widget.maxLines,
      textScaler: widget.textScaler,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      strutStyle: widget.strutStyle,
      locale: widget.locale,
    );
  }

  void _layoutTextPainter() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    _textPainter?.layout(maxWidth: renderBox.size.width);
  }

  TextPosition _getPositionForOffset(Offset localOffset) {
    if (_textPainter == null) return const TextPosition(offset: 0);
    return _textPainter!.getPositionForOffset(localOffset);
  }

  TextSelection _selectWordAtPosition(TextPosition position) {
    if (_textPainter == null) {
      return TextSelection.collapsed(offset: position.offset);
    }
    final TextRange word = _textPainter!.getWordBoundary(position);
    if (word.start == word.end) {
      return TextSelection.collapsed(offset: position.offset);
    }
    return TextSelection(baseOffset: word.start, extentOffset: word.end);
  }

  String get _selectedText {
    if (_selection.isCollapsed || _selection.start < 0) return '';
    return widget.data.substring(_selection.start, _selection.end);
  }

  Offset _getTextGlobalOffset() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.attached) {
      return renderBox.localToGlobal(Offset.zero);
    }
    return Offset.zero;
  }

  void _updateSelection(TextSelection newSelection) {
    if (newSelection != _selection) {
      setState(() => _selection = newSelection);
      final text = _selectedText;
      if (text.isNotEmpty) {
        widget.onSelectionChanged?.call(text);
      }
      _updateHandles();
      _updateMenu();
    }
  }

  // ─── 激活选择模式 ───

  void _activateSelection(Offset localPosition) {
    _layoutTextPainter();

    // 记录激活位置（全局坐标）
    final Offset textGlobal = _getTextGlobalOffset();
    _activationGlobalPosition = textGlobal + localPosition;

    final TextSelection newSelection;
    if (widget.selectAllOnActivate) {
      newSelection = TextSelection(baseOffset: 0, extentOffset: widget.data.length);
    } else {
      final position = _getPositionForOffset(localPosition);
      final wordSelection = _selectWordAtPosition(position);
      if (wordSelection.isCollapsed) return;
      newSelection = wordSelection;
    }

    _selection = newSelection;
    _isActive = true;

    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    _attachScrollListener();
    _showBarrier();
    _showHandles();
    _showMenu();
    setState(() {});

    final text = _selectedText;
    if (text.isNotEmpty) {
      widget.onSelectionChanged?.call(text);
    }
  }

  // ─── 选区内点击选词 ───

  void _onTapDownInSelection(Offset localPosition) {
    if (!_isActive || _textPainter == null) return;
    _layoutTextPainter();

    // 更新按压位置
    final Offset textGlobal = _getTextGlobalOffset();
    _activationGlobalPosition = textGlobal + localPosition;

    final position = _getPositionForOffset(localPosition);
    final wordSelection = _selectWordAtPosition(position);
    if (!wordSelection.isCollapsed) {
      _updateSelection(wordSelection);
    }
  }

  // ─── 拖拽时自动滚动 ───

  Rect? _getViewportRect() {
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return null;
    final RenderBox? scrollBox = scrollable.context.findRenderObject() as RenderBox?;
    if (scrollBox == null || !scrollBox.attached) return null;
    return scrollBox.localToGlobal(Offset.zero) & scrollBox.size;
  }

  void _startAutoScroll(double direction) {
    _autoScrollDirection = direction;
    if (_autoScrollTicker != null && _autoScrollTicker!.isActive) return;
    _autoScrollTicker?.dispose();
    _autoScrollTicker = createTicker(_onAutoScrollTick)..start();
  }

  void _stopAutoScroll() {
    _autoScrollDirection = 0;
    _autoScrollTicker?.stop();
    _autoScrollTicker?.dispose();
    _autoScrollTicker = null;
  }

  void _onAutoScrollTick(Duration elapsed) {
    if (_scrollPosition == null || _autoScrollDirection == 0) {
      _stopAutoScroll();
      return;
    }
    final double delta = _autoScrollDirection * widget.autoScrollSpeed;
    final double newOffset = (_scrollPosition!.pixels + delta).clamp(
      _scrollPosition!.minScrollExtent,
      _scrollPosition!.maxScrollExtent,
    );
    if (newOffset != _scrollPosition!.pixels) {
      _scrollPosition!.jumpTo(newOffset);
      // 滚动后重新计算选区位置
      if (_lastDragGlobalPosition != null) {
        _updateSelectionFromDrag(_lastDragGlobalPosition!, _lastDragIsBase);
      }
    } else {
      _stopAutoScroll();
    }
  }

  void _handleDragAutoScroll(Offset globalPosition) {
    final viewport = _getViewportRect();
    if (viewport == null || _scrollPosition == null) return;

    final double edge = widget.autoScrollEdgeExtent;
    if (globalPosition.dy < viewport.top + edge) {
      _startAutoScroll(-1);
    } else if (globalPosition.dy > viewport.bottom - edge) {
      _startAutoScroll(1);
    } else {
      _stopAutoScroll();
    }
  }

  void _updateSelectionFromDrag(Offset globalPosition, bool isBase) {
    _layoutTextPainter();
    final Offset textGlobal = _getTextGlobalOffset();
    final Offset localOffset = Offset(
      globalPosition.dx - textGlobal.dx,
      globalPosition.dy - textGlobal.dy,
    );
    final TextPosition position = _getPositionForOffset(localOffset);

    if (isBase) {
      final int newBase = position.offset;
      final int extent = _selection.extentOffset;
      if (newBase != extent) {
        _updateSelection(
          TextSelection(baseOffset: min(newBase, extent), extentOffset: max(newBase, extent)),
        );
      }
    } else {
      final int base = _selection.baseOffset;
      final int newExtent = position.offset;
      if (base != newExtent) {
        _updateSelection(
          TextSelection(baseOffset: min(base, newExtent), extentOffset: max(base, newExtent)),
        );
      }
    }
  }

  // ─── 滚动监听 ───

  void _attachScrollListener() {
    _detachScrollListener();
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      _scrollPosition = scrollable.position;
      _scrollPosition!.isScrollingNotifier.addListener(_onScrollStatusChanged);
      _scrollPosition!.addListener(_onScroll);
    }
  }

  void _detachScrollListener() {
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition?.isScrollingNotifier.removeListener(_onScrollStatusChanged);
    _scrollPosition = null;
  }

  void _onScroll() {
    if (!mounted || !_isActive) return;
    if (!_isScrolling) {
      _isScrolling = true;
      _removeHandleEntries();
      _removeMenuEntry();
    }
  }

  void _onScrollStatusChanged() {
    if (!mounted || !_isActive) return;
    final isScrolling = _scrollPosition?.isScrollingNotifier.value ?? false;
    if (!isScrolling && _isScrolling) {
      _isScrolling = false;
      _layoutTextPainter();
      _showHandles();
      _showMenu();
      setState(() {});
    }
  }

  // ─── Barrier（覆盖层背景，点击关闭） ───

  void _showBarrier() {
    _barrierEntry?.remove();
    _barrierEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _hideMenu,
          child: const SizedBox.expand(),
        ),
      ),
    );
    Overlay.of(context).insert(_barrierEntry!);
  }

  // ─── 手柄 ───

  void _showHandles() {
    _removeHandleEntries();
    if (_selection.isCollapsed || _textPainter == null) return;

    _handleBaseEntry = OverlayEntry(builder: (_) => _buildHandleFollower(isBase: true));
    _handleExtentEntry = OverlayEntry(builder: (_) => _buildHandleFollower(isBase: false));

    final overlay = Overlay.of(context);
    overlay.insert(_handleBaseEntry!);
    overlay.insert(_handleExtentEntry!);
  }

  void _updateHandles() {
    _handleBaseEntry?.markNeedsBuild();
    _handleExtentEntry?.markNeedsBuild();
  }

  void _removeHandleEntries() {
    _handleBaseEntry?.remove();
    _handleBaseEntry = null;
    _handleExtentEntry?.remove();
    _handleExtentEntry = null;
  }

  Widget _buildHandleFollower({required bool isBase}) {
    if (_textPainter == null) return const SizedBox.shrink();

    final int offset = isBase ? _selection.baseOffset : _selection.extentOffset;
    final caretOffset = _textPainter!.getOffsetForCaret(TextPosition(offset: offset), Rect.zero);
    final double lineHeight = _textPainter!.preferredLineHeight;
    final double circleRadius = widget.handleSize / 3;
    final double totalHeight = lineHeight + circleRadius * 2;

    // 检查手柄是否在可见视口内
    final Rect? viewport = _getViewportRect();
    if (viewport != null) {
      final Offset textGlobal = _getTextGlobalOffset();
      final double handleGlobalY = textGlobal.dy + caretOffset.dy;
      if (handleGlobalY + lineHeight < viewport.top || handleGlobalY > viewport.bottom) {
        return const SizedBox.shrink();
      }
    }

    final double handleX = caretOffset.dx - widget.handleSize / 2;
    final double handleY = isBase ? caretOffset.dy - totalHeight + lineHeight : caretOffset.dy;

    final ThemeData theme = Theme.of(context);
    final Color handleColor = widget.handleColor ?? theme.colorScheme.primary;

    final double handleTouchPadding = 8.0;

    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: Offset(handleX - handleTouchPadding, handleY - handleTouchPadding),
      child: Align(
        alignment: Alignment.topLeft,
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) {
            if (isBase) {
              _isDraggingBase = true;
            } else {
              _isDraggingExtent = true;
            }
            _hideMenuDuringDrag();
          },
          onPanUpdate: (details) {
            if (isBase && !_isDraggingBase) return;
            if (!isBase && !_isDraggingExtent) return;

            final Offset globalPos = details.globalPosition;
            _lastDragGlobalPosition = globalPos;
            _lastDragIsBase = isBase;

            _handleDragAutoScroll(globalPos);
            _updateSelectionFromDrag(globalPos, isBase);
          },
          onPanEnd: (_) {
            _isDraggingBase = false;
            _isDraggingExtent = false;
            _lastDragGlobalPosition = null;
            _stopAutoScroll();
            _showMenu();
          },
          child: Padding(
            padding: EdgeInsets.all(handleTouchPadding),
            child: _SelectionHandle(
              color: handleColor,
              size: widget.handleSize,
              lineHeight: lineHeight,
              isBase: isBase,
            ),
          ),
        ),
      ),
    );
  }

  // ─── 菜单 ───

  void _showMenu() {
    _removeMenuEntry();
    if (_selection.isCollapsed || _textPainter == null) return;

    _menuAnimationController?.dispose();
    _menuAnimationController = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    );

    _menuSize = null;

    _menuEntry = OverlayEntry(builder: (_) => _buildMenu());
    Overlay.of(context).insert(_menuEntry!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureMenu();
    });
  }

  void _measureMenu() {
    final RenderBox? renderBox = _menuMeasureKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      _menuSize = renderBox.size;
      _menuEntry?.markNeedsBuild();
      _menuAnimationController?.forward();
    }
  }

  void _updateMenu() {
    _menuEntry?.markNeedsBuild();
  }

  void _removeMenuEntry() {
    _menuAnimationController?.dispose();
    _menuAnimationController = null;
    _menuEntry?.remove();
    _menuEntry = null;
  }

  void _hideMenuDuringDrag() {
    _removeMenuEntry();
  }

  Widget _buildMenu() {
    if (_textPainter == null || _selection.isCollapsed) {
      return const SizedBox.shrink();
    }

    if (_menuSize == null) {
      return Positioned(
        left: -9999,
        top: -9999,
        child: Opacity(
          opacity: 0,
          child: Material(
            key: _menuMeasureKey,
            type: MaterialType.transparency,
            child: widget.menuBuilder(context, _selectedText, _hideMenu, _selectAll),
          ),
        ),
      );
    }

    return _PositionedMenu(
      textPainter: _textPainter!,
      selection: _selection,
      getTextGlobalOffset: _getTextGlobalOffset,
      pointerGlobalPosition: _activationGlobalPosition,
      handleSize: widget.handleSize,
      menuSize: _menuSize,
      menuBuilder: widget.menuBuilder,
      selectedText: _selectedText,
      onHideMenu: _hideMenu,
      onSelectAll: _selectAll,
      animation: _menuAnimationController!,
      transitionsBuilder: widget.transitionsBuilder,
      menuBackgroundColor: widget.menuBackgroundColor,
      menuBorderRadius: widget.menuBorderRadius,
      menuPadding: widget.menuPadding,
      menuShadows: widget.menuShadows,
      arrowHeight: widget.arrowHeight,
      arrowWidth: widget.arrowWidth,
      spacing: widget.spacing,
      horizontalMargin: widget.horizontalMargin,
    );
  }

  void _hideMenu() {
    final controller = _menuAnimationController;
    if (controller != null && controller.value > 0) {
      controller.reverse().then((_) {
        _deactivateSelection();
      });
    } else {
      _deactivateSelection();
    }
  }

  void _selectAll() {
    final allSelection = TextSelection(baseOffset: 0, extentOffset: widget.data.length);
    _updateSelection(allSelection);
  }

  // ─── 清理 ───

  void _deactivateSelection() {
    _clearOverlays();
    _detachScrollListener();
    _isScrolling = false;
    setState(() {
      _selection = const TextSelection.collapsed(offset: -1);
      _isActive = false;
    });
    widget.onMenuClosed?.call();
  }

  void _clearOverlays() {
    _removeHandleEntries();
    _removeMenuEntry();
    _barrierEntry?.remove();
    _barrierEntry = null;
  }

  @override
  void dispose() {
    _clearOverlays();
    _stopAutoScroll();
    _detachScrollListener();
    _textPainter?.dispose();
    super.dispose();
  }

  // ─── build ───

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveStyle = widget.style ?? defaultTextStyle.style;
    if (widget.style == null || widget.style!.inherit) {
      effectiveStyle = defaultTextStyle.style.merge(effectiveStyle);
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: _isActive ? null : (details) => _activateSelection(details.localPosition),
        onDoubleTapDown: _isActive ? null : (details) => _activateSelection(details.localPosition),
        onTapDown: _isActive ? (details) => _onTapDownInSelection(details.localPosition) : null,
        child: CustomPaint(
          foregroundPainter: _isActive && _textPainter != null && !_selection.isCollapsed
              ? _SelectionHighlightPainter(
                  textPainter: _textPainter!,
                  selection: _selection,
                  selectionColor:
                      widget.selectionColor ??
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                )
              : null,
          child: RichText(
            text: TextSpan(text: widget.data, style: effectiveStyle),
            textAlign: widget.textAlign,
            textDirection: widget.textDirection ?? Directionality.of(context),
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
    );
  }
}

// ─── 选区高亮绘制 ───

class _SelectionHighlightPainter extends CustomPainter {
  final TextPainter textPainter;
  final TextSelection selection;
  final Color selectionColor;

  _SelectionHighlightPainter({
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
      canvas.drawRect(Rect.fromLTRB(box.left, box.top, box.right, box.bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SelectionHighlightPainter oldDelegate) {
    return oldDelegate.selection != selection || oldDelegate.selectionColor != selectionColor;
  }
}

// ─── 手柄形状 ───

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
      final double cx = w / 2;
      final double circleY = radius;
      final double lineH = h - radius * 2;
      canvas.drawCircle(Offset(cx, circleY), radius, paint);
      canvas.drawRect(Rect.fromLTWH(cx - lineWidth / 2, radius * 2, lineWidth, lineH), paint);
    } else {
      final double cx = w / 2;
      final double circleY = h - radius;
      final double lineH = h - radius * 2;
      canvas.drawRect(Rect.fromLTWH(cx - lineWidth / 2, 0, lineWidth, lineH), paint);
      canvas.drawCircle(Offset(cx, circleY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandlePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isBase != isBase;
  }
}

// ─── 菜单定位 ───

class _PositionedMenu extends StatelessWidget {
  const _PositionedMenu({
    required this.textPainter,
    required this.selection,
    required this.getTextGlobalOffset,
    this.pointerGlobalPosition,
    required this.handleSize,
    required this.menuSize,
    required this.menuBuilder,
    required this.selectedText,
    required this.onHideMenu,
    required this.onSelectAll,
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
  final Offset Function() getTextGlobalOffset;
  final Offset? pointerGlobalPosition;
  final double handleSize;
  final Size? menuSize;
  final Widget Function(
    BuildContext context,
    String selectedText,
    VoidCallback hideMenu,
    VoidCallback selectAll,
  )
  menuBuilder;
  final String selectedText;
  final VoidCallback onHideMenu;
  final VoidCallback onSelectAll;
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

    final Offset textGlobal = getTextGlobalOffset();

    final baseCaretOffset = textPainter.getOffsetForCaret(
      TextPosition(offset: selection.baseOffset),
      Rect.zero,
    );
    final extentCaretOffset = textPainter.getOffsetForCaret(
      TextPosition(offset: selection.extentOffset),
      Rect.zero,
    );

    final double selectionTopLocal = min(baseCaretOffset.dy, extentCaretOffset.dy);
    final double selectionBottomLocal =
        max(baseCaretOffset.dy, extentCaretOffset.dy) + textPainter.preferredLineHeight;
    final double selectionCenterXLocal = (baseCaretOffset.dx + extentCaretOffset.dx) / 2;

    final double selectionTopScreen = textGlobal.dy + selectionTopLocal;
    final double selectionBottomScreen = textGlobal.dy + selectionBottomLocal;
    final double selectionCenterXScreen = textGlobal.dx + selectionCenterXLocal;

    final double menuWidth = menuSize?.width ?? 200;
    final double menuHeight = menuSize?.height ?? 48;
    final double totalMenuHeight = menuHeight + arrowHeight;
    final double totalSpacing = handleSize + spacing;

    // 先尝试用完整选区做锚点
    final double selectionSpaceAbove = selectionTopScreen - topPadding;
    final double selectionSpaceBelow = screenHeight - bottomPadding - selectionBottomScreen;
    final bool fitsWithSelectionAnchor =
        selectionSpaceAbove >= totalMenuHeight + totalSpacing ||
        selectionSpaceBelow >= totalMenuHeight + totalSpacing;

    // 如果选区上下放不下菜单且有按压位置，回退到按压位置
    final double lineHeight = textPainter.preferredLineHeight;
    final bool usePointerAnchor = !fitsWithSelectionAnchor && pointerGlobalPosition != null;

    final double anchorTopScreen;
    final double anchorBottomScreen;
    final double anchorCenterXScreen;

    if (usePointerAnchor) {
      final double pointerLocalY = pointerGlobalPosition!.dy - textGlobal.dy;
      final double lineTop = (pointerLocalY / lineHeight).floorToDouble() * lineHeight;
      anchorTopScreen = textGlobal.dy + lineTop;
      anchorBottomScreen = anchorTopScreen + lineHeight;
      anchorCenterXScreen = pointerGlobalPosition!.dx;
    } else {
      anchorTopScreen = selectionTopScreen;
      anchorBottomScreen = selectionBottomScreen;
      anchorCenterXScreen = selectionCenterXScreen;
    }

    ArrowVerticalDirection arrowDirection;
    double menuYScreen;

    final double spaceAbove = anchorTopScreen - topPadding;
    final double spaceBelow = screenHeight - bottomPadding - anchorBottomScreen;

    if (spaceAbove >= totalMenuHeight + totalSpacing) {
      arrowDirection = ArrowVerticalDirection.down;
      menuYScreen = anchorTopScreen - totalSpacing - totalMenuHeight;
    } else if (spaceBelow >= totalMenuHeight + totalSpacing) {
      arrowDirection = ArrowVerticalDirection.up;
      menuYScreen = anchorBottomScreen + totalSpacing;
    } else {
      if (spaceAbove > spaceBelow) {
        arrowDirection = ArrowVerticalDirection.down;
        menuYScreen = anchorTopScreen - totalSpacing - totalMenuHeight;
      } else {
        arrowDirection = ArrowVerticalDirection.up;
        menuYScreen = anchorBottomScreen + totalSpacing;
      }
    }

    double menuXScreen = anchorCenterXScreen - menuWidth / 2;
    if (menuXScreen < horizontalMargin) menuXScreen = horizontalMargin;
    if (menuXScreen + menuWidth > screenWidth - horizontalMargin) {
      menuXScreen = screenWidth - menuWidth - horizontalMargin;
    }

    if (menuYScreen < topPadding) menuYScreen = topPadding;
    if (menuYScreen + totalMenuHeight > screenHeight - bottomPadding) {
      menuYScreen = screenHeight - bottomPadding - totalMenuHeight;
    }

    double arrowOffset = anchorCenterXScreen - menuXScreen;
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
        child: menuBuilder(context, selectedText, onHideMenu, onSelectAll),
      ),
    );

    final Offset menuCenter = Offset(
      menuXScreen + menuWidth / 2,
      menuYScreen + totalMenuHeight / 2,
    );
    final double alignX = (menuCenter.dx / screenSize.width) * 2 - 1;
    final double alignY = (menuCenter.dy / screenSize.height) * 2 - 1;
    final Alignment alignment = Alignment(alignX, alignY);

    final Animation<double> curve = animation.drive(CurveTween(curve: Curves.fastOutSlowIn));

    final Widget animatedMenu =
        transitionsBuilder?.call(context, animation, menuCenter, alignment, menuWidget) ??
        FadeTransition(
          opacity: curve,
          child: ScaleTransition(scale: curve, alignment: alignment, child: menuWidget),
        );

    return Positioned(left: menuXScreen, top: menuYScreen, child: animatedMenu);
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
