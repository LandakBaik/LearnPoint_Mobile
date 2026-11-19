import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/screens/akun_screen.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/detail_materi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_screen.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/materi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/tugas_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/hero_banner_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/services/task_api_service.dart';

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
  LastReadMateri? _lastReadMateri;

  // DATA TUGAS DARI API
  List<Map<String, dynamic>> _taskList = [];
  bool _isLoadingTasks = true;
  String? _taskError;

  @override
  void initState() {
    super.initState();
    _loadLastReadMateri();
    _loadDashboardTasks();
  }

  Future<void> _loadLastReadMateri() async {
    final data = await MateriPreferencesService.getLastRead();
    if (!mounted) return;

    setState(() {
      _lastReadMateri = data;
    });
  }

  Future<void> _loadDashboardTasks() async {
    setState(() {
      _isLoadingTasks = true;
      _taskError = null;
    });

    try {
      final result = await TaskApiService.getTasks();

      if (!mounted) return;

      final pendingTasks = result.where((task) {
        final submitted = task['is_submitted'];

        return !(submitted == true ||
            submitted == 1 ||
            submitted == '1' ||
            submitted?.toString().toLowerCase() == 'true');
      }).toList();

      pendingTasks.sort((a, b) {
        final dateA = DateTime.tryParse(a['deadline']?.toString() ?? '');
        final dateB = DateTime.tryParse(b['deadline']?.toString() ?? '');

        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateA.compareTo(dateB);
      });

      setState(() {
        _taskList = pendingTasks.map((task) {
          final subject = task['mapel']?.toString() ?? 'Mata Pelajaran';
          final deadline = task['deadline']?.toString() ?? '';

          final colors = _getSubjectColors(subject);

          return {
            ...task,
            'id': task['id']?.toString() ?? '',
            'subject': subject,
            'subjectBg': colors['bg'],
            'subjectColor': colors['text'],
            'remaining': _getTaskRemaining(deadline),
            'remainingBg': const Color(0xFFFEE2E2),
            'remainingColor': const Color(0xFF9F1239),
            'title': task['judul']?.toString() ?? 'Tugas tanpa judul',
            'deadlineRaw': deadline,
            'deadline': _getTaskDeadlineText(deadline),
            'progressText': 'Belum dikumpulkan',
          };
        }).toList();

        _currentTaskIndex = 0;
        _isLoadingTasks = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingTasks = false;
        _taskError = e.toString();
      });
    }
  }

  Map<String, Color> _getSubjectColors(String subject) {
    final value = subject.toLowerCase();

    if (value.contains('matematika')) {
      return {'bg': const Color(0xFFE0E7FF), 'text': const Color(0xFF3730A3)};
    }

    if (value.contains('inggris')) {
      return {'bg': const Color(0xFFDCFCE7), 'text': const Color(0xFF166534)};
    }

    if (value.contains('ipa')) {
      return {'bg': const Color(0xFFCCFBF1), 'text': const Color(0xFF0F5F57)};
    }

    return {'bg': const Color(0xFFF3E8FF), 'text': const Color(0xFF7E22CE)};
  }

  String _getTaskRemaining(String deadline) {
    final date = DateTime.tryParse(deadline);

    if (date == null) return 'Deadline tidak tersedia';

    final difference = date.toLocal().difference(DateTime.now());

    if (difference.isNegative) return 'Terlambat';
    if (difference.inDays >= 1) return 'Sisa ${difference.inDays} Hari';
    if (difference.inHours >= 1) return 'Sisa ${difference.inHours} Jam';
    if (difference.inMinutes >= 1) {
      return 'Sisa ${difference.inMinutes} Menit';
    }

    return 'Segera berakhir';
  }

  String _getTaskDeadlineText(String deadline) {
    final date = DateTime.tryParse(deadline);

    if (date == null) return 'Batas: Tidak tersedia';

    final localDate = date.toLocal();

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return 'Batas: ${localDate.day} ${months[localDate.month - 1]} '
        '${localDate.year}, $hour:$minute WIB';
  }

  // Fungsi _loadDashboardTasks() dan fungsi pembantunya
  // diletakkan DI SINI.

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationScreen()));
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
      description:
          taskMap['description']?.toString() ??
          taskMap['deskripsi']?.toString() ??
          '',
      deadline: (taskMap['deadline'] as String).replaceFirst('Batas: ', ''),
      timeRemainingTag: taskMap['remaining'] as String,
      subjectColor: taskMap['subjectColor'] as Color,
      accentBorderColor: taskMap['subjectColor'] as Color,
      icon: Icons.assignment_outlined,
      iconBgColor: taskMap['subjectBg'] as Color,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailTugasPage(task: taskModel)),
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
              continueSubject: _lastReadMateri?.subject,
              continueTitle: _lastReadMateri?.title,
              onContinueTap: () async {
                if (_lastReadMateri != null) {
                  MateriItemModel? itemModel;
                  if (_lastReadMateri!.id != null) {
                    itemModel = MateriItemModel(
                      id: _lastReadMateri!.id!,
                      judul: _lastReadMateri!.title,
                      deskripsi: _lastReadMateri!.deskripsi,
                      urlYoutube: _lastReadMateri!.urlYoutube,
                      fileMateri: _lastReadMateri!.fileMateri,
                      fileUrl: _lastReadMateri!.fileUrl,
                      guru: _lastReadMateri!.guru,
                    );
                  }

                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DetailMateriPage(
                        title: _lastReadMateri!.title,
                        subject: _lastReadMateri!.subject,
                        duration: '15 Menit',
                        materiItem: itemModel,
                      ),
                    ),
                  );
                } else {
                  // Jika belum ada materi yang pernah dibaca, arahkan ke daftar mapel
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const Materi()),
                  );
                }
                _loadLastReadMateri();
              },
            ),

            const SizedBox(height: 65),

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

  Widget _buildTugasTerbaruSection() {
    // 1. Kondisi loading
    if (_isLoadingTasks) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        ),
      );
    }

    // 2. Kondisi jika API mengalami error
    if (_taskError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 10),
            const Text(
              'Gagal memuat tugas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              _taskError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadDashboardTasks,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // 3. Kondisi jika tidak ada tugas

    if (_taskList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER TUGAS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tugas Terbaru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const TugasPage()),
                  );
                },
                child: Text(
                  'Lihat Semua ›',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF4F46E5),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // EMPTY STATE CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8E7F5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.045),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // ILUSTRASI
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 38,
                    color: Color(0xFF6255E8),
                  ),
                ),

                const SizedBox(width: 14),

                // TEKS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yeay, tugasmu kosong!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Belum ada tugas baru untuk dikerjakan. '
                        'Nikmati waktu belajarmu!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          height: 1.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        'Semangat belajar ✨',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6255E8),
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

    // 4. Ambil tugas jika data tersedia
    final safeIndex = _currentTaskIndex < _taskList.length
        ? _currentTaskIndex
        : 0;

    final currentTask = _taskList[safeIndex];

    // LANJUTKAN KODE LAMA DI SINI

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tugas Terbaru',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1B4B),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${_currentTaskIndex + 1} / ${_taskList.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
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
                  child: Text(
                    'Lihat Semua ›',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF4F46E5),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // CARD TUGAS
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // DEKORASI LINGKARAN LAVENDER
              Positioned(
                bottom: -18,
                left: -18,
                child: Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECFE).withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // TITIK LAVENDER
              Positioned(
                bottom: 45,
                left: 55,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB8B4F8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // TITIK PINK
              Positioned(
                bottom: 20,
                left: 80,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCA5B9),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // TITIK KUNING
              Positioned(
                bottom: 12,
                left: 105,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBD38D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // ISI CARD
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BADGE MATA PELAJARAN & DEADLINE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: currentTask['subjectBg'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.menu_book_rounded,
                                size: 14,
                                color: Color(0xFF4F46E5),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  currentTask['subject'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: currentTask['subjectColor'] as Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: currentTask['remainingBg'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Color(0xFFC92A4E),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              currentTask['remaining'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                color: currentTask['remainingColor'] as Color,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // JUDUL TUGAS
                  Text(
                    currentTask['title'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111538),
                      height: 1.35,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DEADLINE
                  Text(
                    currentTask['deadline'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF5B6275),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PAGINATION & TOMBOL KERJAKAN
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4FD),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // PANAH SEBELUMNYA
                                  InkWell(
                                    onTap: () {
                                      if (_currentTaskIndex > 0) {
                                        setState(() {
                                          _currentTaskIndex--;
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.chevron_left_rounded,
                                        color: Color(0xFF4F46E5),
                                        size: 18,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // INDIKATOR DOT
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(_taskList.length, (
                                      index,
                                    ) {
                                      final isActive =
                                          index == _currentTaskIndex;

                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        width: isActive ? 8 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFF4F46E5)
                                              : const Color(0xFFC7D2FE),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }),
                                  ),

                                  const SizedBox(width: 8),

                                  // PANAH BERIKUTNYA
                                  InkWell(
                                    onTap: () {
                                      if (_currentTaskIndex <
                                          _taskList.length - 1) {
                                        setState(() {
                                          _currentTaskIndex++;
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFF4F46E5),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Geser ke kiri atau kanan',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // SPARKLE LAVENDER & KUNING
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          const Positioned(
                            top: -8,
                            left: -6,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFFA5B4FC),
                              size: 15,
                            ),
                          ),

                          const Positioned(
                            top: 8,
                            left: -8,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFFFBBF24),
                              size: 11,
                            ),
                          ),

                          // TOMBOL KERJAKAN
                          Material(
                            color: const Color(0xFF4F46E5),
                            shape: const CircleBorder(),
                            elevation: 5,
                            shadowColor: const Color(0xFF4F46E5)
                                .withOpacity(0.3),
                            child: InkWell(
                              onTap: () => _openTaskDetail(currentTask),
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 46,
                                height: 46,
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 21,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => const Materi()));
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
