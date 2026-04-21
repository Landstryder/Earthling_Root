// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:earthling_root/main.dart';

void main() {
  testWidgets('Earthling Root v0.4 launches and shows balance radar', (WidgetTester tester) async {
    await tester.pumpWidget(const EarthlingRootApp());

    // App title
    expect(find.text('Earthling Root v0.4'), findsOneWidget);

    // Check-in button
    expect(find.text('Check In Now'), findsOneWidget);

    // Radar chart section
    expect(find.text('Life Balance Radar'), findsOneWidget);

    // Domain values section
    expect(find.text('Domain Values'), findsOneWidget);
  });
}
