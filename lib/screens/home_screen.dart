import 'package:flutter/material.dart';

import '../models/breathing_technique.dart';
import '../models/context_preset.dart';
import '../motion/fade_rise.dart';
import '../motion/motion.dart';
import '../motion/tide_route.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/glow_button.dart';
import 'session_screen.dart';
import 'settings_screen.dart';

/// Presets, technique and length pickers, and Begin. A preset is a
/// shortcut that fills in the pickers — the user can still change either
/// before starting (CLAUDE.md, golden rule 3).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const lengthOptions = [1, 2, 3, 5, 10];

  BreathingTechnique _technique = ContextPreset.beforeAMeeting.technique;
  int _minutes = ContextPreset.beforeAMeeting.minutes;

  /// The preset whose technique + length are currently both selected, if
  /// any — purely for the highlight; the pickers are the source of truth.
  ContextPreset? get _matchingPreset {
    for (final preset in ContextPreset.all) {
      if (preset.technique == _technique && preset.minutes == _minutes) {
        return preset;
      }
    }
    return null;
  }

  void _applyPreset(ContextPreset preset) {
    setState(() {
      _technique = preset.technique;
      _minutes = preset.minutes;
    });
  }

  void _begin() {
    Navigator.of(context).push(
      TideRoute<void>(
        builder: (_) => SessionScreen(
          technique: _technique,
          minutes: _minutes,
          presetTitle: _matchingPreset?.title,
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context)
        .push(TideRoute<void>(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                  children: [
                    FadeRise(
                      index: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'OneAndDone',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune_rounded),
                            color: tide.textMuted,
                            tooltip: 'Settings',
                            onPressed: _openSettings,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeRise(
                      index: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay once. Breathe forever.',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tide.mint,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                tide.text,
                                tide.textMuted.withValues(alpha: 0.9),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'Ready when\nyou are.',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    FadeRise(
                      index: 2,
                      child: _Section(
                        label: 'For right now',
                        child: Column(
                          children: [
                            for (final preset in ContextPreset.all) ...[
                              _PresetCard(
                                preset: preset,
                                selected: _matchingPreset == preset,
                                onTap: () => _applyPreset(preset),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeRise(
                      index: 3,
                      child: _Section(
                        label: 'Technique',
                        child: _Segmented<BreathingTechnique>(
                          options: BreathingTechnique.all,
                          selected: _technique,
                          labelOf: (t) => t.shortName,
                          onChanged: (t) => setState(() => _technique = t),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeRise(
                      index: 4,
                      child: _Section(
                        label: 'Length',
                        child: _Segmented<int>(
                          options: lengthOptions,
                          selected: _minutes,
                          labelOf: (m) => '$m min',
                          onChanged: (m) => setState(() => _minutes = m),
                          gap: 8,
                          contained: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              FadeRise(
                index: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
                  child: Column(
                    children: [
                      GlowButton(label: 'Begin', onPressed: _begin),
                      const SizedBox(height: 14),
                      Text(
                        'No account. No subscription. Nothing collected.',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
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

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final ContextPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);
    final reduced = Motion.reduced(context);

    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label:
          '${preset.title}. ${preset.subtitle}. ${preset.technique.name}, ${preset.minutes} minutes.',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : Motion.quick,
          curve: Motion.ease,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NightTide.radius),
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(tide.surfaceRaised, tide.accent, 0.14)!,
                      tide.surfaceRaised,
                    ],
                  )
                : null,
            color: selected ? null : tide.surface,
            border: Border.all(
              color: selected ? tide.accent.withValues(alpha: 0.8) : tide.line,
              width: selected ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: tide.accent.withValues(alpha: selected ? 0.22 : 0),
                blurRadius: 32,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(preset.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(preset.subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedDefaultTextStyle(
                duration: reduced ? Duration.zero : Motion.quick,
                style: theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? tide.accent : tide.textMuted,
                ),
                child: Text(
                  '${preset.technique.shortName} · ${preset.minutes} min',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of equal-width options with one selected. [contained] draws the
/// whole row on a shared pill (technique); otherwise each option is its own
/// chip (length).
class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.gap = 4,
    this.contained = true,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final double gap;
  final bool contained;

  @override
  Widget build(BuildContext context) {
    final tide = NightTide.of(context);
    final row = Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: _SegmentOption(
              label: labelOf(options[i]),
              selected: options[i] == selected,
              outlined: !contained,
              onTap: () => onChanged(options[i]),
            ),
          ),
        ],
      ],
    );
    if (!contained) return row;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tide.surface,
        borderRadius: BorderRadius.circular(NightTide.radius),
        border: Border.all(color: tide.line),
      ),
      child: row,
    );
  }
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
    required this.label,
    required this.selected,
    required this.outlined,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);
    final reduced = Motion.reduced(context);
    final radius = outlined ? NightTide.radius : NightTide.radius - 4;

    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : Motion.quick,
          curve: Motion.ease,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? tide.accent
                : (outlined ? tide.surface : Colors.transparent),
            borderRadius: BorderRadius.circular(radius),
            border: outlined
                ? Border.all(color: selected ? tide.accent : tide.line)
                : null,
            boxShadow: [
              BoxShadow(
                color: tide.accent.withValues(alpha: selected ? 0.28 : 0),
                blurRadius: 18,
              ),
            ],
          ),
          child: AnimatedDefaultTextStyle(
            duration: reduced ? Duration.zero : Motion.quick,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? tide.onAccent : tide.textMuted,
            ),
            textAlign: TextAlign.center,
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
