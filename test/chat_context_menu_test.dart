import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:chat_context_menu/src/route/anchor_viewport_clip.dart';
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
              widgetBuilder: (context, showMenu) {
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
                menuBuilder: (context, hideMenu) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Action'),
                      ElevatedButton(onPressed: hideMenu, child: const Text('Close')),
                    ],
                  );
                },
                widgetBuilder: (context, showMenu) {
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

  testWidgets('Tapping shaded area closes menu when barrier has cutout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatContextMenuWrapper(
              barrierColor: Colors.black54,
              menuBuilder: (context, hideMenu) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [const Text('Copy scrim dismiss')],
                );
              },
              barrierAnchorBorderRadius: BorderRadius.circular(12),
              widgetBuilder: (context, showMenu) {
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
                      widgetBuilder: (BuildContext c, void Function() showMenu) {
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
    final Rect clipped = clipAnchorGlobalRectForHole(
      context: wrapElement,
      anchorGlobal: raw,
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
}
