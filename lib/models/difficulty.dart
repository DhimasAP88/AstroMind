import 'package:flutter/material.dart';

/// Enum tingkat kesulitan (Easy, Medium, Hard) untuk rentang usia 7 - 15 tahun.
enum Difficulty {
  easy(
    id: 'easy',
    label: 'EASY',
    ageRange: '7 - 9 Tahun',
    color: Color(0xFF00E676),
    timeSeconds: 45,
    xpMultiplier: 1,
  ),
  medium(
    id: 'medium',
    label: 'MEDIUM',
    ageRange: '10 - 12 Tahun',
    color: Color(0xFFFFEA00),
    timeSeconds: 35,
    xpMultiplier: 2,
  ),
  hard(
    id: 'hard',
    label: 'HARD',
    ageRange: '13 - 15 Tahun',
    color: Color(0xFFFF5252),
    timeSeconds: 25,
    xpMultiplier: 3,
  );

  final String id;
  final String label;
  final String ageRange;
  final Color color;
  final int timeSeconds;
  final int xpMultiplier;

  const Difficulty({
    required this.id,
    required this.label,
    required this.ageRange,
    required this.color,
    required this.timeSeconds,
    required this.xpMultiplier,
  });

  static Difficulty fromId(String? id) {
    return Difficulty.values.firstWhere(
      (d) => d.id == id,
      orElse: () => Difficulty.easy,
    );
  }
}

/// Jenis modul latihan kognitif utama.
enum GameModule {
  focus('focus', 'Radar Fokus'),
  math('math', 'Reaktor Numerik'),
  memory('memory', 'Matriks Memori');

  final String id;
  final String title;
  const GameModule(this.id, this.title);
}
