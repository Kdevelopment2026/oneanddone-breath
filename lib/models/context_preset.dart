import 'package:flutter/foundation.dart';

import 'breathing_technique.dart';

/// A lightweight, honest answer to the category's "doesn't adapt to
/// context" complaint — a short list of sensible defaults, not a fake
/// personalisation engine. The user can always override the technique and
/// duration on Home regardless of which preset they start from.
@immutable
class ContextPreset {
  const ContextPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.technique,
    required this.minutes,
  });

  final String id;
  final String title;
  final String subtitle;
  final BreathingTechnique technique;
  final int minutes;

  static const beforeAMeeting = ContextPreset(
    id: 'before_meeting',
    title: 'Before a meeting',
    subtitle: 'A quick, steady reset',
    technique: BreathingTechnique.box,
    minutes: 2,
  );

  static const windDown = ContextPreset(
    id: 'wind_down',
    title: 'Wind down',
    subtitle: 'Slower, longer exhale',
    technique: BreathingTechnique.fourSevenEight,
    minutes: 5,
  );

  static const resetFocus = ContextPreset(
    id: 'reset_focus',
    title: 'Reset focus',
    subtitle: 'Even, unhurried breathing',
    technique: BreathingTechnique.coherent,
    minutes: 3,
  );

  static const all = [beforeAMeeting, windDown, resetFocus];
}
