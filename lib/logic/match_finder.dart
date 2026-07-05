import '../models/grid.dart';
import '../models/tile.dart';
import '../models/tile_type.dart';

/// Represents a group of matched tiles
class MatchGroup {
  final List<Tile> tiles;
  final MatchShape shape;

  const MatchGroup({required this.tiles, required this.shape});

  int get length => tiles.length;

  /// The center tile — used to place a special tile after clearing
  Tile get center => tiles[tiles.length ~/ 2];
}

enum MatchShape {
  line3,    // 3 in a row/col
  line4,    // 4 in a row/col → Rocket
  line5,    // 5 in a row/col → Rainbow
  lShape,   // L or T shape   → Bomb
  tShape,
}

class MatchFinder {
  final Grid grid;

  MatchFinder(this.grid);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Find all matches currently on the grid.
  List<MatchGroup> findAllMatches() {
    final groups = <MatchGroup>[];
    final visited = <String>{};

    // Horizontal scan
    for (int r = 0; r < grid.rows; r++) {
      int c = 0;
      while (c < grid.cols) {
        final run = _horizontalRun(r, c);
        if (run.length >= 3) {
          final key = _groupKey(run);
          if (!visited.contains(key)) {
            visited.add(key);
            groups.add(MatchGroup(tiles: run, shape: _shapeForLength(run.length)));
          }
          c += run.length;
        } else {
          c++;
        }
      }
    }

    // Vertical scan
    for (int c = 0; c < grid.cols; c++) {
      int r = 0;
      while (r < grid.rows) {
        final run = _verticalRun(r, c);
        if (run.length >= 3) {
          final key = _groupKey(run);
          if (!visited.contains(key)) {
            visited.add(key);
            groups.add(MatchGroup(tiles: run, shape: _shapeForLength(run.length)));
          }
          r += run.length;
        } else {
          r++;
        }
      }
    }

    // Merge overlapping H+V runs into L/T shapes
    return _mergeOverlapping(groups);
  }

  /// Returns true if swapping these two tiles would create at least one match.
  bool wouldMatch(int r1, int c1, int r2, int c2) {
    grid.swap(r1, c1, r2, c2);
    final has = findAllMatches().isNotEmpty;
    grid.swap(r1, c1, r2, c2); // revert
    return has;
  }

  /// Finds a valid move hint. Returns null if no moves available (deadlock).
  ({int r1, int c1, int r2, int c2})? findHint() {
    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        // Try swap right
        if (c + 1 < grid.cols && wouldMatch(r, c, r, c + 1)) {
          return (r1: r, c1: c, r2: r, c2: c + 1);
        }
        // Try swap down
        if (r + 1 < grid.rows && wouldMatch(r, c, r + 1, c)) {
          return (r1: r, c1: c, r2: r + 1, c2: c);
        }
      }
    }
    return null;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  List<Tile> _horizontalRun(int r, int startC) {
    final first = grid.get(r, startC);
    if (!first.type.isNormal) return [first];
    final run = <Tile>[first];
    for (int c = startC + 1; c < grid.cols; c++) {
      final t = grid.get(r, c);
      if (t.type == first.type) {
        run.add(t);
      } else {
        break;
      }
    }
    return run;
  }

  List<Tile> _verticalRun(int startR, int c) {
    final first = grid.get(startR, c);
    if (!first.type.isNormal) return [first];
    final run = <Tile>[first];
    for (int r = startR + 1; r < grid.rows; r++) {
      final t = grid.get(r, c);
      if (t.type == first.type) {
        run.add(t);
      } else {
        break;
      }
    }
    return run;
  }

  String _groupKey(List<Tile> tiles) =>
      tiles.map((t) => '${t.row},${t.col}').join('|');

  MatchShape _shapeForLength(int len) {
    if (len >= 5) return MatchShape.line5;
    if (len == 4) return MatchShape.line4;
    return MatchShape.line3;
  }

  /// Merges groups that share at least one tile into combined L/T shapes.
  List<MatchGroup> _mergeOverlapping(List<MatchGroup> groups) {
    if (groups.length < 2) return groups;

    final merged = <MatchGroup>[];
    final used = List.filled(groups.length, false);

    for (int i = 0; i < groups.length; i++) {
      if (used[i]) continue;
      final tilesA = Set<String>.from(
          groups[i].tiles.map((t) => '${t.row},${t.col}'));
      var combinedTiles = List<Tile>.from(groups[i].tiles);
      bool didMerge = false;

      for (int j = i + 1; j < groups.length; j++) {
        if (used[j]) continue;
        final tilesB = groups[j].tiles.map((t) => '${t.row},${t.col}').toSet();
        if (tilesA.intersection(tilesB).isNotEmpty) {
          // Merge
          for (final t in groups[j].tiles) {
            if (!tilesA.contains('${t.row},${t.col}')) {
              combinedTiles.add(t);
              tilesA.add('${t.row},${t.col}');
            }
          }
          used[j] = true;
          didMerge = true;
        }
      }

      merged.add(MatchGroup(
        tiles: combinedTiles,
        shape: didMerge ? MatchShape.lShape : groups[i].shape,
      ));
      used[i] = true;
    }

    return merged;
  }
}
