import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/breathing_technique.dart';
import '../state/session_controller.dart';
import '../widgets/breathing_animation.dart';

/// The whole session in one full-screen view: the animation, the current
/// phase in plain text (never animation-only — see CLAUDE.md, golden rule
/// 6), and a countdown. Owns the real-time [Ticker] driving
/// [SessionController.tick]; the controller itself stays framework-agnostic
/// so it can be unit-tested without one.
class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.technique, required this.minutes});

  final BreathingTechnique technique;
  final int minutes;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> with SingleTickerProviderStateMixin {
  late final SessionController _controller = SessionController(
    technique: widget.technique,
    totalMinutes: widget.minutes,
  );
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.start();
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    _controller.tick(delta.inMicroseconds / Duration.microsecondsPerSecond);
  }

  void _onControllerChanged() {
    if (_controller.state == SessionState.complete) {
      _ticker.stop();
    }
    setState(() {});
  }

  void _togglePause() {
    if (_controller.state == SessionState.running) {
      _controller.pause();
      _ticker.stop();
    } else if (_controller.state == SessionState.paused) {
      _controller.start();
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _controller.remainingSeconds.ceil();
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final isComplete = _controller.state == SessionState.complete;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.technique.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isComplete
                  ? const _CompleteView()
                  : BreathingAnimation(
                      phase: _controller.currentPhase.type,
                      progress: _controller.phaseProgress,
                    ),
            ),
            if (!isComplete) ...[
              Text(
                _controller.currentPhase.type.label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '$minutes:$seconds remaining',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              IconButton.filledTonal(
                iconSize: 36,
                icon: Icon(
                  _controller.state == SessionState.running ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: _togglePause,
              ),
              const SizedBox(height: 24),
            ] else
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompleteView extends StatelessWidget {
  const _CompleteView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('Session complete', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
