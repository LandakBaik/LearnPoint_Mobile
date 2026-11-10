import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/student_profile_model.dart';
import '../models/task_model.dart';
import 'akun.dart';
import 'detail_materi.dart';
import 'detail_tugas.dart';
import 'materi.dart';
import 'notifikasi.dart';
import 'tugas.dart';
import 'widgets/hero_banner_widget.dart';

class SiswaDashboardScreen extends StatefulWidget {
  const SiswaDashboardScreen({super.key});

  static const studentProfile = StudentProfileModel(
    name: 'Rolanda Rafa',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMPN 14 Jember',
    initials: 'R',
    hasNotification: true,
    username: 'rolanda_rafa',
    email: 'rolanda.rafa@learnpoint.sch.id',
    address: 'Jl. Kalimantan No. 37, Sumbersari, Jember, Jawa Timur',
    dateOfBirth: '14 Mei 2011',
    gender: 'Laki-laki',
    parentName: 'Bambang Sudarmono',
    parentPhone: '0812-3456-7890',
    nisn: '01234',
    academicYear: '2026/2027',
  );

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  int _currentTaskIndex = 0;

  final List<Map<String, dynamic>> _taskList = [
    {
      'id': 't1',
      'subject': 'Matematika',
      'subjectBg': const Color(0xFFE0E7FF),
      'subjectColor': const Color(0xFF3730A3),
      'remaining': 'Sisa 1 Hari',
      'remainingBg': const Color(0xFFFEE2E2),
      'remainingColor': const Color(0xFF9F1239),
      'title': 'Latihan Soal Persamaan Linear Dua Variabel',
      'deadline': 'Batas: Besok, 23:59 WIB',
      'progressText': '0/3 Soal Selesai',
    },
    {
      'id': 't2',
      'subject': 'Bahasa Inggris',
      'subjectBg': const Color(0xFFDCFCE7),
      'subjectColor': const Color(0xFF166534),
      'remaining': 'Sisa 3 Hari',
      'remainingBg': const Color(0xFFFEF3C7),
      'remainingColor': const Color(0xFF92400E),
      'title': 'Writing Task: Descriptive Text of Solar System',
      'deadline': 'Batas: Kamis, 18:00 WIB',
      'progressText': '1/2 Soal Selesai',
    },
    {
      'id': 't3',
      'subject': 'IPA Biologi',
      'subjectBg': const Color(0xFFCCFBF1),
      'subjectColor': const Color(0xFF0F5F57),
      'remaining': 'Sisa 5 Hari',
      'remainingBg': const Color(0xFFE0E7FF),
      'remainingColor': const Color(0xFF3730A3),
      'title': 'Kuis Organ Pencernaan & Enzim Manusia',
      'deadline': 'Batas: Sabtu, 23:59 WIB',
      'progressText': '0/5 Soal Selesai',
    },
  ];

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NotificationScreen()),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const AkunScreen(profile: SiswaDashboardScreen.studentProfile),
      ),
    );
  }

  void _openTaskDetail(Map<String, dynamic> taskMap) {
    final taskModel = TaskModel(
      id: taskMap['id'] as String,
      subject: taskMap['subject'] as String,
      title: taskMap['title'] as String,
      deadline: (taskMap['deadline'] as String).replaceFirst('Batas: ', ''),
      timeRemainingTag: taskMap['remaining'] as String,
      subjectColor: taskMap['subjectColor'] as Color,
      accentBorderColor: taskMap['subjectColor'] as Color,
      icon: Icons.assignment_outlined,
      iconBgColor: taskMap['subjectBg'] as Color,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailTugasPage(task: taskModel),
      ),
    );
  }

  void _showScheduleZoomDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(14),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  'assets/images/jadwal.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.65),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header & Hero Area with GIF Background and Floating Banner
            HeroBannerWidget(
              profile: SiswaDashboardScreen.studentProfile,
              onNotificationTap: _openNotifications,
              onProfileTap: _openProfile,
              onContinueTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DetailMateriPage(
                      title: 'Matematika · Bab 5',
                      subject: 'Matematika',
                      duration: '15 Menit',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 2. Section: Tugas Terbaru
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTugasTerbaruSection(),
            ),

            const SizedBox(height: 24),

            // 3. Section: Materi Baru Minggu Ini
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMateriBaruSection(),
            ),

            const SizedBox(height: 24),

            // 4. Section: Jadwal Pelajaran Kelas VIII-A
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildJadwalPelajaranSection(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: TUGAS TERBARU SECTION ---
  Widget _buildTugasTerbaruSection() {
    final currentTask = _taskList[_currentTaskIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tugas Terbaru',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1B4B),
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentTaskIndex + 1} / ${_taskList.length}',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF374151),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TugasPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Lihat Semua ›',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF4F46E5),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Task Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject & Remaining Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: currentTask['subjectBg'] as Color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentTask['subject'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        color: currentTask['subjectColor'] as Color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: currentTask['remainingBg'] as Color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentTask['remaining'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        color: currentTask['remainingColor'] as Color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                currentTask['title'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1B4B),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 6),

              // Deadline
              Text(
                currentTask['deadline'] as String,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF5B6275),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              const SizedBox(height: 14),

              // Progress & Kerjakan Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTask['progressText'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF5B6275),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openTaskDetail(currentTask),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    label: const Icon(Icons.arrow_forward_rounded, size: 18),
                    icon: const Text('Kerjakan'),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Pagination Indicators and Prev/Next buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(_taskList.length, (index) {
                      final isActive = index == _currentTaskIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  // Arrows
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (_currentTaskIndex > 0) {
                            setState(() => _currentTaskIndex--);
                          }
                        },
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5E7EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Color(0xFF1E1B4B),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          if (_currentTaskIndex < _taskList.length - 1) {
                            setState(() => _currentTaskIndex++);
                          }
                        },
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F46E5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET: MATERI BARU MINGGU INI SECTION ---
  Widget _buildMateriBaruSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Materi Baru Minggu Ini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1B4B),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Diunggah guru untuk bahan ujian',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF5B6275),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Materi(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Lihat Semua ›',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF4F46E5),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Materi Card
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Illustration Header Area
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDBEAFE), Color(0xFFCCFBF1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Center icon: Lungs biology illustration
                    Center(
                      child: CustomPaint(
                        size: const Size(64, 64),
                        painter: _LungsIconPainter(
                          color: const Color(0xFF0F5F57),
                        ),
                      ),
                    ),
                    // Badge: IPA Biologi (Top-Left)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'IPA Biologi',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF0F5F57),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Badge: 15 Menit (Bottom-Right)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B4B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '15 Menit',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Materi Details & Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Video & PDF Rangkuman',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF3730A3),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sistem Pernapasan Manusia',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bu Siti, S.Pd',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF5B6275),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const DetailMateriPage(
                                title: 'Sistem Pernapasan Manusia',
                                subject: 'IPA Biologi',
                                duration: '15 Menit',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2FF),
                          foregroundColor: const Color(0xFF4F46E5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Pelajari Materi'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET: JADWAL PELAJARAN KELAS VIII-A SECTION ---
  Widget _buildJadwalPelajaranSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Jadwal Pelajaran\nKelas VIII-A',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1B4B),
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Sem. Ganjil 2026/2027',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF374151),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Schedule Image Holder Card
        Container(
          height: 270,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFE0F2FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Schedule image with fallback to center preview icon and texts
              Image.asset(
                'assets/images/jadwal.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          size: 56,
                          color: Color(0xFF3730A3),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Foto jadwal pelajaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3730A3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ganti dengan foto jadwal kelas VIII-A',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF5B6275),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Bottom-Right Action Buttons
              Positioned(
                right: 12,
                bottom: 12,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showScheduleZoomDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E1B4B),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text('Perbesar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showNotice('Mengunduh jadwal pelajaran...'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Unduh'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- CUSTOM PAINTER: LUNGS BIOLOGY ICON ---
class _LungsIconPainter extends CustomPainter {
  final Color color;
  _LungsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Trachea
    canvas.drawLine(const Offset(12, 3), const Offset(12, 10), paint);

    // Left Lung branch & lobe
    final leftPath = Path()
      ..moveTo(12, 10)
      ..cubicTo(10, 10, 9, 11, 8, 13)
      ..cubicTo(5, 13, 5, 16, 5, 18)
      ..cubicTo(5, 19.5, 7, 20.5, 10, 19)
      ..cubicTo(11, 18, 12, 15, 12, 13);
    canvas.drawPath(leftPath, paint);

    // Right Lung branch & lobe
    final rightPath = Path()
      ..moveTo(12, 10)
      ..cubicTo(14, 10, 15, 11, 16, 13)
      ..cubicTo(19, 13, 19, 16, 19, 18)
      ..cubicTo(19, 19.5, 17, 20.5, 14, 19)
      ..cubicTo(13, 18, 12, 15, 12, 13);
    canvas.drawPath(rightPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LungsIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
