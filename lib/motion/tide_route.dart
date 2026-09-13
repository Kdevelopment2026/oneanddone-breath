import 'package:flutter/material.dart';

import 'motion.dart';

/// Screen transition: the incoming screen fades in while settling from a
/// slight enlargement, the outgoing one dims. No slide — nothing in this
/// app should feel like it's being pushed around.
class TideRoute<T> extends PageRouteBuilder<T> {
  TideRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: Motion.route,
        reverseTransitionDuration: Motion.route,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (Motion.reduced(context)) {
            return FadeTransition(opacity: animation, child: child);
          }
          final curved = CurvedAnimation(
            parent: animation,
            curve: Motion.easeInOut,
          );
          final scale = Tween<double>(begin: 1.04, end: 1).animate(curved);
          final dim = Tween<double>(begin: 1, end: 0.85).animate(
            CurvedAnimation(
              parent: secondaryAnimation,
              curve: Motion.easeInOut,
            ),
          );
          return FadeTransition(
            opacity: dim,
            child: FadeTransition(
              opacity: curved,
              child: ScaleTransition(scale: scale, child: child),
            ),
          );
        },
      );
}
