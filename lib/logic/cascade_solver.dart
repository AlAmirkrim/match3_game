import '../models/grid.dart';
import '../models/tile.dart';
import '../models/tile_type.dart';
import 'match_finder.dart';
import 'special_handler.dart';

/// Result of one cascade step
class CascadeStep {
  final List<MatchGroup> matches;
  final List<Tile> clearedTiles;
  final List<Tile> fallenTiles;
  final List<Tile> spawnedTiles;
  final List<SpecialActivation> specialActivations;
  final int scoreEarned;

  const CascadeStep({
    required this.matches,
    required this.clearedTiles,
    required this.fallenTiles,
    required this.spawnedTiles,
    required this.specialActivations,
    required this.scoreEarned,
  });

  bool get isEmpty => clearedTiles.isEmpty;
}

/// Full result after one player move (may contain multiple cascade steps)
class MoveResult {
  final List<CascadeStep> steps;
  final int totalScore;
  final bool hadMatches;

  const MoveResult({
    required this.steps,
    required this.totalScore,
    required this.hadMatches,
  });
}

class CascadeSolver {
  final Grid grid;
  final MatchFinder _finder;
  final SpecialHandler _specialHandler;

  // Score multiplier increases with each cascade chain
  int _chainMultiplier = 1;

  CascadeSolver(this.grid)
      : _finder = MatchFinder(grid),
        _specialHandler = SpecialHandler(grid);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Attempts a swap. If it produces matches, runs the full cascade.
  /// If no matches, reverts the swap and returns null.
  MoveResult? trySwap(int r1, int c1, int r2, int c2) {
    // Handle special tile activation on swap
    final tile1 = grid.get(r1, c1);
    final tile2 = grid.get(r2, c2);

    // Rainbow + any color: clear all of that color
    if (tile1.type == TileType.rainbow || tile2.type == TileType.rainbow) {
      grid.swap(r1, c1, r2, c2);
      return _resolveRainbow(r1, c1, r2, c2);
    }

    grid.swap(r1, c1, r2, c2);
    final steps = _runCascade();

    if (steps.isEmpty) {
      // No match — revert
      grid.swap(r1, c1, r2, c2);
      return null;
    }

    return MoveResult(
      steps: steps,
      totalScore: steps.fold(0, (s, step) => s + step.scoreEarned),
      hadMatches: true,
    );
  }

  /// Activates a special tile in place (tapped by user).
  MoveResult activateSpecial(int r, int c) {
    final tile = grid.get(r, c);
    if (!tile.isSpecial) return MoveResult(steps: [], totalScore: 0, hadMatches: false);

    final activation = _specialHandler.activate(tile);
    _markEmpty(activation.cleared);
    final fallen = _applyGravity();
    final spawned = grid.fillEmpty();

    final step = CascadeStep(
      matches: [],
      clearedTiles: activation.cleared,
      fallenTiles: fallen,
      spawnedTiles: spawned,
      specialActivations: [activation],
      scoreEarned: activation.cleared.length * 60,
    );

    final remainingSteps = _runCascade();

    return MoveResult(
      steps: [step, ...remainingSteps],
      totalScore: step.scoreEarned +
          remainingSteps.fold(0, (s, st) => s + st.scoreEarned),
      hadMatches: true,
    );
  }

  // ── Cascade engine ─────────────────────────────────────────────────────────

  List<CascadeStep> _runCascade() {
    _chainMultiplier = 1;
    final steps = <CascadeStep>[];

    while (true) {
      final matches = _finder.findAllMatches();
      if (matches.isEmpty) break;

      // Mark matched tiles
      final cleared = <Tile>[];
      final activations = <SpecialActivation>[];

      for (final group in matches) {
        for (final tile in group.tiles) {
          if (!cleared.any((t) => t.row == tile.row && t.col == tile.col)) {
            cleared.add(tile);
          }
        }

        // Spawn special tile at center if match is big enough
        _maybeSpawnSpecial(group);

        // Trigger any special tiles inside the match
        for (final tile in group.tiles) {
          if (tile.isSpecial) {
            final act = _specialHandler.activate(tile);
            activations.add(act);
            for (final ct in act.cleared) {
              if (!cleared.any((t) => t.row == ct.row && t.col == ct.col)) {
                cleared.add(ct);
              }
            }
          }
        }
      }

      // Remove cleared tiles
      _markEmpty(cleared);

      // Gravity
      final fallen = _applyGravity();

      // Refill
      final spawned = grid.fillEmpty();

      // Score: base points × chain multiplier
      final score = cleared.length * 30 * _chainMultiplier;

      steps.add(CascadeStep(
        matches: matches,
        clearedTiles: List.from(cleared),
        fallenTiles: fallen,
        spawnedTiles: spawned,
        specialActivations: activations,
        scoreEarned: score,
      ));

      _chainMultiplier++;
    }

    return steps;
  }

