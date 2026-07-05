import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Floating "+score" text that pops up and fades away.
class ScorePopWidget extends StatelessWidget {
  final int points;
  final Offset position;
  final VoidCallback? onDone;

  const ScorePopWidget({
    super.key,
    required this.points,
    required this.position,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 30,
      top: position.dy - 20,
      child: IgnorePointer(
        child: Text(
          '+$points',
          style: const TextStyle(
            color: Colors.yellowAccent,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        )
            .animate(onComplete: (_) => onDone?.call())
            .slideY(begin: 0, end: -1.5, duration: 700.ms, curve: Curves.easeOut)
            .fadeOut(begin: 1.0, duration: 700.ms, delay: 300.ms),
      ),
    );
  }
}
