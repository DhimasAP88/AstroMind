import 'dart:math';
import 'package:flutter/material.dart';
import '../models/difficulty.dart';

/// Hasil kembalian dari setiap sesi mini-game.
class MissionOutcome {
  final int earnedShards;
  final int rawScore;

  const MissionOutcome({
    required this.earnedShards,
    required this.rawScore,
  });
}

/// Bar HUD di bagian atas layar permainan (Timer, Streak, dan Skor).
class GameHudBar extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final int score;
  final int streak;
  final int highScore;

  const GameHudBar({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.score,
    required this.streak,
    required this.highScore,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '⏱️ $remainingSeconds dtk',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            if (streak >= 2)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔥 Streak $streak×',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                '🏆 Rekor: $highScore',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(
              '💎 $score',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF00E5FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.3 ? const Color(0xFF00E5FF) : const Color(0xFFFF5252),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialog hasil akhir misi dengan indikator rekor baru (High Score).
Future<void> showMissionResultDialog({
  required BuildContext context,
  required String title,
  required int score,
  required int previousHighScore,
  required Difficulty difficulty,
}) async {
  // Apresiasi ramah anak: selalu berikan minimal 20 Kristal Energi atas usaha menyelesaikan misi
  final int finalReward = max(20, score);
  final bool isNewHighScore = finalReward > previousHighScore;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1A2238),
        shape: RoundedCornerShape(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: difficulty.color, width: 2),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐⭐⭐', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            if (isNewHighScore)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEA00).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFEA00)),
                ),
                child: const Text(
                  '🏆 REKOR TERTINGGI BARU!',
                  style: TextStyle(
                    color: Color(0xFFFFEA00),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            Text(
              'Mode: ${difficulty.label} (${difficulty.ageRange})',
              style: TextStyle(
                color: difficulty.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '+$finalReward 💎',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFF00E5FF),
              ),
            ),
            const Text(
              'Kristal Energi Berhasil Disimpan!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedCornerShape(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(
                MissionOutcome(earnedShards: finalReward, rawScore: score),
              );
            },
            child: const Text(
              'SIMPAN & KEMBALI',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ],
      );
    },
  );
}
