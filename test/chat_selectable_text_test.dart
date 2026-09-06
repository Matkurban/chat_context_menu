import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:chat_context_menu/src/route/chat_context_menu_transition.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatSelectableText menu stays within screen horizontal bounds', (
    WidgetTester tester,
  ) async {
    const double horizontalMargin = 10.0;
    const String text = 'And the custom menu looks great too!';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ChatSelectableText(
                  text,
                  horizontalMargin: horizontalMargin,
                  menuBuilder: (context, selectedText, hideMenu, selectAll) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _menuAction('Copy', hideMenu),
                        _menuAction('Select All', selectAll),
                        _menuAction('Search', hideMenu),
                        _menuAction('Share', hideMenu),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.byType(ChatSelectableText));
    await tester.pumpAndSettle();

    expect(find.text('Share'), findsOneWidget);

    final Finder menuShellFinder = find.ancestor(
      of: find.text('Copy'),
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is Container && widget.decoration is ShapeDecoration,
      ),
    );
    expect(menuShellFinder, findsOneWidget);

    final RenderBox menuBox = tester.renderObject<RenderBox>(menuShellFinder);
    final Offset topLeft = menuBox.localToGlobal(Offset.zero);
    final Offset bottomRight = menuBox.localToGlobal(
      Offset(menuBox.size.width, menuBox.size.height),
    );
    final Rect menuRect = Rect.fromPoints(topLeft, bottomRight);

    final double screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;

    expect(menuRect.left, greaterThanOrEqualTo(horizontalMargin - 1));
    expect(menuRect.right, lessThanOrEqualTo(screenWidth - horizontalMargin + 1));
  });

  testWidgets('cupertinoSheet wraps the selection menu', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatSelectableText(
              'Select this text to open the menu.',
              animationStyle: ChatContextMenuAnimationStyle.cupertinoSheet,
              menuBuilder: (context, selectedText, hideMenu, selectAll) {
                return TextButton(onPressed: hideMenu, child: const Text('Copy'));
              },
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.byType(ChatSelectableText));
    await tester.pumpAndSettle();

    expect(find.text('Copy'), findsOneWidget);
    expect(find.byType(ChatContextMenuSheetTransition), findsOneWidget);
  });

  testWidgets('right click activates selection and shows the menu', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatSelectableText(
              'Right click to open the menu.',
              menuBuilder: (context, selectedText, hideMenu, selectAll) {
                return TextButton(onPressed: hideMenu, child: const Text('Copy'));
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ChatSelectableText), buttons: kSecondaryButton);
    await tester.pumpAndSettle();

    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('axis horizontal places the menu beside the selection', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerLeft,
            child: ChatSelectableText(
              'Short',
              axis: Axis.horizontal,
              menuBuilder: (context, selectedText, hideMenu, selectAll) {
                return TextButton(onPressed: hideMenu, child: const Text('Copy'));
              },
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.byType(ChatSelectableText));
    await tester.pumpAndSettle();

    expect(find.text('Copy'), findsOneWidget);

    final Rect textRect = tester.getRect(find.byType(ChatSelectableText));
    final Rect menuRect = tester.getRect(find.text('Copy'));

    // 菜单应位于选区右侧
    expect(menuRect.left, greaterThan(textRect.right));
    // 垂直方向大致与选区中心对齐
    expect(menuRect.center.dy, moreOrLessEquals(textRect.center.dy, epsilon: 30));
  });

  testWidgets('mouse drag selects text and shows the menu on release', (WidgetTester tester) async {
    String lastSelection = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatSelectableText(
              'Drag with the mouse to select this text.',
              onSelectionChanged: (text) => lastSelection = text,
              menuBuilder: (context, selectedText, hideMenu, selectAll) {
                return TextButton(onPressed: hideMenu, child: const Text('Copy'));
              },
            ),
          ),
        ),
      ),
    );

    final Offset topLeft = tester.getTopLeft(find.byType(ChatSelectableText));
    final TestGesture gesture = await tester.startGesture(
      topLeft + const Offset(2, 8),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    // 第一次移动触发 onStart，后续移动触发 onUpdate 扩展选区
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(50, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Copy'), findsOneWidget);
    expect(lastSelection, isNotEmpty);
    // 选区从按下位置（文本开头）开始
    expect(lastSelection, startsWith('Drag with'));
  });

  testWidgets('double click selects the word under the pointer', (WidgetTester tester) async {
    String lastSelection = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatSelectableText(
              'Hello world',
              onSelectionChanged: (text) => lastSelection = text,
              menuBuilder: (context, selectedText, hideMenu, selectAll) {
                return TextButton(onPressed: hideMenu, child: const Text('Copy'));
              },
            ),
          ),
        ),
      ),
    );

    final Offset firstChar =
        tester.getTopLeft(find.byType(ChatSelectableText)) + const Offset(2, 8);
    await tester.tapAt(firstChar);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(firstChar);
    await tester.pumpAndSettle();

    expect(lastSelection, 'Hello');
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('triple click selects the whole paragraph', (WidgetTester tester) async {
    String lastSelection = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatSelectableText(
              'First paragraph line\nSecond paragraph line',
              onSelectionChanged: (text) => lastSelection = text,
              menuBuilder: (context, selectedText, hideMenu, selectAll) {
                return TextButton(onPressed: hideMenu, child: const Text('Copy'));
              },
            ),
          ),
        ),
      ),
    );

    // 点击 'paragraph' 一词的中间，避开双击后出现在选区边缘的手柄
    final Offset tapPoint =
        tester.getTopLeft(find.byType(ChatSelectableText)) + const Offset(147, 8);
    await tester.tapAt(tapPoint);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(tapPoint);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(tapPoint);
    await tester.pumpAndSettle();

    expect(lastSelection, 'First paragraph line');
    expect(find.text('Copy'), findsOneWidget);
  });
}

Widget _menuAction(String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const Icon(Icons.circle_outlined, size: 20), Text(label)],
      ),
    ),
  );
}
