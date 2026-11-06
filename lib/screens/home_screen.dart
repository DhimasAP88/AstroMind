import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/difficulty.dart';
import '../services/storage_service.dart';
import '../widgets/game_hud_bar.dart';
import 'focus_game_screen.dart';
import 'math_game_screen.dart';
import 'memory_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();

  Difficulty _selectedDifficulty = Difficulty.easy;
  PlayerStats _stats = const PlayerStats(
    totalEnergyShards: 0,
    missionsCompleted: 0,
    lastSelectedDifficulty: Difficulty.easy,
    highScores: {},
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    final loaded = await _storage.loadPlayerStats();
    if (!mounted) return;
    setState(() {
      _stats = loaded;
      _selectedDifficulty = loaded.lastSelectedDifficulty;
      _isLoading = false;
    });
  }

  Future<void> _changeDifficulty(Difficulty diff) async {
    HapticFeedback.selectionClick();
    setState(() => _selectedDifficulty = diff);
    await _storage.saveSelectedDifficulty(diff);
  }

  Future<void> _launchMission(GameModule module, Widget screen) async {
    HapticFeedback.mediumImpact();
    final outcome = await Navigator.push<MissionOutcome>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (outcome != null) {
      await _storage.recordMissionResult(
        module: module,
        difficulty: _selectedDifficulty,
        scoreEarned: outcome.earnedShards,
      );
      await _loadSavedProgress();
    }
  }

  Future<void> _confirmResetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2238),
        title: const Text('Reset Data Latihan?'),
        content: const Text(
          'Seluruh Kristal Energi, Pangkat Kadet, dan Rekor Skor Tertinggi yang tersimpan di perangkat ini akan diatur ulang ke 0.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset Sekarang'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.resetAllProgress();
      await _loadSavedProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kartu Status Pemain (Tersimpan Permanen dengan SharedPreferences)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF283593), Color(0xFF1A237E)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        const Text(
                          'ASTROMIND ACADEMY',
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Reset Progres Lokal',
                          onPressed: _confirmResetProgress,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _stats.cadetRank,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatChip(
                          '💎 ${_stats.totalEnergyShards}',
                          'Total Kristal (Tersimpan)',
                        ),
                        _buildStatChip(
                          '🎯 ${_stats.missionsCompleted}',
                          'Misi Selesai',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pemilih Tingkat Kesulitan (Easy, Medium, Hard)
              const Text(
                '1. PILIH TINGKAT KESULITAN:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: Difficulty.values.map((diff) {
                  final bool isSelected = _selectedDifficulty == diff;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => _changeDifficulty(diff),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? diff.color.withValues(alpha: 0.25)
                                : const Color(0xFF1A2238),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? diff.color : Colors.white24,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                diff.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: diff.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                diff.ageRange,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Daftar 3 Mini-Game Utama beserta High Score per Tingkat Kesulitan
              const Text(
                '2. PILIH MISI LATIHAN KOGNITIF:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),

              _buildMissionCard(
                icon: '🎯',
                title: 'Radar Fokus',
                subtitle: _selectedDifficulty == Difficulty.hard
                    ? 'Tantangan Stroop: Teks vs Warna Tinta'
                    : 'Konsentrasi Visual & Kecepatan Reaksi',
                highScore: _stats.getHighScore(
                  GameModule.focus,
                  _selectedDifficulty,
                ),
                accentColor: const Color(0xFF00E5FF),
                onTap: () => _launchMission(
                  GameModule.focus,
                  FocusGameScreen(
                    difficulty: _selectedDifficulty,
                    currentHighScore: _stats.getHighScore(
                      GameModule.focus,
                      _selectedDifficulty,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _buildMissionCard(
                icon: '⚡',
                title: 'Reaktor Numerik',
                subtitle: _selectedDifficulty == Difficulty.easy
                    ? 'Penjumlahan & Pengurangan Cepat'
                    : 'Perkalian, Operasi Campuran & Logika Hitung',
                highScore: _stats.getHighScore(
                  GameModule.math,
                  _selectedDifficulty,
                ),
                accentColor: const Color(0xFF00E676),
                onTap: () => _launchMission(
                  GameModule.math,
                  MathGameScreen(
                    difficulty: _selectedDifficulty,
                    currentHighScore: _stats.getHighScore(
                      GameModule.math,
                      _selectedDifficulty,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _buildMissionCard(
                icon: '🧠',
                title: 'Matriks Memori',
                subtitle: 'Ingat dan Ulangi Urutan Panel Energi Menyala',
                highScore: _stats.getHighScore(
                  GameModule.memory,
                  _selectedDifficulty,
                ),
                accentColor: const Color(0xFFFF9100),
                onTap: () => _launchMission(
                  GameModule.memory,
                  MemoryGameScreen(
                    difficulty: _selectedDifficulty,
                    currentHighScore: _stats.getHighScore(
                      GameModule.memory,
                      _selectedDifficulty,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard({
    required String icon,
    required String title,
    required String subtitle,
    required int highScore,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2238),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '🏆 Rekor ${_selectedDifficulty.label}: $highScore 💎',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _selectedDifficulty.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill, color: accentColor, size: 36),
          ],
        ),
      ),
    );
  }
}
