import 'package:flutter_test/flutter_test.dart';
import 'package:one_and_done_breath/models/breathing_technique.dart';
import 'package:one_and_done_breath/state/session_controller.dart';

void main() {
  group('SessionController', () {
    test('starts in ready state and does not advance until started', () {
      final controller = SessionController(technique: BreathingTechnique.box, totalMinutes: 1);
      controller.tick(2);
      expect(controller.state, SessionState.ready);
      expect(controller.elapsedSeconds, 0);
    });

    test('advances through phases in order', () {
      final controller = SessionController(technique: BreathingTechnique.box, totalMinutes: 1)
        ..start();

      expect(controller.currentPhase.type, BreathPhaseType.inhale);

      controller.tick(4); // box: inhale is 4s, should roll into hold-after-inhale
      expect(controller.currentPhase.type, BreathPhaseType.holdAfterInhale);

      controller.tick(4);
      expect(controller.currentPhase.type, BreathPhaseType.exhale);

      controller.tick(4);
      expect(controller.currentPhase.type, BreathPhaseType.holdAfterExhale);

      controller.tick(4);
      // Cycle wraps back to inhale.
      expect(controller.currentPhase.type, BreathPhaseType.inhale);
    });

    test('completes when total duration is reached', () {
      final controller = SessionController(technique: BreathingTechnique.coherent, totalMinutes: 1)
        ..start();

      controller.tick(59);
      expect(controller.state, SessionState.running);

      controller.tick(2);
      expect(controller.state, SessionState.complete);
      expect(controller.remainingSeconds, 0);
    });

    test('pause stops phase advancement until resumed', () {
      final controller = SessionController(technique: BreathingTechnique.box, totalMinutes: 1)
        ..start();

      controller.tick(2);
      controller.pause();
      final phaseBeforePause = controller.currentPhase.type;
      final elapsedBeforePause = controller.elapsedSeconds;

      controller.tick(10); // ignored while paused
      expect(controller.currentPhase.type, phaseBeforePause);
      expect(controller.elapsedSeconds, elapsedBeforePause);

      controller.start();
      controller.tick(2);
      expect(controller.elapsedSeconds, greaterThan(elapsedBeforePause));
    });

    test('reset returns to ready with a fresh technique/duration', () {
      final controller = SessionController(technique: BreathingTechnique.box, totalMinutes: 1)
        ..start();
      controller.tick(10);

      controller.reset(technique: BreathingTechnique.fourSevenEight, totalMinutes: 5);

      expect(controller.state, SessionState.ready);
      expect(controller.technique, BreathingTechnique.fourSevenEight);
      expect(controller.totalSeconds, 5 * 60);
      expect(controller.elapsedSeconds, 0);
    });
  });
}
