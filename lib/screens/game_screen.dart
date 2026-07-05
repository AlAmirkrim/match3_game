import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_controller.dart';
import '../levels/level_config.dart';
import '../levels/level_progress.dart';
import '../widgets/simple_board.dart';
import '../widgets/hud_widget.dart';
import 'level_complete_screen.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;
  const GameScreen({super.key, required this.levelNumber});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _ctrl;
  bool _overlayShown = false;

  @override
  void initState() {
    super.initState();
    final config = LevelRegistry.get(widget.levelNumber);
    _ctrl = GameController(config: config);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameController>.value(
      value: _ctrl,
      child: Consumer<GameController>(
        builder: (context, ctrl, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeShowOverlay(ctrl);
          });

          return Scaffold(
            backgroundColor: const Color(0xFF0D1B2A),
            body: SafeArea(
              child: Column(
                children: [
                  // ── Top bar ──────────────────────────────────────────
                  _buildTopBar(context, ctrl),
                  const SizedBox(height: 6),

                  // ── Story banner ─────────────────────────────────────
                  if (ctrl.config.storyText != null)
                    _buildStoryBanner(ctrl.config.storyText!),

                  // ── HUD ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: const HudWidget(),
                  ),

                  // ── Board — يأخذ المساحة المتبقية ────────────────────
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: const SimpleBoard(),
                      ),
                    ),
                  ),

                  // ── Boosters ─────────────────────────────────────────
                  _buildBoosterBar(ctrl),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, GameController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _circleButton(Icons.arrow_back_ios, () => _confirmExit(context)),
          const Spacer(),
          Text(
            'Level ${widget.levelNumber}',
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _circleButton(
              Icons.pause, () => _showPauseMenu(context, ctrl)),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Story banner ──────────────────────────────────────────────────────────

  Widget _buildStoryBanner(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.amber, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Booster bar ───────────────────────────────────────────────────────────

  Widget _buildBoosterBar(GameController ctrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BoosterButton(
            emoji: '💣',
            label: 'Bomb',
            onTap: () {
              final r = ctrl.grid.rows ~/ 2;
              final c = ctrl.grid.cols ~/ 2;
              ctrl.useBombBooster(r, c);
            }),
        const SizedBox(width: 20),
        _BoosterButton(
            emoji: '💡', label: 'Hint', onTap: ctrl.requestHint),
        const SizedBox(width: 20),
        _BoosterButton(
            emoji: '➕',
            label: '+5 Moves',
            onTap: () => ctrl.addMoves(5)),
      ],
    );
  }

  // ── Overlays ──────────────────────────────────────────────────────────────

  void _maybeShowOverlay(GameController ctrl) {
    if (_overlayShown) return;
    if (ctrl.phase == GamePhase.levelComplete) {
      _overlayShown = true;
      _saveAndShowComplete(ctrl);
    } else if (ctrl.phase == GamePhase.gameOver) {
      _overlayShown = true;
      _showGameOver();
    }
  }

  Future<void> _saveAndShowComplete(GameController ctrl) async {
    final progress = await LevelProgress.load();
    await progress.recordCompletion(
      levelNumber: widget.levelNumber,
      score: ctrl.score,
      stars: ctrl.stars,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => LevelCompleteScreen(
        levelNumber: widget.levelNumber,
        score: ctrl.score,
        stars: ctrl.stars,
      ),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  void _showGameOver() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) =>
          GameOverScreen(levelNumber: widget.levelNumber),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            const Text('Quit Level?', style: TextStyle(color: Colors.white)),
        content: const Text('Your progress will be lost.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue',
                  style: TextStyle(color: Colors.amber))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Quit',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  void _showPauseMenu(BuildContext context, GameController ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B263B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paused',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _menuBtn('▶  Resume', Colors.amber,
                () => Navigator.pop(context)),
            const SizedBox(height: 12),
            _menuBtn('↺  Restart', Colors.blue, () {
              Navigator.pop(context);
              setState(() {
                _overlayShown = false;
                _ctrl.dispose();
                _ctrl = GameController(
                    config: LevelRegistry.get(widget.levelNumber));
              });
            }),
            const SizedBox(height: 12),
            _menuBtn('✕  Quit', Colors.redAccent,
                () => Navigator.popUntil(context, (r) => r.isFirst)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _menuBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ── Booster button ────────────────────────────────────────────────────────

class _BoosterButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _BoosterButton(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}
