import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'level_map_screen.dart';

class LevelCompleteScreen extends StatelessWidget {
  final int levelNumber;
  final int score;
  final int stars;

  const LevelCompleteScreen({
    super.key,
    required this.levelNumber,
    required this.score,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a237e), Color(0xFF283593), Color(0xFF3949AB)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('👑', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                const Text('Level Complete!',
                    style: TextStyle(color: Colors.amber, fontSize: 36, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Level $levelNumber', style: const TextStyle(color: Colors.white54, fontSize: 18)),
                const SizedBox(height: 28),
                _StarDisplay(stars: stars),
                const SizedBox(height: 24),
                _ScoreCard(score: score),
                const SizedBox(height: 40),
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        _ActionButton(
          label: 'Next Level ▶',
          color: const Color(0xFFFFD700),
          textColor: Colors.black87,
          onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => GameScreen(levelNumber: levelNumber + 1))),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'Level Map',
          color: Colors.white.withOpacity(0.15),
          textColor: Colors.white,
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LevelMapScreen()), (route) => route.isFirst),
        ),
      ],
    );
  }
}

class _StarDisplay extends StatelessWidget {
  final int stars;
  const _StarDisplay({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? Colors.amber : Colors.white24,
            size: filled ? 64 : 52,
          ),
        );
      }),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  const _ScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const Text('SCORE',
              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3)),
          const SizedBox(height: 4),
          Text(
            _formatScore(score),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _formatScore(int s) {
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}K';
    return '$s';
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 54,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
