import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:chat_context_menu/src/route/anchor_viewport_clip.dart';
import 'package:chat_context_menu/src/ui/chat_context_menu_vertical_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal reproduction of a desktop "sliding window" strip:
/// ClipRect > OverflowBox > Transform.translate > Row of panes, where each pane wraps its content
/// in Padding(8) + Material(borderRadius 12, clipBehavior antiAlias) and hosts its own Navigator.
///
/// The strip is 3 panes of 400x600 shifted left by 400, so panes 1 and 2 are visible in the
/// default 800x600 test surface. [child] is placed inside pane index 1 (visible at x 0..400).
Widget buildSlidingPaneApp({required Widget child}) {
  const double paneWidth = 400;
  const double paneHeight = 600;

  Widget paneShell(Widget inner) {
    return SizedBox(
      width: paneWidth,
      height: paneHeight,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: inner,
        ),
      ),
    );
  }

  return MaterialApp(
    home: Scaffold(
      body: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: paneWidth * 3,
          maxWidth: paneWidth * 3,
          minHeight: paneHeight,
          maxHeight: paneHeight,
          child: Transform.translate(
            offset: const Offset(-paneWidth, 0),
            child: Row(
              children: <Widget>[
                paneShell(const ColoredBox(color: Colors.grey)),
                paneShell(
                  Navigator(
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute<void>(
                        settings: settings,
                        builder: (_) => Center(child: child),
                      );
                    },
                  ),
                ),
                paneShell(const ColoredBox(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  const Key anchorKey = Key('anchor');

  Widget buildWrapper({required bool useRootNavigator, bool excludeAnchorFromBarrier = false}) {
    return ChatContextMenuWrapper(
      useRootNavigator: useRootNavigator,
      barrierColor: excludeAnchorFromBarrier ? Colors.black54 : Colors.transparent,
      excludeAnchorFromBarrier: excludeAnchorFromBarrier,
      menuBuilder: (context, hideMenu) {
        return const Column(mainAxisSize: MainAxisSize.min, children: <Widget>[Text('Copy')]);
      },
      widgetBuilder: (context, showMenu, hideMenu) {
        return GestureDetector(
          key: anchorKey,
          onLongPress: showMenu,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(width: 120, height: 40, child: Center(child: Text('anchor'))),
        );
      },
    );
  }

  testWidgets('useRootNavigator: menu aligns with anchor inside translated, clipped nested pane', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSlidingPaneApp(child: buildWrapper(useRootNavigator: true)));

    final Rect anchorRect = tester.getRect(find.byKey(anchorKey));
    // Anchor is in pane index 1, visible at x 0..400 after the -400 translation.
    expect(anchorRect.center.dx, closeTo(200, 1));

    await tester.longPress(find.byKey(anchorKey));
    await tester.pumpAndSettle();

    expect(find.text('Copy'), findsOneWidget);

    // Root overlay coordinates equal window coordinates, so the menu rect must line up with the
    // anchor's window rect. Without overlay-space conversion the error would be ~400px (pane
    // shift) + 8px (card padding).
    final Rect menuRect = tester.getRect(find.byType(ChatContextMenuVerticalWidget));
    expect(menuRect.center.dx, closeTo(anchorRect.center.dx, 1));
    // Default spacing is 6; placed below the anchor (plenty of room).
    expect(menuRect.top, closeTo(anchorRect.bottom + 6, 1));
  });

  testWidgets('default nearest Navigator: menu still aligns with anchor (pane overlay coords)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSlidingPaneApp(child: buildWrapper(useRootNavigator: false)));

    final Rect anchorRect = tester.getRect(find.byKey(anchorKey));

    await tester.longPress(find.byKey(anchorKey));
    await tester.pumpAndSettle();

    expect(find.text('Copy'), findsOneWidget);

    // The route lives in the pane's own overlay, but the anchor rect is measured in that
    // overlay's coordinate space, so the on-screen position must still match the anchor.
    final Rect menuRect = tester.getRect(find.byType(ChatContextMenuVerticalWidget));
    expect(menuRect.center.dx, closeTo(anchorRect.center.dx, 1));
    expect(menuRect.top, closeTo(anchorRect.bottom + 6, 1));
  });

  testWidgets('hole barrier: anchor stays tappable and shaded taps dismiss across panes', (
    WidgetTester tester,
  ) async {
    int anchorTaps = 0;

    await tester.pumpWidget(
      buildSlidingPaneApp(
        child: ChatContextMenuWrapper(
          useRootNavigator: true,
          barrierColor: Colors.black54,
          excludeAnchorFromBarrier: true,
          menuBuilder: (context, hideMenu) {
            return const Column(mainAxisSize: MainAxisSize.min, children: <Widget>[Text('Copy')]);
          },
          widgetBuilder: (context, showMenu, hideMenu) {
            return GestureDetector(
              key: anchorKey,
              onTap: () => anchorTaps++,
              onLongPress: showMenu,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(width: 120, height: 40, child: Center(child: Text('anchor'))),
            );
          },
        ),
      ),
    );

    await tester.longPress(find.byKey(anchorKey));
    await tester.pumpAndSettle();
    expect(find.text('Copy'), findsOneWidget);

    // The hole is punched at the anchor's root-overlay position, so the anchor stays tappable.
    await tester.tap(find.byKey(anchorKey));
    await tester.pump();
    expect(anchorTaps, 1);
    expect(find.text('Copy'), findsOneWidget);

    // A tap on the shaded area of the neighboring pane dismisses the menu.
    await tester.tapAt(const Offset(700, 60));
    await tester.pumpAndSettle();
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('clipAnchorRectForHole clamps the hole to the pane clip chain', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSlidingPaneApp(
        // A 500-wide anchor overflows its 384-wide pane card; the pane Material clips it.
        child: OverflowBox(
          minWidth: 500,
          maxWidth: 500,
          child: ChatContextMenuWrapper(
            useRootNavigator: true,
            barrierColor: Colors.black54,
            excludeAnchorFromBarrier: true,
            menuBuilder: (context, hideMenu) => const Text('Copy'),
            widgetBuilder: (context, showMenu, hideMenu) {
              return GestureDetector(
                key: anchorKey,
                onLongPress: showMenu,
                child: const SizedBox(width: 500, height: 40),
              );
            },
          ),
        ),
      ),
    );

    final Element wrapElement = tester.element(find.byType(ChatContextMenuWrapper));
    final RenderBox anchorBox = wrapElement.findRenderObject()! as RenderBox;
    final NavigatorState rootNavigator = Navigator.of(wrapElement, rootNavigator: true);
    final RenderBox overlayBox = rootNavigator.overlay!.context.findRenderObject()! as RenderBox;

    final Rect raw =
        anchorBox.localToGlobal(Offset.zero, ancestor: overlayBox) & anchorBox.size;
    final Rect clipped = clipAnchorRectForHole(
      context: wrapElement,
      anchorRect: raw,
      anchorRenderBox: anchorBox,
      overlayBox: overlayBox,
    );

    // Pane 1 card content spans x 8..392 in window coords (pane at 0..400, 8px padding).
    expect(raw.width, 500);
    expect(raw.left, lessThan(8));
    expect(clipped.left, greaterThanOrEqualTo(8 - 0.01));
    expect(clipped.right, lessThanOrEqualTo(392 + 0.01));
    expect(clipped.width, lessThan(raw.width));
  });

  testWidgets('ChatSelectableText useRootOverlay: menu aligns with text inside nested pane', (
    WidgetTester tester,
  ) async {
    const Key textKey = Key('selectable');

    await tester.pumpWidget(
      buildSlidingPaneApp(
        child: ChatSelectableText(
          'Select me please',
          key: textKey,
          useRootOverlay: true,
          style: const TextStyle(fontSize: 16),
          menuBackgroundColor: Colors.white,
          menuBuilder: (context, selectedText, hideMenu, selectAll) {
            return const Text('CopyItem');
          },
        ),
      ),
    );

    await tester.longPress(find.byKey(textKey));
    await tester.pumpAndSettle();

    expect(find.text('CopyItem'), findsOneWidget);

    final Rect textRect = tester.getRect(find.byKey(textKey));
    final Rect menuItemRect = tester.getRect(find.text('CopyItem'));

    // Menu is horizontally centered on the selection (whole single-line text) and vertically
    // adjacent to it. Without overlay-space conversion the error would be ~400px.
    expect(menuItemRect.center.dx, closeTo(textRect.center.dx, 30));
    expect(menuItemRect.bottom, lessThanOrEqualTo(textRect.top + 1));
    expect(menuItemRect.bottom, greaterThanOrEqualTo(textRect.top - 80));
  });
}
