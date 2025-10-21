// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_app/authentication.dart';
//import 'package:smart_farm_app/main.dart';

void main() {
  testWidgets('Login page shows expected fields', (WidgetTester tester) async {
    // Build just the LoginPage inside a MaterialApp so decorators work.
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    // Verify expected UI elements on the login screen.
    expect(find.text('Email or Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Optionally, verify the "Don't have an account?" text/button
    expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
  });
}
