import 'package:flutter/material.dart';

// nama    : IDEA BRILIANTA
// nim     : E41251668
// kelompok: 2
// golongan: E

import '../models/materi_page.dart';
import '../models/student_profile_model.dart';
import 'changepass.dart';
import 'notifikasi.dart';
import 'widgets/dashboard_header_widget.dart';
import 'widgets/materi_header_widget.dart';
import 'widgets/materi_section.dart';

class Materimapel extends StatelessWidget {
  final VoidCallback? onBackTap;
  final MateriModel? subject;

  const Materimapel({
    super.key,
    this.onBackTap,
    this.subject,
  });

  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final subjectName = subject?.materi ?? 'Matematika';
    final description = subject?.description ?? 'Angka, rumus, dan logika';

    return Scaffold(
      backgroundColor: const Color(0xFF6336ED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: onBackTap ?? () => Navigator.maybePop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(
                  screenwidth * 0.04,
                  24,
                  screenwidth * 0.04,
                  0,
                ),
                child: MateriHeaderWidget(
                  subjectName: subjectName,
                  description: description,
                ),
              ),
              MateriSectionWidget(
                mapelId: subject?.id,
                subjectName: subjectName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
