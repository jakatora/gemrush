import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/menu/widgets/animated_counter.dart';

void main() {
  testWidgets('AnimatedCounter pokazuje poczatkowa wartosc', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimatedCounter(value: 42)),
      ),
    );
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('AnimatedCounter zmienia wartosc na nowa po update', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimatedCounter(value: 0)),
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimatedCounter(value: 100)),
      ),
    );
    // Po pełnym czasie animacji pokaże 100.
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('AnimatedCounter pokazuje wartosci pomiedzy podczas animacji',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimatedCounter(value: 0)),
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCounter(value: 100, duration: Duration(seconds: 1)),
        ),
      ),
    );
    // Po 500ms (połowa animacji) — wartość powinna być w okolicach 50.
    await tester.pump(const Duration(milliseconds: 500));
    final text = (tester.widget<Text>(find.byType(Text)).data ?? '0');
    final value = int.parse(text);
    expect(value, greaterThan(0));
    expect(value, lessThan(100));
  });
}
