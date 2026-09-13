import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/breathing_technique.dart';
import '../motion/fade_rise.dart';
import '../motion/motion.dart';
import '../state/phase_feedback.dart';
import '../state/session_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/breathing_animation.dart';
import '../widgets/breathing_ring.dart';
import '../widgets/glow_button.dart';

/// The whole session in one full-screen view: the breathing ring, the
/// current phase in plain text laid over it (never animation-only — see
/// CLAUDE.md, golden rule 6), the seconds left in the phase, and the time
/// left in the session. Owns the real-time [Ticker] driving
/// [SessionController.tick]; the controller itself stays framework-agnostic
/// so it can be unit-tested without one.
class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.technique,
    required this.minutes,
    this.presetTitle,
    this.feedback,
  });

  final BreathingTechnique technique;
  final int minutes;

  /// Shown under the technique name when the session came from a preset.
  final String? presetTitle;

  /// Chime + haptic on phase change. Tests pass [PhaseFeedback.silent].
  final PhaseFeedback? feedback;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final SessionController _controller = SessionController(
    technique: widget.technique,
    totalMinutes: widget.minutes,
  );
  late final Ticker _ticker = createTicker(_onTick);
  late final PhaseFeedback _feedback = widget.feedback ?? PhaseFeedback();
  Duration _lastElapsed = Duration.zero;
  int _lastPhaseIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onControllerChanged);
    unawaited(_feedback.prime());
    // Keep the screen on for the length of the session; a breathing guide
    // that dims to black after 30 seconds isn't one.
    unawaited(WakelockPlus.enable().catchError((_) {}));
    _controller.start();
    _ticker.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Leaving the app pauses the session rather than letting the clock run
    // on in the background — the user resumes when they're back.
    if (state != AppLifecycleState.resumed &&
        _controller.state == SessionState.running) {
      _pause();
    }
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    _controller.tick(delta.inMicroseconds / Duration.microsecondsPerSecond);
  }

  void _onControllerChanged() {
    if (_controller.state == SessionState.complete) {
      _ticker.stop();
      unawaited(_feedback.onPhaseChanged());
    } else if (_controller.phaseIndex != _lastPhaseIndex) {
      unawaited(_feedback.onPhaseChanged());
    }
    _lastPhaseIndex = _controller.phaseIndex;
    setState(() {});
  }

  void _pause() {
    _controller.pause();
    _ticker.stop();
  }

  void _resume() {
    // Drop the time that passed while paused so the next tick is small.
    _lastElapsed = Duration.zero;
    _ticker.stop();
    _controller.start();
    _ticker.start();
  }

  void _togglePause() {
    if (_controller.state == SessionState.running) {
      _pause();
    } else if (_controller.state == SessionState.paused) {
      _resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(WakelockPlus.disable().catchError((_) {}));
    _ticker.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    unawaited(_feedback.dispose());
    super.dispose();
  }

  String get _remainingLabel {
    final remaining = _controller.remainingSeconds.ceil();
    final minutes = remaining ~/ 60;
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds remaining';
  }

  int get _phaseSecondsLeft {
    final phase = _controller.currentPhase;
    return (phase.seconds - _controller.phaseElapsedSeconds).ceil().clamp(
      1,
      phase.seconds.ceil(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);
    final reduced = Motion.reduced(context);
    final isComplete = _controller.state == SessionState.complete;
    final isPaused = _controller.state == SessionState.paused;
    final subtitle = [
      if (widget.presetTitle != null) widget.presetTitle!,
      '${widget.minutes} min',
    ].join(' · ');

    return Scaffold(
      body: AuroraBackground(
        variant: AuroraVariant.session,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                FadeRise(
                  index: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.technique.name,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(subtitle, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: tide.textMuted,
                        tooltip: 'End session',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: reduced
                        ? Duration.zero
                        : const Duration(milliseconds: 700),
                    switchInCurve: Motion.easeInOut,
                    switchOutCurve: Motion.easeInOut,
                    child: isComplete
                        ? const _CompleteView(key: ValueKey('complete'))
                        : _ActiveView(
                            key: const ValueKey('active'),
                            phase: _controller.currentPhase.type,
                            progress: _controller.phaseProgress,
                            secondsLeft: _phaseSecondsLeft,
                            remainingLabel: _remainingLabel,
                            paused: isPaused,
                          ),
                  ),
                ),
                FadeRise(
                  index: 2,
                  child: isComplete
                      ? GlowButton(
                          label: 'Done',
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      : GlowButton.quiet(
                          label: isPaused ? 'Resume' : 'Pause',
                          icon: isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          onPressed: _togglePause,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The ring with the phase label and countdown laid over its centre, and
/// the session time left beneath.
class _ActiveView extends StatelessWidget {
  const _ActiveView({
    super.key,
    required this.phase,
    required this.progress,
    required this.secondsLeft,
    required this.remainingLabel,
    required this.paused,
  });

  final BreathPhaseType phase;
  final double progress;
  final int secondsLeft;
  final String remainingLabel;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);
    final reduced = Motion.reduced(context);

    return FadeRise(
      index: 1,
      offset: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Semantics(
              // VoiceOver reads the phase, not the drawing (CLAUDE.md, step 8).
              // Only the label is live, so a change of phase is announced
              // but the countdown doesn't chatter every second.
              label: phase.label,
              value: '$secondsLeft seconds',
              liveRegion: true,
              excludeSemantics: true,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BreathingAnimation(
                    phase: phase,
                    progress: progress,
                    paused: paused,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: reduced ? Duration.zero : Motion.phaseSwap,
                          switchInCurve: Motion.ease,
                          switchOutCurve: Motion.ease,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0, 0.25),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: Text(
                            phase.label,
                            key: ValueKey(phase.label),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Color.lerp(tide.text, tide.mint, 0.25),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: reduced
                              ? Duration.zero
                              : const Duration(milliseconds: 260),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween(
                                    begin: 0.92,
                                    end: 1.0,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: Text(
                            '$secondsLeft',
                            key: ValueKey(secondsLeft),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 76,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: tide.accent.withValues(alpha: 0.5),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: paused ? 0.6 : 1,
            duration: Motion.quick,
            child: Text(
              paused ? 'Paused · $remainingLabel' : remainingLabel,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// A calm end: the ring settles at rest, the words say so, nothing else —
/// no score, no streak, no share (CLAUDE.md, golden rule 9).
class _CompleteView extends StatelessWidget {
  const _CompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const BreathingRing(
                phase: BreathPhaseType.holdAfterInhale,
                progress: 0,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Session complete',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Take that with you.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
