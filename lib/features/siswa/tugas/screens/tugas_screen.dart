import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/dashboard/screens/siswa_dashboard_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_pilgan_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';
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
  int selectedTab = 0;

  final List<String> tabs = [
    'Semua',
    'Belum Dikumpulkan',
    'Sudah Dikumpulkan',
    'Terlambat',
  ];

  List<Map<String, dynamic>> tasks = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // MENGAMBIL DATA TUGAS DARI API //

  Future<void> _loadTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await TaskApiService.getTasks();

      if (!mounted) return;

      setState(() {
        tasks = result;
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

  // MEMERIKSA DEADLINE //

  DateTime? _parseDeadline(Map<String, dynamic> task) {
    final value = task['deadline']?.toString();

    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  bool _isLate(Map<String, dynamic> task) {
    if (task['is_submitted'] == true) {
      return false;
    }

    final deadline = _parseDeadline(task);

    if (deadline == null) {
      return false;
    }

    return DateTime.now().isAfter(deadline);
  }

  // FILTER TUGAS BERDASARKAN TAB //

  List<Map<String, dynamic>> get filteredTasks {
    switch (selectedTab) {
      case 1:
        return tasks.where((task) {
          return task['is_submitted'] != true && !_isLate(task);
        }).toList();

      case 2:
        return tasks.where((task) {
          return task['is_submitted'] == true;
        }).toList();

      case 3:
        return tasks.where(_isLate).toList();

      default:
        return tasks;
    }
  }

  // FORMAT TANGGAL //

  String _formatDeadline(Map<String, dynamic> task) {
    final deadline = _parseDeadline(task);

    if (deadline == null) {
      return '-';
    }

    final date = deadline.day.toString().padLeft(2, '0');
    final month = deadline.month.toString().padLeft(2, '0');

    return '$date/$month/${deadline.year}';
  }

  // FORMAT SISA WAKTU //

  String _getRemainingTime(Map<String, dynamic> task) {
    if (task['is_submitted'] == true) {
      return '✓ Dikumpulkan';
    }

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

  // BUILD //

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmallScreen = constraints.maxWidth < 360;

            final double horizontalPadding = screenWidth < 360 ? 16 : 20;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    screenHeight * 0.08,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isSmallScreen),

                      SizedBox(height: isSmallScreen ? 22 : 28),

                      // JUDUL
                      Text(
                        'Daftar Tugas',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 27,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF202D43),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Pantau tenggat waktu dan kumpulkan tugasmu tepat waktu.',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          height: 1.5,
                          color: const Color(0xFF71809A),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // TAB
                      _buildTabs(),

                      const SizedBox(height: 20),

                      // DAFTAR TUGAS DINAMIS
                      _buildTaskList(isSmallScreen),
                    ],
                  ),
                ),

                // FLOATING BUTTON
                Positioned(
                  right: horizontalPadding,
                  bottom: 18,
                  child: _buildFloatingButton(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // HEADER //

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF080C24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const DashboardHeaderWidget(
        profile: SiswaDashboardScreen.studentProfile,
      ),
    );
  }

  // TABS //

  Widget _buildTabs() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final bool active = selectedTab == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF2864E8)
                    : const Color(0xFFE9EDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : const Color(0xFF63738E),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // DAFTAR TUGAS //

  Widget _buildTaskList(bool isSmallScreen) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF2864E8)),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 35),
          child: Column(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 42,
                color: Color(0xFF98A6B9),
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal mengambil data tugas',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202D43),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF71809A)),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _loadTasks,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final displayedTasks = filteredTasks;

    if (displayedTasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 45),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 48,
                color: Color(0xFF9AA9BD),
              ),
              const SizedBox(height: 12),
              Text(
                selectedTab == 0
                    ? 'Belum ada tugas'
                    : 'Tidak ada tugas pada kategori ini',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF71809A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: displayedTasks.map((task) {
        final bool completed = task['is_submitted'] == true;
        final bool late = _isLate(task);

        return _buildTaskCard(
          task: task,
          subject: task['mapel']?.toString() ?? 'Mata Pelajaran',
          title: task['judul']?.toString() ?? 'Tanpa Judul',
          deadline: _formatDeadline(task),
          remaining: _getRemainingTime(task),
          completed: completed,
          isLate: late,
          isSmallScreen: isSmallScreen,
        );
      }).toList(),
    );
  }

  // TASK CARD //

  Widget _buildTaskCard({
    required Map<String, dynamic> task,
    required String subject,
    required String title,
    required String deadline,
    required String remaining,
    required bool completed,
    required bool isLate,
    required bool isSmallScreen,
  }) {
    final Color statusColor = completed
        ? const Color(0xFF13B87A)
        : isLate
        ? const Color(0xFFE45B5B)
        : const Color(0xFFF3A700);

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        final taskType = task['tipe']?.toString() ?? 'upload';

        final taskModel = TaskModel(
          id: task['id'].toString(),
          subject: subject,
          title: title,
          description: task['deskripsi']?.toString() ?? '',
          deadline: task['deadline']?.toString() ?? '',
          timeRemainingTag: remaining,
          subjectColor: const Color(0xFF687995),
          accentBorderColor: statusColor,
          icon: Icons.description_outlined,
          iconBgColor: const Color(0xFFF0F4F9),
          isSubmitted: completed,
          type: taskType,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (taskType == 'pilihan_ganda') {
                return DetailTugasPilganScreen(task: taskModel);
              }

              return DetailTugasPage(task: taskModel);
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE1E6EF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    bottomLeft: Radius.circular(17),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 40 : 43,
                            height: isSmallScreen ? 40 : 43,
                            decoration: BoxDecoration(
                              color: completed
                                  ? const Color(0xFFE8FFF6)
                                  : const Color(0xFFF0F4F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: completed
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF8A9CB6),
                              size: isSmallScreen ? 20 : 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              subject,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: const Color(0xFF687995),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF202D43),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        deadline,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF71809A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            remaining,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              completed
                                  ? 'Sudah Dikumpulkan'
                                  : isLate
                                  ? 'Terlambat'
                                  : 'Belum Dikumpulkan',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Detail',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2864E8),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Color(0xFF2864E8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FLOATING BUTTON //

  Widget _buildFloatingButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // Aksi pencarian dapat ditambahkan berikutnya.
        },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF2864E8),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.search, color: Colors.white, size: 23),
        ),
      ),
    );
  }
}
