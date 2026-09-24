import 'package:chat_context_menu/src/model/menu_animation_style.dart';
import 'package:chat_context_menu/src/model/statement.dart';
import 'package:chat_context_menu/src/route/anchor_viewport_clip.dart';
import 'package:chat_context_menu/src/route/chat_context_route.dart';
import 'package:material_ui/material_ui.dart';

class ChatContextMenuWrapper extends StatefulWidget {
  const ChatContextMenuWrapper({
    super.key,
    required this.widgetBuilder,
    required this.menuBuilder,
    this.barrierColor = Colors.transparent,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.all(8),
    this.requestFocus = false,
    this.shadows,
    this.arrowHeight = 8.0,
    this.arrowWidth = 12.0,
    this.spacing = 6.0,
    this.animationStyle = ChatContextMenuAnimationStyle.scaleFade,
    this.transitionsBuilder,
    this.transitionDurations,
    this.onClose,
    this.horizontalMargin = 10.0,
    this.menuConstraints,
    this.layoutConstraints,
    this.axis = Axis.vertical,
    this.topPadding = kToolbarHeight,
    this.excludeAnchorFromBarrier = false,
    this.barrierAnchorPadding = EdgeInsets.zero,
    this.barrierAnchorBorderRadius,
    this.useRootNavigator = false,
  });

  ///在页面中显示的组件
  ///Components displayed on the page
  final ContextMenuWidgetBuilder widgetBuilder;

  ///显示的 context menu 组件
  ///Displayed context menu widget
  final ContextMenuContentBuilder menuBuilder;

  ///屏障颜色 （背景叠加层的颜色。）
  ///Color of the background overlay.
  final Color barrierColor;

  ///context menu容器的背景颜色。
  ///也作用于角标的颜色
  ///Background color of the menu container.
  ///Also affects the color of the marker
  final Color? backgroundColor;

  ///context menu容器的圆角
  ///Rounded corners of context menu container
  final BorderRadius borderRadius;

  ///context menu容器的内边距
  ///Padding corners of context menu container
  final EdgeInsets padding;

  ///是否在显示的的时候获取焦点
  ///默认为 false 如果为 true 那么在context menu显示的时候你页面中的其他具有焦点的组件将失去焦点
  ///Whether to get focus when displayed
  ///The default is false. If it is true, other focused components in your page will lose focus when the context menu is displayed.
  final bool requestFocus;

  ///context menu容器的阴影
  ///Shadows corners of context menu container
  final List<BoxShadow>? shadows;

  ///角标的高度
  ///The height of the marker
  final double arrowHeight;

  ///角标的宽度
  ///The width of the marker
  final double arrowWidth;

  ///context menu 和组件的间距
  ///Spacing between context menu and components
  final double spacing;

  ///内置菜单动画。默认 [ChatContextMenuAnimationStyle.scaleFade] 保持现有手感。
  ///[ChatContextMenuAnimationStyle.cupertinoSheet] 为 iOS 操作菜单回弹。
  ///非空的 [transitionsBuilder] 会覆盖两种内置样式。
  ///
  ///Built-in menu animation. Defaults to [ChatContextMenuAnimationStyle.scaleFade].
  ///[ChatContextMenuAnimationStyle.cupertinoSheet] matches the iOS action-sheet bounce.
  ///A non-null [transitionsBuilder] overrides both built-in styles.
  final ChatContextMenuAnimationStyle animationStyle;

  ///自定义出现的动画
  ///Customize the animation that appears
  final Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  transitionsBuilder;

  ///菜单动画时长。为 null 时使用 [animationStyle] 的默认时长
  ///（[ChatContextMenuAnimationStyle.scaleFade] 150ms，
  ///[ChatContextMenuAnimationStyle.cupertinoSheet] 335ms）。
  ///
  ///Duration of the menu animation. When null, uses [animationStyle]'s default
  ///(150ms for [ChatContextMenuAnimationStyle.scaleFade], 335ms for
  ///[ChatContextMenuAnimationStyle.cupertinoSheet]).
  final Duration? transitionDurations;

  ///关闭时触发的回调
  ///Callback triggered when closed
  final void Function(dynamic result)? onClose;

  ///距屏幕左右的最小留白
  ///Minimum horizontal margin from screen edges
  final double horizontalMargin;

  ///context menu容器的约束
  ///Constraints of context menu container
  final BoxConstraints? menuConstraints;

  ///可用屏幕区域的约束（用于布局判定）
  ///Constraints of available screen space (for layout decisions)
  final BoxConstraints? layoutConstraints;

  ///排列方向
  ///Arrangement direction
  final Axis axis;

  ///顶部安全区域的额外边距
  ///默认为 kToolbarHeight，当在 AppBar 中使用时可设为 0
  ///Extra padding for top safe area
  ///Defaults to kToolbarHeight, can be set to 0 when used inside AppBar
  final double topPadding;

