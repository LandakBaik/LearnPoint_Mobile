import 'dart:async';
import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_question_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_floating_island_scene_painter.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_option_card_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_top_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_power_star_button_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_power_up_bottom_sheet_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_progress_indicators_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_question_card_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_ready_dialog_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_result_dialog_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_space_background_painter.dart';

class QuizPlayScreen extends StatefulWidget {
  final String themeTitle;
  final int levelNumber;
  final Color themeColor;
  final List<QuizPlayQuestionModel>? customQuestions;

  const QuizPlayScreen({
    super.key,
    this.themeTitle = 'Geometri',
    this.levelNumber = 1,
    this.themeColor = const Color(0xFF4338CA),
    this.customQuestions,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxSecondsPerQuestion = 60;

  late final List<QuizPlayQuestionModel> _questions;
  late final AnimationController _floatController;

  Timer? _countdownTimer;
  Timer? _autoNextTimer;

  int _currentIndex = 0;
  int _remainingSeconds = _maxSecondsPerQuestion;
  int _gemsScore = 25;
  int _correctCount = 0;

  int? _selectedOptionIndex;
  bool _isAnswerLocked = false;
  bool _isQuizStarted = false;

  // State Power-Up (Bintang Kuning)
  int _power5050Remaining = 1;
  int _powerExtraTimeRemaining = 1;
  int _powerDoublePointsRemaining = 1;
  Set<int> _eliminatedOptions = {};
  bool _isDoublePointsActive = false;

  int get _totalPowersRemaining =>
      _power5050Remaining +
      _powerExtraTimeRemaining +
      _powerDoublePointsRemaining;

  @override
  void initState() {
    super.initState();
    _questions = widget.customQuestions ?? defaultQuizPlayQuestions;

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showAreYouReadyModal();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoNextTimer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _showAreYouReadyModal() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return QuizReadyDialogWidget(
          themeTitle: widget.themeTitle,
          levelNumber: widget.levelNumber,
          totalQuestions: _questions.length,
          maxSecondsPerQuestion: _maxSecondsPerQuestion,
          onCancel: () {
            Navigator.of(ctx).pop();
            Navigator.of(context).pop();
          },
          onStart: () {
            Navigator.of(ctx).pop();
            setState(() {
              _isQuizStarted = true;
            });
            _startQuestionTimer();
          },
        );
      },
    );
  }

