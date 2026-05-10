import 'package:chat_context_menu/src/layout/chat_context_menu_horizontal_layout.dart';
import 'package:chat_context_menu/src/route/hole_modal_barrier.dart';
import 'package:chat_context_menu/src/route/modal_hole_dismiss_scrim.dart';
import 'package:chat_context_menu/src/ui/chat_context_menu_horizontal_widget.dart';
import 'package:chat_context_menu/src/layout/chat_context_menu_vertical_layout.dart';
import 'package:chat_context_menu/src/ui/chat_context_menu_vertical_widget.dart';
import 'package:flutter/material.dart';

class ChatContextRoute extends PageRoute {
  final Rect widgetRect;
  final Widget menuItems;
  final Color? _barrierColor;
  final bool _barrierDismissible;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final List<BoxShadow>? shadows;
  final double arrowHeight;
  final double arrowWidth;
  final double spacing;
  final double horizontalMargin;
  final Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  transitionsBuilder;
  final Duration transitionDurations;
  final BoxConstraints? menuConstraints;
  final BoxConstraints? layoutConstraints;
  final Axis axis;
  final Rect? pointerRect;
  final double topPadding;

  /// When true, the barrier does not obscure or intercept hits on the anchor
  /// [widgetRect] (plus [barrierAnchorPadding]). Default is false (standard full-screen barrier).
  final bool excludeAnchorFromBarrier;

  /// Inflation applied around [widgetRect] for the barrier cutout.
  final EdgeInsets barrierAnchorPadding;

  /// When non-null with non-zero radii, the cutout uses this border radius aligned to the inflated anchor rect (match bubble decor).
  final BorderRadius? barrierAnchorBorderRadius;

  ChatContextRoute({
    super.settings,
    super.requestFocus,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
    super.fullscreenDialog,
    super.allowSnapshotting,
    bool barrierDismissible = true,
    required this.widgetRect,
    required this.menuItems,
    Color? barrierColor,
    this.backgroundColor,
    required this.borderRadius,
    required this.padding,
    this.shadows,
    required this.arrowHeight,
    required this.arrowWidth,
    required this.spacing,
    required this.horizontalMargin,
    this.transitionsBuilder,
    required this.transitionDurations,
    this.menuConstraints,
    this.layoutConstraints,
    required this.axis,
    this.pointerRect,
    required this.topPadding,
    this.excludeAnchorFromBarrier = false,
    this.barrierAnchorPadding = EdgeInsets.zero,
    this.barrierAnchorBorderRadius,
  }) : _barrierColor = barrierColor,
       _barrierDismissible = barrierDismissible;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color? get barrierColor => _barrierColor;

  @override
  String? get barrierLabel => 'chat_context_menu';

  /// Transparent overlay: previous route stays in the tree so the anchor widget
  /// remains hittable when the modal barrier excludes it (`excludeAnchorFromBarrier`).
  @override
  bool get opaque => false;

  @override
  Widget buildModalBarrier() {
    if (!_useHoleBarrier) {
      return super.buildModalBarrier();
    }

    final Color barrierOpaque = _barrierColor!;
    assert(barrierOpaque.a != 0);

    final Rect holeLogical = inflateRectByEdgeInsets(widgetRect, barrierAnchorPadding);
    final Animation<Color?> color = animation!.drive(
      ColorTween(
        begin: barrierOpaque.withValues(alpha: 0.0),
        end: barrierOpaque,
      ).chain(CurveTween(curve: barrierCurve)),
    );

    return HoleModalBarrier(
      animation: color,
      holeRectLogical: holeLogical,
      anchorBorderRadius: barrierAnchorBorderRadius,
    );
  }

  /// Do not gate on [offstage]: [buildPage] must always include the scrim when using a hole
  /// barrier, since [Offstage] already suppresses hit-testing until the route is onstage.
  bool get _useHoleBarrier => excludeAnchorFromBarrier && (_barrierColor?.a ?? 0) != 0;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Rect holeLogical = inflateRectByEdgeInsets(widgetRect, barrierAnchorPadding);

    Widget menuLayer;
    if (axis == Axis.horizontal) {
      menuLayer = ChatContextMenuHorizontalLayout(
        widgetRect: widgetRect,
        padding: padding,
        arrowHeight: arrowHeight,
        spacing: spacing,
        arrowWidth: arrowWidth,
        borderRadius: borderRadius,
        horizontalMargin: horizontalMargin,
        topPadding: topPadding,
        childBuilder: (context, arrowOffset, arrowDirection) {
          return ChatContextMenuHorizontalWidget(
            items: menuItems,
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            padding: padding,
            arrowOffset: arrowOffset,
            arrowDirection: arrowDirection,
            shadows: shadows,
            arrowHeight: arrowHeight,
            arrowWidth: arrowWidth,
            menuConstraints: menuConstraints,
          );
        },
      );
    } else {
      menuLayer = ChatContextMenuVerticalLayout(
        widgetRect: widgetRect,
        pointerRect: pointerRect,
        padding: padding,
        arrowHeight: arrowHeight,
        spacing: spacing,
        arrowWidth: arrowWidth,
        borderRadius: borderRadius,
        horizontalMargin: horizontalMargin,
        layoutConstraints: layoutConstraints,
        topPadding: topPadding,
        childBuilder: (context, arrowOffset, isArrowUp) {
          return ChatContextMenuVerticalWidget(
            items: menuItems,
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            padding: padding,
            arrowOffset: arrowOffset,
            isArrowUp: isArrowUp,
            shadows: shadows,
            arrowHeight: arrowHeight,
            arrowWidth: arrowWidth,
            constraints: menuConstraints,
          );
        },
      );
    }

    if (!_useHoleBarrier) {
      return menuLayer;
    }

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: HoleModalDismissScrim(
            holeRectGlobal: holeLogical,
            anchorBorderRadius: barrierAnchorBorderRadius,
            dismissible: barrierDismissible,
          ),
        ),
        menuLayer,
      ],
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Size screenSize = MediaQuery.of(context).size;
    final Offset center = pointerRect?.center ?? widgetRect.center;
    // Calculate alignment (-1.0 to 1.0)
    final double alignX = (center.dx / screenSize.width) * 2 - 1;
    final double alignY = (center.dy / screenSize.height) * 2 - 1;
    final Alignment alignment = Alignment(alignX, alignY);
    final Animation<double> curve = animation.drive(CurveTween(curve: Curves.fastOutSlowIn));
    return transitionsBuilder?.call(
          context,
          animation,
          secondaryAnimation,
          center,
          alignment,
          child,
        ) ??
        FadeTransition(
          opacity: curve,
          child: ScaleTransition(scale: curve, alignment: alignment, child: child),
        );
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => transitionDurations;
}
