import 'package:flutter/widgets.dart';

/// Shared timing and easing so every screen moves the same way. Calm by
/// design: nothing snaps, nothing bounces (CLAUDE.md, golden rule 10 applies
/// to motion as much as to copy).
abstract final class Motion {
  /// Selection state changes — card highlight, chip fill.
  static const quick = Duration(milliseconds: 220);

  /// Entrance of a single element.
  static const enter = Duration(milliseconds: 520);

  /// Delay between consecutive elements in a staggered entrance.
  static const stagger = Duration(milliseconds: 60);

  /// Screen-to-screen transition.
  static const route = Duration(milliseconds: 560);

  /// Phase label crossfade inside a session.
  static const phaseSwap = Duration(milliseconds: 380);

  /// One full drift cycle of the aurora backdrop.
  static const aurora = Duration(seconds: 26);

  static const ease = Curves.easeOutCubic;
  static const easeInOut = Curves.easeInOutCubic;

  /// Honour the OS "reduce motion" setting: when set, every decorative
  /// animation collapses to its end state and only functional state changes
  /// (e.g. the breathing ring itself) keep moving.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}
