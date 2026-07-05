import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'level_map_screen.dart';

class GameOverScreen extends StatelessWidget {
  final int levelNumber;

  const GameOverScreen({super.key, required this.levelNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF37474F), Color(0xFF263238), Color(0xFF1C1C1C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😔', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                const Text('Out of Moves!',
                    style: TextStyle(color: Colors.redAccent, fontSize: 34, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Level $levelNumber', style: const TextStyle(color: Colors.white38, fontSize: 16)),
                const SizedBox(height: 40),
                _buildButton(
                  context,
                  label: '↺  Try Again',
                  gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)]),
                  onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => GameScreen(levelNumber: levelNumber))),
                ),
                const SizedBox(height: 14),
                _buildButton(
                  context,
                  label: 'Level Map',
                  gradient: LinearGradient(colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.08),
                  ]),
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LevelMapScreen()), (route) => route.isFirst),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label, required Gradient gradient, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 54,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