  ///When true, the modal barrier omits anchor [widgetRect] (plus [barrierAnchorPadding]) so it
  /// stays visible and interactive like the floating menu surface. Default is false (full-screen barrier).
  final bool excludeAnchorFromBarrier;

  ///Inflates the barrier cutout around the measured anchor rectangle.
  final EdgeInsets barrierAnchorPadding;

  ///Optional corner radii for the cutout; match your bubble [BoxDecoration.borderRadius].
  final BorderRadius? barrierAnchorBorderRadius;

  ///是否把菜单路由推到根 Navigator。
  ///默认为 false(推到最近的 Navigator,保持既有行为)。当锚点位于嵌套 Navigator 内
  ///(如桌面端多栏/分栏布局,每一栏各自有 Navigator 且被 ClipRect、Transform 等包裹)时,
  ///设为 true 可让菜单与遮罩覆盖整个窗口、不被栏边界裁剪。
  ///无论推到哪个 Navigator,锚点坐标都会换算到目标 Navigator 的 Overlay 坐标系。
  ///
  ///Whether to push the menu route onto the root [Navigator].
  ///Defaults to false (nearest Navigator, preserving previous behavior). Set it to true when the
  ///anchor lives inside a nested Navigator (e.g. desktop multi-pane layouts where each pane hosts
  ///its own Navigator wrapped in ClipRect/Transform), so the menu and barrier cover the whole
  ///window instead of being clipped to a single pane.
  ///The anchor rect is always measured in the target Navigator's Overlay coordinate space.
  final bool useRootNavigator;

  @override
  State<ChatContextMenuWrapper> createState() => _ChatContextMenuWrapperState();
}

class _ChatContextMenuWrapperState extends State<ChatContextMenuWrapper> {
  ChatContextRoute? _route;
  
  Offset? _lastPointerDown;

  void _showMenu() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    if (_route != null) return;

    final NavigatorState navigator = Navigator.of(context, rootNavigator: widget.useRootNavigator);
    // Measure the anchor in the target Navigator's Overlay coordinate space instead of window
    // coordinates: with nested Navigators (multi-pane desktop layouts) the overlay origin is not
    // the window origin, and `localToGlobal(..., ancestor: overlayBox)` also accounts for any
    // Transform/padding between the anchor and the overlay.
    final RenderObject? overlayRenderObject = navigator.overlay?.context.findRenderObject();
    final RenderBox? overlayBox = overlayRenderObject is RenderBox ? overlayRenderObject : null;

    final Offset offset = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final Rect rawWidgetRect = offset & renderBox.size;
    final Rect widgetRect = clipAnchorRectForHole(
      context: context,
      anchorRect: rawWidgetRect,
      anchorRenderBox: renderBox,
      overlayBox: overlayBox,
    );
    // Pointer positions arrive in window coordinates; map them into the same overlay space.
    final Offset? pointerInOverlay = _lastPointerDown == null
        ? null
        : (overlayBox?.globalToLocal(_lastPointerDown!) ?? _lastPointerDown!);
    final Rect? pointerRect = pointerInOverlay != null
        ? Rect.fromCenter(center: pointerInOverlay, width: 1, height: 1)
        : null;

    _route = ChatContextRoute(
      widgetRect: widgetRect,
      menuItems: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: widget.menuBuilder(context, _hideMenu),
      ),
      barrierColor: widget.barrierColor,
      backgroundColor: widget.backgroundColor,
      borderRadius: widget.borderRadius,
      requestFocus: widget.requestFocus,
      padding: widget.padding,
      shadows: widget.shadows,
      arrowHeight: widget.arrowHeight,
      arrowWidth: widget.arrowWidth,
      spacing: widget.spacing,
      animationStyle: widget.animationStyle,
      transitionsBuilder: widget.transitionsBuilder,
      transitionDurations: widget.animationStyle.resolveDuration(widget.transitionDurations),
      horizontalMargin: widget.horizontalMargin,
      menuConstraints: widget.menuConstraints,
      layoutConstraints: widget.layoutConstraints,
      axis: widget.axis,
      pointerRect: pointerRect,
      topPadding: widget.topPadding,
      excludeAnchorFromBarrier: widget.excludeAnchorFromBarrier,
      barrierAnchorPadding: widget.barrierAnchorPadding,
      barrierAnchorBorderRadius: widget.barrierAnchorBorderRadius,
    );

    navigator.push(_route!).then((result) {
      _route = null;
      if (!mounted) return;
      widget.onClose?.call(result);
    });
  }

  void _hideMenu() {
    final ChatContextRoute? route = _route;
    if (route == null) return;
    // Use the navigator the route was pushed onto: with useRootNavigator it may differ from the
    // nearest Navigator of this context.
    final NavigatorState? navigator = route.navigator;
    if (navigator == null) return;
    if (route.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(route);
    }
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
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _lastPointerDown = event.position;
      },
      child: widget.widgetBuilder(context, _showMenu, _hideMenu),
    );
  }
}
