import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/shared/widgets/glass_key.dart';

void main() {
  group('GlassKey Widget Tests', () {
    testWidgets('renders digit and letters correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassKey(digit: '2', letters: 'ABC', onTap: () {}),
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text('ABC'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassKey(
                digit: '5',
                letters: 'JKL',
                onTap: () => tapCount++,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      expect(tapCount, 1);
    });

    testWidgets('triggers onLongPress callback when held', (tester) async {
      int longPressCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassKey(
                digit: '0',
                letters: '+',
                onTap: () {},
                onLongPress: () => longPressCount++,
              ),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('0'));
      await tester.pumpAndSettle();

      expect(longPressCount, 1);
    });

    testWidgets('exposes accessibility semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassKey(digit: '7', letters: 'PQRS', onTap: () {}),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('7, PQRS'), findsOneWidget);

      handle.dispose();
    });
  });
}
