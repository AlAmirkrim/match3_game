import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/grid.dart';
import '../models/tile.dart';
import '../models/tile_type.dart';
import '../logic/cascade_solver.dart';
import '../logic/match_finder.dart';
import '../levels/level_config.dart';

enum GamePhase { idle, animating, levelComplete, gameOver }

class GameController extends ChangeNotifier {
  final LevelConfig config;
  final Grid grid;
  late final CascadeSolver _solver;
  late final MatchFinder _finder;

  Tile? selectedTile;
  int score = 0;
  int movesLeft;
  int get targetScore => config.targetScore;
  late final List<CollectGoal> collectGoals;
  GamePhase phase = GamePhase.idle;
  MoveResult? lastMoveResult;
  ({int r1, int c1, int r2, int c2})? hint;

  GameController({required this.config, Grid? existingGrid})
      : grid = existingGrid ?? Grid(rows: config.gridRows, cols: config.gridCols),
        movesLeft = config.moves {
    _solver = CascadeSolver(grid);
    _finder = MatchFinder(grid);
    collectGoals = config.collectGoals
        .map((g) => CollectGoal(tileType: g.tileType, required: g.required))
        .toList();
  }

  // ── Input ──────────────────────────────────────────────────────────────────

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
    final result = _solver.trySwap(r1, c1, r2, c2);
    if (result == null) {
      // Invalid swap — just notify UI to show shake, stay idle
      notifyListeners();
      return;
    }

    lastMoveResult = result;
    score += result.totalScore;
    movesLeft--;
    _updateCollectGoals(result);
    hint = null;

    notifyListeners();

    // Auto-complete animation after short delay
    _scheduleAnimationComplete();
  }

  void _activateSpecial(int row, int col) {
    final result = _solver.activateSpecial(row, col);
    lastMoveResult = result;
    score += result.totalScore;
    movesLeft--;
    _updateCollectGoals(result);
    hint = null;
    notifyListeners();
    _scheduleAnimationComplete();
  }

  /// Waits for animations then checks win/lose condition.
  void _scheduleAnimationComplete() {
    // 600ms covers match pop + fall animations
    Timer(const Duration(milliseconds: 600), () {
      if (_isWinConditionMet()) {
        phase = GamePhase.levelComplete;
      } else if (movesLeft <= 0) {
        phase = GamePhase.gameOver;
      } else {
        phase = GamePhase.idle;
        if (_finder.findHint() == null) _shuffleBoard();
      }
      notifyListeners();
    });
  }

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

  bool _isWinConditionMet() {
    switch (config.goalType) {
      case GoalType.score:
        return score >= config.targetScore;
      case GoalType.collect:
        return collectGoals.every((g) => g.isComplete);
      case GoalType.clear:
        return score >= config.targetScore;
    }
  }

  // ── Hint & shuffle ─────────────────────────────────────────────────────────

  void requestHint() {
    if (phase != GamePhase.idle) return;
    hint = _finder.findHint();
    notifyListeners();
  }

  void _shuffleBoard() {
    final types = <TileType>[];
    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        if (grid.get(r, c).isNormal) types.add(grid.get(r, c).type);
      }
    }
    types.shuffle();
    int idx = 0;
    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        if (grid.get(r, c).isNormal) grid.cells[r][c].type = types[idx++];
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

  void addMoves(int count) {
    movesLeft += count;
    notifyListeners();
  }

  // ── Computed ───────────────────────────────────────────────────────────────

  bool get isComplete => phase == GamePhase.levelComplete;
  bool get isGameOver => phase == GamePhase.gameOver;
  double get scoreProgress => (score / config.targetScore).clamp(0.0, 1.0);

  int get stars {
    if (score >= config.targetScore * 1.5) return 3;
    if (score >= config.targetScore * 1.2) return 2;
    if (score >= config.targetScore) return 1;
    return 0;
  }
}
