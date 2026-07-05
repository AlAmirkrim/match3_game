import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/tile.dart';
import '../models/tile_type.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double size;
  final bool isSelected;
  final bool isHint;

  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
    this.isSelected = false,
    this.isHint = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tile.type.isEmpty) return SizedBox(width: size, height: size);

    Widget child = _buildTileContent();

    if (isSelected) {
      child = child
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.12, duration: 300.ms, curve: Curves.easeInOut);
    }

    if (isHint) {
      child = child
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 800.ms, color: Colors.white54);
    }

    return SizedBox(width: size, height: size, child: child);
  }

  Widget _buildTileContent() {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _baseColor(),
        borderRadius: BorderRadius.circular(size * 0.15),
        boxShadow: [
          BoxShadow(
            color: _baseColor().withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _baseColor().withOpacity(0.9),
            _baseColor(),
            _baseColor().withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: _buildIcon(),
      ),
    );
  }

  Widget _buildIcon() {
    switch (tile.type) {
      case TileType.red:
        return _gemIcon(Colors.red.shade300, Icons.square_rounded);
      case TileType.green:
        return _leafIcon();
      case TileType.yellow:
        return _crownIcon();
      case TileType.blue:
        return _gemIcon(Colors.blue.shade300, Icons.diamond);
      case TileType.purple:
        return _gemIcon(Colors.purple.shade300, Icons.hexagon);
      case TileType.rocketH:
        return _specialIcon('🚀', Colors.orange);
      case TileType.rocketV:
        return RotatedBox(
          quarterTurns: 1,
          child: _specialIcon('🚀', Colors.orange),
        );
      case TileType.bomb:
        return _specialIcon('💣', Colors.grey.shade800);
      case TileType.rainbow:
        return _rainbowIcon();
      case TileType.empty:
        return const SizedBox.shrink();
    }
  }

  Widget _gemIcon(Color color, IconData icon) {
    return Icon(icon, color: Colors.white, size: size * 0.55);
  }

  Widget _crownIcon() {
    return Text(
      '👑',
      style: TextStyle(fontSize: size * 0.52),
      textAlign: TextAlign.center,
    );
  }

  Widget _leafIcon() {
    return Text(
      '🌿',
      style: TextStyle(fontSize: size * 0.52),
      textAlign: TextAlign.center,
    );
  }

  Widget _specialIcon(String emoji, Color glowColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(0.6), blurRadius: 8, spreadRadius: 2),
        ],
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: size * 0.52),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _rainbowIcon() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
      ).createShader(bounds),
      child: Icon(Icons.auto_awesome, color: Colors.white, size: size * 0.55),
    );
  }

  Color _baseColor() {
    switch (tile.type) {
      case TileType.red:
        return const Color(0xFFE53935);
      case TileType.green:
        return const Color(0xFF43A047);
      case TileType.yellow:
        return const Color(0xFFFDD835);
      case TileType.blue:
        return const Color(0xFF1E88E5);
      case TileType.purple:
        return const Color(0xFF8E24AA);
      case TileType.rocketH:
      case TileType.rocketV:
        return const Color(0xFFFF8F00);
      case TileType.bomb:
        return const Color(0xFF37474F);
      case TileType.rainbow:
        return const Color(0xFFFFD600);
      case TileType.empty:
        return Colors.transparent;
    }
  }
}
