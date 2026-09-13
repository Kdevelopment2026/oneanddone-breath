import 'package:flutter/material.dart';

import '../motion/fade_rise.dart';
import '../state/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';

/// Sound/haptics toggles, the one-purchase statement, and the privacy
/// statement. There is deliberately nothing else here — no account, no
/// sign-in, no content library to browse (see CLAUDE.md, golden rule 1).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings.shared;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() => setState(() {});

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              FadeRise(
                index: 0,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: tide.textMuted,
                      tooltip: 'Back',
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Text('Settings', style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FadeRise(
                index: 1,
                child: _Group(
                  children: [
                    SwitchListTile(
                      title: const Text('Sound'),
                      subtitle: const Text('A soft chime on phase changes'),
                      value: _settings.soundEnabled,
                      onChanged: _settings.setSoundEnabled,
                    ),
                    const Divider(indent: 20, endIndent: 20),
                    SwitchListTile(
                      title: const Text('Haptics'),
                      subtitle: const Text('A gentle tap on phase changes'),
                      value: _settings.hapticsEnabled,
                      onChanged: _settings.setHapticsEnabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeRise(
                index: 2,
                child: _Group(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.check_circle_outline_rounded,
                        color: tide.accent,
                      ),
                      title: const Text('One purchase, nothing else'),
                      subtitle: const Text(
                        'You already own this outright. The price you paid to download '
                        'OneAndDone Breath is the only charge there ever is. No subscription, '
                        'no account, no purchases inside the app, no recurring charge.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FadeRise(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'This app makes no network requests. Nothing about your sessions is '
                    'collected, stored remotely, or shared.',
                    style: theme.textTheme.bodySmall,
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

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tide = NightTide.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tide.surface,
        borderRadius: BorderRadius.circular(NightTide.radius),
        border: Border.all(color: tide.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(children: children),
      ),
    );
  }
}
