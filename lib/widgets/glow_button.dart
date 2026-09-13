import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/app_theme.dart';

/// The primary action: a mint-to-teal gradient pill with a soft glow that
/// tightens slightly while pressed. Secondary actions use [GlowButton.quiet].
class GlowButton extends StatefulWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : quiet = false;

  const GlowButton.quiet({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : quiet = true;

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool quiet;

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tide = NightTide.of(context);
    final reduced = Motion.reduced(context);
    final duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 140);
    final foreground = widget.quiet ? tide.text : tide.onAccent;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: duration,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: duration,
            height: 56,
            constraints: BoxConstraints(
              minWidth: widget.quiet ? 168 : double.infinity,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NightTide.radius + 4),
              gradient: widget.quiet
                  ? null
                  : LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [tide.mint, tide.accent],
                    ),
              color: widget.quiet ? tide.surface : null,
              border: widget.quiet ? Border.all(color: tide.line) : null,
              boxShadow: widget.quiet
                  ? null
                  : [
                      BoxShadow(
                        color: tide.accent.withValues(
                          alpha: _pressed ? 0.25 : 0.4,
                        ),
                        blurRadius: _pressed ? 22 : 36,
                        spreadRadius: -4,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: foreground),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
