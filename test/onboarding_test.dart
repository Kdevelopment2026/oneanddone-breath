import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_and_done_breath/screens/onboarding_screen.dart';
import 'package:one_and_done_breath/screens/splash_screen.dart';
import 'package:one_and_done_breath/state/app_settings.dart';
import 'package:one_and_done_breath/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget app(Widget home) => MaterialApp(theme: AppTheme.dark, home: home);

  // Entrances and page turns take several frames; pump a few short ones.
  Future<void> settle(WidgetTester tester, [int frames = 10]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('onboarding walks three pages and lands on Home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.shared.load();
    await tester.pumpWidget(app(const OnboardingScreen()));
    await settle(tester);

    expect(find.text('Pay once.\nBreathe forever.'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await settle(tester);
    await tester.tap(find.text('Continue'));
    await settle(tester);
    expect(find.text('Begin'), findsOneWidget);
    // The privacy page says what it doesn't do; nothing asks to sign in.
    expect(find.textContaining('No account'), findsOneWidget);
    expect(find.textContaining('Sign in'), findsNothing);

    await tester.tap(find.text('Begin'));
    await settle(tester, 15);
    expect(find.text('Ready when\nyou are.'), findsOneWidget);
    expect(AppSettings.shared.onboardingSeen, isTrue);
  });

  testWidgets('splash goes straight to Home once onboarding has been seen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    await AppSettings.shared.setOnboardingSeen(true);
    await tester.pumpWidget(app(const SplashScreen()));
    await settle(tester, 30);
    expect(find.text('Ready when\nyou are.'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });
}
