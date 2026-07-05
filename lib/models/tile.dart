import 'tile_type.dart';

class Tile {
  int row;
  int col;
  TileType type;
  TileState state;

  /// Used for fall animation — how many rows this tile needs to drop
  int fallDistance;

  Tile({
    required this.row,
    required this.col,
    required this.type,
    this.state = TileState.idle,
    this.fallDistance = 0,
  });

  Tile copyWith({
    int? row,
    int? col,
    TileType? type,
    TileState? state,
    int? fallDistance,
  }) {
    return Tile(
      row: row ?? this.row,
      col: col ?? this.col,
      type: type ?? this.type,
      state: state ?? this.state,
      fallDistance: fallDistance ?? this.fallDistance,
    );
  }

  bool get isEmpty => type.isEmpty;
  bool get isNormal => type.isNormal;
  bool get isSpecial => type.isSpecial;

  @override
  String toString() => 'Tile($row,$col) ${type.name}';
}
