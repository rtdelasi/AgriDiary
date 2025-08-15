// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Self-contained counter increments', (WidgetTester tester) async {
    int counter = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: Text('$counter', key: const ValueKey('counter')),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => setState(() => counter++),
                child: const Icon(Icons.add),
              ),
            );
          },
        ),
      ),
    );

    // Initial counter value
    expect(find.text('0'), findsOneWidget);

    // Tap the '+' icon
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Counter should increment
    expect(find.text('1'), findsOneWidget);
  });
}
