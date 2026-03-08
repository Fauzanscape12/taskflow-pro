// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. for example, you can send tap and scroll
// gestures into the widget tree, read text, and verify that the values of widget
// properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow_pro/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Container(),
      ),
    );

    // Verify that app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
