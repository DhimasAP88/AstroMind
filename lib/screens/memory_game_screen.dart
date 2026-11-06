import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/difficulty.dart';
import '../widgets/game_hud_bar.dart';

class MemoryGameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final int currentHighScore;

  const MemoryGameScreen({
    super.key,
    required this.difficulty,
    required this.currentHighScore,
  });

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final Random _random = Random();
  late int _gridDimension;
  late int _sequenceLength;

  List<int> _targetSequence = [];
  final List<int> _playerInput = [];
  int? _activeHighlightedTile;
  bool _isShowingPattern = false;

  int _round = 1;
  final int _maxRounds = 4;
  int _score = 0;
  String _statusMessage = 'Perhatikan urutan panel yang menyala!';

  @override
  void initState() {
    super.initState();
    _configureDifficulty();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startNewRound());
  }

  void _configureDifficulty() {
    switch (widget.difficulty) {
      case Difficulty.easy:
        _gridDimension = 3; // Grid 3x3
        _sequenceLength = 3;
        break;
      case Difficulty.medium:
        _gridDimension = 4; // Grid 4x4
        _sequenceLength = 4;
        break;
      case Difficulty.hard:
        _gridDimension = 4; // Grid 4x4 dengan urutan lebih panjang & cepat
        _sequenceLength = 6;
        break;
    }
  }

  Future<void> _startNewRound() async {
    if (!mounted) return;
    setState(() {
      _isShowingPattern = true;
      _playerInput.clear();
      _targetSequence = List.generate(
        _sequenceLength + (_round - 1),
        (_) => _random.nextInt(_gridDimension * _gridDimension),
      );
      _statusMessage = '👀 Hafalkan urutan cahaya... (Ronde $_round/$_maxRounds)';
    });

    await Future.delayed(const Duration(milliseconds: 700));

    final int flashDuration =
        widget.difficulty == Difficulty.hard ? 420 : 650;

    for (final tileIndex in _targetSequence) {
      if (!mounted) return;
      setState(() => _activeHighlightedTile = tileIndex);
      HapticFeedback.selectionClick();
      await Future.delayed(Duration(milliseconds: flashDuration));

      if (!mounted) return;
      setState(() => _activeHighlightedTile = null);
      await Future.delayed(const Duration(milliseconds: 220));
    }

    if (!mounted) return;
    setState(() {
      _isShowingPattern = false;
      _statusMessage =
          'Giliranmu! Ketuk ${_targetSequence.length} panel sesuai urutan!';
    });
  }

  void _onTileTapped(int index) {
    if (_isShowingPattern) return;

    HapticFeedback.lightImpact();
    final int currentStep = _playerInput.length;

    if (index == _targetSequence[currentStep]) {
      setState(() {
        _playerInput.add(index);
        _activeHighlightedTile = index;
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _activeHighlightedTile = null);
      });

      if (_playerInput.length == _targetSequence.length) {
        final int earned = 30 * widget.difficulty.xpMultiplier;
        setState(() {
          _score += earned;
          _statusMessage = '🌟 Sempurna! +$earned Kristal Energi!';
        });

        if (_round >= _maxRounds) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (!mounted) return;
            showMissionResultDialog(
              context: context,
              title: 'Matriks Memori Selesai!',
              score: _score,
              previousHighScore: widget.currentHighScore,
              difficulty: widget.difficulty,
            );
          });
        } else {
          _round++;
          Future.delayed(const Duration(milliseconds: 900), _startNewRound);
        }
      }
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _statusMessage =
            '🔄 Urutan kurang tepat. Mari kita lihat polanya sekali lagi!';
      });
      Future.delayed(const Duration(milliseconds: 1000), _startNewRound);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalTiles = _gridDimension * _gridDimension;

    return Scaffold(
      appBar: AppBar(
        title: Text('Matriks Memori (${widget.difficulty.label})'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ronde: $_round / $_maxRounds',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '🏆 Rekor: ${widget.currentHighScore}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '💎 $_score',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFEA00),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2238),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9100),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalTiles,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridDimension,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final bool isLit = _activeHighlightedTile == index;
                        return GestureDetector(
                          onTap: () => _onTileTapped(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isLit
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF1E2942),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isLit
                                    ? Colors.white
                                    : const Color(0xFF00E5FF)
                                        .withValues(alpha: 0.35),
                                width: isLit ? 3 : 1.5,
                              ),
                              boxShadow: isLit
                                  ? [
                                      const BoxShadow(
                                        color: Color(0xFF00E5FF),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                        );
                      },
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
}
