import 'package:flutter/material.dart';

/// Sound/haptics toggles, purchase status, and the privacy statement.
/// There is deliberately nothing else here — no account, no sign-in, no
/// content library to browse (see CLAUDE.md, golden rule 1).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('A soft chime on phase changes'),
            value: _soundEnabled,
            onChanged: (value) => setState(() => _soundEnabled = value),
          ),
          SwitchListTile(
            title: const Text('Haptics'),
            subtitle: const Text('A gentle tap on phase changes'),
            value: _hapticsEnabled,
            onChanged: (value) => setState(() => _hapticsEnabled = value),
          ),
          const Divider(),
          const ListTile(
            title: Text('One purchase, nothing else'),
            subtitle: Text(
              'You already own this outright — the price you paid to download '
              'OneAndDone Breath is the only charge there ever is. No subscription, '
              'no account, no in-app purchase, no recurring charge.',
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'This app makes no network requests. Nothing about your sessions is '
              'collected, stored remotely, or shared.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
