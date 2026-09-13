import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user preferences the app has: sound and haptics on phase changes,
/// and whether the first-launch introduction has been seen. Stored locally with `shared_preferences` — on the device only, never
/// transmitted, so the App Store privacy label stays "Data Not Collected"
/// (CLAUDE.md, golden rule 5). Nothing about sessions is stored.
class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings shared = AppSettings._();

  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _onboardingKey = 'onboarding_seen';

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _onboardingSeen = false;
  bool _loaded = false;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  /// True once the first-launch introduction has been dismissed.
  bool get onboardingSeen => _onboardingSeen;
  bool get loaded => _loaded;

  /// Reads the stored values. Safe to call more than once; a failure to
  /// read (e.g. in a test without a platform channel) leaves the defaults.
  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_soundKey) ?? true;
      _hapticsEnabled = prefs.getBool(_hapticsKey) ?? true;
      _onboardingSeen = prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      // Defaults stand.
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled == value) return;
    _soundEnabled = value;
    notifyListeners();
    await _write(_soundKey, value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    if (_hapticsEnabled == value) return;
    _hapticsEnabled = value;
    notifyListeners();
    await _write(_hapticsKey, value);
  }

  Future<void> setOnboardingSeen(bool value) async {
    if (_onboardingSeen == value) return;
    _onboardingSeen = value;
    notifyListeners();
    await _write(_onboardingKey, value);
  }

  Future<void> _write(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      // A failed write is not worth surfacing — the in-memory value still
      // applies for this launch.
    }
  }
}
