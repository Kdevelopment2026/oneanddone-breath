import 'package:flutter/material.dart';

import '../models/breathing_technique.dart';
import '../models/context_preset.dart';
import 'session_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BreathingTechnique _technique = BreathingTechnique.coherent;
  int _minutes = 3;

  void _begin(BreathingTechnique technique, int minutes) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionScreen(technique: technique, minutes: minutes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneAndDone Breath'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('What\'s this for right now?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...ContextPreset.all.map(
            (preset) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PresetCard(
                preset: preset,
                onTap: () => _begin(preset.technique, preset.minutes),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Or choose your own', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _TechniquePicker(
            selected: _technique,
            onChanged: (t) => setState(() => _technique = t),
          ),
          const SizedBox(height: 16),
          _DurationPicker(
            selectedMinutes: _minutes,
            onChanged: (m) => setState(() => _minutes = m),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => _begin(_technique, _minutes),
            child: const Text('Begin'),
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.preset, required this.onTap});

  final ContextPreset preset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        title: Text(preset.title),
        subtitle: Text('${preset.subtitle} · ${preset.technique.name} · ${preset.minutes} min'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _TechniquePicker extends StatelessWidget {
  const _TechniquePicker({required this.selected, required this.onChanged});

  final BreathingTechnique selected;
  final ValueChanged<BreathingTechnique> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: BreathingTechnique.all.map((technique) {
        return RadioListTile<BreathingTechnique>(
          value: technique,
          groupValue: selected,
          onChanged: (value) => onChanged(value!),
          title: Text(technique.name),
          subtitle: Text(technique.description),
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({required this.selectedMinutes, required this.onChanged});

  static const options = [1, 3, 5, 10];

  final int selectedMinutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((minutes) {
        return ChoiceChip(
          label: Text('$minutes min'),
          selected: selectedMinutes == minutes,
          onSelected: (_) => onChanged(minutes),
        );
      }).toList(),
    );
  }
}
