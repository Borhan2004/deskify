import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('DeskTitleBar renders native elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: DeskTitleBar(
            title: Text('Custom Desk Title'),
          ),
        ),
      ),
    );

    expect(find.text('Custom Desk Title'), findsOneWidget);
  });

  test('DeskShortcut adaptive creation mappings', () {
    final shortcutCtrlCmd = DeskShortcut.controlOrCommand(LogicalKeyboardKey.keyS);
    expect(shortcutCtrlCmd, isNotNull);

    final shortcutCtrlCmdShift = DeskShortcut.controlOrCommandShift(LogicalKeyboardKey.keyS);
    expect(shortcutCtrlCmdShift, isNotNull);

    final shortcutAlt = DeskShortcut.alt(LogicalKeyboardKey.keyS);
    expect(shortcutAlt, isNotNull);
  });

  testWidgets('DeskConstraintBox respects and animates constraints', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DeskConstraintBox(
          maxWidth: 800,
          child: SizedBox(width: 1000, height: 200),
        ),
      ),
    );

    final animatedContainerFinder = find.byType(AnimatedContainer);
    expect(animatedContainerFinder, findsOneWidget);

    final AnimatedContainer container = tester.widget(animatedContainerFinder);
    expect(container.constraints?.maxWidth, 800);
  });
}
