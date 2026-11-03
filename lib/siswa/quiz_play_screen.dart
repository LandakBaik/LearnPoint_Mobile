import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/quiz_question_model.dart';

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

  @override
  void initState() {
    super.initState();
    _questions = widget.customQuestions ?? defaultQuizPlayQuestions;

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Tampilkan popup "Are You Ready?" terlebih dahulu sebelum waktu berjalan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showAreYouReadyModal();
      }
    });
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon Roket / Tantangan
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          lightenColor(widget.themeColor, 0.12),
                          widget.themeColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.themeColor.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Are You Ready?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.themeTitle} • Level ${widget.levelNumber}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: widget.themeColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Kamu punya waktu $_maxSecondsPerQuestion detik untuk setiap soal. Jawab dengan tepat dan kumpulkan poin sebanyak-banyaknya!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Ringkas Soal & Waktu
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          icon: Icons.quiz_rounded,
                          iconColor: widget.themeColor,
                          label: 'Jumlah Soal',
                          value: '${_questions.length}',
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFFE2E8F0),
                        ),
                        _buildStatItem(
                          icon: Icons.timer_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          label: 'Waktu / Soal',
                          value: '${_maxSecondsPerQuestion}s',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Batal & Mulai Kuis
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
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
                            backgroundColor: widget.themeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoNextTimer?.cancel();
    _floatController.dispose();
    super.dispose();
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
    if (!_isQuizStarted || _isAnswerLocked) return;

    _countdownTimer?.cancel();
    final currentQ = _questions[_currentIndex];
    final isCorrect = optionIndex == currentQ.correctIndex;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _isAnswerLocked = true;
      if (isCorrect) {
        _gemsScore += currentQ.rewardGems;
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
        });
        _startQuestionTimer();
      } else {
        _showQuizResultModal();
      }
    });
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Deretan Bintang
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
                            ? const Color(0xFFFACC15)
                            : const Color(0xFFE2E8F0),
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
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kamu menjawab $_correctCount dari $total soal dengan benar.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),

                // Statistik Poin & Akurasi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        icon: Icons.diamond_rounded,
                        iconColor: const Color(0xFF38BDF8),
                        label: 'Total Poin',
                        value: '$_gemsScore',
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE2E8F0),
                      ),
                      _buildStatItem(
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF22C55E),
                        label: 'Akurasi',
                        value: '$accuracy%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Tombol Ulangi & Kembali ke Peta Level
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
                          });
                          _startQuestionTimer();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: widget.themeColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Ulangi',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: widget.themeColor,
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
                          backgroundColor: widget.themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentIndex];
    final topColor = lightenColor(widget.themeColor, 0.06);
    final midColor = widget.themeColor;
    final bottomColor = darkenColor(widget.themeColor, 0.24);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              topColor,
              midColor,
              bottomColor,
            ],
            stops: const [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Atas (Tombol Kembali, Circular Timer 60, Pill Skor Diamond)
                _buildTopBar(),

                // 2. Ilustrasi 3D Melayang + Bayangan Lembut di Tengah
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        final curveValue = Curves.easeInOut.transform(
                          _floatController.value,
                        );
                        final dy = -12.0 * curveValue;
                        final shadowScale = 1.0 - (0.18 * curveValue);
                        final shadowAlpha = 0.34 - (0.12 * curveValue);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: Offset(0, dy),
                              child: SizedBox(
                                width: 155,
                                height: 155,
                                child: CustomPaint(
                                  painter: _Floating3DShapePainter(
                                    visualType: currentQuestion.visualType,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Transform.scale(
                              scaleX: shadowScale,
                              scaleY: shadowScale,
                              child: Container(
                                width: 110,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: shadowAlpha,
                                      ),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // 3. Nomor Soal (5 / 10) & Teks Pertanyaan Rata Kiri
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Column(
                    key: ValueKey<int>(_currentIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_currentIndex + 1} / ${_questions.length}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.88),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.32,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 4. Pilihan Jawaban Kapsul (Putih, Hijau Benar + ✓, Merah Salah + ✕)
                ...List.generate(
                  currentQuestion.options.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOptionButton(
                      index: index,
                      text: currentQuestion.options[index],
                      correctIndex: currentQuestion.correctIndex,
                    ),
                  ),
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final progress = _remainingSeconds / _maxSecondsPerQuestion;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tombol Back Melingkar Tipis
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 1.5,
              ),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),

        // Timer Melingkar di Tengah (60 Detik)
        SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3.5,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingSeconds <= 10
                        ? const Color(0xFFFF4D67)
                        : Colors.white,
                  ),
                ),
              ),
              Text(
                '$_remainingSeconds',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Badge Diamond / Poin di Kanan Atas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
              width: 1.5,
            ),
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.diamond_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '$_gemsScore',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required int index,
    required String text,
    required int correctIndex,
  }) {
    // Status warna tombol:
    // - Belum dijawab: Putih bersih, teks gelap
    // - Setelah dijawab:
    //   * Jawaban yang benar -> Hijau terang (#8CE600 / #7ED321) + ikon ✓
    //   * Jawaban yang dipilih tapi salah -> Merah (#FF1E42) + ikon ✕
    //   * Opsi lain -> Putih bersih
    final bool isSelected = _selectedOptionIndex == index;
    final bool isCorrectOption = index == correctIndex;

    Color backgroundColor = Colors.white;
    Color textColor = const Color(0xFF0F172A);
    Widget? trailingBadge;

    if (_isAnswerLocked) {
      if (isCorrectOption) {
        backgroundColor = const Color(0xFF84E10C);
        textColor = Colors.white;
        trailingBadge = Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 19,
            color: Color(0xFF65B700),
          ),
        );
      } else if (isSelected && !isCorrectOption) {
        backgroundColor = const Color(0xFFFF173D);
        textColor = Colors.white;
        trailingBadge = Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 19,
            color: Color(0xFFFF173D),
          ),
        );
      }
    }

    return GestureDetector(
      onTap: () => _onSelectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            if (trailingBadge != null)
              Positioned(
                right: 0,
                child: trailingBadge,
              ),
          ],
        ),
      ),
    );
  }
}

