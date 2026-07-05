import '../models/tile_type.dart';

/// Defines the win condition type for a level
enum GoalType {
  score,        // Reach target score
  collect,      // Collect specific tile types
  clear,        // Clear all tiles in marked cells
}

/// A single collection goal (e.g. collect 20 red tiles)
class CollectGoal {
  final TileType tileType;
  final int required;
  int collected;

  CollectGoal({
    required this.tileType,
    required this.required,
    this.collected = 0,
  });

  // const-friendly factory used in static level definitions
  const CollectGoal.fixed({
    required this.tileType,
    required this.required,
  }) : collected = 0;

  bool get isComplete => collected >= required;
  int get remaining => (required - collected).clamp(0, required);

  CollectGoal copyWith({int? collected}) =>
      CollectGoal(tileType: tileType, required: required, collected: collected ?? this.collected);
}

/// Full configuration for one level
class LevelConfig {
  final int levelNumber;
  final int moves;
  final int targetScore;
  final GoalType goalType;
  final List<CollectGoal> collectGoals; // used when goalType == collect
  final int gridRows;
  final int gridCols;
  final String? storyText;       // Story blurb shown before level
  final String? backgroundAsset; // asset path for background

  const LevelConfig({
    required this.levelNumber,
    required this.moves,
    required this.targetScore,
    this.goalType = GoalType.score,
    this.collectGoals = const [],
    this.gridRows = 8,
    this.gridCols = 7,
    this.storyText,
    this.backgroundAsset,
  });
}

/// All levels in the game
class LevelRegistry {
  static const List<LevelConfig> levels = [
    // ── World 1 ──────────────────────────────────────────────────────────────
    LevelConfig(
      levelNumber: 1,
      moves: 25,
      targetScore: 1000,
      goalType: GoalType.score,
      storyText: 'Help the king escape the dungeon!',
      backgroundAsset: 'assets/images/bg_dungeon.png',
    ),
    LevelConfig(
      levelNumber: 2,
      moves: 22,
      targetScore: 1500,
      goalType: GoalType.collect,
      collectGoals: [
        CollectGoal.fixed(tileType: TileType.red, required: 15),
        CollectGoal.fixed(tileType: TileType.yellow, required: 10),
      ],
      backgroundAsset: 'assets/images/bg_dungeon.png',
    ),
    LevelConfig(
      levelNumber: 3,
      moves: 20,
      targetScore: 2000,
      goalType: GoalType.score,
      backgroundAsset: 'assets/images/bg_castle.png',
    ),
    LevelConfig(
      levelNumber: 4,
      moves: 18,
      targetScore: 2500,
      goalType: GoalType.collect,
      collectGoals: [
        CollectGoal.fixed(tileType: TileType.green, required: 20),
        CollectGoal.fixed(tileType: TileType.blue, required: 15),
      ],
      backgroundAsset: 'assets/images/bg_castle.png',
    ),
    LevelConfig(
      levelNumber: 5,
      moves: 20,
      targetScore: 3000,
      goalType: GoalType.score,
      storyText: 'Clear the path to the royal garden!',
      backgroundAsset: 'assets/images/bg_garden.png',
    ),
    // ── World 2 ──────────────────────────────────────────────────────────────
    LevelConfig(
      levelNumber: 6,
      moves: 18,
      targetScore: 3500,
      goalType: GoalType.score,
      backgroundAsset: 'assets/images/bg_garden.png',
    ),
    LevelConfig(
      levelNumber: 7,
      moves: 16,
      targetScore: 4000,
      goalType: GoalType.collect,
      collectGoals: [
        CollectGoal.fixed(tileType: TileType.purple, required: 25),
      ],
      backgroundAsset: 'assets/images/bg_tower.png',
    ),
    LevelConfig(
      levelNumber: 8,
      moves: 20,
      targetScore: 4500,
      goalType: GoalType.score,
      backgroundAsset: 'assets/images/bg_tower.png',
    ),
    LevelConfig(
      levelNumber: 9,
      moves: 18,
      targetScore: 5000,
      goalType: GoalType.collect,
      collectGoals: [
        CollectGoal.fixed(tileType: TileType.red, required: 20),
        CollectGoal.fixed(tileType: TileType.yellow, required: 20),
        CollectGoal.fixed(tileType: TileType.blue, required: 20),
      ],
      backgroundAsset: 'assets/images/bg_tower.png',
    ),
    LevelConfig(
      levelNumber: 10,
      moves: 22,
      targetScore: 6000,
      goalType: GoalType.score,
      storyText: 'The king reaches the throne room!',
      backgroundAsset: 'assets/images/bg_throne.png',
    ),
  ];

  static LevelConfig get(int levelNumber) {
    final idx = levelNumber - 1;
    if (idx < 0 || idx >= levels.length) {
      // Generate a procedural level for anything beyond defined levels
      return _generateLevel(levelNumber);
    }
    return levels[idx];
  }

  static LevelConfig _generateLevel(int n) {
    return LevelConfig(
      levelNumber: n,
      moves: (20 - (n ~/ 5)).clamp(12, 25),
      targetScore: 1000 + (n * 600),
      goalType: n.isEven ? GoalType.collect : GoalType.score,
      collectGoals: n.isEven
          ? [CollectGoal(tileType: TileType.values[n % 5], required: 15 + n)]
          : [],
    );
  }

  static int get totalLevels => levels.length;
}
