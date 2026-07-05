import 'package:flutter/foundation.dart';
import '../models/grid.dart';
import '../models/tile.dart';
import '../models/tile_type.dart';
import '../logic/cascade_solver.dart';
import '../logic/match_finder.dart';
import '../levels/level_config.dart';

enum GamePhase {
  idle,          // Waiting for player input
  animating,     // Playing match/fall animations
  levelComplete,
  gameOver,
}

class GameController extends ChangeNotifier {
  final LevelConfig config;
  final Grid grid;
  late final CascadeSolver _solver;
  late final MatchFinder _finder;

  // Selection state
  Tile? selectedTile;

  // Scoring & moves
  int score = 0;
  int movesLeft;
  int get targetScore => config.targetScore;

  // Collection goals (deep copy so we can track progress)
  late final List<CollectGoal> collectGoals;

  // Phase
  GamePhase phase = GamePhase.idle;

  // Last cascade result (used by UI to drive animations)
  MoveResult? lastMoveResult;

  // Hint
  ({int r1, int c1, int r2, int c2})? hint;

  GameController({required this.config, Grid? existingGrid})
      : grid = existingGrid ??
            Grid(rows: config.gridRows, cols: config.gridCols),
        movesLeft = config.moves {
    _solver = CascadeSolver(grid);
    _finder = MatchFinder(grid);
    // Deep-copy collect goals so we can mutate them
    collectGoals = config.collectGoals
        .map((g) => CollectGoal(
              tileType: g.tileType,
              required: g.required,
              collected: 0,
            ))
        .toList();
  }

  // ── Input handling ─────────────────────────────────────────────────────────

  void onTileTap(int row, int col) {
    if (phase != GamePhase.idle) return;

    final tapped = grid.get(row, col);

    if (tapped.isSpecial && selectedTile == null) {
      _activateSpecial(row, col);
      return;
    }

    if (selectedTile == null) {
      selectedTile = tapped;
      tapped.state = TileState.selected;
      notifyListeners();
      return;
    }

    final sel = selectedTile!;

    if (sel.row == row && sel.col == col) {
      sel.state = TileState.idle;
      selectedTile = null;
      notifyListeners();
      return;
    }

    final dr = (sel.row - row).abs();
    final dc = (sel.col - col).abs();
    if ((dr == 1 && dc == 0) || (dr == 0 && dc == 1)) {
      sel.state = TileState.idle;
      selectedTile = null;
      _attemptSwap(sel.row, sel.col, row, col);
      return;
    }

    sel.state = TileState.idle;
    selectedTile = tapped;
    tapped.state = TileState.selected;
    notifyListeners();
  }

  void onSwipeSwap(int r1, int c1, int r2, int c2) {
    if (phase != GamePhase.idle) return;
    selectedTile?.state = TileState.idle;
    selectedTile = null;
    _attemptSwap(r1, c1, r2, c2);
  }

  // ── Move logic ─────────────────────────────────────────────────────────────

  void _attemptSwap(int r1, int c1, int r2, int c2) {
    phase = GamePhase.animating;
    hint = null;
    notifyListeners();

    final result = _solver.trySwap(r1, c1, r2, c2);

    if (result == null) {
      phase = GamePhase.idle;
      notifyListeners();
      return;
    }

    lastMoveResult = result;
    score += result.totalScore;
    movesLeft--;
    _updateCollectGoals(result);

    notifyListeners();
  }

  void _activateSpecial(int row, int col) {
    phase = GamePhase.animating;
    hint = null;
    notifyListeners();

    final result = _solver.activateSpecial(row, col);
    lastMoveResult = result;
    score += result.totalScore;
    movesLeft--;
    _updateCollectGoals(result);

    notifyListeners();
  }

  /// Update collect goals from all cleared tiles in the move result
  void _updateCollectGoals(MoveResult result) {
    if (collectGoals.isEmpty) return;
    for (final step in result.steps) {
      for (final tile in step.clearedTiles) {
        for (final goal in collectGoals) {
          if (goal.tileType == tile.type && !goal.isComplete) {
            goal.collected++;
          }
        }
      }
    }
  }

  /// Called by the board widget after all step animations finish.
  void onAnimationComplete() {
    if (_isWinConditionMet()) {
      phase = GamePhase.levelComplete;
    } else if (movesLeft <= 0) {
      phase = GamePhase.gameOver;
    } else {
      phase = GamePhase.idle;
      _checkDeadlock();
    }
    notifyListeners();
  }

  bool _isWinConditionMet() {
    switch (config.goalType) {
      case GoalType.score:
        return score >= config.targetScore;
      case GoalType.collect:
        return collectGoals.every((g) => g.isComplete);
      case GoalType.clear:
        return score >= config.targetScore; // fallback
    }
  }

  // ── Hint & deadlock ────────────────────────────────────────────────────────

  void requestHint() {
    if (phase != GamePhase.idle) return;
    hint = _finder.findHint();
    notifyListeners();
  }

  void _checkDeadlock() {
    if (_finder.findHint() == null) _shuffleBoard();
  }

  void _shuffleBoard() {
    final types = <TileType>[];
    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        final t = grid.get(r, c);
        if (t.isNormal) types.add(t.type);
      }
    }
    types.shuffle();
    int idx = 0;
    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        final t = grid.get(r, c);
        if (t.isNormal) grid.cells[r][c].type = types[idx++];
      }
    }
    notifyListeners();
  }

  // ── Boosters ───────────────────────────────────────────────────────────────

  void useBombBooster(int row, int col) {
    if (phase != GamePhase.idle) return;
    grid.placeSpecial(row, col, TileType.bomb);
    _activateSpecial(row, col);
  }

  // ── Computed properties ────────────────────────────────────────────────────

  bool get isComplete => phase == GamePhase.levelComplete;
  bool get isGameOver => phase == GamePhase.gameOver;

  double get scoreProgress =>
      (score / config.targetScore).clamp(0.0, 1.0);

  int get stars {
    if (score >= config.targetScore * 1.5) return 3;
    if (score >= config.targetScore * 1.2) return 2;
    if (score >= config.targetScore) return 1;
    return 0;
  }

  String get goalDescription {
    switch (config.goalType) {
      case GoalType.score:
        return 'Reach $targetScore pts';
      case GoalType.collect:
        final parts = collectGoals
            .map((g) => '${g.remaining}× ${g.tileType.emoji}')
            .join('  ');
        return parts;
      case GoalType.clear:
        return 'Clear all tiles';
    }
  }
}
