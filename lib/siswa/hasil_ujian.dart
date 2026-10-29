import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detail Ujian',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF1F6FC),
      ),
      home: const HasilUjianPage(),
    );
  }
}

class HasilUjianPage extends StatelessWidget {
  const HasilUjianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hasil Ujian',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFF0A58CA),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Top Summary Card
            _buildTopScoreCard(),
            const SizedBox(height: 14),

            // 2x2 Stats Grid
            _buildStatsGrid(),
            const SizedBox(height: 14),

            // Pembahasan Soal Header Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Text(
                  'Pembahasan Soal',
                  style: TextStyle(
                    color: Color(0xFF0D6EFD),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Item Pembahasan Soal
            _buildQuestionCard(
              number: 'Nomor 1',
              isCorrect: true,
              question:
                  'Bentuk paling sederhana dari persamaan linear 3x + 7 = 22 menghasilkan nilai x sama dengan...',
              userAnswer: 'B. x = 5',
              isUserAnswerCorrect: true,
              explanationTitle: 'Penjelasan Singkat:',
              explanationContent:
                  '3x + 7 = 22 → 3x = 22 - 7 → 3x = 15 → x = 5.\nJawaban tepat!',
            ),
            const SizedBox(height: 14),

            _buildQuestionCard(
              number: 'Nomor 5',
              isCorrect: false,
              question:
                  'Selisih umur seorang kakak dan adiknya adalah 4 tahun. Jika jumlah umur keduanya saat ini adalah 28 tahun, berapakah umur adik?',
              userAnswer: 'C. 14 Tahun (Salah)',
              isUserAnswerCorrect: false,
              keyAnswer: 'A. 12 Tahun',
              explanationTitle: 'Langkah Penyelesaian:',
              hasIconInExplanation: true,
              explanationContent:
                  'Langkah 1: Misalkan umur adik = x tahun, maka umur kakak = x + 4 tahun.\n'
                  'Langkah 2: Bentuk persamaannya: x + (x + 4) = 28 → 2x + 4 = 28.\n'
                  'Langkah 3: 2x = 24 → x = 12 tahun. Jadi umur adik adalah 12 tahun.',
            ),
            const SizedBox(height: 14),

            _buildQuestionCard(
              number: 'Nomor 12',
              isCorrect: true,
              question:
                  'Tentukan himpunan penyelesaian dari pertidaksamaan 2(y - 3) ≤ 4y + 2 untuk y bilangan bulat!',
              userAnswer: 'D. y ≥ -4',
              isUserAnswerCorrect: true,
              explanationTitle: 'Penjelasan Singkat:',
              explanationContent:
                  '2y - 6 ≤ 4y + 2 → -2y ≤ 8 → y ≥ -4 (ingat: pembagian bilangan negatif membalik tanda ketidaksamaan).',
            ),
            const SizedBox(height: 20),

            // Tombol Kembali ke Beranda
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.home_outlined, color: Colors.white, size: 20),
                label: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopScoreCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1F8F6),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          // Badge Subjek
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0EFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.grid_view_rounded, size: 14, color: Color(0xFF0B63E5)),
                SizedBox(width: 6),
                Text(
                  'Matematika • Kelas VIII',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B63E5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Judul Ujian
          const Text(
            'Persamaan Linear Satu Variabel',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),

          // Waktu Selesai
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
              SizedBox(width: 5),
              Text(
                'Selesai pada 18 Mei 2024, 10.30 WIB',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Circular Score Chart
          CustomPaint(
            painter: CircleGaugePainter(
              progress: 0.85,
              activeColor: const Color(0xFF007E59),
              trackColor: const Color(0xFFE2E8F0),
              strokeWidth: 9,
            ),
            child: const SizedBox(
              width: 120,
              height: 120,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '85',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'KKM: 75',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lulus Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD6EFE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified, size: 16, color: Color(0xFF0A7B54)),
                SizedBox(width: 6),
                Text(
                  'LULUS / TUNTAS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A7B54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Keterangan Kelulusan
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Hebat! Nilaimu melampaui batas ketuntasan minimum. Terus pertahankan ritme belajar ini!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.check,
                iconColor: const Color(0xFF0B7B53),
                iconBgColor: const Color(0xFFD6F0E4),
                title: 'Benar',
                value: '13',
                suffix: 'Soal',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatItem(
                icon: Icons.close,
                iconColor: const Color(0xFFD32F2F),
                iconBgColor: const Color(0xFFFFE5E5),
                title: 'Salah',
                value: '2',
                suffix: 'Soal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF0D6EFD),
                iconBgColor: const Color(0xFFE2EFFF),
                title: 'Durasi',
                value: '14m 20d',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatItem(
                icon: Icons.bar_chart,
                iconColor: const Color(0xFF0D6EFD),
                iconBgColor: const Color(0xFFE2EFFF),
                title: 'Peringkat',
                value: '#4',
                suffix: '/ 32',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: iconBgColor,
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  children: suffix != null
                      ? [
                          TextSpan(
                            text: ' $suffix',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF64748B),
                            ),
                          )
                        ]
                      : [],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String number,
    required bool isCorrect,
    required String question,
    required String userAnswer,
    required bool isUserAnswerCorrect,
    String? keyAnswer,
    required String explanationTitle,
    required String explanationContent,
    bool hasIconInExplanation = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Soal & Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFFD6EFE5) : const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check : Icons.close,
                      size: 13,
                      color: isCorrect ? const Color(0xFF0A7B54) : const Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCorrect ? 'Jawaban Benar' : 'Perlu Evaluasi',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? const Color(0xFF0A7B54) : const Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Deskripsi Pertanyaan
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Jawaban Anda
          Row(
            children: [
              const Text(
                'Jawaban Anda: ',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isUserAnswerCorrect ? const Color(0xFFDCF6E7) : const Color(0xFFFFDFDF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  userAnswer,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isUserAnswerCorrect ? const Color(0xFF087443) : const Color(0xFFC5221F),
                  ),
                ),
              ),
            ],
          ),

          // Kunci Jawaban jika salah
          if (keyAnswer != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  'Kunci Jawaban: ',
                  style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCF6E7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    keyAnswer,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF087443),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),

          // Kotak Penjelasan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (hasIconInExplanation) ...[
                      const Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFF0369A1)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      explanationTitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: hasIconInExplanation
                            ? const Color(0xFF0369A1)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  explanationContent,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    height: 1.4,
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

// Custom Painter untuk Lingkaran Nilai
class CircleGaugePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  CircleGaugePainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background track ring
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc (-90 derajat adalah posisi jam 12)
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}