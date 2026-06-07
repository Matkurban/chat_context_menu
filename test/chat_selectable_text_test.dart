import 'package:chat_context_menu/chat_context_menu.dart';
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
