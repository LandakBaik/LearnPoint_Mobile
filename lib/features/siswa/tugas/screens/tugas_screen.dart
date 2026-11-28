  import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/core/widgets/authenticated_file_preview_page.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_pilgan_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/services/task_api_service.dart';

void main() {
  runApp(const LearnPointApp());
}

class LearnPointApp extends StatelessWidget {
  const LearnPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnPoint',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      ),
      home: const TugasPage(),
    );
  }
}

class TugasPage extends StatefulWidget {
  const TugasPage({super.key});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  List<Map<String, dynamic>> tasks = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedSort = 'terbaru';

  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color purpleHeaderStart = Color(0xFF7B4AE2);
  static const Color purpleHeaderMid = Color(0xFF6D3CE0);
  static const Color purpleHeaderEnd = Color(0xFF8154E8);
  static const Color darkColor = Color(0xFF1E1B4B);
  static const Color mutedColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  final List<Map<String, String>> sortOptions = [
    {
      'value': 'terbaru',
      'label': 'Deadline Terbaru',
    },
    {
      'value': 'terlama',
      'label': 'Deadline Terlama',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // ============================================================
  // MENGAMBIL DATA TUGAS YANG BELUM DIKERJAKAN
  // ============================================================

  Future<void> _loadTasks() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await TaskApiService.getTasks();

      if (!mounted) return;

      // Hanya tampilkan tugas yang belum dikumpulkan.
      final pendingTasks = result.where((task) {
        return task['is_submitted'] != true;
      }).toList();

      setState(() {
        tasks = pendingTasks;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // MENGAMBIL NAMA GURU
  // ============================================================

  String _getTeacherName(Map<String, dynamic> task) {
    final guru = task['guru']?.toString().trim();

    if (guru != null && guru.isNotEmpty) {
      return guru;
    }

    return 'GURU PENGAMPU';
  }

  // ============================================================
  // MENGAMBIL JENIS TUGAS
  // ============================================================

  String _getTaskType(Map<String, dynamic> task) {
    final type = task['tipe']?.toString().toLowerCase().trim();

    if (type == 'pilihan_ganda' || type == 'pilgan') {
      return 'Pilihan Ganda';
    }

    return 'Upload';
  }

  // ============================================================
  // MENGAMBIL URL LAMPIRAN
  // ============================================================

  String? _getAttachmentUrl(Map<String, dynamic> task) {
    final url = task['file_url']?.toString().trim();

    if (url == null || url.isEmpty) {
      return null;
    }

    return url;
  }

  // ============================================================
  // MEMBUKA LAMPIRAN (TERAUTENTIKASI DI DALAM APLIKASI)
  // ============================================================

  Future<void> _openAttachment(
    Map<String, dynamic> task,
    String url,
  ) async {
    final resolvedUrl = ApiConfig.resolveUrl(url);
    if (resolvedUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat lampiran tidak valid.'),
        ),
      );
      return;
    }

    final rawLampiran = task['file_lampiran']?.toString().trim() ?? '';
    final fileName = rawLampiran.isNotEmpty
        ? rawLampiran.split('/').last
        : 'Lampiran Tugas';

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthenticatedFilePreviewPage(
          fileName: fileName,
          fileUrl: resolvedUrl,
        ),
      ),
    );
  }

  // ============================================================
  // PARSE DEADLINE
  // ============================================================

  DateTime? _parseDeadline(Map<String, dynamic> task) {
    final value = task['deadline']?.toString();

    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  // ============================================================
  // STATUS PENGUMPULAN
  // ============================================================

  bool _isSubmitted(Map<String, dynamic> task) {
    return task['is_submitted'] == true;
  }

  bool _isLate(Map<String, dynamic> task) {
    if (_isSubmitted(task)) {
      return false;
    }

    final deadline = _parseDeadline(task);

    if (deadline == null) {
      return false;
    }

    return DateTime.now().isAfter(deadline);
  }

  // ============================================================
  // FORMAT TANGGAL
  // ============================================================

  String _formatDeadline(Map<String, dynamic> task) {
    final deadline = _parseDeadline(task);

    if (deadline == null) {
      return 'Deadline tidak tersedia';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = deadline.day.toString().padLeft(2, '0');
    final month = months[deadline.month - 1];
    final year = deadline.year;

    final hour = deadline.hour.toString().padLeft(2, '0');
    final minute = deadline.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute WIB';
  }

  // ============================================================
  // FORMAT SISA WAKTU
  // ============================================================

  String _getRemainingTime(Map<String, dynamic> task) {
    if (_isLate(task)) {
      return 'Terlambat';
    }

    final deadline = _parseDeadline(task);

    if (deadline == null) {
      return 'Deadline tidak tersedia';
    }

    final difference = deadline.difference(DateTime.now());

    if (difference.inDays >= 1) {
      return '${difference.inDays} hari lagi';
    }

    if (difference.inHours >= 1) {
      return '${difference.inHours} jam lagi';
    }

    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} menit lagi';
    }

    return 'Segera dikumpulkan';
  }

  // ============================================================
  // SORTING TUGAS
  // ============================================================

