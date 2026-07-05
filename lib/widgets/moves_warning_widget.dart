import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../game/game_controller.dart';

/// Shows a pulsing warning overlay when moves drop to 5 or below.
class MovesWarningWidget extends StatelessWidget {
  const MovesWarningWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();
    if (ctrl.movesLeft > 5 || ctrl.phase != GamePhase.idle) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.redAccent, blurRadius: 12, spreadRadius: 2),
            ],
          ),
          child: Text(
            '⚠️  Only ${ctrl.movesLeft} moves left!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 1.0, end: 1.05, duration: 500.ms)
            .shimmer(duration: 1000.ms, color: Colors.white38),
      ),
    );
  }
}
