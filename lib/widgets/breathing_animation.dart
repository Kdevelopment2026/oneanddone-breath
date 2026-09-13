import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/breathing_technique.dart';
import 'breathing_ring.dart';

/// Drives the visual breathing guide. Tries a Lottie composition per phase
/// first — matching the product's chosen tech stack — and falls back to
/// [BreathingRing], the Flutter-drawn Night Tide ring, if that asset isn't
/// there yet.
///
/// **No real Lottie files ship in this scaffold.** `assets/animations/` is
/// empty; sourcing or commissioning the actual `inhale.json` / `hold.json` /
/// `exhale.json` compositions is explicit, tracked work — see CLAUDE.md,
/// golden rule 7. The ring below means the app is fully usable and looks
/// finished before that happens; it is not a placeholder to delete, it's
/// the permanent safety net for any asset that fails to load.
class BreathingAnimation extends StatefulWidget {
  const BreathingAnimation({
    super.key,
    required this.phase,
    required this.progress,
    this.paused = false,
  });

  final BreathPhaseType phase;
  final double progress;
  final bool paused;

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void didUpdateWidget(covariant BreathingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.duration != null) {
      _controller.value = widget.progress;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _assetPath {
    switch (widget.phase) {
      case BreathPhaseType.inhale:
        return 'assets/animations/inhale.json';
      case BreathPhaseType.holdAfterInhale:
      case BreathPhaseType.holdAfterExhale:
        return 'assets/animations/hold.json';
      case BreathPhaseType.exhale:
        return 'assets/animations/exhale.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      _assetPath,
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        _controller.value = widget.progress;
      },
      errorBuilder: (context, error, stackTrace) => BreathingRing(
        phase: widget.phase,
        progress: widget.progress,
        dimmed: widget.paused,
      ),
    );
  }
}