/// Painter untuk menggambar ilustrasi bangun ruang 3D isometrik penuh warna
/// seperti pada referensi gambar (tanpa butuh engine 3D berat).
class _Floating3DShapePainter extends CustomPainter {
  final QuizVisualType visualType;

  const _Floating3DShapePainter({required this.visualType});

  @override
  void paint(Canvas canvas, Size size) {
    switch (visualType) {
      case QuizVisualType.cube3d:
        _paintIsometricCube(canvas, size);
        break;
      case QuizVisualType.pyramid3d:
        _paintIsometricPyramid(canvas, size);
        break;
      case QuizVisualType.cylinder3d:
        _paintCylinder(canvas, size);
        break;
      case QuizVisualType.sphere3d:
        _paintSphere(canvas, size);
        break;
      case QuizVisualType.cone3d:
        _paintCone(canvas, size);
        break;
      default:
        _paintIsometricCube(canvas, size);
        break;
    }
  }

  void _paintIsometricCube(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;

    final topCenter = Offset(cx, cy - r * 0.88);
    final leftTop = Offset(cx - r * 0.86, cy - r * 0.36);
    final rightTop = Offset(cx + r * 0.86, cy - r * 0.36);
    final centerMid = Offset(cx, cy + r * 0.14);
    final leftBottom = Offset(cx - r * 0.86, cy + r * 0.56);
    final rightBottom = Offset(cx + r * 0.86, cy + r * 0.56);
    final bottomCenter = Offset(cx, cy + r * 1.06);

    // Sisi Atas (Pastel Pink - Cyan Gradient)
    final topFace = Path()
      ..moveTo(topCenter.dx, topCenter.dy)
      ..lineTo(rightTop.dx, rightTop.dy)
      ..lineTo(centerMid.dx, centerMid.dy)
      ..lineTo(leftTop.dx, leftTop.dy)
      ..close();

    canvas.drawPath(
      topFace,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA5F3FC), Color(0xFFF5D0FE), Color(0xFFFDA4AF)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Sisi Kiri (Coral - Ungu)
    final leftFace = Path()
      ..moveTo(leftTop.dx, leftTop.dy)
      ..lineTo(centerMid.dx, centerMid.dy)
      ..lineTo(bottomCenter.dx, bottomCenter.dy)
      ..lineTo(leftBottom.dx, leftBottom.dy)
      ..close();

    canvas.drawPath(
      leftFace,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFB7185), Color(0xFFC084FC)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Panel Dalam Sisi Kiri (Hijau Mint - Kuning)
    final insetLeft = Path()
      ..moveTo(leftTop.dx + 10, leftTop.dy + 14)
      ..lineTo(centerMid.dx - 8, centerMid.dy + 6)
      ..lineTo(bottomCenter.dx - 8, bottomCenter.dy - 14)
      ..lineTo(leftBottom.dx + 10, leftBottom.dy - 6)
      ..close();

    canvas.drawPath(
      insetLeft,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDE047), Color(0xFF6EE7B7)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Sisi Kanan (Biru Muda - Ungu)
    final rightFace = Path()
      ..moveTo(centerMid.dx, centerMid.dy)
      ..lineTo(rightTop.dx, rightTop.dy)
      ..lineTo(rightBottom.dx, rightBottom.dy)
      ..lineTo(bottomCenter.dx, bottomCenter.dy)
      ..close();

    canvas.drawPath(
      rightFace,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF67E8F9), Color(0xFF818CF8)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Panel Dalam Sisi Kanan (Amber - Peach)
    final insetRight = Path()
      ..moveTo(centerMid.dx + 8, centerMid.dy + 6)
      ..lineTo(rightTop.dx - 10, rightTop.dy + 14)
      ..lineTo(rightBottom.dx - 10, rightBottom.dy - 6)
      ..lineTo(bottomCenter.dx + 8, bottomCenter.dy - 14)
      ..close();

    canvas.drawPath(
      insetRight,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFCD34D), Color(0xFFFDA4AF)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Highlight Garis Tepi Halus
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(topFace, edgePaint);
  }

