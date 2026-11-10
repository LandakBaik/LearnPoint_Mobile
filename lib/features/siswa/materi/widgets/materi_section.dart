import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/detail_materi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/detail_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/soal_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/hasil_ujian_screen.dart';

class MateriSectionWidget extends StatefulWidget {
  final int? mapelId;
  final String subjectName;

  const MateriSectionWidget({
    super.key,
    this.mapelId,
    this.subjectName = 'Matematika',
  });

  @override
  State<MateriSectionWidget> createState() => _MateriSectionWidgetState();
}

class _MateriSectionWidgetState extends State<MateriSectionWidget> {
  int selectedIndex = 0;
  Set<String> completedKeys = {};
  Set<String> bookmarkedKeys = {};
  List<MateriItemModel> apiMateriList = [];
  bool isLoadingApi = false;

  final List<String> tabs = [
    'Materi',
    'Tugas',
    'Ujian',
  ];

  final List<String> fallbackMateri = [
    'Persamaan Linear',
    'Bangun Ruang',
    'Statistika',
    'Peluang',
    'Aljabar',
    'Bilangan Bulat',
  ];

  @override
  void initState() {
    super.initState();
    _loadProgressStates();
    _loadMateriFromApi();
  }

  Future<void> _loadProgressStates() async {
    final completed = await MateriPreferencesService.getCompletedKeys();
    final bookmarked = await MateriPreferencesService.getBookmarkedKeys();
    if (!mounted) return;
    setState(() {
      completedKeys = completed.toSet();
      bookmarkedKeys = bookmarked.toSet();
    });
  }

  Future<void> _loadMateriFromApi() async {
    if (widget.mapelId == null) return;
    setState(() {
      isLoadingApi = true;
    });
    final items = await MateriService.fetchMateriPerMapel(widget.mapelId!);
    if (!mounted) return;
    setState(() {
      apiMateriList = items;
      isLoadingApi = false;
    });
  }

  String get _headerTitle {
    switch (selectedIndex) {
      case 1:
        return 'Daftar Tugas';
      case 2:
        return 'Daftar Ujian';
      default:
        return 'Daftar Materi';
    }
  }

