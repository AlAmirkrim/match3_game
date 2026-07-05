import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores one level's best result
class LevelResult {
  final int levelNumber;
  final int bestScore;
  final int stars;       // 0 = not played, 1-3
  final bool unlocked;

  const LevelResult({
    required this.levelNumber,
    required this.bestScore,
    required this.stars,
    required this.unlocked,
  });

  factory LevelResult.locked(int levelNumber) => LevelResult(
        levelNumber: levelNumber,
        bestScore: 0,
        stars: 0,
        unlocked: false,
      );

  factory LevelResult.fromJson(Map<String, dynamic> json) => LevelResult(
        levelNumber: json['levelNumber'] as int,
        bestScore: json['bestScore'] as int,
        stars: json['stars'] as int,
        unlocked: json['unlocked'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'bestScore': bestScore,
        'stars': stars,
        'unlocked': unlocked,
      };

  LevelResult copyWith({int? bestScore, int? stars, bool? unlocked}) =>
      LevelResult(
        levelNumber: levelNumber,
        bestScore: bestScore ?? this.bestScore,
        stars: stars ?? this.stars,
        unlocked: unlocked ?? this.unlocked,
      );
}

/// Manages persistent level progress using SharedPreferences
class LevelProgress {
  static const _key = 'level_progress';
  static LevelProgress? _instance;

  final Map<int, LevelResult> _results = {};

  LevelProgress._();

  static Future<LevelProgress> load() async {
    if (_instance != null) return _instance!;
    final lp = LevelProgress._();
    await lp._loadFromPrefs();
    _instance = lp;
    return lp;
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  LevelResult getLevel(int levelNumber) {
    return _results[levelNumber] ??
        LevelResult(
          levelNumber: levelNumber,
          bestScore: 0,
          stars: 0,
          unlocked: levelNumber == 1,
        );
  }

  bool isUnlocked(int levelNumber) => getLevel(levelNumber).unlocked;

  int starsFor(int levelNumber) => getLevel(levelNumber).stars;

  int get totalStars =>
      _results.values.fold(0, (sum, r) => sum + r.stars);

  int get highestUnlockedLevel {
    int max = 1;
    for (final r in _results.values) {
      if (r.unlocked && r.levelNumber > max) max = r.levelNumber;
    }
    return max;
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Records a level completion. Unlocks the next level.
  Future<void> recordCompletion({
    required int levelNumber,
    required int score,
    required int stars,
  }) async {
    final existing = getLevel(levelNumber);
    final newResult = existing.copyWith(
      bestScore: score > existing.bestScore ? score : existing.bestScore,
      stars: stars > existing.stars ? stars : existing.stars,
      unlocked: true,
    );
    _results[levelNumber] = newResult;

    // Unlock next level
    final next = levelNumber + 1;
    final nextExisting = getLevel(next);
    if (!nextExisting.unlocked) {
      _results[next] = nextExisting.copyWith(unlocked: true);
    }

    await _saveToPrefs();
  }

  Future<void> unlockAll() async {
    for (int i = 1; i <= 100; i++) {
      final existing = getLevel(i);
      if (!existing.unlocked) {
        _results[i] = existing.copyWith(unlocked: true);
      }
    }
    await _saveToPrefs();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      // First launch — unlock level 1
      _results[1] = LevelResult(
        levelNumber: 1,
        bestScore: 0,
        stars: 0,
        unlocked: true,
      );
      return;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    for (final item in list) {
      final r = LevelResult.fromJson(item as Map<String, dynamic>);
      _results[r.levelNumber] = r;
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _results.values.map((r) => r.toJson()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }
}
