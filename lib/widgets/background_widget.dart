import 'dart:math';
import 'package:flutter/material.dart';

/// Animated parallax background with floating orbs and a gradient.
class BackgroundWidget extends StatefulWidget {
  final List<Color> gradientColors;
  final Widget child;

  const BackgroundWidget({
    super.key,
    required this.gradientColors,
    required this.child,
  });

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _random = Random();
  late List<_Orb> _orbs;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _orbs = List.generate(6, (_) => _Orb.random(_random));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient base
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.gradientColors,
            ),
          ),
        ),
        // Floating orbs
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return CustomPaint(
              painter: _OrbPainter(_orbs, _ctrl.value),
              child: const SizedBox.expand(),
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _Orb {
  final double x;      // 0..1
  final double y;      // 0..1
  final double size;
  final Color color;
  final double speed;  // phase offset

  _Orb({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
  });

  factory _Orb.random(Random rng) {
    const colors = [
      Color(0x22FFD700),
      Color(0x22FF6B35),
      Color(0x221E90FF),
      Color(0x2232CD32),
      Color(0x22DA70D6),
    ];
    return _Orb(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: 60 + rng.nextDouble() * 120,
      color: colors[rng.nextInt(colors.length)],
      speed: rng.nextDouble(),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final List<_Orb> orbs;
  final double t;

  _OrbPainter(this.orbs, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final orb in orbs) {
      final phase = (t + orb.speed) % 1.0;
      final dy = sin(phase * 2 * pi) * 20;
      final cx = orb.x * size.width;
      final cy = orb.y * size.height + dy;

      final paint = Paint()
        ..color = orb.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

      canvas.drawCircle(Offset(cx, cy), orb.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}
