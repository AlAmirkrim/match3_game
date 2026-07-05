import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_controller.dart';
import '../models/tile_type.dart';

/// Board بسيط بدون animations معقدة — للإنتاج
class SimpleBoard extends StatelessWidget {
  const SimpleBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();
    final grid = ctrl.grid;
    final screenWidth = MediaQuery.of(context).size.width - 32;
    final tileSize = screenWidth / grid.cols;

    return Container(
      width: screenWidth,
      height: tileSize * grid.rows,
      decoration: BoxDecoration(
        color: const Color(0xFF0D2137),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(grid.rows, (r) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(grid.cols, (c) {
                final tile = grid.get(r, c);
                final isSelected = ctrl.selectedTile?.row == r &&
                    ctrl.selectedTile?.col == c;

                return GestureDetector(
                  onTap: () => ctrl.onTileTap(r, c),
                  child: Container(
                    width: tileSize,
                    height: tileSize,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getTileColor(tile.type),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: _getTileColor(tile.type).withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getTileEmoji(tile.type),
                        style: TextStyle(fontSize: tileSize * 0.5),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Color _getTileColor(TileType type) {
    switch (type) {
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

  String _getTileEmoji(TileType type) {
    switch (type) {
      case TileType.red:
        return '🟥';
      case TileType.green:
        return '🟩';
      case TileType.yellow:
        return '🟨';
      case TileType.blue:
        return '🟦';
      case TileType.purple:
        return '🟪';
      case TileType.rocketH:
      case TileType.rocketV:
        return '🚀';
      case TileType.bomb:
        return '💣';
      case TileType.rainbow:
        return '🌈';
      case TileType.empty:
        return '';
    }
  }
}
