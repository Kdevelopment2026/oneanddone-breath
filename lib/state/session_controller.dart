import 'package:flutter/foundation.dart';

import '../models/breathing_technique.dart';

enum SessionState { ready, running, paused, complete }

/// Owns all business state for one breathing session: which phase of the
/// technique is active, how far through it, and how much of the total
/// session remains. Holds no widgets, no `Ticker`, no platform animation
/// objects, so it is driven identically by a real timer or by a test —
/// call [tick] with the elapsed seconds since the last call
/// (mirrors the existing Flutter project's `SimulationController` pattern).
class SessionController extends ChangeNotifier {
  SessionController({
    required BreathingTechnique technique,
    required int totalMinutes,
  }) : _technique = technique, // ignore: prefer_initializing_formals
       _totalSeconds = totalMinutes * 60;

  BreathingTechnique _technique;
  double _totalSeconds;

  SessionState _state = SessionState.ready;
  double _elapsedSeconds = 0;
  int _phaseIndex = 0;
  double _phaseElapsedSeconds = 0;

  BreathingTechnique get technique => _technique;
  double get totalSeconds => _totalSeconds;
  SessionState get state => _state;
  double get elapsedSeconds => _elapsedSeconds;
  double get remainingSeconds =>
      (_totalSeconds - _elapsedSeconds).clamp(0, _totalSeconds);

  BreathPhase get currentPhase => _technique.phases[_phaseIndex];

  /// Index of [currentPhase] within the technique's cycle.
  int get phaseIndex => _phaseIndex;
  double get phaseElapsedSeconds => _phaseElapsedSeconds;

  /// 0.0–1.0 progress through the current phase, for driving the animation.
  double get phaseProgress => currentPhase.seconds == 0
      ? 1
      : (_phaseElapsedSeconds / currentPhase.seconds).clamp(0, 1);

  void start() {
    if (_state == SessionState.running) return;
    _state = SessionState.running;
    notifyListeners();
  }

  void pause() {
    if (_state != SessionState.running) return;
    _state = SessionState.paused;
    notifyListeners();
  }

  void reset({BreathingTechnique? technique, int? totalMinutes}) {
    if (technique != null) _technique = technique;
    if (totalMinutes != null) _totalSeconds = totalMinutes * 60;
    _state = SessionState.ready;
    _elapsedSeconds = 0;
    _phaseIndex = 0;
    _phaseElapsedSeconds = 0;
    notifyListeners();
  }

  /// Advances the session by [deltaSeconds]. No-ops unless running.
  void tick(double deltaSeconds) {
    if (_state != SessionState.running) return;
    // A restarted Ticker reports elapsed time from zero again; a negative
    // or NaN delta must never wind the session backwards.
    if (deltaSeconds.isNaN || deltaSeconds <= 0) return;

    _elapsedSeconds += deltaSeconds;
    _phaseElapsedSeconds += deltaSeconds;

    if (_elapsedSeconds >= _totalSeconds) {
      _elapsedSeconds = _totalSeconds;
      _state = SessionState.complete;
      notifyListeners();
      return;
    }

    while (_phaseElapsedSeconds >= currentPhase.seconds) {
      _phaseElapsedSeconds -= currentPhase.seconds;
      _phaseIndex = (_phaseIndex + 1) % _technique.phases.length;
    }

    notifyListeners();
  }
}
