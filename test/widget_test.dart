// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:couples_daily_q/main.dart';

void main() {
  testWidgets('DailyQScreen displays today\'s question and submits answer', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const CouplesDailyQApp());

    // Check that "Today's Question:" is displayed.
    expect(find.text("Today's Question:"), findsOneWidget);

    // Find the TextField and enter an answer.
    final answerField = find.byType(TextField);
    expect(answerField, findsOneWidget);
    await tester.enterText(answerField, 'My answer');

    // Tap the Submit button.
    await tester.tap(find.text('Submit'));
    await tester.pump();

    // Check that the answer is displayed.
    expect(find.text('You answered: My answer'), findsOneWidget);

    // Check that the answer appears in Past Q&As.
    expect(find.text('Past Q&As:'), findsOneWidget);
    expect(find.text('My answer'), findsWidgets);
  });
}
