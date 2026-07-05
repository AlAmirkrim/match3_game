enum TileType {
  red,
  green,
  yellow,
  blue,
  purple,
  // Special tiles
  rocketH,   // Rocket clears entire row
  rocketV,   // Rocket clears entire column
  bomb,      // Bomb clears 3x3 area
  rainbow,   // Rainbow clears all tiles of one color
  empty,
}

enum TileState {
  idle,
  selected,
  matched,
  falling,
  spawning,
}

extension TileTypeExtension on TileType {
  bool get isNormal =>
      this == TileType.red ||
      this == TileType.green ||
      this == TileType.yellow ||
      this == TileType.blue ||
      this == TileType.purple;

  bool get isSpecial =>
      this == TileType.rocketH ||
      this == TileType.rocketV ||
      this == TileType.bomb ||
      this == TileType.rainbow;

  bool get isEmpty => this == TileType.empty;

  /// Returns true if two tiles can match (same normal color)
  bool matches(TileType other) {
    if (!isNormal || !other.isNormal) return false;
    return this == other;
  }

  String get emoji {
    switch (this) {
      case TileType.red:
        return '🟥';
      case TileType.green:
        return '🌿';
      case TileType.yellow:
        return '👑';
      case TileType.blue:
        return '🔵';
      case TileType.purple:
        return '🟣';
      case TileType.rocketH:
        return '🚀';
      case TileType.rocketV:
        return '🚀';
      case TileType.bomb:
        return '💣';
      case TileType.rainbow:
        return '🌈';
      case TileType.empty:
        return '  ';
    }
  }
}
