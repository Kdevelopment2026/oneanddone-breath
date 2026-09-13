import 'package:flutter/material.dart';

/// "Night Tide" — the chosen visual direction (see the Pencil design file):
/// OLED-deep charcoal-navy, a luminous sea-glass accent, aurora blooms of
/// teal and indigo behind the content, thin geometric type. Calm and
/// unhurried — nothing that reads as gamified or alarming (CLAUDE.md,
/// golden rule 10).
///
/// The app is dark-first. A light theme is still built from the same seed
/// so the system setting is respected, but the dark one is the design.
abstract final class AppTheme {
  static const seed = Color(0xFF7FD1C4);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final tide = isDark ? NightTide.dark : NightTide.light;

    final colorScheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness).copyWith(
          primary: tide.accent,
          onPrimary: tide.onAccent,
          surface: tide.background,
          onSurface: tide.text,
          onSurfaceVariant: tide.textMuted,
          outline: tide.line,
          outlineVariant: tide.line,
          surfaceContainerLow: tide.surfaceRaised,
          surfaceContainer: tide.surfaceRaised,
          surfaceContainerHigh: tide.surfaceRaised,
          surfaceContainerHighest: tide.surfaceRaised,
        );

    final baseText = ThemeData(brightness: brightness).textTheme.apply(
      fontFamily: 'Geist',
      bodyColor: tide.text,
      displayColor: tide.text,
    );

    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        fontWeight: FontWeight.w200,
        letterSpacing: -1,
        height: 1.05,
      ),
      displayMedium: baseText.displayMedium?.copyWith(
        fontWeight: FontWeight.w300,
        letterSpacing: -0.8,
        height: 1.04,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w400),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: baseText.bodyMedium?.copyWith(color: tide.textMuted),
      bodySmall: baseText.bodySmall?.copyWith(color: tide.textMuted),
      labelSmall: baseText.labelSmall?.copyWith(
        color: tide.textMuted,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tide.background,
      fontFamily: 'Geist',
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      extensions: [tide],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: tide.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(220, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NightTide.radius),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? tide.onAccent
              : tide.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? tide.accent
              : tide.surfaceRaised,
        ),
        trackOutlineColor: WidgetStateProperty.all(tide.line),
      ),
      dividerTheme: DividerThemeData(color: tide.line, space: 1),
      listTileTheme: ListTileThemeData(
        textColor: tide.text,
        subtitleTextStyle: textTheme.bodySmall,
      ),
    );
  }
}

/// Night Tide's own tokens, over and above what a Material [ColorScheme]
/// can express — the aurora colours, the glow, the card surfaces. Read via
/// `NightTide.of(context)`.
@immutable
class NightTide extends ThemeExtension<NightTide> {
  const NightTide({
    required this.background,
    required this.backgroundDeep,
    required this.surface,
    required this.surfaceRaised,
    required this.line,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.mint,
    required this.indigo,
  });

  /// Corner radius used on cards, pills and the primary button.
  static const double radius = 24;

  final Color background;
  final Color backgroundDeep;
  final Color surface;
  final Color surfaceRaised;
  final Color line;
  final Color text;
  final Color textMuted;
  final Color accent;
  final Color onAccent;
  final Color mint;
  final Color indigo;

  static const dark = NightTide(
    background: Color(0xFF0D1320),
    backgroundDeep: Color(0xFF0A0E15),
    surface: Color(0x14FFFFFF),
    surfaceRaised: Color(0xFF141A24),
    line: Color(0x1FFFFFFF),
    text: Color(0xFFE8ECF1),
    textMuted: Color(0xFF8A94A3),
    accent: Color(0xFF7FD1C4),
    onAccent: Color(0xFF06110F),
    mint: Color(0xFFB8F5E9),
    indigo: Color(0xFF5B6CFF),
  );

  /// The same direction in daylight — used only when the system asks for a
  /// light theme. Kept deliberately close to the dark one's structure.
  static const light = NightTide(
    background: Color(0xFFF2F6F8),
    backgroundDeep: Color(0xFFE8EEF2),
    surface: Color(0xB3FFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    line: Color(0x1F0B0F16),
    text: Color(0xFF0B0F16),
    textMuted: Color(0xFF5E6878),
    accent: Color(0xFF1E8E7E),
    onAccent: Color(0xFFFFFFFF),
    mint: Color(0xFF57C7B5),
    indigo: Color(0xFF5B6CFF),
  );

  static NightTide of(BuildContext context) =>
      Theme.of(context).extension<NightTide>() ?? dark;

  @override
  NightTide copyWith({
    Color? background,
    Color? backgroundDeep,
    Color? surface,
    Color? surfaceRaised,
    Color? line,
    Color? text,
    Color? textMuted,
    Color? accent,
    Color? onAccent,
    Color? mint,
    Color? indigo,
  }) {
    return NightTide(
      background: background ?? this.background,
      backgroundDeep: backgroundDeep ?? this.backgroundDeep,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      line: line ?? this.line,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      mint: mint ?? this.mint,
      indigo: indigo ?? this.indigo,
    );
  }

  @override
  NightTide lerp(ThemeExtension<NightTide>? other, double t) {
    if (other is! NightTide) return this;
    return NightTide(
      background: Color.lerp(background, other.background, t)!,
      backgroundDeep: Color.lerp(backgroundDeep, other.backgroundDeep, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      line: Color.lerp(line, other.line, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      indigo: Color.lerp(indigo, other.indigo, t)!,
    );
  }
}
