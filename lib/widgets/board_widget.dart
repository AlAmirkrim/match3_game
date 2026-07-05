import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../game/game_controller.dart';
import '../models/tile_type.dart';
import 'tile_widget.dart';

class BoardWidget extends StatefulWidget {
  const BoardWidget({super.key});

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  // Drag state
  int? _dragStartRow;
  int? _dragStartCol;
  Offset? _dragStartOffset;

  static const double _swipeThreshold = 20.0;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();
    final grid = ctrl.grid;

    return LayoutBuilder(builder: (context, constraints) {
      final tileSize =
          (constraints.maxWidth / grid.cols).clamp(0.0, constraints.maxHeight / grid.rows);

      return Container(
        width: grid.cols * tileSize,
        height: grid.rows * tileSize,
        decoration: BoxDecoration(
          color: const Color(0xFF1A5C8A).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: List.generate(grid.rows, (r) {
            return Row(
              children: List.generate(grid.cols, (c) {
                final tile = grid.get(r, c);
                final isSelected = ctrl.selectedTile?.row == r &&
                    ctrl.selectedTile?.col == c;
                final hint = ctrl.hint;
                final isHint = hint != null &&
                    ((hint.r1 == r && hint.c1 == c) ||
                        (hint.r2 == r && hint.c2 == c));

                Widget tileW = TileWidget(
                  tile: tile,
                  size: tileSize,
                  isSelected: isSelected,
                  isHint: isHint,
                );

                // Spawn animation
                if (tile.state == TileState.spawning) {
                  tileW = tileW
                      .animate()
                      .fadeIn(duration: 250.ms)
                      .scaleXY(begin: 0.4, end: 1.0, duration: 250.ms, curve: Curves.elasticOut);
                }

                // Fall animation
                if (tile.state == TileState.falling) {
                  tileW = tileW
                      .animate()
                      .slideY(
                        begin: -(tile.fallDistance.toDouble()),
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeIn,
                      );
                }

                // Match pop animation
                if (tile.state == TileState.matched) {
                  tileW = tileW
                      .animate()
                      .scaleXY(begin: 1.0, end: 0.0, duration: 200.ms)
                      .fadeOut(duration: 200.ms);
                }

                return GestureDetector(
                  onTap: () => ctrl.onTileTap(r, c),
                  onPanStart: (details) {
                    _dragStartRow = r;
                    _dragStartCol = c;
                    _dragStartOffset = details.localPosition;
                  },
                  onPanEnd: (details) {
                    _handleSwipe(ctrl, tileSize);
                  },
                  onPanUpdate: (details) {
                    if (_dragStartOffset == null) return;
                    final delta = details.localPosition - _dragStartOffset!;
                    if (delta.distance > _swipeThreshold) {
                      _handleSwipeFromDelta(ctrl, delta);
                      _dragStartOffset = null;
                    }
                  },
                  child: tileW,
                );
              }),
            );
          }),
        ),
      );
    });
  }

  void _handleSwipe(GameController ctrl, double tileSize) {
    _dragStartRow = null;
    _dragStartCol = null;
    _dragStartOffset = null;
  }

  void _handleSwipeFromDelta(GameController ctrl, Offset delta) {
    if (_dragStartRow == null || _dragStartCol == null) return;

    final r = _dragStartRow!;
    final c = _dragStartCol!;
    int targetR = r;
    int targetC = c;

    // Determine swipe direction
    if (delta.dx.abs() > delta.dy.abs()) {
      // Horizontal swipe
      targetC = delta.dx > 0 ? c + 1 : c - 1;
    } else {
      // Vertical swipe
      targetR = delta.dy > 0 ? r + 1 : r - 1;
    }

    _dragStartRow = null;
    _dragStartCol = null;

    // Bounds check
    if (!ctrl.grid.inBounds(targetR, targetC)) return;

    ctrl.onSwipeSwap(r, c, targetR, targetC);
  }
}
