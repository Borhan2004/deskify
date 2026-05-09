import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Deskify Example App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DeskifyExampleApp());

    expect(find.text('Deskify Tasks'), findsOneWidget);

    expect(find.text('My Tasks'), findsWidgets);

    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
