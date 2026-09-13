import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'state/app_settings.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Sound/haptics preferences, read from local storage before first frame
  // so the toggles never flash their defaults.
  await AppSettings.shared.load();
  runApp(const OneAndDoneBreathApp());
}

/// A strictly one-time-purchase breathing app — see README.md for why.
class OneAndDoneBreathApp extends StatelessWidget {
  const OneAndDoneBreathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneAndDone Breath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Night Tide is a dark design; the light theme exists so nothing
      // breaks if this is ever switched to ThemeMode.system.
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
