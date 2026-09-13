import 'package:flutter/foundation.dart';

/// The four phases any breathing technique here is built from. Not every
/// technique uses every phase — [BreathingTechnique.phases] simply omits the
/// ones it doesn't need.
enum BreathPhaseType { inhale, holdAfterInhale, exhale, holdAfterExhale }

extension BreathPhaseTypeLabel on BreathPhaseType {
  /// Plain-language label shown during a session — no jargon, matches the
  /// category's "no meditation vocabulary required" positioning.
  String get label {
    switch (this) {
      case BreathPhaseType.inhale:
        return 'Breathe in';
      case BreathPhaseType.holdAfterInhale:
      case BreathPhaseType.holdAfterExhale:
        return 'Hold';
      case BreathPhaseType.exhale:
        return 'Breathe out';
    }
  }
}

/// One step in a technique's repeating cycle.
@immutable
class BreathPhase {
  const BreathPhase(this.type, this.seconds);

  final BreathPhaseType type;
  final double seconds;
}

/// A named, evidence-based breathing pattern. Deliberately a small, fixed
/// set for v1 — this app's whole pitch is "a few good techniques, owned
/// outright," not an ever-growing content library (see CLAUDE.md, golden
/// rule 1).
@immutable
class BreathingTechnique {
  const BreathingTechnique({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.phases,
  });

  final String id;
  final String name;

  /// One or two words for tight spaces (segmented picker, preset meta).
  final String shortName;
  final String description;
  final List<BreathPhase> phases;

  /// Total seconds for one full cycle through [phases].
  double get cycleSeconds =>
      phases.fold(0, (sum, phase) => sum + phase.seconds);

  static const box = BreathingTechnique(
    id: 'box',
    name: 'Box breathing',
    shortName: 'Box',
    description: 'Four equal steps — in, hold, out, hold. A steady, general-purpose reset.',
    phases: [
      BreathPhase(BreathPhaseType.inhale, 4),
      BreathPhase(BreathPhaseType.holdAfterInhale, 4),
      BreathPhase(BreathPhaseType.exhale, 4),
      BreathPhase(BreathPhaseType.holdAfterExhale, 4),
    ],
  );

  static const fourSevenEight = BreathingTechnique(
    id: 'four_seven_eight',
    name: '4-7-8 breathing',
    shortName: '4-7-8',
    description: 'A longer hold and a slow exhale — popularised for winding down before sleep.',
    phases: [
      BreathPhase(BreathPhaseType.inhale, 4),
      BreathPhase(BreathPhaseType.holdAfterInhale, 7),
      BreathPhase(BreathPhaseType.exhale, 8),
    ],
  );

  static const coherent = BreathingTechnique(
    id: 'coherent',
    name: 'Coherent breathing',
    shortName: 'Coherent',
    description: 'Even, unhurried in-and-out with no holds — the simplest place to start.',
    phases: [
      BreathPhase(BreathPhaseType.inhale, 5.5),
      BreathPhase(BreathPhaseType.exhale, 5.5),
    ],
  );

  static const all = [box, fourSevenEight, coherent];
}
