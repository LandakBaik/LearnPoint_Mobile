import 'dart:async';
import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_question_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/services/quiz_api_service.dart';
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
  final int? quizId;
  final String themeTitle;
  final int levelNumber;
  final String? arc;
  final int? arcLevelNum;
  final int? step;
  final Color themeColor;
  final List<QuizPlayQuestionModel>? customQuestions;

  const QuizPlayScreen({
    super.key,
    this.quizId,
    this.themeTitle = 'Geometri',
    this.levelNumber = 1,
    this.arc,
    this.arcLevelNum,
    this.step,
    this.themeColor = const Color(0xFF4338CA),
    this.customQuestions,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxSecondsPerQuestion = 60;

  List<QuizPlayQuestionModel> _questions = defaultQuizPlayQuestions;
  late final AnimationController _floatController;

  Timer? _countdownTimer;
  Timer? _autoNextTimer;

  bool _isLoadingApi = false;
  int _currentIndex = 0;
  int _remainingSeconds = _maxSecondsPerQuestion;
  int _elapsedSeconds = 0;
  int _gemsScore = 25;
  int _correctCount = 0;

  int? _selectedOptionIndex;
  bool _isAnswerLocked = false;
  bool _isQuizStarted = false;

  /// Menyimpan jawaban siswa per soal (`{soal_id: 'a'}`) untuk dikirim ke API `submit`
  final Map<String, String> _submittedAnswers = {};

  // State Power-Up (Bintang Kuning)
  int _power5050Remaining = 1;
  int _powerExtraTimeRemaining = 1;
  int _powerDoublePointsRemaining = 1;
  int _powerPiratesCompassRemaining = 1;
  Set<int> _eliminatedOptions = {};
  bool _isDoublePointsActive = false;
  bool _isPiratesCompassUsedOnQuestion = false;
  String? _currentHintText;
  Map<int, Map<String, dynamic>> _questionStates = {};

  int get _totalPowersRemaining =>
      _power5050Remaining +
      _powerExtraTimeRemaining +
      _powerDoublePointsRemaining +
      _powerPiratesCompassRemaining;

  @override
  void initState() {
    super.initState();
    if (widget.customQuestions != null && widget.customQuestions!.isNotEmpty) {
      _questions = widget.customQuestions!;
    }

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeQuizData();
      }
    });
  }

  Future<void> _initializeQuizData() async {
    if (widget.quizId != null && widget.customQuestions == null) {
      setState(() {
        _isLoadingApi = true;
      });
      try {
        final results = await Future.wait([
          QuizApiService.fetchQuestionsForLevel(
            quizId: widget.quizId!,
            arc: widget.arc,
            levelNum: widget.arcLevelNum ?? widget.levelNumber,
            step: widget.step,
          ),
          QuizApiService.fetchQuizPowers(widget.quizId!)
              .then<({
                List<QuizPowerItemModel> powers,
                Map<int, Map<String, dynamic>> questionStates,
              })?>((val) => val)
              .catchError((_) => null),
        ]);

        final fetchedQuestions = results[0] as List<QuizPlayQuestionModel>;
        final powersData = results[1] as ({
          List<QuizPowerItemModel> powers,
          Map<int, Map<String, dynamic>> questionStates,
        })?;

        if (mounted && fetchedQuestions.isNotEmpty) {
          setState(() {
            _questions = fetchedQuestions;
            if (powersData != null) {
              _syncPowersFromApi(powersData.powers);
              _questionStates = powersData.questionStates;
            }
          });
          _applyQuestionStateForCurrentQuestion();
        }
      } on QuizApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      } catch (_) {
        // Fallback ke defaultQuizPlayQuestions jika gagal memuat
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingApi = false;
          });
        }
      }
    }

    if (mounted) {
      await _showAreYouReadyModal();
    }
  }

  void _syncPowersFromApi(List<QuizPowerItemModel> powers) {
    int countFor(String kode) {
      for (final p in powers) {
        if (p.kode == kode && p.isActive) return p.jumlah;
      }
      return 0;
    }

    _power5050Remaining = countFor('remove_wrong_answer');
    _powerDoublePointsRemaining =
        countFor('two_x_score') + countFor('double_side_knife');
    _powerExtraTimeRemaining = countFor('second_chance');
    _powerPiratesCompassRemaining = countFor('pirates_compass');
  }

  /// Menerapkan efek eliminasi & hint dari payload `powers/use` maupun `question_states`
  void _applyEffectPayload(
    Map<String, dynamic> rawEffect, {
    bool showCompassToast = false,
  }) {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;
    final currentQ = _questions[_currentIndex];

    // Normalisasi struktur payload (langsung atau nested di dalam 'effect' / 'pirates_compass')
    final effect = rawEffect['effect'] is Map<String, dynamic>
        ? rawEffect['effect'] as Map<String, dynamic>
        : (rawEffect['pirates_compass'] is Map<String, dynamic>
            ? rawEffect['pirates_compass'] as Map<String, dynamic>
            : rawEffect);

    final rawEliminated = effect['eliminated_options'];
    final newIndices = <int>{};
    final eliminatedKeys = <String>{};
    if (rawEliminated is List) {
      for (final key in rawEliminated) {
        final cleanKey = key.toString().trim().toLowerCase();
        if (cleanKey.isEmpty) continue;
        eliminatedKeys.add(cleanKey);
        final idx = currentQ.indexForKey(cleanKey);
        if (idx >= 0) newIndices.add(idx);
      }
    }

    final rawHint = (effect['hint_text'] ?? '').toString().trim();

    if (!mounted) return;
    setState(() {
      if (newIndices.isNotEmpty) {
        _eliminatedOptions = {..._eliminatedOptions, ...newIndices};
      }
      // Reset pilihan jika siswa sebelumnya sudah memilih opsi yang dieliminasi
      if (_selectedOptionIndex != null &&
          _eliminatedOptions.contains(_selectedOptionIndex)) {
        _selectedOptionIndex = null;
        _isAnswerLocked = false;
      }
      if (currentQ.id != null) {
        final soalKey = currentQ.id.toString();
        final savedKey = _submittedAnswers[soalKey]?.trim().toLowerCase();
        if (savedKey != null && eliminatedKeys.contains(savedKey)) {
          _submittedAnswers.remove(soalKey);
        }
      }
      if (rawHint.isNotEmpty) {
        _currentHintText = rawHint;
        _isPiratesCompassUsedOnQuestion = true;
      }
    });

    if (showCompassToast && newIndices.isNotEmpty && mounted) {
      final sortedIndices = newIndices.toList()..sort();
      final labels =
          sortedIndices.map((i) => String.fromCharCode(65 + i)).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kompas menunjuk Pilihan $labels sebagai jawaban yang salah',
          ),
          backgroundColor: const Color(0xFF0F766E),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _applyQuestionStateForCurrentQuestion() {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;
    final soalId = _questions[_currentIndex].id;
    if (soalId == null) return;
    final state = _questionStates[soalId];
    if (state != null) {
      _applyEffectPayload(state);
    }
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
      _elapsedSeconds++;
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
    final selectedKey = currentQ.keyAt(optionIndex);
    if (currentQ.id != null) {
      _submittedAnswers[currentQ.id.toString()] = selectedKey;
      if (widget.quizId != null) {
        unawaited(
          QuizApiService.saveDraft(
            quizId: widget.quizId!,
            jawaban: {currentQ.id.toString(): selectedKey},
          ).catchError((_) {}),
        );
      }
    }

    // Jika correctIndex tersedia (>= 0), evaluasi langsung; jika dari API (-1), evaluasi di akhir saat submit
    final hasLocalKey = currentQ.correctIndex >= 0;
    final isCorrect = hasLocalKey
        ? optionIndex == currentQ.correctIndex
        : true;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _isAnswerLocked = true;
      if (isCorrect) {
        final earned = _isDoublePointsActive
            ? currentQ.rewardGems * 2
            : currentQ.rewardGems;
        _gemsScore += earned;
        if (hasLocalKey) {
          _correctCount++;
        }
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
          _isPiratesCompassUsedOnQuestion = false;
          _currentHintText = null;
        });
        _applyQuestionStateForCurrentQuestion();
        _startQuestionTimer();
      } else {
        _finishAndShowResultModal();
      }
    });
  }

  Future<void> _usePower5050() async {
    if (_power5050Remaining <= 0 || _eliminatedOptions.isNotEmpty) return;

    final currentQ = _questions[_currentIndex];
    if (widget.quizId != null && currentQ.id != null) {
      try {
        final effect = await QuizApiService.usePower(
          quizId: widget.quizId!,
          soalId: currentQ.id!,
          powerKode: 'remove_wrong_answer',
        );
        if (mounted) {
          setState(() {
            _power5050Remaining--;
          });
          _applyEffectPayload(effect);
        }
        return;
      } catch (_) {}
    }

    final wrongIndices = List<int>.generate(currentQ.options.length, (i) => i)
        .where((i) => i != currentQ.correctIndex)
        .toList()
      ..shuffle();

    setState(() {
      _power5050Remaining--;
      _eliminatedOptions = wrongIndices.take(2).toSet();
    });
  }

  Future<void> _usePowerPiratesCompass() async {
    if (_powerPiratesCompassRemaining <= 0 || _isPiratesCompassUsedOnQuestion) {
      return;
    }

    final currentQ = _questions[_currentIndex];
    if (widget.quizId != null && currentQ.id != null) {
      try {
        final effect = await QuizApiService.usePower(
          quizId: widget.quizId!,
          soalId: currentQ.id!,
          powerKode: 'pirates_compass',
        );
        if (mounted) {
          setState(() {
            _powerPiratesCompassRemaining--;
            _isPiratesCompassUsedOnQuestion = true;
          });
          _applyEffectPayload(effect, showCompassToast: true);
        }
        return;
      } on QuizApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
        return;
      } catch (_) {}
    }

    final wrongIndices = List<int>.generate(currentQ.options.length, (i) => i)
        .where(
          (i) => i != currentQ.correctIndex && !_eliminatedOptions.contains(i),
        )
        .toList()
      ..shuffle();

    if (wrongIndices.isEmpty) return;
    final pickedIdx = wrongIndices.first;
    final displayLetter = String.fromCharCode(65 + pickedIdx);
    final wrongText = currentQ.options[pickedIdx];

    setState(() {
      _powerPiratesCompassRemaining--;
      _isPiratesCompassUsedOnQuestion = true;
      _eliminatedOptions = {..._eliminatedOptions, pickedIdx};
      if (_selectedOptionIndex == pickedIdx) {
        _selectedOptionIndex = null;
        _isAnswerLocked = false;
      }
      _currentHintText =
          'Kompas Bajak Laut menunjuk 1 jawaban yang salah: "$wrongText".';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kompas menunjuk Pilihan $displayLetter sebagai jawaban yang salah',
          ),
          backgroundColor: const Color(0xFF0F766E),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _usePowerExtraTime() {
    if (_powerExtraTimeRemaining <= 0) return;

    setState(() {
      _powerExtraTimeRemaining--;
      _remainingSeconds += 15;
    });
  }

  Future<void> _usePowerDoublePoints() async {
    if (_powerDoublePointsRemaining <= 0 || _isDoublePointsActive) return;

    final currentQ = _questions[_currentIndex];
    if (widget.quizId != null && currentQ.id != null) {
      unawaited(
        QuizApiService.usePower(
          quizId: widget.quizId!,
          soalId: currentQ.id!,
          powerKode: 'two_x_score',
        ).catchError((_) => <String, dynamic>{}),
      );
    }

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
          powerPiratesCompassRemaining: _powerPiratesCompassRemaining,
          is5050UsedOnQuestion: _eliminatedOptions.isNotEmpty,
          isDoublePointsActive: _isDoublePointsActive,
          isPiratesCompassUsedOnQuestion: _isPiratesCompassUsedOnQuestion,
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
          onUsePiratesCompass: () {
            Navigator.of(ctx).pop();
            _usePowerPiratesCompass();
          },
        );
      },
    );
  }

  Future<void> _finishAndShowResultModal() async {
    if (widget.quizId != null && _submittedAnswers.isNotEmpty) {
      try {
        final submitResult = await QuizApiService.submitQuizLevel(
          quizId: widget.quizId!,
          jawaban: _submittedAnswers,
          durasiDetik: _elapsedSeconds,
          arc: widget.arc,
          levelNum: widget.arcLevelNum ?? widget.levelNumber,
          step: widget.step,
        );
        if (mounted) {
          setState(() {
            _correctCount = submitResult.jumlahBenar;
            if (submitResult.koinDidapat > 0) {
              _gemsScore = submitResult.koinDidapat;
            }
          });
        }
      } on QuizApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      } catch (_) {}
    }

    if (!mounted) return;

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
            if (widget.quizId != null) {
              // Level kuis API yang sudah selesai tidak dapat diulang, kembali ke peta level
              Navigator.of(context).pop();
              return;
            }
            setState(() {
              _currentIndex = 0;
              _selectedOptionIndex = null;
              _isAnswerLocked = false;
              _correctCount = 0;
              _gemsScore = 25;
              _power5050Remaining = 1;
              _powerExtraTimeRemaining = 1;
              _powerDoublePointsRemaining = 1;
              _powerPiratesCompassRemaining = 1;
              _eliminatedOptions = {};
              _isDoublePointsActive = false;
              _isPiratesCompassUsedOnQuestion = false;
              _currentHintText = null;
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

            if (_isLoadingApi)
              const Center(
                child: CircularProgressIndicator(
                  color: QuizPlayColors.creamGold,
                ),
              )
            else
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

                      if (_currentHintText != null &&
                          _currentHintText!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildPiratesCompassHintCard(_currentHintText!),
                      ],

                      const SizedBox(height: 16),

                      // 5. Pilihan Jawaban A, B, C, D
                      ...List.generate(
                        currentQuestion.options.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: QuizOptionCardWidget(
                            index: index,
                            text: currentQuestion.options[index],
                            correctIndex: currentQuestion.correctIndex >= 0
                                ? currentQuestion.correctIndex
                                : (_selectedOptionIndex ?? -1),
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

  Widget _buildPiratesCompassHintCard(String hintText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3D36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF34D399),
          width: 1.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF0A0E17),
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: Color(0xFF6EE7B7),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Petunjuk Pirates Compass',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6EE7B7),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hintText,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
