// This is a basic Flutter widget test for Flicker calendar component.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flicker/src/widgets/swipable_view.dart';

void main() {
  testWidgets('SwipableView generic component test', (
    WidgetTester tester,
  ) async {
    // Test data
    final items = ['Item 1', 'Item 2', 'Item 3'];

    // Build the SwipableView widget
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: SwipableView<String>(
            items: items,
            initialIndex: 0,
            onIndexChange: (index) {
              // Index change callback
            },
            builder: (context, item) {
              return Center(child: Text(item));
            },
          ),
        ),
      ),
    );

    // Verify that the widget loads without crashing
    expect(find.byType(SwipableView<String>), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
  });
}
