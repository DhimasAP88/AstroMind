import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/difficulty.dart';
import '../widgets/game_hud_bar.dart';

class ColorItem {
  final String name;
  final Color color;
  const ColorItem(this.name, this.color);
}

class FocusGameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final int currentHighScore;

  const FocusGameScreen({
    super.key,
    required this.difficulty,
    required this.currentHighScore,
  });

  @override
  State<FocusGameScreen> createState() => _FocusGameScreenState();
}

class _FocusGameScreenState extends State<FocusGameScreen> {
  static const List<ColorItem> _palette = [
    ColorItem('MERAH', Color(0xFFFF5252)),
    ColorItem('BIRU', Color(0xFF448AFF)),
    ColorItem('HIJAU', Color(0xFF00E676)),
    ColorItem('KUNING', Color(0xFFFFEA00)),
  ];

  final Random _random = Random();
  Timer? _timer;
  late int _remainingSeconds;
  int _score = 0;
  int _streak = 0;

  late ColorItem _displayedWord;
  late ColorItem _displayedInk;
  late bool _matchByInkColor;
  String _feedbackText = 'Fokus pada instruksi di bawah!';

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.difficulty.timeSeconds;
    _generateQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _finishGame();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _generateQuestion() {
    _displayedWord = _palette[_random.nextInt(_palette.length)];

    if (widget.difficulty == Difficulty.easy) {
      // Easy (7-9 tahun): Warna tinta dan teks kata selaras
      _displayedInk = _displayedWord;
      _matchByInkColor = true;
    } else if (widget.difficulty == Difficulty.medium) {
      // Medium (10-12 tahun): Warna tinta berbeda, fokus pada WARNA TINTA
      _displayedInk = _palette[_random.nextInt(_palette.length)];
      _matchByInkColor = true;
    } else {
      // Hard (13-15 tahun): Stroop Test penuh! Aturan berubah acak antara Teks vs Tinta
      _displayedInk = _palette[_random.nextInt(_palette.length)];
      _matchByInkColor = _random.nextBool();
    }
  }

  void _handleAnswer(ColorItem selected) {
    final ColorItem correctTarget =
        _matchByInkColor ? _displayedInk : _displayedWord;

    setState(() {
      if (selected.name == correctTarget.name) {
        HapticFeedback.lightImpact();
        _streak++;
        final int bonus = (_streak >= 3) ? 15 : 10;
        _score += bonus * widget.difficulty.xpMultiplier;
        _feedbackText = _streak >= 3
            ? '🔥 COMBO $_streak! +${bonus * widget.difficulty.xpMultiplier} Poin'
            : '✅ Tepat! Pertahankan fokusmu!';
      } else {
        HapticFeedback.vibrate();
        _streak = 0;
        _feedbackText =
            '⚠️ Hati-hati pengecoh! Perhatikan perintah (${_matchByInkColor ? "WARNA TINTA" : "TULISAN KATA"})';
      }
      _generateQuestion();
    });
  }

  void _finishGame() {
    showMissionResultDialog(
      context: context,
      title: 'Misi Radar Fokus Selesai!',
      score: _score,
      previousHighScore: widget.currentHighScore,
      difficulty: widget.difficulty,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radar Fokus (${widget.difficulty.label})'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GameHudBar(
                remainingSeconds: _remainingSeconds,
                totalSeconds: widget.difficulty.timeSeconds,
                score: _score,
                streak: _streak,
                highScore: widget.currentHighScore,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2238),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  _matchByInkColor
                      ? 'INSTRUKSI: Ketuk sesuai WARNA TINTA!'
                      : 'INSTRUKSI: Ketuk sesuai TULISAN KATA!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                height: 170,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF121829),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: Text(
                  _displayedWord.name,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: _displayedInk.color,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _feedbackText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const Spacer(),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 2.2,
                physics: const NeverScrollableScrollPhysics(),
                children: _palette.map((item) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2942),
                      foregroundColor: Colors.white,
                      shape: RoundedCornerShape(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      side: BorderSide(color: item.color, width: 2.5),
                    ),
                    onPressed: () => _handleAnswer(item),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(backgroundColor: item.color, radius: 10),
                        const SizedBox(width: 10),
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