  List<Map<String, dynamic>> get sortedTasks {
    final result = List<Map<String, dynamic>>.from(tasks);

    result.sort((a, b) {
      final deadlineA = _parseDeadline(a);
      final deadlineB = _parseDeadline(b);

      if (deadlineA == null && deadlineB == null) {
        return 0;
      }

      if (deadlineA == null) return 1;
      if (deadlineB == null) return -1;

      if (selectedSort == 'terbaru') {
        return deadlineB.compareTo(deadlineA);
      }

      return deadlineA.compareTo(deadlineB);
    });

    return result;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _buildPurpleHeader(context),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 360;
                final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

                return RefreshIndicator(
                  color: purpleHeaderStart,
                  onRefresh: _loadTasks,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      18,
                      horizontalPadding,
                      35,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSortDropdown(),
                        const SizedBox(height: 18),
                        _buildTaskList(isSmallScreen),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PURPLE GRADIENT HEADER (REFERENSI MAPEL / DASHBOARD)
  // ============================================================

  Widget _buildPurpleHeader(BuildContext context) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < 360;
    final pendingCount = tasks.length;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            purpleHeaderStart,
            purpleHeaderMid,
            purpleHeaderEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 16 : 20,
            12,
            isSmallScreen ? 16 : 20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBackButton(),
                  if (!isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$pendingCount Tugas',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Tugas Terbaru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 22 : 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daftar tugas yang belum kamu kerjakan.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 12 : 13,
                  height: 1.45,
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOMBOL KEMBALI
  // ============================================================

  Widget _buildBackButton() {
    return InkWell(
      onTap: () {
        Navigator.maybePop(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
            Text(
              'Kembali',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN PENGURUTAN
  // ============================================================

  Widget _buildSortDropdown() {
    return Row(
      children: [
        const Icon(
          Icons.sort_rounded,
          size: 19,
          color: primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          'Urutkan:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: darkColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSort,
                isExpanded: true,
                isDense: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: mutedColor,
                  size: 20,
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: darkColor,
                ),
                items: sortOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedSort = value;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DAFTAR TUGAS
  // ============================================================

  Widget _buildTaskList(bool isSmallScreen) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    final displayedTasks = sortedTasks;

    if (displayedTasks.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: displayedTasks.map((task) {
        return _buildTaskCard(
          task: task,
          isSmallScreen: isSmallScreen,
        );
      }).toList(),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 45,
              color: Color(0xFF98A6B9),
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal mengambil data tugas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              errorMessage ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.assignment_turned_in_outlined,
              size: 32,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Tidak Ada Tugas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Semua tugas sudah kamu kerjakan. '
            'Belum ada tugas lain yang perlu dikumpulkan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.6,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TASK CARD
  // ============================================================

  Widget _buildTaskCard({
    required Map<String, dynamic> task,
    required bool isSmallScreen,
  }) {
    final late = _isLate(task);

    final remainingBg =
        late ? const Color(0xFFFEE2E2) : const Color(0xFFEEF2FF);
    final remainingColor =
        late ? const Color(0xFF9F1239) : primaryColor;

    final teacherName = _getTeacherName(task);
    final taskType = _getTaskType(task);
    final subject = task['mapel']?.toString() ?? 'Mata Pelajaran';
    final title = task['judul']?.toString() ?? 'Tanpa Judul';
    final deadline = _formatDeadline(task);
    final remaining = _getRemainingTime(task);
    final attachmentUrl = _getAttachmentUrl(task);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARIS ATAS: MAPEL DAN SISA WAKTU
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3730A3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: remainingBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      late
                          ? Icons.warning_amber_rounded
                          : Icons.access_time_rounded,
                      size: 13,
                      color: remainingColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      remaining,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: remainingColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // JUDUL TUGAS
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 15 : 16.5,
              fontWeight: FontWeight.w800,
              color: darkColor,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 10),

          // GURU & JENIS TUGAS
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13.5,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 170),
                      child: Text(
                        teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EEFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  taskType,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: purpleHeaderStart,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // DEADLINE
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13.5,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Tenggat: $deadline',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: mutedColor,
                  ),
                ),
              ),
            ],
          ),

          // LAMPIRAN GURU
          if (attachmentUrl != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _openAttachment(task, attachmentUrl),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file_rounded,
                      size: 15,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Lihat Lampiran Guru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // TOMBOL KERJAKAN
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _openTaskDetail(task),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kerjakan Tugas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGASI KE DETAIL TUGAS
  // ============================================================

  void _openTaskDetail(Map<String, dynamic> task) {
    final taskType = task['tipe']?.toString() ?? 'upload';

    final late = _isLate(task);
    final remaining = _getRemainingTime(task);

    final taskModel = TaskModel(
      id: task['id'].toString(),
      subject: task['mapel']?.toString() ?? 'Mata Pelajaran',
      title: task['judul']?.toString() ?? 'Tanpa Judul',
      description: task['deskripsi']?.toString() ?? '',
      deadline: task['deadline']?.toString() ?? '',
      timeRemainingTag: remaining,
      subjectColor: const Color(0xFF687995),
      accentBorderColor: late
          ? const Color(0xFFE45B5B)
          : primaryColor,
      icon: Icons.description_outlined,
      iconBgColor: const Color(0xFFF0F4F9),
      isSubmitted: false,
      type: taskType,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (taskType == 'pilihan_ganda' || taskType == 'pilgan') {
            return DetailTugasPilganScreen(
              task: taskModel,
            );
          }

          return DetailTugasPage(
            task: taskModel,
          );
        },
      ),
    ).then((_) {
      // Muat ulang data setelah kembali dari detail tugas.
      if (mounted) {
        _loadTasks();
      }
    });
  }
}