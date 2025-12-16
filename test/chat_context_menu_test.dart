import 'package:chat_context_menu/chat_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatContextMenuWrapper builds and shows menu', (
    WidgetTester tester,
  ) async {
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
                    ElevatedButton(
                      onPressed: hideMenu,
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
              widgetBuilder: (context, showMenu) {
                return GestureDetector(
                  onLongPress: showMenu,
                  child: const Text('Long press me'),
                );
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
}
