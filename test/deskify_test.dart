import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:deskify/deskify.dart';

void main() {
  testWidgets('HoverDecorator changes opacity on hover', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HoverDecorator(onHoverOpacity: 0.5, child: Text('Hover Me')),
      ),
    );

    final opacityFinder = find.byType(AnimatedOpacity);
    expect(opacityFinder, findsOneWidget);

    // Initial opacity should be 1.0
    final AnimatedOpacity initialOpacity = tester.widget(opacityFinder);
    expect(initialOpacity.opacity, 1.0);
  });
}
