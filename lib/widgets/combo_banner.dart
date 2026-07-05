import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shows a "Combo x2!", "Combo x3!" banner in the center of the screen.
class ComboBanner extends StatelessWidget {
  final int multiplier;
  final VoidCallback? onDone;

  const ComboBanner({super.key, required this.multiplier, this.onDone});

  @override
  Widget build(BuildContext context) {
    final label = multiplier >= 5
        ? '🔥 INCREDIBLE! ×$multiplier'
        : multiplier >= 4
            ? '⚡ AMAZING! ×$multiplier'
            : multiplier >= 3
                ? '✨ GREAT! ×$multiplier'
                : '👍 COMBO ×$multiplier';

    final color = multiplier >= 5
        ? Colors.deepOrange
        : multiplier >= 3
            ? Colors.amber
            : Colors.lightBlueAccent;

    return Center(
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: color.withOpacity(0.8), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              shadows: [
                Shadow(color: color.withOpacity(0.8), blurRadius: 12),
              ],
            ),
          ),
        )
            .animate(onComplete: (_) => onDone?.call())
            .scaleXY(begin: 0.4, end: 1.1, duration: 250.ms, curve: Curves.elasticOut)
            .then()
            .scaleXY(begin: 1.1, end: 1.0, duration: 100.ms)
            .then(delay: 600.ms)
            .fadeOut(duration: 300.ms)
            .slideY(begin: 0, end: -0.5, duration: 300.ms),
      ),
    );
  }
}
