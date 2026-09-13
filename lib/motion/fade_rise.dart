import 'package:flutter/material.dart';

import 'motion.dart';

/// Fades a child in while lifting it a few points — the entrance used for
/// every section on Home and Session. Give consecutive children increasing
/// [index] values for a staggered reveal.
///
/// Collapses to the final state immediately under "reduce motion".
class FadeRise extends StatefulWidget {
  const FadeRise({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 18,
  });

  final Widget child;
  final int index;

  /// Vertical distance travelled, in logical pixels.
  final double offset;

  @override
  State<FadeRise> createState() => _FadeRiseState();
}

class _FadeRiseState extends State<FadeRise>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.enter,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Motion.ease,
  );
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    if (Motion.reduced(context)) {
      _controller.value = 1;
      return;
    }
    Future<void>.delayed(Motion.stagger * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
