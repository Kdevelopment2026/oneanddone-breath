import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_and_done_breath/models/breathing_technique.dart';
import 'package:one_and_done_breath/screens/session_screen.dart';
import 'package:one_and_done_breath/state/phase_feedback.dart';
import 'package:one_and_done_breath/theme/app_theme.dart';

void main() {
  Widget app(Widget home) => MaterialApp(theme: AppTheme.dark, home: home);

  testWidgets('phase is always shown as plain text, never animation-only', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        SessionScreen(
          technique: BreathingTechnique.box,
          minutes: 1,
          feedback: PhaseFeedback.silent(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Breathe in'), findsOneWidget);
    expect(find.textContaining('remaining'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);

    // Box: inhale is 4 s — after that, the label must read Hold.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Hold'), findsOneWidget);
  });

  testWidgets('pause swaps the control label and stops the clock', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        SessionScreen(
          technique: BreathingTechnique.coherent,
          minutes: 1,
          feedback: PhaseFeedback.silent(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));

    await tester.tap(find.text('Pause'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Resume'), findsOneWidget);
    expect(find.textContaining('Paused'), findsOneWidget);
  });

  testWidgets('completion shows a calm end state with Done', (tester) async {
    await tester.pumpWidget(
      app(
        SessionScreen(
          technique: BreathingTechnique.coherent,
          minutes: 1,
          feedback: PhaseFeedback.silent(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(seconds: 61));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Session complete'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);
  });
}