  // ── Gravity ────────────────────────────────────────────────────────────────

  /// Shifts tiles down to fill gaps. Returns list of tiles that moved.
  List<Tile> _applyGravity() {
    final moved = <Tile>[];

    for (int c = 0; c < grid.cols; c++) {
      // Collect non-empty tiles in column from bottom to top
      final column = <TileType>[];
      for (int r = grid.rows - 1; r >= 0; r--) {
        if (!grid.get(r, c).isEmpty) {
          column.add(grid.get(r, c).type);
        }
      }

      // Rebuild column: empty on top, then non-empty types from bottom
      int writeR = grid.rows - 1;
      for (final type in column) {
        if (grid.get(writeR, c).type != type ||
            grid.get(writeR, c).state != TileState.idle) {
          grid.cells[writeR][c].type = type;
          grid.cells[writeR][c].state = TileState.falling;
          moved.add(grid.cells[writeR][c]);
        }
        writeR--;
      }
      // Empty remaining top rows
      for (int r = writeR; r >= 0; r--) {
        grid.cells[r][c].type = TileType.empty;
        grid.cells[r][c].state = TileState.idle;
      }
    }

    return moved;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _markEmpty(List<Tile> tiles) {
    for (final t in tiles) {
      grid.cells[t.row][t.col].type = TileType.empty;
      grid.cells[t.row][t.col].state = TileState.matched;
    }
  }

  void _maybeSpawnSpecial(MatchGroup group) {
    if (group.length < 4) return;

    TileType special;
    if (group.shape == MatchShape.line5 || group.length >= 5) {
      special = TileType.rainbow;
    } else if (group.shape == MatchShape.lShape ||
        group.shape == MatchShape.tShape) {
      special = TileType.bomb;
    } else {
      // 4 in a row — horizontal or vertical rocket
      final tile0 = group.tiles.first;
      final tile1 = group.tiles[1];
      special = (tile0.row == tile1.row)
          ? TileType.rocketH
          : TileType.rocketV;
    }

    final center = group.center;
    grid.placeSpecial(center.row, center.col, special);
  }

  MoveResult _resolveRainbow(int r1, int c1, int r2, int c2) {
    // After swap: one tile is rainbow, other is normal color
    final t1 = grid.get(r1, c1);
    final t2 = grid.get(r2, c2);

    TileType targetColor;
    int rainbowR, rainbowC;

    if (t1.type == TileType.rainbow) {
      rainbowR = r1; rainbowC = c1;
      targetColor = t2.type.isNormal ? t2.type : TileType.red;
    } else {
      rainbowR = r2; rainbowC = c2;
      targetColor = t1.type.isNormal ? t1.type : TileType.red;
    }

    // Clear all tiles of that color + the rainbow itself
    final cleared = <Tile>[];
    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        final t = grid.get(r, c);
        if (t.type == targetColor ||
            (r == rainbowR && c == rainbowC)) {
          cleared.add(t);
        }
      }
    }

    _markEmpty(cleared);
    final fallen = _applyGravity();
    final spawned = grid.fillEmpty();

    final step = CascadeStep(
      matches: [],
      clearedTiles: cleared,
      fallenTiles: fallen,
      spawnedTiles: spawned,
      specialActivations: [],
      scoreEarned: cleared.length * 80,
    );

    final remainingSteps = _runCascade();

    return MoveResult(
      steps: [step, ...remainingSteps],
      totalScore: step.scoreEarned +
          remainingSteps.fold(0, (s, st) => s + st.scoreEarned),
      hadMatches: true,
    );
  }
}
