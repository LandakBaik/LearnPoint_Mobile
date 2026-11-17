import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_question_model.dart';

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

  // Palet warna tema malam luar angkasa
  static const Color _bgTop = Color(0xFF1D273B);
  static const Color _bgBottom = Color(0xFF151D2E);
  static const Color _creamGold = Color(0xFFF3DF9B);
  static const Color _parchmentBg = Color(0xFFEDE2C4);
  static const Color _terracotta = Color(0xFFC4745A);
  static const Color _optionCardBg = Color(0xFF253146);
  static const Color _inkOutline = Color(0xFF0E1420);
  static const Color _darkText = Color(0xFF1A2233);

  static const List<Color> _badgeColors = [
    Color(0xFFF3E2B3), // A: Krem Hangat
    Color(0xFFC4745A), // B: Terracotta
    Color(0xFF93BE79), // C: Hijau Sage
    Color(0xFF8FA7BF), // D: Biru Baja
  ];

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
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 26),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _parchmentBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _inkOutline, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF0A0E17),
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _terracotta,
                      border: Border.all(color: _inkOutline, width: 2.2),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: _parchmentBg,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Siap Memulai Kuis?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.themeTitle} • Level ${widget.levelNumber}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _terracotta,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Kamu punya waktu $_maxSecondsPerQuestion detik untuk setiap soal. Jawab dengan tepat dan kumpulkan poin sebanyak-banyaknya!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: _darkText.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3D5B3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _inkOutline, width: 1.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          icon: Icons.quiz_rounded,
                          iconColor: _terracotta,
                          label: 'Jumlah Soal',
                          value: '${_questions.length}',
                        ),
                        Container(
                          width: 1.5,
                          height: 30,
                          color: _inkOutline.withValues(alpha: 0.25),
                        ),
                        _buildStatItem(
                          icon: Icons.timer_rounded,
                          iconColor: const Color(0xFFB45309),
                          label: 'Waktu / Soal',
                          value: '${_maxSecondsPerQuestion}s',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: const BorderSide(color: _inkOutline, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _darkText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            setState(() {
                              _isQuizStarted = true;
                            });
                            _startQuestionTimer();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _terracotta,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            elevation: 0,
                            side: const BorderSide(color: _inkOutline, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Mulai!',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
          decoration: const BoxDecoration(
            color: _bgTop,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(
              top: BorderSide(color: _inkOutline, width: 2.5),
              left: BorderSide(color: _inkOutline, width: 2.5),
              right: BorderSide(color: _inkOutline, width: 2.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(
                      painter: _PowerStarPainter(isActive: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GUNAKAN POWER',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _creamGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih kekuatan khusus untuk membantumu di soal ini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 18),
              _buildPowerOptionTile(
                icon: Icons.auto_fix_high_rounded,
                badgeColor: const Color(0xFFF3E2B3),
                title: '50 : 50',
                subtitle: 'Hapus 2 pilihan jawaban yang salah',
                remaining: _power5050Remaining,
                alreadyUsedOnQuestion: _eliminatedOptions.isNotEmpty,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _usePower5050();
                },
              ),
              const SizedBox(height: 10),
              _buildPowerOptionTile(
                icon: Icons.more_time_rounded,
                badgeColor: const Color(0xFF93BE79),
                title: '+15 Detik',
                subtitle: 'Tambah waktu pengerjaan soal ini',
                remaining: _powerExtraTimeRemaining,
                alreadyUsedOnQuestion: false,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _usePowerExtraTime();
                },
              ),
              const SizedBox(height: 10),
              _buildPowerOptionTile(
                icon: Icons.bolt_rounded,
                badgeColor: const Color(0xFFC4745A),
                title: '2x Poin',
                subtitle: 'Gandakan skor jika jawabanmu benar',
                remaining: _powerDoublePointsRemaining,
                alreadyUsedOnQuestion: _isDoublePointsActive,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _usePowerDoublePoints();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPowerOptionTile({
    required IconData icon,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required int remaining,
    required bool alreadyUsedOnQuestion,
    required VoidCallback onTap,
  }) {
    final bool canUse = remaining > 0 && !alreadyUsedOnQuestion;

    return GestureDetector(
      onTap: canUse ? onTap : null,
      child: Opacity(
        opacity: canUse ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _optionCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _inkOutline, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0A0E17),
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                  border: Border.all(color: _inkOutline, width: 1.8),
                ),
                child: Icon(icon, color: _darkText, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alreadyUsedOnQuestion ? 'Sudah aktif di soal ini' : subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: remaining > 0
                      ? _creamGold.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: remaining > 0
                        ? _creamGold.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '${remaining}x',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: remaining > 0 ? _creamGold : Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuizResultModal() async {
    final total = _questions.length;
    final accuracy = (_correctCount / total * 100).round();
    final stars = accuracy >= 80
        ? 3
        : accuracy >= 50
            ? 2
            : 1;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _parchmentBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _inkOutline, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF0A0E17),
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.star_rounded,
                        size: i == 1 ? 54 : 42,
                        color: active
                            ? const Color(0xFFEAB308)
                            : const Color(0xFFCBD5E1),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  'Level ${widget.levelNumber} Selesai!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kamu menjawab $_correctCount dari $total soal dengan benar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _darkText.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3D5B3),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _inkOutline, width: 1.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        icon: Icons.monetization_on_rounded,
                        iconColor: const Color(0xFFD97706),
                        label: 'Total Poin',
                        value: '$_gemsScore',
                      ),
                      Container(
                        width: 1.5,
                        height: 36,
                        color: _inkOutline.withValues(alpha: 0.25),
                      ),
                      _buildStatItem(
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF16A34A),
                        label: 'Akurasi',
                        value: '$accuracy%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
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
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(color: _inkOutline, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Ulangi',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _darkText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _terracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          side: const BorderSide(color: _inkOutline, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Selesai',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _darkText.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: _bgBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: Stack(
          children: [
            // Lapisan bintang-bintang & ornamen langit malam
            const Positioned.fill(
              child: CustomPaint(
                painter: _SpaceBackgroundPainter(),
              ),
            ),

            // Konten utama
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  children: [
                    // 1. Header Atas: SOAL X/Y + Timer + Koin Skor
                    _buildTopHeader(),

                    const SizedBox(height: 14),

                    // 2. Baris Indikator Progress Soal (Titik & Lingkaran)
                    _buildProgressIndicators(),

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
                                  painter: _FloatingIslandScenePainter(),
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
                              color: _terracotta,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _inkOutline, width: 1.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 15,
                                  color: _creamGold,
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
                        _buildPowerStarButton(),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 4. Kartu Pertanyaan Krem dengan Badge "SOAL" di Atasnya
                    _buildQuestionCard(currentQuestion.question),

                    const SizedBox(height: 16),

                    // 5. Pilihan Jawaban A, B, C, D
                    ...List.generate(
                      currentQuestion.options.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: _buildOptionCard(
                          index: index,
                          text: currentQuestion.options[index],
                          correctIndex: currentQuestion.correctIndex,
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

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Kiri: Tombol kembali halus + "SOAL 3/5"
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(right: 8, top: 4, bottom: 4),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _creamGold,
                  size: 18,
                ),
              ),
            ),
            Text(
              'SOAL ${_currentIndex + 1}/${_questions.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _creamGold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),

        // Kanan: Timer ringkas + Koin Skor
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _remainingSeconds <= 10
                    ? const Color(0xFF4C1D24)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _remainingSeconds <= 10
                      ? const Color(0xFFF87171)
                      : _creamGold.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: _remainingSeconds <= 10
                        ? const Color(0xFFFCA5A5)
                        : _creamGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_remainingSeconds}s',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _remainingSeconds <= 10
                          ? const Color(0xFFFCA5A5)
                          : _creamGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Ikon Koin Emas
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF6C85F),
                border: Border.all(
                  color: const Color(0xFFC88A1E),
                  width: 2,
                ),
              ),
              child: const Center(
                child: SizedBox(
                  width: 3,
                  height: 9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFB47814),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              '$_gemsScore',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _creamGold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_questions.length, (i) {
        final bool isDone = i < _currentIndex;
        final bool isCurrent = i == _currentIndex;

        if (isCurrent) {
          // Lingkaran konsentris aktif (pinggiran krem, tengah terracotta)
          return Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _creamGold, width: 2),
            ),
            child: Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _terracotta,
                ),
              ),
            ),
          );
        }

        if (isDone) {
          // Titik penuh krem/emas untuk soal yang sudah lewat
          return Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE5CB86),
            ),
          );
        }

        // Soal yang belum dikerjakan
        if (i == _questions.length - 1) {
          return Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.32),
                width: 1.4,
              ),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          );
        }

        return Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.4,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuestionCard(String questionText) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Kartu Krem Utama
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 24),
          decoration: BoxDecoration(
            color: _parchmentBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _inkOutline, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0A0E17),
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              questionText,
              key: ValueKey<int>(_currentIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _darkText,
                height: 1.38,
              ),
            ),
          ),
        ),

        // Pill Badge "SOAL" di Tengah Atas Kartu
        Positioned(
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: _terracotta,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _inkOutline, width: 2.2),
            ),
            child: const Text(
              'SOAL',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: _darkText,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPowerStarButton() {
    final bool hasPower = _totalPowersRemaining > 0;
    final bool canTap = _isQuizStarted && !_isAnswerLocked && hasPower;

    return GestureDetector(
      onTap: canTap
          ? _showPowerUpSheet
          : () {
              if (!hasPower && _isQuizStarted && !_isAnswerLocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua power sudah digunakan pada kuis ini.'),
                    duration: Duration(milliseconds: 1400),
                  ),
                );
              }
            },
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final pulse = 1.0 + (0.08 * _floatController.value);
          return Transform.scale(
            scale: canTap ? pulse : 1.0,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Cahaya halo kuning di belakang bintang
                if (hasPower)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFF3E0A2).withValues(alpha: 0.36),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: CustomPaint(
                    painter: _PowerStarPainter(isActive: hasPower),
                  ),
                ),
                // Badge jumlah power tersisa
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: hasPower ? _terracotta : const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _inkOutline, width: 1.5),
                    ),
                    child: Text(
                      '$_totalPowersRemaining',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String text,
    required int correctIndex,
  }) {
    final bool isEliminated = _eliminatedOptions.contains(index);
    final bool isSelected = _selectedOptionIndex == index;
    final bool isCorrectOption = index == correctIndex;

    Color cardBg = _optionCardBg;
    Color borderColor = _inkOutline;
    Widget? trailingStatus;

    if (_isAnswerLocked) {
      if (isCorrectOption) {
        cardBg = const Color(0xFF1F4B38);
        borderColor = const Color(0xFF4ADE80);
        trailingStatus = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF4ADE80),
          size: 22,
        );
      } else if (isSelected && !isCorrectOption) {
        cardBg = const Color(0xFF4C1F2A);
        borderColor = const Color(0xFFF87171);
        trailingStatus = const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFF87171),
          size: 22,
        );
      }
    }

    final letter = String.fromCharCode(65 + index); // A, B, C, D
    final badgeColor = _badgeColors[index % _badgeColors.length];

    return GestureDetector(
      onTap: isEliminated ? null : () => _onSelectOption(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: isEliminated ? 0.3 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0A0E17),
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Badge Huruf Bulat (A, B, C, D)
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                  border: Border.all(color: _inkOutline, width: 1.8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _darkText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Teks Opsi Jawaban
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF1F5F9),
                    height: 1.25,
                    decoration:
                        isEliminated ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (trailingStatus != null) ...[
                const SizedBox(width: 10),
                trailingStatus,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter untuk bintang-bintang & tanda plus (+) pada latar langit malam.
class _SpaceBackgroundPainter extends CustomPainter {
  const _SpaceBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.78)
      ..style = PaintingStyle.fill;

    final crossPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Titik-titik bintang kecil
    final dots = <Offset>[
      Offset(size.width * 0.24, size.height * 0.08),
      Offset(size.width * 0.42, size.height * 0.11),
      Offset(size.width * 0.07, size.height * 0.14),
      Offset(size.width * 0.05, size.height * 0.38),
      Offset(size.width * 0.68, size.height * 0.41),
      Offset(size.width * 0.90, size.height * 0.16),
      Offset(size.width * 0.85, size.height * 0.49),
    ];

    for (final p in dots) {
      canvas.drawCircle(p, 1.8, dotPaint);
    }

    // Bintang berbentuk tanda plus (+)
    _drawCross(canvas, Offset(size.width * 0.27, size.height * 0.13), 10, crossPaint);
    _drawCross(canvas, Offset(size.width * 0.10, size.height * 0.25), 9, crossPaint);
    _drawCross(canvas, Offset(size.width * 0.84, size.height * 0.09), 7, crossPaint);
    _drawCross(canvas, Offset(size.width * 0.93, size.height * 0.37), 9, crossPaint);
  }

  void _drawCross(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), paint);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter untuk ikon bintang kuning Power-Up 4-sisi.
