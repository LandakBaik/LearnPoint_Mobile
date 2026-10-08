import 'package:flutter/material.dart';

import 'soal_ujian.dart';

// ============================================================
// COLORS
// ============================================================

const Color primaryBlue = Color(0xFF0757C9);
const Color darkText = Color(0xFF13233A);
const Color secondaryText = Color(0xFF596579);
const Color lightBlue = Color(0xFFEAF4FF);
const Color cardBlue = Color(0xFFF0F5FF);

// ============================================================
// NAMA: ABDUL AZIZ NURULLAH
// NIM : E412518866
// GOL : E
// ============================================================

class UjianScreen extends StatefulWidget {
  const UjianScreen({super.key});

  @override
  State<UjianScreen> createState() => _UjianScreenState();
}

class _UjianScreenState extends State<UjianScreen> {
  int selectedFilter = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  final List<String> filters = ['Semua (6)', 'Urutkan: Terbaru'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildPageTitle()),
                  SliverToBoxAdapter(child: _buildSearch()),
                  SliverToBoxAdapter(child: _buildFilter()),
                  SliverToBoxAdapter(child: _buildTaskBanner()),
                  SliverToBoxAdapter(
                    child: _buildQuizCard(
                      type: 'UJIAN',
                      subject: 'IPA',
                      grade: 'Kelas VIII',
                      title: 'Sistem Pernapasan pada\nManusia',
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
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuizCard(
                      type: 'UJIAN',
                      subject: 'Matematika',
                      grade: 'Kelas VIII',
                      title: 'Ujian Tengah Semester\n(UTS)',
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
                      buttonEnabled: false,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuizCard(
                      type: 'UJIAN',
                      subject: 'Matematika',
                      grade: 'Kelas VIII',
                      title: 'Persamaan Linear Satu\nVariabel',
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
                      buttonText: '',
                      buttonIcon: Icons.check,
                      buttonEnabled: false,
                      completed: true,
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildHelpCard()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: const Icon(Icons.menu, color: darkText, size: 25),
          ),
          const SizedBox(width: 5),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 7),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LearnPoint',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                    height: 1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'E-LEARNING SMP',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0872B4),
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: darkText,
                  size: 24,
                ),
              ),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 3),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildPageTitle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBEAFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 13,
                      color: Color(0xFF0874AD),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'T.A. 2024/2025 Genap',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0874AD),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Flexible(
                child: Text(
                  'SMP Negeri 1 Cerdas',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0874AD),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Halaman Ujian',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: darkText,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Uji pemahamanmu melalui ujian yang tersedia',
            style: TextStyle(fontSize: 12, color: secondaryText, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Container(
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: Color(0xFF7C8799),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchText = '';
                });
              },
              icon: const Icon(Icons.tune, size: 18, color: Color(0xFF7C8799)),
            ),
            hintText: 'Cari ujian...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF7C8799)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilter() {
    return SizedBox(
      height: 43,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final bool selected = selectedFilter == index;

          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: selected ? primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    if (index == 1) ...[
                      Icon(
                        Icons.swap_vert,
                        size: 15,
                        color: selected ? Colors.white : primaryBlue,
                      ),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      filters[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF39445A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // TASK BANNER
  // ============================================================

  Widget _buildTaskBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E1FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERFORMA BELAJAR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Tugas Perlu Aksi Segera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Selesaikan sebelum batas waktu berakhir hari ini!',
                  style: TextStyle(
                    fontSize: 10,
                    color: secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: primaryBlue,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUIZ CARD
  // ============================================================

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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 7),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuizStartPage(),
                              ),
                            );
                          }
                        : null, // dinonaktifkan sementara
                    style: TextButton.styleFrom(
                      backgroundColor: buttonEnabled
                          ? primaryBlue
                          : const Color(0xFFD7E5FF),
                      foregroundColor: buttonEnabled
                          ? Colors.white
                          : primaryBlue,
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

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: primaryBlue),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              color: secondaryText,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HELP CARD
  // ============================================================

  Widget _buildHelpCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFDDEAFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh Kisi-Kisi Tambahan?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Unduh modul latihan dari gurumu',
                  style: TextStyle(fontSize: 9, color: secondaryText),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFD4E5FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward,
              size: 18,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
