import 'dart:math';
import 'package:flutter/material.dart';

/// Renders a burst of colorful particles at a given position.
/// Use an [OverlayEntry] to show this above everything else.
class ParticleBurst extends StatefulWidget {
  final Offset position;
  final Color color;
  final int count;
  final VoidCallback? onDone;

  const ParticleBurst({
    super.key,
    required this.position,
    this.color = Colors.amber,
    this.count = 12,
    this.onDone,
  });

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;
  final _random = Random();

  static const _colors = [
    Colors.amber,
    Colors.orange,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (_) {
      return _Particle(
        angle: _random.nextDouble() * 2 * pi,
        speed: 60 + _random.nextDouble() * 120,
        size: 5 + _random.nextDouble() * 8,
        color: _colors[_random.nextInt(_colors.length)],
      );
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDone?.call();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Stack(
          children: _particles.map((p) {
            final dx = cos(p.angle) * p.speed * t;
            final dy = sin(p.angle) * p.speed * t;
            final opacity = (1.0 - t).clamp(0.0, 1.0);
            return Positioned(
              left: widget.position.dx + dx - p.size / 2,
              top: widget.position.dy + dy - p.size / 2,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: p.size,
                  height: p.size,
                  decoration: BoxDecoration(
                    color: p.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: p.color.withOpacity(0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Helper to show a particle burst inside an Overlay
void showParticleBurst(BuildContext context, Offset globalPosition, Color color) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => ParticleBurst(
      position: globalPosition,
      color: color,
      count: 14,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}
