import 'package:flutter_test/flutter_test.dart';
import 'package:one_and_done_breath/models/breathing_technique.dart';

void main() {
  group('BreathingTechnique', () {
    test('box breathing cycle is 16 seconds', () {
      expect(BreathingTechnique.box.cycleSeconds, 16);
    });

    test('4-7-8 cycle is 19 seconds', () {
      expect(BreathingTechnique.fourSevenEight.cycleSeconds, 19);
    });

    test('coherent breathing has no hold phases', () {
      final hasHold = BreathingTechnique.coherent.phases.any(
        (phase) =>
            phase.type == BreathPhaseType.holdAfterInhale ||
            phase.type == BreathPhaseType.holdAfterExhale,
      );
      expect(hasHold, isFalse);
    });

    test('every phase label is plain language, never blank', () {
      for (final technique in BreathingTechnique.all) {
        for (final phase in technique.phases) {
          expect(phase.type.label, isNotEmpty);
        }
      }
    });
  });
}
