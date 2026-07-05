import 'dart:math';
import 'tile.dart';
import 'tile_type.dart';

class Grid {
  final int rows;
  final int cols;
  late List<List<Tile>> cells;
  final Random _random = Random();

  static const List<TileType> _normalTypes = [
    TileType.red,
    TileType.green,
    TileType.yellow,
    TileType.blue,
    TileType.purple,
  ];

  Grid({this.rows = 8, this.cols = 7}) {
    _initGrid();
  }

  // ── Initialisation ─────────────────────────────────────────────────────────

  void _initGrid() {
    cells = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => Tile(row: r, col: c, type: _safeRandomType(r, c)),
      ),
    );
  }

  /// Picks a random normal type that doesn't immediately form a match at (r,c).
  TileType _safeRandomType(int r, int c) {
    final available = List<TileType>.from(_normalTypes);
    available.shuffle(_random);
    for (final type in available) {
      if (!_wouldMatchAt(r, c, type)) return type;
    }
    return available.first; // fallback (very unlikely)
  }

  bool _wouldMatchAt(int r, int c, TileType type) {
    // Check horizontal — needs 2 already placed tiles to the left
    if (c >= 2 &&
        cells[r][c - 1].type == type &&
        cells[r][c - 2].type == type) {
      return true;
    }
    // Check vertical — needs 2 already placed tiles above
    if (r >= 2 &&
        cells[r - 1][c].type == type &&
        cells[r - 2][c].type == type) {
      return true;
    }
    return false;
  }

  // ── Accessors ──────────────────────────────────────────────────────────────

  Tile get(int r, int c) => cells[r][c];

  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  // ── Swap ───────────────────────────────────────────────────────────────────

  /// Swaps two adjacent tiles. Returns false if they are not adjacent.
  bool swap(int r1, int c1, int r2, int c2) {
    if (!_isAdjacent(r1, c1, r2, c2)) return false;
    final tmp = cells[r1][c1].type;
    cells[r1][c1].type = cells[r2][c2].type;
    cells[r2][c2].type = tmp;
    // Reset states
    cells[r1][c1].state = TileState.idle;
    cells[r2][c2].state = TileState.idle;
    return true;
  }

  bool _isAdjacent(int r1, int c1, int r2, int c2) {
    final dr = (r1 - r2).abs();
    final dc = (c1 - c2).abs();
    return (dr == 1 && dc == 0) || (dr == 0 && dc == 1);
  }

  // ── Spawn ──────────────────────────────────────────────────────────────────

  /// Fills all empty cells with new random tiles (top rows get fallDistance set).
  List<Tile> fillEmpty() {
    final spawned = <Tile>[];
    for (int c = 0; c < cols; c++) {
      int emptyCount = 0;
      for (int r = rows - 1; r >= 0; r--) {
        if (cells[r][c].isEmpty) emptyCount++;
      }
      // Fill from the top
      for (int r = 0; r < rows; r++) {
        if (cells[r][c].isEmpty) {
          cells[r][c].type = _randomNormalType();
          cells[r][c].state = TileState.spawning;
          cells[r][c].fallDistance = emptyCount;
          spawned.add(cells[r][c]);
        }
      }
    }
    return spawned;
  }

  TileType _randomNormalType() =>
      _normalTypes[_random.nextInt(_normalTypes.length)];

  // ── Place special tile ─────────────────────────────────────────────────────

  void placeSpecial(int r, int c, TileType special) {
    cells[r][c].type = special;
    cells[r][c].state = TileState.idle;
  }

  // ── Debug ──────────────────────────────────────────────────────────────────

  @override
  String toString() {
    final sb = StringBuffer();
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        sb.write(cells[r][c].type.emoji);
        sb.write(' ');
      }
      sb.writeln();
    }
    return sb.toString();
  }
}
