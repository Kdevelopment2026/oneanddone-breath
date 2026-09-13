import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';

/// The soft chime and gentle tap on phase changes (CLAUDE.md, build order
/// step 6). Both respect [AppSettings]; both are local — the chime is a
/// bundled asset, never streamed.
class PhaseFeedback {
  PhaseFeedback({AppSettings? settings})
    : _settings = settings ?? AppSettings.shared,
      _enabled = true;

  /// A feedback object that never touches the platform — for widget tests,
  /// where there is no audio or haptics channel.
  PhaseFeedback.silent({AppSettings? settings})
    : _settings = settings ?? AppSettings.shared,
      _enabled = false;

  final AppSettings _settings;
  final bool _enabled;
  AudioPlayer? _player;
  bool _primed = false;

  /// Preloads the chime so the first phase change doesn't lag.
  Future<void> prime() async {
    if (_primed || !_enabled) return;
    _primed = true;
    try {
      final player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _player = player;
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setSource(AssetSource('audio/chime.wav'));
    } catch (_) {
      // No audio on this device/session — the visual guide still works.
      _player = null;
    }
  }

  Future<void> onPhaseChanged() async {
    if (!_enabled) return;
    if (_settings.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    final player = _player;
    if (_settings.soundEnabled && player != null) {
      try {
        await player.stop();
        await player.play(AssetSource('audio/chime.wav'), volume: 0.7);
      } catch (_) {
        // Same as above: silence is an acceptable fallback.
      }
    }
  }

  Future<void> dispose() async => _player?.dispose();
}
