import 'package:chat_context_menu/src/model/menu_trigger_mode.dart';
import 'package:chat_context_menu/src/route/selectable_text_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

///可选择文本组件，支持文本选中并弹出自定义菜单
///A selectable text widget that supports text selection with a custom context menu
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
    this.selectionColor,
    this.handleColor,
    this.handleSize = 16.0,
    this.enableHapticFeedback = true,
    this.barrierColor,
    required this.menuBuilder,
    this.onSelectionChanged,
    this.onMenuClosed,
    this.mobileTriggerMode = MobileTriggerMode.longPress,
    this.desktopTriggerMode = DesktopTriggerMode.rightClick,
    this.transitionsBuilder,
    this.transitionDurations = const Duration(milliseconds: 150),
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
  final String data;

  ///文本样式
  ///Text style
  final TextStyle? style;

  ///文本对齐方式
  ///Text alignment
  final TextAlign textAlign;

  ///文本方向
  ///Text direction
  final TextDirection? textDirection;

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

  ///StrutStyle
  final StrutStyle? strutStyle;

  ///Locale
  final Locale? locale;

  ///是否自动换行
  ///Whether to soft wrap
  final bool softWrap;

  ///选中区域的颜色
  ///默认使用主题的 selectionColor
  ///Color of the selection highlight
  ///Defaults to theme's selectionColor
  final Color? selectionColor;

  ///选中手柄的颜色
  ///默认使用主题的 primaryColor
  ///Color of the selection handles
  ///Defaults to theme's primaryColor
  final Color? handleColor;

  ///手柄大小
  ///默认 16.0
  ///Handle widget size
  ///Defaults to 16.0
  final double handleSize;

  ///是否启用触感反馈
  ///默认 true，菜单显示时触发振动
  ///Whether to enable haptic feedback
  ///Defaults to true, vibrates when the menu appears
  final bool enableHapticFeedback;

  ///遮罩层颜色
  ///默认 Colors.transparent
  ///Barrier color
  ///Defaults to Colors.transparent
  final Color? barrierColor;

  ///构建菜单的回调
  ///参数: context, 选中的文本, 关闭菜单的回调
  ///Builder for the context menu
  ///Parameters: context, selected text, close callback
  final Widget Function(
    BuildContext context,
    String selectedText,
    VoidCallback hideMenu,
  )
  menuBuilder;

  ///选中文本变化时的回调
  ///Callback when selected text changes
  final ValueChanged<String>? onSelectionChanged;

  ///菜单关闭时的回调
  ///Callback when the menu is closed
  final VoidCallback? onMenuClosed;

  ///移动端菜单触发方式
  ///默认为长按
  ///Menu trigger mode for mobile platforms
  ///Defaults to long press
  final MobileTriggerMode mobileTriggerMode;

  ///桌面端菜单触发方式
  ///默认为右键
  ///Menu trigger mode for desktop platforms
  ///Defaults to right click
  final DesktopTriggerMode desktopTriggerMode;

  ///自定义菜单动画
  ///Custom menu animation
  final Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  transitionsBuilder;

  ///菜单动画时长
  ///Duration of menu animation
  final Duration transitionDurations;

  ///菜单容器的背景颜色
  ///也作用于角标的颜色
  ///Background color of the menu container
  ///Also affects the color of the arrow marker
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
  State<ChatSelectableText> createState() => _ChatSelectableTextState();
}

class _ChatSelectableTextState extends State<ChatSelectableText> {
  SelectableTextRoute? _route;

  ///是否为桌面平台
  bool get _isDesktop {
    if (UniversalPlatform.isWeb) {
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) {
        return false;
      }
      return true;
    }
    return UniversalPlatform.isDesktop;
  }

  void _showSelectionOverlay() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    if (_route != null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Rect widgetRect = offset & renderBox.size;
    final ThemeData theme = Theme.of(context);
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);

    TextStyle effectiveTextStyle = widget.style ?? defaultTextStyle.style;
    if (widget.style == null || widget.style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(effectiveTextStyle);
    }

    ///初始全选
    ///Initial: select all text
    final TextSelection initialSelection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.data.length,
    );

    _route = SelectableTextRoute(
      text: widget.data,
      textStyle: effectiveTextStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection ?? Directionality.of(context),
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textScaler: widget.textScaler,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor:
          widget.selectionColor ??
          theme.colorScheme.primary.withValues(alpha: 0.3),
      handleColor: widget.handleColor ?? theme.colorScheme.primary,
      widgetRect: widgetRect,
      menuBuilder: widget.menuBuilder,
      initialSelection: initialSelection,
      onSelectionChanged: widget.onSelectionChanged,
      strutStyle: widget.strutStyle,
      locale: widget.locale,
      softWrap: widget.softWrap,
      handleSize: widget.handleSize,
      enableHapticFeedback: widget.enableHapticFeedback,
      barrierColor: widget.barrierColor,
      transitionsBuilder: widget.transitionsBuilder,
      transitionDurations: widget.transitionDurations,
      menuBackgroundColor: widget.menuBackgroundColor,
      menuBorderRadius: widget.menuBorderRadius,
      menuPadding: widget.menuPadding,
      menuShadows: widget.menuShadows,
      arrowHeight: widget.arrowHeight,
      arrowWidth: widget.arrowWidth,
      spacing: widget.spacing,
      horizontalMargin: widget.horizontalMargin,
    );

    Navigator.of(context).push(_route!).then((_) {
      _route = null;
      if (!mounted) return;
      widget.onMenuClosed?.call();
    });
  }

  @override
  void dispose() {
    if (_route != null && _route!.isActive) {
      _route!.navigator?.removeRoute(_route!);
      _route = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      widget.data,
      style: widget.style,
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
    );

    if (_isDesktop) {
      if (widget.desktopTriggerMode == DesktopTriggerMode.rightClick) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onSecondaryTap: _showSelectionOverlay,
          child: text,
        );
      }
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showSelectionOverlay,
        child: text,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.mobileTriggerMode == MobileTriggerMode.tap
          ? _showSelectionOverlay
          : null,
      onDoubleTap: widget.mobileTriggerMode == MobileTriggerMode.doubleTap
          ? _showSelectionOverlay
          : null,
      onLongPress: widget.mobileTriggerMode == MobileTriggerMode.longPress
          ? _showSelectionOverlay
          : null,
      child: text,
    );
  }
}
