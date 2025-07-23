import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:headsup_ats/screens/onboarding_screen.dart';

void main() {
  testWidgets('App loads onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify that the onboarding screen is present (by checking for a known text or widget).
    expect(find.text('HEADSUP HR SOLUTIONS'), findsOneWidget);
  });
}
