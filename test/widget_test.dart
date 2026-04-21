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
  testWidgets('Earthling Root v0.5 launches and shows balance radar', (WidgetTester tester) async {
    await tester.pumpWidget(const EarthlingRootApp());
    
    // Wait for initialization to complete
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // App title (now v0.5)
    expect(find.text('Earthling Root v0.5'), findsWidgets);

    // Check-in button
    expect(find.text('Check In Now'), findsOneWidget);

    // Your Balance section
    expect(find.text('Your Balance'), findsOneWidget);
  });
}
