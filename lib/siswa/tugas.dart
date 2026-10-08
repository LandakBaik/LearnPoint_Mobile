import 'package:flutter/material.dart';

import '../models/student_profile_model.dart';
import 'widgets/header_profile_widget.dart';
import 'widgets/inverted_top_curve_clipper.dart';
import 'widgets/task_card_widget.dart';
import '../models/task_model.dart';
import 'notifikasi.dart';

// Data Dummy Lengkap Sesuai UI Desain
final List<TaskModel> defaultTaskList = [
  // --- BELUM DIKUMPULKAN ---
  TaskModel(
    id: "1",
    subject: "Matematika",
    title: "Latihan Soal : Teorema Pythagoras & Trigonometri",
    deadline: "Tenggat: 24 Mar 2025, 23:59 WIB",
    timeRemainingTag: "Terlambat",
    subjectColor: Colors.redAccent,
    accentBorderColor: Colors.red,
    icon: Icons.edit_note,
    iconBgColor: Colors.red.shade50,
    footerNote: "Segera selesaikan",
    isSubmitted: false,
  ),

  // --- SUDAH DIKUMPULKAN ---
  TaskModel(
    id: "3",
    subject: "B. INGGRIS",
    title: "Writing about Last Holiday",
    deadline: "Dikumpulkan pada 19 Mar 2025, 14:15 WIB",
    timeRemainingTag: "Tepat Waktu",
    subjectColor: Colors.teal,
    accentBorderColor: Colors.green,
    icon: Icons.check_circle_outline,
    iconBgColor: Colors.green.shade50,
    isSubmitted: true,
    score: "92 / 100",
  ),
  TaskModel(
    id: "4",
    subject: "SENI BUDAYA",
    title: "Portofolio Gambar Ragam Hias Tradisional",
    deadline: "Dikumpulkan pada 17 Mar 2025, 20:00 WIB",
    timeRemainingTag: "Tepat Waktu",
    subjectColor: Colors.teal,
    accentBorderColor: Colors.green,
    icon: Icons.check_circle_outline,
    iconBgColor: Colors.green.shade50,
    isSubmitted: true,
    footerNote: "Status: Sedang Dinilai Guru",
  ),
];

class TugasScreen extends StatefulWidget {
  final List<TaskModel>? tasks;

  const TugasScreen({
    super.key,
    this.tasks,
  });

   static final StudentProfileModel studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A', // atau className sesuai nama properti di modelmu
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final allTasks = widget.tasks ?? defaultTaskList;
    final pendingTasks = allTasks.where((task) => !task.isSubmitted).toList();
    final completedTasks = allTasks.where((task) => task.isSubmitted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Background abu-abu soft
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: HeaderProfileWidget(
                  profile: TugasScreen.studentProfile,
                  onNotificationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                       builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
              ),

                // 1. HEADER UTAMA
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.04,
                    16,
                    screenWidth * 0.04,
                    8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Badge Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Daftar Tugas",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Kelola & pantau semua tenggat belajarmu",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              "${allTasks.length} Total",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Input Search
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                            hintText: "Cari tugas...",
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. TABBAR FILTER (Semua, Belum Dikumpulkan, Sudah Dikumpulkan)
                Container(
                  color: const Color(0xFFF1F5F9),
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: EdgeInsets.zero,
                    indicatorColor: const Color(0xFF2563EB),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF2563EB),
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(text: "Semua"),
                      Tab(text: "Belum Dikumpulkan"),
                      Tab(text: "Sudah Dikumpulkan"),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // 3. TABBAR VIEW CONTENT
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: SEMUA TUGAS (Sama persis seperti di gambar)
                      _buildAllTasksTab(
                        allTasks: allTasks,
                        pendingTasks: pendingTasks,
                        completedTasks: completedTasks,
                        screenWidth: screenWidth,
                      ),

                      // TAB 2: BELUM DIKUMPULKAN
                      _buildTaskListOnly(pendingTasks, screenWidth),

                      // TAB 3: SUDAH DIKUMPULKAN
                      _buildTaskListOnly(completedTasks, screenWidth),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // WIDGET KONTEN UTAMA TAB "SEMUA"
  Widget _buildAllTasksTab({
    required List<TaskModel> allTasks,
    required List<TaskModel> pendingTasks,
    required List<TaskModel> completedTasks,
    required double screenWidth,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub Header: Menampilkan X Tugas & Tombol Urutkan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Menampilkan ${allTasks.length} Tugas",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.tune, size: 14, color: Color(0xFF64748B)),
                    SizedBox(width: 4),
                    Text(
                      "Urutkan",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // SECTION 1: TUGAS BELUM DIKUMPULKAN
          if (pendingTasks.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.circle, color: Colors.redAccent, size: 8),
                    SizedBox(width: 6),
                    Text(
                      "TUGAS BELUM DIKUMPULKAN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Lihat semua",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...pendingTasks.map((task) => TaskCardWidget(task: task, onTap: () {})),
            const SizedBox(height: 16),
          ],

          // SECTION 2: SUDAH DIKUMPULKAN
          if (completedTasks.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 8),
                    const SizedBox(width: 6),
                    const Text(
                      "SUDAH DIKUMPULKAN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${completedTasks.length} Selesai",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
              ],
            ),
            const SizedBox(height: 10),
            ...completedTasks.map((task) => TaskCardWidget(task: task, onTap: () {})),
            const SizedBox(height: 16),
          ],

          // BANNER "Butuh Kisi-Kisi Tambahan?"
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.help_outline, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Butuh Kisi-Kisi Tambahan?",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Unduh modul latihan dari gurumu",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // WIDGET HELPER TAB TUGAS TUNGGAL
  Widget _buildTaskListOnly(List<TaskModel> tasks, double screenWidth) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada tugas di kategori ini",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 12,
      ),
      child: Column(
        children: tasks.map((task) => TaskCardWidget(task: task, onTap: () {})).toList(),
      ),
    );
  }
}