import '../models/grid.dart';
import '../models/tile.dart';
import '../models/tile_type.dart';

class SpecialActivation {
  final TileType type;
  final List<Tile> cleared;

  const SpecialActivation({required this.type, required this.cleared});
}

/// Handles the activation logic for all special tile types.
class SpecialHandler {
  final Grid grid;

  SpecialHandler(this.grid);

  SpecialActivation activate(Tile tile) {
    switch (tile.type) {
      case TileType.rocketH:
        return _activateRocketH(tile.row, tile.col);
      case TileType.rocketV:
        return _activateRocketV(tile.row, tile.col);
      case TileType.bomb:
        return _activateBomb(tile.row, tile.col);
      case TileType.rainbow:
        // When tapped alone (not swapped), clear most common color
        return _activateRainbowAlone(tile.row, tile.col);
      default:
        return SpecialActivation(type: tile.type, cleared: []);
    }
  }

  // ── Rocket H — clears entire row ──────────────────────────────────────────
  SpecialActivation _activateRocketH(int r, int col) {
    final cleared = <Tile>[];
    for (int c = 0; c < grid.cols; c++) {
      final t = grid.get(r, c);
      if (!t.isEmpty) cleared.add(t);
    }
    return SpecialActivation(type: TileType.rocketH, cleared: cleared);
  }

  // ── Rocket V — clears entire column ───────────────────────────────────────
  SpecialActivation _activateRocketV(int row, int c) {
    final cleared = <Tile>[];
    for (int r = 0; r < grid.rows; r++) {
      final t = grid.get(r, c);
      if (!t.isEmpty) cleared.add(t);
    }
    return SpecialActivation(type: TileType.rocketV, cleared: cleared);
  }

  // ── Bomb — clears 3×3 area ────────────────────────────────────────────────
  SpecialActivation _activateBomb(int row, int col) {
    final cleared = <Tile>[];
    for (int r = row - 1; r <= row + 1; r++) {
      for (int c = col - 1; c <= col + 1; c++) {
        if (grid.inBounds(r, c)) {
          final t = grid.get(r, c);
          if (!t.isEmpty) cleared.add(t);
        }
      }
    }
    return SpecialActivation(type: TileType.bomb, cleared: cleared);
  }

  // ── Rainbow alone — finds most common color and clears all of it ──────────
  SpecialActivation _activateRainbowAlone(int row, int col) {
    // Count colors
    final counts = <TileType, int>{};
    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        final t = grid.get(r, c);
        if (t.type.isNormal) {
          counts[t.type] = (counts[t.type] ?? 0) + 1;
        }
      }
    }

    if (counts.isEmpty) {
      return SpecialActivation(type: TileType.rainbow, cleared: []);
    }

    // Pick most common color
    final target = counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    final cleared = <Tile>[];
    // Add the rainbow tile itself
    cleared.add(grid.get(row, col));

    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        if (r == row && c == col) continue;
        final t = grid.get(r, c);
        if (t.type == target) cleared.add(t);
      }
    }

    return SpecialActivation(type: TileType.rainbow, cleared: cleared);
  }
}