  void _paintIsometricPyramid(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;

    final apex = Offset(cx, cy - r * 0.92);
    final leftBase = Offset(cx - r * 0.88, cy + r * 0.35);
    final midBase = Offset(cx, cy + r * 0.88);
    final rightBase = Offset(cx + r * 0.88, cy + r * 0.35);

    final leftFace = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(leftBase.dx, leftBase.dy)
      ..lineTo(midBase.dx, midBase.dy)
      ..close();

    final rightFace = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(midBase.dx, midBase.dy)
      ..lineTo(rightBase.dx, rightBase.dy)
      ..close();

    canvas.drawPath(
      leftFace,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDE047), Color(0xFFFB7185)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      rightFace,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF67E8F9), Color(0xFF818CF8)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  void _paintCylinder(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.62;
    final h = size.height * 0.68;

    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy + 8),
      width: w,
      height: h * 0.75,
    );
    final topOval = Rect.fromCenter(
      center: Offset(cx, cy - h * 0.30),
      width: w,
      height: 34,
    );
    final bottomOval = Rect.fromCenter(
      center: Offset(cx, cy + h * 0.45),
      width: w,
      height: 34,
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF38BDF8),
          Color(0xFFA78BFA),
          Color(0xFFF472B6),
        ],
      ).createShader(bodyRect);

    canvas.drawOval(bottomOval, bodyPaint);
    canvas.drawRect(bodyRect, bodyPaint);
    canvas.drawOval(
      topOval,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFA5F3FC), Color(0xFFFDE047)],
        ).createShader(topOval),
    );
  }

  void _paintSphere(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.95,
          colors: [
            Color(0xFFFEF08A),
            Color(0xFF38BDF8),
            Color(0xFF6366F1),
          ],
        ).createShader(rect),
    );
  }

  void _paintCone(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.66;
    final apex = Offset(cx, cy - size.height * 0.36);
    final baseCenter = Offset(cx, cy + size.height * 0.28);

    final conePath = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(cx - w / 2, baseCenter.dy)
      ..arcTo(
        Rect.fromCenter(center: baseCenter, width: w, height: 34),
        math.pi,
        -math.pi,
        false,
      )
      ..close();

    canvas.drawPath(
      conePath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDE047),
            Color(0xFFFB7185),
            Color(0xFF818CF8),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _Floating3DShapePainter oldDelegate) {
    return oldDelegate.visualType != visualType;
  }
}
