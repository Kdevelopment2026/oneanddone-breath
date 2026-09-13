import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/app_theme.dart';

/// The Night Tide backdrop: a deep vertical gradient with two or three soft
/// aurora blooms that drift very slowly. Drawn with radial gradients rather
/// than blur filters so it's cheap enough to sit under every screen.
///
/// With "reduce motion" on, the blooms are drawn once and never move.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    required this.child,
    this.variant = AuroraVariant.home,
  });

  final Widget child;
  final AuroraVariant variant;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

/// Where the blooms sit — Home keeps them out of the way of the content
/// column; Session gathers them behind the ring.
enum AuroraVariant { home, session }

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: Motion.aurora,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tide = NightTide.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [tide.background, tide.backgroundDeep],
            ),
          ),
        ),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _drift,
            builder: (context, _) => CustomPaint(
              painter: _AuroraPainter(
                t: _drift.value,
                blooms: _bloomsFor(widget.variant, tide),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }

  List<_Bloom> _bloomsFor(AuroraVariant variant, NightTide tide) {
    switch (variant) {
      case AuroraVariant.home:
        return [
          _Bloom(
            anchor: const Alignment(1.1, -1.2),
            radius: 0.62,
            colour: tide.accent,
            alpha: 0.34,
            wobble: 0.10,
          ),
          _Bloom(
            anchor: const Alignment(-1.3, 0.35),
            radius: 0.62,
            colour: tide.indigo,
            alpha: 0.28,
            wobble: 0.08,
          ),
          _Bloom(
            anchor: const Alignment(0.9, 1.15),
            radius: 0.42,
            colour: tide.mint,
            alpha: 0.08,
            wobble: 0.12,
          ),
        ];
      case AuroraVariant.session:
        return [
          _Bloom(
            anchor: const Alignment(-0.7, -0.15),
            radius: 0.75,
            colour: tide.accent,
            alpha: 0.26,
            wobble: 0.07,
          ),
          _Bloom(
            anchor: const Alignment(0.75, 0.55),
            radius: 0.62,
            colour: tide.indigo,
            alpha: 0.30,
            wobble: 0.07,
          ),
        ];
    }
  }
}

class _Bloom {
  const _Bloom({
    required this.anchor,
    required this.radius,
    required this.colour,
    required this.alpha,
    required this.wobble,
  });

  final Alignment anchor;

  /// Radius as a fraction of the shorter screen side.
  final double radius;
  final Color colour;
  final double alpha;

  /// How far (as a fraction of the shorter side) the bloom wanders.
  final double wobble;
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({required this.t, required this.blooms});

  final double t;
  final List<_Bloom> blooms;

  @override
  void paint(Canvas canvas, Size size) {
    final short = math.min(size.width, size.height);
    final angle = t * 2 * math.pi;
    for (var i = 0; i < blooms.length; i++) {
      final bloom = blooms[i];
      // Each bloom follows its own slow ellipse so they never move in step.
      final phase = angle + i * 2.1;
      final dx = math.cos(phase) * bloom.wobble * short;
      final dy = math.sin(phase * 0.7) * bloom.wobble * short;
      final centre = bloom.anchor.alongSize(size) + Offset(dx, dy);
      final radius = bloom.radius * short;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            bloom.colour.withValues(alpha: bloom.alpha),
            bloom.colour.withValues(alpha: bloom.alpha * 0.35),
            bloom.colour.withValues(alpha: 0),
          ],
          stops: const [0, 0.4, 1],
        ).createShader(Rect.fromCircle(center: centre, radius: radius));
      canvas.drawCircle(centre, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t || old.blooms != blooms;
}
