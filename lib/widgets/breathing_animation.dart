import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/breathing_technique.dart';

/// Drives the visual breathing guide. Tries a Lottie composition per phase
/// first — matching the product's chosen tech stack — and falls back to a
/// plain scaling circle built from stock Flutter widgets if that asset
/// isn't there yet.
///
/// **No real Lottie files ship in this scaffold.** `assets/animations/` is
/// empty; sourcing or commissioning the actual `inhale.json` / `hold.json` /
/// `exhale.json` compositions (e.g. from LottieFiles, or custom-made) is
/// explicit, tracked work — see CLAUDE.md, golden rule 7. The fallback
/// below means the app is fully usable and demoable before that happens;
/// it is not a placeholder to delete, it's the permanent safety net for any
/// asset that fails to load.
class BreathingAnimation extends StatefulWidget {
  const BreathingAnimation({
    super.key,
    required this.phase,
    required this.progress,
  });

  final BreathPhaseType phase;
  final double progress;

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation> with SingleTickerProviderStateMixin {
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
      errorBuilder: (context, error, stackTrace) => _FallbackCircle(
        phase: widget.phase,
        progress: widget.progress,
      ),
    );
  }
}

/// Pure-Flutter stand-in for the Lottie animation: a circle that grows on
/// inhale, holds, and shrinks on exhale. Colour is never the only signal —
/// the phase label is always shown alongside it in SessionScreen.
class _FallbackCircle extends StatelessWidget {
  const _FallbackCircle({required this.phase, required this.progress});

  final BreathPhaseType phase;
  final double progress;

  double get _scale {
    const minScale = 0.6;
    const maxScale = 1.0;
    switch (phase) {
      case BreathPhaseType.inhale:
        return minScale + (maxScale - minScale) * progress;
      case BreathPhaseType.holdAfterInhale:
        return maxScale;
      case BreathPhaseType.exhale:
        return maxScale - (maxScale - minScale) * progress;
      case BreathPhaseType.holdAfterExhale:
        return minScale;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primaryContainer,
            border: Border.all(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
