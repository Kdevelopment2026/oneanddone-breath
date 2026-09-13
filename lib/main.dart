import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
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
      home: const HomeScreen(),
    );
  }
}
