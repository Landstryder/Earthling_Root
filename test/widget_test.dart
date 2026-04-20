// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:earthling_root/main.dart';

void main() {
  testWidgets('Earthling Root app launches correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EarthlingRootApp());

    // Verify that the app title is displayed.
    expect(find.text('Earthling Root'), findsWidgets);

    // Verify that tasks are displayed.
    expect(find.text('Check chickens'), findsOneWidget);
    expect(find.text('Water plants'), findsOneWidget);

    // Verify that the reset button is displayed.
    expect(find.text('Reset Day'), findsOneWidget);
  });
}
