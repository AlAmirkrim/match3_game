import 'package:flutter/material.dart';
import '../levels/level_config.dart';
import '../levels/level_progress.dart';
import 'game_screen.dart';

class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({super.key});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  LevelProgress? _progress;

  @override
  void initState() {
    super.initState();
    LevelProgress.load().then((p) => setState(() => _progress = p));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2e7d32), Color(0xFF1b5e20)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildLevelGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final stars = _progress?.totalStars ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('Choose Level',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.star, color: Colors.amber, size: 22),
          const SizedBox(width: 4),
          Text('$stars',
              style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLevelGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: LevelRegistry.totalLevels,
      itemBuilder: (context, index) {
        final levelNum = index + 1;
        final result = _progress?.getLevel(levelNum) ?? LevelResult.locked(levelNum);
        return _LevelNode(
          levelNumber: levelNum,
          result: result,
          onTap: result.unlocked ? () => _startLevel(context, levelNum) : null,
        );
      },
    );
  }

  void _startLevel(BuildContext context, int levelNum) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameScreen(levelNumber: levelNum),
    ));
  }
}

class _LevelNode extends StatelessWidget {
  final int levelNumber;
  final LevelResult result;
  final VoidCallback? onTap;

  const _LevelNode({required this.levelNumber, required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLocked = !result.unlocked;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLocked
                ? [const Color(0xFF455A64), const Color(0xFF37474F)]
                : [const Color(0xFFFFD700), const Color(0xFFFFA000)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isLocked ? Colors.black26 : const Color(0x66FFA000),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: isLocked ? Colors.white12 : Colors.white38, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLocked)
              const Icon(Icons.lock, color: Colors.white54, size: 24)
            else
              Text('$levelNumber',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            if (!isLocked && result.stars > 0) ...[
              const SizedBox(height: 4),
              _StarRow(stars: result.stars),
            ],
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int stars;
  const _StarRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (i) => Icon(
          i < stars ? Icons.star : Icons.star_border,
          color: i < stars ? Colors.white : Colors.white38,
          size: 13,
        ),
      ),
    );
  }
}
