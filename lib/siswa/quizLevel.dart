import 'package:flutter/material.dart';

import 'changepass.dart';
import 'notifikasi.dart';
import '../models/student_profile_model.dart';
import '../models/quiz_per_mapel.dart';
import '../models/quiz_level_model.dart';
import 'widgets/dashboard_header_widget.dart';
import 'widgets/quiz_level_map_section_widget.dart';

class QuizLevel extends StatefulWidget {
  final QuizPerMapelM? themeItem;

  const QuizLevel({
    super.key,
    this.themeItem,
  });

  @override
  State<QuizLevel> createState() => _QuizLevelState();
}

class _QuizLevelState extends State<QuizLevel> {
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  Widget build(BuildContext context) {
    final themeTitle = widget.themeItem?.title ?? 'Geometri';
    final themeColor = widget.themeItem?.color ?? const Color(0xFF4338CA);

    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Atas
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

            // 2. Konten Utama Peta Level
            Expanded(
              child: QuizLevelMapSectionWidget(
                themeTitle: themeTitle,
                themeColor: themeColor,
                levels: quizLevels,
                onLevelTap: (_) {},
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