  String get _headerSubtitle {
    switch (selectedIndex) {
      case 1:
        return 'Pantau tenggat waktu dan kumpulkan tugasmu tepat waktu';
      case 2:
        return 'Uji pemahamanmu melalui ujian yang tersedia';
      default:
        return 'Pilih materi yang ingin kamu pelajari';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < 360;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _headerTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28233E),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: Text(
              _headerSubtitle,
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          // Tab pilihan tipe: Materi, Tugas, Ujian
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6336ED)
                            : const Color(0xFFF1EEFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6336ED),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: _buildSelectedTabContent(isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(bool isSmallScreen) {
    if (selectedIndex == 1) {
      return _buildTugasList(isSmallScreen);
    } else if (selectedIndex == 2) {
      return _buildUjianList();
    }
    return _buildMateriGrid();
  }

  Widget _buildMateriGrid() {
    final bool useApiData = apiMateriList.isNotEmpty;
    final int itemCount =
        useApiData ? apiMateriList.length : fallbackMateri.length;

    if (isLoadingApi) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final MateriItemModel? apiItem =
            useApiData ? apiMateriList[index] : null;
        final String title = apiItem?.judul ?? fallbackMateri[index];

        final itemKey = MateriPreferencesService.getMateriKey(
          widget.subjectName,
          title,
        );
        final isCompleted = completedKeys.contains(itemKey);
        final isBookmarked = bookmarkedKeys.contains(itemKey);

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailMateriPage(
                  title: title,
                  subject: widget.subjectName,
                  materiItem: apiItem,
                ),
              ),
            );
            _loadProgressStates();
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF6336ED),
                      size: 32,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isBookmarked)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.bookmark_rounded,
                              color: Color(0xFF6336ED),
                              size: 18,
                            ),
                          ),
                        if (isCompleted)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                      ],
                    ),
                  ],
                ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28233E),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF6336ED),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTugasList(bool isSmallScreen) {
    final subject = widget.subjectName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTaskCard(
          id: 'tugas_1',
          subject: subject,
          title: 'Tugas Mandiri Bab 1: Latihan Soal & Analisis Konsep $subject',
          deadline: '26 Apr 2025, 23:59 WIB',
          remaining: '2 hari 15 jam 00 menit',
          completed: false,
          isSmallScreen: isSmallScreen,
        ),
        const SizedBox(height: 14),
        _buildTaskCard(
          id: 'tugas_2',
          subject: subject,
          title: 'Laporan Praktikum & Rangkuman Materi $subject',
          deadline: '27 Mar 2025, 12:00 WIB',
          remaining: '3 hari 6 jam 00 menit',
          completed: false,
          isSmallScreen: isSmallScreen,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'SUDAH DIKUMPULKAN',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: const Color(0xFF8A9BB5),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE4EAF3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                '1',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF65748C),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildTaskCard(
          id: 'tugas_3',
          subject: subject,
          title: 'Tugas Pendahuluan: Pengenalan Dasar $subject',
          deadline: '20 Mar 2025, 15:00 WIB',
          remaining: '✓  Dikumpulkan tepat waktu',
          completed: true,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String id,
    required String subject,
    required String title,
    required String deadline,
    required String remaining,
    required bool completed,
    required bool isSmallScreen,
  }) {
    final Color statusColor = completed
        ? const Color(0xFF13B87A)
        : const Color(0xFFF3A700);

    return GestureDetector(
      onTap: () {
        final taskModel = TaskModel(
          id: id,
          subject: subject,
          title: title,
          deadline: deadline,
          timeRemainingTag: remaining,
          subjectColor: const Color(0xFF6336ED),
          accentBorderColor: statusColor,
          icon: Icons.description_outlined,
          iconBgColor: const Color(0xFFF0F4F9),
          isSubmitted: completed,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailTugasPage(task: taskModel),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xFFE1E6EF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: completed
                              ? const Color(0xFFD6F8E9)
                              : const Color(0xFFFFEDC6),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          completed ? 'SELESAI' : 'TUGAS',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 8 : 9,
                            fontWeight: FontWeight.w800,
                            color: completed
                                ? const Color(0xFF079762)
                                : const Color(0xFFD68600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 15,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF202D43),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: Color(0xFF98A6B9),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Deadline: $deadline',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10.5 : 11.5,
                                color: const Color(0xFF98A6B9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9FFF5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFC9F4E2),
                            ),
                          ),
                          child: Text(
                            remaining,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9.5 : 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0AA66B),
                            ),
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
      ),
    );
  }

  Widget _buildUjianList() {
    final subject = widget.subjectName;

    return Column(
      children: [
        _buildQuizCard(
          type: 'UJIAN',
          subject: subject,
          grade: 'Kelas VIII',
          title: 'Ujian Harian Bab 1:\n$subject',
          icon: Icons.science_outlined,
          iconColor: const Color(0xFFFF5C5C),
          iconBackground: const Color(0xFFFFD9D9),
          info1: '20 Soal Pilihan\nGanda',
          info2: '30 Menit\nPengerjaan',
          infoIcon1: Icons.quiz_outlined,
          infoIcon2: Icons.access_time,
          bottomInfo: 'Batas: 24 Mei 2024, 23.59 WIB',
          bottomIcon: Icons.event_busy_outlined,
          bottomColor: Colors.red,
          status: 'Belum dikerjakan',
          statusColor: const Color(0xFFDDEBFF),
          buttonText: 'Mulai Ujian',
          buttonIcon: Icons.play_arrow,
          buttonEnabled: true,
        ),
        const SizedBox(height: 14),
        _buildQuizCard(
          type: 'UJIAN',
          subject: subject,
          grade: 'Kelas VIII',
          title: 'Ujian Tengah Semester\n(UTS) $subject',
          icon: Icons.assignment_outlined,
          iconColor: const Color(0xFF0088B5),
          iconBackground: const Color(0xFFD4F0FF),
          info1: '40 Soal Terstruktur',
          info2: '60 Menit Durasi',
          infoIcon1: Icons.help_outline,
          infoIcon2: Icons.timer_outlined,
          bottomInfo: 'Jadwal: 30 Mei 2024 • 08.00–09.00 WIB',
          bottomIcon: Icons.calendar_month_outlined,
          bottomColor: const Color(0xFF0072A8),
          status: 'Belum dimulai',
          statusColor: const Color(0xFFE4EDFA),
          buttonText: 'Lihat Detail',
          buttonIcon: Icons.info_outline,
          buttonEnabled: true,
        ),
        const SizedBox(height: 14),
        _buildQuizCard(
          type: 'UJIAN',
          subject: subject,
          grade: 'Kelas VIII',
          title: 'Evaluasi Pemahaman Dasar\n$subject',
          icon: Icons.insights_outlined,
          iconColor: const Color(0xFF00A875),
          iconBackground: const Color(0xFFBFFFE7),
          info1: '15 Soal Diselesaikan',
          info2: '20 Menit',
          infoIcon1: Icons.check_circle_outline,
          infoIcon2: Icons.access_time,
          bottomInfo: 'Selesai pada 18 Mei 2024, 14.12 WIB',
          bottomIcon: Icons.check_circle_outline,
          bottomColor: const Color(0xFF007A58),
          status: 'Lihat Hasil',
          statusColor: const Color(0xFFE7F7F1),
          buttonText: 'Lihat Hasil',
          buttonIcon: Icons.check,
          buttonEnabled: true,
          completed: true,
        ),
      ],
    );
  }

  Widget _buildQuizCard({
    required String type,
    required String subject,
    required String grade,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String info1,
    required String info2,
    required IconData infoIcon1,
    required IconData infoIcon2,
    required String bottomInfo,
    required IconData bottomIcon,
    required Color bottomColor,
    required String status,
    required Color statusColor,
    required String buttonText,
    required IconData buttonIcon,
    required bool buttonEnabled,
    bool completed = false,
  }) {
    const Color primaryBlue = Color(0xFF0757C9);
    const Color darkText = Color(0xFF13233A);
    const Color secondaryText = Color(0xFF596579);
    const Color cardBlue = Color(0xFFF0F5FF);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E6EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 3,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: iconBackground,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: iconColor,
                            ),
                          ),
                        ),
                        Text(
                          '$subject • $grade',
                          style: const TextStyle(
                            fontSize: 9,
                            color: secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            decoration: BoxDecoration(
              color: cardBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _infoItem(infoIcon1, info1)),
                    Expanded(child: _infoItem(infoIcon2, info2)),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(bottomIcon, size: 15, color: bottomColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        bottomInfo,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: bottomColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      completed ? Icons.visibility_outlined : Icons.circle,
                      size: completed ? 14 : 7,
                      color: completed
                          ? const Color(0xFF007A58)
                          : const Color(0xFF6D778A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: completed
                            ? const Color(0xFF007A58)
                            : const Color(0xFF596579),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (buttonText.isNotEmpty)
                SizedBox(
                  height: 34,
                  child: TextButton(
                    onPressed: buttonEnabled
                        ? () {
                            if (buttonText == 'Lihat Detail') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DetailUjianPage(),
                                ),
                              );
                            } else if (buttonText == 'Mulai Ujian') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QuizStartPage(),
                                ),
                              );
                            } else if (buttonText == 'Lihat Hasil') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HasilUjianPage(),
                                ),
                              );
                            }
                          }
                        : null,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonEnabled
                          ? primaryBlue
                          : const Color(0xFFD7E5FF),
                      foregroundColor:
                          buttonEnabled ? Colors.white : primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: buttonEnabled ? Colors.white : primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          buttonIcon,
                          size: 16,
                          color: buttonEnabled ? Colors.white : primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF0757C9)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF596579),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
