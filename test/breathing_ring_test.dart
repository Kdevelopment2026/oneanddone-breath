import 'package:flutter_test/flutter_test.dart';
import 'package:one_and_done_breath/models/breathing_technique.dart';
import 'package:one_and_done_breath/widgets/breathing_ring.dart';

void main() {
  group('breathScale', () {
    test('inhale grows from the small size to the full size', () {
      expect(breathScale(BreathPhaseType.inhale, 0), BreathingRing.minScale);
      expect(breathScale(BreathPhaseType.inhale, 1), BreathingRing.maxScale);
      final mid = breathScale(BreathPhaseType.inhale, 0.5);
      expect(mid, greaterThan(BreathingRing.minScale));
      expect(mid, lessThan(BreathingRing.maxScale));
    });

    test('exhale shrinks from the full size back to the small size', () {
      expect(breathScale(BreathPhaseType.exhale, 0), BreathingRing.maxScale);
      expect(breathScale(BreathPhaseType.exhale, 1), BreathingRing.minScale);
    });

    test('holds keep the size they were handed and never move', () {
      for (final progress in [0.0, 0.3, 1.0]) {
        expect(
          breathScale(BreathPhaseType.holdAfterInhale, progress),
          BreathingRing.maxScale,
        );
        expect(
          breathScale(BreathPhaseType.holdAfterExhale, progress),
          BreathingRing.minScale,
        );
      }
    });

    test('is monotonic within a phase so the ring never jitters', () {
      double last = breathScale(BreathPhaseType.inhale, 0);
      for (var i = 1; i <= 20; i++) {
        final next = breathScale(BreathPhaseType.inhale, i / 20);
        expect(next, greaterThanOrEqualTo(last));
        last = next;
      }
    });

    test('phase boundaries are continuous — no jump between phases', () {
      const eps = 1e-9;
      expect(
        (breathScale(BreathPhaseType.inhale, 1) -
                breathScale(BreathPhaseType.holdAfterInhale, 0))
            .abs(),
        lessThan(eps),
      );
      expect(
        (breathScale(BreathPhaseType.holdAfterInhale, 1) -
                breathScale(BreathPhaseType.exhale, 0))
            .abs(),
        lessThan(eps),
      );
      expect(
        (breathScale(BreathPhaseType.exhale, 1) -
                breathScale(BreathPhaseType.holdAfterExhale, 0))
            .abs(),
        lessThan(eps),
      );
    });
  });
}
