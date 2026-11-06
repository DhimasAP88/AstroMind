import 'package:shared_preferences/shared_preferences.dart';
import '../models/difficulty.dart';

/// Model data progres pemain yang disimpan secara permanen (offline) di perangkat.
class PlayerStats {
  final int totalEnergyShards;
  final int missionsCompleted;
  final Difficulty lastSelectedDifficulty;
  final Map<String, int> highScores;

  const PlayerStats({
    required this.totalEnergyShards,
    required this.missionsCompleted,
    required this.lastSelectedDifficulty,
    required this.highScores,
  });

  /// Pangkat Kadet berdasarkan akumulasi Kristal Energi.
  String get cadetRank {
    if (totalEnergyShards < 150) return '🚀 Kadet Pemula (Rookie)';
    if (totalEnergyShards < 400) return '🛸 Penjelajah Bintang (Explorer)';
    if (totalEnergyShards < 800) return '⚡ Kapten Armada (Captain)';
    return '🌌 Komandan Galaksi (Commander)';
  }

  /// Mendapatkan skor tertinggi berdasarkan jenis game dan tingkat kesulitan.
  int getHighScore(GameModule module, Difficulty difficulty) {
    final key = '${module.id}_${difficulty.id}';
    return highScores[key] ?? 0;
  }
}

/// Service penyimpanan lokal 100% offline menggunakan SharedPreferences.
class StorageService {
  static const String _keyTotalShards = 'astromind_total_shards';
  static const String _keyMissionsCount = 'astromind_missions_count';
  static const String _keyLastDifficulty = 'astromind_last_difficulty';
  static const String _prefixHighScore = 'astromind_highscore_';

  /// Memuat seluruh data progres dan rekor skor tertinggi dari penyimpanan lokal.
  Future<PlayerStats> loadPlayerStats() async {
    final prefs = await SharedPreferences.getInstance();
    final totalShards = prefs.getInt(_keyTotalShards) ?? 0;
    final missionsCount = prefs.getInt(_keyMissionsCount) ?? 0;
    final lastDiffId = prefs.getString(_keyLastDifficulty);

    final Map<String, int> highScores = {};
    for (final module in GameModule.values) {
      for (final diff in Difficulty.values) {
        final key = '${module.id}_${diff.id}';
        highScores[key] = prefs.getInt('$_prefixHighScore$key') ?? 0;
      }
    }

    return PlayerStats(
      totalEnergyShards: totalShards,
      missionsCompleted: missionsCount,
      lastSelectedDifficulty: Difficulty.fromId(lastDiffId),
      highScores: highScores,
    );
  }

  /// Menyimpan pilihan tingkat kesulitan terakhir pemain.
  Future<void> saveSelectedDifficulty(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastDifficulty, difficulty.id);
  }

  /// Menyimpan hasil misi, menambah total kristal energi, dan memperbarui High Score.
  /// Mengembalikan `true` jika pemain mencetak rekor High Score baru.
  Future<bool> recordMissionResult({
    required GameModule module,
    required Difficulty difficulty,
    required int scoreEarned,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final currentShards = prefs.getInt(_keyTotalShards) ?? 0;
    final currentMissions = prefs.getInt(_keyMissionsCount) ?? 0;

    await prefs.setInt(_keyTotalShards, currentShards + scoreEarned);
    await prefs.setInt(_keyMissionsCount, currentMissions + 1);

    final scoreKey = '$_prefixHighScore${module.id}_${difficulty.id}';
    final previousBest = prefs.getInt(scoreKey) ?? 0;

    if (scoreEarned > previousBest) {
      await prefs.setInt(scoreKey, scoreEarned);
      return true;
    }
    return false;
  }

  /// Mereset seluruh data progres pemain (opsional untuk pengujian/reset profil).
  Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
