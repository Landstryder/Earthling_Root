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
  testWidgets('Earthling Root v0.2 launches and shows balance', (WidgetTester tester) async {
    await tester.pumpWidget(const EarthlingRootApp());

    // App title
    expect(find.text('Earthling Root'), findsWidgets);

    // Balance section
    expect(find.text('Life Balance'), findsOneWidget);

    // Tasks header and add button
    expect(find.text('Daily Tasks'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets);
  });
}
