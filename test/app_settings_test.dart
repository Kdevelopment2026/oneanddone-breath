import 'package:flutter_test/flutter_test.dart';
import 'package:one_and_done_breath/state/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'defaults to sound and haptics on, and persists changes locally',
    () async {
      SharedPreferences.setMockInitialValues({});
      final settings = AppSettings.shared;
      await settings.load();
      expect(settings.soundEnabled, isTrue);
      expect(settings.hapticsEnabled, isTrue);

      await settings.setSoundEnabled(false);
      await settings.setHapticsEnabled(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sound_enabled'), isFalse);
      expect(prefs.getBool('haptics_enabled'), isFalse);
      // Only those two keys — nothing about sessions is ever stored.
      expect(prefs.getKeys(), {'sound_enabled', 'haptics_enabled'});
    },
  );
}
