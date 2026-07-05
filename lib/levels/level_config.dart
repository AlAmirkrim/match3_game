import '../models/tile_type.dart';

enum GoalType {
  score,
  collect,
  clear,
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

  bool get isComplete => collected >= required;
  int get remaining => (required - collected).clamp(0, required);
}

/// Full configuration for one level
class LevelConfig {
  final int levelNumber;
  final int moves;
  final int targetScore;
  final GoalType goalType;
  final List<CollectGoal> collectGoals;
  final int gridRows;
  final int gridCols;
  final String? storyText;
  final String? backgroundAsset;

  LevelConfig({
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

/// All levels in the game — نستخدم getter بدل static const عشان CollectGoal مش const
class LevelRegistry {
  static List<LevelConfig> get levels => [
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
        CollectGoal(tileType: TileType.red, required: 15),
        CollectGoal(tileType: TileType.yellow, required: 10),
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
        CollectGoal(tileType: TileType.green, required: 20),
        CollectGoal(tileType: TileType.blue, required: 15),
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
        CollectGoal(tileType: TileType.purple, required: 25),
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
        CollectGoal(tileType: TileType.red, required: 20),
        CollectGoal(tileType: TileType.yellow, required: 20),
        CollectGoal(tileType: TileType.blue, required: 20),
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
    if (idx >= 0 && idx < levels.length) return levels[idx];
    return LevelConfig(
      levelNumber: levelNumber,
      moves: (20 - (levelNumber ~/ 5)).clamp(12, 25),
      targetScore: 1000 + (levelNumber * 600),
      goalType: levelNumber.isEven ? GoalType.collect : GoalType.score,
      collectGoals: levelNumber.isEven
          ? [CollectGoal(tileType: TileType.values[levelNumber % 5], required: 15 + levelNumber)]
          : [],
    );
  }

  static int get totalLevels => 10;
}
