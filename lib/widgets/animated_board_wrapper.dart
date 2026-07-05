import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_controller.dart';
import 'board_widget.dart';
import 'combo_banner.dart';
import 'score_pop_widget.dart';

class AnimatedBoardWrapper extends StatefulWidget {
  const AnimatedBoardWrapper({super.key});

  @override
  State<AnimatedBoardWrapper> createState() => _AnimatedBoardWrapperState();
}

class _AnimatedBoardWrapperState extends State<AnimatedBoardWrapper>
    with SingleTickerProviderStateMixin {
  int _comboMultiplier = 0;
  bool _showCombo = false;
  final List<_ScorePop> _scorePops = [];

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (ctx, ctrl, _) {
        _handleMoveResult(ctrl);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(_shakeAnim.value, 0),
                child: child,
              ),
              child: const BoardWidget(),
            ),
            ..._scorePops.map((pop) => ScorePopWidget(
                  key: pop.key,
                  points: pop.points,
                  position: pop.position,
                  onDone: () => setState(() => _scorePops.remove(pop)),
                )),
            if (_showCombo)
              ComboBanner(
                multiplier: _comboMultiplier,
                onDone: () => setState(() => _showCombo = false),
              ),
          ],
        );
      },
    );
  }

  void _handleMoveResult(GameController ctrl) {
    final result = ctrl.lastMoveResult;
    if (result == null) return;

    if (!result.hadMatches) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _shakeCtrl.forward(from: 0));
      return;
    }

    if (result.steps.length >= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _comboMultiplier = result.steps.length;
          _showCombo = true;
        });
      });
    }

    if (result.totalScore > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final center = box.size.center(Offset.zero);
        setState(() {
          _scorePops.add(_ScorePop(
              key: UniqueKey(),
              points: result.totalScore,
              position: center));
        });
      });
    }

    ctrl.lastMoveResult = null;
  }
}

class _ScorePop {
  final Key key;
  final int points;
  final Offset position;
  _ScorePop({required this.key, required this.points, required this.position});
}
