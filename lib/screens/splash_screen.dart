import 'dart:async';

import 'package:flutter/material.dart';

import '../models/breathing_technique.dart';
import '../motion/motion.dart';
import '../motion/tide_route.dart';
import '../state/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/breathing_ring.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// The first thing on screen after the native launch image: the ring draws
/// itself in and the wordmark settles beneath it, then the app moves on to
/// onboarding (first launch) or Home. About 1.6 s; instant under Reduce
/// Motion. It is a moment of arrival, not a loading screen — nothing is
/// being fetched.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final Animation<double> _draw = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
  );
  late final Animation<double> _word = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (Motion.reduced(context)) {
      _controller.value = 1;
      unawaited(Future<void>.delayed(const Duration(milliseconds: 400), _next));
    } else {
      unawaited(_controller.forward().then((_) => _next()));
    }
  }

  void _next() {
    if (!mounted) return;
    final seen = AppSettings.shared.onboardingSeen;
    Navigator.of(context).pushReplacement(
      TideRoute<void>(
        builder: (_) => seen ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);
    return Scaffold(
      body: AuroraBackground(
        variant: AuroraVariant.session,
        child: Semantics(
          label: 'OneAndDone Breath',
          excludeSemantics: true,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Column(
              children: [
                const Spacer(flex: 3),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Opacity(
                    opacity: Curves.easeOut.transform(
                      (_draw.value * 2).clamp(0.0, 1.0),
                    ),
                    child: BreathingRing(
                      phase: BreathPhaseType.inhale,
                      progress: _draw.value,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Opacity(
                  opacity: _word.value,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - _word.value)),
                    child: Column(
                      children: [
                        Text(
                          'OneAndDone',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Breathe',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tide.mint,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
