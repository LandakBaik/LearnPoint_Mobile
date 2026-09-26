import 'package:flutter/material.dart';

import '../models/student_profile_model.dart';
import '../models/task_model.dart';
import '../models/material_model.dart';
import '../models/schedule_model.dart';
import 'notifikasi.dart';

import '../widget/section_header.dart';
import 'widgets/header_profile_widget.dart';
import 'widgets/hero_banner_widget.dart';
import 'widgets/task_card_widget.dart';
import 'widgets/material_card_widget.dart';
import 'widgets/schedule_table_widget.dart';

class SiswaDashboardScreen extends StatelessWidget {
  const SiswaDashboardScreen({super.key});

  // Dummy Profile Data
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  // Dummy Tasks Data
  static final List<TaskModel> upcomingTasks = [
    const TaskModel(
      id: 't1',
      subject: 'Matematika',
      title: 'Persamaan Linear',
      deadline: 'Besok (23:59 WIB)',
      timeRemainingTag: '23 Jam Lagi',
      subjectColor: Color(0xFF2563EB),
      accentBorderColor: Color(0xFF2563EB),
      icon: Icons.grid_view_rounded,
      iconBgColor: Color(0xFFDBEAFE),
    ),
    const TaskModel(
      id: 't2',
      subject: 'IPA Terpadu',
      title: 'Sistem Organisasi Kehidupan',
      deadline: 'Rabu, 24 Sep',
      timeRemainingTag: '2 Hari Lagi',
      subjectColor: Color(0xFF16A34A),
      accentBorderColor: Color(0xFF16A34A),
      icon: Icons.science_outlined,
      iconBgColor: Color(0xFFDCFCE7),
    ),
  ];

  // Dummy Materials Data
  static final List<MaterialModel> latestMaterials = [
    const MaterialModel(
      id: 'm1',
      subject: 'Matematika',
      title: 'Sistem Persamaan...',
      typeLabel: 'Materi • Video',
      typeIcon: Icons.play_circle_outline_rounded,
    ),
    const MaterialModel(
      id: 'm2',
      subject: 'IPA Terpadu',
      title: 'Struktur Sel &...',
      typeLabel: 'Materi • PDF',
      typeIcon: Icons.insert_drive_file_outlined,
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
    const ScheduleItemModel(
      day: "Jum'at",
      time: '13.00 WIB',
      duration: '2 Jam',
      subject: 'Workshop Basis Data',
      room: 'GEDUNG TEKNOLOGI INFORMASI - KELAS TI 3.6',
      teacher: 'Fatimatuzzahra S.Kom., M.Kom.',
    ),
    const ScheduleItemModel(
      day: 'Kamis',
      time: '09.00 WIB',
      duration: '2 Jam',
      subject: 'Workshop Mobile Application',
      room: 'GEDUNG TEKNOLOGI INFORMASI - LAB REKAYASA PERANGKAT LUNAK',
      teacher: 'Choirul Huda S.Kom., M.Kom.',
    ),
    const ScheduleItemModel(
      day: 'Kamis',
      time: '13.00 WIB',
      duration: '2 Jam',
      subject: 'Workshop Pengembangan Website',
      room: 'GEDUNG TEKNOLOGI INFORMASI - LAB REKAYASA PERANGKAT LUNAK',
      teacher: 'Hermawan Arief S.T., M.T.',
    ),
    const ScheduleItemModel(
      day: 'Kamis',
      time: '15.00 WIB',
      duration: '2 Jam',
      subject: 'Workshop Pengembangan Website',
      room: 'GEDUNG TEKNOLOGI INFORMASI - LAB REKAYASA PERANGKAT LUNAK',
      teacher: 'Hermawan Arief S.T., M.T.',
    ),
    const ScheduleItemModel(
      day: 'Rabu',
      time: '09.00 WIB',
      duration: '2 Jam',
      subject: 'Workshop Basis Data',
      room: 'GEDUNG TEKNOLOGI INFORMASI - KELAS TI 3.6',
      teacher: 'Fatimatuzzahra S.Kom., M.Kom.',
    ),
    const ScheduleItemModel(
      day: 'Selasa',
      time: '09.00 WIB',
      duration: '2 Jam',
      subject: 'Workshop Mobile Application',
      room: 'GEDUNG TEKNOLOGI INFORMASI - LAB REKAYASA PERANGKAT LUNAK',
      teacher: 'Choirul Huda S.Kom., M.Kom.',
      isToday: true,
    ),
    const ScheduleItemModel(
      day: 'Selasa',
      time: '13.00 WIB',
      duration: '2 Jam',
      subject: 'Workshop Pengembangan Website',
      room: 'GEDUNG TEKNOLOGI INFORMASI - LAB REKAYASA PERANGKAT LUNAK',
      teacher: 'Hermawan Arief S.T., M.T.',
      isToday: true,
    ),
    const ScheduleItemModel(
      day: 'Selasa',
      time: '15.00 WIB',
      duration: '2 Jam',
      subject: 'Workshop Pengembangan Website',
      room: 'GEDUNG TEKNOLOGI INFORMASI - LAB REKAYASA PERANGKAT LUNAK',
      teacher: 'Hermawan Arief S.T., M.T.',
      isToday: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Profile & Notifications
              HeaderProfileWidget(
                profile: studentProfile,
                onNotificationTap: () => _openNotifications(context),
              ),

              const SizedBox(height: 16),

              // 2. Hero Banner Card
              const HeroBannerWidget(
                title: 'Mau belajar apa\nhari ini?',
                subtitle: 'Yuk lanjutkan kegiatan\nbelajarmu.',
                timeString: '06:30',
              ),

              const SizedBox(height: 24),

              // 3. Section: Tugas Mendatang
              SectionHeader(
                title: 'Tugas Mendatang',
                onActionTap: () {},
              ),

              const SizedBox(height: 12),

              ...upcomingTasks.map(
                (task) => TaskCardWidget(
                  task: task,
                  onTap: () {},
                ),
              ),

              const SizedBox(height: 20),

              // 4. Section: Materi Terbaru
              SectionHeader(
                title: 'Materi Terbaru',
                onActionTap: () {},
              ),

              const SizedBox(height: 12),

              Row(
                children: latestMaterials.map((mat) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: mat == latestMaterials.first ? 8.0 : 0.0,
                        left: mat == latestMaterials.last ? 8.0 : 0.0,
                      ),
                      child: MaterialCardWidget(
                        material: mat,
                        onTap: () {},
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 5. Section: Jadwal
              SectionHeader(
                title: 'Jadwal',
                onActionTap: () {},
              ),

              const SizedBox(height: 12),

              ScheduleTableWidget(
                schedules: schedules,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static void _openNotifications(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationScreen()));
  }
}
