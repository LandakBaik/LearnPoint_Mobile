import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:learnpoint_mobile/features/siswa/dashboard/providers/notification_provider.dart';
import 'package:learnpoint_mobile/features/siswa/profile/providers/profile_provider.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/screens/akun_screen.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/detail_materi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_pilgan_screen.dart';
import 'package:learnpoint_mobile/features/siswa/mapel/screens/mapel_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/tugas_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/widgets/task_card_widget.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/hero_banner_widget.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/materi_dashboard_widget.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/data/gacha_service.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/screens/inventory_screen.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/services/task_api_service.dart';

class SiswaDashboardScreen extends StatefulWidget {
  const SiswaDashboardScreen({super.key});

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  final GlobalKey<MateriDashboardWidgetState> _materiWidgetKey =
      GlobalKey<MateriDashboardWidgetState>();
  LastReadMateri? _lastReadMateri;

  // DATA TUGAS DARI API
  List<Map<String, dynamic>> _taskList = [];
  bool _isLoadingTasks = true;
  String? _taskError;
  bool _isBannerLoading = GachaService.activeBannerNotifier.value == null;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<ProfileProvider>().ensureLoaded();
    });

    _loadLastReadMateri();
    _loadDashboardTasks();
    _loadActiveBanner();
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _refreshProviders(),
      _loadLastReadMateri(),
      _loadDashboardTasks(),
      _loadActiveBanner(),
      if (_materiWidgetKey.currentState != null)
        _materiWidgetKey.currentState!.refresh(),
    ]);
  }

  Future<void> _refreshProviders() async {
    try {
      await context.read<ProfileProvider>().fetchProfile();
    } on ProviderNotFoundException {
      // Abaikan jika provider tidak tersedia pada tree widget.
    }
    if (!mounted) return;
    try {
      await context.read<NotificationProvider>().refreshUnreadCount();
    } on ProviderNotFoundException {
      // Abaikan jika provider tidak tersedia pada tree widget.
    }
  }

  Future<void> _loadActiveBanner() async {
    if (GachaService.activeBannerNotifier.value == null && mounted) {
      setState(() => _isBannerLoading = true);
    }

    try {
      await GachaService.fetchGachaStatus();
    } catch (_) {
      // Fallback ke banner default/lokal jika offline
    } finally {
      if (mounted && _isBannerLoading) {
        setState(() => _isBannerLoading = false);
      }
    }
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
    return {'bg': const Color(0xFFDBEAFE), 'text': const Color(0xFF1D4ED8)};
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
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const AkunScreen()));
  }

  void _openTaskDetail(Map<String, dynamic> taskMap) {
    final taskType = (taskMap['tipe'] ?? 'upload')
        .toString()
        .toLowerCase()
        .trim();

    final isPilgan = taskType == 'pilihan_ganda' || taskType == 'pilgan';

    final taskModel = TaskModel(
      id: taskMap['id'].toString(),
      subject: taskMap['subject']?.toString() ?? 'Mata Pelajaran',
      title: taskMap['title']?.toString() ?? 'Tugas tanpa judul',
      description:
          taskMap['description']?.toString() ??
          taskMap['deskripsi']?.toString() ??
          '',
      deadline: (taskMap['deadline']?.toString() ?? '').replaceFirst(
        'Batas: ',
        '',
      ),
      timeRemainingTag: taskMap['remaining']?.toString() ?? '',
      subjectColor:
          taskMap['subjectColor'] as Color? ?? const Color(0xFF687995),
      accentBorderColor:
          taskMap['subjectColor'] as Color? ?? const Color(0xFF687995),
      icon: Icons.assignment_outlined,
      iconBgColor: taskMap['subjectBg'] as Color? ?? const Color(0xFFF0F4F9),
      isSubmitted: false,
      type: isPilgan ? 'pilihan_ganda' : 'upload',
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          if (isPilgan) {
            return DetailTugasPilganScreen(task: taskModel);
          }

          return DetailTugasPage(task: taskModel);
        },
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: const Color(0xFF2563EB),
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header & Hero Area
            ValueListenableBuilder<BannerItemModel?>(
              valueListenable: GachaService.activeBannerNotifier,
              builder: (context, activeBanner, _) {
                return HeroBannerWidget(
                  profile: context.watch<ProfileProvider>().currentProfile,
                  activeBanner: activeBanner,
                  isBannerLoading: _isBannerLoading,
                  onNotificationTap: _openNotifications,
                  onProfileTap: _openProfile,
                  onBannerTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Inventory(initialTab: 1),
                      ),
                    );
                  },
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
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MapelScreen(),
                        ),
                      );
                    }

                    _loadLastReadMateri();
                  },
                );
              },
            ),

            const SizedBox(height: 50),

            // 2. Section: Tugas Terbaru
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TaskCardWidget(
                tasks: _taskList,
                isLoading: _isLoadingTasks,
                error: _taskError,
                onRetry: _loadDashboardTasks,
                onSeeAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const TugasPage()),
                  );
                },
                onTapTask: _openTaskDetail,
              ),
            ),

            const SizedBox(height: 24),

            // 3. Section: Materi Baru Minggu Ini
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MateriDashboardWidget(key: _materiWidgetKey),
            ),

            const SizedBox(height: 24),

            // 4. Section: Jadwal Pelajaran
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildJadwalPelajaranSection(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      ),
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
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Sem. Ganjil 2026/2027',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF1D4ED8),
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
              colors: [Color(0xFFDBEAFE), Color(0xFFEFF6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Schedule image with fallback
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
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Foto jadwal pelajaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1D4ED8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ganti dengan foto jadwal kelas VIII-A',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
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
                        foregroundColor: const Color(0xFF1E293B),
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
                      onPressed: () {
                        _showNotice('Mengunduh jadwal pelajaran...');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
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