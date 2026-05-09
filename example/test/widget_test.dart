import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:deskify/deskify.dart';

void main() {
  testWidgets('Deskify Example App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DeskifyExampleApp());

    // Verify that the app title is present.
    expect(find.text('Deskify Tasks'), findsOneWidget);

    // Verify that we are on the Tasks page.
    expect(find.text('My Tasks'), findsWidgets);

    // Since the default test surface is 800x600, it should be a NavigationRail (Sidebar).
    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
