import 'package:flutter/material.dart';

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
        fontFamily: 'Arial',
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

  @override
  Widget build(BuildContext context) {
    // =====================================================
    // MEDIA QUERY
    // Mengambil ukuran layar perangkat
    // =====================================================

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      // ===================================================
      // SAFE AREA
      // Supaya konten tidak tertutup status bar / notch
      // ===================================================

      body: SafeArea(
        child: LayoutBuilder(
          // =================================================
          // LAYOUT BUILDER
          // Menyesuaikan layout berdasarkan ukuran layar
          // =================================================

          builder: (context, constraints) {
            // Jika layar kecil
            final bool isSmallScreen = constraints.maxWidth < 360;

            // Padding berdasarkan MediaQuery
            final double horizontalPadding =
                screenWidth < 360 ? 16 : 20;

            return Stack(
              children: [
                // =================================================
                // CONTENT UTAMA
                // =================================================

                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    screenHeight * 0.08,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildHeader(
                        isSmallScreen,
                      ),

                      SizedBox(
                        height: isSmallScreen ? 22 : 28,
                      ),

                      // =================================================
                      // JUDUL
                      // =================================================

                      Text(
                        'Daftar Tugas',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen ? 24 : 27,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF202D43),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Pantau tenggat waktu dan kumpulkan tugasmu tepat waktu.',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen ? 13 : 14,
                          height: 1.5,
                          color: const Color(0xFF71809A),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // TAB
                      // =================================================

                      _buildTabs(),

                      const SizedBox(height: 20),

                      // =================================================
                      // TUGAS 1
                      // =================================================

                      _buildTaskCard(
                        subject:
                            'Pendidikan Pancasila & Kewarganegaraan',
                        title:
                            'Analisis Nilai-Nilai Pancasila dalam Kehidupan Sehari-hari',
                        deadline:
                            '26 Apr 2025, 23:59 WIB',
                        remaining:
                            '2 hari 15 jam 00 menit',
                        completed: false,
                        isSmallScreen: isSmallScreen,
                      ),

                      const SizedBox(height: 14),

                      // =================================================
                      // TUGAS 2
                      // =================================================

                      _buildTaskCard(
                        subject:
                            'Ilmu Pengetahuan Alam (IPA)',
                        title:
                            'Laporan Praktikum Organ Pencernaan',
                        deadline:
                            '27 Mar 2025, 12:00 WIB',
                        remaining:
                            '3 hari 6 jam 00 menit',
                        completed: false,
                        isSmallScreen: isSmallScreen,
                      ),

                      SizedBox(
                        height: isSmallScreen ? 25 : 30,
                      ),

                      // =================================================
                      // SECTION SUDAH DIKUMPULKAN
                      // =================================================

                      Row(
                        children: [
                          Text(
                            'SUDAH DIKUMPULKAN',
                            style: TextStyle(
                              fontSize:
                                  isSmallScreen ? 11 : 12,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: 0.5,
                              color:
                                  const Color(0xFF8A9BB5),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFE4EAF3),
                              borderRadius:
                                  BorderRadius.circular(5),
                            ),
                            child: const Text(
                              '2',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color:
                                    Color(0xFF65748C),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // =================================================
                      // TUGAS SELESAI
                      // =================================================

                      _buildTaskCard(
                        subject: 'Bahasa Inggris',
                        title:
                            'Writing Practice: Recount Text about Last Holiday',
                        deadline:
                            '20 Mar 2025, 15:00 WIB',
                        remaining:
                            '✓  Dikumpulkan tepat waktu',
                        completed: true,
                        isSmallScreen: isSmallScreen,
                      ),

                      const SizedBox(height: 14),

                      _buildTaskCard(
                        subject:
                            'Seni Budaya & Prakarya',
                        title:
                            'Portofolio Gambar Ragam Hias Tradisional',
                        deadline:
                            '18 Mar 2025, 12:00 WIB',
                        remaining:
                            '✓  Dikumpulkan tepat waktu',
                        completed: true,
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  ),
                ),

                // =================================================
                // STACK
                // Floating Button
                // =================================================

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

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      children: [
        // Logo
        Container(
          width: isSmallScreen ? 43 : 48,
          height: isSmallScreen ? 43 : 48,
          decoration: BoxDecoration(
            color: const Color(0xFF3E70E8),
            borderRadius: BorderRadius.circular(
              isSmallScreen ? 13 : 15,
            ),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: isSmallScreen ? 24 : 27,
          ),
        ),

        const SizedBox(width: 10),

        // Nama aplikasi
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'LearnPoint',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17243D),
                ),
              ),
              Text(
                'E-LEARNING SMP',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1,
                  color: Color(0xFF7B889E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Notification
        Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF52617A),
                size: 23,
              ),
            ),

            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 7,
                height: 7,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFE5394F),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 7),

        // Profile
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE5F5),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xFF60718C),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // TABS
  // =========================================================

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
              margin:
                  const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF2864E8)
                    : const Color(0xFFE9EDF5),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight:
                      active
                          ? FontWeight.w700
                          : FontWeight.w500,
                  color: active
                      ? Colors.white
                      : const Color(0xFF63738E),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // TASK CARD
  // =========================================================

  Widget _buildTaskCard({
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE1E6EF),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            // Garis kiri
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius:
                    const BorderRadius.only(
                  topLeft:
                      Radius.circular(17),
                  bottomLeft:
                      Radius.circular(17),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                  isSmallScreen ? 14 : 16,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // ICON + SUBJECT
                    // ==========================================

                    Row(
                      children: [
                        Container(
                          width:
                              isSmallScreen
                                  ? 40
                                  : 43,
                          height:
                              isSmallScreen
                                  ? 40
                                  : 43,
                          decoration:
                              BoxDecoration(
                            color: completed
                                ? const Color(
                                    0xFFE8FFF6,
                                  )
                                : const Color(
                                    0xFFF0F4F9,
                                  ),
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),
                          child: Icon(
                            Icons
                                .description_outlined,
                            color: completed
                                ? const Color(
                                    0xFF10B981,
                                  )
                                : const Color(
                                    0xFF8A9CB6,
                                  ),
                            size:
                                isSmallScreen
                                    ? 20
                                    : 22,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            subject,
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              fontSize:
                                  isSmallScreen
                                      ? 11
                                      : 12,
                              color:
                                  const Color(
                                0xFF687995,
                              ),
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // BADGE
                    // ==========================================

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration:
                          BoxDecoration(
                        color: completed
                            ? const Color(
                                0xFFD6F8E9,
                              )
                            : const Color(
                                0xFFFFEDC6,
                              ),
                        borderRadius:
                            BorderRadius.circular(
                          5,
                        ),
                      ),
                      child: Text(
                        completed
                            ? 'SELESAI'
                            : 'TUGAS',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen
                                  ? 8
                                  : 9,
                          fontWeight:
                              FontWeight.w800,
                          color: completed
                              ? const Color(
                                  0xFF079762,
                                )
                              : const Color(
                                  0xFFD68600,
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ==========================================
                    // TITLE
                    // ==========================================

                    Text(
                      title,
                      style: TextStyle(
                        fontSize:
                            isSmallScreen
                                ? 14
                                : 15,
                        height: 1.35,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            const Color(
                          0xFF202D43,
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    // ==========================================
                    // DEADLINE
                    // ==========================================

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .access_time_rounded,
                          size: 15,
                          color:
                              Color(0xFF98A6B9),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Deadline: $deadline',
                            style: TextStyle(
                              fontSize:
                                  isSmallScreen
                                      ? 10.5
                                      : 11.5,
                              color:
                                  const Color(
                                0xFF98A6B9,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // STATUS
                    // ==========================================

                    Align(
                      alignment:
                          Alignment.centerRight,
                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFE9FFF5,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(20),
                          border: Border.all(
                            color:
                                const Color(
                              0xFFC9F4E2,
                            ),
                          ),
                        ),
                        child: Text(
                          remaining,
                          style: TextStyle(
                            fontSize:
                                isSmallScreen
                                    ? 9.5
                                    : 10.5,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                const Color(
                              0xFF0AA66B,
                            ),
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
    );
  }

  // =========================================================
  // FLOATING BUTTON
  // =========================================================

  Widget _buildFloatingButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
        onTap: () {
          // Aksi tombol
        },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF2864E8),
            borderRadius:
                BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF2864E8)
                        .withOpacity(0.3),
                blurRadius: 12,
                offset:
                    const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.search,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }
}