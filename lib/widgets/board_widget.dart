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
  int? _dragStartRow;
  int? _dragStartCol;
  Offset? _dragStartOffset;
  static const double _swipeThreshold = 20.0;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();
    final grid = ctrl.grid;

    // حساب حجم كل tile بناءً على عرض الشاشة مباشرةً
    final screenWidth = MediaQuery.of(context).size.width - 16;
    final tileSize = screenWidth / grid.cols;

    return Container(
      width: screenWidth,
      height: tileSize * grid.rows,
      decoration: BoxDecoration(
        color: const Color(0xFF0D2137),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(grid.rows, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(grid.cols, (c) {
              final tile = grid.get(r, c);
              final isSelected =
                  ctrl.selectedTile?.row == r && ctrl.selectedTile?.col == c;
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

              if (tile.state == TileState.spawning) {
                tileW = tileW
                    .animate()
                    .fadeIn(duration: 250.ms)
                    .scaleXY(
                        begin: 0.4,
                        end: 1.0,
                        duration: 250.ms,
                        curve: Curves.elasticOut);
              }

              if (tile.state == TileState.falling) {
                tileW = tileW.animate().slideY(
                      begin: -(tile.fallDistance.toDouble()),
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeIn,
                    );
              }

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
                onPanUpdate: (details) {
                  if (_dragStartOffset == null) return;
                  final delta = details.localPosition - _dragStartOffset!;
                  if (delta.distance > _swipeThreshold) {
                    _handleSwipeFromDelta(ctrl, delta);
                    _dragStartOffset = null;
                  }
                },
                onPanEnd: (_) {
                  _dragStartRow = null;
                  _dragStartCol = null;
                  _dragStartOffset = null;
                },
                child: tileW,
              );
            }),
          );
        }),
      ),
    );
  }

  void _handleSwipeFromDelta(GameController ctrl, Offset delta) {
    if (_dragStartRow == null || _dragStartCol == null) return;
    final r = _dragStartRow!;
    final c = _dragStartCol!;
    int targetR = r;
    int targetC = c;

    if (delta.dx.abs() > delta.dy.abs()) {
      targetC = delta.dx > 0 ? c + 1 : c - 1;
    } else {
      targetR = delta.dy > 0 ? r + 1 : r - 1;
    }

    _dragStartRow = null;
    _dragStartCol = null;

    if (!ctrl.grid.inBounds(targetR, targetC)) return;
    ctrl.onSwipeSwap(r, c, targetR, targetC);
  }
}
