import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:chat_context_menu/src/model/arrow_horizontal_direction.dart';
import 'package:chat_context_menu/src/model/arrow_vertical_direction.dart';
import 'package:chat_context_menu/src/route/anchor_viewport_clip.dart';
import 'package:chat_context_menu/src/route/chat_context_menu_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatContextMenuWrapper builds and shows menu', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatContextMenuWrapper(
              menuBuilder: (context, hideMenu) {
                return Column(
                  children: [
                    const Text('Copy'),
                    const Text('Delete'),
                    const Icon(Icons.copy),
                    const Icon(Icons.delete),
                    ElevatedButton(onPressed: hideMenu, child: const Text('Close')),
                  ],
                );
              },
              widgetBuilder: (context, showMenu, hideMenu) {
                return GestureDetector(onLongPress: showMenu, child: const Text('Long press me'));
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Long press me'), findsOneWidget);

    await tester.longPress(find.text('Long press me'));
    await tester.pumpAndSettle();

    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  testWidgets('Anchor stays tappable when barrier uses cutout (excludeAnchorFromBarrier)', (
    WidgetTester tester,
  ) async {
    const Key anchorKey = Key('anchor');

    var anchorTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ChatContextMenuWrapper(
                barrierColor: Colors.black54,
                excludeAnchorFromBarrier: true,
                menuBuilder: (context, hideMenu) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Action'),
                      ElevatedButton(onPressed: hideMenu, child: const Text('Close')),
                    ],
                  );
                },
                widgetBuilder: (context, showMenu, hideMenu) {
                  return GestureDetector(
                    key: anchorKey,
                    onTap: () => anchorTaps++,
                    onLongPress: showMenu,
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 160,
                      height: 56,
                      child: Center(child: Text('anchor')),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.byKey(anchorKey));
    await tester.pumpAndSettle();

    expect(find.text('Action'), findsOneWidget);

    await tester.tap(find.byKey(anchorKey));
    await tester.pump();

    expect(anchorTaps, 1);
  });

  testWidgets('hideMenu from widgetBuilder closes menu when open', (WidgetTester tester) async {
    VoidCallback? hideMenuFromAnchor;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatContextMenuWrapper(
              menuBuilder: (context, hideMenu) {
                return const Text('Menu open');
              },
              widgetBuilder: (context, showMenu, hideMenu) {
                hideMenuFromAnchor = hideMenu;
                return GestureDetector(onLongPress: showMenu, child: const Text('Open menu'));
              },
            ),
          ),
        ),
      ),
    );

    hideMenuFromAnchor!();
    await tester.pumpAndSettle();
    expect(find.text('Menu open'), findsNothing);

    await tester.longPress(find.text('Open menu'));
    await tester.pumpAndSettle();
    expect(find.text('Menu open'), findsOneWidget);

    hideMenuFromAnchor!();
    await tester.pumpAndSettle();
    expect(find.text('Menu open'), findsNothing);
  });

  testWidgets('Tapping shaded area closes menu when barrier has cutout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatContextMenuWrapper(
              barrierColor: Colors.black54,
              excludeAnchorFromBarrier: true,
              menuBuilder: (context, hideMenu) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [const Text('Copy scrim dismiss')],
                );
              },
              barrierAnchorBorderRadius: BorderRadius.circular(12),
              widgetBuilder: (context, showMenu, hideMenu) {
                return GestureDetector(onLongPress: showMenu, child: const Text('Hold me'));
              },
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Hold me'));
    await tester.pumpAndSettle();
    expect(find.text('Copy scrim dismiss'), findsOneWidget);

    await tester.tapAt(const Offset(40, 40));
    await tester.pumpAndSettle();

    expect(find.text('Copy scrim dismiss'), findsNothing);
  });

  testWidgets('Tall list bubble widgetRect is clipped to scroll viewport', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 180,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    ChatContextMenuWrapper(
                      barrierColor: Colors.black54,
                      menuBuilder: (BuildContext c, void Function() h) {
                        return const Text('Action');
                      },
                      widgetBuilder:
                          (BuildContext c, void Function() showMenu, void Function() hideMenu) {
                            return GestureDetector(
                              onLongPress: showMenu,
                              child: Container(
                                height: 500,
                                color: Colors.green,
                                alignment: Alignment.topCenter,
                                child: const Text('tall'),
                              ),
                            );
                          },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100, key: Key('footer')),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final Finder wrap = find.byType(ChatContextMenuWrapper);
    final Element wrapElement = tester.element(wrap);
    final RenderBox anchorBox = wrapElement.findRenderObject()! as RenderBox;
    final Rect raw = anchorBox.localToGlobal(Offset.zero) & anchorBox.size;
    final Rect clipped = clipAnchorRectForHole(
      context: wrapElement,
      anchorRect: raw,
      anchorRenderBox: anchorBox,
    );

    final RenderAbstractViewport? abstractViewport = RenderAbstractViewport.maybeOf(anchorBox);
    expect(abstractViewport, isNotNull);
    final RenderBox viewportBox = abstractViewport! as RenderBox;
    final Rect viewportGlobal = viewportBox.localToGlobal(Offset.zero) & viewportBox.size;

    expect(clipped.bottom, lessThanOrEqualTo(viewportGlobal.bottom + 0.01));
    expect(clipped.top, greaterThanOrEqualTo(viewportGlobal.top - 0.01));
    expect(raw.height, greaterThan(clipped.height));
  });

  group('ChatContextMenuAnimationStyle', () {
    test('scaleFade defaults to 150ms and cupertinoSheet to 335ms', () {
      expect(
        ChatContextMenuAnimationStyle.scaleFade.defaultDuration,
        const Duration(milliseconds: 150),
      );
      expect(
        ChatContextMenuAnimationStyle.cupertinoSheet.defaultDuration,
        const Duration(milliseconds: 335),
      );
      expect(
        ChatContextMenuAnimationStyle.cupertinoSheet.resolveDuration(null),
        const Duration(milliseconds: 335),
      );
      expect(
        ChatContextMenuAnimationStyle.cupertinoSheet.resolveDuration(
          const Duration(milliseconds: 400),
        ),
        const Duration(milliseconds: 400),
      );
    });

    test('sheetScaleAlignment pins the origin to the arrow edge', () {
      expect(
        sheetScaleAlignment(
          axis: Axis.vertical,
          vertical: ArrowVerticalDirection.up,
          arrowOffset: 40,
          menuSize: const Size(80, 40),
        ),
        const Alignment(0, -1),
      );
      expect(
        sheetScaleAlignment(axis: Axis.vertical, vertical: ArrowVerticalDirection.down),
        Alignment.bottomCenter,
      );
      expect(
        sheetScaleAlignment(
          axis: Axis.horizontal,
          horizontal: ArrowHorizontalDirection.left,
          arrowOffset: 10,
          menuSize: const Size(40, 40),
        ),
        const Alignment(-1, -0.5),
      );
    });

    testWidgets('scaleFade shows the menu without a sheet transition', (WidgetTester tester) async {
      await tester.pumpWidget(_animationHarness());

      await tester.longPress(find.text('Long press me'));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsOneWidget);
      expect(find.byType(ChatContextMenuSheetTransition), findsNothing);
      expect(
        ModalRoute.of(tester.element(find.text('Copy')))!.transitionDuration,
        const Duration(milliseconds: 150),
      );
    });

    testWidgets('cupertinoSheet wraps the menu and uses 335ms', (WidgetTester tester) async {
      await tester.pumpWidget(
        _animationHarness(style: ChatContextMenuAnimationStyle.cupertinoSheet),
      );

      await tester.longPress(find.text('Long press me'));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsOneWidget);
      expect(find.byType(ChatContextMenuSheetTransition), findsOneWidget);
      expect(
        ModalRoute.of(tester.element(find.text('Copy')))!.transitionDuration,
        const Duration(milliseconds: 335),
      );
    });

    testWidgets('cupertinoSheet opacity hits 0 before scale finishes on dismiss', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _animationHarness(style: ChatContextMenuAnimationStyle.cupertinoSheet),
      );

      await tester.longPress(find.text('Long press me'));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pump();
      // 60% through the 335ms reverse: controller ~0.4, Interval(0.5, 1.0) => opacity 0.
      await tester.pump(const Duration(milliseconds: 201));

      final Finder sheetFade = find.descendant(
        of: find.byType(ChatContextMenuSheetTransition),
        matching: find.byType(FadeTransition),
      );
      expect(sheetFade, findsOneWidget);
      final FadeTransition fade = tester.widget(sheetFade);
      expect(fade.opacity.value, 0.0);

      final Finder sheetScale = find.descendant(
        of: find.byType(ChatContextMenuSheetTransition),
        matching: find.byType(ScaleTransition),
      );
      expect(sheetScale, findsOneWidget);
      final ScaleTransition scale = tester.widget(sheetScale);
      expect(scale.scale.value, greaterThanOrEqualTo(0.0));
    });

    testWidgets('cupertinoSheet works for a horizontal menu', (WidgetTester tester) async {
      await tester.pumpWidget(
        _animationHarness(
          style: ChatContextMenuAnimationStyle.cupertinoSheet,
          axis: Axis.horizontal,
        ),
      );

      await tester.longPress(find.text('Long press me'));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsOneWidget);
      expect(find.byType(ChatContextMenuSheetTransition), findsOneWidget);
    });

    testWidgets('transitionsBuilder is not wrapped with the cupertino sheet transition', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _animationHarness(
          style: ChatContextMenuAnimationStyle.cupertinoSheet,
          transitionsBuilder: (context, animation, secondary, center, alignment, child) {
            return FadeTransition(
              key: const Key('custom-transition'),
              opacity: animation,
              child: child,
            );
          },
        ),
      );

      await tester.longPress(find.text('Long press me'));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsOneWidget);
      expect(find.byKey(const Key('custom-transition')), findsOneWidget);
      expect(find.byType(ChatContextMenuSheetTransition), findsNothing);
    });

    testWidgets('explicit transitionDurations overrides the style default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _animationHarness(
          style: ChatContextMenuAnimationStyle.cupertinoSheet,
          transitionDurations: const Duration(milliseconds: 400),
        ),
      );

      await tester.longPress(find.text('Long press me'));
      await tester.pumpAndSettle();

      expect(
        ModalRoute.of(tester.element(find.text('Copy')))!.transitionDuration,
        const Duration(milliseconds: 400),
      );
    });
  });
}

Widget _animationHarness({
  ChatContextMenuAnimationStyle style = ChatContextMenuAnimationStyle.scaleFade,
  Axis axis = Axis.vertical,
  Duration? transitionDurations,
  Widget? Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Offset centerOffset,
    Alignment alignment,
    Widget child,
  )?
  transitionsBuilder,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ChatContextMenuWrapper(
          animationStyle: style,
          axis: axis,
          transitionDurations: transitionDurations,
          transitionsBuilder: transitionsBuilder,
          menuBuilder: (context, hideMenu) {
            return const Text('Copy');
          },
          widgetBuilder: (context, showMenu, hideMenu) {
            return GestureDetector(onLongPress: showMenu, child: const Text('Long press me'));
          },
        ),
      ),
    ),
  );
}
