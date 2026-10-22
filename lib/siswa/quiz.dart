import 'package:flutter/material.dart';

import 'materimapel.dart';
import 'changepass.dart';
import 'notifikasi.dart';
import '../models/student_profile_model.dart';
import '../models/materi_page.dart';
import 'widgets/dashboard_header_widget.dart';
import 'widgets/quiz_parallax_background_widget.dart';
import 'widgets/quiz_top_decoration_widget.dart';
import 'widgets/quiz_subject_list_section_widget.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  // Dummy Profile Data
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  // Menyimpan perubahan posisi scroll untuk menggerakkan stars1.png
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topBgHeight = screenHeight * 0.60 + 25;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Layer Background Parallax (spacebg1, stars1, lands)
            QuizParallaxBackgroundWidget(
              topBgHeight: topBgHeight,
              scrollOffset: _scrollOffset,
            ),

            // 2. Layer Konten Utama
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: DashboardHeaderWidget(
                    profile: studentProfile,
                    onNotificationTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                    onProfileTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const Changepass(),
                        ),
                      );
                    },
                  ),
                ),

                Expanded(
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      final delta = notification.scrollDelta ?? 0.0;
                      _scrollOffset.value = (_scrollOffset.value + delta).clamp(
                        0.0,
                        1000.0,
                      );
                      return false;
                    },
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) => const [
                        SliverToBoxAdapter(
                          child: QuizTopDecorationWidget(),
                        ),
                      ],
                      // Daftar mata pelajaran / kuis
                      body: QuizSubjectListSectionWidget(
                        subjects: subjek,
                        onSubjectTap: (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Materimapel(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
