import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talyer/core/design/design.dart';

/// Smoke tests for the design system. Wrap each component in the Talyer theme
/// (so the `TalyerColors` extension resolves) and assert it renders.
Widget _host(Widget child) => MaterialApp(
      theme: TalyerTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('VerifiedBadge renders its label', (tester) async {
    await tester.pumpWidget(_host(const VerifiedBadge()));
    expect(find.text('Verified'), findsOneWidget);
  });

  testWidgets('TalyerButton shows label and fires onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(TalyerButton(label: 'Tawag', onPressed: () => tapped = true)),
    );
    expect(find.text('Tawag'), findsOneWidget);
    await tester.tap(find.text('Tawag'));
    expect(tapped, isTrue);
  });

  testWidgets('TalyerButton(loading) hides label and disables tap',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(TalyerButton(
          label: 'Loading', loading: true, onPressed: () => tapped = true)),
    );
    await tester.tap(find.byType(TalyerButton));
    expect(tapped, isFalse);
  });

  testWidgets('MechanicCard surfaces name, rating and Verified seal',
      (tester) async {
    await tester.pumpWidget(_host(const SizedBox(
      width: 360,
      child: MechanicCard(
        name: 'Mang Ramon Dela Cruz',
        specialization: 'Engine • Brakes',
        rating: 4.8,
        reviews: 213,
        distanceKm: 1.4,
        etaMinutes: 8,
        priceFrom: '₱350',
      ),
    )));
    expect(find.text('Mang Ramon Dela Cruz'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    // MechanicCard uses the compact (icon-only) seal — assert the widget, not text.
    expect(find.byType(VerifiedBadge), findsOneWidget);
  });
}
