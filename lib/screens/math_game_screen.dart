import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/difficulty.dart';
import '../widgets/game_hud_bar.dart';

class MathGameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final int currentHighScore;

  const MathGameScreen({
    super.key,
    required this.difficulty,
    required this.currentHighScore,
  });

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  final Random _random = Random();
  Timer? _timer;
  late int _remainingSeconds;
  int _score = 0;
  int _streak = 0;

  String _equationText = '';
  int _correctAnswer = 0;
  List<int> _choices = [];
  String _feedback = 'Seimbangkan energi reaktor dengan jawaban tepat!';

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.difficulty.timeSeconds;
    _generateMathProblem();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        showMissionResultDialog(
          context: context,
          title: 'Reaktor Numerik Selesai!',
          score: _score,
          previousHighScore: widget.currentHighScore,
          difficulty: widget.difficulty,
        );
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _generateMathProblem() {
    int a, b, c;
    switch (widget.difficulty) {
      case Difficulty.easy:
        // Usia 7-9: Penjumlahan & Pengurangan dasar
        a = _random.nextInt(15) + 5;
        b = _random.nextInt(10) + 1;
        if (_random.nextBool()) {
          _equationText = '$a + $b = ?';
          _correctAnswer = a + b;
        } else {
          _equationText = '$a - $b = ?';
          _correctAnswer = a - b;
        }
        break;

      case Difficulty.medium:
        // Usia 10-12: Perkalian & Operasi Campuran 2 Langkah
        a = _random.nextInt(9) + 3;
        b = _random.nextInt(8) + 2;
        if (_random.nextBool()) {
          _equationText = '$a × $b = ?';
          _correctAnswer = a * b;
        } else {
          c = _random.nextInt(15) + 5;
          _equationText = '($a × 2) + $c = ?';
          _correctAnswer = (a * 2) + c;
        }
        break;

      case Difficulty.hard:
        // Usia 13-15: Operasi 3 Suku, Kuadrat & Bilangan Negatif
        a = _random.nextInt(10) + 4;
        b = _random.nextInt(7) + 3;
        c = _random.nextInt(20) + 5;
        if (_random.nextBool()) {
          _equationText = '($a × $b) - $c = ?';
          _correctAnswer = (a * b) - c;
        } else {
          _equationText = '($a² - $c) + $b = ?';
          _correctAnswer = (a * a - c) + b;
        }
        break;
    }

    final Set<int> optionSet = {_correctAnswer};
    while (optionSet.length < 4) {
      final int offset =
          (_random.nextInt(7) + 1) * (_random.nextBool() ? 1 : -1);
      optionSet.add(_correctAnswer + offset);
    }
    _choices = optionSet.toList()..shuffle();
  }

  void _submitAnswer(int selected) {
    setState(() {
      if (selected == _correctAnswer) {
        HapticFeedback.lightImpact();
        _streak++;
        final int points =
            (12 + (_streak * 2)) * widget.difficulty.xpMultiplier;
        _score += points;
        _feedback = '⚡ Tepat! +$points Kristal Energi (Streak $_streak×)';
      } else {
        HapticFeedback.vibrate();
        _streak = 0;
        _feedback = '💡 Jawaban tadi adalah $_correctAnswer. Ayo lanjut!';
      }
      _generateMathProblem();
    });
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
        title: Text('Reaktor Numerik (${widget.difficulty.label})'),
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
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2238),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF00E676), width: 2),
                ),
                child: Text(
                  _equationText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _feedback,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const Spacer(),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 2.1,
                physics: const NeverScrollableScrollPhysics(),
                children: _choices.map((choice) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF263238),
                      foregroundColor: Colors.white,
                      shape: RoundedCornerShape(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF00E676),
                        width: 2,
                      ),
                    ),
                    onPressed: () => _submitAnswer(choice),
                    child: Text(
                      '$choice',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
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