  void _startQuestionTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = _maxSecondsPerQuestion;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _remainingSeconds = 0;
          _isAnswerLocked = true;
        });
        timer.cancel();
        _scheduleNextQuestion();
      }
    });
  }

  void _onSelectOption(int optionIndex) {
    if (!_isQuizStarted ||
        _isAnswerLocked ||
        _eliminatedOptions.contains(optionIndex)) {
      return;
    }

    _countdownTimer?.cancel();
    final currentQ = _questions[_currentIndex];
    final isCorrect = optionIndex == currentQ.correctIndex;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _isAnswerLocked = true;
      if (isCorrect) {
        final earned = _isDoublePointsActive
            ? currentQ.rewardGems * 2
            : currentQ.rewardGems;
        _gemsScore += earned;
        _correctCount++;
      }
    });

    _scheduleNextQuestion();
  }

  void _scheduleNextQuestion() {
    _autoNextTimer?.cancel();
    _autoNextTimer = Timer(const Duration(milliseconds: 1350), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedOptionIndex = null;
          _isAnswerLocked = false;
          _eliminatedOptions = {};
          _isDoublePointsActive = false;
        });
        _startQuestionTimer();
      } else {
        _showQuizResultModal();
      }
    });
  }

  void _usePower5050() {
    if (_power5050Remaining <= 0 || _eliminatedOptions.isNotEmpty) return;

    final currentQ = _questions[_currentIndex];
    final wrongIndices = List<int>.generate(currentQ.options.length, (i) => i)
        .where((i) => i != currentQ.correctIndex)
        .toList()
      ..shuffle();

    setState(() {
      _power5050Remaining--;
      _eliminatedOptions = wrongIndices.take(2).toSet();
    });
  }

  void _usePowerExtraTime() {
    if (_powerExtraTimeRemaining <= 0) return;

    setState(() {
      _powerExtraTimeRemaining--;
      _remainingSeconds += 15;
    });
  }

  void _usePowerDoublePoints() {
    if (_powerDoublePointsRemaining <= 0 || _isDoublePointsActive) return;

    setState(() {
      _powerDoublePointsRemaining--;
      _isDoublePointsActive = true;
    });
  }

  Future<void> _showPowerUpSheet() async {
    if (!_isQuizStarted || _isAnswerLocked) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return QuizPowerUpBottomSheetWidget(
          power5050Remaining: _power5050Remaining,
          powerExtraTimeRemaining: _powerExtraTimeRemaining,
          powerDoublePointsRemaining: _powerDoublePointsRemaining,
          is5050UsedOnQuestion: _eliminatedOptions.isNotEmpty,
          isDoublePointsActive: _isDoublePointsActive,
          onUse5050: () {
            Navigator.of(ctx).pop();
            _usePower5050();
          },
          onUseExtraTime: () {
            Navigator.of(ctx).pop();
            _usePowerExtraTime();
          },
          onUseDoublePoints: () {
            Navigator.of(ctx).pop();
            _usePowerDoublePoints();
          },
        );
      },
    );
  }

  Future<void> _showQuizResultModal() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return QuizResultDialogWidget(
          levelNumber: widget.levelNumber,
          correctCount: _correctCount,
          totalQuestions: _questions.length,
          gemsScore: _gemsScore,
          onRetry: () {
            Navigator.of(ctx).pop();
            setState(() {
              _currentIndex = 0;
              _selectedOptionIndex = null;
              _isAnswerLocked = false;
              _correctCount = 0;
              _gemsScore = 25;
              _power5050Remaining = 1;
              _powerExtraTimeRemaining = 1;
              _powerDoublePointsRemaining = 1;
              _eliminatedOptions = {};
              _isDoublePointsActive = false;
            });
            _startQuestionTimer();
          },
          onFinish: () {
            Navigator.of(ctx).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: QuizPlayColors.bgBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QuizPlayColors.bgTop, QuizPlayColors.bgBottom],
          ),
        ),
        child: Stack(
          children: [
            // Lapisan bintang-bintang & ornamen langit malam
            const Positioned.fill(
              child: CustomPaint(
                painter: QuizSpaceBackgroundPainter(),
              ),
            ),

            // Konten utama
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  children: [
                    // 1. Header Atas: SOAL X/Y + Timer + Koin Skor
                    QuizPlayTopHeaderWidget(
                      currentQuestionNumber: _currentIndex + 1,
                      totalQuestions: _questions.length,
                      remainingSeconds: _remainingSeconds,
                      gemsScore: _gemsScore,
                      onBackTap: () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(height: 14),

                    // 2. Baris Indikator Progress Soal (Titik & Lingkaran)
                    QuizProgressIndicatorsWidget(
                      totalQuestions: _questions.length,
                      currentIndex: _currentIndex,
                    ),

                    // 3. Ilustrasi Pulau Terbang & Bulan di Tengah
                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            final curveValue = Curves.easeInOut.transform(
                              _floatController.value,
                            );
                            final dy = -9.0 * curveValue;

                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: const SizedBox(
                                width: 290,
                                height: 220,
                                child: CustomPaint(
                                  painter: QuizFloatingIslandScenePainter(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Baris Power-Up: Badge 2x Poin (kiri jika aktif) & Bintang Kuning Power (kanan)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_isDoublePointsActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: QuizPlayColors.terracotta,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: QuizPlayColors.inkOutline,
                                width: 1.8,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 15,
                                  color: QuizPlayColors.creamGold,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '2x Poin Aktif',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        QuizPowerStarButtonWidget(
                          floatAnimation: _floatController,
                          totalPowersRemaining: _totalPowersRemaining,
                          isQuizStarted: _isQuizStarted,
                          isAnswerLocked: _isAnswerLocked,
                          onTap: _showPowerUpSheet,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 4. Kartu Pertanyaan Krem dengan Badge "SOAL" di Atasnya
                    QuizQuestionCardWidget(
                      questionIndex: _currentIndex,
                      questionText: currentQuestion.question,
                    ),

                    const SizedBox(height: 16),

                    // 5. Pilihan Jawaban A, B, C, D
                    ...List.generate(
                      currentQuestion.options.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: QuizOptionCardWidget(
                          index: index,
                          text: currentQuestion.options[index],
                          correctIndex: currentQuestion.correctIndex,
                          selectedOptionIndex: _selectedOptionIndex,
                          isAnswerLocked: _isAnswerLocked,
                          isEliminated: _eliminatedOptions.contains(index),
                          onTap: () => _onSelectOption(index),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
