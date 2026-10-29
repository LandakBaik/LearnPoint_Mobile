import 'package:flutter/material.dart';

import 'changepass.dart';
import 'notifikasi.dart';
import 'quizLevel.dart';
import '../models/student_profile_model.dart';
import '../models/materi_page.dart';
import '../models/quiz_per_mapel.dart';
import 'widgets/dashboard_header_widget.dart';
import 'widgets/quiz_theme_list_section_widget.dart';
import 'widgets/quiz_character_area_widget.dart';

class QuizPerMapel extends StatefulWidget {
  final MateriModel? subject;

  const QuizPerMapel({super.key, this.subject});

  @override
  State<QuizPerMapel> createState() => _QuizPerMapelState();
}

class _QuizPerMapelState extends State<QuizPerMapel> {
  final ScrollController _scrollController = ScrollController();

  // Dummy Profile Data
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectTitle = widget.subject?.materi ?? 'Matematika';

    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      body: SafeArea(
        child: Stack(
          children: [
            // Layer Background
            Positioned.fill(
              child: Container(color: const Color(0xFF4338CA)),
            ),

            // Layer Konten Utama
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Atas menggunakan template DashboardHeaderWidget
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

                // 2. Konten Utama: Daftar Pilihan Quiz (Lingkaran Kiri-Kanan dengan Background Looping)
                Expanded(
                  child: QuizThemeListSectionWidget(
                    subjectTitle: subjectTitle,
                    themes: quizMapel,
                    scrollController: _scrollController,
                    onThemeTap: (item) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizLevel(themeItem: item),
                        ),
                      );
                    },
                  ),
                ),

                // 3. Area Karakter User di bagian bawah layar
                const QuizCharacterAreaWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