class _PowerStarPainter extends CustomPainter {
  final bool isActive;

  const _PowerStarPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.44;

    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + r * 0.2, c.dy - r * 0.2, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + r * 0.2, c.dy + r * 0.2, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r * 0.2, c.dy + r * 0.2, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - r * 0.2, c.dy - r * 0.2, c.dx, c.dy - r)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = isActive
            ? const Color(0xFFF3E0A2)
            : const Color(0xFF64748B),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0E1420)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(covariant _PowerStarPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}

/// Painter ilustrasi Pulau Melayang, Kastil, Pohon, dan Bulan Purnama.
class _FloatingIslandScenePainter extends CustomPainter {
  const _FloatingIslandScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.45;
    final cy = size.height * 0.58;

    // 1. Bulan di sebelah kanan dengan cincin orbit tipis
    final moonCenter = Offset(size.width * 0.83, size.height * 0.48);
    const moonRadius = 33.0;

    final orbitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(moonCenter, moonRadius + 10, orbitPaint);
    canvas.drawCircle(moonCenter, moonRadius + 18, orbitPaint);

    // Badan Bulan
    canvas.drawCircle(
      moonCenter,
      moonRadius,
      Paint()..color = const Color(0xFFF1DE9E),
    );
    // Bayangan lembut sisi kanan bawah bulan
    canvas.drawCircle(
      moonCenter + const Offset(4, 4),
      moonRadius - 4,
      Paint()..color = const Color(0xFFE4CC83).withValues(alpha: 0.45),
    );
    // Kawah-kawah bulan
    canvas.drawCircle(
      moonCenter + const Offset(-10, -8),
      4.5,
      Paint()..color = const Color(0xFFD5BC74),
    );
    canvas.drawCircle(
      moonCenter + const Offset(10, -14),
      3.0,
      Paint()..color = const Color(0xFFD5BC74),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: moonCenter + const Offset(6, 16),
        width: 11,
        height: 6,
      ),
      Paint()..color = const Color(0xFF3E3A35),
    );
    // Kilau lengkung kiri atas bulan
    canvas.drawArc(
      Rect.fromCircle(center: moonCenter, radius: moonRadius - 5),
      math.pi * 1.05,
      math.pi * 0.35,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // 2. Pulau Terbang (Tanah Cokelat + Rumput Hijau)
    final islandRect = Rect.fromCenter(
      center: Offset(cx, cy + 10),
      width: 162,
      height: 74,
    );

    // Bagian bawah tanah (mangkuk/kerucut melengkung)
    final rockPath = Path()
      ..moveTo(islandRect.left + 6, cy + 4)
      ..quadraticBezierTo(cx, cy + 72, islandRect.right - 6, cy + 4)
      ..close();
    canvas.drawPath(
      rockPath,
      Paint()..color = const Color(0xFF6B4D3C),
    );

    // Bayangan gelap di dasar bawah tanah
    final rockShadowPath = Path()
      ..moveTo(islandRect.left + 16, cy + 16)
      ..quadraticBezierTo(cx + 8, cy + 68, islandRect.right - 16, cy + 12)
      ..quadraticBezierTo(cx, cy + 52, islandRect.left + 16, cy + 16)
      ..close();
    canvas.drawPath(
      rockShadowPath,
      Paint()..color = const Color(0xFF4D3529),
    );

    // Lapisan rumput hijau bagian atas pulau
    final grassRect = Rect.fromCenter(
      center: Offset(cx, cy + 3),
      width: 162,
      height: 36,
    );
    canvas.drawOval(
      grassRect.shift(const Offset(0, 3)),
      Paint()..color = const Color(0xFF6A9459),
    );
    canvas.drawOval(
      grassRect,
      Paint()..color = const Color(0xFF8DBA78),
    );

    // 3. Pohon Bulat di Kiri Kastil
    final treeTrunkRect = Rect.fromLTWH(cx - 56, cy - 16, 6, 15);
    canvas.drawRect(
      treeTrunkRect,
      Paint()..color = const Color(0xFF5A3E30),
    );
    canvas.drawCircle(
      Offset(cx - 53, cy - 23),
      13,
      Paint()..color = const Color(0xFF75A362),
    );
    canvas.drawCircle(
      Offset(cx - 56, cy - 26),
      8,
      Paint()..color = const Color(0xFF8DBA78),
    );

    // 4. Kastil / Bangunan Sekolah
    final wallPaint = Paint()..color = const Color(0xFFEFE5CF);
    final wallShadowPaint = Paint()..color = const Color(0xFFDDD0B4);
    final roofPaint = Paint()..color = const Color(0xFFBF6952);

    // Menara Kiri
    canvas.drawRect(Rect.fromLTWH(cx - 32, cy - 34, 18, 34), wallShadowPaint);
    _drawTriangleRoof(
      canvas,
      Offset(cx - 34, cy - 34),
      Offset(cx - 12, cy - 34),
      Offset(cx - 23, cy - 50),
      roofPaint,
    );

    // Menara Kanan
    canvas.drawRect(Rect.fromLTWH(cx + 22, cy - 34, 18, 34), wallShadowPaint);
    _drawTriangleRoof(
      canvas,
      Offset(cx + 20, cy - 34),
      Offset(cx + 42, cy - 34),
      Offset(cx + 31, cy - 50),
      roofPaint,
    );

    // Bangunan Utama Tengah
    canvas.drawRect(Rect.fromLTWH(cx - 16, cy - 48, 40, 48), wallPaint);
    _drawTriangleRoof(
      canvas,
      Offset(cx - 20, cy - 48),
      Offset(cx + 28, cy - 48),
      Offset(cx + 4, cy - 70),
      roofPaint,
    );

    // Bendera Kuning di Puncak Atap
    canvas.drawLine(
      Offset(cx + 4, cy - 70),
      Offset(cx + 4, cy - 84),
      Paint()
        ..color = const Color(0xFFEFE5CF)
        ..strokeWidth = 1.8,
    );
    final flagPath = Path()
      ..moveTo(cx + 4, cy - 84)
      ..lineTo(cx + 16, cy - 79)
      ..lineTo(cx + 4, cy - 74)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = const Color(0xFFF3CA58));

    // Pintu Lengkung Gelap
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx - 2, cy - 20, 12, 20),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
    );
    canvas.drawRRect(doorRect, Paint()..color = const Color(0xFF1B2438));

    // Jendela kecil
    canvas.drawCircle(
      Offset(cx + 4, cy - 33),
      3.5,
      Paint()..color = const Color(0xFF1B2438),
    );
    canvas.drawCircle(
      Offset(cx - 23, cy - 20),
      2.5,
      Paint()..color = const Color(0xFF1B2438),
    );
    canvas.drawCircle(
      Offset(cx + 31, cy - 20),
      2.5,
      Paint()..color = const Color(0xFF1B2438),
    );
  }

  void _drawTriangleRoof(
    Canvas canvas,
    Offset left,
    Offset right,
    Offset top,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(left.dx, left.dy)
      ..lineTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
