import 'package:flutter/material.dart';

import '../models/student_profile_model.dart';
import '../models/task_model.dart';
import '../models/material_model.dart';
import '../models/schedule_model.dart';

import '../widget/section_header.dart';
import 'widgets/dashboard_header_widget.dart';
import 'widgets/task_card_widget.dart';
import 'widgets/material_card_widget.dart';
import 'widgets/schedule_table_widget.dart';

class SiswaDashboardScreen extends StatelessWidget {
  const SiswaDashboardScreen({super.key});

  // Dummy Profile Data disesuaikan persis dengan tampilan desain
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu putra',
    gradeClass: '7-A',
    schoolName: 'SMPN 14 Jember',
    initials: 'AP',
    hasNotification: true,
  );

  // Dummy Tasks Data (Tugas Mendatang)
  static final List<TaskModel> upcomingTasks = [
    const TaskModel(
      id: 't1',
      subject: 'Matematika',
      title: 'Persamaan Linear',
      deadline: 'Besok (23:59 WIB)',
      timeRemainingTag: '23 Jam Lagi',
      subjectColor: Color(0xFF4F46E5),
      accentBorderColor: Color(0xFF4F46E5),
      icon: Icons.grid_view_rounded,
      iconBgColor: Color(0xFFEDE9FE),
    ),
    const TaskModel(
      id: 't2',
      subject: 'IPA Terpadu',
      title: 'Sistem Organisasi Kehidupan',
      deadline: 'Rabu, 24 Sep',
      timeRemainingTag: '2 Hari Lagi',
      subjectColor: Color(0xFF059669),
      accentBorderColor: Color(0xFF059669),
      icon: Icons.indeterminate_check_box_outlined,
      iconBgColor: Color(0xFFDCFCE7),
    ),
  ];

  // Dummy Materials Data (Materi Terbaru)
  static final List<MaterialModel> latestMaterials = [
    const MaterialModel(
      id: 'm1',
      subject: 'Matematika',
      title: 'Sistem Persamaan...',
      typeLabel: 'Materi • Video',
      typeIcon: Icons.play_circle_outline_rounded,
      duration: '15 Menit',
      imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=500&q=80',
      subjectColor: Color(0xFF4F46E5),
    ),
    const MaterialModel(
      id: 'm2',
      subject: 'IPA Terpadu',
      title: 'Struktur Sel &...',
      typeLabel: 'Materi • PDF',
      typeIcon: Icons.insert_drive_file_outlined,
      duration: '20 Menit',
      imageUrl: 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=500&q=80',
      subjectColor: Color(0xFF059669),
    ),
  ];

  // Dummy Schedule Data
  static final List<ScheduleItemModel> schedules = [
    const ScheduleItemModel(
      day: "Jum'at",
      time: '15.00 WIB',
      duration: '2 Jam',
      subject: 'Workshop Basis Data',
      room: 'GEDUNG TEKNOLOGI INFORMASI - KELAS TI 3.6',
      teacher: 'Fatimatuzzahra S.Kom., M.Kom.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Menggunakan MediaQuery 
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      // 2. Menggunakan SafeArea
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: mediaQuery.padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3730A3),
                      Color(0xFF4338CA),
                      Color(0xFF4F46E5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: DashboardHeaderWidget(
                  profile: studentProfile,
                  onNotificationTap: () {},
                  onProfileTap: () {},
                ),
              ),

              // ========================================
              // KONTEN DASHBOARD (CONTAINER PUTIH MELENGKUNG)
              // ========================================
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: mediaQuery.size.width > 600 ? 28.0 : 18.0,
                    vertical: 24.0,
                  ),
                  // 3. Menggunakan LayoutBuilder untuk layouting yang presisi dan responsif
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 12) / 2;
                      final gridAspectRatio = (itemWidth / 170).clamp(
                        0.80,
                        1.05,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ========================================
                          // HERO GREETING TEXT
                          // ========================================
                          const Text(
                            'Mau belajar apa hari ini?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Yuk lanjutkan kegiatan belajarmu.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ========================================
                          // TUGAS MENDATANG (LIST VIEW)
                          // ========================================
                          SectionHeader(
                            title: 'Tugas Mendatang',
                            onActionTap: () {},
                          ),

                          const SizedBox(height: 12),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: upcomingTasks.length,
                            itemBuilder: (context, index) {
                              return TaskCardWidget(
                                task: upcomingTasks[index],
                                onTap: () {},
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          // ========================================
                          // MATERI TERBARU (GRID VIEW 2 ROW / 2 COLS)
                          // ========================================
                          SectionHeader(
                            title: 'Materi Terbaru',
                            onActionTap: () {},
                          ),

                          const SizedBox(height: 12),

                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: gridAspectRatio,
                                ),
                            itemCount: latestMaterials.length,
                            itemBuilder: (context, index) {
                              return MaterialCardWidget(
                                material: latestMaterials[index],
                                onTap: () {},
                              );
                            },
                          ),

                          const SizedBox(height: 22),

                          // ========================================
                          // SCHEDULE TABLE DI BAWAH MATERI TERBARU
                          // ========================================
                          SectionHeader(
                            title: 'Jadwal Pelajaran',
                            onActionTap: () {},
                          ),

                          const SizedBox(height: 12),

                          ScheduleTableWidget(schedules: schedules),

                          const SizedBox(height: 28),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
