import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../levels/level_progress.dart';
import 'level_map_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a237e), Color(0xFF4a148c), Color(0xFF880e4f)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Castle illustration placeholder
              _buildCastle(),
              const SizedBox(height: 16),
              // Title
              _buildTitle(),
              const Spacer(),
              // Play button
              _buildPlayButton(context),
              const SizedBox(height: 16),
              // Settings row
              _buildBottomRow(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCastle() {
    return Container(
      width: 200,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF5D060)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: const Center(
        child: Text('🏰', style: TextStyle(fontSize: 100)),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'ROYAL',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFD700),
            letterSpacing: 6,
            shadows: [
              Shadow(color: Colors.black54, blurRadius: 8, offset: const Offset(2, 4)),
            ],
          ),
        ),
        Text(
          'MATCH',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 8,
            shadows: [
              Shadow(color: Colors.black38, blurRadius: 6, offset: const Offset(1, 3)),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .scaleXY(begin: 0.8, end: 1.0, delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut);
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openLevelMap(context),
      child: Container(
        width: 220,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x88FFA000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'PLAY',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.04, duration: 900.ms, curve: Curves.easeInOut);
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _iconButton(Icons.settings, 'Settings', () {}),
        const SizedBox(width: 24),
        _iconButton(Icons.leaderboard, 'Leaderboard', () {}),
        const SizedBox(width: 24),
        _iconButton(Icons.info_outline, 'About', () => _showAbout(context)),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _iconButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  void _openLevelMap(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LevelMapScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a237e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Royal Match', style: TextStyle(color: Colors.amber)),
        content: const Text(
          'A Match-3 puzzle game.\nSwipe or tap tiles to match 3 or more!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }
}
