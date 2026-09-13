import 'package:flutter/material.dart';

import '../models/breathing_technique.dart';
import '../motion/fade_rise.dart';
import '../motion/motion.dart';
import '../motion/tide_route.dart';
import '../state/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/breathing_ring.dart';
import '../widgets/glow_button.dart';
import 'home_screen.dart';

/// Three swipeable pages shown once, on first launch: what you bought, what
/// it does, what it doesn't do with your data. No account step, no
/// permission prompts, no "personalise your plan" (CLAUDE.md, golden rules
/// 3, 5, 9). Skippable at any point.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    _Page(
      eyebrow: 'One purchase',
      title: 'Pay once.\nBreathe forever.',
      body:
          'You already own the whole app. No subscription, no upgrade, '
          'no "premium techniques". This is the only screen that will ever '
          'mention money.',
      visual: _Visual.ring,
    ),
    _Page(
      eyebrow: 'Three techniques',
      title: 'A few good ways\nto breathe.',
      body:
          'Box breathing for a steady reset. 4-7-8 for winding down. '
          'Coherent breathing for calm focus. Presets pick one for the '
          'moment; you can always change it.',
      visual: _Visual.techniques,
    ),
    _Page(
      eyebrow: 'Private by design',
      title: 'Nothing collected.\nNothing to protect.',
      body:
          'No account, no cloud, no analytics. Nothing about your sessions '
          'is stored anywhere. It works fully offline. Open it, breathe, '
          'close it.',
      visual: _Visual.privacy,
    ),
  ];

  final PageController _pageController = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  void _advance() {
    if (_isLast) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: Motion.reduced(context) ? Duration.zero : Motion.route,
      curve: Motion.easeInOut,
    );
  }

  void _finish() {
    AppSettings.shared.setOnboardingSeen(true);
    Navigator.of(context)
        .pushReplacement(TideRoute<void>(builder: (_) => const HomeScreen()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              FadeRise(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OneAndDone',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: _finish,
                        style: TextButton.styleFrom(
                          foregroundColor: tide.textMuted,
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _PageView(page: _pages[i]),
                ),
              ),
              FadeRise(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Column(
                    children: [
                      _Dots(count: _pages.length, index: _index),
                      const SizedBox(height: 20),
                      GlowButton(
                        label: _isLast ? 'Begin' : 'Continue',
                        onPressed: _advance,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Visual { ring, techniques, privacy }

class _Page {
  const _Page({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.visual,
  });

  final String eyebrow;
  final String title;
  final String body;
  final _Visual visual;
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page});

  final _Page page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Center(child: _VisualFor(page.visual))),
          FadeRise(
            index: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.eyebrow,
                  style: theme.textTheme.labelSmall?.copyWith(color: tide.mint),
                ),
                const SizedBox(height: 10),
                Text(
                  page.title,
                  style: theme.textTheme.displayMedium?.copyWith(fontSize: 38),
                ),
                const SizedBox(height: 14),
                Text(
                  page.body,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: tide.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _VisualFor extends StatelessWidget {
  const _VisualFor(this.visual);

  final _Visual visual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);
    switch (visual) {
      case _Visual.ring:
        return const SizedBox(
          width: 280,
          height: 280,
          child: BreathingRing(phase: BreathPhaseType.inhale, progress: 0.7),
        );
      case _Visual.techniques:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final t in BreathingTechnique.all) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: tide.surface,
                  borderRadius: BorderRadius.circular(NightTide.radius),
                  border: Border.all(color: tide.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(t.name, style: theme.textTheme.titleMedium),
                    ),
                    Text(
                      t.phases.map((p) => _short(p.seconds)).join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tide.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      case _Visual.privacy:
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                tide.accent.withValues(alpha: 0.35),
                tide.accent.withValues(alpha: 0),
              ],
            ),
          ),
          child: Icon(Icons.lock_outline_rounded, size: 72, color: tide.mint),
        );
    }
  }

  static String _short(double seconds) => seconds == seconds.roundToDouble()
      ? seconds.toInt().toString()
      : seconds.toString();
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tide = NightTide.of(context);
    final reduced = Motion.reduced(context);
    return Semantics(
      label: 'Page ${index + 1} of $count',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: reduced ? Duration.zero : Motion.quick,
              curve: Motion.ease,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == index ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == index ? tide.accent : tide.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}
