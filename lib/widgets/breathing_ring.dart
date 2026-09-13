import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/breathing_technique.dart';
import '../theme/app_theme.dart';

/// Size of the breathing disc for a given phase and 0–1 progress through it,
/// as a fraction of [BreathingRing.maxScale]. Pure so it can be unit-tested
/// without a widget tree: it grows on inhale, holds, shrinks on exhale, and
/// is continuous across every phase boundary so the ring never jumps.
double breathScale(BreathPhaseType phase, double progress) {
  const min = BreathingRing.minScale;
  const max = BreathingRing.maxScale;
  final t = Curves.easeInOutSine.transform(progress.clamp(0, 1));
  switch (phase) {
    case BreathPhaseType.inhale:
      return min + (max - min) * t;
    case BreathPhaseType.holdAfterInhale:
      return max;
    case BreathPhaseType.exhale:
      return max - (max - min) * t;
    case BreathPhaseType.holdAfterExhale:
      return min;
  }
}

/// The Night Tide breathing guide, drawn entirely with a [CustomPainter]:
/// a luminous disc that swells and settles with the breath, a progress arc
/// for the current phase, faint echo rings that move in counter-phase, and
/// a glow whose strength follows the disc.
///
/// Draws no text — the phase label and countdown are laid over it by
/// [SessionScreen] as plain text so the phase is never animation-only
/// (CLAUDE.md, golden rule 6).
class BreathingRing extends StatelessWidget {
  const BreathingRing({
    super.key,
    required this.phase,
    required this.progress,
    this.dimmed = false,
  });

  static const double minScale = 0.72;
  static const double maxScale = 1.0;

  final BreathPhaseType phase;

  /// 0–1 progress through [phase].
  final double progress;

  /// True while paused: the glow settles and the arc stops advancing.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final tide = NightTide.of(context);
    return AnimatedOpacity(
      opacity: dimmed ? 0.55 : 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: CustomPaint(
        painter: _RingPainter(
          scale: breathScale(phase, progress),
          arc: progress,
          holdShimmer: _isHold ? math.sin(progress * math.pi) : 0,
          accent: tide.accent,
          mint: tide.mint,
          discInner: Color.lerp(tide.surfaceRaised, tide.background, 0.2)!,
          discOuter: tide.backgroundDeep,
          line: tide.line,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  bool get _isHold =>
      phase == BreathPhaseType.holdAfterInhale ||
      phase == BreathPhaseType.holdAfterExhale;
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.scale,
    required this.arc,
    required this.holdShimmer,
    required this.accent,
    required this.mint,
    required this.discInner,
    required this.discOuter,
    required this.line,
  });

  final double scale;
  final double arc;
  final double holdShimmer;
  final Color accent;
  final Color mint;
  final Color discInner;
  final Color discOuter;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    // Leave room outside the track for the outer echo ring.
    final trackRadius = math.min(size.width, size.height) / 2 * 0.78;
    final discRadius = trackRadius * 0.66 * scale;
    // 0 at the small end of the breath, 1 at the full end.
    final breath =
        ((scale - BreathingRing.minScale) /
                (BreathingRing.maxScale - BreathingRing.minScale))
            .clamp(0.0, 1.0);
    final glowStrength = 0.35 + 0.65 * breath + 0.12 * holdShimmer;

    _paintEchoes(canvas, centre, trackRadius, breath);
    _paintGlow(canvas, centre, discRadius, glowStrength);
    _paintDisc(canvas, centre, discRadius);
    _paintTrack(canvas, centre, trackRadius);
    _paintArc(canvas, centre, trackRadius);
  }

  void _paintEchoes(
    Canvas canvas,
    Offset centre,
    double trackRadius,
    double breath,
  ) {
    // Echo rings drift outwards as the disc contracts, inwards as it
    // fills — a slow counter-motion that keeps the frame alive without
    // competing with the disc.
    final drift = 1 - breath;
    final echoes = [
      (radius: trackRadius * (1.12 + 0.05 * drift), alpha: 0.14),
      (radius: trackRadius * (1.28 + 0.09 * drift), alpha: 0.07),
    ];
    for (final echo in echoes) {
      canvas.drawCircle(
        centre,
        echo.radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = accent.withValues(alpha: echo.alpha),
      );
    }
  }

  void _paintGlow(
    Canvas canvas,
    Offset centre,
    double discRadius,
    double strength,
  ) {
    final glowRadius = discRadius * 1.9;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.42 * strength),
          accent.withValues(alpha: 0.12 * strength),
          accent.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: centre, radius: glowRadius));
    canvas.drawCircle(centre, glowRadius, paint);
  }

  void _paintDisc(Canvas canvas, Offset centre, double discRadius) {
    final rect = Rect.fromCircle(center: centre, radius: discRadius);
    canvas.drawCircle(
      centre,
      discRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [discInner, discOuter],
          stops: const [0, 1],
        ).createShader(rect),
    );
    canvas.drawCircle(
      centre,
      discRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = line,
    );
  }

  void _paintTrack(Canvas canvas, Offset centre, double trackRadius) {
    canvas.drawCircle(
      centre,
      trackRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = line.withValues(alpha: line.a * 0.6),
    );
  }

  void _paintArc(Canvas canvas, Offset centre, double trackRadius) {
    if (arc <= 0) return;
    final rect = Rect.fromCircle(center: centre, radius: trackRadius);
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * arc.clamp(0.0, 1.0);

    // Soft halo under the arc, then the crisp arc on top.
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = accent.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: 2 * math.pi,
          transform: const GradientRotation(start),
          colors: [mint, accent],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.scale != scale ||
      old.arc != arc ||
      old.holdShimmer != holdShimmer ||
      old.accent != accent ||
      old.mint != mint ||
      old.discInner != discInner ||
      old.discOuter != discOuter ||
      old.line != line;
}
