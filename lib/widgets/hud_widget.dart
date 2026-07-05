import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_controller.dart';
import '../levels/level_config.dart';

class HudWidget extends StatelessWidget {
  const HudWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Moves left
          _HudCell(
            icon: Icons.touch_app,
            label: 'Moves',
            value: '${ctrl.movesLeft}',
            color: ctrl.movesLeft <= 5 ? Colors.redAccent : Colors.white,
          ),
          const SizedBox(width: 12),
          // Score / Goal progress
          Expanded(child: _buildGoalSection(ctrl)),
          const SizedBox(width: 12),
          // Hint button
          _HintButton(onTap: ctrl.requestHint),
        ],
      ),
    );
  }

  Widget _buildGoalSection(GameController ctrl) {
    if (ctrl.config.goalType == GoalType.score) {
      return _ScoreBar(
        score: ctrl.score,
        target: ctrl.targetScore,
        progress: ctrl.scoreProgress,
      );
    }
    // Collect goals
    return _CollectGoalRow(goals: ctrl.collectGoals);
  }
}

// ── Score bar ──────────────────────────────────────────────────────────────

class _ScoreBar extends StatelessWidget {
  final int score;
  final int target;
  final double progress;

  const _ScoreBar({
    required this.score,
    required this.target,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$score',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              '/ $target',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.greenAccent : const Color(0xFFFFD700),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Collect goal row ───────────────────────────────────────────────────────

class _CollectGoalRow extends StatelessWidget {
  final List<CollectGoal> goals;
  const _CollectGoalRow({required this.goals});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: goals
          .map((g) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(g.tileType.emoji, style: const TextStyle(fontSize: 22)),
                    Text(
                      '${g.remaining}',
                      style: TextStyle(
                        color: g.isComplete ? Colors.greenAccent : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration:
                            g.isComplete ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ── Single HUD cell ────────────────────────────────────────────────────────

class _HudCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _HudCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}

// ── Hint button ────────────────────────────────────────────────────────────

class _HintButton extends StatelessWidget {
  final VoidCallback onTap;
  const _HintButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x440288D1), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 22),
      ),
    );
  }
}
